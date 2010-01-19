//
//  NetOpponent.m
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "BluetoothOpponent.h"
#import "NetOpponent.h"
#import "W2Utilities.h"

enum {
	kNetworkEventCointoss       = 1 << 0,
    kNetworkEventPingEvent      = 1 << 1,
    kNetworkEventHeartbeat      = 1 << 2
};
typedef NSInteger NetworkEventType;

static NSString *descriptionforNetworkEvent(NetworkEventType t)
{
    switch (t) {
        case kNetworkEventCointoss:
            return @"Cointoss";
            break;
        case kNetworkEventHeartbeat:
            return @"Hearbeat";
            break;
        case kNetworkEventPingEvent:
            return @"Ping";
        default:
            [NSException raise:@"InvalidNetworkEvent" format:@"event type was invalid"];
            break;
    }
    return nil;
}

static NSString * const kPongSessionID = @"iPong";

@interface BluetoothOpponent ()

- (void)_didConnectWithPeer:(NSString*)peer;
- (GKSession*)_makeSession;
- (void)_invalidateSession;
- (void)_sendStateChange;
- (void)_sendNetworkDict:(NSMutableDictionary*)dict withType:(NetworkEventType)t;
- (void)_dismissAlertWithAnimation:(BOOL)doAnimation;
- (void)_heartbeatCheck;
- (void)_scheduleHeartbeatCheck;
- (void)_didLoseConnection;

@property (retain) NSDate *lastHeartbeatDate;
@property (retain) GKSession *session;
@property (retain) GKPeerPickerController *picker;
@property (copy) NSString *opponentGamePeerId;
@property (retain) NSTimer *heartbeatTimer;
@property (retain) UIAlertView *connectionAlert;
@property (retain) NSString *myName;
@property (retain) NSString *opponentName;
@end

@implementation BluetoothOpponent
@synthesize connectionAlert, delegate;
@synthesize lastHeartbeatDate, networkState, heartbeatTimer;
@synthesize picker, session, opponentGamePeerId, heartbeatInterval;
@synthesize myName, opponentName;

#pragma mark NetOpponent protocol methods
- (BOOL)doesWinCointoss
{
    if (networkState < kNetworkStateConnected) {
        [NSException raise:@"networkStateNotConnected" format:@"networkState is not yet connected"];
    }
    return doesWinCointoss;
}

/** Find opponents using either PeerPicker or setting client/server manually, as
    GameKit on the simulator doesn't work with PeerMode. */
- (void)findOpponents
{
    if (networkState != kNetworkStateDisconnected) {
        [self disconnect];
    }
    
    [self _dismissAlertWithAnimation:NO];

#ifdef DEBUG
    LogTo(Opponent, @"creating manual GKSession");
    self.session = [self _makeSession];
    session.delegate = self;
    session.available = YES;
#else
    self.picker = [[[GKPeerPickerController alloc] init] autorelease];
	picker.delegate = self;
	[picker show]; // show the Peer Picker
#endif
    
    networkState = kNetworkStateFinding;
    [self _sendStateChange];
}

- (void)disconnect
{
    if ([picker isVisible]) {
        // should call - (void)peerPickerControllerDidCancel:(GKPeerPickerController *)p
        // and in turn [self invalidateSession]
        [picker dismiss];
        picker.delegate = nil;
        self.picker = nil;
    } else {
        [self _invalidateSession];
    }
    
    [self _dismissAlertWithAnimation:NO];
    
    networkState = kNetworkStateDisconnected;
}

#pragma mark Opponent protocol methods

/** By send, this means the opponent 'receives' an event from the GUI. In other words,
 a network packet send. */
- (void)sendPongEvent:(PongEvent*)p
{
    AssertEq(networkState,kNetworkStateConnected);
    
    NSMutableDictionary *netEvent = [NSMutableDictionary dictionaryWithObject:p forKey:@"pongEvent"];
    [self _sendNetworkDict:netEvent withType:kNetworkEventPingEvent];
}

- (NSString*)humanReadableName
{
    return opponentName;
}

- (NSString*)machineName
{
    return opponentGamePeerId;
}

#pragma mark GKPeerPickerControllerDelegate methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)p 
{ 
    AssertEqual(p,picker);
    AssertEq(networkState,kNetworkStateFinding);
    
    LogTo(Opponent, @"canceled picker");
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// release this picker. 
    [picker dismiss];
	picker.delegate = nil;
    self.picker = nil;
    networkState = kNetworkStateDisconnected;
	
	// invalidate and release game session if one is around.
    [self _invalidateSession];
    
    // Inform our delegate that our user canceled this prompt, so it can programmatically
    // choose to start finding another opponent.
    [self _sendStateChange];
}

/* TODO: probably don't need this as PeerPicker does this for us. */
- (GKSession *)peerPickerController:(GKPeerPickerController *)p 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    self.session = [self _makeSession];
    session.delegate = self;

    /* this method only works when GKSession is a peer. */
    AssertEq(session.sessionMode, GKSessionModePeer);
	return session;
}

/** informs us when a peer connects to us. This method should fire once since we
    stop advertising in this method's implementation. */
- (void)peerPickerController:(GKPeerPickerController *)p 
              didConnectPeer:(NSString *)opponentPeerId 
                   toSession:(GKSession *)sess
{
    AssertEq(sess, session);
    AssertEq(networkState, kNetworkStateFinding);
    
    picker.delegate = nil;

    [self _didConnectWithPeer:opponentPeerId];
} 

#pragma mark GKSessionDelegate methods

/** PeerPicker typically handles this for us, but if we're testing we need to accept
    connections manually. */
- (void)session:(GKSession *)s didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    AssertEq(s, session);
#ifdef DEBUG
    AssertEq(s.sessionMode, GKSessionModeServer);
    NSString *pName = [s displayNameForPeer:peerID];        

    if (networkState == kNetworkStateFinding) {
        if ([s acceptConnectionFromPeer:peerID error:nil]) {
            LogTo(Opponent, @"Successfully connected to peer '%@'", pName);
            session.available = NO;
            [self _didConnectWithPeer:peerID];            
        } else {
            LogTo(Opponent, @"problem with accepting connection to '%@'");
        }
    } else {
        LogTo(Opponent, @"Already received a connection request, won't fulfill this one from '%@'", pName);
        [s denyConnectionFromPeer:peerID];
    }
#endif
}

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer 
          inSession:(GKSession *)session 
            context:(void *)context 
{ 
    AssertEqual(peer,opponentGamePeerId);
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NetworkEventType eventType = [[dict objectForKey:@"eventType"] integerValue];
    NSInteger packetNum = [[dict objectForKey:@"packetNum"] integerValue];
    LogTo(Opponent,@"received network event %@, packet# %d",descriptionforNetworkEvent(eventType), packetNum);
    
    // check to make sure packet numbering in monotonically increasing
    static NSInteger lastReceivedPacketNum = -1;
	if(packetNum < lastReceivedPacketNum) {
        LogTo(Opponent, @"threw out packet due to invalid packet num");
		return;	
	}
    
    lastReceivedPacketNum = packetNum;

    // If any network info is received, we want to connect if we were reconnecting. 
    if (networkState == kNetworkStateReconnecting) {
        LogTo(Opponent, @"reconnected after trying to reconnect");
        [self _dismissAlertWithAnimation:YES];
        networkState = kNetworkStateConnected;
        [self _sendStateChange];
    }
    
    switch (eventType) {
        case kNetworkEventPingEvent: {
            // TODO: should probably do some more type checking here
            PongEvent *event = [dict objectForKey:@"pongEvent"];
            [delegate opponentEventDidOccur:event];
        }
            break;
        case kNetworkEventCointoss: {
            if (networkState != kNetworkStateCointoss || ![dict objectForKey:@"doesWinCointoss"]) {
                Warn(@"Received networkEventCointoss packet when not in cointoss state or invalid");
                return;
            }
            doesWinCointoss = [[dict objectForKey:@"doesWinCointoss"] boolValue];
            LogTo(Opponent,@"opponent %@ cointoss",doesWinCointoss ? @"won" : @"lost");

#ifndef DEBUG
            [picker dismiss];
            self.picker = nil;
#endif
            
            [self _scheduleHeartbeatCheck];
            
            networkState = kNetworkStateConnected;
            [self _sendStateChange];
        }
            break;
        case kNetworkEventHeartbeat: {
            self.lastHeartbeatDate = [NSDate date];
        }
            break;
        default: {
            // otherwise we don't know what this packet is; toss it out
            return;
        }
            break;
    }    
}

// we've gotten a state change in the session
- (void)session:(GKSession *)s 
           peer:(NSString *)peerID 
 didChangeState:(GKPeerConnectionState)state
{
    AssertEqual(s, session);
#ifdef DEBUG
    if (networkState == kNetworkStateFinding && s.sessionMode == GKSessionModeClient) {
        if (state == GKPeerStateAvailable) {
            LogTo(Opponent, @"found '%@', attempting to connect", [s displayNameForPeer:peerID]);
            // wait 20 seconds to connect. This will fail hard if we timeout, but won't be in production code. 
            [s connectToPeer:peerID withTimeout:20];             
        } else if (state == GKPeerStateConnected) {
            session.available = NO;
            [self _didConnectWithPeer:peerID];
        }
    }
#endif
    /* If we lost our peer in the middle of a session. */
    if ([peerID isEqual:opponentGamePeerId] && 
        state == GKPeerStateDisconnected &&
        networkState != kNetworkStateReconnecting) {
            LogTo(Opponent, @"lost connection to '%@'", [s displayNameForPeer:peerID]);
            [self _didLoseConnection];
    } 
}

#pragma mark -
#pragma mark Instance methods

- (id)init
{
    self = [super init];
    if (self != nil) {
        session = nil;
        opponentGamePeerId = nil;
        lastHeartbeatDate = nil;
        picker = nil;
        networkState = kNetworkStateDisconnected;
        heartbeatInterval = kDefaultHearbeatInterval;
        heartbeatTimer = nil;
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
    self.picker = nil;
    self.connectionAlert = nil;
    self.opponentGamePeerId = nil;
    self.heartbeatTimer = nil;
    self.lastHeartbeatDate = nil;
    self.myName = self.opponentName = nil;
    
    [super dealloc];
}

#pragma mark Private methods

- (void)_didConnectWithPeer:(NSString*)peer
{
    opponentName = [session displayNameForPeer:peer];
    myName = [session displayNameForPeer:session.peerID];

    LogTo(Opponent, @"connection made with peer '%@'", opponentName);
    self.opponentGamePeerId = peer;
    
    [session setDataReceiveHandler:self withContext:NULL];
    
    // If our peerID is higher than the opponent's, then we will choose the cointoss.
    if ([opponentName compare:myName] == NSOrderedAscending) {
        LogTo(Opponent, @"taking control over cointoss");
        doesWinCointoss = [Random bool];
        LogTo(Opponent, @"opponent %@ cointoss", doesWinCointoss ? @"won" : @"lost");
        
        // Send the negation of doesWinCointoss to the peer. 
        NSMutableDictionary *netEvent = [NSMutableDictionary 
                                         dictionaryWithObject:$object(!doesWinCointoss)
                                         forKey:@"doesWinCointoss"];
        [self _sendNetworkDict:netEvent withType:kNetworkEventCointoss];
        [self _scheduleHeartbeatCheck];
        networkState = kNetworkStateConnected;
        
        // otherwise, wait for the other player to decide who goes first. 
    } else {
        LogTo(Opponent, @"waiting for network cointoss event");
        networkState = kNetworkStateCointoss;
    }
    
    [self _sendStateChange];    
}

/** Return to the picker a specialized session. This is explicitly configured on 
 debug builds to be client/server, as GameKit doesn't work otherwise. 
 See http://volcore.limbicsoft.com/2009/09/iphone-os-31-gamekit-pt-2-next-day.html */
- (GKSession*)_makeSession
{
    GKSessionMode mode;
#ifdef DEBUG
#if !(TARGET_IPHONE_SIMULATOR)
    LogTo(Opponent, @"session mode is server");
    mode = GKSessionModeServer;
#else
    LogTo(Opponent, @"session mode is client");
    mode = GKSessionModeClient;
#endif
#else // RELEASE
    LogTo(Opponent, @"session mode is peer");
    mode = GKSessionModePeer;
#endif
    return [[[GKSession alloc] initWithSessionID:kPongSessionID 
                                     displayName:nil   // default displayName
                                     sessionMode:mode] autorelease];
}

- (void)_heartbeatCheck
{
//    if (fabs([lastHeartbeatDate timeIntervalSinceNow]) > self.heartbeatInterval) {
//        [self _didLoseConnection];
//    }
}

- (void)_didLoseConnection
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Couldn't reconnect with %@.",
                                                                 @"lost connection description"),
                     opponentName];
    if (!connectionAlert) {
        self.connectionAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lost Connection", @"lost connection title") 
                                                           message:msg
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"End Game", 
                                                                                     @"end game button for connection dropped dialog") 
                                                 otherButtonTitles:nil] autorelease];
        connectionAlert.delegate = self;
    }
    if (networkState != kNetworkStateReconnecting) {
        networkState = kNetworkStateReconnecting;
        [self _sendStateChange];        
    }

    [connectionAlert show];
}

/** UIAlertView delegate method for connectionAlert. */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self _invalidateSession];
    networkState = kNetworkStateDisconnected;
    [self _sendStateChange];
}

- (void)_scheduleHeartbeatCheck
{
    if (heartbeatTimer) {
        [heartbeatTimer invalidate];    
    }
    self.lastHeartbeatDate = [NSDate date];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatInterval 
                                                           target:self 
                                                         selector:@selector(_heartbeatCheck) 
                                                         userInfo:nil 
                                                          repeats:YES];
}

- (void)_sendNetworkDict:(NSMutableDictionary*)dict withType:(NetworkEventType)t
{
    static NSInteger currentPacketNumber = 0;
    [dict setValue:$object(t) forKey:@"eventType"];
    [dict setValue:$object(currentPacketNumber++) forKey:@"packetNum"];
    NSData *serializedEvent = [NSKeyedArchiver archivedDataWithRootObject:dict];

    if (![session sendData:serializedEvent 
              toPeers:[NSArray arrayWithObject:opponentGamePeerId] 
         withDataMode:GKSendDataReliable
                error:nil]) {
        Warn(@"sendNetworkData failed!");
    }
}

- (void)_sendStateChange
{
    if ([(NSObject*)delegate conformsToProtocol:@protocol(NetOpponentDelegate)]) {
        // Fire off state change asynchronously
        [(NSObject*)delegate performSelector:@selector(opponentDidChangeState:) 
                                  withObject:$object(networkState)
                                  afterDelay:0];
    } else {
        Warn(@"delegate does not respond to state change messages");
    }

}

- (void)_invalidateSession
{
	if(session != nil) {
        [session disconnectFromAllPeers];
        session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
        self.session = nil;
	}
    [heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}

- (void)_dismissAlertWithAnimation:(BOOL)doAnimation
{
    if ([connectionAlert isVisible]) {
        [connectionAlert dismissWithClickedButtonIndex:-1 animated:doAnimation];        
    }
}


@end

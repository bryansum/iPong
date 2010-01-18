//
//  NetOpponent.m
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "BluetoothOpponent.h"
#import "NetOpponent.h"

enum {
	kNetworkEventCointoss       = 1 << 0,
    kNetworkEventPingEvent      = 1 << 1,
    kNetworkEventHeartbeat      = 1 << 2
};
typedef NSInteger NetworkEventType;

static NSString * const kPongSessionID = @"iPong";

@interface BluetoothOpponent ()

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
@end

@implementation BluetoothOpponent
@synthesize delegate, connectionAlert;
@synthesize lastHeartbeatDate, networkState, heartbeatTimer;
@synthesize picker, session, opponentGamePeerId, heartbeatInterval;

#pragma mark NetOpponent protocol methods
- (BOOL)doesWinCointoss
{
    if (networkState < kNetworkStateConnected) {
        [NSException raise:@"networkStateNotConnected" format:@"networkState is not yet connected"];
    }
    return doesWinCointoss;
}

- (void)findOpponents
{
    if (networkState != kNetworkStateDisconnected) {
        [self disconnect];
    }
    
    [self _dismissAlertWithAnimation:NO];
        
    // note: picker is released in various picker delegate methods when picker use is done.
    self.picker = [[[GKPeerPickerController alloc] init] autorelease];
	picker.delegate = self;
	[picker show]; // show the Peer Picker
    
    networkState = kNetworkStateFinding;
    [self _sendStateChange];
}

- (void)disconnect
{
    if ([picker isVisible]) {
        // should call - (void)peerPickerControllerDidCancel:(GKPeerPickerController *)p
        // and in turn [self invalidateSession]
        [picker dismiss]; 
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
    return [session displayNameForPeer:opponentGamePeerId];
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
    
    NSLog(@"canceled picker");
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// release this picker. 
	picker.delegate = nil;
    self.picker = nil;
    networkState = kNetworkStateDisconnected;
	
	// invalidate and release game session if one is around.
    [self _invalidateSession];
    
    // Inform our delegate that our user canceled this prompt, so it can programmatically
    // choose to start finding another opponent.
    [self _sendStateChange];
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)p 
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{ 
	self.session = [[GKSession alloc] initWithSessionID:kPongSessionID 
                                            displayName:nil   // default displayName
                                            sessionMode:GKSessionModePeer];
    session.delegate = self;
	return session;
}

- (void)peerPickerController:(GKPeerPickerController *)p 
              didConnectPeer:(NSString *)opponentPeerId 
                   toSession:(GKSession *)sess
{ 
    NSLog(@"connection made with peer %@", opponentPeerId);
    Assert(networkState == kNetworkStateFinding, @"networkState should be finding");
    Assert(sess == session, @"session different than expected");
    
	// Remember the current peer.
    self.opponentGamePeerId = opponentPeerId;

    picker.delegate = nil;
        
    // If our peerID is higher than the opponent's, then we will choose the cointoss.
    if ([[session peerID] compare:opponentPeerId] == NSOrderedDescending) {
        srandom(time(NULL));
        doesWinCointoss = (random() & 0x1) ? YES : NO;
        
        // Send the negation of doesWinCointoss to the peer. 
        NSMutableDictionary *netEvent = [NSMutableDictionary 
                                         dictionaryWithObject:$object(!doesWinCointoss)
                                                       forKey:@"doesWinCointoss"];
        [self _sendNetworkDict:netEvent withType:kNetworkEventCointoss];
        [self _scheduleHeartbeatCheck];
        networkState = kNetworkStateConnected;
    
    // otherwise, wait for the other player to decide who goes first. 
    } else {
        networkState = kNetworkStateCointoss;
    }
    
    [session setDataReceiveHandler:self withContext:NULL];
    [self _sendStateChange];
} 



#pragma mark GKSessionDelegate methods

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer 
          inSession:(GKSession *)session 
            context:(void *)context 
{ 
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NetworkEventType eventType = [[dict objectForKey:@"eventType"] integerValue];
    NSInteger packetNum = [[dict objectForKey:@"packetNum"] integerValue];
    
    // check to make sure packet numbering in monotonically increasing
    static NSInteger lastReceivedPacketNum = -1;
	if(packetNum < lastReceivedPacketNum && eventType != kNetworkEventCointoss) {
		return;	
	}
    
    lastReceivedPacketNum = packetNum;

    // If any network info is received, we want to connect if we were reconnecting. 
    if (networkState == kNetworkStateReconnecting) {
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
                NSLog(@"Received networkEventCointoss packet when not in cointoss state or invalid");
                return;
            }
            doesWinCointoss = [[dict objectForKey:@"doesWinCointoss"] boolValue];

            [picker dismiss];
            self.picker = nil;
            
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
    Assert([s isEqual:session], @"session values should match");
    
    if (!(state == GKPeerStateDisconnected || state == GKPeerStateUnavailable) ||
        ![peerID isEqual:opponentGamePeerId] ||
        networkState == kNetworkStateReconnecting) { // already reconnecting
        return;        
    }
    
    [self _didLoseConnection];
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
    self.opponentGamePeerId = nil;
    self.lastHeartbeatDate = nil;
    
    [super dealloc];
}

#pragma mark Private methods

- (void)_heartbeatCheck
{
    if (fabs([lastHeartbeatDate timeIntervalSinceNow]) > self.heartbeatInterval) {
        [self _didLoseConnection];
    }
}

- (void)_didLoseConnection
{
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Couldn't reconnect with %@.",
                                                                 @"lost connection description"),
                     [session displayNameForPeer:opponentGamePeerId]];
    if (!connectionAlert) {
        self.connectionAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lost Connection", @"lost connection title") 
                                                           message:msg
                                                          delegate:self 
                                                 cancelButtonTitle:NSLocalizedString(@"End Game", 
                                                                                     @"end game button for connection dropped dialog") 
                                                 otherButtonTitles:nil] autorelease];
        connectionAlert.delegate = self;
    }
    [connectionAlert show];

    networkState = kNetworkStateReconnecting;
    [self _sendStateChange];
}

/** UIAlertView delegate method for connectionAlert. */
- (void)alertViewCancel:(UIAlertView *)alertView
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

    NSError *err = nil;
    [session sendData:serializedEvent 
              toPeers:[NSArray arrayWithObject:opponentGamePeerId] 
         withDataMode:GKSendDataReliable
                error:&err];
    if (err) {
        NSLog(@"sendNetworkData failed with: %@", [err localizedDescription]);
    }
}

- (void)_sendStateChange
{
    if ([delegate respondsToSelector:@selector(opponentDidChangeState:)]) {
        // Fire off state change asynchronously
        [delegate performSelector:@selector(opponentDidChangeState:) 
                       withObject:$object(networkState)
                       afterDelay:0];
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

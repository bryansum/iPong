//
//  iPongAppDelegate.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iPongAppDelegate.h"

#define kNumBeeps 4 // 4th is the one we want the user to press. 
#define kFinalBeep (kNumBeeps - 1)

//
// various states the game can get into
//
typedef enum {
	kStateStartGame,
	kStatePicker,
	kStateMultiplayer,
    kStateMyServe,
    kStateEndGame,
	kStateMultiplayerCointoss,
	kStateMultiplayerReconnect
} gameStates;


typedef enum {
	kServer,
	kClient
} gameNetwork;

// GameKit Session ID for app
#define kPongSessionID @"iPong"

#define kMaxPongPacketSize 1024

@interface iPongAppDelegate()
- (void) startSampling;
- (void) stopSampling;
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end

@implementation iPongAppDelegate

@synthesize gameState, peerStatus, gameSession, gamePeerId, lastHeartbeatDate, connectionAlert;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//Create a full-screen window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[_window setBackgroundColor:[UIColor darkGrayColor]];
  
  
	UIImageView *backgroundPattern = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-pattern.png"]];
  [backgroundPattern setFrame:[[UIScreen mainScreen] bounds]];
  [_window addSubview:backgroundPattern];
  
	UIImageView *scoreboardBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-bg.png"]];
  [scoreboardBg setFrame:CGRectMake(0, 0, 320, 480)];
  [_window addSubview:scoreboardBg];
  
	UIImageView *scoreboard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard.png"]];
  [scoreboard setFrame:CGRectMake(0, 40, 320, 53)];
  [_window addSubview:scoreboard];
  
	UIImageView *divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-divider.png"]];
  [divider setFrame:CGRectMake(160, 41, 2, 51)];
  [_window addSubview:divider];
  
  UILabel *scoreLabel = [[UILabel alloc] init];
  [scoreLabel setFrame:CGRectMake(136, 20, 83, 18)];
  [scoreLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [scoreLabel setText:@"SCORE"];
  [scoreLabel setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [scoreLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
  [scoreLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
  [scoreLabel setTextColor:[UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0]];
  [_window addSubview:scoreLabel];
  
  myScoreValue = [[UILabel alloc] init];
  [myScoreValue setFrame:CGRectMake(10, 50, 153, 35)];
  [myScoreValue setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [myScoreValue setText:@"11"];
  [myScoreValue setTextAlignment:UITextAlignmentCenter];
  [myScoreValue setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [myScoreValue setShadowOffset:CGSizeMake(0.0, 1.0)];
  [myScoreValue setFont:[UIFont boldSystemFontOfSize:40.0]];
  [myScoreValue setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
  [_window addSubview:myScoreValue];
  
  remoteScoreValue = [[UILabel alloc] init];
  [remoteScoreValue setFrame:CGRectMake(160, 50, 153, 35)];
  [remoteScoreValue setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
  [remoteScoreValue setText:@"5"];
  [remoteScoreValue setTextAlignment:UITextAlignmentCenter];
  [remoteScoreValue setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
  [remoteScoreValue setShadowOffset:CGSizeMake(0.0, 1.0)];
  [remoteScoreValue setFont:[UIFont boldSystemFontOfSize:40.0]];
  [remoteScoreValue setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
  [_window addSubview:remoteScoreValue];
  
  buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
  [buttonView setFrame:CGRectMake(70, 130, 186, 310)];
  [buttonView imageRectForContentRect:CGRectMake(100, 1300, 3200, 350)];
  [buttonView setBackgroundImage:[UIImage imageNamed:@"paddle.png"] forState:UIButtonTypeCustom];
  [buttonView addTarget:self action:@selector(startSampling) forControlEvents:UIControlEventTouchDown];
  [buttonView addTarget:self action:@selector(stopSampling) forControlEvents:UIControlEventTouchUpInside];
  [_window addSubview:buttonView];       
  
    int curX = 110;
    for (int i = 0; i < kNumBeeps; i++) {
        dots[i] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]];
        [dots[i] setFrame:CGRectMake(curX, 440, 30, 30)];
        [_window addSubview:dots[i]];

        curX += 25;        
    }
  
	//Show the window
	[_window makeKeyAndVisible];
  
  direction = 1.0;
  startTime = [[NSDate date] timeIntervalSince1970];  
  previousTimeInterval = startTime;
	
	z = 0;
	x = 0;
	isServe = true;
  
  accelerometer = [UIAccelerometer sharedAccelerometer];
  [accelerometer setDelegate:self];
  [accelerometer setUpdateInterval:1.0/60.0];	

    
    avController = [[AVController alloc] init];

    peerStatus = kServer;
    gamePacketNumber = 0;
    gameSession = nil;
    gamePeerId = nil;
    lastHeartbeatDate = nil;

    NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
    gameUniqueID = [uid hash];

    self.gameState = kStateStartGame; // Setting to kStateStartGame does a reset of players, scores, etc. See -setGameState: below

    [NSTimer scheduledTimerWithTimeInterval:0.033 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

-(void)displayDotForInterval:(int)interval
{
    for (int i = 0; i < kNumBeeps; i++) {
        [dots[i] setImage:[UIImage imageNamed: (interval == i ? @"glowing-dot.png" : @"empty-dot.png")]];        
    }
}

- (void) startSampling {
  partialVelocity = 0;
	isSwinging = false;
  numberOfSamples = 0;
  previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
  isSampling = true;
}

- (void) stopSampling {
	isSwinging = false;
  currentSwing.velocity = 0;
  numberOfSamples = 0;
  isSampling = false;    

    if (self.gameState == kStateStartGame) {
        self.gameState = kStatePicker;
        [self startPicker];  
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	NSTimeInterval intervalDate = [[NSDate date] timeIntervalSince1970];
	CGFloat timeDifference = intervalDate - previousTimeInterval;
	previousTimeInterval = intervalDate;
	
	//if(!isSampling) return;
	
	z = 0.923077 * (z + acceleration.z - prevZ);
	x = 0.923077 * (x + acceleration.x - prevX);
	
	
	if(isServe) {
		//	NSLog(@"z %f, x %f", z, acceleration.x);
		if (z > .5  && -0.1 <= x  && x <= 0.1 && z > acceleration.z) {
			NSLog(@"threw the ball for serve");
			isServe = false;
		}
	} else {
		
		//	NSLog(@"velocity %f", z);
		UIAccelerationValue temp = sqrt(x*x + z*z);
		//	NSLog(@"z %f, x %f", z, x);
		
		//If the direction has changed
		currentSwing.velocity = (timeDifference * temp);
		if(z >= 0.5){
			if (x <= -0.5 || x >= 0.5 || currentSwing.swingType == 0) {
				NSLog(@"topspin %f", (-x)/(z-x));
				
				//x will be more - implies more top
				currentSwing.swingType = kTopSpin;
				currentSwing.typeIntensity = (-x)/(z-x);
			} else if (x/(x+z) <= 0.5 && x/(x+z) >= -0.1 && z > acceleration.z) {
				NSLog(@"normal %f", currentSwing.velocity);
				//x will be more + implies more 
				currentSwing.swingType = kNormal;
				currentSwing.typeIntensity = 1;
			}
		} else if (-0.5<= acceleration.z && acceleration.z <= 0.0 && (x >= 0.5 || x <= -0.5)) {
			NSLog(@"slice %f", x/(x+fabs(z)));
			
			currentSwing.swingType = kSlice;
			currentSwing.typeIntensity = (x)/(x+z);
		} else {
			currentSwing.swingType = kNormal;
			currentSwing.velocity = 0.0;
		}
		
	}
	
	prevZ = acceleration.z;
	prevX = acceleration.x;
	
}

#pragma mark SwingTimerDelegate methods

-(void)intervalDidOccur:(int)interval
{
    if (interval != kFinalBeep) {
        [avController playBeepAtVolume:interval/(float)kNumBeeps];
        
        [self displayDotForInterval:interval];
        
    } else {
        BOOL hit = YES;
        PongPacket packet;
        packet.velocity = 1;
        packet.swingType = kNormal;
        packet.typeIntensity = 1;

        // test for hit
        // Right now, assume hit all the time
        if (hit) {
            [avController playHit];
            [self didHit:&packet];
        } else {
            [self didMiss];
        }        
    }
    
}

-(void)didMiss
{
    NSLog(@"Missed our swing");
    [self sendNetworkPacket:gameSession 
                   packetID:NETWORK_MISS_EVENT
                   withData:nil 
                   ofLength:0
                   reliable:NO];
}

-(void)didHit:(PongPacket *)packet
{
    NSLog(@"Sending serve to peer");
    [self sendNetworkPacket:gameSession 
                   packetID:NETWORK_PING_EVENT 
                   withData:packet 
                   ofLength:sizeof(packet)
                   reliable:NO];
}

#pragma mark Swing methods
-(void)didServe
{
    self.gameState = kStateMultiplayer;
    
    // Fire off our swing timer as it comes down; act like it's 
    PongPacket packet;
    packet.velocity = 1.0;
    packet.swingType = kNormal;
    packet.typeIntensity = 1;
    
    SwingTimer *swingTimer = [[SwingTimer alloc] initWithEnemyPacket:&packet 
                                                         andNumBeeps:kNumBeeps];
    swingTimer.delegate = self;
    [swingTimer start];
}

#pragma mark Peer Picker Related Methods

-(void)startPicker {
	GKPeerPickerController*		picker;
	
	self.gameState = kStatePicker; // we're going to do Multiplayer!
    
	// note: picker is released in various picker delegate methods when picker use is done.
	picker = [[GKPeerPickerController alloc] init]; 
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(self.gameSession != nil)	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
} 

/*
 *	Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *		- see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
	GKSession *session = [[GKSession alloc] initWithSessionID:kPongSessionID displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
	// Remember the current peer.
	self.gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self; 
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	self.gameState = kStateMultiplayerCointoss;
} 

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession. 
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];
	//
	// developer  check the network time and make sure packers are in order
	//
	int packetTime = pIntData[0];
	int packetID = pIntData[1];
	if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
		return;	
	}
	
	lastPacketTime = packetTime;
	switch( packetID ) {
		case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            // if other player's coin is higher than ours then that player is the server
            if(coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            } else {
                // we're server
                self.peerStatus = kServer;
//                self.gameState = kStateMyServe;
                [self didServe];
            }
        }
			break;
		case NETWORK_PING_EVENT:
        {
            // received move event from other player, update other player's position/destination info
            PongPacket *pp = (PongPacket *)&incomingPacket[8];            
            // calls interval did occur every at every 1/numBeeps interval
            SwingTimer *swingTimer = [[SwingTimer alloc] initWithEnemyPacket:pp andNumBeeps:kNumBeeps];
            swingTimer.delegate = self;
            [swingTimer start];
            
        }
			break;
        case NETWORK_MISS_EVENT:
        {
            // received a miss event from the other player. This means that we, 
            // in turn, score. 
            
            // TODO: update our score. 
            
            self.gameState = kStateMyServe;
            
            // now wait for a serve event to take us into multiplayer mode. 
            
        }
            break;
		case NETWORK_HEARTBEAT:
        {
            // Received heartbeat data with other player's position, destination, and firing status.
            // update heartbeat timestamp
            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
			break;
		default:
			// error
			break;
	}
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
	// the packet we'll send is resued
	static unsigned char networkPacket[kMaxPongPacketSize];
	const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
	
	if(length < (kMaxPongPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
		int *pIntData = (int *)&networkPacket[0];
		// header info
		pIntData[0] = gamePacketNumber++;
		pIntData[1] = packetID;
		// copy data in after the header
		memcpy( &networkPacket[packetHeaderSize], data, length ); 
		
		NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
		if(howtosend == YES) { 
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
		} else {
			[session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
		}
	}
}

#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
	if(self.gameState == kStatePicker) {
		return;	// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		
		// Update user alert or throw alert if it isn't already up
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", 
                             [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && 
           self.connectionAlert &&
           self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" 
                                                            message:message 
                                                           delegate:self 
                                                  cancelButtonTitle:@"End Game" 
                                                  otherButtonTitles:nil];
			self.connectionAlert = alert;
			[alert show];
			[alert release];
		}
		
		// go back to start mode
		self.gameState = kStateStartGame; 
	} 
} 

//
// Game loop runs at regular interval to update game based on current game state
//
- (void)gameLoop {
	static int counter = 0;
	switch (self.gameState) {
		case kStatePicker:
		case kStateStartGame:
			break;
		case kStateMultiplayerCointoss:
			[self sendNetworkPacket:self.gameSession 
                           packetID:NETWORK_COINTOSS 
                           withData:&gameUniqueID 
                           ofLength:sizeof(int) 
                           reliable:YES];
			self.gameState = kStateMultiplayer; // we only want to be in the cointoss state for one loop
			break;
        case kStateMyServe: // wait for a serve event
		case kStateMultiplayer: // playing the game... still use heartbeats
        case kStateEndGame: // either you won or you lost... waits for button press
            
			counter++;
			if(!(counter&7)) { // once every 8 updates check if we have a recent heartbeat from the other player, and send a heartbeat packet with current state
				if(self.lastHeartbeatDate == nil) {
					// we haven't received a hearbeat yet, so set one (in case we never receive a single heartbeat)
					self.lastHeartbeatDate = [NSDate date];
                    
                    // see if the last heartbeat is too old
				} else if(fabs([self.lastHeartbeatDate timeIntervalSinceNow]) >= kMaxPongPacketSize) { 
					// seems we've lost connection, notify user that we are trying to reconnect (until GKSession actually disconnects)
					NSString *message = [NSString stringWithFormat:@"Trying to reconnect...\nMake sure you are within range of %@.", 
                                         [self.gameSession displayNameForPeer:self.gamePeerId]];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" 
                                                                    message:message 
                                                                   delegate:self 
                                                          cancelButtonTitle:@"End Game" 
                                                          otherButtonTitles:nil];
					self.connectionAlert = alert;
					[alert show];
					[alert release];
					self.gameState = kStateMultiplayerReconnect;
				}
				
				[self sendNetworkPacket:gameSession 
                               packetID:NETWORK_HEARTBEAT 
                               withData:nil 
                               ofLength:0 
                               reliable:NO];
			}
			break;
		case kStateMultiplayerReconnect:
			// we have lost a heartbeat for too long, 
            // so pause game and notify user while we wait for next heartbeat or session disconnect.
			counter++;
			if(!(counter&7)) { // keep sending heartbeats to the other player in case it returns
				[self sendNetworkPacket:gameSession 
                               packetID:NETWORK_HEARTBEAT 
                               withData:nil 
                               ofLength:0
                               reliable:NO];
			}
			break;
		default:
			break;
	}
}

- (void)dealloc {

    self.lastHeartbeatDate = nil;
	if(self.connectionAlert.visible) {
		[self.connectionAlert dismissWithClickedButtonIndex:-1 animated:NO];
	}
	self.connectionAlert = nil;
	
	// cleanup the session
	[self invalidateSession:self.gameSession];
	self.gameSession = nil;
	self.gamePeerId = nil;

    [avController release];
    [_window release];
    
    [super dealloc];
}


@end

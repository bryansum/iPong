//
//  iPongAppDelegate.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>
#import "ScoreController.h"
#import "PongPacket.h"
#import "SwingTimer.h"
#import "AVController.h"
#import "SwingHandler.h"
#define CLAMP(x, l, h)  (((x) > (h)) ? (h) : (((x) < (l)) ? (l) : (x)))

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_PING_EVENT,				// ping event received
    NETWORK_MISS_EVENT,
	NETWORK_HEARTBEAT				// send of entire state at regular intervals
} packetCodes;

@interface iPongAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate, 
                                        GKPeerPickerControllerDelegate, GKSessionDelegate, 
                                        UIAlertViewDelegate, SwingTimerDelegate,
                                        SwingHandlerDelegate>
{
    UIWindow				  *_window;
    NSInputStream		  *_inStream;
    NSOutputStream		*_outStream;
    BOOL				   	  _inReady;
    BOOL		_outReady;
    
    UILabel           *labelView;
    UILabel           *secondLabel;
    
    UIButton          *buttonView;
    UIButton          *soundButton;
    
    UIImageView       *dots[4];
    
    UILabel           *myScoreValue;
    UILabel           *remoteScoreValue;

	ScoreController   *player;
    
    // game state
    NSInteger           gameState;
    NSInteger           peerStatus;
    BOOL                myServe;
    NSInteger           round;
    
    // networking
	GKSession		*gameSession;
	int				gameUniqueID;
	int				gamePacketNumber;
	NSString		*gamePeerId;
	NSDate			*lastHeartbeatDate;
    
    UIAlertView		*connectionAlert;
    
    AVController    *avController;    
    SwingHandler    *swingHandler;
}

@property (nonatomic) NSInteger		gameState;
@property (nonatomic) NSInteger		peerStatus;
@property (nonatomic) BOOL  myServe;
@property (nonatomic) NSInteger round;

@property (nonatomic, retain) GKSession	 *gameSession;
@property (nonatomic, copy)	 NSString	 *gamePeerId;
@property (nonatomic, retain) NSDate	 *lastHeartbeatDate;
@property (nonatomic, retain) UIAlertView *connectionAlert;

- (void) invalidateSession:(GKSession *)session;
- (void) sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend;
- (void) startPicker;
-(void)gameWonFor:(NSInteger)peerStatus;
- (void) updateMyScoreLabel:(NSInteger)peerStatus withValue:(NSInteger)n;

-(BOOL)wasHit:(PongPacket *)packet;
-(void)incRound;
@end


//
//  iPongAppDelegate.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#import <GameKit/GameKit.h>
#import "PongPacket.h"
#import "SwingTimer.h"
#import "AVController.h"

typedef struct AccelerationSample{
  NSTimeInterval elapsedTime;
  double x;
} AccelerationSample;

typedef enum {
	NETWORK_ACK,					// no packet
	NETWORK_COINTOSS,				// decide who is going to be the server
	NETWORK_PING_EVENT,				// ping event received
    NETWORK_MISS_EVENT,
	NETWORK_HEARTBEAT				// send of entire state at regular intervals
} packetCodes;

@interface iPongAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate, 
                                        GKPeerPickerControllerDelegate, GKSessionDelegate, 
                                        UIAlertViewDelegate,
                                        UIAccelerometerDelegate, SwingTimerDelegate>
{
	UIWindow				  *_window;
	NSInputStream		  *_inStream;
	NSOutputStream		*_outStream;
	BOOL				   	  _inReady;
	BOOL				      _outReady;
  
    UILabel           *labelView;
    UILabel           *secondLabel;

    UIButton          *buttonView;
    UIButton          *soundButton;
  
    // acceleration 
    UIAccelerometer   *accelerometer;

    BOOL              isSampling;
    NSTimeInterval    startTime;
    NSUInteger        previousTimeInterval;
    NSInteger         direction;
    NSUInteger        numberOfSamples;

    UIImageView       *dots[4];

  UILabel           *myScoreValue;
  UILabel           *remoteScoreValue;

    NSInteger           gameState;
	NSInteger           peerStatus;

    // networking
	GKSession		*gameSession;
	int				gameUniqueID;
	int				gamePacketNumber;
	NSString		*gamePeerId;
	NSDate			*lastHeartbeatDate;
    
    UIAlertView		*connectionAlert;
    
    AVController    *avController;
    
	UIAccelerationValue		prevZ;
	UIAccelerationValue		z;
	UIAccelerationValue		prevX;
	UIAccelerationValue		x;
	PongPacket			currentSwing;
	BOOL isServe;
}

@property (nonatomic) NSInteger		gameState;
@property (nonatomic) NSInteger		peerStatus;

@property (nonatomic, retain) GKSession	 *gameSession;
@property (nonatomic, copy)	 NSString	 *gamePeerId;
@property (nonatomic, retain) NSDate	 *lastHeartbeatDate;
@property (nonatomic, retain) UIAlertView *connectionAlert;

- (void)invalidateSession:(GKSession *)session;
- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend;
-(void)startPicker;

-(void)didMiss;
-(void)didHit:(PongPacket *)packet;

@end


//
//  SwingHandler.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PongPacket.h"

@protocol SwingHandlerDelegate

-(void)didServe;

@end

@interface SwingHandler : NSObject <UIAccelerometerDelegate> {
	UIAccelerationValue		prevZ;
	UIAccelerationValue		z;
	UIAccelerationValue		prevX;
	UIAccelerationValue		x;
    
    NSTimeInterval              startTime;
    NSUInteger                  previousTimeInterval;
    
    PongPacket                  currentSwing;
    BOOL canServe;
    
    // acceleration 
    UIAccelerometer             *accelerometer;
    
    id                          delegate;
}

-(void)startRecording;
-(void)stopRecording;

- (void) accelerometer:(UIAccelerometer *)accelerometer 
         didAccelerate:(UIAcceleration *)acceleration;

- (PongPacket)currentSwing;

@property (retain) id delegate;
@property (assign) BOOL canServe;
@end

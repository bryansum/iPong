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
  // acceleration 
  UIAccelerometer             *accelerometer;
    
  NSTimeInterval              startTime;
  NSUInteger                  previousTimeInterval;
  
  UIAcceleration *acc;
  
  id                          delegate;
}

-(void)startRecording;
-(void)stopRecording;

- (PongPacket)currentSwing;

@property (retain) UIAcceleration* acc;
@property (retain) id delegate;
@end


//
//  AccelerometerHandler.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

@class PongEvent;

@interface AccelerometerHandler : NSObject <UIAccelerometerDelegate> {
    NSTimeInterval              startTime;
    NSUInteger                  previousTimeInterval;

    UIAcceleration              *acc;
}

-(void)startRecording;
-(void)stopRecording;

/** Return the current PongEvent for this swing. */
- (PongEvent*)currentSwing;
@end


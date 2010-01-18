//
//  AccelerometerHandler.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "AccelerometerHandler.h"
#import "PongEvent.h"

#define CLAMP(x, l, h)  (((x) > (h)) ? (h) : (((x) < (l)) ? (l) : (x)))
#define kAccelSamplingFreq 1.0/60.0

@interface AccelerometerHandler ()
-(BOOL)_isHit:(float)event;

@property (nonatomic, retain) UIAcceleration *acc;
@end

@implementation AccelerometerHandler
@synthesize acc;

- (void)startRecording
{
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:kAccelSamplingFreq];	
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

-(void)stopRecording
{
    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

-(PongEvent*)currentSwing
{
    PongEvent *retSwing;
    float v = CLAMP(sqrt(pow(acc.x,2) + pow(acc.y,2) + pow(acc.z,2))-1,0,3)/2;
    if ([self _isHit:v]) {
        retSwing = [PongEvent pongMiss];
    } else {
        retSwing = [PongEvent pongHitWithVelocity:v
                                        swingType:kSwingTypeNormal
                                    typeIntensity:0];
    }
    return retSwing;
}

#pragma mark UIAccelerometerDelegate methods

- (void) accelerometer:(UIAccelerometer *)accelerometer 
         didAccelerate:(UIAcceleration *)acceleration 
{
    self.acc = acceleration;
}


#pragma mark Private methods
- (id) init
{
    self = [super init];
    if (self != nil) {
        acc = [[UIAcceleration alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [self stopRecording];
    [super dealloc];
}

-(BOOL)_isHit:(float)velocity
{
    /* MAJD - Reduced threshold from 0.5 to 0.3 */
    return velocity > 0.3 ? YES : NO; 
}

@end

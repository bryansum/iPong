//
//  AccelerometerHandler.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "AccelerometerHandler.h"
#import "PongEvent.h"
#import "Utilities.h"

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

/** When using the simulator, we don't have access to the accelorometer, so just
    give it some random values to use. */
-(PongEvent*)currentSwing
{
    PongEvent *retSwing;
#if TARGET_IPHONE_SIMULATOR
    if ([Random bool]) {
        Log(@"Simulated hit");
        retSwing = [PongEvent pongHitWithVelocity:1 
                                        swingType:kSwingTypeNormal 
                                    typeIntensity:1];
    } else {
        Log(@"Simulated miss");
        retSwing = [PongEvent pongMiss];
    }
#else
    float v = CLAMP(sqrt(pow(acc.x,2) + pow(acc.y,2) + pow(acc.z,2))-1,0,3)/2;
    if ([self _isHit:v]) {
        retSwing = [PongEvent pongMiss];
    } else {
        retSwing = [PongEvent pongHitWithVelocity:v
                                        swingType:kSwingTypeNormal
                                    typeIntensity:0];
    }    
#endif
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
    self.acc = nil;
    [self stopRecording];
    [super dealloc];
}

-(BOOL)_isHit:(float)velocity
{
    /* MAJD - Reduced threshold from 0.5 to 0.3 */
    return velocity > 0.3 ? YES : NO; 
}

@end

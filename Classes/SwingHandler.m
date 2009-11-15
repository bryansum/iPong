//
//  SwingHandler.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "SwingHandler.h"


@implementation SwingHandler

@synthesize delegate, canServe;

- (id) init
{
    self = [super init];
    if (self != nil) {
        z = 0;
        x = 0;
        canServe = false;
        accelerometer = [UIAccelerometer sharedAccelerometer];        
    }
    return self;
}

- (void) dealloc
{
    [self stopRecording];
    [accelerometer release];
    [delegate release];
    [super dealloc];
}

- (void)startRecording
{
    [accelerometer setDelegate:self];
    [accelerometer setUpdateInterval:1.0/60.0];	
    startTime = previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
}

-(void)stopRecording
{
    [accelerometer setDelegate:nil];
}

#pragma mark SwingHandler

- (void) accelerometer:(UIAccelerometer *)accelerometer 
         didAccelerate:(UIAcceleration *)acceleration {

    @synchronized(self) {
        NSTimeInterval intervalDate = [[NSDate date] timeIntervalSince1970];
        CGFloat timeDifference = intervalDate - previousTimeInterval;
        previousTimeInterval = intervalDate;
        
        //if(!isSampling) return;
        
        z = 0.923077 * (z + acceleration.z - prevZ);
        x = 0.923077 * (x + acceleration.x - prevX);
        
        if(canServe) {
            //	NSLog(@"z %f, x %f", z, acceleration.x);
            if (z > .5  && -0.1 <= x  && x <= 0.1 && z > acceleration.z) {
                [delegate didServe];
                canServe = false;
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
}

-(PongPacket)currentSwing
{
    PongPacket retSwing;
    @synchronized(self) {
        retSwing = currentSwing;
    }
    return retSwing;
}

@end

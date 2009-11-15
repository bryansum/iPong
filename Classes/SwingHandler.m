//
//  SwingHandler.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "SwingHandler.h"
#define CLAMP(x, l, h)  (((x) > (h)) ? (h) : (((x) < (l)) ? (l) : (x)))
#define NORMALIZE(x)    (CLAMP(x,0,2)*0.5)
#define VEL_NORMALIZE(x) (CLAMP(x,0,3))

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
-(void)describe
{
    NSLog(@"velocity = %f, swingType = %d, intensity = %f", currentSwing.velocity, 
          currentSwing.swingType, currentSwing.typeIntensity);
    
}

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
            currentSwing.velocity = VEL_NORMALIZE(timeDifference * temp);
            if(z >= 0.5){
                if (x <= -0.5 || x >= 0.5 || currentSwing.swingType == 0) {
                    NSLog(@"topspin %f", (-x)/(z-x));
                    
                    //x will be more - implies more top
                    currentSwing.swingType = kTopSpin;
                    currentSwing.typeIntensity = NORMALIZE((-x)/(z-x));
                                    [self describe];

                } else if (x/(x+z) <= 0.5 && x/(x+z) >= -0.1 && z > acceleration.z) {
                    NSLog(@"normal %f", currentSwing.velocity);
                    //x will be more + implies more 
                    currentSwing.swingType = kNormal;
                    currentSwing.typeIntensity = NORMALIZE(1);    
                                    [self describe];
                }
            } else if (-0.5<= acceleration.z && acceleration.z <= 0.0 && (x >= 0.5 || x <= -0.5)) {
                NSLog(@"slice %f", x/(x+fabs(z)));
                
                currentSwing.swingType = kSlice;
                currentSwing.typeIntensity = NORMALIZE((x)/(x+z));
                [self describe];
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

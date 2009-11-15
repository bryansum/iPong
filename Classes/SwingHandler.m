//
//  SwingHandler.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "SwingHandler.h"
#import "PongPacket.h"

#define CLAMP(x, l, h)  (((x) > (h)) ? (h) : (((x) < (l)) ? (l) : (x)))
#define kSwingBufferSize 10
#define kSampleSize 10
#define kAccelSamplingFreq 1.0/60.0

@implementation SwingHandler

@synthesize delegate, acc;

- (id) init
{
    self = [super init];
    if (self != nil) {
        accelerometer = [UIAccelerometer sharedAccelerometer];        
        self.acc = [[UIAcceleration alloc] init];
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
    [accelerometer setUpdateInterval:kAccelSamplingFreq];	
    previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
    [accelerometer setDelegate:self];
}

-(void)stopRecording
{
    [accelerometer setDelegate:nil];
}

#pragma mark SwingHandler
static void describe(PongPacket*p) 
{
    NSLog(@"velocity = %f, swingType = %d, intensity = %f", p->velocity, 
          p->swingType, p->typeIntensity);
    
}

- (void) accelerometer:(UIAccelerometer *)accelerometer 
         didAccelerate:(UIAcceleration *)acceleration {

    @synchronized(self) {
      self.acc = acceleration;
    }
}

-(PongPacket)currentSwing
{
    PongPacket retSwing;
  
    @synchronized(self) {
      if (!acc) {
        retSwing.velocity = 0;
      } else {
        retSwing.velocity = sqrt(pow(acc.x,2) + pow(acc.y,2) + pow(acc.z,2));
      }
                                 
      // Values typically from 1 - 4
      retSwing.velocity = CLAMP(retSwing.velocity-1,0,3)/2;
      NSLog(@"vel = %f",retSwing.velocity);
      
      retSwing.swingType = kNormal;
      retSwing.typeIntensity = 1;
    }
    describe(&retSwing);
    return retSwing;
}

@end

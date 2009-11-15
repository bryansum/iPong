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
#define VEL_NORMALIZE(x) ((CLAMP(x,0,1)+1)/2)
#define kSwingBufferSize 10
#define kSampleSize 10
#define kAccelSamplingFreq 1.0/60.0

@implementation SwingHandler

@synthesize delegate;

- (id) init
{
    self = [super init];
    if (self != nil) {
        z = 0;
        x = 0;
        accelerometer = [UIAccelerometer sharedAccelerometer];        
        currentSwingBuffer = malloc(sizeof(PongPacket) * kSwingBufferSize);
        curSwing = 0;
    }
    return self;
}

- (void) dealloc
{
    free(currentSwingBuffer);
    [self stopRecording];
    [accelerometer release];
    [delegate release];
    [super dealloc];
}

- (void)startRecording
{
    [accelerometer setDelegate:self];
    [accelerometer setUpdateInterval:kAccelSamplingFreq];	
    startTime = previousTimeInterval = [[NSDate date] timeIntervalSince1970];  
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
        NSTimeInterval intervalDate = [[NSDate date] timeIntervalSince1970];
        CGFloat timeDifference = intervalDate - previousTimeInterval;
        previousTimeInterval = intervalDate;
        
        //if(!isSampling) return;
        
        z = 0.923077 * (z + acceleration.z - prevZ);
        x = 0.923077 * (x + acceleration.x - prevX);
            
        //	NSLog(@"velocity %f", z);
        UIAccelerationValue temp = sqrt(x*x + z*z);
        //	NSLog(@"z %f, x %f", z, x);
        
        //If the direction has changed
        currentSwingBuffer[curSwing].velocity = VEL_NORMALIZE(timeDifference * temp);
        if(z >= 0.5){
            if (x <= -0.5 || x >= 0.5 || currentSwingBuffer[curSwing].swingType == 0) {
                NSLog(@"topspin %f", (-x)/(z-x));
                
                //x will be more - implies more top
                currentSwingBuffer[curSwing].swingType = kTopSpin;
                currentSwingBuffer[curSwing].typeIntensity = NORMALIZE((-x)/(z-x));
              describe(&currentSwingBuffer[curSwing]);

            } else if (x/(x+z) <= 0.5 && x/(x+z) >= -0.1 && z > acceleration.z) {
                NSLog(@"normal %f", currentSwingBuffer[curSwing].velocity);
                //x will be more + implies more 
                currentSwingBuffer[curSwing].swingType = kNormal;
                currentSwingBuffer[curSwing].typeIntensity = NORMALIZE(1);    
              describe(&currentSwingBuffer[curSwing]);
            }
        } else if (-0.5<= acceleration.z && acceleration.z <= 0.0 && (x >= 0.5 || x <= -0.5)) {
            NSLog(@"slice %f", x/(x+fabs(z)));
            
            currentSwingBuffer[curSwing].swingType = kSlice;
            currentSwingBuffer[curSwing].typeIntensity = NORMALIZE((x)/(x+z));
              describe(&currentSwingBuffer[curSwing]);
        } else {
            currentSwingBuffer[curSwing].swingType = kNormal;
            currentSwingBuffer[curSwing].velocity = 0.0;
        }
        
        prevZ = acceleration.z;
        prevX = acceleration.x;        
    }
    curSwing++;
    if (curSwing == kSwingBufferSize) curSwing = 0;
}

-(PongPacket)currentSwing
{
    PongPacket retSwing;
  
    @synchronized(self) {
      NSUInteger swingNum = curSwing;
      // record previous five swings
      for(int i = 0; i < kSampleSize; i++) {
          retSwing.velocity = currentSwingBuffer[swingNum].velocity;
          retSwing.swingType = currentSwingBuffer[swingNum].swingType;
          retSwing.typeIntensity = currentSwingBuffer[swingNum].typeIntensity;
        if (swingNum == 0) swingNum = kSwingBufferSize;
        swingNum--;
      }      
      retSwing.velocity /= kSampleSize;
      retSwing.swingType = floor(retSwing.swingType/kSampleSize);
      retSwing.typeIntensity /= kSampleSize;
    }
  describe(&retSwing);
    return retSwing;
}

@end

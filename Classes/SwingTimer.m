//
//  SwingTimer.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "SwingTimer.h"
#import "PongPacket.h"

#define kDistance 1

@implementation SwingTimer

@synthesize delegate;

-(void)fireIntervalBeeps
{
    [NSThread setThreadPriority:1.0];
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSTimeInterval curTime = 0.0;
    for(int curInterval = 0; curInterval < numBeeps; curInterval++) {

        NSTimeInterval interval = (timeAtInterval[curInterval] - curTime);
        [NSThread sleepForTimeInterval:interval];
        curTime = timeAtInterval[curInterval];

        // play a sound, etc
        [delegate intervalDidOccur:curInterval];
        
    }
    [pool release];
}

-(id)initWithEnemyPacket:(PongPacket*)packet andNumBeeps:(int)nBeeps
{
    self = [super init];
    if (self != nil) {
        
        numBeeps = nBeeps;
        
        timeAtInterval = malloc(numBeeps * sizeof(NSTimeInterval));
        
        NSTimeInterval totalTime = (double) kDistance / packet->velocity;

        NSLog(@"total time %f", totalTime);
        NSTimeInterval secPerInterval = totalTime/(double)(numBeeps - 1);
        double specialSwing;

        // calculate time interval 
        for (int i = 0; i < numBeeps; i++) {
            switch (packet->swingType) {
                case kTopSpin:
                    specialSwing = M_2_PI*acos(-(i*secPerInterval) + 1);
                    break;
                case kSlice:
                    specialSwing = M_2_PI*asin(i*secPerInterval);
                    break;
                case kNormal:
                default:
                    specialSwing = i*secPerInterval; // linear
                    break;
            }
            
            // weighting function b/t linear and special swing
            timeAtInterval[i] = packet->typeIntensity*specialSwing + 
                                    (1-packet->typeIntensity)*(i*secPerInterval);
            
            NSLog(@"timeInterval %d is %f", i, timeAtInterval[i]);
        }        
    }
    return self;    
}

-(void)start
{
    [NSThread detachNewThreadSelector:@selector(fireIntervalBeeps) toTarget:self withObject:nil];
}

- (void) dealloc
{
    NSLog(@"free interval");
    free(timeAtInterval);
    [delegate release];
    [super dealloc];
}

@end

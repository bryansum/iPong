//
//  SwingTimer.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 http://bsumm.net. All rights reserved.
//

#import "SwingTimer.h"
#import "PongEvent.h"
#import "Test.h"

#define _nBeeps 4
static const NSInteger kNumBeeps = _nBeeps;
static const NSInteger kFinalBeep = _nBeeps - 1;

/** Arbitrary constant determining how long the given playing field is. */
static const double kDistanceToTravel = 1;

@interface SwingTimer ()

-(void)_fireIntervalBeeps;
@end

@implementation SwingTimer
@synthesize delegate, event, numBeeps, curBeep;

+ (id)timerWithEvent:(PongEvent*)ev delegate:(id)d startImmediately:(BOOL)startNow
{
    SwingTimer *st = [[[[self class] alloc] initWithEvent:ev] autorelease];
    st.delegate = d;
    if (startNow) {
        [st start];
    }
    return st;
}

- (id)initWithEvent:(PongEvent*)ev
{
    self = [super init];
    if (self != nil) {
        AssertEq([ev hitEventType],kHitEventHit);
        secsBetweenBeeps = calloc(kNumBeeps, sizeof(NSTimeInterval));
        event = [ev copy];
        curBeep = 0;
        numBeeps = kNumBeeps;
        
        // For now, we treat all swings like normal ones. 
        switch ([ev swingType]) {
            default: {
                NSTimeInterval totalTime = kDistanceToTravel / [ev velocity];
                for (int i = 0; i < kNumBeeps; i++) {
                    secsBetweenBeeps[i] = totalTime/(kNumBeeps - 1);
                }                
            }
                break;
        }
    }
    return self;    
}

-(void)start
{
    Assert(delegate != nil, @"delegate not set for swingTimer");
    [NSThread detachNewThreadSelector:@selector(_fireIntervalBeeps) 
                             toTarget:self
                           withObject:nil];
}

- (BOOL)isFinalBeep
{
    return curBeep == kFinalBeep;
}

- (void)_fireIntervalBeeps
{
    for (curBeep = 0; curBeep < kNumBeeps; curBeep++) {
        [delegate performSelectorOnMainThread:@selector(swingTimerBeepDidOccur:) 
                                   withObject:self
                                waitUntilDone:YES];        
        [NSThread sleepForTimeInterval:secsBetweenBeeps[curBeep]];
    }
}

- (void) dealloc
{
    free(secsBetweenBeeps);
    [event release];
    self.delegate = nil;
    [super dealloc];
}

@end

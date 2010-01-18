//
//  SwingTimer.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "SwingTimer.h"
#import "PongEvent.h"
#import "Test.h"

#define _nBeeps 4
const NSInteger kNumBeeps = _nBeeps;
const NSInteger kFinalBeep = _nBeeps - 1;

/** Arbitrary constant determining how long the given playing field is. */
static const double kDistanceToTravel = 1;

@interface SwingTimer ()

-(void)_fireIntervalBeeps;

@property (nonatomic, retain) PongEvent *event;
@end

@implementation SwingTimer
@synthesize delegate, event;

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
        self.event = ev;
        curBeep = 0;
        
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

-(void)_fireIntervalBeeps
{
    for (curBeep = 0; curBeep < kNumBeeps; curBeep++) {
        NSNumber *n = [[NSNumber alloc] initWithInteger:curBeep];
        [delegate performSelectorOnMainThread:@selector(swingTimerBeepDidOccur:) 
                                   withObject:n
                                waitUntilDone:NO];        
        [n release];
        [NSThread sleepForTimeInterval:secsBetweenBeeps[curBeep]];
    }
}

- (void) dealloc
{
    free(secsBetweenBeeps);
    self.delegate = nil;
    [super dealloc];
}

@end

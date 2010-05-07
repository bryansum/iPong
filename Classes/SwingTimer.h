//
//  SwingTimer.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 http://bsumm.net. All rights reserved.
//

@class PongEvent;
@class SwingTimer;

@protocol SwingTimerDelegate <NSObject>

/** After starting the timer, this delegate method is called for 0..(kNumBeeps - 1). */
-(void)swingTimerBeepDidOccur:(SwingTimer*)st;
@end

/** When allocated, sets off a timer which plays a beep at given intervals 
    given a PongEvent. */
@interface SwingTimer : NSObject {
    NSInteger                           curBeep;
    NSInteger                           numBeeps;
    NSTimeInterval                      *secsBetweenBeeps;
    PongEvent                           *event;
    NSObject<SwingTimerDelegate>        *delegate;
}

+ (id)timerWithEvent:(PongEvent*)ev delegate:(id)d startImmediately:(BOOL)s;

- (id)initWithEvent:(PongEvent*)ev;
- (void)start;

- (BOOL)isFinalBeep;

@property (readonly) PongEvent *event;
@property (readonly) NSInteger curBeep;
@property (readonly) NSInteger numBeeps;
@property (retain) id<SwingTimerDelegate> delegate;
@end

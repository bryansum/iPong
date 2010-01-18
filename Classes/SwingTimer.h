//
//  SwingTimer.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

@class PongEvent;

@protocol SwingTimerDelegate <NSObject>

/** After starting the timer, this delegate method is called for 0..(kNumBeeps - 1). */
-(void)swingTimerBeepDidOccur:(NSNumber *)beepNum;
@end

extern const NSInteger kNumBeeps;
extern const NSInteger kFinalBeep;

/** When allocated, sets off a timer which plays a beep at given intervals 
    given a PongEvent. */
@interface SwingTimer : NSObject {
    NSInteger                           curBeep;
    NSTimeInterval                      *secsBetweenBeeps;
    PongEvent                           *event;
    NSObject<SwingTimerDelegate>        *delegate;
}

+ (id)timerWithEvent:(PongEvent*)ev delegate:(id)d startImmediately:(BOOL)s;

- (id)initWithEvent:(PongEvent*)ev;
- (void)start;

@property (retain) id<SwingTimerDelegate> delegate;
@end

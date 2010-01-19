//
//  AIOpponent.h
//  iPong
//
//  Created by Bryan Summersett on 1/18/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "SwingTimer.h"
#import "Opponent.h"

@interface AIOpponent : NSObject<Opponent, SwingTimerDelegate> {
    float       skillLevel;
    float       swingyness;
    float       hitVelocityDeviation;
    float       specialSwingVelocityDeviation;
    BOOL        doesWinCointoss;
    float       meanVelocity;
    float       meanSpecialSwingVelocity;
    
    id<OpponentDelegate>  delegate;
}

/** Serve back the ball somewhere between 0..5 seconds later. */
- (void)yourServe;

/** The probability the opponent hits, from [0..1]. */
@property (nonatomic) float skillLevel;

/** The probability that the opponent will do a special swing, [0..1]. */
@property (nonatomic) float swingyness;

/** Given a hit, the mean velocity for this opponent. */
@property (nonatomic) float meanVelocity;
@property (nonatomic) float meanSpecialSwingVelocity;

/** Given a hit, the amount of variation between hit velocities. */
@property (nonatomic) float hitVelocityDeviation;
@property (nonatomic) float specialSwingVelocityDeviation;

@property (nonatomic) BOOL doesWinCointoss;
@end

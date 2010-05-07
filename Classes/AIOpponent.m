//
//  AIOpponent.m
//  iPong
//
//  Created by Bryan Summersett on 1/18/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "AIOpponent.h"
#import "Utilities.h"

static const NSInteger kMaxVelocity = 3;
static const NSInteger kMinVelocity = 0.3;

@interface AIOpponent ()
- (void)_fireSimulatedServe;
- (PongEvent*)_simulateEvent;
- (float)_normalDistWithMean:(float) m stdDev:(float)s;
@end

@implementation AIOpponent
@synthesize delegate, doesWinCointoss;
@synthesize meanVelocity, meanSpecialSwingVelocity;
@synthesize skillLevel, swingyness, hitVelocityDeviation, specialSwingVelocityDeviation;

- (void)yourServe
{
    [self _fireSimulatedServe];
}

- (NSString*)humanReadableName
{
    return [self machineName];
}
- (NSString*)machineName
{
    return @"AIOpponent";
}

- (void)sendPongEvent:(PongEvent*)received
{
    if (received.hitEventType == kHitEventMiss) {
        return;
    }

    /* otherwise simulate our timer as if the opponent was waiting to hit it. */
    [SwingTimer timerWithEvent:received
                      delegate:self 
              startImmediately:YES];
}

#pragma mark SwingTimerDelegate methods

-(void)swingTimerBeepDidOccur:(SwingTimer*)st
{
    if ([st isFinalBeep]) {
        [(NSObject*)delegate performSelector:@selector(opponentEventDidOccur:) 
                                  withObject:[self _simulateEvent]];            
    }
}


#pragma mark Private methods

- (id) init
{
    self = [super init];
    if (self != nil) {
        skillLevel = [Random float0to1];
        swingyness = [Random float0to1];
        meanVelocity = [Random float0to1] * 3;
        meanSpecialSwingVelocity = [Random float0to1] * 3;
        doesWinCointoss = [Random bool];
        
        hitVelocityDeviation = 0.5;
        specialSwingVelocityDeviation = 0.5;

        LogTo(Opponent, @"AIOpponent: %@",self);
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"skillLevel %0.2f, swingyness %0.2f, \
            meanVelocity %0.2f, meanSpecial %0.2f, vStdDev %0.2f, specVStdDev %0.2f",
            skillLevel, swingyness, meanVelocity, meanSpecialSwingVelocity,
            hitVelocityDeviation, specialSwingVelocityDeviation];
}

- (void)_fireSimulatedServe
{
    NSTimeInterval delay = [Random float0to1] * 8 + 3;
    LogTo(Opponent, @"received 'yourServe' message, firing serve after %0.2f seconds", delay);
    [(NSObject*)delegate performSelector:@selector(opponentEventDidOccur:) 
                              withObject:[self _simulateEvent] 
                              afterDelay:delay];    
}

- (PongEvent*)_simulateEvent
{
    PongEvent *toSend;
    if ([Random float0to1] > skillLevel) {
        
        SwingType type = kSwingTypeNormal;
        float typeIntensity = 0;
        float v = CLAMP([self _normalDistWithMean:meanVelocity 
                                           stdDev:specialSwingVelocityDeviation],
                        kMinVelocity, kMaxVelocity);
        Assert(v >= kMinVelocity);

        if ([Random float0to1] > swingyness) {
            type = [Random bool] ? kSwingTypeTopSpin : kSwingTypeSlice;
            typeIntensity = CLAMP([self _normalDistWithMean:meanSpecialSwingVelocity 
                                               stdDev:specialSwingVelocityDeviation],
                                  0, 1);
        }
        
        Assert(typeIntensity >= 0);

        toSend = [PongEvent pongHitWithVelocity:v 
                                      swingType:type 
                                  typeIntensity:typeIntensity];
    } else {
        toSend = [PongEvent pongMiss];
    }
    
    LogTo(Opponent, @"simulating event %@", toSend);

    return toSend;
}

/** normal random variate generator. mean m, standard deviation s.
    Taken from: http://www.bearcave.com/misl/misl_tech/wavelets/hurst/random.html . */
- (float)_normalDistWithMean:(float) m stdDev:(float)s
{
	float x1, x2, w, y1;
	static float y2;
	static int use_last = 0;
    
	if (use_last)		        /* use value from previous call */
	{
		y1 = y2;
		use_last = 0;
	}
	else
	{
		do {
			x1 = 2.0 * [Random float0to1] - 1.0;
			x2 = 2.0 * [Random float0to1] - 1.0;
			w = x1 * x1 + x2 * x2;
		} while ( w >= 1.0 );
        
		w = sqrt( (-2.0 * log( w ) ) / w );
		y1 = x1 * w;
		y2 = x2 * w;
		use_last = 1;
	}
    
	return( m + y1 * s );
}

@end

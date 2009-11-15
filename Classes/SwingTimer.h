//
//  SwingTimer.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PongPacket.h"

@protocol SwingTimerDelegate

-(void)intervalDidOccur:(int)interval;

@end

// When allocated, sets off a timer which plays a beep at given intervals 
// given a PongPacket. 
@interface SwingTimer : NSObject {
                                 // array of when the next beep should fire using 
                                 // weighting functions
    NSTimeInterval               *timeAtInterval;
    int                          numBeeps;
    id                           delegate;
}

-(id)initWithEnemyPacket:(PongPacket*)packet andNumBeeps:(int)nBeeps;
-(void)start;

@property (retain) id delegate;

@end

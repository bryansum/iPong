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
  if (curInterval == 4) [timer invalidate];
  [delegate intervalDidOccur:[NSNumber numberWithInt:curInterval]];
  curInterval++;
}

-(id)initWithEnemyPacket:(PongPacket*)packet andNumBeeps:(int)nBeeps
{
    self = [super init];
    if (self != nil) {
        
        numBeeps = nBeeps;
        
        NSTimeInterval totalTime = (double) kDistance / packet->velocity;

        NSLog(@"total time %f", totalTime);
        NSTimeInterval secPerInterval = totalTime/(double)(numBeeps - 1);
      
        timeAtInterval = secPerInterval;       
    }
    return self;    
}

-(void)start
{
  curInterval = 0;
  timer = [[NSTimer scheduledTimerWithTimeInterval:timeAtInterval target:self selector:@selector(fireIntervalBeeps) userInfo:nil repeats:YES] retain];
}

- (void) dealloc
{
    [timer release];
    [delegate release];
    [super dealloc];
}

@end

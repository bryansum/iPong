//
//  Opponent.h
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PongEvent.h"

@protocol OpponentDelegate <NSObject>
- (void)opponentEventDidOccur:(PongEvent*)p;
@end

/** Describes a class which iPong can use to compete with. */
@protocol Opponent

/** If the opponent would win a cointoss against the sender. */
- (BOOL)doesWinCointoss;

/** Send the opponent a Pong event. It should then respond asyncronously via the 
    opponentEventDidOccur: method */
- (void)sendPongEvent:(PongEvent*)p;

@property (retain) NSObject<OpponentDelegate> *delegate;
@property (readonly) NSString *humanReadableName;
@property (readonly) NSString *machineName;

@end

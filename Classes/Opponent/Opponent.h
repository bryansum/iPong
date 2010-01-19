//
//  Opponent.h
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PongEvent.h"

@protocol OpponentDelegate
- (void)opponentEventDidOccur:(PongEvent*)p;
@end

/** Describes a class which iPong can use to compete with. */
@protocol Opponent

/** If the opponent would win a cointoss against the sender. */
- (BOOL)doesWinCointoss;

/** Send the opponent a Pong event. It should then respond asyncronously via the 
    opponentEventDidOccur: method */
- (void)sendPongEvent:(PongEvent*)p;

@property (assign) id<OpponentDelegate> delegate;
@property (readonly) NSString *humanReadableName;
@property (readonly) NSString *machineName;

@optional

/** Alerts the opponent that it is now his serve, if necessary. Networked opponents 
    are already notified of this implicitly, so this is most useful for AI-type 
    opponents. */
- (void)yourServe;
@end

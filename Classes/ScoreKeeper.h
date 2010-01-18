//
//  ScoreKeeper.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	kPeerMe         = 1 << 0,
	kPeerOpponent   = 1 << 1
};
typedef NSUInteger PeerType;

extern const NSInteger kScoreKeeperNumPlayers;

@interface ScoreKeeper : NSObject {
    NSInteger       winningScore;
    NSInteger       *score;
}

/** Returns the current score for the given player. */
- (NSInteger)scoreFor:(PeerType)player;

/** Resets all scores. */
- (void)reset;

/** Increment the given player's score. Returns YES if the player won the game. */
- (BOOL)incrementScoreFor:(PeerType)player;

@property (nonatomic, readonly) NSInteger winningScore;
@end

//
//  ScoreKeeper.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "ScoreKeeper.h"

const NSInteger kScoreKeeperNumPlayers = 2;
static const NSInteger kDefaultWinningScore = 11;

@implementation ScoreKeeper
@synthesize winningScore;

static inline void validateScoreType(PeerType t) {
    assert(t == kPeerMe || t == kPeerOpponent);
}

- (NSInteger)scoreFor:(PeerType)player;
{
    validateScoreType(player);
    return score[player];
}

- (BOOL)incrementScoreFor:(PeerType)player
{
    validateScoreType(player);
    score[player]++;

    if (score[player] == winningScore) {
        return YES;
        // have to win by two
    } else if(score[player] == winningScore - 1 && 
              score[player] == score[player == kPeerMe ? kPeerOpponent : kPeerMe]){
        winningScore++;
    }        

    return NO;
}

- (void)reset
{
    for (int i = 0; i < kScoreKeeperNumPlayers; i++) {
        score[i] = 0;
    }
    winningScore = kDefaultWinningScore;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        score = calloc(kScoreKeeperNumPlayers, sizeof(NSInteger));
        [self reset];
    }
    return self;
}

- (void)dealloc 
{
    free(score);
    [super dealloc];
}

@end

//
//  GameController.m
//  iPong
//
//  Created by Majd Taby on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "iPongAppDelegate.h"
#import "ScoreController.h"

#define kDefaultWinningScore 11

@implementation ScoreController

@synthesize d, winningScore;

- (id) init {
  self = [super init];
  [self resetScores];
  d = [[UIApplication sharedApplication] delegate];
  
  return self;
}

- (void) pointScored:(NSInteger)peerStatus {
  
  score[peerStatus]++;
  [d updateMyScoreLabel:peerStatus withValue:score[peerStatus]];
  
  for(int i = 0; i < 2; i++) {
    if (score[i] == winningScore) {
      [d gameWonFor:i];
    }
    // have to win by two
    if(score[i] == winningScore - 1 && score[i] == score[i ? 0 : 1]){
      winningScore++;
    }        
  }    
  
}

-(void)resetScores
{
  for (int i = 0; i < 2; i++) {
    score[i] = 0;
  }
  self.winningScore = kDefaultWinningScore;
}

- (void)dealloc {
    [super dealloc];
}


@end

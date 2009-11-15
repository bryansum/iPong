//
//  GameController.m
//  iPong
//
//  Created by Majd Taby on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScoreController.h"


@implementation ScoreController

- (void) pointScored:(NSInteger)peerStatus{
  if(!peerStatus){
    localScore++;
  }
  else{
    remoteScore++;
  }
  
  if(localScore == winningScore || remoteScore == winningScore){
    [self gameWon];
  }
  
  if(localScore == winningScore - 1 && localScore == remoteScore){
    winningScore++;
  }
}

- (void) gameWon {
  
}

- (void)dealloc {
    [super dealloc];
}


@end

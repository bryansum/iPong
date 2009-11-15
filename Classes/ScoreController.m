//
//  GameController.m
//  iPong
//
//  Created by Majd Taby on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "iPongAppDelegate.h"
#import "ScoreController.h"


@implementation ScoreController

@synthesize localPeerStatus, d;

- (id) init {
  self = [super init];
  winningScore = 11;
  d = [[UIApplication sharedApplication] delegate];
  
  return self;
}

- (void) pointScored:(NSInteger)peerStatus{
  
  if(peerStatus == localPeerStatus){
    localScore++;
    [d updateMyScoreLabelWithValue:localScore];
  }
  else{
    remoteScore++;
    [d updateRemoteScoreLabelWithValue:remoteScore];
  }
  
  if(localScore == winningScore || remoteScore == winningScore){
    [d gameEnded];
    [self gameWon];
  }
  
  if(localScore == winningScore - 1 && localScore == remoteScore){
    winningScore++;
  }
}

- (void) _showAlert:(NSString *)title withMessage:(NSString *)message andButtonTitle:(NSString *) buttonTitle
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:buttonTitle otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

- (void) alertIsMyFirstServe {
    [self _showAlert:@"Your serve" withMessage:@"You are the server" andButtonTitle:@"Let's play!"];    
}

- (void) alertIsMyServe{
  [self _showAlert:@"Service Change!" withMessage:@"You are now the server" andButtonTitle:@"Let's play!"];
}

- (void) gameWon {
  
  if(localScore == winningScore) {
      [d playWinSound];
    [self _showAlert:@"You won!" 
         withMessage:@"Hail To The Victors!" 
      andButtonTitle:@"Start a new game"];
  } else {
    [self _showAlert:@"You lost :(" 
         withMessage:@"Fail." 
      andButtonTitle:@"Start a new game"];    
  }

}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
  
  if([alertView title] == @"You won!" || [alertView title] == @"You lost :("){
    
    localScore = 0;
    remoteScore = 0;
    winningScore = 11;
    
    [d updateMyScoreLabelWithValue:0];
    [d updateRemoteScoreLabelWithValue:0];
    
      [d startNewGame];
      
  } else if ([alertView title] == @"Your serve") {
      [d startFirstGame];
  } else {
      [d beginGame];
  }
  
}

- (void)dealloc {
    [super dealloc];
}


@end

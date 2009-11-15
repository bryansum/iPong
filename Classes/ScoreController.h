//
//  GameController.h
//  iPong
//
//  Created by Majd Taby on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreController : NSObject <UIAlertViewDelegate> {
  NSInteger winningScore;
  NSInteger score[2];
  
  NSInteger localPeerStatus;
    
    id      d;
}

@property (nonatomic, assign) NSInteger winningScore;
@property (retain) id d;

- (void) resetScores;
- (void) pointScored:(NSInteger)peerStatus;

@end

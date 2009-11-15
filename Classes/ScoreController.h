//
//  GameController.h
//  iPong
//
//  Created by Majd Taby on 11/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreController : NSObject {
  NSInteger winningScore;
  NSInteger localScore;
  NSInteger remoteScore;
}

- (void) gameWon;
- (void) pointScored:(NSInteger) peerStatus;

@end

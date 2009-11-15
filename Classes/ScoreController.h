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
  NSInteger localScore;
  NSInteger remoteScore;
  
  NSInteger localPeerStatus;
    
    id      d;
}

@property (retain) id d;
@property (nonatomic, assign) NSInteger localPeerStatus;

- (void) gameWon;
- (void) alertIsMyServe;
- (void) alertIsMyFirstServe;
- (void) pointScored:(NSInteger) peerStatus;
- (void) _showAlert:(NSString *)title withMessage:(NSString *)message andButtonTitle:(NSString *)buttonTitle;

@end

//
//  InGameView.h
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "VCView.h"

@class InGameViewController;

@interface InGameView : VCView {
    UIButton            *paddleButton;
    UIButton            *soundButton;
    
    NSArray             *dots;
    UIImageView         *flashView;
    
    UILabel             *myScore;
    UILabel             *opponentScore;
}

- (void)displayDotForInterval:(int)interval;
- (void)resetDots;

@property (nonatomic, readonly) UIImageView *flashView;
@property (nonatomic, readonly) UIButton  *paddleButton;
@property (nonatomic, readonly) UILabel   *myScore;
@property (nonatomic, readonly) UILabel   *opponentScore;

@end

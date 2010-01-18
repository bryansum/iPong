//
//  InGameView.h
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 NatIanBryan. All rights reserved.
//

#import "VCView.h"

#ifndef IN_GAME_VIEW_H
#define IN_GAME_VIEW_H

#define kNumDots 4

@interface InGameView : VCView {

    UILabel           *labelView;
    UILabel           *secondLabel;
    
    UIButton          *paddleButton;
    UIButton          *soundButton;
    
    UIImageView       *dots[kNumDots];
    UIImageView       *flashView;
    
    UILabel           *myScore;
    UILabel           *opponentScore;    
}

- (void)displayDotForInterval:(NSNumber*)interval;
- (void)resetDots;

@property (nonatomic, readonly) UIImageView *flashView;
@property (nonatomic, readonly) UIButton  *paddleButton;
@property (nonatomic, readonly) UILabel   *myScore;
@property (nonatomic, readonly) UILabel   *opponentScore;

@end

#endif // IN_GAME_VIEW_H

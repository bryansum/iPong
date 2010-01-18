//
//  InGameViewController.h
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "SwingTimer.h"
#import "NetOpponent.h"

@class InGameView;
@class Jukebox;
@class AccelerometerHandler;
@class ScoreKeeper;
@class Opponent;

enum {
    kGameStatePreGame = 0,
    kGameStateConnecting,
	kGameStatePreServe,
	kGameStatePlaying,
    kGameStateEndGameWaiting,
};
typedef NSInteger GameStateType;

@interface InGameViewController : UIViewController <UIAlertViewDelegate, SwingTimerDelegate, NetOpponentDelegate> {
    UIView                      *containerView;
    InGameView                  *inGameView;
    
    Jukebox                     *audio;    
    AccelerometerHandler        *accHandler;    
	ScoreKeeper                 *scoreKeeper;
    Opponent                    *opponent;
    NSArray                     *alerts;
    
    // game state variables
    GameStateType               gameState;
    BOOL                        isMyServe;
    NSInteger                   curRound;

    NetworkStateType            previousNetworkState;
}

/** called by inGameView when user touched the paddle on-screen. */
- (void)didTouchPaddle;

@property (retain) Opponent *opponent;
@property (readonly) GameStateType gameState;
@property (nonatomic, retain) InGameView *inGameView;
@property (nonatomic, retain) UIView *containerView;
@end

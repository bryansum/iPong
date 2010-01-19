//
//  InGameViewController.m
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "InGameViewController.h"
#import "InGameView.h"
#import "Jukebox.h"
#import "AccelerometerHandler.h"
#import "SwingTimer.h"
#import "PongEvent.h"
#import "ScoreKeeper.h"
#import "BluetoothOpponent.h"
#import "Test.h"
#import "CollectionUtils.h"

enum {
    kAlertYourServe = 0,
    kAlertServiceChange = 1,
    kAlertWin = 2,
    kAlertLoss = 3,
    kAlertOpponentServe = 4
};
typedef NSInteger AlertType;

@interface InGameViewController ()

-(void)_incRound;
-(void)_playerDidWin:(PeerType)p;

- (void)_updateMyScore:(NSInteger)n;
- (void)_updateOpponentScore:(NSInteger)n;
- (void)_startGame;
- (void)_resetGame;
- (void)_resetScores;

- (void)_flashWindow;
- (void)_animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)_showAlert:(AlertType)type;
- (void)_dismissAlert;

@property (nonatomic, retain) NSArray *alerts;
@property (nonatomic, assign) UIAlertView *alertView;
@property (nonatomic, retain) NSMutableArray *alertViewQueue;
@end

@implementation InGameViewController

@synthesize alerts, alertViewQueue, alertView;
@synthesize inGameView, containerView, gameState, opponent;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{    
	//Show the window
    CGRect box = CGRectMake(0, 0, 480, 320);
    self.containerView = [[[UIView alloc] initWithFrame:box] autorelease];
    self.containerView.backgroundColor = [UIColor darkGrayColor];
    self.inGameView = [[[InGameView alloc] initWithFrame:box viewController:self] autorelease];
    
    [containerView addSubview:self.inGameView];
    self.view = containerView;
    
    [accHandler startRecording];

    [self _resetGame];

    LogTo(InGame,@"InGameView loaded");
}

- (void)viewDidUnload
{
    [accHandler stopRecording];
    self.inGameView = nil;
    self.containerView = nil;
    
    LogTo(InGame,@"InGameView unloaded");
}

#pragma mark OpponentDelegate methods

- (void)opponentEventDidOccur:(PongEvent*)p
{
    LogTo(InGame,@"received opponentEvent event: %@",p);
    AssertEq(gameState, kGameStatePlaying);

    if (p.hitEventType == kHitEventHit) {
        
        /** If our OpponentServe dialog is present, just quit it. */
        if (alertView && alertView.visible && alertView.tag == kAlertOpponentServe) {
            [self _dismissAlert];
        }

        [SwingTimer timerWithEvent:p delegate:self startImmediately:YES];
        
    } else {
        BOOL didWin = [scoreKeeper incrementScoreFor:kPeerMe];
        [self _updateMyScore:[scoreKeeper scoreFor:kPeerMe]];
        if (didWin) {
            [self _playerDidWin:kPeerMe];
        } else {
            [self _incRound];
        }
    }
}

/** NetOpponent uses this to inform the delegate of any network changes. Note that
    Opponent does not need to call this. */
- (void)opponentDidChangeState:(NSNumber*)networkState
{
    NetworkStateType state = [networkState integerValue];
    LogTo(InGame,@"opponent changed state to %@",descriptionforNetworkState(state));

    switch (state) {
        case kNetworkStateConnected: {
            // If we're succeeded in reconnecting
            if (previousNetworkState == kNetworkStateReconnecting) {
                [accHandler startRecording];
            } else {
                AssertEq(kGameStateConnecting, gameState);
                [self _startGame];
            }
        }
            break;
        // network error. An alert view will be present on screen, so we should
        // stop handling acceleration, etc. 
        case kNetworkStateReconnecting: {
            [accHandler stopRecording];
            if (alertView) {
                Warn(@"Trying to dimiss alertView to show reconnecting alert view; doing nothing for now");
                [self _dismissAlert];
            }
        }
        case kNetworkStateDisconnected: {
            [self _resetGame];
        }
        default:
            break;
    }
    previousNetworkState = state;
}

#pragma mark SwingTimerDelegate methods

- (void)swingTimerBeepDidOccur:(SwingTimer*)st
{
    [self _flashWindow];
    
    if (![st isFinalBeep]) {
        [audio playSound:@"bounce"];
        [inGameView displayDotForInterval:st.curBeep];
    } else {
        [inGameView resetDots];
        PongEvent *event = [accHandler currentSwing];
        
        if (event.hitEventType == kHitEventMiss) {
            BOOL didWin = [scoreKeeper incrementScoreFor:kPeerOpponent];
            [self _updateOpponentScore:[scoreKeeper scoreFor:kPeerOpponent]];
            if (didWin) {
                [self _playerDidWin:kPeerOpponent];
            } else {
                [self _incRound];                
            }
        }
        [opponent sendPongEvent:event];
    }    
}

#pragma mark InGameView methods

- (void)didTouchPaddle
{
    Assert(opponent, @"opponent shouldn't be nil");
    if (gameState == kGameStatePreGame) {
        if ([opponent conformsToProtocol:@protocol(NetOpponent)]) {
            LogTo(InGame,@"finding network opponents");
            [opponent findOpponents];
            gameState = kGameStateConnecting;
        } else {
            LogTo(InGame,@"no network, starting game immediately");
            [self _startGame];
        }

    } else if (gameState == kGameStatePreServe) {
        LogTo(InGame,@"initiating serve swing");
        gameState = kGameStatePlaying;
        PongEvent *pongEvent = [PongEvent pongHitWithVelocity:1 swingType:kSwingTypeNormal typeIntensity:0];
        [SwingTimer timerWithEvent:pongEvent delegate:self startImmediately:YES];
    }
}

#pragma mark Private methods
             
- (void)_resetGame
{
    LogTo(InGame,@"game was reset");
    curRound = 0;
    gameState = kGameStatePreGame;
    previousNetworkState = -1;
    [self _resetScores];
}

- (void)_startGame
{
    if ([opponent doesWinCointoss]) {
        isMyServe = NO;
        gameState = kGameStatePlaying;
        [self _showAlert:kAlertOpponentServe];
        [opponent yourServe];
    } else {
        isMyServe = YES;
        gameState = kGameStatePreServe;
        [self _showAlert:kAlertYourServe];
    }
}

-(void)_incRound
{
    if (++curRound % 5 == 0) {
        isMyServe = !isMyServe;
        
        LogTo(InGame,@"service change! Is it now %@ serve", isMyServe ? @"my" : @"opponent's");
        if (isMyServe) {
            [self _showAlert:kAlertServiceChange];
        } else {
            [self _showAlert:kAlertOpponentServe];
        }
    }
    
    LogTo(InGame,@"currentRound: %d",curRound);
    
    if (isMyServe) {
        gameState = kGameStatePreServe;
    } else {
        /* tell AI opponents that should serve again. */
        [opponent yourServe];
        gameState = kGameStatePlaying;
    }
}

-(void)_playerDidWin:(PeerType)p
{
    if (p == kPeerMe) {
        [audio playSound:@"happy"];
        [self _showAlert:kAlertWin];
    } else {
        [self _showAlert:kAlertLoss];
    }
    gameState = kGameStateEndGameWaiting;
}

- (void)_showAlert:(AlertType)alertType
{
    /** add to the queue if one alert is already present. */
    if (alertView) {
        [alertViewQueue addObject:$object(alertType)];
    } else {
        NSDictionary *alertStrings = [alerts objectAtIndex:alertType];
        LogTo(InGame,@"showing alert type '%@'",[alertStrings objectForKey:@"title"]);
        
        self.alertView = [[[UIAlertView alloc] initWithTitle:[alertStrings objectForKey:@"title"]
                                                     message:[alertStrings objectForKey:@"description"] 
                                                    delegate:self 
                                           cancelButtonTitle:[alertStrings objectForKey:@"buttonTitle"]
                                           otherButtonTitles:nil] autorelease];
        alertView.tag = alertType;
        alertView.delegate = self;
        [alertView show];
        
        /* temporarily stop reading accelerometer data. */
        [accHandler stopRecording];        
    }
}

- (void)_dismissAlert
{
    if (!alertView) {
        LogTo(InGame,@"dismissAlert called but no alerts visible.");
    } else {
        /** This will in turn call the delegate method and pick the next alert off the queue, if present. */
        [alertView dismissWithClickedButtonIndex:alertView.cancelButtonIndex animated:YES];
    }
}

/** UIAlertViewDelegate delegate method. */
- (void)alertView:(UIAlertView *)av didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AssertEqual(av, alertView);

    AlertType alertType = av.tag;
    switch (alertType) {
        case kAlertWin:
        case kAlertLoss: {
            [self _resetScores];
            [self _incRound];
        }
            break;
        case kAlertYourServe:
        case kAlertServiceChange:
        case kAlertOpponentServe:
            break;
        default:
            Warn(@"AlertType %d not present in array",alertType);
            break;
    }

    alertView = nil;
    /* Take the next alert in the queue and display it. */
    if ([alertViewQueue count]) {
        AlertType aType = [[alertViewQueue objectAtIndex:0] integerValue];
        [alertViewQueue removeObjectAtIndex:0];
        [self _showAlert:aType];
    }

    [accHandler startRecording];
}

- (void)_resetScores
{
    [scoreKeeper reset];
    [self _updateMyScore:0];
    [self _updateOpponentScore:0];
}

- (void)_updateMyScore:(NSInteger)n
{
    inGameView.myScore.text = [NSString stringWithFormat:@"%d",n];
}

- (void)_updateOpponentScore:(NSInteger)n
{
    inGameView.opponentScore.text = [NSString stringWithFormat:@"%d",n];
}


- (void)_flashWindow
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(_animationFinished:finished:context:)];
	[inGameView.flashView setAlpha:0.6];
	[UIView commitAnimations];	
}

- (void)_animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[inGameView.flashView setAlpha:0.0];
	[UIView commitAnimations];		
}

- (id)initWithNibName:(NSString*)nib bundle:(NSBundle*)bundle
{
    self = [super initWithNibName:nib bundle:bundle];
    if (self != nil) {
        opponent = nil;
        audio = [[Jukebox alloc] init];
        scoreKeeper = [[ScoreKeeper alloc] init];
        accHandler = [[AccelerometerHandler alloc] init];
        alertView = nil;
        
        self.alertViewQueue = [NSMutableArray array];
        self.alerts = $array($dict({@"title",NSLocalizedString(@"Your serve!",@"alert declaring the player is serving")},
                              {@"description",NSLocalizedString(@"You are the server.", @"service change description")},
                              {@"buttonTitle",NSLocalizedString(@"Click paddle to serve", @"serv. change confirm button")}),

                        $dict({@"title",NSLocalizedString(@"Service Change!",@"service change title")},
                              {@"description",NSLocalizedString(@"You are now the server.", @"service change description")},
                              {@"buttonTitle",NSLocalizedString(@"Click paddle to serve", @"serv. change confirm button")}),
                        
                        $dict({@"title",NSLocalizedString(@"You won!", @"winning title")},
                              {@"description",NSLocalizedString(@"Hail To The Victors!",@"winning alert description.")},
                              {@"buttonTitle",NSLocalizedString(@"Start a new game",@"option asking to start a game")}),
                        
                        $dict({@"title",NSLocalizedString(@"You lost :(",@"losing title")},
                              {@"description",NSLocalizedString(@"Fail.",@"losing alert description")},
                              {@"buttonTitle",NSLocalizedString(@"Start a new game.",@"option asking to start a game")}),
                        $dict({@"title",NSLocalizedString(@"Opponent's serve!",@"service change title")},
                              {@"description",NSLocalizedString(@"Your opponent is serving. Just wait for them to attempt their serve to you.", 
                                                                @"description of what happens when the opponent serves. ")},
                              {@"buttonTitle",NSLocalizedString(@"Continue", @"continue playing")})
                         );
        
    }
    return self;
}

- (void)dealloc
{
    self.opponent = nil;
    self.alerts = nil;
    [alertView release];
    [audio release];
    [accHandler release];
    [scoreKeeper release];    
    [super dealloc];
}

@end

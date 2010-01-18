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
#import "CollectionUtils.h"
#import "Test.h"

enum {
    kAlertServiceChange = 0,
    kAlertWin = 1,
    kAlertLoss = 2
};
typedef NSInteger AlertType;

@interface InGameViewController (Private)

-(void)_incRound;
-(void)_playerDidWin:(PeerType)p;

- (void)_updateMyScore:(NSInteger)n;
- (void)_updateOpponentScore:(NSInteger)n;
- (void)_startGame;
- (void)_resetGame;
- (void)_resetScores;

- (void)_startAnimation;
- (void)_animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)_showAlert:(AlertType)type;
@end

@implementation InGameViewController

@synthesize inGameView, containerView, gameState, opponent;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{    
	//Show the window
    CGRect box = CGRectMake(0, 0, 480, 320);
    self.containerView = [[[UIView alloc] initWithFrame:box] autorelease];
    self.containerView.backgroundColor = [UIColor darkGrayColor];
    self.inGameView = [[[InGameView alloc] initWithFrame:box andViewController:self] autorelease];
    
    [containerView addSubview:self.inGameView];
    self.view = containerView;
    
    [accHandler startRecording];

    [self _resetGame];
}

- (void)viewDidUnload
{
    [accHandler stopRecording];
    self.inGameView = nil;
    self.containerView = nil;
}

#pragma mark OpponentDelegate methods

- (void)opponentEventDidOccur:(PongEvent*)p
{
    AssertEq(gameState, kGameStatePlaying);

    if (p.hitEventType == kHitEventHit) {
        [SwingTimer timerWithEvent:p delegate:self startImmediately:YES];
    } else {
        [self _updateMyScore:[scoreKeeper scoreFor:kPeerMe]];
        if ([scoreKeeper incrementScoreFor:kPeerMe]) {
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

- (void)swingTimerBeepDidOccur:(NSNumber *)b
{
    NSInteger beepNum = [b integerValue];
    
    [self _startAnimation];
    
    if (beepNum != kFinalBeep) {
        [audio playSound:@"bounce"];
    } else {        
        PongEvent *event = [accHandler currentSwing];
        
        if (event.hitEventType == kHitEventMiss) {
            [self _updateOpponentScore:[scoreKeeper scoreFor:kPeerOpponent]];
            if ([scoreKeeper incrementScoreFor:kPeerOpponent]) {
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
            [opponent findOpponents];
            gameState = kGameStateConnecting;
        } else {
            [self _startGame];
        }

    } else if (gameState == kGameStatePreServe) {
        PongEvent *pongEvent = [PongEvent pongHitWithVelocity:1 swingType:kSwingTypeNormal typeIntensity:0];
        [SwingTimer timerWithEvent:pongEvent delegate:self startImmediately:YES];
        gameState = kGameStatePlaying;
    }
}

#pragma mark Private methods
             
- (void)_resetGame
{
    curRound = 0;
    gameState = kGameStatePreGame;
    previousNetworkState = -1;
    [self _resetScores];
}

- (void)_startGame
{
    if ([opponent doesWinCointoss]) {
        gameState = kGameStatePlaying;
    } else {
        gameState = kGameStatePreServe;
    }
}

-(void)_incRound
{
    if (++curRound % 5 == 0) {
        isMyServe = !isMyServe;
        
        if (isMyServe) {
            [self _showAlert:kAlertServiceChange];
        }
    }
    
    gameState = isMyServe ? kGameStatePreServe : kGameStatePlaying;
}

-(void)_playerDidWin:(PeerType)p
{
    if (p == kPeerMe) {
        [audio playSound:@"happy" atVolume:1];
        [self _showAlert:kAlertWin];
    } else {
        [self _showAlert:kAlertLoss];
    }
    gameState = kGameStateEndGameWaiting;
}

- (void)_showAlert:(AlertType)alertType
{
    NSDictionary *alertStrings = [alerts objectAtIndex:alertType];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[alertStrings objectForKey:@"title"]
                                                        message:[alertStrings objectForKey:@"description"] 
                                                       delegate:self 
                                              cancelButtonTitle:[alertStrings objectForKey:@"buttonTitle"]
                                              otherButtonTitles:nil];
    alertView.tag = alertType;
    alertView.delegate = self;
    [alertView show];
    [alertView release];
    
    // temporarily stop reading accelerometer data
    [accHandler stopRecording];
}

/** UIAlertViewDelegate delegate method. */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    AlertType alertType = alertView.tag;
    switch (alertType) {
        case kAlertWin:
        case kAlertLoss: {
            [self _resetScores];
            gameState = kGameStatePreServe;
        }
            break;
        default:
            break;
    }
    [accHandler startRecording];
}

- (void)_resetScores
{
    [self _updateMyScore:0];
    [self _updateOpponentScore:0];
}

- (void)_updateMyScore:(NSInteger)n
{
    [self.inGameView.myScore setText:[NSString stringWithFormat:@"%d",n]];
}

- (void)_updateOpponentScore:(NSInteger)n
{
    [self.inGameView.opponentScore setText:[NSString stringWithFormat:@"%d",n]];
}


- (void)_startAnimation
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(_animationFinished:finished:context:)];
    
	// Change property or properties here
	[self.inGameView.flashView setAlpha:0.6];
	[UIView commitAnimations];	
}

- (void)_animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.15];
	[UIView setAnimationDelegate:self];
    
	// Change property or properties here
	[self.inGameView.flashView setAlpha:0.0];
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
        
        alerts = $array($dict({@"title",NSLocalizedString(@"Service Change!",@"service change title")},
                              {@"description",NSLocalizedString(@"You are now the server", @"service change description")},
                              {@"buttonTitle",NSLocalizedString(@"Click paddle to serve", @"serv. change confirm button")}),
                        
                        $dict({@"title",NSLocalizedString(@"You won!", @"winning title")},
                              {@"description",NSLocalizedString(@"Hail To The Victors!",@"winning alert description.")},
                              {@"buttonTitle",NSLocalizedString(@"Start a new game",@"option asking to start a game")}),
                        
                        $dict({@"title",NSLocalizedString(@"You lost :(",@"losing title")},
                              {@"description",NSLocalizedString(@"Fail.",@"losing alert description")},
                              {@"buttonTitle",NSLocalizedString(@"Start a new game",@"option asking to start a game")})
                        );
    }
    return self;
}

- (void)dealloc
{
    self.opponent = nil;
    [audio release];
    [accHandler release];
    [scoreKeeper release];    
    [alerts release];
    [super dealloc];
}

@end

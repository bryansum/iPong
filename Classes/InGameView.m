//
//  InGameView.m
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "InGameView.h"
#import "InGameViewController.h"

static const NSInteger kNumDots = 4;

@interface InGameView (Private)
- (void)_setupView;
@end


@implementation InGameView

@synthesize myScore, opponentScore, paddleButton, flashView;

- (void)displayDotForInterval:(int)i
{
    Log(@"displaying dot for %d", i);
    UIImageView *dot = [dots objectAtIndex:i];
    dot.image = [UIImage imageNamed:@"glowing-dot.png"];
}

- (void)resetDots
{
    for(int i = 0; i < kNumDots; i++) {
        [[dots objectAtIndex:i] setImage:[UIImage imageNamed:@"empty-dot.png"]];
    }
}

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)vc
{
    if ((self = [super initWithFrame:frame viewController:vc])) {
        [self _setupView];
    }
    return self;
}

- (void) dealloc
{
    [dots release];
    
    [paddleButton release];
    [soundButton release];
    
    [flashView release];
    [myScore release];
    [opponentScore release];
    [super dealloc];
}

#pragma mark Private methods

- (void)_setupView
{
    UIImageView *bgPattern = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-pattern.png"]];
    [bgPattern setFrame:[[UIScreen mainScreen] bounds]];
    [self addSubview:bgPattern];
    [bgPattern release];
    
	UIImageView *scoreboardBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-bg.png"]];
    [scoreboardBg setFrame:CGRectMake(0, 0, 320, 480)];
    [self addSubview:scoreboardBg];
    [scoreboardBg release];
    
	UIImageView *scoreboard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard.png"]];
    [scoreboard setFrame:CGRectMake(0, 40, 320, 53)];
    [self addSubview:scoreboard];
    [scoreboard release];
    
	UIImageView *divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scoreboard-divider.png"]];
    [divider setFrame:CGRectMake(160, 41, 2, 51)];
    [self addSubview:divider];
    [divider release];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(136, 20, 83, 18)];
    [scoreLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    [scoreLabel setText:@"SCORE"];
    [scoreLabel setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
    [scoreLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [scoreLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [scoreLabel setTextColor:[UIColor colorWithRed:97.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0]];
    [self addSubview:scoreLabel];
    [scoreLabel release];
    
    myScore = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 153, 35)];
    [myScore setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    [myScore setText:@"0"];
    [myScore setTextAlignment:UITextAlignmentCenter];
    [myScore setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
    [myScore setShadowOffset:CGSizeMake(0.0, 1.0)];
    [myScore setFont:[UIFont boldSystemFontOfSize:40.0]];
    [myScore setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
    [self addSubview:myScore];
    
    opponentScore = [[UILabel alloc] initWithFrame:CGRectMake(160, 50, 153, 35)];
    [opponentScore setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    [opponentScore setText:@"0"];
    [opponentScore setTextAlignment:UITextAlignmentCenter];
    [opponentScore setShadowColor:[UIColor colorWithRed:221.0/255.0 green:230.0/255.0 blue:211.0/255.0 alpha:1.0]];
    [opponentScore setShadowOffset:CGSizeMake(0.0, 1.0)];
    [opponentScore setFont:[UIFont boldSystemFontOfSize:40.0]];
    [opponentScore setTextColor:[UIColor colorWithRed:74.0/255.0 green:96.0/255.0 blue:52.0/255.0 alpha:1.0]];
    [self addSubview:opponentScore];
    
    paddleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [paddleButton setFrame:CGRectMake(70, 130, 186, 310)];
    [paddleButton imageRectForContentRect:CGRectMake(100, 1300, 3200, 350)];
    [paddleButton setBackgroundImage:[UIImage imageNamed:@"paddle.png"] forState:UIButtonTypeCustom];
    [paddleButton addTarget:self.viewController action:@selector(didTouchPaddle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:paddleButton];
    
    int curX = 110;
    NSMutableArray *mDotsArray = [NSMutableArray array];
    for(int i = 0; i < kNumDots; i++) {
        UIImageView *dot = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty-dot.png"]] autorelease];
        [dot setFrame:CGRectMake(curX, 440, 30, 30)];
        [self addSubview:dot];
        [mDotsArray insertObject:dot atIndex:i];
        curX += 25;            
    }
    dots = [mDotsArray copy];
	
	flashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	[flashView setImage:[UIImage imageNamed:@"white.png"]];
	[flashView setAlpha:0.0];
	[self addSubview:flashView];
}

@end

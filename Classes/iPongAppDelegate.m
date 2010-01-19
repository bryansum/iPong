//
//  iPongAppDelegate.m
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "iPongAppDelegate.h"
#import "InGameViewController.h"
#import "BluetoothOpponent.h"
#import "AIOpponent.h"
#import "W2Utilities.h"

@implementation iPongAppDelegate

@synthesize window, viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//Create a full-screen window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setBackgroundColor:[UIColor darkGrayColor]];

    /* Seed our random number generator. */
    [Random seed:time(NULL)];

    viewController = [[InGameViewController alloc] initWithNibName:nil bundle:nil];
    viewController.opponent = [[[AIOpponent alloc] init] autorelease];
    [viewController.opponent setDelegate:viewController];
//    viewController.opponent = [[[BluetoothOpponent alloc] init] autorelease];
//    [viewController.opponent setDelegate:viewController];
    
    [window addSubview:self.viewController.view];
    [window makeKeyAndVisible];
}

                  
- (void)dealloc
{
    self.viewController = nil;
    self.window = nil;
    
    [super dealloc];
}


@end

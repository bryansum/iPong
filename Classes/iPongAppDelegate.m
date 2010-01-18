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

@implementation iPongAppDelegate

@synthesize window, viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//Create a full-screen window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setBackgroundColor:[UIColor darkGrayColor]];

    viewController = [[InGameViewController alloc] initWithNibName:nil bundle:nil];
    viewController.opponent = [[[BluetoothOpponent alloc] init] autorelease];
    
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

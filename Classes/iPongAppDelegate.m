//
//  iPongAppDelegate.m
//  iPong
//
//  Created by Bryan Summersett on 11/13/09.
//  Copyright http://bsumm.net 2010. All rights reserved.
//

#import "iPongAppDelegate.h"
#import "InGameViewController.h"
#import "BluetoothOpponent.h"
#import "AIOpponent.h"
#import "Utilities.h"

@implementation iPongAppDelegate

@synthesize window, viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//Create a full-screen window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setBackgroundColor:[UIColor darkGrayColor]];

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

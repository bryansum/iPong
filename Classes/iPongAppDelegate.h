//
//  iPongAppDelegate.h
//  iPong
//
//  Created by Majd Taby on 11/13/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

@class InGameViewController;

@interface iPongAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow                *window;
    InGameViewController    *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) InGameViewController *viewController;
@end


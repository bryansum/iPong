//
//  iPongAppDelegate.h
//  iPong
//
//  Created by Bryan Summersett on 11/13/09.
//  Copyright http://bsumm.net 2010. All rights reserved.
//

@class InGameViewController;

@interface iPongAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow                *window;
    InGameViewController    *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) InGameViewController *viewController;
@end


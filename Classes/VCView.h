//
//  VCView.h
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

/** VCView adds a view controller property to the standard UIView. */
@interface VCView : UIView {
    UIViewController    *viewController;
}

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)vc;

@property (nonatomic, assign) UIViewController *viewController;
@end

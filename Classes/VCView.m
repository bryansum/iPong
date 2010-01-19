//
//  VCView.m
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "VCView.h"
#import "InGameViewController.h"

@implementation VCView

@synthesize viewController;

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)vc
{
    if ((self = [super initWithFrame:frame])) {

        // Note: we want a weak pointer here so that we don't cause any 
        // circular dependencies
        self.viewController = vc;
        
    }
    return self;
}

- (void) dealloc
{
    self.viewController = nil;
    [super dealloc];
}


@end

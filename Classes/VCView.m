//
//  VCView.m
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 NatIanBryan. All rights reserved.
//

#import "VCView.h"
#import "InGameViewController.h"

@implementation VCView

@synthesize viewController;

- (id)init
{
    NSLog(@"default init should never be called for this view");
    assert(false);
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (id)initWithFrame:(CGRect)frame andViewController:(InGameViewController*)vc
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

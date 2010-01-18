//
//  VCView.h
//  iPong
//
//  Created by Bryan Summersett on 1/11/10.
//  Copyright 2010 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InGameViewController;

@interface VCView : UIView {
    InGameViewController    *viewController;
}

- (id)initWithFrame:(CGRect)frame andViewController:(InGameViewController*)vc;

@property (nonatomic, assign) InGameViewController *viewController;
@end

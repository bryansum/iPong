//
//  Utilities.m
//  iPong
//
//  Created by Bryan Summersett on 1/18/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "Utilities.h"
#import <stdlib.h>

#define ARC4RANDOM_MAX      0x100000000

@implementation Random

+ (BOOL)bool
{
    return arc4random() & 0x1;
}

+ (float)float0to1
{
	return (float)floorf(((double)arc4random() / ARC4RANDOM_MAX) * 1.0f);
}


@end

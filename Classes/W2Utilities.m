//
//  W2Utilities.m
//  iPong
//
//  Created by Bryan Summersett on 1/18/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "W2Utilities.h"

@implementation Random

+ (void)seed:(NSInteger)s
{
    srandom(s);
}

+ (BOOL)bool
{
    return random() & 0x1;
}

+ (float)float0to1
{
    return (float)random()/LONG_MAX;
}


@end

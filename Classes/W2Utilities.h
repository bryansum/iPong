/*
 *  W2Utilities.h
 *  iPong
 *
 *  Created by Bryan Summersett on 1/18/10.
 *  Copyright 2010 WinBy2Sports. All rights reserved.
 *
 */

#define CLAMP(x, l, h)  (((x) > (h)) ? (h) : (((x) < (l)) ? (l) : (x)))

@interface Random : NSObject

+ (void)seed:(NSInteger)s;
+ (BOOL)bool;
+ (float)float0to1;

@end

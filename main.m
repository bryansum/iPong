//
//  main.m
//  iPong
//
//  Created by Bryan Summersett on 11/13/09.
//  Copyright http://bsumm.net 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil,  @"iPongAppDelegate");
    [pool release];
    return retVal;
}

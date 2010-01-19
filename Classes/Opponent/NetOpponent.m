//
//  NetOpponent.m
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "NetOpponent.h"

const NSTimeInterval kDefaultHearbeatInterval = 0.25; // 1/4 sec heartbeat

NSString *descriptionforNetworkState(NetworkStateType t)
{
    NSString *d = nil;
    switch (t) {
        case kNetworkStateDisconnected:
            d = @"Disconnected";
            break;
        case kNetworkStateCointoss:
            d = @"Cointoss";
            break;
        case kNetworkStateFinding:
            d = @"Finding";
            break;
        case kNetworkStateConnected:
            d = @"Connected";
            break;
        case kNetworkStateReconnecting:
            d = @"Reconnecting";
        default:
            [NSException raise:@"InvalidNetworkState" format:@"network state was invalid"];
            break;
    }
    return d;
}

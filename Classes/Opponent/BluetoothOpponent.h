//
//  NetOpponent.h
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "NetOpponent.h"

@interface BluetoothOpponent : NSObject <NetOpponent, GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate> {
    // networking
	GKSession                   *session;
    NSString                    *opponentGamePeerId;
    NSInteger                   networkState;
    BOOL                        doesWinCointoss;

    // Heartbeat info
    NSDate                      *lastHeartbeatDate;
    NSTimeInterval              heartbeatInterval;
    NSTimer                     *heartbeatTimer;
    
    // GUI variables
    GKPeerPickerController      *picker;
    UIAlertView                 *connectionAlert;
    
    NSObject<NetOpponentDelegate>    *delegate;
}

@end

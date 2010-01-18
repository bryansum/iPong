//
//  NetOpponent.h
//  iPong
//
//  Created by Bryan Summersett on 1/16/10.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "Opponent.h"

enum {
    kNetworkStateDisconnected   = 1 << 0,
	kNetworkStateFinding        = 1 << 1,
    kNetworkStateCointoss       = 1 << 2,
	kNetworkStateConnected      = 1 << 3,
    kNetworkStateReconnecting   = 1 << 4
};
typedef NSInteger NetworkStateType;

/** Describes a delegate for network-based opponents. */
@protocol NetOpponentDelegate <OpponentDelegate>

/** Alert the delegate method when the opponent changed state. This includes 
 the initial 'disconnected' state, 'finding', etc. and is a NSNumber masquerading
 as a NetworkStateType. Use the integerValue method to extract its real value. */
- (void)opponentDidChangeState:(NSNumber*)networkState;

@end

/** Describes a network-based opponent. */
@protocol NetOpponent <Opponent>

/** Since network opponents need to first be found, start a search to find one. 
    This may involve opening alert views, dialog boxes, etc. To determine when it
    has found an opponent the sender should listen via the opponentDidChangeState: 
    delegate method. */
- (void)findOpponents;

/** Disconnect from all searches, etc. */
- (void)disconnect;

/** Current state of the network. */
@property (readonly) NetworkStateType networkState;
@property NSTimeInterval heartbeatInterval; 
@end

extern const NSTimeInterval kDefaultHearbeatInterval;

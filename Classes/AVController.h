//
//  AVController.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVController : NSObject {
    
    NSMutableDictionary      *soundPlayers;
}

- (void)playBeepAtVolume:(float)volume;
- (void)playHitAtVolume:(float)volume;

@end

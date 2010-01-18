//
//  AudioController.h
//  iPong
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

@interface Jukebox : NSObject {
    NSMutableDictionary      *soundPlayers;
}

-(void)playSound:(NSString *)sound;
-(void)playSound:(NSString *)sound atVolume:(float)volume;

@end

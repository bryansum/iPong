//
//  AVController.m
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AVController.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation AVController

- (id) init
{
    self = [super init];
    if (self != nil) {
        // Make the array to store our AVAudioPlayer objects
        NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"aif" inDirectory:nil];
        
        soundPlayers = [[NSMutableDictionary alloc] initWithCapacity:[paths count]];
        NSLog(@"Capacity %d", [paths count]);
        for (NSString *path in paths) {
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
            AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
            
            // set up AudioPlayer so it doesn't have to load it initially
            [player prepareToPlay];
            
            NSString *instrumentName = [[path lastPathComponent] stringByDeletingPathExtension];
            NSLog(@"audio file %@", instrumentName);
            // set every audio player's key to its last path component without the extension,
            // i.e., 'kick'
            [soundPlayers setObject:player forKey:instrumentName];
            [fileURL release];
            [player release];
        }
        
    }
    return self;
}

-(void)dealloc
{
    [soundPlayers release];
    [super dealloc];
}

-(void)playSound:(NSString *)sound atVolume:(float)volume
{
    AVAudioPlayer *player = [soundPlayers objectForKey:sound];
    if (player == nil) {
        NSLog(@"Couldn't find instrument '%@'\n",sound);
        return;
    }
    if ([player isPlaying]) {
        [player stop];
        [player setCurrentTime:0];
    }
    [player play];
}

- (void)playBeepAtVolume:(float)volume
{
    [self playSound:@"tap" atVolume:volume];
}

- (void)playHitAtVolume:(float)volume
{
    [self playSound:@"tap" atVolume:volume];
}


@end

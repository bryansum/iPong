//
//  AudioController.m
//  iPong
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "Jukebox.h"
#import <AVFoundation/AVFoundation.h>

@implementation Jukebox

- (id) init
{
    self = [super init];
    if (self != nil) {
        
        NSArray *resources = $array(@"wav",@"mp3");
        for (NSString *resourceType in resources) {

            NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"wav" inDirectory:nil];
            
            // Make the array to store our AVAudioPlayer objects
            soundPlayers = [[NSMutableDictionary alloc] initWithCapacity:[paths count]];
            NSError *err;
            
            for (NSString *path in paths) {
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
                AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];
                
                if (!player) {
                    NSLog(@"AudioController error: %@\n", *err);
                }
                // set up AudioPlayer so it doesn't have to load it initially
                [player prepareToPlay];
                
                NSString *instrumentName = [[path lastPathComponent] stringByDeletingPathExtension];
                
                // set every audio player's key to its last path component without the extension,
                // i.e., 'kick'
                [soundPlayers setObject:player forKey:instrumentName];
                [fileURL release];
                [player release];
            }            
        }
        
    }
    return self;
}

-(void)dealloc
{
    [soundPlayers release];
    [super dealloc];
}

-(void)playSound:(NSString *)sound
{
    [self playSound:sound atVolume:1];
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
    [player setVolume:volume];
    [player play];      
}

@end

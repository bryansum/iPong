//
//  PongEvent.m
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

#import "PongEvent.h"

@implementation PongEvent
@synthesize hitEventType, velocity, swingType, typeIntensity;

+ (id)pongMiss
{
    return [[[[self class] alloc] initWithMiss] autorelease];
}

+ (id)pongHitWithVelocity:(float)v 
                swingType:(SwingType)st 
            typeIntensity:(float)intensity
{
    return [[[[self class] alloc] initHitVelocity:v 
                                        swingType:st 
                                    typeIntensity:intensity] autorelease];
}

- (id)initWithMiss
{
    self = [super init];
    if (self != nil) {
        hitEventType = kHitEventMiss;
    }
    return self;
}

- (id)initHitVelocity:(float)v 
            swingType:(SwingType)st 
        typeIntensity:(float)intensity
{
    self = [super init];
    if (self != nil) {
        hitEventType = kHitEventHit;
        velocity = v;
        swingType = st;
        typeIntensity = intensity;        
    }
    return self;
}

/** Since the class is immutable, we can just make copies of it */
- (id) copyWithZone: (NSZone*)zone
{
    return [self retain];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:hitEventType forKey:@"hitEventType"];
    [coder encodeFloat:velocity forKey:@"velocity"];
    [coder encodeInteger:swingType forKey:@"swingType"];
    [coder encodeFloat:typeIntensity forKey:@"intensity"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self ) {        
        hitEventType = [decoder decodeIntegerForKey:@"hitEventType"];
        velocity = [decoder decodeFloatForKey:@"velocity"];
        swingType = [decoder decodeIntegerForKey:@"swingType"];
        typeIntensity = [decoder decodeFloatForKey:@"intensity"];
    }
    return self;
}
@end

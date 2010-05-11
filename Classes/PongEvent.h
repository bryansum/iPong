//
//  PongEvent.h
//  iPong
//
//  Created by Bryan Summersett on 11/14/09.
//  Copyright 2010 WinBy2Sports. All rights reserved.
//

enum {
    kHitEventMiss,
    kHitEventHit
};
typedef NSInteger HitEventType;

enum {
    kSwingTypeTopSpin,
    kSwingTypeSlice,
    kSwingTypeNormal
};
typedef NSInteger SwingType;

@interface PongEvent : NSObject <NSCopying, NSCoding> {
    HitEventType    hitEventType;
    float           velocity;
    SwingType       swingType;
    float           typeIntensity;
}

+ (id)pongMiss;
+ (id)pongHitWithVelocity:(float)velocity 
                swingType:(SwingType)st 
            typeIntensity:(float)intensity;

- (id)initWithMiss;
- (id)initHitVelocity:(float)velocity 
            swingType:(SwingType)st 
        typeIntensity:(float)intensity;

@property (nonatomic, readonly) HitEventType hitEventType;
@property (nonatomic, readonly) SwingType swingType;
@property (nonatomic, readonly) float velocity;
@property (nonatomic, readonly) float typeIntensity;
 
@end

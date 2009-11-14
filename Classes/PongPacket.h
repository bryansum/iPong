/*
 *  PongPacket.h
 *  iPong
 *
 *  Created by Bryan Summersett on 11/14/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

typedef enum {
    kTopSpin,
    kSlice,
    kNormal
} SwingType;

typedef struct PongPacket {
    float           velocity;
    SwingType      swingType;
    float           typeIntensity;
} PongPacket;
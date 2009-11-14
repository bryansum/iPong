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
    kSlice
} kSwingType;

typedef struct PongPacket {
    float           velocity;
    kSwingType      swingType;
} PongPacket;
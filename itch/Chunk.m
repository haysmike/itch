//
//  Chunk.m
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "Chunk.h"

@implementation Chunk

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type: %@, size: %u, crc: 0x%08x }", [self type], [self size], [self crc]];
}

@end

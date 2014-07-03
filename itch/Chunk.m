//
//  Chunk.m
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "zlib.h"
#import "Chunk.h"

@implementation Chunk

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ type: %@, size: %u, crc: 0x%08x }", [self type], [self size], [self crc]];
}

- (void)updateData:(NSData *)newData
{
    if ([newData length] != [self size]) {
        NSLog(@"WRRONNGGG");
        return;
    }

    [self setData:newData];

    // update crc
    NSMutableData *data = [NSMutableData dataWithData:[self typeData]];
    [data appendData:newData];
    uLong crc = crc32(0L, [data bytes], (uInt)[data length]);
    [self setCrc:(UInt32)crc];
    NSLog(@"crc: 0x%08lx", crc);
}

- (NSData *)sizeData
{
    UInt32 swappedSize = CFSwapInt32HostToBig([self size]);
    return [NSData dataWithBytes:&swappedSize length:4];
}

- (NSData *)crcData
{
    UInt32 swappedCrc = CFSwapInt32HostToBig([self crc]);
    return [NSData dataWithBytes:&swappedCrc length:4];
}

- (NSData *)typeData
{
    return [[self type] dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *)allData
{
    NSMutableData *chunkData = [NSMutableData dataWithData:[self sizeData]];
    [chunkData appendData:[self typeData]];
    [chunkData appendData:[self data]];
    [chunkData appendData:[self crcData]];
    return chunkData;
}

@end

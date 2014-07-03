//
//  Chunk.m
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "zlib.h"
#import "Chunk.h"

@implementation Chunk {
    NSMutableData *_data;
}

// used when unpacking a file before creating an instance
+ (UInt32)readChunkLength:(NSData *)data location:(NSUInteger)location
{
    UInt32 size;
    [data getBytes:&size range:NSMakeRange(location, 4)];
    return CFSwapInt32BigToHost(size) + 12;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    _data = [data mutableCopy];
    return self;
}

- (NSData *)data
{
    return _data;
}

- (NSRange)rangeForChunkDataLength
{
    return NSMakeRange(0, 4);
}

- (NSRange)rangeForChunkType
{
    return NSMakeRange(4, 4);
}

- (NSRange)rangeForChunkData
{
    return NSMakeRange(8, [_data length] - 12);
}

- (NSRange)rangeForCrc
{
    return NSMakeRange([_data length] - 4, 4);
}

- (UInt32)chunkDataLength
{
    UInt32 size;
    [_data getBytes:&size range:[self rangeForChunkDataLength]];
    return CFSwapInt32BigToHost(size);
}

- (NSString *)chunkType
{
    NSData *subData = [_data subdataWithRange:[self rangeForChunkType]];
    return [[NSString alloc] initWithData:subData encoding:NSASCIIStringEncoding];
}

- (NSData *)chunkData
{
    return [_data subdataWithRange:[self rangeForChunkData]];
}

- (UInt32)chunkCrc
{
    UInt32 crc;
    [_data getBytes:&crc range:[self rangeForCrc]];
    return CFSwapInt32BigToHost(crc);
}

- (void)updateChunkData:(NSData *)newData
{
    if ([newData length] != [[self chunkData] length]) {
        NSLog(@"incorrect length. itch does not support changing chunk sizes");
        return;
    }

    [_data replaceBytesInRange:[self rangeForChunkData] withBytes:[newData bytes]];

    // update crc
    NSMutableData *data = [NSMutableData dataWithData:[_data subdataWithRange:[self rangeForChunkType]]];
    [data appendData:[self chunkData]];
    uLong crc = crc32(0L, [data bytes], (uInt)[data length]);
    UInt32 swappedCrc = CFSwapInt32HostToBig((UInt32)crc);
    [_data replaceBytesInRange:[self rangeForCrc] withBytes:&swappedCrc];
}

@end

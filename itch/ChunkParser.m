//
//  ChunkParser.m
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "ChunkParser.h"

@implementation ChunkParser {
    NSData *_data;
    BOOL _more;
    NSUInteger _loc;
}

- (id)initWithData:(NSData *)data location:(NSUInteger)loc
{
    self = [super init];
    _data = data;
    _more = YES;
    _loc = loc;
    return self;
}

- (void)parseSize:(Chunk *)chunk
{
    UInt32 size;
    size_t len = sizeof(size);
    [_data getBytes:&size range:NSMakeRange(_loc, len)];
    [chunk setSize:CFSwapInt32BigToHost(size)];
    _loc += len;
}

- (void)parseChunkType:(Chunk *)chunk
{
    int len = 4;
    NSData *subData = [_data subdataWithRange:NSMakeRange(_loc, len)];
    NSString *type = [[NSString alloc] initWithData:subData encoding:NSASCIIStringEncoding];
    [chunk setType:type];
    _loc += len;
}

- (void)parseChunkData:(Chunk *)chunk
{
    int len = [chunk size];
    [chunk setData:[_data subdataWithRange:NSMakeRange(_loc, len)]];
    _loc += len;
}

- (void)parseCrc:(Chunk *)chunk
{
    UInt32 crc;
    int len = sizeof(crc);
    [_data getBytes:&crc range:NSMakeRange(_loc, len)];
    [chunk setCrc:CFSwapInt32BigToHost(crc)];
    _loc += len;
}

- (Chunk *)nextChunk
{
    Chunk *chunk = [[Chunk alloc] init];
    [self parseSize:chunk];
    [self parseChunkType:chunk];
    [self parseChunkData:chunk];
    [self parseCrc:chunk];
    if (_loc >= [_data length]) {
        _more = NO;
    }
    return chunk;
}

- (BOOL)hasMore
{
    return _more;
}

@end

//
//  Chunk.h
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

@interface Chunk : NSObject

+ (UInt32)readChunkLength:(NSData *)data location:(NSUInteger)location;

- (id)initWithData:(NSData *)data;
- (NSData *)data;

- (UInt32)chunkDataLength;
- (NSString *)chunkType;
- (NSData *)chunkData;
- (UInt32)chunkCrc;

- (void)updateChunkData:(NSData *)newData;  // also updates CRC

@end

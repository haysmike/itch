//
//  ChunkParser.h
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "Chunk.h"

@interface ChunkParser : NSObject

- (id)initWithData:(NSData *)data location:(NSUInteger)loc;

- (BOOL)hasMore;
- (Chunk *)nextChunk;

@end

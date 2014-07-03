//
//  Chunk.h
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

@interface Chunk : NSObject

@property UInt32 size;
@property NSString *type;
@property NSData *data;
@property UInt32 crc;

- (void)updateData:(NSData *)newData;
- (NSData *)sizeData;
- (NSData *)crcData;

- (NSData *)allData;

@end

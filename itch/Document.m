//
//  Document.m
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "Document.h"
#import "EditorWindowController.h"
#import "Chunk.h"

const char PNG_SIG[8] = {137, 80, 78, 71, 13, 10, 26, 10};

@implementation Document

- (id)init
{
    self = [super init];
    _chunks = [NSMutableArray array];
    return self;
}

- (void)makeWindowControllers
{
    EditorWindowController *controller = [[EditorWindowController alloc] init];
    [self addWindowController:controller];
}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [self concatenateChunks];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    if (![self isValidSignature:data]) {
        NSLog(@"NOT A PNG");
        //        outError = [NSError errorWithDomain:(NSString *) code:(NSInteger) userInfo:(NSDictionary *)]
        return NO;
    }

    // TODO: dispatch this to a thread? measure performance...
    NSUInteger location = 8;
    while (location < [data length]) {
        UInt32 chunkLength = [Chunk readChunkLength:data location:location];
        Chunk *chunk = [[Chunk alloc] initWithData:[data subdataWithRange:NSMakeRange(location, chunkLength)]];
        [[self chunks] addObject:chunk];
        location += chunkLength;
    }

    return YES;
}

- (BOOL)isValidSignature:(NSData *)data
{
    Byte sig[8];
    [data getBytes:sig length:sizeof(PNG_SIG)];
    return !memcmp(sig, PNG_SIG, sizeof(PNG_SIG));
}

- (NSData *)concatenateChunks
{
    NSMutableData *png = [NSMutableData dataWithBytes:PNG_SIG length:sizeof(PNG_SIG)];
    for (id chunk in [self chunks]) {
        [png appendData:[chunk data]];
    }
    return png;
}

- (NSImage *)image
{
    return [[NSImage alloc] initWithData:[self concatenateChunks]];
}

@end

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

@implementation Document {
    NSMutableData *_pngData;
}

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

- (void)revertDocumentToSaved:(id)sender
{
    [super revertDocumentToSaved:sender];
}

- (BOOL)revertToContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    return [super revertToContentsOfURL:url ofType:typeName error:outError];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return _pngData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    _pngData = [data mutableCopy];
    if (![self isValidSignature:data]) {
        NSLog(@"NOT A PNG");
        //        outError = [NSError errorWithDomain:(NSString *) code:(NSInteger) userInfo:(NSDictionary *)]
        return NO;
    }

    // TODO: dispatch this to a thread? measure performance...
    [_chunks removeAllObjects];
    NSUInteger location = 8;
    while (location < [data length]) {
        UInt32 chunkLength = [Chunk readChunkLength:data location:location];
        NSRange chunkRange = NSMakeRange(location, chunkLength);
        Chunk *chunk = [[Chunk alloc] initWithData:[data subdataWithRange:chunkRange]];
        [chunk setRange:chunkRange];
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

- (NSRange)rangeForChunkWithIndex:(NSUInteger)index
{
    return [[_chunks objectAtIndex:index] range];
}

- (void)updateChunk:(Chunk *)chunk
{
    [_pngData replaceBytesInRange:[chunk range] withBytes:[[chunk data] bytes]];
}

- (NSImage *)image
{
    return [[NSImage alloc] initWithData:_pngData];
}

@end

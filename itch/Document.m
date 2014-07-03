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
#import "ChunkParser.h"

const char PNG_SIG[8] = {137, 80, 78, 71, 13, 10, 26, 10};

@implementation Document {
    NSData *_data;
    NSMutableArray *_chunks;
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

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return NO;
    // TODO:
    //    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    _data = data;
    NSUInteger loc = [self consumeSignature];
    if (loc == 0) {
        NSLog(@"NOT A PNG");
        //        outError = [NSError errorWithDomain:(NSString *) code:(NSInteger) userInfo:(NSDictionary *)]
        return NO;
    }

    // TODO: dispatch this to a thread? measure performance...
    ChunkParser *parser = [[ChunkParser alloc] initWithData:_data location:loc];
    while ([parser hasMore]) {
        Chunk *chunk = [parser nextChunk];
        [_chunks addObject:chunk];
    }

    return YES;
}

// returns location of next range
- (NSUInteger)consumeSignature
{
    char sig[8];
    [_data getBytes:sig length:sizeof(PNG_SIG)];
    if (memcmp(sig, PNG_SIG, sizeof(PNG_SIG))) {
        return 0;
    } else {
        return sizeof(PNG_SIG);
    }
}

- (NSArray *)chunks
{
    return _chunks;
}

- (void)setChunks:(NSArray *)chunks
{
    // update the file yo
}

- (NSImage *)image
{
    return [[NSImage alloc] initWithData:_data];
}

@end

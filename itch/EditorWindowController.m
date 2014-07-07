//
//  EditorWindowController.m
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//


#import "EditorWindowController.h"
#import "Document.h"
#import "Chunk.h"
#import "ItchTextView.h"

@interface EditorWindowController () <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>

@end

@implementation EditorWindowController {
    NSMutableArray *_textViews;
    NSTimer *_timer;
}

- (id)init
{
    self = [super initWithWindowNibName:@"Document"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self tableView] setDataSource:self];
    [[self tableView] setDelegate:self];
}

- (void)setDocumentEdited:(BOOL)dirtyFlag
{
    [super setDocumentEdited:dirtyFlag];

    NSUndoManager *undoManager = [[self document] undoManager];
    BOOL canRedo = undoManager && [undoManager canRedo];

    if (!dirtyFlag && !canRedo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_textViews) {
                for (id obj in _textViews) {
                    if (![obj isEqual:[NSNull null]]) {
                        [obj removeFromSuperview];
                    }
                }
                [_textViews removeAllObjects];
            } else {
                _textViews = [NSMutableArray arrayWithCapacity:[[[self document] chunks] count]];
            }
            for (int i = 0; i < [[[self document] chunks] count]; i++) {
                [_textViews addObject:[NSNull null]];
            }
            [[self tableView] reloadData];
            [[self tableView] selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];

            [self updateImage];
        });
    }
}

- (ItchTextView *)textViewForChunk:(NSUInteger)index
{
    ItchTextView *textView = [_textViews objectAtIndex:index];
    NSRect frame = [[self scrollView] frame];
    frame.origin = NSZeroPoint;
    if ([textView isEqual:[NSNull null]]) {
        textView = [[ItchTextView alloc] initWithFrame:frame];
        [textView setFont:[NSFont fontWithName:@"Menlo" size:13.0f]];
        [textView setEnabledTextCheckingTypes:0];
        [textView setAllowsUndo:YES];
        [textView setIndex:index];
        [textView setDelegate:self];
        [textView setAutoresizingMask:(NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin)];
        [_textViews insertObject:textView atIndex:index];
    }
    NSLog(@"adding textView %@ to scrollView %@", textView, [self scrollView]);
    [[self scrollView] setDocumentView:textView];
    return textView;
}

- (Byte)byteForChar:(char)c
{
    if (c >= '0' && c <= '9') {
        c = c - '0';
    } else if (c >= 'A' && c <= 'F') {
        c = c - 'A' + 0x0a;
    } else if (c >= 'a' && c <= 'f') {
        c = c - 'a' + 0x0a;
    } else {
        NSLog(@"invalid half-byte %c", c);
    }
    return c;
}

- (void)updateImage
{
    NSImage *image = [[self document] image];
    [[self imageView] setImage:image];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSArray *chunks = [[self document] chunks];
    return chunks ? [chunks count] : 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    Chunk *chunk = [[[self document] chunks] objectAtIndex:row];
    NSString *columnName = [tableColumn identifier];
    if ([columnName isEqualToString:@"type"]) {
        return [chunk chunkType];
    } else if ([columnName isEqualToString:@"size"]) {
        return [NSString stringWithFormat:@"%u", [chunk chunkDataLength]];
    } else if ([columnName isEqualToString:@"crc"]) {
        return [NSString stringWithFormat:@"0x%08x", [chunk chunkCrc]];
    }

    return nil;
}

#pragma mark - NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [[self tableView] selectedRow];
    if (row < 0) {
        return;
    }

    Chunk *chunk = [[[self document] chunks] objectAtIndex:row];

    NSMutableString *wowe = [NSMutableString string];

    // for each byte
    const Byte *bytes = (Byte *) [[chunk chunkData] bytes];
    for (int i = 0; i < [chunk chunkDataLength]; i++) {
        Byte chars = bytes[i];
        [wowe appendFormat:@"%02x", chars];
    }
    [[self textViewForChunk:row] setString:wowe];
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9a-f]+$" options:NSRegularExpressionCaseInsensitive error:NULL];
    if ([regex numberOfMatchesInString:replacementString options:0 range:NSMakeRange(0, [replacementString length])]) {
        return YES;
    } else {
        NSLog(@"invalid hex: %@", replacementString);
        return NO;
    }
}

- (void)textDidChange:(NSNotification *)notification
{
    ItchTextView *textView = [notification object];
    const char *str = [[textView string] cStringUsingEncoding:NSASCIIStringEncoding];

    Chunk *chunk = [[[self document] chunks] objectAtIndex:[textView index]];
    Byte c;
    NSMutableData *data = [NSMutableData data];
    for (int i = 0; i + 1 < [chunk chunkDataLength] * 2; i += 2) {
        c = [self byteForChar:str[i]] << 4;
        c += [self byteForChar:str[i+1]];
        [data appendBytes:&c length:1];
    }

    [chunk updateChunkData:data];
    [[self document] updateChunk:chunk];
    [[self tableView] reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[textView index]]
                                columnIndexes:[NSIndexSet indexSetWithIndex:2]];

    [self updateImage];
}

@end

//
//  EditorWindowController.m
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "zlib.h"

#import "EditorWindowController.h"
#import "Document.h"
#import "Chunk.h"
#import "ItchTextView.h"

@interface EditorWindowController () <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>

@end

@implementation EditorWindowController {
    Chunk *_chunk;
}

- (id)init
{
    self = [super initWithWindowNibName:@"Document"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self imageView] setImage:[[super document] image]];

    [[self tableView] setDataSource:self];
    [[self tableView] setDelegate:self];

    [[self textView] setFont:[NSFont fontWithName:@"Menlo" size:13.0f]];
    [[self textView] setContinuousSpellCheckingEnabled:NO];
    [[self textView] setDelegate:self];
}

- (void)dealloc
{
    [self setTextView:nil];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[super document] chunks] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    Chunk *chunk = [[[super document] chunks] objectAtIndex:row];
    NSString *columnName = [tableColumn identifier];
    if ([columnName isEqualToString:@"type"]) {
        return [chunk type];
    } else if ([columnName isEqualToString:@"size"]) {
        return [NSString stringWithFormat:@"%u", [chunk size]];
    } else if ([columnName isEqualToString:@"crc"]) {
        return [NSString stringWithFormat:@"0x%08x", [chunk crc]];
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

    _chunk = [[[super document] chunks] objectAtIndex:row];

    NSMutableString *wowe = [NSMutableString string];

    // for each byte
    const Byte *bytes = (Byte *) [[_chunk data] bytes];
    for (int i = 0; i < [_chunk size]; i++) {
        Byte chars = bytes[i];
        [wowe appendFormat:@"%02x", chars];
    }
    [[self textView] setString:wowe];
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

- (Byte)byteForChar:(char)c
{
    if (c >= '0' && c <= '9') {
        c = c - '0';
    } else if (c >= 'A' && c <= 'F') {
        c = c - 'A' + 0x0a;
    } else if (c >= 'a' && c <= 'f') {
        c = c - 'a' + 0x0a;
    } else {
        NSLog(@"WTF");
    }
    return c;
}

- (void)textDidChange:(NSNotification *)notification
{
    NSMutableData *data = [NSMutableData dataWithData:[[_chunk type] dataUsingEncoding:NSASCIIStringEncoding]];
    const char *str = [[[self textView] string] cStringUsingEncoding:NSASCIIStringEncoding];

    Byte c;
    for (int i = 0; i + 1 < MIN(strlen(str), [_chunk size] * 2); i += 2) {
        c = [self byteForChar:str[i]] << 4;
        c += [self byteForChar:str[i+1]];
        [data appendBytes:&c length:1];
    }

    uLong crc = crc32(0L, [data bytes], (uInt)[data length]);
    NSLog(@"crc: 0x%08lx", crc);
}

@end

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

@interface EditorWindowController () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation EditorWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"Document"];
    if (self) {

    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self imageView] setImage:[[super document] image]];
    [[self tableView] setDataSource:self];
    [[self tableView] setDelegate:self];
}

//- (void)setDocumentEdited:(BOOL)dirtyFlag
//{
////    [super setDocumentEdited:dirtyFlag];
//    NSLog(@"document edited... %@", [[super document] fileURL]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[self imageView] setImage:[[super document] image]];
//    });
//}

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
    Chunk *chunk = [[[super document] chunks] objectAtIndex:row];
    NSString *wowe = [[NSString alloc] initWithData:[chunk data] encoding:NSASCIIStringEncoding];
    [[self textView] setString:wowe];
}

@end

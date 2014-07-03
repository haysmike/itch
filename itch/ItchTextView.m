//
//  ItchTextView.m
//  itch
//
//  Created by Mike Hays on 7/1/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import "ItchTextView.h"

@implementation ItchTextView

- (void)paste:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    if ([[pb types] containsObject:NSPasteboardTypeString]) {
        [self insertText:[pb stringForType:NSPasteboardTypeString]];
    }
}

- (void)insertText:(id)string
{
    NSRange range = [self selectedRange];
    if (range.location == [[self string] length]) return;
    range.length = [string length];
    NSInteger over = range.location + range.length - [[self string] length];
    if (over > 0) {
        range.length -= over;
    }
    string = [string substringToIndex:range.length];
    [super insertText:[string lowercaseString] replacementRange:range];
}

@end

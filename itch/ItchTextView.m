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

- (void)insertText:(id)aString
{
    // calling super here causes insertText:replacementRange: to be called with
    // reasonable values (MH)
    [super insertText:aString];
}

- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange
{
    if (replacementRange.location == [[self string] length]) return;
    replacementRange.length = [aString length];
    NSInteger over = replacementRange.location + replacementRange.length - [[self string] length];
    if (over > 0) {
        replacementRange.length -= over;
    }
    aString = [aString substringToIndex:replacementRange.length];
    [super insertText:aString replacementRange:replacementRange];
}

@end

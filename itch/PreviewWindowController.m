//
//  PreviewWindowController.m
//  itch
//
//  Created by Mike Hays on 7/7/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "PreviewWindowController.h"

@implementation PreviewWindowController {
    NSImage *_image;
}

- (id)initWithImage:(NSImage *)image
{
    self = [super initWithWindowNibName:@"PreviewWindow"];
    _image = image;
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [[self window] setTitle:@"preview"];

    NSRect imageFrame = NSZeroRect;
    imageFrame.size = [_image size];
    CGImageRef imageRef = [_image CGImageForProposedRect:&imageFrame
                                                 context:[NSGraphicsContext currentContext]
                                                   hints:nil];
    [[self imageView] setImage:imageRef imageProperties:nil];
}

@end

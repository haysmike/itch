//
//  PreviewWindowController.h
//  itch
//
//  Created by Mike Hays on 7/7/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

@class IKImageView;

@interface PreviewWindowController : NSWindowController

- (id)initWithImage:(NSImage *)image;

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet IKImageView *imageView;

@end

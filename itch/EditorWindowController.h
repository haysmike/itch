//
//  EditorWindowController.h
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

@class ItchTextView;

@interface EditorWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSClipView *customView;

@end

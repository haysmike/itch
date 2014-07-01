//
//  EditorWindowController.h
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

@interface EditorWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *imageView;
@property (assign) IBOutlet NSTextView *textView;

@end

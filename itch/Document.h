//
//  Document.h
//  itch
//
//  Created by Mike Hays on 6/30/14.
//  Copyright (c) 2014 murkey. All rights reserved.
//

extern const char PNG_SIG[8];

@interface Document : NSDocument

@property (strong, readonly) NSMutableArray *chunks;

- (NSImage *)image;

@end

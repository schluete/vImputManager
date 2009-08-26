//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>

@class Commands;

@interface KeyHandler: NSObject {
  NSTextView *_textView;
  Commands *_commands;
}

// constructor, called to initialize the view we're working on
- (id)initWithTextView:(NSTextView *)aTextView;

// called by the modified text view to process an event
- (BOOL)handleKeyDownEvent:(NSEvent *)event;

@end

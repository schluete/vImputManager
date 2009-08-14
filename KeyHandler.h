//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>


// the possible vi modes the input is in
typedef enum {
  Insert=0,
  Command=1,
} ViMode;


@interface KeyHandler: NSObject {
  NSTextView *textView;
  ViMode currentMode;
}

// constructor, called to initialize the view we're working on
- (id)initWithTextView:(NSTextView *)textView;

// called by the modified text view to process an event
- (BOOL)handleKeyDownEvent:(NSEvent *)event;

// change vi mode to command mode
- (void)handleEscape;

// process command mode key input
- (void)handleCommand:(unichar)charCode modifiers:(NSUInteger)modifiers;

// handle cursor movement commands
- (BOOL)handleMovement:(unichar)charCode modifiers:(NSUInteger)modifiers;

// handle insert mode commands
- (BOOL)handleInsert:(unichar)charCode modifiers:(NSUInteger)modifiers;

@end

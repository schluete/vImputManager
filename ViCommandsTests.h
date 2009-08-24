//  Created by Axel on 24.08.09.
//  Copyright 2009 pqrs.de. All rights reserved.

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>

@class Commands;

@interface ViCommandsTests: SenTestCase {
  NSTextView *textView;
  Commands *cmds;
}

// move the cursor to a specific position in the text
- (void)moveCursorTo:(NSUInteger)pos;

// move the cursor to the beginning of the text
- (void)moveCursorToStart;

// move the cursor to the end of the text
- (void)moveCursorToEnd;

// replace the content of the text view
- (void)replaceText:(NSString *)text;

// return the current cursor position
- (NSUInteger)cursorPosition;

@end

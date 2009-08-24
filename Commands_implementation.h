//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

@interface Commands (utilities) 

// return the current cursor position
- (NSUInteger)cursorPosition;

// move the cursor to the given position.
- (void)moveCursor:(NSUInteger)pos;

// find the next or previous occurencs of a line break.
- (NSUInteger)findEndOfLineAt:(NSUInteger)pos direction:(SearchDirection)dir;

@end

@interface Commands (implementation)

// move cursor left 
- (void)cursorLeft;

// move cursor right
- (void)cursorRight;

// move cursor up 
- (void)cursorUp;

// move cursor down
- (void)cursorDown;

// move to the beginning of the current line
- (void)beginningOfLine;

// move to the first non-whitespace character of the current line
- (void)beginningOfLineNonWhitespace;

// moves to the end of the current line
- (void)endOfLine;

// go to a specific line or to the end of the file
- (void)goToLine;

@end

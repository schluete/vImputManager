//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"

@interface Commands (utilities) 

// true if the given text is a multiline text, false otherwise
- (BOOL)hasMultipleLines:(NSString *)text inRange:(NSRange)range;

// store the given text into a register
- (void)storeText:(NSString *)text intoRegister:(unichar)namedRegister;

// return the current cursor position
- (NSUInteger)cursorPosition;

// move the cursor to the given position.
- (void)moveCursorTo:(NSUInteger)pos;

// find the first character in the current line
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos;

// find the last character in the current line
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos;

// return the real end of line position
- (NSUInteger)findRealEndOfLine:(NSUInteger)currentPos;

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

// move a word forward in the current line
- (void)wordForward;

// move a word forward in the current line
- (void)WORDForward;

// Used internally, advances to the beginning of the next word
- (void)wordForwardWithWordCharacters:(NSCharacterSet *)wordChars;

// move a word bacward in the current line
- (void)wordBackward;

// move a word bacward in the current line
- (void)WORDBackward;

// Used internally, advances to the beginning of the next word
- (void)wordBackwardWithWordCharacters:(NSCharacterSet *)wordChars;

// go to insert mode at current cursor position.
- (void)insertMode;

// Appends arbitrary text after the current cursor position
- (void)insertModeAfterCursor;

// Inserts at the beginning of a line; a synonym for ^i. 
- (void)insertModeAtBeginningOfLine;

// Appends at the end of line, a synonym for $a (7.2). 
- (void)insertModeAtEndOfLine;

// Changes the rest of the text on the current line; a synonym for c$. 
- (void)changeToEndOfLine;

// Deletes the rest of the text on the current line; a synonym for d$. 
- (void)deleteEndOfLine;

// Finds the first instance of the next character following the cursor on the current line
- (void)findCharacter;

// Advances the cursor up to the character before the next character typed
- (void)findAndStopBeforeCharacter;

@end

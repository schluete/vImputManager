//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"

@interface Commands (utilities) 

// true if the given text is a multiline text, false otherwise
- (BOOL)hasMultipleLines:(NSString *)text inRange:(NSRange)range;

// store the given text into a register
- (void)storeText:(NSString *)text intoRegister:(unichar)namedRegister;

// return the text from the current register
- (NSString *)textForCurrentRegister;

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

// places the cursor on the character in the column specified by the count (7.1, 7.2). 
- (void)cursorToColumn;

// move to the beginning of the current line
- (void)beginningOfLine;

// move to the first non-whitespace character of the current line
- (void)beginningOfLineNonWhitespace;

// moves to the end of the current line
- (void)endOfLine;

// go to a specific line or to the end of the file
- (void)goToLine;

// go to a specific line or to the end of the file with the "gg" command
- (void)goToLineVim;

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

// Changes the single character under the cursor 
- (void)changeSingleCharacter;

// Deletes the rest of the text on the current line; a synonym for d$. 
- (void)deleteEndOfLine;

// Finds the first instance of the next character following the cursor on the current line
- (void)findCharacter;

// Finds a single character, backwards in the current line. A count repeats this search that many times (4.1). 
- (void)findCharacterBackward;

// Advances the cursor up to the character before the next character typed
- (void)findAndStopBeforeCharacter;

// Deletes the single character under the cursor
- (void)deleteCharacter;

// Replaces the single character at the cursor
- (void)replaceCharacter;

// determine the range to modify for single character operations
- (NSRange)rangeForSingleCharacterOperations;

// opens new lines below the current line; otherwise like <O> (3.1). 
- (void)openNewLine;

// opens a newline above the current line
- (void)openNewLineAbove;

// joins together lines
- (void)joinLines;

// paste the content of a buffer before/ above the current cursor position
- (void)pasteBefore;

// paste the content of a buffer after/ below the current cursor position
- (void)pasteAfter;

@end

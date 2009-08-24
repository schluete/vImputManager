//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"
#import "Commands_implementation.h"
#import "Logger.h"

@implementation Commands (utilities)

/**
 * return the current cursor position
 */
- (NSUInteger)cursorPosition {
  NSRange range=[textView selectedRange];
  return range.location;
}

/**
 * move the cursor to the given position.
 */
- (void)moveCursor:(NSUInteger)pos {
  [textView setSelectedRange:NSMakeRange(pos,0)];
}

/**
 * return the position of the first character in the current line
 * or 0 if we're at the beginning of the text
 */
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos {
  NSString *text=[[textView textStorage] string];
  NSCharacterSet *newlines=[NSCharacterSet newlineCharacterSet];
  NSInteger pos=currentPos;
  if([newlines characterIsMember:[text characterAtIndex:pos]])
    pos--;
  for(;pos>=0;pos--)
    if([newlines characterIsMember:[text characterAtIndex:pos]])
      return pos+1;
  return 0;
}

/**
 * return the position of the last character in the current line
 * or the text length if we're at the end of the text
 */
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos {
  NSString *text=[[textView textStorage] string];
  NSCharacterSet *newlines=[NSCharacterSet newlineCharacterSet];
  for(NSInteger pos=currentPos;pos<[text length];pos++)
    if([newlines characterIsMember:[text characterAtIndex:pos]])
      return pos;
  return [text length];
}

@end

@implementation Commands (implementation)

/**
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorLeft {
  NSInteger pos=[self cursorPosition],
            startOfLine=[self findStartOfLine:pos];
  pos-=(currentCount>0 ? currentCount:1);
  if(pos<startOfLine)
    pos=startOfLine;
  [self moveCursor:pos];
}

/**
 * Moves the cursor one character to the right. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorRight {
  NSInteger pos=[self cursorPosition],
            endOfLine=[self findEndOfLine:pos];
  pos+=(currentCount>0 ? currentCount:1);
  if(pos>endOfLine)
    pos=endOfLine;
  [self moveCursor:pos];
}

/**
 * Moves the cursor one line up.
 */
- (void)cursorUp {
  [Logger log:@"move cursor up %d chars",currentCount];
}

/**
 * Moves the cursor one line down in the same column. If the position does not exist, vi 
 * comes as close as possible to the same column. A count repeats the effect.
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorDown {
  [Logger log:@"move cursor down %d chars",currentCount];
}

// move to the beginning of the current line
- (void)beginningOfLine {
  NSUInteger pos=[self findStartOfLine:[self cursorPosition]];
  [self moveCursor:pos];
}

// move to the first non-whitespace character of the current line
- (void)beginningOfLineNonWhitespace {
  NSUInteger pos=[self cursorPosition],
             endOfLine=[self findEndOfLine:pos],
             startOfLine=[self findStartOfLine:pos];

  NSString *text=[[textView textStorage] string];
  NSRange where=[text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                      options:0
                                        range:NSMakeRange(startOfLine,endOfLine-startOfLine+1)];
  if(where.location==NSNotFound)
    [self moveCursor:startOfLine];
  else
    [self moveCursor:where.location];
}

// moves to the end of the current line
- (void)endOfLine {
  NSUInteger pos=[self findEndOfLine:[self cursorPosition]];
  [self moveCursor:pos];
}

/**
 * Goes to the line number given as preceding argument, or the end of the file if no 
 * preceding count is given. The screen is redrawn with the new current line in the 
 * center if necessary (7.2). 
 */
- (void)goToLine {
  [Logger log:@"go to line %d",currentCount];
}

@end


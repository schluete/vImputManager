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
- (void)moveCursorTo:(NSUInteger)pos {
  [textView setSelectedRange:NSMakeRange(pos,0)];
}

/**
 * return the position of the first character in the current line
 * or 0 if we're at the beginning of the text
 */
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos {
  NSString *text=[[textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(currentPos,0)];
  return lineRange.location;
}

/**
 * return the position of the last character in the current line
 * or the text length if we're at the end of the text
 */
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos {
  // determine the last position of the line
  NSString *text=[[textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(currentPos,0)];
  NSInteger pos=lineRange.location+lineRange.length;

  // if the current line has at least one char we've to 
  // determine the "visible" end-of-line, because we don't
  // want the cursor to be on the non-visible newline
  // characters
  if(lineRange.length>0) {
    unichar charAtPos=[text characterAtIndex:pos-1];
    BOOL isNewline=[[NSCharacterSet newlineCharacterSet] characterIsMember:charAtPos];
    if(isNewline)
      pos--;
  }

  // return the visible end-of-line position
  return pos;
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
  [self moveCursorTo:pos];
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
  [self moveCursorTo:pos];
}

/**
 * Moves the cursor one line up.
 */
- (void)cursorUp {
  int lines=(currentCount>0 ? currentCount:1);
  for(int i=0;i<lines;i++)
    [textView moveUp:self];
}

/**
 * Moves the cursor one line down in the same column. If the position does not exist, vi 
 * comes as close as possible to the same column. A count repeats the effect.
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorDown {
  int lines=(currentCount>0 ? currentCount:1);
  for(int i=0;i<lines;i++)
    [textView moveDown:self];
}

// move to the beginning of the current line
- (void)beginningOfLine {
  NSUInteger pos=[self findStartOfLine:[self cursorPosition]];
  [self moveCursorTo:pos];
}

// move to the first non-whitespace character of the current line
- (void)beginningOfLineNonWhitespace {
  NSUInteger pos=[self cursorPosition];
  NSString *text=[[textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(pos,0)],
          where=[text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                      options:0
                                        range:lineRange];
  if(where.location==NSNotFound)
    [self moveCursorTo:lineRange.location];
  else
    [self moveCursorTo:where.location];
}

// moves to the end of the current line
- (void)endOfLine {
  NSUInteger pos=[self findEndOfLine:[self cursorPosition]];
  [self moveCursorTo:pos];
}

/**
 * Goes to the line number given as preceding argument, or the end of the file if no 
 * preceding count is given. The screen is redrawn with the new current line in the 
 * center if necessary (7.2). 
 */
- (void)goToLine {
  if(currentCount==0)
    [textView moveToEndOfDocument:self];
  else {
    NSInteger pos=0;
    NSString *text=[[textView textStorage] string];
    for(int line=0;line<currentCount-1;line++) {
      NSRange lineRange=[text lineRangeForRange:NSMakeRange(pos,0)];
      pos=lineRange.location+lineRange.length;
    }
    [self moveCursorTo:pos];
  }
  [self beginningOfLineNonWhitespace];
}

/**
 * Advances to the beginning of the next word. A word is a sequence of alphanumerics, 
 * or a sequence of special characters. A count repeats the effect (2.4). 
 *
first line
def 123a_bc!cdef abc
second line
 */
- (void)wordForward {
  NSMutableCharacterSet *wordChars=[[[NSMutableCharacterSet alloc] init] autorelease];
  [wordChars formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
  [wordChars addCharactersInString:@"_"];
  [self wordForwardWithWordCharacters:wordChars];
}

/**
 * Advances to the beginning of the next word. Words are composed of non-blank 
 * sequences. A count repeats the effect (2.4). 
 */
- (void)WORDForward {
  NSCharacterSet *wordChars=
    [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
  [self wordForwardWithWordCharacters:wordChars];
}

/**
 * Used internally, advances to the beginning of the next word. Words are composed 
 * of the characters given in the wordChars set. A count repeats the effect
 */
- (void)wordForwardWithWordCharacters:(NSCharacterSet *)wordChars {
  NSCharacterSet *whitespaceChars=[NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *text=[[textView textStorage] string];
  NSInteger pos=[self cursorPosition];
  int count=(currentCount>0 ? currentCount:1);
  for(int i=0;i<count;i++) {
    // let's find the end of the current word. If the current char is a word char then we're
    // searching only for word chars, otherwise we take the current char as a special char and
    // are looking only for special chars
    unichar currChar=[text characterAtIndex:pos];
    if([wordChars characterIsMember:currChar])
      while(pos<[text length] &&
            [wordChars characterIsMember:[text characterAtIndex:pos]])
        pos++;
    else
      while(pos<[text length] &&
            ![wordChars characterIsMember:[text characterAtIndex:pos]] &&
            ![whitespaceChars characterIsMember:[text characterAtIndex:pos]])
        pos++;

    // then move over the whitespaces after the current word
    while(pos<[text length] &&
          [whitespaceChars characterIsMember:[text characterAtIndex:pos]])
      pos++;
  }

  // if we're at the beginning or the end of the text modify position
  if(pos==[text length])
    pos=[text length]-1;
  if(pos<0)
    pos=0;
  [self moveCursorTo:pos];
}

/**
 * Backs up to the beginning of a word in the current line. A word is a sequence of 
 * alphanumerics, or a sequence of special characters. A count repeats the effect (2.4). 
 */
- (void)wordBackward {
  NSMutableCharacterSet *wordChars=[[[NSMutableCharacterSet alloc] init] autorelease];
  [wordChars formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
  [wordChars addCharactersInString:@"_"];
  [self wordBackwardWithWordCharacters:wordChars];
}

/**
 * Backs up to the beginning of a word in the current line. Words are composed of 
 * non-blank sequences. A count repeats the effect (2.4). 
 */
- (void)WORDBackward {
  NSCharacterSet *wordChars=
    [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
  [self wordBackwardWithWordCharacters:wordChars];
}

/**
 * Used internally, backs up to the beginning of the previous word. Words are composed 
 * of the characters given in the wordChars set. A count repeats the effect
 */
- (void)wordBackwardWithWordCharacters:(NSCharacterSet *)wordChars {
  NSCharacterSet *whitespaceChars=[NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *text=[[textView textStorage] string];
  NSInteger pos=[self cursorPosition]-1;
  int count=(currentCount>0 ? currentCount:1);
  for(int i=0;i<count;i++) {
    // move over the whitespaces before the current word
    while(pos>=0 && [whitespaceChars characterIsMember:[text characterAtIndex:pos]])
      pos--;
    if(pos<0)
      break;

    // then let's find the beginning of the current word. If the current char is a word char 
    // then we're searching only for word chars, otherwise we take the current char as a 
    // special char and are looking only for those.
    unichar currChar=[text characterAtIndex:pos];
    if([wordChars characterIsMember:currChar])
      while(pos>=0 && [wordChars characterIsMember:[text characterAtIndex:pos]])
        pos--;
    else
      while(pos>=0 &&
            ![wordChars characterIsMember:[text characterAtIndex:pos]] &&
            ![whitespaceChars characterIsMember:[text characterAtIndex:pos]])
        pos--;
  }

  // move the cursor to the position
  if(pos<(NSInteger)[text length]-1)
    pos++;
  [self moveCursorTo:pos];
}

@end


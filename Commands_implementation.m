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
 * sucht das naechste (bzw. das vorhergende) Zeilenende ab der gegebenen 
 * Position. Es wird dabei in die uebergebene Richtung gesucht.
 */
- (NSUInteger)findEndOfLineAt:(NSUInteger)pos direction:(SearchDirection)dir {
  NSString *text=[[textView textStorage] string];
  NSCharacterSet *newlines=[NSCharacterSet newlineCharacterSet];
  for(;;) {
    if([newlines characterIsMember:[text characterAtIndex:pos]])
      return pos;
    if(dir==Forward) {
      if(++pos>=[text length])
        return [text length];
    }
    else {
      if(--pos<=0)
        return 0;
    }
  }
}

@end

@implementation Commands (implementation)

/**
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorLeft {
  NSUInteger pos=[self cursorPosition],
             prevEolPos=[self findEndOfLineAt:pos direction:Backward];
//[Logger log:@"pos is <%d>, prevEolPos is <%d>",pos,prevEolPos];
  pos-=(currentCount>0 ? currentCount:1);
//[Logger log:@"current count is <%d>, new pos is <%d>",currentCount,pos];
  if(pos<prevEolPos)
    pos=prevEolPos;
//[Logger log:@"final pos is <%d>",pos];
  [self moveCursor:pos];
}

/**
 * Moves the cursor one character to the right. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorRight {
  NSUInteger pos=[self cursorPosition],
             nextEolPos=[self findEndOfLineAt:pos direction:Forward];
  pos+=(currentCount>0 ? currentCount:1);
  if(pos>nextEolPos)
    pos=nextEolPos;
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
  NSUInteger pos=[self findEndOfLineAt:[self cursorPosition] 
                             direction:Backward];
  [self moveCursor:pos];
}

// move to the first non-whitespace character of the current line
- (void)beginningOfLineNonWhitespace {
  NSUInteger pos=[self cursorPosition],
             nextEolPos=[self findEndOfLineAt:pos direction:Forward],
             startOfLine=[self findEndOfLineAt:pos direction:Backward];

  NSString *text=[[textView textStorage] string];
  NSRange where=[text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                      options:0
                                        range:NSMakeRange(startOfLine,nextEolPos-startOfLine)];
  if(where.location==NSNotFound)
    [self moveCursor:startOfLine];
  else
    [self moveCursor:where.location];
}

// moves to the end of the current line
- (void)endOfLine {
  NSUInteger pos=[self findEndOfLineAt:[self cursorPosition] 
                             direction:Forward];
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


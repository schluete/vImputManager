//  Created by Axel on 24.08.09.
//  Copyright 2009 pqrs.de. All rights reserved.

#import "ViCommandsTests.h"
#import "Commands.h"
#import "Logger.h"

/**
 * STAssertNotNil(a1, description, ...)
 * STAssertTrue(expression, description, ...)
 * STAssertFalse(expression, description, ...)
 * STAssertEqualObjects(a1, a2, description, ...)
 * STAssertEquals(a1, a2, description, ...)
 * STAssertThrows(expression, description, ...)
 * STAssertNoThrow(expression, description, ...)
 * STFail(description, ...)
 */

// originally declared privately in Commands_implementation
@interface Commands (utilities) 
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos;
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos;
@end


@implementation ViCommandsTests

/**
 * create and initialize data structures. This method is 
 * called once before each test.
 */
- (void)setUp {
  textView=[[NSTextView alloc] init];
  [self replaceText:@"the quick brown fox jumps over the lazy doc"];
  [self moveCursorToStart];
  cmds=[[Commands alloc] initWithTextView:textView];
}
 
/**
 * release data structures. This method is called once 
 * after each test.
 */
- (void)tearDown {
  [textView release];
  [cmds release];
}

/**
 * move the cursor to the end of the line
 */
- (void)testMoveToEndOfLine {
  [self replaceText:@"first line\nsecond line\n   third line\nfourth line"];

  // wir sind irgendwo in der Mitte irgendeiner Zeile
  [self moveCursorTo:27];
  [cmds processInput:'$'];
  STAssertEquals([self cursorPosition],(NSUInteger)36,@"invalid movement");

  // wir sind irgendwo in der Mitte der letzten Zeile
  [self moveCursorTo:39];
  [cmds processInput:'$'];
  STAssertEquals([self cursorPosition],(NSUInteger)48,@"invalid movement");
}


/**
 * move the cursor to the start of the line
 */
- (void)testMoveToBeginningOfLine {
  [self replaceText:@"first line\nsecond line\n   third line\nfourth line"];

  // wir sind irgendwo in der Mitte der ersten Zeile
  [self moveCursorTo:5];
  [cmds processInput:'0'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");

  // wir sind irgendwo in der Mitte irgendeiner Zeile
  [self moveCursorTo:16];
  [cmds processInput:'0'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid movement");

  // wir sind irgendwo in der Mitte irgendeiner Zeile und 
  // springen zum ersten non-whitespace-zeichen
  [self moveCursorTo:29];
  [cmds processInput:'^'];
  STAssertEquals([self cursorPosition],(NSUInteger)26,@"invalid movement");
}

/**
 * move the cursor to the right 
 */
- (void)testMoveCursorRight {
  [self replaceText:@"first line\nsecond line\nthird line"];

  // wenn wir am Ende des Textes sind darf nichts passieren
  [self moveCursorTo:33];
  [cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)33,@"invalid movement");

  // am Ende einer bel. Zeile ebenfalls nichts
  [self moveCursorTo:22];
  [cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)22,@"invalid movement");

  // irgendwo im Text geht's dann nach links
  [self moveCursorTo:4];
  [cmds processInput:'l'];
  [cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid movement");

  // und jetzt nochmal mit einem Count irgendwo im Text
  [self moveCursorTo:4];
  [cmds processInput:'3'];
  [cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)7,@"invalid movement");

  // und mit Count ueber das Ende hinaus
  [self moveCursorTo:7];
  [cmds processInput:'6'];
  [cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)10,@"invalid movement");
}

/**
 * move the cursor to the left 
 */
- (void)testMoveCursorLeft {
  [self replaceText:@"first line\nsecond line\nthird line"];

  // wenn wir am Anfang des Textes sind darf nichts passieren
  [self moveCursorTo:0];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");

  // am Anfang einer bel. Zeile ebenfalls nichts
  [self moveCursorTo:11];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid movement");

  // irgendwo im Text geht's dann nach links
  [self moveCursorTo:4];
  [cmds processInput:'h'];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)2,@"invalid movement");

  // und jetzt nochmal mit einem Count irgendwo im Text
  [self moveCursorTo:5];
  [cmds processInput:'3'];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)2,@"invalid movement");

  // und mit Count ueber den Anfang hinaus
  [self moveCursorTo:3];
  [cmds processInput:'6'];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");
}

/**
 * find the next line break from a given position on
 */
- (void)testFindEndOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger endOfLine=[cmds findEndOfLine:0];
  STAssertEquals(endOfLine,(NSUInteger)10,@"expected the first EOL at 10, found %d!",endOfLine);
  endOfLine=[cmds findEndOfLine:13];
  STAssertEquals(endOfLine,(NSUInteger)22,@"expected the first EOL at 22, found %d!",endOfLine);
  endOfLine=[cmds findEndOfLine:24];
  STAssertEquals(endOfLine,(NSUInteger)33,@"expected the first EOL at 33, found %d!",endOfLine);
}

/**
 * find the beginning of the current line
 */
- (void)testFindStartOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger startOfLine=[cmds findStartOfLine:25];
  STAssertEquals(startOfLine,(NSUInteger)23,@"expected the first SOL at 22, found %d!",startOfLine);
  startOfLine=[cmds findStartOfLine:15];
  STAssertEquals(startOfLine,(NSUInteger)11,@"expected the first SOL at 10, found %d!",startOfLine);
  startOfLine=[cmds findStartOfLine:5];
  STAssertEquals(startOfLine,(NSUInteger)0,@"expected the first SOL at 0, found %d!",startOfLine);
}

/**
 * move the cursor to the beginning of the text
 */
- (void)moveCursorToStart {
  [self moveCursorTo:0];
}

/**
 * move the cursor to a position in the text
 */
- (void)moveCursorTo:(NSUInteger)pos {
  NSRange start={pos,0};
  [textView setSelectedRange:start];
}

/**
 * move the cursor to the end of the text
 */
- (void)moveCursorToEnd {
  NSRange end={[[textView string] length],0};
  [textView setSelectedRange:end];
  //[textView scrollRangeToVisible:end];
}

/**
 * replace the content of the text view
 */
- (void)replaceText:(NSString *)text {
  NSAttributedString *attributedText=[[NSAttributedString alloc] initWithString:text];
  [[textView textStorage] setAttributedString:attributedText];
  [attributedText release];
  [self moveCursorToStart];
}

/**
 * return the current cursor position
 */
- (NSUInteger)cursorPosition {
  NSRange range=[textView selectedRange];
  return range.location;
}

@end

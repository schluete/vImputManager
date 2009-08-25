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
 * word movements backward
 */
- (void)testWordBackward {
  [self replaceText:@"first line\ndef 123abc!cdef abc\nsecond line"];

  // what happens at the beginning of the text?
  [self moveCursorTo:0];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");

  // simple word backward, same for both <W> and <w>
  [self moveCursorTo:8];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:8];
  [cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

  // simple word backward when the cursor is at the first char of the current word
  [self moveCursorTo:7];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:6];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");

  // WORD backward over special chars
  [self moveCursorTo:24];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)22,@"invalid word movement");
  [self moveCursorTo:24];
  [cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // simple word backward over line endings, same for both <W> and <w>
  [self moveCursorTo:11];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:11];
  [cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

  // finally let's add a count 
  [self moveCursorTo:17];
  [cmds processInput:'3'];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:17];
  [cmds processInput:'3'];
  [cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

#if 0
require '#'yaml'
require 'set'

module ActiveRecord #:nodoc:
#endif

  // word backward with special chars
  [self replaceText:@"require '#'yaml'\nrequire 'set'\n\nmodule ActiveRecord #:nodoc:\n"];

  [self moveCursorTo:17];
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)8,@"invalid word movement");
  [cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");
}

/**
 * word movements forward
 */
- (void)testWordForward {
  [self replaceText:@"first line\ndef 123abc!cdef abc\nsecond line"];

  // simple word forward, same for both <W> and <w>
  [self moveCursorTo:11];
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [self moveCursorTo:11];
  [cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // WORD forward over special chars
  [self moveCursorTo:15];
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)21,@"invalid word movement");
  [self moveCursorTo:15];
  [cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)27,@"invalid word movement");

  // simple word forward over line endings, same for both <W> and <w>
  [self moveCursorTo:6];
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [self moveCursorTo:6];
  [cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");

  // finally let's add a count 
  [self moveCursorTo:1];
  [cmds processInput:'3'];
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [self moveCursorTo:1];
  [cmds processInput:'3'];
  [cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // word forward with special chars
  [self replaceText:@"require '#'yaml'\nrequire 'set'\n\nmodule ActiveRecord #:nodoc:\n"];

  [self moveCursorTo:0];
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)8,@"invalid word movement");
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)17,@"invalid word movement");
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
 * was passiert, wenn wir in einem one-liner ganz am Ende sind?
 */
- (void)testMoveCursorLeftOnOneLiner {
  [self replaceText:@"foobar carcdr"];
  [self moveCursorTo:13];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)12,@"invalid movement");
}

/**
 * find the next line break from a given position on
 */
- (void)testFindEndOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger endOfLine=[cmds findEndOfLine:0];
  STAssertEquals(endOfLine,(NSUInteger)10,@"invalid eol!");
  endOfLine=[cmds findEndOfLine:13];
  STAssertEquals(endOfLine,(NSUInteger)22,@"invalid eol!");
  endOfLine=[cmds findEndOfLine:24];
  STAssertEquals(endOfLine,(NSUInteger)33,@"invalid eol!");
}

/**
 * find the beginning of the current line
 */
- (void)testFindStartOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger startOfLine=[cmds findStartOfLine:25];
  STAssertEquals(startOfLine,(NSUInteger)23,@"invalid sol!");
  startOfLine=[cmds findStartOfLine:15];
  STAssertEquals(startOfLine,(NSUInteger)11,@"invalid sol!");
  startOfLine=[cmds findStartOfLine:5];
  STAssertEquals(startOfLine,(NSUInteger)0,@"invalid sol!");
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

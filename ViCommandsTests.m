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
 * move the cursor to the left 
 */
- (void)testMoveCursorLeft {
  [self replaceText:@"first line\nsecond line\nthird line"];

#if 0
  // wenn wir am Anfang des Textes sind darf nichts passieren
  [self moveCursorTo:0];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");

  // am Anfang einer bel. Zeile ebenfalls nichts
  [self moveCursorTo:11];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid movement");
#endif

  // irgendwo im Text geht's dann nach links
  [self moveCursorTo:4];
  [cmds processInput:'h'];
  [cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)2,@"invalid movement");

#if 0
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
#endif
}


/**
 * find the next line break from a given position on
 */
- (void)testFindEndOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger posOfEol=[cmds findEndOfLineAt:0 direction:Forward];
  STAssertEquals(posOfEol,(NSUInteger)10,@"expected the first EOL at 10, found %d!",posOfEol);
  posOfEol=[cmds findEndOfLineAt:11 direction:Forward];
  STAssertEquals(posOfEol,(NSUInteger)22,@"expected the first EOL at 22, found %d!",posOfEol);
  posOfEol=[cmds findEndOfLineAt:24 direction:Forward];
  STAssertEquals(posOfEol,(NSUInteger)33,@"expected the first EOL at 33, found %d!",posOfEol);

  posOfEol=[cmds findEndOfLineAt:24 direction:Backward];
  STAssertEquals(posOfEol,(NSUInteger)22,@"expected the first EOL at 22, found %d!",posOfEol);
  posOfEol=[cmds findEndOfLineAt:15 direction:Backward];
  STAssertEquals(posOfEol,(NSUInteger)10,@"expected the first EOL at 10, found %d!",posOfEol);
  posOfEol=[cmds findEndOfLineAt:5 direction:Backward];
  STAssertEquals(posOfEol,(NSUInteger)0,@"expected the first EOL at 0, found %d!",posOfEol);
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

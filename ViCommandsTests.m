//  Created by Axel on 24.08.09.
//  Copyright 2009 pqrs.de. All rights reserved.
//  
//  xcodebuild -target Testing -configuration Debug  

#import "ViCommandsTests.h"
#import "Commands.h"
#import "Logger.h"

/**
 * STFail(description, ...)
 * STAssertNil(a1, description, ...)
 * STAssertNotNil(a1, description, ...)
 * STAssertTrue(expression, description, ...)
 * STAssertTrueNoThrow(expression, description, ...)
 * STAssertFalse(expression, description, ...)
 * STAssertFalseNoThrow(expression, description, ...)
 * STAssertEqualObjects(a1, a2, description, ...)
 * STAssertEquals(a1, a2, description, ...)
 * STAssertEqualsWithAccuracy(left, right, accuracy, description, ...)
 * STAssertThrows(expression, description, ...)
 * STAssertThrowsSpecific(expression, specificException, description, ...)
 * STAssertThrowsSpecificNamed(expr, specificException, aName, description, ...)
 * STAssertNoThrow(expression, description, ...)
 * STAssertNoThrowSpecific(expression, specificException, description, ...)
 * STAssertNoThrowSpecificNamed(expr, specificException, aName, description, ...)
 */

// originally declared privately in Commands_implementation,
// mostly only for unit testing purposes
@interface Commands (utilities) 
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos;
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos;
- (unichar)currentNamedRegister;
- (NSString *)temporaryBuffer;
@end


@implementation ViCommandsTests

/**
 * create and initialize data structures. This method is 
 * called once before each test.
 */
- (void)setUp {
  _textView=[[NSTextView alloc] init];
  [self replaceText:@"the quick brown fox jumps over the lazy doc"];
  [self moveCursorToStart];
  _cmds=[[Commands alloc] initWithTextView:_textView];
  [_cmds processInput:0x1b];
}
 
/**
 * release data structures. This method is called once 
 * after each test.
 */
- (void)tearDown {
  [_textView release];
  [_cmds release];
}

/**
 * open new lines via <o> and <O>
 */
- (void)testOpenNewLines {
  // let's open a line below the cursor
  [self replaceText:@"the quick\nbrown fox"];
  [self moveCursorTo:5];
  [_cmds processInput:'o'];
  STAssertTrue([_cmds viMode]==Insert,@"vi should be in insert mode");
  STAssertEquals([self cursorPosition],(NSUInteger)10,@"invalid cursor location?!");
  STAssertEqualObjects([self line:1],@"\n",@"invalid line content?!");
  [_cmds processInput:0x1b];

  // let's open a line below the cursor when we're at the last line
  [self replaceText:@"the quick\nbrown fox"];
  [self moveCursorTo:13];
  [_cmds processInput:'o'];
  STAssertTrue([_cmds viMode]==Insert,@"vi should be in insert mode");
  STAssertEquals([self cursorPosition],(NSUInteger)20,@"invalid cursor location?!");
  STAssertEqualObjects([self line:2],@"",@"invalid line content?!");
  [_cmds processInput:0x1b];

  // let's open a line above the cursor
  [self replaceText:@"the quick\nbrown fox"];
  [self moveCursorTo:13];
  [_cmds processInput:'O'];
  STAssertTrue([_cmds viMode]==Insert,@"vi should be in insert mode");
  STAssertEquals([self cursorPosition],(NSUInteger)10,@"invalid cursor location?!");
  STAssertEqualObjects([self line:1],@"\n",@"invalid line content?!");
  [_cmds processInput:0x1b];

  // let's open a line above the cursor when we're at the first line
  [self replaceText:@"the quick\nbrown fox"];
  [self moveCursorTo:5];
  [_cmds processInput:'O'];
  STAssertTrue([_cmds viMode]==Insert,@"vi should be in insert mode");
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"\n",@"invalid line content?!");
  [_cmds processInput:0x1b];
}

/**
 * replace single characters 
 */
- (void)testReplacementOfSingleCharacters {
  // let's replace a single character
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'r'];
  [_cmds processInput:'f'];
  STAssertEquals([self cursorPosition],(NSUInteger)5,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qfick brown fox\n",@"invalid line content?!");

  // then let's replace multiple characters
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'3'];
  [_cmds processInput:'r'];
  [_cmds processInput:'f'];
  STAssertEquals([self cursorPosition],(NSUInteger)7,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qfffk brown fox\n",@"invalid line content?!");

  // then we're replacing the whole line
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:'0'];
  [_cmds processInput:'r'];
  [_cmds processInput:'f'];
  STAssertEquals([self cursorPosition],(NSUInteger)18,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qffffffffffffff\n",@"invalid line content?!");
}

/**
 * delete of change single characters
 */
- (void)testDeleteOrChangeOfSingleCharacters {
  // let's delete a single character
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'x'];
  STAssertEquals([self cursorPosition],(NSUInteger)5,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qick brown fox\n",@"invalid line content?!");

  // then we're going to delete multiple characters
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'7'];
  [_cmds processInput:'x'];
  STAssertEquals([self cursorPosition],(NSUInteger)5,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qown fox\n",@"invalid line content?!");

  // we're deleting more characters then the line contains
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:'0'];
  [_cmds processInput:'x'];
  STAssertEquals([self cursorPosition],(NSUInteger)5,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the q\n",@"invalid line content?!");

  // if we're at the end of the line the last character should disappear
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:19];
  [_cmds processInput:'x'];
  STAssertEquals([self cursorPosition],(NSUInteger)18,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the quick brown fo\n",@"invalid line content?!");

  // finally let's see if the change of characters works
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];
  [self moveCursorTo:5];
  [_cmds processInput:'3'];
  [_cmds processInput:'s'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)8,@"invalid cursor location?!");
  STAssertEqualObjects([self line:0],@"the qfook brown fox\n",@"invalid line content?!");
}

/**
 * move cursor to a given column
 */
- (void)testMoveCursorToColumn {
  [self replaceText:@"the quick brown fox\njumps over the lazy dog"];

  // move to start of line
  [_cmds processInput:'|'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid cursor placement?!");

  // move to the tenth column
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:'|'];
  STAssertEquals([self cursorPosition],(NSUInteger)10,@"invalid cursor placement?!");

  // move to end of line
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:'0'];
  [_cmds processInput:'|'];
  STAssertEquals([self cursorPosition],(NSUInteger)19,@"invalid cursor placement?!");
}

/**
 * test some possibilities to enter insert mode
 */
- (void)testInsertModeCommands {
  // simple insert mode via <i>
  [self replaceText:@"the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:1];
  [_cmds processInput:'i'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)4,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"tfoohe quick brown\n",@"invalid line content?!");

  // simple insert mode after current cursor via <a>
  [self replaceText:@"the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:1];
  [_cmds processInput:'a'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)5,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"thfooe quick brown\n",@"invalid line content?!");

  // insert at the beginning of the line via <I>
  [self replaceText:@"   the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:8];
  [_cmds processInput:'I'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"   foothe quick brown\n",@"invalid line content?!");

  // append to the end of line via <A>
  [self replaceText:@"   the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:8];
  [_cmds processInput:'A'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)21,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"   the quick brownfoo\n",@"invalid line content?!");

  // change to the end of line via <C>
  [self replaceText:@"the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:6];
  [_cmds processInput:'C'];
  [_textView insertText:@"foo"];
  [_cmds processInput:0x1b];
  STAssertEquals([self cursorPosition],(NSUInteger)9,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"the qufoo\n",@"invalid line content?!");

  // delete to the end of line via <D>
  [self replaceText:@"the quick brown\nfox jumps over\nthe lazy dog"];
  [self moveCursorTo:6];
  [_cmds processInput:'D'];
  STAssertTrue([_cmds viMode]==Command,@"vi should be in command mode");
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"the qu\n",@"invalid line content?!");
}

/**
 * does the delete operator work with the <t> and <f> commands?
 */
- (void)testDeleteToSearchSingleCharacters {
  // let's remove everything including the <b> at position 10
  [self replaceText:@"the quick brown fox jumps over the lazy dog\nSecond line"];
  [self moveCursorTo:1];
  [_cmds processInput:'d'];
  [_cmds processInput:'f'];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"trown fox jumps over the lazy dog\n",@"invalid line content?!");

  // let's remove everything right up to the <b> at position 10
  [self replaceText:@"the quick brown fox jumps over the lazy dog\nSecond line"];
  [self moveCursorTo:1];
  [_cmds processInput:'d'];
  [_cmds processInput:'t'];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");
  STAssertEqualObjects([self line:0],@"tbrown fox jumps over the lazy dog\n",@"invalid line content?!");
}

/**
 * test the search of single characters in the current line
 */
- (void)testSearchSingleCharacters {
  [self replaceText:@"the quick brown fox jumps over the lazy dog\nSecond line"];

  // do we find an existing character ahead of the current position?
  [self moveCursorTo:1];
  [_cmds processInput:'f'];
  [_cmds processInput:'q'];
  STAssertEquals([self cursorPosition],(NSUInteger)4,@"invalid cursor movement?!");

  // do we find the character the cursor is on?
  [self moveCursorTo:4];
  [_cmds processInput:'f'];
  [_cmds processInput:'q'];
  STAssertEquals([self cursorPosition],(NSUInteger)4,@"invalid cursor movement?!");

  // do we ignore a character before the current position?
  [self moveCursorTo:11];
  [_cmds processInput:'f'];
  [_cmds processInput:'q'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid cursor movement?!");

  // do we ignore a character in the next line?
  [self moveCursorTo:1];
  [_cmds processInput:'f'];
  [_cmds processInput:'S'];
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");

  // does a count argument work as specified?
  [self moveCursorTo:0];
  [_cmds processInput:'2'];
  [_cmds processInput:'f'];
  [_cmds processInput:'e'];
  STAssertEquals([self cursorPosition],(NSUInteger)28,@"invalid cursor movement?!");

  // does the <t> command work, too?
  [self moveCursorTo:1];
  [_cmds processInput:'t'];
  [_cmds processInput:'q'];
  STAssertEquals([self cursorPosition],(NSUInteger)3,@"invalid cursor movement?!");

  // even at the beginning of a line?
  [self moveCursorTo:45];
  [_cmds processInput:'f'];
  [_cmds processInput:'S'];
  STAssertEquals([self cursorPosition],(NSUInteger)45,@"invalid cursor movement?!");
  [_cmds processInput:'t'];
  [_cmds processInput:'S'];
  STAssertEquals([self cursorPosition],(NSUInteger)45,@"invalid cursor movement?!");
}

/**
 * yank some text into buffers
 */
- (void)testYanking {
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:1];
  [_cmds processInput:'y'];
  [_cmds processInput:'3'];
  [_cmds processInput:'w'];
  STAssertEqualObjects([self line:0],@"first line with some long text words\n",@"invalid line found?!");
  STAssertEqualObjects([_cmds temporaryBuffer],@"irst line with ",@"invalid temporary buffer content?!");
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");
}

/**
 * some delete operator tests
 */
- (void)testDeleteOperator {
  // let's delete parts of a single word
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:7];
  [_cmds processInput:'d'];
  [_cmds processInput:'w'];
  STAssertEqualObjects([self line:0],@"first lwith some long text words\n",@"invalid line found?!");
  STAssertEquals([self cursorPosition],(NSUInteger)7,@"invalid cursor movement?!");

  // let's delete multiple words with an operator count
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:1];
  [_cmds processInput:'4'];
  [_cmds processInput:'d'];
  [_cmds processInput:'w'];
  STAssertEqualObjects([self line:0],@"flong text words\n",@"invalid line found?!");
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");

  // let's delete multiple words with a command count
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:1];
  [_cmds processInput:'d'];
  [_cmds processInput:'4'];
  [_cmds processInput:'w'];
  STAssertEqualObjects([self line:0],@"flong text words\n",@"invalid line found?!");
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");

  // let's delete multiple words with both operator and command counts
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:1];
  [_cmds processInput:'2'];
  [_cmds processInput:'d'];
  [_cmds processInput:'2'];
  [_cmds processInput:'w'];
  STAssertEqualObjects([self line:0],@"flong text words\n",@"invalid line found?!");
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"invalid cursor movement?!");

  // let's delete multiple words over line boundaries
  [self replaceText:@"first line with some long text words\ndef 123abc!cdef abc\nthird line\nfourth line"];
  [self moveCursorTo:1];
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:'d'];
  [_cmds processInput:'w'];
  // XXX
  // this would be VIM: STAssertEqualObjects([self line:0],@"fcdef abc\n",@"invalid line found?!");
  STAssertEqualObjects([self line:0],@"third line\n",@"invalid line found?!");
  // XXX
}

/**
 * does the handling of named registers work?
 */
- (void)testReadingOfNamedRegisters {
  [self moveCursorTo:0];
  STAssertEquals([_cmds currentNamedRegister],(unichar)0,@"invalid named register");
  [_cmds processInput:'"'];
  [_cmds processInput:'"'];
  STAssertEquals([_cmds currentNamedRegister],(unichar)0,@"invalid named register");
  [_cmds processInput:'"'];
  [_cmds processInput:'a'];
  STAssertEquals([_cmds currentNamedRegister],(unichar)'a',@"invalid named register");
  [_cmds processInput:'"'];
  [_cmds processInput:0x1b];
  [_cmds processInput:'y'];
  STAssertEquals([_cmds currentNamedRegister],(unichar)0,@"invalid named register");
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"cursor must not move?!");
}

/**
 * try to cancel a command by pressing escape
 */
- (void)testCancelCurrentCommand {
  [self moveCursorTo:0];
  [_cmds processInput:'1'];
  [_cmds processInput:'0'];
  [_cmds processInput:0x1b];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)1,@"command wasn't canceled?!");
}

/**
 * word movements backward
 */
- (void)testWordBackward {
  [self replaceText:@"first line\ndef 123abc!cdef abc\nsecond line"];

  // what happens at the beginning of the text?
  [self moveCursorTo:0];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");

  // simple word backward, same for both <W> and <w>
  [self moveCursorTo:8];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:8];
  [_cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

  // simple word backward when the cursor is at the first char of the current word
  [self moveCursorTo:7];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:6];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");

  // WORD backward over special chars
  [self moveCursorTo:24];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)22,@"invalid word movement");
  [self moveCursorTo:24];
  [_cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // simple word backward over line endings, same for both <W> and <w>
  [self moveCursorTo:11];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:11];
  [_cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

  // finally let's add a count 
  [self moveCursorTo:17];
  [_cmds processInput:'3'];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");
  [self moveCursorTo:17];
  [_cmds processInput:'3'];
  [_cmds processInput:'B'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid word movement");

  // word backward with special chars
  [self replaceText:@"require '#'yaml'\nrequire 'set'\n\nmodule ActiveRecord #:nodoc:\n"];

  [self moveCursorTo:17];
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)8,@"invalid word movement");
  [_cmds processInput:'b'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid word movement");
}

/**
 * word movements forward
 */
- (void)testWordForward {
  [self replaceText:@"first line\ndef 123abc!cdef abc\nsecond line"];

  // simple word forward, same for both <W> and <w>
  [self moveCursorTo:11];
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [self moveCursorTo:11];
  [_cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // WORD forward over special chars
  [self moveCursorTo:15];
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)21,@"invalid word movement");
  [self moveCursorTo:15];
  [_cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)27,@"invalid word movement");

  // simple word forward over line endings, same for both <W> and <w>
  [self moveCursorTo:6];
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [self moveCursorTo:6];
  [_cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");

  // finally let's add a count 
  [self moveCursorTo:1];
  [_cmds processInput:'3'];
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [self moveCursorTo:1];
  [_cmds processInput:'3'];
  [_cmds processInput:'W'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");

  // word forward with special chars
  [self replaceText:@"require '#'yaml'\nrequire 'set'\n\nmodule ActiveRecord #:nodoc:\n"];

  [self moveCursorTo:0];
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)8,@"invalid word movement");
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid word movement");
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)15,@"invalid word movement");
  [_cmds processInput:'w'];
  STAssertEquals([self cursorPosition],(NSUInteger)17,@"invalid word movement");
}

/**
 * move the cursor to the end of the line
 */
- (void)testMoveToEndOfLine {
  [self replaceText:@"first line\nsecond line\n   third line\nfourth line"];

  // wir sind irgendwo in der Mitte irgendeiner Zeile
  [self moveCursorTo:27];
  [_cmds processInput:'$'];
  STAssertEquals([self cursorPosition],(NSUInteger)36,@"invalid movement");

  // wir sind irgendwo in der Mitte der letzten Zeile
  [self moveCursorTo:39];
  [_cmds processInput:'$'];
  STAssertEquals([self cursorPosition],(NSUInteger)48,@"invalid movement");
}

/**
 * move the cursor to the start of the line
 */
- (void)testMoveToBeginningOfLine {
  [self replaceText:@"first line\nsecond line\n   third line\nfourth line"];

  // wir sind irgendwo in der Mitte der ersten Zeile
  [self moveCursorTo:5];
  [_cmds processInput:'0'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");

  // wir sind irgendwo in der Mitte irgendeiner Zeile
  [self moveCursorTo:16];
  [_cmds processInput:'0'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid movement");

  // wir sind irgendwo in der Mitte irgendeiner Zeile und 
  // springen zum ersten non-whitespace-zeichen
  [self moveCursorTo:29];
  [_cmds processInput:'^'];
  STAssertEquals([self cursorPosition],(NSUInteger)26,@"invalid movement");
}

/**
 * move the cursor to the right 
 */
- (void)testMoveCursorRight {
  [self replaceText:@"first line\nsecond line\nthird line"];

  // wenn wir am Ende des Textes sind darf nichts passieren
  [self moveCursorTo:33];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)33,@"invalid movement");

  // am Ende einer bel. Zeile ebenfalls nichts
  [self moveCursorTo:22];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)22,@"invalid movement");

  // irgendwo im Text geht's dann nach links
  [self moveCursorTo:4];
  [_cmds processInput:'l'];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)6,@"invalid movement");

  // und jetzt nochmal mit einem Count irgendwo im Text
  [self moveCursorTo:4];
  [_cmds processInput:'3'];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)7,@"invalid movement");

  // und mit Count ueber das Ende hinaus
  [self moveCursorTo:7];
  [_cmds processInput:'6'];
  [_cmds processInput:'l'];
  STAssertEquals([self cursorPosition],(NSUInteger)10,@"invalid movement");
}

/**
 * move the cursor to the left 
 */
- (void)testMoveCursorLeft {
  [self replaceText:@"first line\nsecond line\nthird line"];

  // wenn wir am Anfang des Textes sind darf nichts passieren
  [self moveCursorTo:0];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");

  // am Anfang einer bel. Zeile ebenfalls nichts
  [self moveCursorTo:11];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)11,@"invalid movement");

  // irgendwo im Text geht's dann nach links
  [self moveCursorTo:4];
  [_cmds processInput:'h'];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)2,@"invalid movement");

  // und jetzt nochmal mit einem Count irgendwo im Text
  [self moveCursorTo:5];
  [_cmds processInput:'3'];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)2,@"invalid movement");

  // und mit Count ueber den Anfang hinaus
  [self moveCursorTo:3];
  [_cmds processInput:'6'];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)0,@"invalid movement");
}

/**
 * was passiert, wenn wir in einem one-liner ganz am Ende sind?
 */
- (void)testMoveCursorLeftOnOneLiner {
  [self replaceText:@"foobar carcdr"];
  [self moveCursorTo:13];
  [_cmds processInput:'h'];
  STAssertEquals([self cursorPosition],(NSUInteger)12,@"invalid movement");
}

/**
 * find the next line break from a given position on
 */
- (void)testFindEndOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger endOfLine=[_cmds findEndOfLine:0];
  STAssertEquals(endOfLine,(NSUInteger)10,@"invalid eol!");
  endOfLine=[_cmds findEndOfLine:13];
  STAssertEquals(endOfLine,(NSUInteger)22,@"invalid eol!");
  endOfLine=[_cmds findEndOfLine:24];
  STAssertEquals(endOfLine,(NSUInteger)33,@"invalid eol!");
}

/**
 * find the beginning of the current line
 */
- (void)testFindStartOfLine {
  [self replaceText:@"first line\nsecond line\nthird line"];

  NSUInteger startOfLine=[_cmds findStartOfLine:25];
  STAssertEquals(startOfLine,(NSUInteger)23,@"invalid sol!");
  startOfLine=[_cmds findStartOfLine:15];
  STAssertEquals(startOfLine,(NSUInteger)11,@"invalid sol!");
  startOfLine=[_cmds findStartOfLine:5];
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
  [_textView setSelectedRange:start];
}

/**
 * move the cursor to the end of the text
 */
- (void)moveCursorToEnd {
  NSRange end={[[_textView string] length],0};
  [_textView setSelectedRange:end];
  //[_textView scrollRangeToVisible:end];
}

/**
 * replace the content of the text view
 */
- (void)replaceText:(NSString *)text {
  NSAttributedString *attributedText=[[NSAttributedString alloc] initWithString:text];
  [[_textView textStorage] setAttributedString:attributedText];
  [attributedText release];
  [self moveCursorToStart];
}

/**
 * return the current cursor position
 */
- (NSUInteger)cursorPosition {
  NSRange range=[_textView selectedRange];
  return range.location;
}

/**
 * return the content of the given line
 */
- (NSString *)line:(int)lineNo {
  NSString *text=[[_textView textStorage] string];
  NSRange lineRange;
  int pos=0;
  for(int i=-1;i<lineNo;i++) {
    lineRange=[text lineRangeForRange:NSMakeRange(pos,0)];
    pos=lineRange.location+lineRange.length;
  }
  return [text substringWithRange:lineRange];
}

@end

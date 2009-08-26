//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands_implementation.h"
#import "Logger.h"

@implementation Commands (utilities)

/**
 * !!!METHOD ONLY FOR UNIT TESTING!!!
 * returns the current named register for the current command.
 */
- (unichar)currentNamedRegister {
  return _currentNamedRegister;
}

/**
 * !!!METHOD ONLY FOR UNIT TESTING!!!
 * returns the content of the delete buffer
 */
- (NSString *)temporaryBuffer {
  return _temporaryBuffer;
}

/**
 * true if the given text is a multiline text, false otherwise
 */
- (BOOL)hasMultipleLines:(NSString *)text inRange:(NSRange)range {
    NSRange isMultiline=[text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                              options:0
                                                range:range];
    return isMultiline.location!=NSNotFound;
}

/**
 * store the given text into a named register. If the name of the 
 * register is invalid, nothing will be stored and the call is a NOP.
 */
- (void)storeText:(NSString *)text intoRegister:(unichar)namedRegister {
  if(namedRegister==0)  // do we have a valid register?
    return;
  [Logger log:@"register handling for register <%c> is not yet implemented!",namedRegister];
}

/**
 * return the current cursor position
 */
- (NSUInteger)cursorPosition {
  NSRange range=[_textView selectedRange];
  return range.location;
}

/**
 * move the cursor to the given position.
 */
- (void)moveCursorTo:(NSUInteger)pos {
  [_textView setSelectedRange:NSMakeRange(pos,0)];
}

/**
 * return the position of the first character in the current line
 * or 0 if we're at the beginning of the text
 */
- (NSUInteger)findStartOfLine:(NSUInteger)currentPos {
  NSString *text=[[_textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(currentPos,0)];
  return lineRange.location;
}

/**
 * return the position of the last character in the current line
 * or the text length if we're at the end of the text
 */
- (NSUInteger)findEndOfLine:(NSUInteger)currentPos {
  // determine the last position of the line
  NSString *text=[[_textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(currentPos,0)];
  NSInteger pos=lineRange.location+lineRange.length;

  // if the current line has at least one char we've to determine the "visible" end-of-line, 
  // because we don't want the cursor to be on the non-visible newline characters
  if(lineRange.length>0) {
    unichar charAtPos=[text characterAtIndex:pos-1];
    BOOL isNewline=[[NSCharacterSet newlineCharacterSet] characterIsMember:charAtPos];
    if(isNewline)
      pos--;
  }

  // return the visible end-of-line position
  return pos;
}

/**
 * return the real end of line position including all white spaces and
 * newline characters at the end of the current line
 */
- (NSUInteger)findRealEndOfLine:(NSUInteger)currentPos {
  NSString *text=[[_textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(currentPos,0)];
  return lineRange.location+lineRange.length;
}

@end

@implementation Commands (implementation)

/**
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorLeft {
  NSInteger pos=[self cursorPosition],
            startOfLine=[self findStartOfLine:pos];
  pos-=(_currentCount>0 ? _currentCount:1);
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
  pos+=(_currentCount>0 ? _currentCount:1);
  if(pos>endOfLine)
    pos=endOfLine;
  [self moveCursorTo:pos];
}

/**
 * Moves the cursor one line up.
 */
- (void)cursorUp {
  int lines=(_currentCount>0 ? _currentCount:1);
  for(int i=0;i<lines;i++)
    [_textView moveUp:self];
}

/**
 * Moves the cursor one line down in the same column. If the position does not exist, vi 
 * comes as close as possible to the same column. A count repeats the effect.
 * Moves the cursor one character to the left. A count repeats the effect (3.1,7.5). 
 */
- (void)cursorDown {
  int lines=(_currentCount>0 ? _currentCount:1);
  for(int i=0;i<lines;i++)
    [_textView moveDown:self];
}

/**
 * places the cursor on the character in the column specified by the count (7.1, 7.2). 
 */
- (void)cursorToColumn {
  int pos=[self cursorPosition],
      startOfLine=[self findStartOfLine:pos],
      endOfLine=[self findEndOfLine:pos],
      newPos=startOfLine+_currentCount;
  [self moveCursorTo:(newPos>endOfLine ? endOfLine:newPos)];
}

/**
 * move to the beginning of the current line
 */
- (void)beginningOfLine {
  NSUInteger pos=[self findStartOfLine:[self cursorPosition]];
  [self moveCursorTo:pos];
}

/**
 * move to the first non-whitespace character of the current line
 */
- (void)beginningOfLineNonWhitespace {
  NSUInteger pos=[self cursorPosition];
  NSString *text=[[_textView textStorage] string];
  NSRange lineRange=[text lineRangeForRange:NSMakeRange(pos,0)],
          where=[text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                      options:0
                                        range:lineRange];
  if(where.location==NSNotFound)
    [self moveCursorTo:lineRange.location];
  else
    [self moveCursorTo:where.location];
}

/**
 * moves to the end of the current line
 */
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
  if(_currentCount==0)
    [_textView moveToEndOfDocument:self];
  else {
    NSInteger pos=0;
    NSString *text=[[_textView textStorage] string];
    for(int line=0;line<_currentCount-1;line++) {
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
  NSString *text=[[_textView textStorage] string];
  NSInteger pos=[self cursorPosition];
  int count=(_currentCount>0 ? _currentCount:1);
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

  NSString *text=[[_textView textStorage] string];
  NSInteger pos=[self cursorPosition]-1;
  int count=(_currentCount>0 ? _currentCount:1);
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

/**
 * Switches the case of the given count of characters starting from the current cursor position 
 * to the end of the current line. Non-alphabetic characters remain unchanged.
 *
 * This implementation is stupid and slow as hell, but it should be good enough since we are 
 * changing only a fairly small number of characters per call.
 */
- (void)switchCase {
  // first let's determine the final position in the text to swap the case
  int count=(_currentCount>0 ? _currentCount:1);
  NSInteger startPos=[self cursorPosition],
            endOfLine=[self findEndOfLine:startPos];
  if(startPos+count>endOfLine)
    count=endOfLine-startPos;
  NSRange swapRange=NSMakeRange(startPos,count);

  // then get the current content and swap its case.
  NSString *text=[[_textView textStorage] string];
  NSMutableString *result=[[[NSMutableString alloc] initWithCapacity:swapRange.length] autorelease];
  for(int i=0;i<count;i++) {
    NSString *singleChar=[text substringWithRange:NSMakeRange(startPos+i,1)];
    if([singleChar isEqualToString:[singleChar lowercaseString]])
      [result appendString:[singleChar uppercaseString]];
    else
      [result appendString:[singleChar lowercaseString]];
  }
 
  // finally replace the original content with the swapped version
  [_textView replaceCharactersInRange:swapRange
                          withString:result];
  [self moveCursorTo:(startPos+count)];
}

/**
 * go to insert mode at current cursor position.
 */
- (void)insertMode {
  _viMode=Insert;
}

/**
 * Appends arbitrary text after the current cursor position; the insert can continue onto multiple lines by using
 * <CR> within the insert. A count causes the inserted text to be replicated, but only if the inserted text is 
 * all on one line. The insertion terminates with an <ESC> (3.1,7.2). 
 */
- (void)insertModeAfterCursor {
  [self cursorRight];
  _viMode=Insert;
}

/**
 * Inserts at the beginning of a line; a synonym for ^i. 
 */
- (void)insertModeAtBeginningOfLine {
  [self beginningOfLineNonWhitespace];
  _viMode=Insert;
}

/**
 * Appends at the end of line, a synonym for $a (7.2). 
 */
- (void)insertModeAtEndOfLine {
  [self endOfLine];
  _viMode=Insert;
}

/**
 * Changes the rest of the text on the current line; a synonym for c$. 
 */
- (void)changeToEndOfLine {
  [self deleteEndOfLine];
  _viMode=Insert;
}

/**
 * Deletes the rest of the text on the current line; a synonym for d$. 
 */
- (void)deleteEndOfLine {
  int startPos=[self cursorPosition],
      endPos=[self findEndOfLine:startPos];
  [_textView setSelectedRange:NSMakeRange(startPos,endPos-startPos)];
  [_textView delete:self];
}

/**
 * Finds the first instance of the next character following the cursor on the current 
 * line. A count repeats the find (4.1). 
 */
- (void)findCharacter {
  // we need a second char
  if(!_waitingForFurtherInput) {
    _waitingForFurtherInput=TRUE;
    return;
  }

  // otherwise we got our second char, let's find it in the current lien
  _waitingForFurtherInput=FALSE;
  int startPos=[self cursorPosition],
      endPos=[self findEndOfLine:startPos],
      foundAt=NSNotFound;
  if(endPos<=startPos)
    return;
  NSString *text=[[_textView textStorage] string];
  int count=(_currentCount>0 ? _currentCount:1);
  for(int i=0;i<count;i++) {
    NSRange pos=[text rangeOfString:[NSString stringWithCharacters:&_currentInput length:1]
                            options:0
                              range:NSMakeRange(startPos,endPos-startPos)];
    if((foundAt=pos.location)==NSNotFound)
      break;
    startPos=foundAt+1;
    if(startPos>=[text length]) {
      foundAt=NSNotFound;
      break;
    }
  }

  // if we found the character move to cursor to it
  if(foundAt!=NSNotFound) {
    // strange vi speciality: if we're using this command inside an operator, we
    // have to include one more char to ensure we get a vi compatible range of 
    // characters for the operator to work on
    if(_operatorState!=NoOperator) {
      if(++foundAt>=[text length])
        foundAt--;
    }
  
    // finally let's move the cursor
    [self moveCursorTo:foundAt];
  }
}

/**
 * Finds a single character, backwards in the current line. 
 * A count repeats this search that many times (4.1). 
 */
- (void)findCharacterBackward {
  // we need a second char
  if(!_waitingForFurtherInput) {
    _waitingForFurtherInput=TRUE;
    return;
  }

  int crash=*((int *)0x00);
}

/**
 * Advances the cursor up to the character before the next character typed. Most useful with operators such as
 * <d> and <c> to delete the characters up to a following character. One can use <.> to delete more if this 
 * doesn’t delete enough the first time (4.1). 
 */
- (void)findAndStopBeforeCharacter {
  int currPos=[self cursorPosition];
  [self findCharacter];
  if([self cursorPosition]!=currPos)
    [self cursorLeft];
}

@end


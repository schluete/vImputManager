//  Created by Axel on 26.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands_operators.h"
#import "Commands_implementation.h"
#import "Logger.h"

@implementation Commands (operators)

/**
 * An operator which changes the following object, replacing it with the following input text up to an <ESC>. If
 * more than part of a single line is affected, the text which is changed away is saved in the numeric named buffers. 
 * If only part of the current line is affected, then the last character to be changed away is marked with a$. A 
 * count causes that many objects to be affected, thus both 3c)  and c3) change the following three sentences (7.4). 
 */
- (void)operatorChange {
  // let's see if we should do something this time
  NSRange changeRange=[self determineOperatorRange];
  if(changeRange.location==NSNotFound || changeRange.length<=0)
    return;
  
  // we store the changed text into the unnamed register
  [self storeText:_temporaryBuffer intoRegister:'"'];

  // ok, delete the range and go to insert mode
  [_textView setSelectedRange:changeRange];
  [_textView delete:self];
  _viMode=Insert;
}

/**
 * An operator which deletes the following object. If more than part of a line is affected, the text is saved in 
 * the numeric buffers. A count causes that many objects to be affected; thus 3dw is the same as d3w (3.3,3.4,4.1,7.4). 
 */
- (void)operatorDelete {
  // let's see if we should do something this time
  NSRange deleteRange=[self determineOperatorRange];
  if(deleteRange.location==NSNotFound || deleteRange.length<=0)
    return;

  // we store the changed text into the unnamed register
  [self storeText:_temporaryBuffer intoRegister:'"'];

  // ok, we got a text range to delete
  [_textView setSelectedRange:deleteRange];
  [_textView delete:self];
}

/**
 * (yank into register, does not change the text) An operator, yanks the following object into the unnamed temporary 
 * buffer. If preceded by a named buffer specification, "x, the text is placed in that buffer also. Text can be 
 * recovered by a later <p> or <P> (7.4). 
 */
- (void)operatorYank {
  // let's see if we should do something this time
  NSRange yankRange=[self determineOperatorRange];
  if(yankRange.location==NSNotFound || yankRange.length<=0)
    return;

  // we store the changed text into the unnamed register
  [self storeText:_temporaryBuffer intoRegister:'"'];
  
  // ok, we've got a range to yank into the buffer, but the yanking
  // was done by the determineOperatorRange method. So only the move
  // to the originating cursor position is left for us to do.
  [self moveCursorTo:_operatorStartPos];
}

/**
 * determine the range the operator should work on
 */
- (NSRange)determineOperatorRange {
  NSString *text=[[_textView textStorage] string];
  int count=(_operatorCount>0 ? _operatorCount:1);
  NSRange range={NSNotFound,0};

  // if we're called the second time let's operate on some lines
  if(_operatorState==SecondTime) {
    NSInteger startPos=[self findStartOfLine:[self cursorPosition]],
              endPos=startPos;
    for(int i=0;i<count;i++)
      endPos=[self findRealEndOfLine:endPos];
    range=NSMakeRange(startPos,endPos-startPos);
  }

  // otherwise we're waiting for the end of the following movement to
  // determine the final position for our operation
  else if(_operatorState==FirstTime)
    _operatorStartPos=[self cursorPosition];

  // were we called after a movement command following an operator? Then
  // let's determine the range to operate on
  else if(_operatorState==AfterCommand) {
    // determine the final position
    int startPos=(_operatorStartPos>0 ? _operatorStartPos:0),
        endPos=[self cursorPosition];
    if(startPos>endPos) {
      int buffer=startPos;
      startPos=endPos;
      endPos=buffer;
    }

    // if the range is multiline we're deleting the whole lines
    if([self hasMultipleLines:text inRange:NSMakeRange(startPos,endPos-startPos)]) {
      startPos=[self findStartOfLine:startPos];
      endPos=[self findRealEndOfLine:endPos];
    }

    // set the range to operate on
    range=NSMakeRange(startPos,endPos-startPos);
  }

  // if we got a valid range copy the range into the temporary buffer and 
  // possibly into a named register, too.
  if(range.location!=NSNotFound) {
    [_temporaryBuffer setString:[text substringWithRange:range]];
    [self storeText:_temporaryBuffer intoRegister:_currentNamedRegister];
    return range;
  }
  else
    return NSMakeRange(NSNotFound,0);
}

@end

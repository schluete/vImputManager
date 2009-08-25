//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>


// the constants for the search direction when lookup up chars
typedef enum _SearchDirection {
  Forward=1,
  Backward=-1
} SearchDirection;


/**
 * the command processor class
 */
@interface Commands: NSObject {
  NSTextView *textView;
  BOOL isReadingCount;
  NSMutableString *countBuffer;
  int currentCount;
  BOOL isReadingNamedRegister;
  unichar currentNamedRegister;
}

// constructor, called to set the view we're working on
- (id)initWithTextView:(NSTextView *)textView;

// cancel current command
- (BOOL)escape;

// process a single input character from the keyboard
- (BOOL)processInput:(unichar)input;

// process as named register identifier
- (BOOL)processInputAsNamedRegister:(unichar)input;

// process a single input character from the keyboard
- (BOOL)processInput:(unichar)input withControl:(BOOL)isControl;

@end


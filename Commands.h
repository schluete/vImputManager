//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>

// the possible vi modes the processor is in
typedef enum _ViMode{
  Insert=0,
  Command=1,
  Replace=2,
} ViMode;

// the constants for the search direction when lookup up chars
typedef enum _SearchDirection {
  Forward=1,
  Backward=-1
} SearchDirection;

// what is the current operator state
typedef enum _OperatorState {
  NoOperator=0,
  FirstTime=1,
  SecondTime=2,
  AfterCommand=3,
} OperatorState;


/**
 * the command processor class
 */
@interface Commands: NSObject {
  NSTextView *_textView;
  ViMode _viMode;
  unichar _currentInput;
  BOOL _waitingForFurtherInput;
  SEL _furtherInputHandler;

  BOOL _isReadingCount;
  NSMutableString *_countBuffer;
  int _currentCount;

  BOOL _isReadingNamedRegister;
  unichar _currentNamedRegister;

  OperatorState _operatorState;
  SEL _currentOperator;
  int _operatorCount;
  int _operatorStartPos;

  NSMutableString *_temporaryBuffer;
}

// constructor, called to set the view we're working on
- (id)initWithTextView:(NSTextView *)aTextView;

// return the current mode we're in
- (ViMode)viMode;

// cancel current command
- (void)escape;

// process a single input character from the keyboard
- (void)processInput:(unichar)input;

// process a single input character from the keyboard
- (void)processInput:(unichar)input withControl:(BOOL)isControl;

// try to process the input as a command
- (BOOL)processInputAsCommand:(unichar)input withControl:(BOOL)isControl;

// call the given command handler
- (void)callCommandHandler:(SEL)action;

// try to process the input as an operator
- (BOOL)processInputAsOperator:(unichar)input;

// called after a command was executed with an active operator.
- (void)processOperatorAfterCommand;

// process as named register identifier
- (BOOL)processInputAsNamedRegister:(unichar)input;

// try to process the input as an additional count
- (BOOL)processInputAsCount:(unichar)input;

@end


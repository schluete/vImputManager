//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"
#import "Logger.h"
#import "Commands_table.h"
#import "Commands_implementation.h"
#import "Commands_private.h"

@implementation Commands 

/**
 * constructor, called to initialize the view we're working on
 */
- (id)initWithTextView:(NSTextView *)aTextView { 
  if(![super init]) 
    return nil; 

  [aTextView retain];
  _textView=aTextView;

  [self initializeCommandsTable];
  _countBuffer=[[NSMutableString alloc] initWithCapacity:10];
  _temporaryBuffer=[[NSMutableString alloc] initWithCapacity:10];
  [self escape];

  _viMode=Insert;
  return self; 
}

/**
 * destructor, gibt alle Resources frei. Da wir sowohl in GC-
 * als auch in non-GC-Programmen laufen koennen fangen wir hier
 * beide Moeglichkeiten ab
 */
- (void)dealloc { [self destructor]; [super dealloc]; }
- (void)finalize { [self destructor]; [super finalize]; }
- (void)destructor {
  [_countBuffer release];
  [_temporaryBuffer release];
  [_textView release];
}

/**
 * we need to determine the selectors for all possible actions 
 * at runtime because if we're trying to insert them into the 
 * list of commands array at compile time we get a nasty error
 * message
 */
- (void)initializeCommandsTable {
  if(ListOfCommands[0].selector!=nil)
    return;

  // zuerst die Liste mit den Operators
  for(int pos=0;ListOfOperators[pos].key!=0;pos++) {
    NSString *selectorName=ListOfOperators[pos].selectorName;
    ListOfOperators[pos].selector=NSSelectorFromString(selectorName);
  }

  // dann die Liste mit den Commands
  for(int pos=0;ListOfCommands[pos].key!=0;pos++) {
    NSString *selectorName=ListOfCommands[pos].selectorName;
    ListOfCommands[pos].selector=NSSelectorFromString(selectorName);
  }
}

/**
 * return the current mode we're in
 */
- (ViMode)viMode {
  return _viMode;
}

/**
 * cancel current command and (re)initialize back to basic command mode 
 */
- (void)escape {
  _isReadingCount=FALSE;
  [_countBuffer setString:@""];
  _currentCount=0;

  _isReadingNamedRegister=FALSE;
  _currentNamedRegister=0;

  _operatorState=NoOperator;
  _currentOperator=nil;
  _operatorCount=0;

  _viMode=Command;
  _currentInput=0;
  _waitingForFurtherInput=FALSE;
  _furtherInputHandler=nil;
}

/**
 * process a single input character from the keyboard.
 */
- (void)processInput:(unichar)input {
  [self processInput:input withControl:FALSE];
}

/**
 * process a single input character from the keyboard.
 */
- (void)processInput:(unichar)input withControl:(BOOL)isControl {
  _currentInput=input;
//[Logger log:@"processing <%c> (%x) (control <%d>)",input,input,isControl];

  // wenn wir ein Escape gefunden haben brechen wir die aktuelle
  // Eingabe ab und initialisieren den Command Mode neu
  if(!isControl && input==0x1b) {
    [self escape];
    return;
  }

  // wenn wir nicht im Command-Mode sind brauchen wir den Rest gar nicht
  // erst auszuprobieren, da wir nur mit einem Escape in Selbigen kommen koennen.
  if(_viMode!=Command)
    return;

  // if we have pending command waiting for further input let's call 
  // that command first before handing the input over to other commands
  if(_waitingForFurtherInput) {
    [self callCommandHandler:_furtherInputHandler];
    return;
  }

  // dann gucken wir, ob wir vielleicht gerade in einem Count 
  // sind. Wenn ja handeln wir den zuerst ab.
  if(!isControl && [self processInputAsCount:input]) 
    return;

  // dann ueberpruefen wir, ob wir vielleich ein named register
  // fuer den folgenden Befehl haben
  if(!isControl && [self processInputAsNamedRegister:input])
    return;

  // nun gucken wir doch mal, ob wir einen Operator gefunden haben
  if(!isControl && [self processInputAsOperator:input])
    return;

  // jetzt bleibt nur noch die die Liste der moeglichen Kommandos, 
  // die wir nun durchsuchen ob irgendwas passt.
  if([self processInputAsCommand:input withControl:isControl]) {
    return;
  }

  // keinen passenden Commandhandler gefunden, schade.
  [Logger log:@"invalid input, no command or operator found for <%c> (control <%d>)",input,isControl];
  return;
}

/**
 * loops throught the list of command handlers and searches the matching 
 * one. If a handler was found the method will return TRUE, otherwise FALSE
 * will be returned
 */
- (BOOL)processInputAsCommand:(unichar)input withControl:(BOOL)isControl {
  for(int pos=0;ListOfCommands[pos].key!=0;pos++)
    if(ListOfCommands[pos].key==input && ListOfCommands[pos].control==isControl) {
      // if we're in an operator and if we got an operator count we want to 
      // execute the movement operatorCount * commandCount times.
      if(_operatorState!=NoOperator && _operatorCount>0)
        _currentCount=(_currentCount>0 ? _currentCount:1)*_operatorCount;

      // let's call the command handler
      SEL action=ListOfCommands[pos].selector;
      [self callCommandHandler:action];
      return TRUE;
    }

  // no valid command handler found for this input
  return FALSE;
}

/**
 * call the given command handler and clean up afterwards
 */
- (void)callCommandHandler:(SEL)action {
  int cursorPos=[self cursorPosition];
  [self performSelector:action];
  if(!_waitingForFurtherInput) {
    // let's clean up after the command
    if(cursorPos!=[self cursorPosition])
      [_textView scrollRangeToVisible:[_textView selectedRange]];
    _currentCount=0;
    _furtherInputHandler=nil;

    // do we still have a pending operator? 
    if(_operatorState!=NoOperator)
      [self processOperatorAfterCommand];
    _currentNamedRegister=0;
  }
  else
    _furtherInputHandler=action;
}

/**
 * versucht die aktuelle Eingabe als Operator zu verarbeiten
 */
- (BOOL)processInputAsOperator:(unichar)input {
  for(int pos=0;ListOfOperators[pos].key!=0;pos++)
    if(ListOfOperators[pos].key==input) {
      SEL action=ListOfOperators[pos].selector;

      // sind wir bereits im Operator-Mode und rufen diesen Operator zum zweiten Mal auf?
      if(_currentOperator) {
        if(_currentOperator==action) {
          _operatorState=SecondTime;
          [self performSelector:action];
          _operatorState=NoOperator;
          _currentOperator=nil;
          _operatorCount=0;
        }
        else 
          [self escape];    // fehlerhafter Operator-Call
      }

      // nein, zum ersten Mal, dann einfach aufrufen
      else {
        _currentOperator=action;
        _operatorState=FirstTime;
        _operatorCount=_currentCount;
        _currentCount=0;
        [self performSelector:action];
      }

      // nach einem Operator machen wir nix mehr 
      return TRUE;
    }

  // die Eingabe war wohl eher kein Operator
  return FALSE;
}

/**
 * called after a command was executed with an active operator.
 * Executes the operator action a second time, then clear the 
 * current operator
 */
- (void)processOperatorAfterCommand {
  _operatorState=AfterCommand;
  [self performSelector:_currentOperator];
  _operatorState=NoOperator;
  _currentOperator=nil;
  _operatorCount=0;
}

/**
 * ueberprueft, ob die aktuelle Eingabe die Bezeichnung fuer ein named
 * register darstellt.
 */
- (BOOL)processInputAsNamedRegister:(unichar)input {
  if(_isReadingNamedRegister) {
    if((input>='a' && input<='z') || (input>='A' && input<='Z') ||
       (input>='0' && input<='9') ||
       input=='.' || input=='%' || input=='#' || input==':' || input=='-')
      _currentNamedRegister=input;
    else {
      _currentNamedRegister=0;
    }
    _isReadingNamedRegister=FALSE;
  }
  else if(input=='"')
    _isReadingNamedRegister=TRUE;
  else
    return FALSE;
  return TRUE;
}

/**
 * liest einen Zahlenwert als zusaetzliche Stelle fuer den Count
 * ein. Wenn die Eingabe zum Count gehoerte wird TRUE zurueckgegeben, 
 * ansonsten wird FALSE geliefert.
 */
- (BOOL)processInputAsCount:(unichar)input {
  // wenn die Eingabe keine Zahl ist oder wir eine fuehrende 0 haben
  // (die es im VI als count nicht geben kann) ignorieren wir die Eingabe
  if(![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:input]) {
    if(_isReadingCount) {
      _currentCount=[_countBuffer intValue];
      [_countBuffer setString:@""];
      _isReadingCount=FALSE;
    }
    return FALSE;
  }
  if(!_isReadingCount && input=='0')
    return FALSE;

  // wenn es die erste Ziffer des count ist eine neue Zahl anfangen
  if(!_isReadingCount) {
    _isReadingCount=TRUE;
    [_countBuffer setString:@""];
  }

  // und dann die Ziffer an die Zahl anfuegen
  [_countBuffer appendFormat:@"%c",input];
  return TRUE;
}

@end

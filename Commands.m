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
  [self escape];
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
 * cancel current command and (re)initialize back to basic 
 * command mode 
 */
- (BOOL)escape {
  _isReadingCount=FALSE;
  [_countBuffer setString:@""];
  _currentCount=0;

  _isReadingNamedRegister=FALSE;
  _currentNamedRegister=0;

  return TRUE;
}

/**
 * process a single input character from the keyboard
 */
- (BOOL)processInput:(unichar)input {
  return [self processInput:input withControl:FALSE];
}

/**
 * process a single input character from the keyboard
 */
- (BOOL)processInput:(unichar)input withControl:(BOOL)isControl {
//[Logger log:@"processing <%c> (%x) (control <%d>)",input,input,isControl];

  // wenn wir ein Escape gefunden haben brechen wir die aktuelle
  // Eingabe ab und initialisieren den Command Mode neu
  if(input==0x1b)
    return [self escape];

  // dann gucken wir, ob wir vielleicht gerade in einem Count 
  // sind. Wenn ja handeln wir den zuerst ab.
  if(!isControl && [self processInputAsCount:input]) 
    return TRUE;

  // dann ueberpruefen wir, ob wir vielleich ein named register
  // fuer den folgenden Befehl haben
  if(!isControl && [self processInputAsNamedRegister:input])
    return TRUE;

  // nun gucken wir doch mal, ob wir einen Operator gefunden haben
  for(int pos=0;ListOfOperators[pos].key!=0;pos++)
    if(ListOfOperators[pos].key==input) {
      SEL action=ListOfOperators[pos].selector;
      // rufen wir diesen Operator gerade zum zweiten Mal auf?
     
      [self performSelector:action];
      return TRUE;
    }

  // jetzt bleibt nur noch die die Liste der moeglichen Kommandos, 
  // die wir nun durchsuchen ob irgendwas passt.
  for(int pos=0;ListOfCommands[pos].key!=0;pos++)
    if(ListOfCommands[pos].key==input && ListOfCommands[pos].control==isControl) {
      SEL action=ListOfCommands[pos].selector;
      [self performSelector:action];
      [_textView scrollRangeToVisible:[_textView selectedRange]];
      _currentCount=0;
      _currentNamedRegister=0;
      return TRUE;
    }

  // keinen passenden Commandhandler gefunden, schade.
  [Logger log:@"invalid input, no command or operator found for <%c> (control <%d>)",input,isControl];
  return FALSE;
}

/**
 * ueberprueft, ob die aktuelle Eingabe die Bezeichnung fuer ein named
 * register darstellt.
 */
- (BOOL)processInputAsNamedRegister:(unichar)input {
  if(input!='"')
    return FALSE;
  if(_isReadingNamedRegister) {
    if((input>='a' && input<='z') || (input>='A' && input<='Z') ||
       (input>='0' && input<='9') ||
       input=='.' || input=='%' || input=='#' || input==':' || input=='-')
      _currentNamedRegister=input;
    else
      _currentNamedRegister=0;
  }
  else
    _isReadingNamedRegister=TRUE;
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

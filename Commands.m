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
  textView=aTextView;

  isReadingCount=FALSE;
  countBuffer=[[NSMutableString alloc] initWithCapacity:10];
  currentCount=0;

  [self initializeCommandsTable];
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
  [countBuffer release];
  [textView release];
}

/**
 * we need to determine the selectors for all possible actions 
 * at runtime because if we're trying to insert them into the 
 * list of commands array at compile time we get a nasty error
 * message
 */
- (void)initializeCommandsTable {
  if(ListOfCommands[0].selector==nil)
    for(int pos=0;ListOfCommands[pos].key!=0;pos++) {
      NSString *selectorName=ListOfCommands[pos].selectorName;
      ListOfCommands[pos].selector=NSSelectorFromString(selectorName);
    }
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
//  [Logger log:@"processing <%c> (control <%d>)",input,isControl];

  // zuerst gucken wir, ob wir vielleicht gerade in einem Count 
  // sind. Wenn ja handeln wir den zuerst ab.
  if(!isControl && [self processInputAsCount:input]) 
    return TRUE;
//  [Logger log:@"current count is <%d>",currentCount];

  // kein Count, also durchsuchen wir die Liste der 
  // moeglichen Kommandos, ob irgendwas passt.
  for(int pos=0;ListOfCommands[pos].key!=0;pos++)
    if(ListOfCommands[pos].key==input && ListOfCommands[pos].control==isControl) {
      SEL action=ListOfCommands[pos].selector;
      if([self respondsToSelector:action]) {
        [self performSelector:action];
        [textView scrollRangeToVisible:[textView selectedRange]];
        currentCount=0;
      }
      else
        [Logger log:@"unknown action <%s>",action];
      return TRUE;
    }

  [Logger log:@"invalid input, no command found for <%c> (control <%d>)",input,isControl];
  return FALSE;
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
    if(isReadingCount) {
      currentCount=[countBuffer intValue];
      isReadingCount=FALSE;
    }
    return FALSE;
  }
  if(!isReadingCount && input=='0')
    return FALSE;

  // wenn es die erste Ziffer des count ist eine neue Zahl anfangen
  if(!isReadingCount) {
    isReadingCount=TRUE;
    [countBuffer setString:@""];
  }

  // und dann die Ziffer an die Zahl anfuegen
  [countBuffer appendFormat:@"%c",input];
  return TRUE;
}

@end

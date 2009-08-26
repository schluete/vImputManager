//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "KeyHandler.h"
#import "Logger.h"
#import "Commands.h"

@interface KeyHandler (privateCalls)

// release all resources 
- (void)destructor;

@end

@implementation KeyHandler

/**
 * constructor, called to initialize the view we're working on
 */
- (id)initWithTextView:(NSTextView *)aTextView { 
  [super init]; 
  _textView=[aTextView retain];
  _commands=[[Commands alloc] initWithTextView:_textView];
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
  [_commands release];
  [_textView release];
}

/**
 * called by the modified text view to process an event
 */
- (BOOL)handleKeyDownEvent:(NSEvent *)event {
  NSString *chars=[event charactersIgnoringModifiers];
  unichar charCode=[chars characterAtIndex:0];
  NSUInteger modifiers=[event modifierFlags];

  // if we're not in command mode and the current input isn't 
  // an ESC we're not going to handle this input by ourself
  if([_commands viMode]!=Command && charCode!=0x1b)
    return TRUE; 

  // otherwise we're handling this as a vi command input
  BOOL isControl=(modifiers & NSControlKeyMask)>0;
  [_commands processInput:charCode withControl:isControl];
  return FALSE;
}

@end

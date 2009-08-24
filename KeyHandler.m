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
  textView=[aTextView retain];
  commands=[[Commands alloc] initWithTextView:textView];
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
  [commands release];
  [textView release];
}

/**
 * called by the modified text view to process an event
 */
- (BOOL)handleKeyDownEvent:(NSEvent *)event {
  NSString *chars=[event charactersIgnoringModifiers];
  unichar charCode=[chars characterAtIndex:0];
  NSUInteger modifiers=[event modifierFlags];

  // zuerst ueberpruefen wir, ob wir ein [ESC] gefunden haben
  if(charCode==0x1b) {
    currentMode=Command;
    return FALSE;
  }

  // ok, es war kein Escape, sind wir im Command Mode?
  if(currentMode==Command) {
    BOOL isControl=(modifiers & NSControlKeyMask);
    [commands processInput:charCode withControl:isControl];
    return FALSE;
  }

  // nein, kein Command Mode, also auch nix fuer unseren vi
  return TRUE;
}

@end

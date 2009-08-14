//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "KeyHandler.h"
#import "Logger.h"


@implementation KeyHandler

/**
 * constructor, called to initialize the view we're working on
 */
- (id)initWithTextView:(NSTextView *)aTextView { 
  [super init]; 
  textView=aTextView;
  currentMode=Insert;
  return self; 
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
    [self handleEscape];
    return FALSE;
  }

  // ok, es war kein Escape, sind wir im Command Mode?
  if(currentMode==Command) {
    [self handleCommand:charCode modifiers:modifiers];
    return FALSE;
  }

  // nein, kein Command Mode, also auch nix fuer unseren vi
  return TRUE;
}

/**
 * change vi mode to command mode
 */
- (void)handleEscape {
  currentMode=Command;
}

/**
 * verarbeitet die Eingabe und fuehrt entsprechende vi-commandos aus
 */
- (void)handleCommand:(unichar)charCode modifiers:(NSUInteger)modifiers {
  // haben wir ein insert mode command?
  if([self handleInsert:charCode modifiers:modifiers])
    return;

  // oder haben wir eine Cursor-Bewegung?
  if([self handleMovement:charCode modifiers:modifiers])
    return;

  // unbekannter Befehl, einfach ignorieren
  [Logger log:@"unknown charCode found in command mode: <0x%x> (%c)",charCode,charCode];
}

/**
 * ueberprueft, ob eine Eingabe den Cursor bewegen soll, wenn 
 * ja wird die Bewegung durchgefuehrt und TRUE zurueckgeliefert.
 * In allen anderen Faellen wir FALSE als Ergebnis zurueckgegeben.
 */
- (BOOL)handleMovement:(unichar)charCode modifiers:(NSUInteger)modifiers {
  if(charCode=='h') {        // cursor left
    [textView moveLeft:textView];
  }
  else if(charCode=='l') {   // cursor right
    [textView moveRight:textView];
  }
  else if(charCode=='j') {   // down
    [textView moveDown:self];
  }
  else if(charCode=='k') {   // up
    [textView moveUp:self];
  }
  else if(charCode=='0') {   // beginning of line
    [textView moveToBeginningOfLine:self];
  }
  else if(charCode=='$') {   // end of line
    [textView moveToEndOfLine:self];
  }
  else if(charCode=='w') {   // word forward
    [textView moveWordForward:self];
  }
  else if(charCode=='b') {   // word backward
    [textView moveWordBackward:self];
  }
  else if(charCode=='G' && modifiers&NSShiftKeyMask) {      // move to end of document
    [textView moveToEndOfDocument:self];
    [textView moveToBeginningOfLine:self];
  }
  else
    return FALSE;
  return TRUE;
}

/**
 * verarbeitet alle Kommandos, die zum Insert Mode fuehren
 */
- (BOOL)handleInsert:(unichar)charCode modifiers:(NSUInteger)modifiers {
  if(charCode=='i') {                 // insert at caret position
  }
  else if(charCode=='a') {            // append after cursor position
    [textView moveRight:textView];
  }
  else if(charCode=='A') {            // append at the end of line
    [textView moveToEndOfLine:self];
  }
  else if(charCode=='o') {            // begin a new line below caret and insert text
    [textView moveToEndOfLine:self];
    [textView insertLineBreak:self];
  }
  else if(charCode=='O') {            // begin a new line above cursor and insert text
    [textView moveUp:self];
    [textView moveToEndOfLine:self];
    [textView insertLineBreak:self];
  }
  else
    return FALSE;
  currentMode=Insert;
  return TRUE;
}

@end

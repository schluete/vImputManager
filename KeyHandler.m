//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "KeyHandler.h"
#import "Logger.h"
#import <ctype.h>

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
  textView=aTextView;
  currentMode=Insert;
  currentNumber=[[NSMutableString alloc] initWithCapacity:10];
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
  [currentNumber release];
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
    if(![self handleDigits:charCode])
      if(![self handleCommand:charCode modifiers:modifiers])
        [Logger log:@"unknown charCode found in command mode: <0x%x> (%c)",charCode,charCode];
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
  isEnteringNumber=FALSE;
}

/**
 * verarbeitet die Eingabe von aufeinanderfolgende Ziffern 
 * als Zahl, die als Count fuer Commands genutzt werden kann.
 */
- (BOOL)handleDigits:(unichar)charCode {
  // ist die aktuelle Eingabe ueberhaupt eine Ziffer?
  if(!isdigit(charCode)) {
    isEnteringNumber=FALSE;
    return FALSE;
  }

  // wenn es die erste Ziffer der Zahl ist eine neue Zahl anfangen
  if(!isEnteringNumber) {
    isEnteringNumber=TRUE;
    [currentNumber setString:@""];
  }

  // und dann die Ziffer an die Zahl anfuegen
  [currentNumber appendFormat:@"%c",charCode];
  return TRUE;
}

/**
 * verarbeitet die Eingabe und fuehrt entsprechende vi-commandos aus
 */
- (BOOL)handleCommand:(unichar)charCode modifiers:(NSUInteger)modifiers {
  // haben wir ein insert mode command?
  if([self handleInsert:charCode modifiers:modifiers])
    return TRUE;

  // oder haben wir eine Cursor-Bewegung?
  if([self handleMovement:charCode modifiers:modifiers])
    return TRUE;

  // unbekannter Befehl, einfach ignorieren
  return FALSE;
}

/**
 * ueberprueft, ob eine Eingabe den Cursor bewegen soll, wenn 
 * ja wird die Bewegung durchgefuehrt und TRUE zurueckgeliefert.
 * In allen anderen Faellen wir FALSE als Ergebnis zurueckgegeben.
 */
- (BOOL)handleMovement:(unichar)charCode modifiers:(NSUInteger)modifiers {
  int count=[currentNumber intValue];

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
    [textView moveToBeginningOfLine:self];
    if(count==0)
      [textView moveToEndOfDocument:self];
    else {
      NSRange range=[textView selectedRange];
      NSRange line=[[textView string] lineRangeForRange: range];
      [Logger log:@"count <%d> location <%d>, length <%d>",count,range.location,range.length];
      [Logger log:@"line location <%d>, length <%d>",line.location,line.length];
    }
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

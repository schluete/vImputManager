//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "NSTextView_vImputManager.h"
#import "Commands.h"
#import "Logger.h"
#import <time.h>

// the global list of currently allocated command processors.
static NSMutableDictionary *ViCommandProcessors=nil;

@implementation NSTextView (vImputManager)

/**
 * overload the destructor to release the command 
 * processor instance associated with this text view.
 */
- (void)dealloc {
  [super dealloc];
  [ViCommandProcessors removeObjectForKey:[NSNumber numberWithInt:(int)self]];
}

/**
 * intercept key events to handle vi input mode.
 */
- (void)vImputManager_keyDown:(NSEvent *)event {
  // first we need to get the characters to process
  NSString *chars=[event charactersIgnoringModifiers];
  unichar charCode=[chars characterAtIndex:0];
  NSUInteger modifiers=[event modifierFlags];

  // get the command processor for this text view, allocate 
  // a new one if none is currently present for the view.
  if(!ViCommandProcessors)
    ViCommandProcessors=[[NSMutableDictionary alloc] init];
  NSNumber *myId=[NSNumber numberWithInt:(int)self];
  Commands *processor=[ViCommandProcessors objectForKey:myId];
  if(processor==nil) {
    processor=[[Commands alloc] initWithTextView:self];
    [ViCommandProcessors setObject:processor forKey:myId];
[Logger log:@"allocated a new processor <%@> for id <%x>",processor,[myId intValue]];
  }

  // if we're not in command mode and the current input isn't 
  // an ESC we're not going to handle this input by ourself
  if([processor viMode]==Command || charCode==0x1b) {
    BOOL isControl=(modifiers & NSControlKeyMask)>0;
    [processor processInput:charCode withControl:isControl];
  }

  // otherwise let the event bubble up the handler hierarchie
  else
    [self vImputManager_originalKeyDown:event];
}

/**
 * the garbage collector invokes this method before disposing 
 * of the memory it uses. We're overriding this method from 
 * NSTextView to ensure that the corresponding command processor
 * gets disposed.
 */
- (void)vImputManager_finalize {
  if(ViCommandProcessors) {
    NSNumber *myId=[NSNumber numberWithInt:(int)self];
[Logger log:@"finalized a processor <%@> for id <%x>",[ViCommandProcessors objectForKey:myId],[myId intValue]];
    [ViCommandProcessors removeObjectForKey:myId];
  }
else NSLog(@"trying to finalize processor but no list of processors found?!");

  [self vImputManager_originalFinalize];
}

/**
 * deallocates the memory occupied by the receiver. We're overriding 
 * this method from NSTextView to ensure that the corresponding 
 * key handler gets disposed.
 */
- (void)vImputManager_dealloc {
  if(ViCommandProcessors) {
    NSNumber *myId=[NSNumber numberWithInt:(int)self];
[Logger log:@"deallocated a processor <%@> for id <%x>",[ViCommandProcessors objectForKey:myId],[myId intValue]];
    [ViCommandProcessors removeObjectForKey:myId];
  }
else NSLog(@"trying to deallocate processor but no list of processors found?!");

  [self vImputManager_originalDealloc];
}

@end

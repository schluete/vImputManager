//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "NSTextView_vImputManager.h"
#import "KeyHandlerStorage.h"
#import "KeyHandler.h"
#import "Logger.h"
#import <time.h>


@implementation NSTextView (vImputManager)

/**
 * called by the keybinding to start the vi input mode. 
 *
 * To bind this message to a specific key you have to 
 * edit the default keybindings. These can be found 
 * in ~/Library/KeyBindings/DefaultKeyBinding.dict. To 
 * call this message add a custom keybinding like this:
 * "$\U001B" = "vImputManagerMode:";
 */
- (void)vImputManagerMode:(id)sender {
  [Logger log:@"the vim input mode was requested from <%@> at %ld!",sender,time(NULL)];
}

/**
 * intercept key events to handle vi input mode.
 */
- (void)vImputManager_keyDown:(NSEvent *)event {
  BOOL eventWasNotHandled=TRUE;

  KeyHandler *keyHandler=[[KeyHandlerStorage sharedInstance] findOrCreateHandlerFor:self];
  if(keyHandler)
    eventWasNotHandled=[keyHandler handleKeyDownEvent:event];

  if(eventWasNotHandled)
    [self vImputManager_originalKeyDown:event];
}

/**
 * the garbage collector invokes this method before disposing 
 * of the memory it uses. We're overriding this method from 
 * NSTextView to ensure that the corresponding key handler gets
 * disposed.
 */
- (void)vImputManager_finalize {
  [Logger log:@"we're being finalized %@",self];
  [[KeyHandlerStorage sharedInstance] releaseHandlerFor:self];
  [self vImputManager_originalFinalize];
}

/**
 * deallocates the memory occupied by the receiver. We're overriding 
 * this method from NSTextView to ensure that the corresponding 
 * key handler gets disposed.
 */
- (void)vImputManager_dealloc {
  [Logger log:@"we're being deallocated %@",self];
  [[KeyHandlerStorage sharedInstance] releaseHandlerFor:self];
  [self vImputManager_originalDealloc];
}

@end

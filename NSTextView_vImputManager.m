//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "NSTextView_vImputManager.h"
#import <time.h>
#import "Logger.h"

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
  //[[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
  time_t ts=time(NULL);
  [Logger log:@"the vim input mode was requested from <%@> at %ld!",sender,ts];
}

/**
 * intercept key events to handle vi input mode.
 */
- (void)vImputManager_keyDown:(NSEvent *)event {
  time_t ts=time(NULL);
  [Logger log:@"we got a key event <%@> at %ld!",event,ts];

/*    NSEvent: 
      type=KeyDown 
      loc=(0,442) 
      time=12603.9 
      flags=0x100 
      win=0x0 
      winNum=1973 
      ctxt=0x84af 
      chars="t" 
      unmodchars="t" 
      repeat=0 
      keyCode=17> at 1250175408!
*/
  if([event keyCode]==17)
    [self insertText:@"Hello world!"];
  else
    [self vImputManager_originalKeyDown:event];
}

@end

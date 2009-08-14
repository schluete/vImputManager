//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>


@interface NSTextView (vImputManager)

// called by the keybinding to start the vi input mode
- (void)vImputManagerMode:(id)sender;

// intercept key events to handle vi input mode 
- (void)vImputManager_keyDown:(NSEvent *)event;

// the garbage collector invokes this method before disposing of the memory it uses
- (void)vImputManager_finalize;

// deallocates the memory occupied by the receiver
- (void)vImputManager_dealloc;

@end



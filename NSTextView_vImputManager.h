//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import <Cocoa/Cocoa.h>


@interface NSTextView (vImputManager)

// called by the keybinding to start the vi input mode
- (void)vImputManagerMode:(id)sender;

// intercept key events to handle vi input mode 
- (void)vImputManager_keyDown:(NSEvent *)event;

@end



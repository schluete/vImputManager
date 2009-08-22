//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>

@interface Commands: NSObject {
}

// process a single input character from the keyboard
- (BOOL)processInput:(unichar)input withControl:(BOOL)isControl;

@end


//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "PseudoController.h"
#import "Logger.h"
#import <objc/objc-class.h>


@implementation PseudoController

- (void)awakeFromNib {
  [PseudoController swizzleMethodsOfClass:[NSTextView class] 
                                     from:@selector(keyDown:)
                                       to:@selector(vImputManager_originalKeyDown:)];
  [PseudoController swizzleMethodsOfClass:[NSTextView class] 
                                     from:@selector(vImputManager_keyDown:)
                                       to:@selector(keyDown:)];
  [Logger log:@"vi input mode successfully installed for test application"];
}

/**
 * exchange two method implementation on NSTextView
 */
+ (BOOL)swizzleTextViewMethodFrom:(SEL)originalSel to:(SEL)newSel {
  return [self swizzleMethodsOfClass:[NSTextView class]
                                from:originalSel 
                                  to:newSel];
}

/**
 * exchange two method implementation on the given class
 */
+ (BOOL)swizzleMethodsOfClass:(Class)clazz from:(SEL)originalSel to:(SEL)newSel {
	Method method=class_getInstanceMethod(clazz,originalSel);
	if(method==nil)
		return FALSE;
	method->method_name=newSel;
	return TRUE;
}

@end

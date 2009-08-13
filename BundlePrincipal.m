//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "BundlePrincipal.h"
#import <objc/objc-class.h>
#import "Logger.h"


@implementation BundlePrincipal

/**
 * called by the runtime after the input manager was loaded.
 */
+ (void)load {
  // let's get some informations about our current host app
  NSBundle *hostApp=[NSBundle mainBundle];
  NSString *bundleID=[hostApp bundleIdentifier];
  NSDictionary *infoDict=[hostApp infoDictionary];
  float version=[[infoDict valueForKey:@"CFBundleVersion"] floatValue];
  [Logger log:@"we were loaded for <%@>, version <%f>",bundleID,version];

  // install our own handlers by exchanging the NSTextView
  // keyDown: method implementation with our own version if 
  // this is the TextEdit.app
  if([bundleID isEqualToString:@"com.apple.TextEdit"] && version==244.0) {
    [BundlePrincipal swizzleMethodsOfClass:[NSTextView class] 
                                      from:@selector(keyDown:)
                                        to:@selector(vImputManager_originalKeyDown:)];
    [BundlePrincipal swizzleMethodsOfClass:[NSTextView class] 
                                      from:@selector(vImputManager_keyDown:)
                                        to:@selector(keyDown:)];
    [Logger log:@"vi input mode successfully installed"];
  }
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

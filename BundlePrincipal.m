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
  if(([bundleID isEqualToString:@"com.apple.TextEdit"] && version==244.0) ||
     ([bundleID isEqualToString:@"com.apple.Xcode"] && version==1191.0) ||
     ([bundleID isEqualToString:@"com.apple.mail"] && version==936.0)) 
  {
    [self renameMethods];
    [Logger log:@"vi input mode successfully installed"];
  }
}

/**
 * swap implementations for all methods used by our class
 */
+ (void)renameMethods {
  // the keyDown event handler
  [self swizzleTextViewMethodFrom:@selector(keyDown:)
                               to:@selector(vImputManager_originalKeyDown:)];
  [self swizzleTextViewMethodFrom:@selector(vImputManager_keyDown:)
                               to:@selector(keyDown:)];

  // the memory dealloction call (with garbage collector)
  [self swizzleTextViewMethodFrom:@selector(finalize) 
                               to:@selector(vImputManager_originalFinalize)];
  [self swizzleTextViewMethodFrom:@selector(vImputManager_finalize)
                               to:@selector(finalize)];

  // the memory dealloction call (without garbage collector)
  [self swizzleTextViewMethodFrom:@selector(dealloc)
                               to:@selector(vImputManager_originalDealloc)];
  [self swizzleTextViewMethodFrom:@selector(vImputManager_dealloc)
                               to:@selector(dealloc)];
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

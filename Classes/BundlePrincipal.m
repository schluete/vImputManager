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
  NSString *bundleId=[hostApp bundleIdentifier];
  NSDictionary *infoDict=[hostApp infoDictionary];
  float version=[[infoDict valueForKey:@"CFBundleVersion"] floatValue];
  [Logger log:@"we were loaded for <%@>, version <%f>",bundleId,version];

  // if the current application is blacklisted let's do nothing
  if(![self isHostApplicationAllowed:bundleId]) {
    [Logger log:@"application is blacklisted, ignore it!"];
    return;
  }

  // install our own handlers by exchanging the NSTextView
  // keyDown: method implementation with our own version
  [self renameMethods];
  [Logger log:@"vi input mode successfully installed"];
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

/**
 * read the whitelist property list and validate the given 
 * host application name against the list. If the application 
 * appears on the list the methods returns TRUE, otherwise
 * FALSE will be returned.
 */
+ (BOOL)isHostApplicationAllowed:(NSString *)appId {
  // find the blacklist file and read its raw data
  NSBundle *bundle=[NSBundle bundleWithIdentifier:@"de.pqrs.vImputManager"];
  NSString *plistPath=[bundle pathForResource:@"Whitelist" ofType:@"plist"];
  NSData *plistXML=[[NSFileManager defaultManager] contentsAtPath:plistPath];

  // then parse the blacklist file as a plist and 
  // return the entries
  NSString *errorDesc=nil;
  NSPropertyListFormat format;
  NSDictionary *plist=(NSDictionary *)[NSPropertyListSerialization 
    propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
                  format:&format
        errorDescription:&errorDesc];
  if(!plist)
    return false;
  NSArray *entries=[plist objectForKey:@"Entries"];
  if(!entries)
    return false;

  // finally check the given app name against the list entries
  for(NSString *entry in entries)
    if([entry isEqualToString:appId])
      return true;
  return false;
}

@end

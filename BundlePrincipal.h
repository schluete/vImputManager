//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>

@interface BundlePrincipal: NSObject {
}

// called by the runtime after the input manager was loaded
+ (void)load;

// swap implementations for all methods used by our class
+ (void)renameMethods;

// exchange two method implementation on NSTextView
+ (BOOL)swizzleTextViewMethodFrom:(SEL)originalSel to:(SEL)newSel;

// exchange two method implementation on the given class
+ (BOOL)swizzleMethodsOfClass:(Class)clazz from:(SEL)originalSel to:(SEL)newSel;

// check if the given application is blacklisted 
+ (BOOL)isBlacklistedHostApplication:(NSString *)appId;

@end

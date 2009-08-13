//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface BundlePrincipal: NSObject {
}

// called by the runtime after the input manager was loaded
+ (void)load;

// exchange two method implementation on the given class
+ (BOOL)swizzleMethodsOfClass:(Class)clazz from:(SEL)originalSel to:(SEL)newSel;

@end

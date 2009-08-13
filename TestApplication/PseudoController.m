//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "PseudoController.h"
#import "BundlePrincipal.h"
#import "Logger.h"


@implementation PseudoController

- (void)awakeFromNib {
  [BundlePrincipal swizzleMethodsOfClass:[NSTextView class] 
                                    from:@selector(keyDown:)
                                      to:@selector(vImputManager_originalKeyDown:)];
  [BundlePrincipal swizzleMethodsOfClass:[NSTextView class] 
                                    from:@selector(vImputManager_keyDown:)
                                      to:@selector(keyDown:)];
  [Logger log:@"vi input mode successfully installed for test application"];
}

@end

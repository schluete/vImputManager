//
//  PseudoController.h
//  vImputManager
//
//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PseudoController : NSObject {
  IBOutlet NSTextView *textView;
}

- (void)awakeFromNib;

// exchange two method implementation on NSTextView
+ (BOOL)swizzleTextViewMethodFrom:(SEL)originalSel to:(SEL)newSel;

// exchange two method implementation on the given class
+ (BOOL)swizzleMethodsOfClass:(Class)clazz from:(SEL)originalSel to:(SEL)newSel;

@end

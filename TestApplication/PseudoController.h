//
//  PseudoController.h
//  vImputManager
//
//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PseudoController : NSObject {
  IBOutlet NSTextView *textView;
}

- (void)awakeFromNib;

@end

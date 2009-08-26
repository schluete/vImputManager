//  Created by Axel on 26.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands_operators.h"
#import "Commands_implementation.h"
#import "Logger.h"

@implementation Commands (operators)

/**
 * An operator which changes the following object, replacing it with the following input text up to an <ESC>. If
 * more than part of a single line is affected, the text which is changed away is saved in the numeric named buffers. 
 * If only part of the current line is affected, then the last character to be changed away is marked with a$. A 
 * count causes that many objects to be affected, thus both 3c)  and c3) change the following three sentences (7.4). 
 */
- (void)operatorChange {
  NSLog(@"operator change");
}

/**
 * An operator which deletes the following object. If more than part of a line is affected, the text is saved in 
 * the numeric buffers. A count causes that many objects to be affected; thus 3dw is the same as d3w (3.3,3.4,4.1,7.4). 
 */
- (void)operatorDelete {
  NSLog(@"operator delete");
}

/**
 * (yank into register, does not change the text) An operator, yanks the following object into the unnamed temporary 
 * buffer. If preceded by a named buffer specification, "x, the text is placed in that buffer also. Text can be 
 * recovered by a later <p> or <P> (7.4). 
 */
- (void)operatorYank {
  NSLog(@"operator yank");
}

@end

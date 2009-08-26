//  Created by Axel on 26.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"

@interface Commands (operators)

// change the following object
- (void)operatorChange;

// delete the following object
- (void)operatorDelete;

// yank the following object into a register
- (void)operatorYank;

// determine the range an operator should work on
- (NSRange)determineOperatorRange;

@end

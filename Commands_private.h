//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.


@interface Commands (private)

// destructor
- (void)destructor;

// determine the selectors for the actions at runtime
- (void)initializeCommandsTable;

// process the given input as a digit for the count
- (BOOL)processInputAsCount:(unichar)input;

@end

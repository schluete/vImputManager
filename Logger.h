//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import <Cocoa/Cocoa.h>


@interface Logger: NSObject {
}

// write a log message into the system log
+ (void)log:(NSString *)format,...;

@end

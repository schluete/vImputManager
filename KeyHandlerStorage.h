//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import <Cocoa/Cocoa.h>

// forward declaration of the key handler class
@class KeyHandler;


@interface KeyHandlerStorage: NSObject {
}

// returns the singleton instance of the storage
+ (id)sharedInstance;

// constructor, called to initialize the view we're working on
- (id)init;

// return the corresponding handler for the given text view
- (KeyHandler *)findOrCreateHandlerFor:(NSTextView *)textView;

// remove a previously allocated key handler from the global
- (void)releaseHandlerFor:(NSTextView *)textView;

@end

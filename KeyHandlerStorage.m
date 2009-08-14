//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "KeyHandlerStorage.h"
#import "KeyHandler.h"


/**
 * the global hash containing the KeyHandler instances currently 
 * existing. It should be noted that this hash is definitly not 
 * garbage collected and resources must be handled manually!
 */
NSMutableDictionary *GlobalKeyHandlerStorage;


@implementation KeyHandlerStorage

/**
 * returns the singleton instance of the storage
 */
+ (id)sharedInstance {
  static KeyHandlerStorage *sharedInstance=nil;
  if(!sharedInstance)
    sharedInstance=[[KeyHandlerStorage alloc] init];
  return sharedInstance;
}

/**
 * constructor, called to initialize the view we're working on
 */
- (id)init { 
  [super init]; 
  GlobalKeyHandlerStorage=[[NSMutableDictionary alloc] init];
  return self; 
}

/**
 * return the corresponding handler for the given text view.
 * If no such handler currently exists a new one will be created
 * and added to the global handler list.
 */
- (KeyHandler *)findOrCreateHandlerFor:(NSTextView *)textView {
  NSNumber *hash=[NSNumber numberWithInteger:[textView hash]];
  KeyHandler *handler=[GlobalKeyHandlerStorage objectForKey:hash];
  if(handler==nil) {
    handler=[[KeyHandler alloc] initWithTextView:textView];
    [GlobalKeyHandlerStorage setObject:handler forKey:hash];
    [handler release];
  }
  return handler;
}

/**
 * remove a previously allocated key handler from the global
 * list of handlers. If no handler exists for the given text view
 * this method is a nop.
 */
- (void)releaseHandlerFor:(NSTextView *)textView {
  NSNumber *hash=[NSNumber numberWithInteger:[textView hash]];
  [GlobalKeyHandlerStorage removeObjectForKey:hash];
}

@end

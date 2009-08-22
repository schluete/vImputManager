//  Created by Axel on 20.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

#import "Commands.h"
#import "Logger.h"

@implementation Commands 

/**
 * constructor.
 */
- (id)init {
  if(![super init]) 
    return nil; 

  return self; 
}

struct {
  unichar key;
  BOOL control;
  SEL selector;
} CommandList[]={
  {'f',FALSE,(SEL)"foobar"}, // @selector(foobar)
  {'c',FALSE,(SEL)"carcdr:"}, // @selector(carcdr)

  {0,FALSE,nil}
};


/**
 * process a single input character from the keyboard
 */
- (BOOL)processInput:(unichar)input withControl:(BOOL)isControl {
//  [Logger log:@"we're called with <%c>",input];

  int pos=0;
  while(CommandList[pos].key!=0) {
    if(CommandList[pos].key==input && CommandList[pos].control==isControl) {
      SEL action=CommandList[pos].selector;
      if([self respondsToSelector:action])
        [self performSelector:action];
      else
        [Logger log:@"unknown action <%s>",action];
      return TRUE;
    }
    pos++;
  }
  return FALSE;
}

- (void)foobar {
  [Logger log:@"foobar"];
}

- (void)carcdr {
  [Logger log:@"carcdr"];
}

@end

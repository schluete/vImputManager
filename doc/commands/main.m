#import <Foundation/Foundation.h>
#import "Commands.h"

int main(int argc,const char **argv) {
  NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];

  Commands *cmds=[[Commands alloc] init];
 
  [cmds processInput:'f' withControl:FALSE];
  [cmds processInput:'c' withControl:FALSE];
  [cmds processInput:'f' withControl:FALSE];

#if 0
  [cmds processInput:'1' withControl:FALSE];
  [cmds processInput:'0' withControl:FALSE];
  [cmds processInput:'G' withControl:FALSE];

  [cmds processInput:'l' withControl:FALSE];

  [cmds processInput:'f' withControl:TRUE];
  [cmds processInput:'b' withControl:TRUE];
#endif

  [pool drain];
  return 0;
}

#import <Foundation/Foundation.h>
#import "Commands.h"

int main(int argc,const char **argv) {
  NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];

  Commands *cmds=[[Commands alloc] init];

  [cmds processInput:'3' withControl:FALSE];
  [cmds processInput:'G' withControl:FALSE];      // goto third line

  [cmds processInput:'0' withControl:FALSE];      // at the beginning of the line

  [cmds processInput:'1' withControl:FALSE];
  [cmds processInput:'0' withControl:FALSE];
  [cmds processInput:'l' withControl:FALSE];      // then move ten chars to the right

//  [cmds processInput:'c' withControl:FALSE];
//  [cmds processInput:'f' withControl:FALSE];

  [pool drain];
  return 0;
}

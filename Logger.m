//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "Logger.h"
#import <syslog.h>


@implementation Logger

/**
 * write a log message into the system log
 */
+ (void)log:(NSString *)format,... {
  va_list args;
  va_start(args,format);

  NSString *msg=[[NSString alloc] initWithFormat:format arguments:args];
  openlog("vImputManager",LOG_CONS|LOG_PID,LOG_USER);
  syslog(LOG_NOTICE,[msg UTF8String]);
  closelog();

  va_end(args);
  [msg release];
}

@end

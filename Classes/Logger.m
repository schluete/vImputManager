//  Created by Axel on 13.08.09.
//  Copyright 2009 pqrs.de, All rights reserved.

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
#ifdef BUILD_FOR_TEST_APPLICATION
  NSLog(@"%@", msg);
#else
  openlog("vImputManager",LOG_CONS|LOG_PID,LOG_USER);
  syslog(LOG_NOTICE,[msg UTF8String]);
  closelog();
#endif

  va_end(args);
  [msg release];
}

@end

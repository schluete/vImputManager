//  Created by Axel on 13.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.

#import "BundlePrincipal.h"
#import <syslog.h>


@implementation BundlePrincipal

+ (void)load {
  // let's get some informations about our current host app
  NSBundle *hostApp=[NSBundle mainBundle];
  NSString *bundleID=[hostApp bundleIdentifier];
  NSDictionary *infoDict=[hostApp infoDictionary];
  float version=[[infoDict valueForKey:@"CFBundleVersion"] floatValue];

  // write the host app info to the system log
  NSString *msg=[NSString stringWithFormat:@"we were loaded for <%@>, version <%f>",bundleID,version];
  openlog("vImputManager",LOG_CONS|LOG_PID,LOG_USER);
  syslog(LOG_NOTICE,[msg UTF8String]);
  closelog();
}

@end

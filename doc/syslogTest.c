
#include <stdio.h>
#include <syslog.h>

int main(int argc,char **argv) {
  openlog("axel",LOG_CONS|LOG_PID,LOG_USER);
  syslog(LOG_NOTICE,"and this is another little notice");
  closelog();

  printf("logging done!\n");
  return 0;
}

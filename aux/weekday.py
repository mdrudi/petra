#! /usr/bin/env python
#SAMPLE:
#
#$>weekday.py 20120919
#3
#$>weekday.py 20120920
#4
#
import sys
import time
#import calendar
t1=time.strptime(sys.argv[1],"%Y%m%d")
print (t1.tm_wday+1)

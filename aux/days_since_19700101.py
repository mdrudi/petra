#! /usr/bin/env python
#SAMPLE:
#
#
#
import sys
import time
import calendar
t1=time.strptime(sys.argv[1],"%Y%m%d")
s1=calendar.timegm(t1)
#print t1
j2=(s1-calendar.timegm(time.strptime("19700101","%Y%m%d")))/(24*60*60)
#/(24*60*60)
#print t2
print j2

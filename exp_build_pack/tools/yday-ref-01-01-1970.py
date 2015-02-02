#! /usr/bin/env python
#SAMPLE:
#
#$>jday.py 19700101 +15022
#20110217
#$>
#
#
import sys
import time
import calendar
t1=time.strptime(sys.argv[1],"%Y%m%d")
t2=time.strptime("19700101","%Y%m%d")
s1=calendar.timegm(t1)
s2=calendar.timegm(t2)
print 1+(s1-s2)/(24*60*60)

#s2=s1+int(sys.argv[2])*24*60*60
#t2=time.gmtime(s2)
#print t2
#out=time.strftime("%Y%m%d",t2)
#print out

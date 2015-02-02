#! /usr/bin/env python
#SAMPLE:
#./YYYYMMDDHHMMSS_19700101000000.py 1373373000
# 20130709 12:30:00
#
#./YYYYMMDDHHMMSS_19700101000000.py '20130709 12:30:00'
# 1373373000

import sys
import time
import calendar

try:
     t1=time.strptime(sys.argv[1],"%Y%m%d %H:%M:%S")
     s1=calendar.timegm(t1)
     #print t1
     j2=(s1-calendar.timegm(time.strptime("19700101000000","%Y%m%d%H%M%S")))
     print j2
except:
     t1=sys.argv[1]
     s1=time.strftime('%Y%m%d %H:%M:%S', time.gmtime(float(t1)))
     print s1  









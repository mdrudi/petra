#! /usr/bin/env python
#SAMPLE:
#
#$>./sec_counter.py "XXX_label_b1"
#XXX_label_b1 - sec 1456392533 - Thu 25 02 2016 09:28:53 +0000
#$>
#
#
import sys
import time
print sys.argv[1],'- sec', int(time.time()),'-' , time.strftime("%a %d %m %Y %H:%M:%S +0000",time.gmtime())

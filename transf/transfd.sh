#!/bin/sh

. `dirname $0`/envi.sh

#TimeStamp=`date +%Y%m%d%H%M%S`

#LogFile=$TILogDir/`basename $0`-${TimeStamp}-$$.log
##echo $LogFile
#exec 1> $LogFile  2>&1


#sh `dirname $0`/download.sh &
sh `dirname $0`/transfd-bg.sh &


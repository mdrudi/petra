#EventSpace=/tmp/eventmng
ComponentName=eventmng

#if [ _$TimeStamp = _ ]; then
#   TimeStamp=`date -u +%Y%m%d%H%M%S`$$
#   fi

#if [ -f /home/`whoami`/.eventmng.rc ]; then
#   echo Including /home/`whoami`/.eventmng.rc
#   . /home/`whoami`/.eventmng.rc
#   fi

. `dirname $0`/../envi.sh

export EventMng

if [ ! -d $EVEventSpace ]; then
   mkdir $EVEventSpace
fi

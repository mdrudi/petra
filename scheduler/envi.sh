ExeMapDefault=/home/`whoami`/exe_map.txt

if [ _$TimeStamp = _ ]; then
   TimeStamp=`date -u +%Y%m%d%H%M%S`$$
   fi

. `dirname $0`/../envi.sh

if [ ! -d $SCLogDir ]; then
   mkdir $SCLogDir
   if [ $? -eq 1 ]; then
      echo Failed mkdir $SCLogDir
      exit
   fi
fi

if [ ! -d $SCWorkDirBase ]; then
   mkdir $SCWorkDirBase
   if [ $? -eq 1 ]; then
      echo Failed mkdir $SCWorkDirBase
      exit
   fi
fi

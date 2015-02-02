


if [ $1 = "to_be_done" ]; then
   exit 0
   fi


if [ $1 = "list" ]; then
   ProcDay=$2

   BaseDir=/mnt/nfs0/tmp/postproc/datain/mfs_analyses_$ProcDay

   BinDir=`dirname $0`

   for i in -1 -2 -3 -4 -5 -6 -7 ; do
#-8 -9 -10 -11 -12 -13 -14 -15; do
      DayCut=`$BinDir/jday.py $ProcDay $i | cut -c3-`
      echo $BaseDir/${DayCut}_T.nc
      echo $BaseDir/${DayCut}_U.nc
      echo $BaseDir/${DayCut}_V.nc
      done
   fi

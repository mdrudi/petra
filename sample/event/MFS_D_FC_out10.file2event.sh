

if [ $1 = "to_be_done" ]; then
   exit 1
   fi

if [ $1 = "list" ]; then
   ProcDay=$2
   BaseDir=/mnt/nfs0/tmp/postproc/datain/mfs_forecast_$ProcDay

   BinDir=`dirname $0`

   for i in 0 1 2 3 4 5 6 7 8 9; do
      DayCut=`$BinDir/jday.py $ProcDay $i | cut -c3-`
      echo $BaseDir/${DayCut}_T.nc
      echo $BaseDir/${DayCut}_U.nc
      echo $BaseDir/${DayCut}_V.nc
      done
   fi

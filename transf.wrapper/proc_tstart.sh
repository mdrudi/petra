. `dirname $0`/envi.sh
PackSection=${PackSpace}/$1

locDir=`dirname $0`

for file_tstart in `find $PackSection -name "pack_*_*_*.tstart" -print | sort`; do
   echo Processing : $file_tstart
   StartTime=`bash ${locDir}/wrap_get.sh tstart $file_tstart`
   echo Found StartTime : $StartTime
   file_destdir=`dirname $file_tstart`/`basename $file_tstart | cut -d . -f 1`.destdir
   if [ `date +%Y%m%d%H%M` -ge ${StartTime} ] && [ ! -f $file_destdir ] ; then
      DestDir=`bash ${locDir}/wrap_get.sh bk_destdir $file_tstart`
      echo To be activated : $DestDir
      Cmd="echo $DestDir > $file_destdir"
      echo "$Cmd"
      eval $Cmd
      UpDown=`basename $file_tstart| cut -d_ -f 3`
      if [ $UpDown = "download" ]; then
         Cmd="mkdir $DestDir"
         echo "$Cmd"
         eval $Cmd
         fi
   else
      echo DestDir already active
   fi
   done

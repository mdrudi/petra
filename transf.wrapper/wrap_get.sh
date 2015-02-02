Command=$1
FileComplete=$2

if [ $Command == "procday" ]; then
   tmp=`basename $FileComplete | cut -d . -f 1`
   tmp1=`echo $tmp | cut -d _ -f 4`
   echo $tmp1
fi

if [ $Command == "line" ]; then
   tmp=`basename $FileComplete | cut -d . -f 1`
   tmp1=`echo $tmp | cut -d _ -f 5`
   echo $tmp1
fi

if [ $Command == "listfile" ]; then
   tmp=`dirname $FileComplete`/`basename $FileComplete | cut -d . -f 1`.TRANSFER_OK.txt
   for dlfile in `cat $tmp`; do
      NumC=`echo $dlfile | wc -c`
      UpLim=`expr $NumC - 2`
      PathFileName=`echo $dlfile | cut -c2-$UpLim`
      FileDestDir=`dirname $FileComplete`/`basename $FileComplete | cut -d . -f 1`.destdir
      echo `cat ${FileDestDir}`/`basename $PathFileName`
   done
fi 

if [ $Command == "tstart" ]; then
   cat `dirname $FileComplete`/`basename $FileComplete | cut -d . -f 1`.tstart
fi

if [ $Command == "bk_destdir" ]; then
   cat `dirname $FileComplete`/`basename $FileComplete | cut -d . -f 1`.bk_destdir 
fi

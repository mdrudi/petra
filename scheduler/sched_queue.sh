QueueList=$1
Day=$2      #optional
ExeMap=$3   #optional

. `dirname $0`/envi.sh

if [ _$Day != _"" ]; then
   ProcDay=$Day
   else
   ProcDay=`today.sh`
   fi

LogFile=$SCLogDir/`basename $0`-`basename ${QueueList}`-${ProcDay}-$TimeStamp-$$.log 
#echo $LogFile 
exec 1> $LogFile  2>&1                                                                           


AtLeastOneTransfer=0
AtLeastOneProc=0
AtLeastOneMonit=0


ProcHandler() {
            echo
            echo START - found $dcr
            if [ ! -f $dcr ]; then
               echo No action, does not exist : $dcr
            else
               #ExeTag=`basename $dcr`
               #grep _${ExeTag}_ $ExeMap
               #ForzoZero=0
               #if [ $? -eq 1 ]; then
               #if [ $ForzoZero -eq 1 ]; then
               #   echo $ExeTag is not active
               #   else
                  TypeDescr=`basename $dcr | cut -d. -f2`
                  if [ $TypeDescr == file2event ]; then
                     ProcS=$EventMng/file2event.sh
                  elif [ $TypeDescr == event2file ]; then
                     ProcS=$EventMng/event2file.sh
                  elif [ $TypeDescr == event2event ]; then
                     ProcS=$EventMng/event2event.sh
                  elif [ $TypeDescr == proc ]; then
                     AtLeastOneProc=1
                     ProcS=$SchedulerDir/sched_m_descr.sh
                  elif [ $TypeDescr == upload ]; then
                     AtLeastOneTransfer=1
                     ProcS=$TransfIndata/transf.sh
                  elif [ $TypeDescr == download ]; then
                     AtLeastOneTransfer=1
                     ProcS=$TransfIndata/transf.sh
                  elif [ $TypeDescr == checkevent ]; then
                     AtLeastOneMonit=1
                     ProcS=$MonitDir/monit-checkevent.sh
                  elif [ $TypeDescr == checksystem ]; then
                     AtLeastOneMonit=1
                     ProcS=$MonitDir/monit-checksystem.sh
                  elif [ $TypeDescr == mapevent ]; then
                     AtLeastOneMonit=1
                     ProcS=$MonitDir/monit-mapevent.sh
                  fi
                  Cmd="bash $ProcS $dcr $ProcDay"
                  echo $Cmd
                  eval "$Cmd"
               #fi
            fi
            echo END - found $dcr
            echo
   }


if [ _$Day != _"" ]; then 
   echo Working in manual mode with ProcToday= $ProcDay
   fi


#if [ _$ExeMap == _"" ]; then
#   ExeMap=$ExeMapDefault
#   fi
#if [ ! -f $ExeMap ]; then
#   echo $ExeMap does not exist
#   exit
#   fi

echo Processing ProcDay = $ProcDay
echo Processing Queue = $QueueList
#echo Checking the Active Procedure on $ExeMap


for RelativePathHandler in `cat $QueueList`; do

#   ExeTag=`basename $line`

   if [ ! `echo "$RelativePathHandler" | cut -c1` == "#" ]; then
      line=`dirname $QueueList`/$RelativePathHandler

      if [ -d $line ]; then

         SourceDir=$line
         for TypeDescr in file2event event2file event2event download proc upload checkevent checksystem ; do
            for dcr in `ls ${SourceDir}/*.${TypeDescr}.sh` ; do
               ProcHandler
            done
         done

      else  #it is not a dir, just a file

         dcr=$line
         ProcHandler

      fi
   fi

done




echo
echo START - final gather of events from processing and transfers

if [ $AtLeastOneTransfer -eq 1 ]; then
   Cmd="sh $TransfIndata/transfd.sh"
   echo $Cmd
   eval "$Cmd"
fi

#if [ $AtLeastOneProc -eq 1 ]; then             #not sure the done always works at the end of processing
#   Cmd="sh $SchedulerDir/sched_m_done.sh"      #so, need to launch also from here
#   echo $Cmd
#   eval "$Cmd"
#fi

if [ $AtLeastOneMonit -eq 1 ]; then
   Cmd="sh $MonitDir/monitd.sh"
   echo $Cmd
   eval "$Cmd"
fi

echo END - final gather of events from processing and transfers
echo


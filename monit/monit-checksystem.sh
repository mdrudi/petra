#!/bin/sh

. `dirname $0`/envi.sh

HandlerFile=$1

if [ $# -eq 2 ]; then
   ProcToday=$2
   echo Working in manual mode with ProcToday= $ProcToday
   else
   ProcToday=`date +%Y%m%d`
   fi

Handler() {
   echo > $MNMonitBlackBoard
   sh $HandlerFile systemproc $ProcToday
   if [ $? -eq 1 ]; then
      echo Failed the check $HandlerFile $ProcToday
      TimeStamp=`now-YYYYMMDDHHMMSS.sh`
      event_id_failed=${MNComponentName}-cs-`basename $HandlerFile|cut -d. -f1`-$ProcToday-$TimeStamp-failed
      ${EventMng}/event.sh set :$event_id_failed
#      event_id_start=${MNComponentName}-`basename $HandlerFile|cut -d. -f1`-$ProcToday-start
#      ${EventMng}/event.sh set :$event_id_start
#      if [ $? -eq 1 ]; then
      echo Recording the pending fail...
      Email=`sh $HandlerFile list_emails $ProcToday`
      EventNameFail=`sh $HandlerFile event_name_fail $ProcToday`
      if [ _$EventNameFail == "_" ] ; then
           EventNameFail="missing_event_name"
      fi
      echo `LogFormat.sh now` , check_system_fail , ${EventNameFail} , `head $MNMonitBlackBoard` >> $MNMonitLogFile
      cmd="grep '${HandlerFile};${ProcToday}' $MNLogDir/pending-$ProcToday.fails.txt"
      ExistingSameFail=`eval $cmd`
      if [ ! _$ExistingSameFail == '_' ] ; then
          echo no action: ${HandlerFile} already failed 
          else
            if [ _`grep workdir ${HandlerFile}` == '_' ] && [ _`echo  ${EventNameFail} | grep perf_slow` == '_' ] ; then
              echo "${HandlerFile};${ProcToday};;;${TimeStamp};${Email};${EventNameFail};`head $MNMonitBlackBoard`" >> $MNLogDir/pending-$ProcToday.fails.txt
            else
              echo "${HandlerFile};;;;;${Email};${EventNameFail};`head $MNMonitBlackBoard`" >> $MNLogDir/pending-$ProcToday.fails.txt
            fi
          fi   
      fi
   }


echo
echo found $HandlerFile
echo

Handler


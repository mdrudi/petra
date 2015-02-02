#!/bin/sh

. `dirname $0`/envi.sh

HandlerFile=$1

if [ $# -eq 2 ]; then
   ProcDay=$2
   echo Working in manual mode with ProcDay= $ProcDay
   else
   ProcDay=`date +%Y%m%d`
   fi

Handler() {
   ListEvents=`sh $HandlerFile list_wait_for_event $ProcDay`
   counter=0
   for EventIdMon in $ListEvents; do
      Checktime=`sh $HandlerFile checktime $ProcDay $counter`
      if [ ${Checktime}00 -le `now-YYYYMMDDHHMMSS.sh` ]; then
         event_id_start=${MNComponentName}-ce-`basename $HandlerFile|cut -d. -f1`-$ProcDay-${counter}-start
         ${EventMng}/event.sh check :$event_id_start
         if [ $? -eq 1 ]; then
            echo Already done $HandlerFile $ProcDay $counter - $EventIdMon
         else 
            ${EventMng}/event.sh set :$event_id_start
            ${EventMng}/event.sh check :$EventIdMon
            if [ $? -ne 1 ]; then
               event_id_failed=${MNComponentName}-ce-${EventIdMon}-failed
               ${EventMng}/event.sh set :$event_id_failed
               Email=`sh $HandlerFile list_emails $ProcDay`
               EventNameFail=`sh $HandlerFile event_name_fail $ProcDay $counter`
               if [ _$EventNameFail == "_" ] ; then
                  EventNameFail="missing_event_name"
               fi
               echo Recording the pending fail...
               echo "${HandlerFile};${ProcDay};${counter};${EventIdMon};${Checktime};${Email};${EventNameFail};`head $MNMonitBlackBoard`" >> $MNLogDir/pending-$ProcDay.fails.txt
               echo `LogFormat.sh now` , target_time_fail , ${ProcDay} , ${EventNameFail} ,  ${Checktime} >> $MNMonitLogFile
            fi
         fi
      fi
      counter=`expr $counter + 1`
   done
   }


echo
echo found $HandlerFile
echo

Handler


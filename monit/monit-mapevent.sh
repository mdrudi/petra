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
   ListEvents=`sh $HandlerFile list_in_event $ProcDay`
   counter=0
   for EventIdMon in $ListEvents; do
      event_id_done=${MNComponentName}-me-`basename $HandlerFile|cut -d. -f1`-$ProcDay-${counter}-done
      sh ${EventMng}/event.sh check :$event_id_done
      if [ $? -eq 1 ]; then
         echo Already done $HandlerFile $ProcDay $counter - $EventIdMon
         else 
         sh ${EventMng}/event.sh check :$EventIdMon
         if [ $? -eq 1 ]; then
            sh ${EventMng}/event.sh set :$event_id_done
            echo Mapping the event...
            timestamp=`sh ${EventMng}/event.sh gettimestamp :$EventIdMon`
            EventIdOut=`sh $HandlerFile list_out_event $ProcDay $counter`
            echo `LogFormat.sh $timestamp` , event_time_record , ${ProcDay} , ${EventIdOut}  >> $MNMonitLogFile
            fi
         fi
      counter=`expr $counter + 1`
      done
   }


echo
echo found $HandlerFile
echo

Handler


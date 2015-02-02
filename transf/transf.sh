#!/bin/bash

. `dirname $0`/envi.sh

#TimeStamp=`date +%Y%m%d%H%M%S`
#LogFile=$TILogDir/`basename $0`-$TimeStamp.log
##echo $LogFile
#exec 1> $LogFile  2>&1

. ${petra_aux}/CompetitionControl-r05.sh
CompetitionControl $TILogDir


SourcePlugIn=$1
ProcToday=$2
#if [ $# -eq 2 ]; then
#   ProcToday=$2
#   echo Working in manual mode with ProcToday= $ProcToday
#   else
#   ProcToday=`date +%Y%m%d`
#   fi


MyDel2() {
   md2_window=$1
   md2_basedir=$2
   num=`ls -1d $md2_basedir | wc -l`
   if [ $num -gt $md2_window ]; then
      ToDel=`expr $num - $md2_window`
      FileToDel=`ls -1d $md2_basedir | head -$ToDel`
      for nFile in $FileToDel ; do
         if [ -d $nFile ]; then
            Cmd="rm -f $nFile/*"
            echo "$Cmd"
            eval $Cmd
            Cmd="rmdir $nFile"
            echo "$Cmd"
            eval $Cmd
            else
            Cmd="rm -f $nFile"
            echo "$Cmd"
            eval $Cmd
            fi
         done
      else
      echo "#No file/s to remove in $md2_basedir"
      fi
   }



Line () {

   event_id_out=${TIComponentName}-`basename $descrfile|cut -d. -f1`-$ProcToday-${event_counter}-start
   ${EventMng}/event.sh check :$event_id_out
      if [ $? -eq 1 ]; then
         echo Already done $ProcToday $descrfile
         else
         proceed_flag=0
         if [ $noevent_flag -eq 0 ]; then
            ${EventMng}/event.sh check :$event2wait
            if [ $? -eq 1 ]; then
               proceed_flag=1
               else
               echo $descrfile : not ready yet $event2wait
               fi
            else
            proceed_flag=1
            fi

         if [ $proceed_flag -eq 1 ]; then
            bash ${FileTransfer}/wrap_descr1.sh $PackSection $descrfile $ProcToday $event_counter
            RollOff=`bash $descrfile rolloff`
            if [  _$RollOff != _0 ] && [  _$RollOff != _ ]; then
               echo RollOff= $RollOff
               OutDir=`bash $descrfile rolloff_dest`
               MyDel2 $RollOff "$OutDir"
               fi
         ${EventMng}/event.sh set :$event_id_out
#            sh ${EventMng}/event.sh prepare :$event_id_out
#            if [ $? -eq 1 ]; then
#               for line in `sh $descrfile event_body $ProcToday ${event_counter}`; do
#                  sh ${EventMng}/event.sh appendmsg :$event_id_out $line
#                  done
#               sh ${EventMng}/event.sh activation :$event_id_out
#               fi
            fi
         fi
   }



Handler() {
   PackSection=$TIComponentName/`basename $descrfile | cut -d . -f 1`
   listevent2wait=`sh $descrfile list_wait_for_event $ProcToday`
   echo listevent2wait = _ $listevent2wait
   noevent_flag=0
   event_counter=0
   if [ "$listevent2wait"_ == _  ]; then
      noevent_flag=1
      Line
      else
      for event2wait in $listevent2wait; do
         Line
         event_counter=`expr $event_counter + 1`
         done
      fi
   }









descrfile=$SourcePlugIn
echo
echo found $descrfile

Handler


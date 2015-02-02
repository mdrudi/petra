#!/bin/sh

. `dirname $0`/envi.sh

. ${petra_aux}/CompetitionControl-r05.sh
CompetitionControl $MNLogDir

TimeStamp=`now-YYYYMMDDHHMMSS.sh`

LogFile=$MNLogDir/`basename $0`-${TimeStamp}-$$.log
#echo $LogFile
exec 1> $LogFile  2>&1


counter=0

while [ $counter -lt $MNCheckNumber ]; do
   echo counter= $counter

   Cmd="rm -f $MNLogDir/email-*txt"
   echo $Cmd
   eval $Cmd


   echo
   echo Building Emails from Pending Events - `now-YYYYMMDDHHMMSS.sh`
   for PendingFile in `ls $MNLogDir/pending*`; do
      echo
      echo PendingFile= $PendingFile
      FlagValid=0
      #numSystFail=0

      
      while read line ; do
         echo
         echo line= $line
         ProcessEmail=0

         HandlerFile=`echo $line | cut -d';' -f1`

         if [ `basename $HandlerFile | cut -d. -f2` == "checkevent" ]; then
            ProcDay=`echo $line | cut -d';' -f2`
            EventIdMon=`echo "$line" | cut -d';' -f4`
            #CheckTime=`echo $line | cut -d';' -f5`
            EventNameFail=`echo $line | cut -d';' -f7`
            echo EventIdMon= $EventIdMon
            ${EventMng}/event.sh check :$EventIdMon
            if [ $? -ne 1 ]; then
               FlagValid=1
               ProcessEmail=1
               echo Check Still Fails
               ProcDayPending=`basename $PendingFile | cut -d- -f2 | cut -d. -f1`
               if [ `date -u +%Y%m%d` -gt `jday.py $ProcDayPending +2` ] ; then
                  echo event obsolete : Pending fail since $ProcDayPending is older then two days from now
                  ProcessEmail=0  
               fi
            else
               echo Check Passed
               timestamp=`sh ${EventMng}/event.sh gettimestamp :$EventIdMon`
               echo `LogFormat.sh $timestamp` , target_time_recover , ${ProcDay} , ${EventNameFail} >> $MNMonitLogFile
            fi
         fi

         if [ `basename $HandlerFile | cut -d. -f2` == "checksystem" ]; then
            ProcDay=`echo $line | cut -d';' -f2`
            EventNameFail=`echo $line | cut -d';' -f7`
            echo > $MNMonitBlackBoard
            sh $HandlerFile systemproc $ProcDay
            if [ $? -eq 1 ]; then
               FlagValid=1
               ProcessEmail=1
               #numSystFail=`expr $numSystFail + 1`
               echo Check Still Fails
               echo `LogFormat.sh now` , check_system_fail , ${EventNameFail} , `head $MNMonitBlackBoard` >> $MNMonitLogFile
               else
               echo Check Passed
               fi
         fi

         if [ $ProcessEmail -eq 1 ] ; then   #create or append the fail log in emailX file (one file each user)
            counter2=1
            Email=`echo $line | cut -d';' -f6`
            #echo Email $Email
            emc=`echo $Email | cut -d, -f $counter2`
            while [ ! _$emc == "_" ]; do
               echo Inserting for address $emc
               echo $line >> $MNLogDir/email-$emc.txt
               counter2=`expr $counter2 + 1`
               emc=`echo $Email | cut -d, -f $counter2`
            done
         fi

         done  < $PendingFile # for line in pending... 

      if [ $FlagValid -eq 0 ]; then
         echo
         echo All pending fails in $PendingFile are over...
         Cmd="rm -f $PendingFile"
         echo $Cmd
         eval $Cmd
         fi

      done   # for PendingFile

   echo
   echo Sending Emails
   counter2=0
   for EmailFile in `ls $MNLogDir/email-*`; do
      echo EmailFile= $EmailFile
      
       if [ $counter2 -eq 0 ] ; then                 #merging any mails in one for sendmail.py 
           cat $EmailFile > $MNLogDir/email-total.txt
       else
           prev=`expr $counter2 - 1`
            while read line2 ; do
              cmd="grep '`echo ${line2}`' ${EMC[$prev]}" #| cut -d';' -f1-6
              if [ _$(echo `eval $cmd |head -1| cut -c1`) == '_' ] ; then
                  echo $line2 >> $MNLogDir/email-total.txt
              fi
            done < $EmailFile
       fi
       EMC[$counter2]=$EmailFile  
       counter2=`expr $counter2 + 1`
      done
      
   python `dirname $0`/sendmail.py $MNLogDir/email-total.txt $PETRAComponentName
   if [ $? -eq 1 ] ; then
      python `dirname $0`/sendmail-passwd.py $MNLogDir/email-total.txt $PETRAComponentName `dirname $0`/pass.txt
   fi
   #rm -f $MNLogDir/email-total.txt
   echo
   Cmd="sleep $MNCheckPeriod"
   echo $Cmd
   eval $Cmd

   counter=`expr $counter + 1`
   done    # while

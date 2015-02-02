#!/bin/bash

Descr=$1
ForecastDay=$2

. `dirname $0`/envi.sh

#. ${petra_aux}/CompetitionControl-r04.sh
#CompetitionControl

MyDel2() {
   md2_window=$1
   md2_basedir=$2
   num=`ls -1d $md2_basedir | wc -l`
   if [ $num -gt $md2_window ]; then
      ToDel=`expr $num - $md2_window`
      FileToDel=`ls -1d $md2_basedir | head -$ToDel`
      for nFile in $FileToDel ; do
         if [ -d $nFile ]; then
            Cmd="rm -f $nFile/* $nFile/.*"
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



date -u
#for follow_event_id in `sh $Descr wait_for_event $ForecastDay`; do
#   sh ${EventMng}/event.sh wait :$follow_event_id
#   Cmd="touch $WorkDir/procday.$ForecastDay"
#   echo $Cmd
#   eval $Cmd
#   echo block > $WorkDir/input.txt
#   echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
#   for line in `sh ${EventMng}/event.sh readall :$follow_event_id`; do
#      echo localhost:$line >> $WorkDir/input.txt
#      done
#   echo block >> $WorkDir/input.txt
#   Proc=`sh $Descr proc`
#   echo
#   echo `date -u` - Start Processing , on event $follow_event_id
#   Cmd="sh `dirname $0`/sched_m_wdir.sh $WorkDir/input.txt $Proc $WorkDir localhost start"
#   echo $Cmd
#   eval $Cmd
#   echo `date -u` - End Processing , on event $follow_event_id
#   echo
#   done

#event_id=${ComponentName}-`basename $Descr|cut -d. -f1`-$ForecastDay
#sh ${EventMng}/event.sh check :$event_id

#if [ $? -eq 1 ]; then
#   echo Already done $ForecastDay $Descr
#   else

Linea() {
#   event2wait=`sh $Descr wait_for_event $ForecastDay`
#   sh ${EventMng}/event.sh wait :$event2wait
   Cmd="touch $WorkDir/procday.$ForecastDay"
   echo $Cmd
   eval $Cmd

   if [ -f $WorkDir/input.txt ];then
      Cmd="rm -f $WorkDir/input.txt"
      echo $Cmd
      eval $Cmd
      fi
   Cmd="touch $WorkDir/input.txt"
   echo $Cmd
   eval $Cmd

   FirstSMD=1
   OneBlockSMD=0
   for line in `${EventMng}/event.sh readall :$event2wait`; do
      #echo DBG $line
      if [ $line = "block" ]; then
         if [ ! $FirstSMD -eq 1 ]; then
            echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
         fi
         echo block >> $WorkDir/input.txt
      fi 
      if [ ! $line = "block" ]; then
         if [ $FirstSMD -eq 1 ]; then
            echo block >> $WorkDir/input.txt
            OneBlockSMD=1      #list of files are just one block
#         else
#            echo localhost:$line >> $WorkDir/input.txt
         fi
         echo localhost:$line >> $WorkDir/input.txt
      fi
      FirstSMD=0
   done
   if [ $OneBlockSMD -eq 1 ]; then
      echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
      echo block >> $WorkDir/input.txt
   fi
   if [ $FirstSMD -eq 1 ]; then
      echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
   fi

#   echo block >> $WorkDir/input.txt
#   block_flag=1
#   echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
#   for line in `sh ${EventMng}/event.sh readall :$event2wait`; do
#      if [ $line = "block" ] && [ $block_flag -eq 0 ]; then
#         echo block >> $WorkDir/input.txt
#         block_flag=1
##         echo $block_flag 1
#         echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
#         fi
#      if [ ! $line = "block" ]; then
#         echo localhost:$line >> $WorkDir/input.txt
#         block_flag=0
##         echo $block_flag 0
#         fi
#      done
#   if [ $block_flag -eq 0 ]; then
#      echo block >> $WorkDir/input.txt
#      fi

   Cmd="cat $WorkDir/input.txt"
   echo $Cmd
   eval $Cmd

#   echo block > $WorkDir/input.txt
#   echo localhost:$WorkDir/procday.$ForecastDay >> $WorkDir/input.txt
#   for line in `sh ${EventMng}/event.sh readall :$event2wait`; do
#      echo localhost:$line >> $WorkDir/input.txt
#      done
#   echo block >> $WorkDir/input.txt


   Proc=`sh $Descr proc`
   ExecType=`sh $Descr exec_type`
   if [ _$ExecType = _ ]; then
      ExecType="localhost"
      ExecPars="none"
   else
      ExecPars=`sh $Descr exec_pars`
   fi
   echo
   echo `date -u` - Start Processing , on event $event2wait
   Cmd="$SchedulerDir/sched_m_wdir.sh $WorkDir/input.txt $Proc $WorkDir $ExecType start \"$ExecPars\" "
#   Cmd="sh $SchedulerDir/sched_m_wdir.sh $WorkDir/input.txt $Proc $WorkDir localhost start \"$ExecPars\" "
   echo $Cmd
   eval $Cmd
   echo `date -u` - End Processing , on event $event2wait
   echo
   echo
#   echo `date -u` - Start Publishing
#   OutDir=`sh $Descr outdir $ForecastDay`
#   for line in `sh $Descr template_out $ForecastDay`; do
#      if [ ! -d $OutDir ]; then
#         Cmd="mkdir $OutDir"
#         echo $Cmd
#         eval $Cmd
#         fi
#      Cmd="mv -f $WorkDir/$line $OutDir"
#      echo $Cmd
#      eval $Cmd
#      done
#   echo
   echo `date -u` - Start Clean Old Data
   RollOff=`sh $Descr rolloff`
   RollOff_Dest=`sh $Descr rolloff_dest`
   echo RollOff= $RollOff
   MyDel2 $RollOff "$RollOff_Dest"
   echo
   echo `date -u` - End Clean
   }




listevent2wait=`sh $Descr list_wait_for_event $ForecastDay`
line_number=0
for event2wait in $listevent2wait; do 

   event_start_handler_line=${SCComponentName}-`basename $Descr|cut -d. -f1`-$ForecastDay-${line_number}-start
   ${EventMng}/event.sh check :$event_start_handler_line
   if [ $? -eq 1 ]; then
      echo Already started $Descr $ForecastDay $line_number 
      else
      ${EventMng}/event.sh check :$event2wait
      if [ $? -eq 1 ]; then

         ${EventMng}/event.sh set :$event_start_handler_line

         WorkDir=$SCWorkDirBase/`basename $Descr|cut -d . -f 1`-$ForecastDay-$line_number

         if [ -d $WorkDir ]; then
            Cmd="rm -f $WorkDir/*"
            echo $Cmd
            eval $Cmd
         else
            Cmd="mkdir $WorkDir"
            echo $Cmd
            eval $Cmd

            if [ ! -d $WorkDir ]; then
               echo $0 : WorkDir non esiste : exit
               exit
            fi
         fi
         
         sh $Descr outdir $ForecastDay $line_number > $WorkDir/outdir.txt
         sh $Descr template_out $ForecastDay $line_number > $WorkDir/template_out.txt 

         Linea

      else
         echo $Descr $ForecastDay $line_number : not ready yet $event2wait
      fi
   fi

   line_number=`expr $line_number + 1`

   done

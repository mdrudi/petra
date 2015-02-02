#!/bin/bash

. `dirname $0`/envi.sh

LogFile=$SCLogDir/`basename $0`-${TimeStamp}-$$.log
#echo $LogFile
exec 1> $LogFile  2>&1

#PathDone=$1

#if [ ! _$PathDone = "_" ]; then

#. ${petra_aux}/CompetitionControl-r05.sh
#CompetitionControl $SCLogDir


#for file_done in `ls -1 $SCWorkDirBase/*/done.txt`; do
ProcessDone () {
   echo
   echo $file_done
   WorkDir=`dirname $file_done`
   event_id=${SCComponentName}-`basename $WorkDir`-done
   ${EventMng}/event.sh prepare :$event_id
   if [ $? -eq 1 ]; then
#      echo ERROR - unexperted state
#   else
      outdir=`cat $WorkDir/outdir.txt`
      if [ ! -d $outdir ]; then
         Cmd="mkdir $outdir"
         echo $Cmd
         eval $Cmd
      fi
      if [ ! -d $outdir ]; then
         echo ERROR - not possible mkdir $outdir
      else
         template_out=`cat $WorkDir/template_out.txt`
         for file_tr in $template_out; do
            Cmd="cp -p $WorkDir/$file_tr $outdir/"
            echo $Cmd
            eval $Cmd
            if [ ! $? -eq 0 ]; then
               echo ERROR - not possible copy for $WorkDir/$file_tr
               exit
            else
               Cmd="rm -f $WorkDir/$file_tr"
               echo $Cmd
               eval $Cmd
            fi 
            ${EventMng}/event.sh appendmsg :$event_id "$outdir/$file_tr" 
         done
         ${EventMng}/event.sh activation :$event_id
      fi
   fi 
}
#done



PathDone=$1

if [ ! _$PathDone = "_" ]; then

   if [ -f $PathDone ]; then
      file_done=$PathDone
      ProcessDone
   else
      echo File does not exist : $PathDone
   fi

else

   . ${petra_aux}/CompetitionControl-r05.sh
   CompetitionControl $SCLogDir

   for file_done in `ls -1 $SCWorkDirBase/*/done.txt`; do
      ProcessDone
   done

fi

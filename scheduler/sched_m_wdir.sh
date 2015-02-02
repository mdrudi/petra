#!/bin/bash

if [ $# -lt 4 ]; then
   echo
   echo Syntax error
   echo Usage: `basename $0` "InputDataSet FileProcessor ClusterOutDir Node StartAction"
   echo
   echo Sample 1:
   echo host:~/$ InputDataSet=/home/dopman/procedure/dataset/ds2001-2007Sys2b.txt
   echo host:~/$ FileProcessor=/home/myname/procedura.sh
   echo host:~/$ ClusterOutDir=/store/myname/myoutputs
   echo host:~/$ `basename $0` \$InputDataSet \$FileProcessor \$ClusterOutDir localhost start
   echo
#   echo Sample 2:
#   echo host:~/$ OutDir=ftp://myname@ftp.cmcc.it/incoming
#   echo host:~/$ `basename $0` \$DataSet \$FileProcessor \$WorkDir \$OutDir
#   echo
   exit 1
   fi

InputData=$1
FileProcessor=$2
OutDir=$3
Node=$4          #localhost or cluster
StartAction=$5
SubPars=$6       #optional : required in case Node=cluster

. `dirname $0`/envi.sh

CheckFile(){
   if [ ! -f $1 ]; then
      echo
      echo "error: file $1 missing"
      exit
      fi
   }

CheckFile $InputData
CheckFile $FileProcessor

CheckDir() {
   echo
   echo Testing $1= $2
   if [ ! -d $2 ]; then
      echo "error: dir $2 does't exist"
      exit
      fi
   if [ ! `echo $2 | cut -c1` == "/" ]; then
      echo error: dir $2 must be absolute path
      exit
      fi
   }

CheckDir "ClusterOutDir" $OutDir


Pilot="$OutDir/pilot.sh"
echo
echo Pilot= 
echo $Pilot

echo "#!/bin/sh" 1> $Pilot  2>&1 
Cmd="$SchedulerDir/sched_m_input.sh $InputData $FileProcessor $OutDir/work $OutDir $OutDir/tmp $Node \"$SubPars\" "
echo "#$Cmd" 1> $Pilot  2>&1
eval $Cmd 1> $Pilot  2>&1

if [ _$petra_custom != _ ] ; then
   if [ -f $petra_custom ]; then
      cp -p $petra_custom $OutDir/
      Cmd="export petra_custom;petra_custom=$OutDir/`basename $petra_custom`"
      #echo "echo \"$Cmd\" " >> $Pilot
      echo "$Cmd"           >> $Pilot
   fi
fi
Cmd="$SchedulerDir/sched_m_done.sh $OutDir/done.txt"
echo "echo \"$Cmd\" " >> $Pilot
echo "$Cmd"           >> $Pilot

if [ $StartAction = "start" ]; then
   echo Start pilot...
   sh $Pilot &
   fi

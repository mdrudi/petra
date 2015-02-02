#!/bin/bash

FileList=$1
#Envi=$2
Processor=$2 #on cluster
WorkDir=$3
OutDir=$4    #on cluster
AppoDir=$5   #on cluster
Node=$6      #localhost or cluster
SubPars=$7   # optional : required in case Node=cluster


CopiaFile() {
      cpmyprefix=`echo $InFile | cut -c-10`
      cpmyval=`echo $InFile | cut -c11-`

      echo
      if [ "localhost:" == $cpmyprefix ]; then
         Cmd="cp  $cpmyval $adIn/"
         Cmd="ln -s $cpmyval $adIn/"
         else
         #Cmd="scp -p $InFile $wdIn/"
         Cmd="ncftpget mfs $adIn/ $InFile"
         fi
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      InFileName=`basename $InFile`
      FileGZ=$adIn/$InFileName
      nc=`echo $FileGZ | wc -c`
      ncm3=`expr $nc - 3`
      FileType=`echo $FileGZ | cut -c$ncm3-`
      read InFile
      if [ $? -ne 0 ]; then
         Continua=1
	 InFile="stop"
         fi
   }


echo
echo "#******BRGIN $0*******"
echo "#"`date`
echo "#FileList=    $FileList"
echo "#clProcessor= $Processor"
echo "#WorkDir=     $WorkDir"
echo "#clOutDir=    $OutDir"
echo "#clAppoDir=   $AppoDir"
echo "#******BRGIN $0*******"
echo

echo PATH=$PATH
echo export PATH

MakeDir() {
   echo
   echo "if [ ! -d $1 ]; then"
   Cmd="mkdir $1"
   echo "   echo \"$Cmd\" "
   echo "   $Cmd"
   echo "   fi"
   }

MakeDir $WorkDir 
MakeDir $OutDir 
MakeDir $AppoDir

adInBase="$AppoDir/in"
LogFileName=`basename $WorkDir`

echo
echo "TimeStamp=\`date -u +%Y%m%d%H%M%S%N\`\$$ "
#echo "LogFile=\"$WorkDir/log-\$TimeStamp.log\" "
#echo "LogFile=\"$OutDir/$LogFileName-\$TimeStamp.log\" "
echo "LogFile=\"$OutDir/log.txt\" "
echo "echo \"set LogFile= \$LogFile\" "
echo "exec 1>> \$LogFile  2>&1 "


echo
echo "echo \"Lista file da processare:\" "
Cmd="cat $FileList"
echo "$Cmd"


echo
#Cmd="cp $SchedulerDir/processor_wrapper.sh $AppoDir/"
#echo "echo \"$Cmd\" "
#echo "$Cmd"

#echo
#cat $Envi

exec < $FileList

BlockMode=0
Continua=0

read InFile
if [ $? -ne 0 ]; then
   Continua=1
   fi
if [ $InFile == "stop" ]; then
   Continua=1
   fi

Cmd="date"
echo "echo \"$Cmd\" "
echo "$Cmd"

cont=0
while [ $Continua -eq 0 ] ; do
   adIn=${adInBase}-$cont
   job_cont=$AppoDir/job_${cont}
   cont=`expr $cont + 1`
   echo
   Cmd="mkdir ${adIn}"
   echo "echo \"$Cmd\" "
   echo "$Cmd"
#all'inizio devo avere: nome file, primo "block"
   if [ $InFile == "block" ] ; then
      BlockMode=1
      read InFile
      if [ $? -ne 0 ]; then
         Continua=1
         fi
      fi

   if [ $BlockMode -eq 1 ] ; then

      while [ $InFile != "block" ] &&  [ $InFile != "stop" ] ; do 
         CopiaFile
         done
      if [ $InFile == "stop" ]; then
         Continua=1
         fi
      if [ $InFile == "block" ]; then
         read InFile
         if [ $? -ne 0 ]; then
            Continua=1
            fi
	 fi
      else
      CopiaFile
      if [ $InFile == "stop" ]; then
         Continua=1
         fi
      fi

   echo
   if [ $Node == 'localhost' ]; then
      Cmd="$Processor $adIn $WorkDir noneLog $OutDir"
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      Cmd="rm -f $adIn/*"
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      Cmd="rmdir $adIn"
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      echo
   else
      Cmd="echo \"$Processor $adIn $WorkDir noneLog $OutDir\" > ${job_cont}"
      echo "$Cmd"
      Cmd="echo \"touch ${job_cont}.done\" >> ${job_cont}"
      echo "$Cmd"
      Cmd="cat ${job_cont}"
      echo "echo \"*** ${job_cont} ***\""
      echo "$Cmd"
      echo "echo \"******\""
      Cmd="cd $AppoDir"
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      Cmd="bsub $SubPars < ${job_cont}"
      echo "echo \"$Cmd\" "
      echo "$Cmd"
      Cmd="echo \"wait the end of job...\""
      echo "$Cmd"
      Cmd="while [ ! -f ${job_cont}.done ]; do"
      echo "$Cmd"
      Cmd="   sleep 60"
      echo "$Cmd"
      Cmd="done"
      echo "$Cmd"

      echo
   fi


   done

echo   

Cmd="date -u > ${OutDir}/done.txt"
echo "echo \"$Cmd\" "
echo "$Cmd"

#Cmd="rm -f $AppoDir/*"
#echo "echo \"$Cmd\" "
#echo "$Cmd"
#Cmd="rmdir $AppoDir"
#echo "echo \"$Cmd\" "
#echo "$Cmd"
#Cmd="rm -f $WorkDir/*"
#echo "echo \"$Cmd\" "
#echo "$Cmd"
#Cmd="rmdir $WorkDir"
#echo "echo \"$Cmd\" "
#echo "$Cmd"



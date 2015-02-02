#!/bin/sh

. `dirname $0`/envi.sh

PackSection=$1
DescrFile=$2
ProcDay=$3
LineNumber=$4

PackDir=$PackSpace/$PackSection
echo PackDir= $PackDir
if [ ! -d $PackDir ]; then
   mkdir `dirname $PackDir`
   mkdir $PackDir
   fi

Prot=`sh $DescrFile prot`

UpDown="download"
UpDownFile=`echo $DescrFile | cut -d . -f 2`
if [ $UpDownFile == "upload" ]; then
   UpDown="upload"
   fi

PackFile=$PackDir/pack_${Prot}_${UpDown}_${ProcDay}_${LineNumber}

if [ ! -f $PackFile ]; then

   Cmd="sh $DescrFile list $ProcDay $LineNumber > $PackFile"
   echo "$Cmd"
   eval $Cmd

   Cmd="sh $DescrFile netcfg > ${PackFile}.net"
   echo "$Cmd"
   eval $Cmd

   Cmd="chmod og-r ${PackFile}.net"
   echo "$Cmd"
   eval $Cmd

   Cmd="sh $DescrFile hstart ${ProcDay} > ${PackFile}.tstart"
   echo "$Cmd"
   eval $Cmd

   Cmd="sh $DescrFile dest $ProcDay $LineNumber > ${PackFile}.bk_destdir"
   echo "$Cmd"
   eval $Cmd

   Cmd="sh $DescrFile clean $ProcDay $LineNumber > ${PackFile}.clean"
   echo "$Cmd"
   eval $Cmd 

   fi


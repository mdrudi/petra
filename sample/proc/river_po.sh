#!/bin/sh

InDir=$1
WorkDir=$2
#LogDir=$3
OutDir=$4

ProcDay=`ls -1 $InDir/procday.*`
ProcDay=`basename $ProcDay | cut -d . -f 2`

Cmd="cp -p $InDir/ingv2.txt $OutDir/${ProcDay}-ingv2.txt"
echo "$Cmd"
eval $Cmd


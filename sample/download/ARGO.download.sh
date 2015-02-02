#!/bin/sh

if [ $1 = "list" ]; then
   DayToProcess=$2
   Line=$3
   index_file=`sh $EventMng/event.sh readall :transf.indata_HCMRIndex_${DayToProcess}`
   ActualDay=`${petra_aux}/jday.py $DayToProcess -$Line`
   echo `grep PR_PF.........${ActualDay} ${index_file}  | cut -d , -f2 | cut -d / -f4- | sort | uniq`
   fi

if [ $1 = "dest" ]; then
   DayCycle=$2
   Line=$3
   ActualDay=`${petra_aux}/jday.py $DayCycle -$Line`
   echo /home/`whoami`/transf.indata/ARGO/${ActualDay}
   fi

if [ $1 = "hstart" ]; then
   echo ${2}0025
   fi

if [ $1 = "netcfg" ]; then
   echo host medinsitu.hcmr.gr 
   echo user XXXXXXX 
   echo pass XXXXXXX
   fi

if [ $1 = "prot" ]; then
   echo ftp
   fi

if [ $1 = "list_wait_for_event" ]; then
   DayToProcess=$2
   echo transf.indata_HCMRIndex_${DayToProcess}
   echo transf.indata_HCMRIndex_${DayToProcess}
   echo transf.indata_HCMRIndex_${DayToProcess}
   fi


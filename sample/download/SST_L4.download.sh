#!/bin/sh

if [ $1 = "list" ]; then

   today=$2

#   for i in -7 -6 -5 -4 -3 -2 -1 0 ; do
#      dmy=`jday.py $today $i`
      dmy=$today
      #NRT
      yy=`echo $dmy | cut -c"1-4"`
      mm=`echo $dmy | cut -b"5-6"`
      dd=`echo $dmy | cut -b"7-8"`
      DownloadDirNRT=SST_MED_SST_L4_NRT_OBSERVATIONS_010_004_a/$yy/$mm
      ## SST Near Real Time
      echo ${DownloadDirNRT}/${dmy}000000-GOS-L4_GHRSST-SSTfnd-OISST_HR_NRT-MED-v02.0-fv02.0.nc
#      done

   fi

if [ $1 = "dest" ]; then
   echo /home/`whoami`/transf.indata/MFS_INDATA/SST_L4
   fi

if [ $1 = "hstart" ]; then
   echo ${2}0025
   fi

if [ $1 = "netcfg" ]; then
   echo host myocean.artov.isac.cnr.it
   echo user XXXXXXXX
   echo pass XXXXXXXXX
   fi

if [ $1 = "prot" ]; then
   echo ftp
   fi

if [ $1 = "rolloff" ]; then
   echo 20
   fi

if [ $1 = "rolloff_dest" ]; then
   echo /home/`whoami`/transf.indata/MFS_INDATA/SST_L4/"*"
   fi



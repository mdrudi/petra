#!/bin/sh

if [ $1 = "list_wait_for_event" ]; then
   ProcDay=$2
   echo transf.indata_PO_${ProcDay}
#   echo transf.indata_PO1
   fi

if [ $1 = "outdir" ]; then
   echo /home/`whoami`/transf.indata/MFS_INDATA/RIVER_PO/
   fi

if [ $1 = "rolloff" ]; then
   echo 3
   fi

if [ $1 = "rolloff_dest" ]; then
   echo /home/`whoami`/transf.indata/MFS_INDATA/RIVER_PO/"*"
   fi

if [ $1 = "proc" ]; then
   a=`dirname $0`/`basename $0 | cut -d . -f 1`.sh 
   echo $a
   fi

if [ $1 = "template_out" ]; then
   ProcDay=$2
   echo ${ProcDay}-ingv2.txt
   fi

if [ $1 = "event_body" ]; then
   ProcDay=$2
   echo `sh $0 outdir`/${ProcDay}-ingv2.txt
   fi

#if [ $1 = "generate_event" ]; then
#   ProcDay=$2
#   event_id=proc_river_po_${ProcDay}
#   echo
#   sh ${EventMng}/event.sh prepare :$event_id
#   if [ $? -eq 1 ]; then
#      sh ${EventMng}/event.sh appendmsg :$event_id `sh $0 outdir`/${ProcDay}-ingv2.txt
#      sh ${EventMng}/event.sh activation :$event_id
#      fi
#   fi

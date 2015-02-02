

if [ $1 = "to_be_done" ]; then
   exit 1
   fi

if [ $1 = "event_to_check" ]; then
   ProcDay=$2
   echo PO_READY2-${ProcDay}
   fi

if [ $1 = "output_file" ]; then
   ProcDay=$2
   echo /home/`whoami`/workdir/event2file/po_ready-${ProcDay}
   fi


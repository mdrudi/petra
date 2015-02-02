#!/bin/sh

if [ $1 = "wait_for_events" ]; then
   ProcDay=$2
   echo river_po-${ProcDay}-0
fi

if [ $1 = "generate_events" ]; then
   ProcDay=$2
   event_id_in=`sh $0 wait_for_events $ProcDay`
   event_id_out=PO_READY2-$ProcDay
   sh ${EventMng}/event.sh prepare :$event_id_out
   for line in `sh ${EventMng}/event.sh readall :$event_id_in`; do
      new_line=`echo $line | cut -d / -f3-`
      sh ${EventMng}/event.sh appendmsg :$event_id_out $new_line
   done
   sh ${EventMng}/event.sh activation :$event_id_out
fi


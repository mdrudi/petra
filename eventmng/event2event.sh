. `dirname $0`/envi.sh

Descr=$1
ProcDay=$2

event_id_base=${ComponentName}-e2e-`basename $Descr|cut -d. -f1`-${ProcDay}-
event_id_start=${event_id_base}start

#sh $Descr already_done $ProcDay
`dirname $0`/event.sh check :${event_id_start}
if [ $? -eq 1 ]; then
   echo already started = $Descr
   exit
   fi

non_trovato=0
for event_id in `sh $Descr wait_for_events $ProcDay`; do
   `dirname $0`/event.sh check :$event_id
   if [ $? -eq 0 ]; then
      non_trovato=1
      fi
   done

if [ $non_trovato -eq 0 ]; then
   echo All input events are available
   `dirname $0`/event.sh set :${event_id_start}
   sh $Descr generate_events $ProcDay $event_id_base
   fi


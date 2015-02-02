. `dirname $0`/envi.sh

ListGenerator=$1
ProcDay=$2

sh $ListGenerator to_be_done $ProcDay
if [ $? -eq 0 ]; then
   echo not to be done = $ListGenerator
   exit
   fi

event_id=${ComponentName}-f2e-`basename $1 | cut -d. -f1`-${ProcDay}-start
`dirname $0`/event.sh check :$event_id
if [ $? -ne 0 ]; then
   echo already done = $event_id
   exit
   fi

non_trovato=0
for file in `sh $ListGenerator list $ProcDay`; do
   echo check $file
   if [ ! -f $file ]; then
      echo ___still missing $file
      non_trovato=1
      fi
   done

if [ $non_trovato -eq 0 ]; then
   echo
   `dirname $0`/event.sh prepare :$event_id
   if [ $? -eq 1 ]; then
      for file_tr in `sh $ListGenerator list $ProcDay`; do
         `dirname $0`/event.sh appendmsg :$event_id "$file_tr"
         done
      `dirname $0`/event.sh activation :$event_id
      fi
   fi


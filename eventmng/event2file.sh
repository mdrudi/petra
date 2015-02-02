. `dirname $0`/envi.sh

HDescr=$1
ProcDay=$2

sh $HDescr to_be_done $ProcDay
if [ $? -eq 0 ]; then
   echo not to be done = $HDescr
   exit
fi

event_id=${ComponentName}-e2f-`basename $1 | cut -d. -f1`-${ProcDay}-start
`dirname $0`/event.sh check :$event_id
if [ $? -ne 0 ]; then
   echo already done = $event_id
   exit
fi

event_to_check=`sh $HDescr event_to_check $ProcDay`
`dirname $0`/event.sh check :$event_to_check
if [ $? -ne 0 ]; then
   echo Found $event_to_check ...
   output_file=`sh $HDescr output_file $ProcDay`
   if [ -f $output_file ]; then
      Cmd="rm -f $output_file"
      echo $Cmd
      eval $Cmd
   fi
   `dirname $0`/event.sh prepare :$event_id
   if [ $? -eq 1 ]; then
      EventDir=`dirname $0`
      for file_tr in `${EventDir}/event.sh readall :$event_to_check`  ;do
         `dirname $0`/event.sh appendmsg :$event_id "$file_tr"
         echo $file_tr >> `dirname $output_file`/.tmp.`basename $output_file`
      done
   Cmd="mv `dirname $output_file`/.tmp.`basename $output_file` $output_file"
   echo $Cmd
   eval $Cmd
   `dirname $0`/event.sh activation :$event_id
   fi
fi



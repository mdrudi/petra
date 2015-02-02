if [ $1 = "list_in_event" ]; then
   ProcDay=$2
   echo scheduler-MFS_SYS4C_CORE_1-${ProcDay}-0-done
fi

if [ $1 = "list_out_event" ]; then
   ProcDay=$2
   Line=$3
   echo event_ID_in_log
fi
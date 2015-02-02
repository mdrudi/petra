
if [ $1 = "list_wait_for_event" ]; then
   ProcDay=$2
   echo scheduler-MFS_SYS4C_CORE_1-${ProcDay}-0-done
fi

if [ $1 = "checktime" ]; then
   ProcDay=$2
   Line=$3
   echo ${ProcDay}0110
fi

if [ $1 = "list_emails" ]; then
   echo massimiliano.drudi@bo.ingv.it,drudi@bo.ingv.it
fi

if [ $1 = "event_name_fail" ]; then   #optional method
   echo event_ID_in_email_notification-tlfail
fi


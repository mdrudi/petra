
#if [ $1 = "list_wait_for_event" ]; then
#   ProcDay=$2
#   echo scheduler-MFS_SYS4C_CORE_1-${ProcDay}-0-done
#fi

if [ $1 = "systemproc" ]; then
#   ProcDay=$2

   diskspace=`du -ks ~ | cut -f1`
   if [ $diskspace -gt 100000 ]; then
      # in caso di piu' check che possono fallire, il testo deve essere generato alla fine prima di fare exit 1 (viene usata solo la prima linea)
      echo "Error in Home dir" > $MNMonitBlackBoard 
      exit 1
   fi
   exit 0

fi


if [ $1 = "list_emails" ]; then
   echo massimiliano.drudi@bo.ingv.it,drudi@bo.ingv.it
fi


if [ $1 = "event_name_fail" ]; then   #optional method
   echo event_ID_in_email_notification-xxfail
fi

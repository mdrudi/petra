. `dirname $0`/envi.sh

. ${petra_aux}/CompetitionControl-r05.sh
CompetitionControl $TILogDir

TimeStamp=`now-YYYYMMDDHHMMSS.sh`

LogFile=$TILogDir/`basename $0`-${TimeStamp}-$$.log
#echo $LogFile
exec 1> $LogFile  2>&1

bash ${FileTransfer}/proc_tstart.sh ${TIComponentName}

bash ${FileTransfer}/ftp_download.sh ${TIComponentName} ${TIComponentName} 
bash ${FileTransfer}/http_download.sh ${TIComponentName} ${TIComponentName} 
bash ${FileTransfer}/subsetter_download.sh ${TIComponentName} ${TIComponentName}
bash ${FileTransfer}/ftp_upload.sh ${TIComponentName} ${TIComponentName}
bash ${FileTransfer}/ftpXXXX_upload.sh ${TIComponentName} ${TIComponentName}

for file_complete in `bash ${FileTransfer}/list_complete.sh ${TIComponentName}`; do
   procday=`bash ${FileTransfer}/wrap_get.sh procday $file_complete`
   line=`bash ${FileTransfer}/wrap_get.sh line $file_complete`
   data_type=`dirname $file_complete`
   data_type=`basename $data_type`
   event_id=${TIComponentName}-${data_type}-${procday}-${line}-done
   echo
   ${EventMng}/event.sh prepare :$event_id
   if [ $? -eq 1 ]; then
      for file_tr in `bash ${FileTransfer}/wrap_get.sh listfile $file_complete`; do
         ${EventMng}/event.sh appendmsg :$event_id "$file_tr"
         done
      ${EventMng}/event.sh activation :$event_id
      fi
   done



LogMessage (){
   echo `date` -$1 >> ${LOGFile}
   }

RolMessage (){
   echo `date` -$1 >> ${ROLFile}
   }

. `dirname $0`/envi.sh
PackSection=${PackSpace}/$1
today=`date +%Y%m%d`
Channel=$2   #used to have more active proces, but no more than one for channel

echo
echo `date -u` - START $0

PIDFILE=${PackSpace}/`basename $0`_channel$2.pid
if [ -f $PIDFILE ]; then
   pid=`cat $PIDFILE`
   echo Last PID $pid
   echo Actual PID $$
   else
   pid=XXXXXX
   fi
ps -fu ${locUser} | grep `basename $0` | grep $pid 1> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo `basename $0` : script already running pid $pid...
   ps -fA | grep $pid
   exit
   fi
echo $$ > $PIDFILE


for filelist in `find $PackSection -name "pack_ftp_upload_*" -print | sort`; do

   DestContainer=${filelist}.destdir
   CompleteFlag=${filelist}.complete
   FiletoRemove=${filelist}.clean

   if [ -f ${DestContainer} -a ! -f ${CompleteFlag} ]; then

      TOKFile=${filelist}.TRANSFER_OK.txt
      LOGFile=${filelist}.log.txt
      ROLFile=${filelist}.rol.txt

      #UPLOAD PARAMETER
      destdir=`cat ${DestContainer}`
      cfgfile=${filelist}.net
      if [ ! -f $cfgfile ]; then
         LogMessage "TRANSFER_ERROR : cfgfile not available"
      else
         desthost=`cat ${cfgfile} | grep host | awk '{print $2}'`

         complete_flag=1

         for file in `cat $filelist`; do
            if [ ! -f $file ]; then
               RolMessage "TRANSFER_WARNING local file absent: $file"
               complete_flag=0
               else
               grep _${file}_ ${TOKFile} 1> /dev/null 2>&1
               if [ $? -eq 0 ]; then
                  RolMessage "TRANSFER_WARNING file marked as already uploaded : $file"
                  else
                  filename=`basename $file`
                  buff_line=`ncftpls -f $cfgfile -l -a -o useCLNT=0,useFEAT=0 ftp://${desthost}/${destdir}/$filename`
                  dim_remote=`echo $buff_line | awk '{print $5}'`
                  dim_local=`ls -l $file | awk '{print $5}'`
                  if [ _$dim_remote == _$dim_local ]; then
                     echo _${file}_ >> ${TOKFile}
                     RolMessage "TRANSFER_WARNING file seems already uploaded : $file $dim_local $dim_remote"
                     else
                     LogMessage "TRANSFER_ONGOING : $file $dim_local $dim_remote"
                     RolMessage "TRANSFER_ONGOING : $file $dim_local $dim_remote"
                    ### ncftpput -f $cfgfile -T .upl. -z -m -V -U 022 -y -o useCLNT=0,useFEAT=0 ${destdir}/ $file
                     ncftpput -f $cfgfile -T .upl. -z -m -V -y -o useCLNT=0,useFEAT=0 ${destdir}/ $file
                     ncres=$? 
                     if [ $ncres -ne 0 ]; then
                        LogMessage "TRANSFER_ERROR code $ncres transfering $file"
                        RolMessage "TRANSFER_ERROR code $ncres transfering $file"
                        complete_flag=0
                        else
                        buff_line=`ncftpls -f $cfgfile -l -a -o useCLNT=0,useFEAT=0 ftp://${desthost}/${destdir}/$filename`
                        dim_remote=`echo $buff_line | awk '{print $5}'`
                        dim_local=`ls -l $file | awk '{print $5}'`
                        if [ _$dim_remote == _$dim_local ]; then
                           echo _${file}_ >> $TOKFile
                           LogMessage "TRANSFER_OK : for $file $dim_local $dim_remote"
                           RolMessage "TRANSFER_OK : for $file $dim_local $dim_remote" 
                        else
                           LogMessage "TRANSFER_ERROR for $file $dim_local $dim_remote"
                           RolMessage "TRANSFER_ERROR for $file $dim_local $dim_remote"
                           complete_flag=0
                        fi
                     fi
                  fi
               fi
            fi
         done
         if [ $complete_flag -eq 1 ]; then
            LogMessage "REMOVING OLD FILES : $FiletoRemove"
            RolMessage "REMOVING OLD FILES : $FiletoRemove"
            python `dirname $0`/RemoteFTPCleaning.py $FiletoRemove $cfgfile >> ${LOGFile}    
            if [ $? -eq 0 ] ; then
                date -u >> $CompleteFlag
             fi
         fi
      fi
   fi
done

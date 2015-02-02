
LogMessage (){
   echo `date` -$1 >> ${LOGFile}
   }

RolMessage (){
   echo `date` -$1 >> ${ROLFile}
   }

. `dirname $0`/envi.sh
#locUser=`whoami`
#PackSpace=/mnt/nfs0/tmp/${locUser}
PackSection=${PackSpace}/$1
today=`date +%Y%m%d`
Channel=$2   #used to have more active proces, but no more than one for channel

#LogFile=$TmpDir/`basename $0`.${today}.log
#exec 1> $LogFile  2>&1

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

for filelist in `find $PackSection -name "pack_http_download_*" -print | sort`; do

   DestContainer=${filelist}.destdir
   CompleteFlag=${filelist}.complete

   if [ -f ${DestContainer} -a ! -f ${CompleteFlag} ]; then
#      MapDir=`dirname $filelist`
      TOKFile=${filelist}.TRANSFER_OK.txt
      LOGFile=${filelist}.log.txt
      ROLFile=${filelist}.rol.txt
#      echo > $ROLFile

      #DOWNLOAD PARAMETER
      destdir=`cat ${DestContainer}`
      cfgfile=${filelist}.net
      if [ ! -d $destdir -o ! -f $cfgfile ]; then  
         if [ ! -d $destdir ]; then
            LogMessage "TRANSFER_ERROR : destdir not available - $destdir"
            fi
         if [ ! -f $cfgfile ]; then
            LogMessage "TRANSFER_ERROR : cfgfile not available"
            fi
         else
         desthost=`cat ${cfgfile} | grep host | awk '{print $2}'`
         destuser=`cat ${cfgfile} | grep user | awk '{print $2}'`
         destpass=`cat ${cfgfile} | grep pass | awk '{print $2}'`
         complete_flag=1

         for file in `cat $filelist`; do
            grep _${file}_ ${TOKFile} 1> /dev/null 2>&1
            if [ $? -eq 0 ]; then
               RolMessage "TRANSFER_WARNING file marked as already downloaded : $file"
               else
               filename=`basename $file`
#               buff_line=`ncftpls -f $cfgfile -l -o useCLNT=0,useFEAT=0 ftp://${desthost}/$file`
#               buff_line_filename=`echo $buff_line | awk '{print $9}'`
#               buff_line_dim=`echo $buff_line | awk '{print $5}'`
#               if [ "$buff_line_filename" != "$filename" ]; then
#                  RolMessage "TRANSFER_WARNING remote file not yet available: $file"
#                  complete_flag=0
#                  else
#                  dim_remote=$buff_line_dim
#                  if [ -f $destdir/$filename ]; then
#                     dim_local=`ls -l $destdir/$filename | awk '{print $5}'`
#                     else
#                     dim_local=no
#                     fi
 #                 if [ _$dim_remote = _$dim_local ]; then
 #                    echo _${file}_ >> ${TOKFile}
 #                    RolMessage "TRANSFER_WARNING file seems already downloaded : $file $dim_local $dim_remote"
 #                    else
                     LogMessage "TRANSFER_ONGOING : $file"
                     RolMessage "TRANSFER_ONGOING : $file"
                     wget -c -nv --tries=3 --http-user=$destuser --http-passwd=$destpass ${desthost}${file} -P $destdir 
                     ncres=$? 
                     if [ $ncres -ne 0 ]; then
                        LogMessage "TRANSFER_ERROR code $ncres transfering $file"
                        RolMessage "TRANSFER_ERROR code $ncres transfering $file"
                        complete_flag=0
                        else
 #                      buff_line=`ncftpls -f $cfgfile -l -o useCLNT=0,useFEAT=0 ftp://${desthost}/$file`
  #                      dim_remote=`echo $buff_line | awk '{print $5}'`
  #                      dim_local=`ls -l $destdir/$filename | awk '{print $5}'`
  #                      if [ _$dim_remote = _$dim_local ]; then
                           echo _${file}_ >> $TOKFile
                           LogMessage "TRANSFER_OK : for $file $dim_local $dim_remote"
                           RolMessage "TRANSFER_OK : for $file $dim_local $dim_remote"
#                           else
#                           complete_flag=0
#                           fi
                        fi
#                     fi
                  fi
#               fi
            done
         if [ $complete_flag -eq 1 ]; then
            date -u >> $CompleteFlag
            fi
         fi
      fi
   done



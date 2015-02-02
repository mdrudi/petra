
LogMessage (){
   echo `date` -$1 >> ${LOGFile}
   }

RolMessage (){
   echo `date` -$1 >> ${ROLFile}
   }

. `dirname $0`/envi.sh
#locUser=`whoami`
#############################
# Change the PathMotuClient #
#############################
#PathMotuClient=`dirname $0/../motu-client-python-1.0.2/src/python/
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

for filelist in `find $PackSection -name "pack_subsetter_download_*" -print | sort`; do

   DestContainer=${filelist}.destdir
   CompleteFlag=${filelist}.complete

   if [ -f ${DestContainer} -a ! -f ${CompleteFlag} ]; then
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
         desthost=`cat ${cfgfile} | grep motu | awk '{print $2}'`
#         destserv=`cat ${cfgfile} | grep srvt | awk '{print $2}'`
#         destdata=`cat ${cfgfile} | grep dtst | awk '{print $2}'`
         destuser=`cat ${cfgfile} | grep user | awk '{print $2}'`
         destpass=`cat ${cfgfile} | grep pass | awk '{print $2}'`
#         destname=`cat ${cfgfile} | grep name | awk '{print $2}'` 
         complete_flag=1
         #for file in `cat $filelist`; do
         counter=1
         numline=`wc -l $filelist| cut -d" " -f 1`
         while [ $counter -le $numline ]; do
            line=`head -$counter $filelist | tail -1`
            file=`echo $line | cut -d , -f 2`
            param=`echo $line | cut -d , -f 1`

            grep _${file}_ ${TOKFile} 1> /dev/null 2>&1
            if [ $? -eq 0 ]; then
               RolMessage "TRANSFER_WARNING file marked as already downloaded : $file"
               else
               filename=`basename $file`
               LogMessage "TRANSFER_ONGOING : $file"
               RolMessage "TRANSFER_ONGOING : $file"
               Pupp="-u $destuser -p $destpass -m $desthost"
#               year=`echo $file | cut -c "1-4"`
#               month=`echo $file | cut -c "6-7"`
#               day=`echo $file | cut -c "9-10"`
#               nm=${destname}_${year}${month}${day}_${year}${month}${day}_${today}.zip 
######################################
# Change the name of the output file #
# zip is for SLA data otherwise nc   #
###################################### 
               $MotuClient $Pupp $param -o $destdir 
               ncres=$? 
               if [ $ncres -ne 0 ]; then
                  LogMessage "TRANSFER_ERROR code $ncres transfering $file"
                  RolMessage "TRANSFER_ERROR code $ncres transfering $file"
                  complete_flag=0
                  else
                  echo _${file}_ >> $TOKFile
                  LogMessage "TRANSFER_OK : for $file $dim_local $dim_remote"
                  RolMessage "TRANSFER_OK : for $file $dim_local $dim_remote"
                  fi
               fi
            counter=`expr $counter + 1`
            done
         if [ $complete_flag -eq 1 ]; then
            date -u >> $CompleteFlag
            fi
         fi
      fi
   done



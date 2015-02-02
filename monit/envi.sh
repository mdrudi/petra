. `dirname $0`/../envi.sh

if [ ! -d $MNLogDir ]; then
   mkdir $MNLogDir
   if [ $? -eq 1 ]; then
      echo Failed mkdir $MNLogDir
      exit
   fi
fi

YYYYMM=`today.sh | cut -c 1-6` 
MNCheckPeriod=3600                                                          #Concerns email notification and further update in MNMonitLogFile
MNCheckNumber=24                                                            #Concerns email notification and further update in MNMonitLogFile
MNMonitLogFile=${MNLogDir}/${PETRAComponentName}.log.${YYYYMM}              #reports all negative results from checksystem, and initial and final time concerning fail from checkevent
MNMonitBlackBoard=${MNLogDir}/blackboard.txt;export MNMonitBlackBoard

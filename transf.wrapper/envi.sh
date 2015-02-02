. `dirname $0`/../envi.sh

if [ ! -d $FTLogDir ]; then
   mkdir $FTLogDir
   if [ $? -eq 1 ]; then
      echo Failed mkdir $FTLogDir
      exit
   fi
fi

export locUser;locUser=`whoami`  #do not change
PackSpace=$FTLogDir

export MotuClient;MotuClient=motu-client.py    #`dirname $0`/../motu-client-python-1.0.2/src/python/motu-client.py

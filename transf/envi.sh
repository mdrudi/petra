. `dirname $0`/../envi.sh

if [ ! -d $TILogDir ]; then
   mkdir $TILogDir
   if [ $? -eq 1 ]; then
      echo Failed mkdir $TILogDir
      exit
   fi
fi

export EventMng    #ATTENZIONE serve perche descrittori usano event.sh BUG

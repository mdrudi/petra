CompetitionControl () {

   LogDir=$1

   echo
   echo "****Start Competition Control *** Script Name: $0"
   echo Actual Pid: $$
   echo

   ccPID=$LogDir/`basename $0`.pid

   if [ ! -f $ccPID ]; then

      echo $ccPID not found
      echo
      echo Writing Pid $$ in $ccPID 
      echo $$ > $ccPID
      echo

      else

      echo $ccPID exist
      LastPid=`cat $ccPID`   
      if [ a$LastPid = a ]; then
         echo
         echo WARNING Pid file was empty...recovering the state and writing Pid $$ in $ccPID
         echo $$ > $ccPID
         echo
         LastPid=0
      fi
      echo Last Pid: $LastPid
      echo

      echo Looking for a Matching Process...
      #bn=`basename $0`
      HypPid=a`ps ax | grep $0 | grep $LastPid | awk '{print \$1}' `
      #ps ax | grep $LastPid
      #LEC=$?
      LEC=1
      if [ $HypPid = a$LastPid ]; then 
         LEC=0
      fi 
      echo "Last Exit Code (by grep): $LEC"
      echo 

      if [ $LEC -eq 0 ]; then
         echo "Pid $LastPid is still runnig...aborting Pid $$"
         echo
         exit 1
      else
         echo "Pid $LastPid not found...Writing Pid $$ in $ccPID"
         echo $$ > $ccPID
         TestPID=`cat $ccPID`
         if [ ! a$TestPID = a$$ ]; then
            echo
            echo ERROR Writing problem in $ccPID  ...aborting
            echo
            exit 1
         fi
      fi

   fi
   echo
   echo "****End Competition Control *** Script Name: $0"
   echo
   }


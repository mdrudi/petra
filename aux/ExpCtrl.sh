ExpDescr=$1
Command=$2


echo Checking if it exists
if [ -f $ExpDescr ]; then
   echo Found Descriptor $ExpDescr
   . $ExpDescr
   ExpDir=$ScratchDir/`basename $ExpDescr`

   if [ _$Command = _'create' ]; then
      if [ -d $ExpDir ]; then echo Experiment already exists; exit 1; fi
      Cmd="ExpBuild.sh $ExpDescr"
      echo $Cmd
      eval $Cmd
   elif [ -d $ExpDir ]; then

      echo Found Experiment $ExpDir 

      if [ _$Command = _'kill' ]; then
         Cmd="ps -fu"
         echo $Cmd
         eval $Cmd
         Cmd="kill -9 "`cat $ExpDir/pid`
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'bkill' ]; then
         Cmd="bjobs"
         echo $Cmd
         eval $Cmd
         Cmd="bkill "`cat $ExpDir/model/index_P*.jobid`
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'pause' ]; then
         Cmd="touch $ExpDir/pause"
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'resume' ]; then
         Cmd="rm $ExpDir/pause"
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'remove' ]; then
         Cmd="rm -Rf $ExpDir"
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'start' ]; then
         Cmd="sh $ExpDir/tmp/"`basename $ExpDescr`.sh
         echo $Cmd
         eval $Cmd
      elif [ _$Command = _'cd' ]; then
         Cmd="cd $ExpDir"
         echo $Cmd
         eval $Cmd
         echo Opening new sessione...
         bash --norc
      else
         echo Wrong Command
         exit 1
      fi
   fi
fi


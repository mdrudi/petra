#!/bin/bash
. `dirname $0`/envi.sh > /dev/null

EventSpace=$EVEventSpace

Command=$1
EventOwnerID=$2
EventBody=$3

GetEventFile() {
   gef_eID=$1
#echo hhh
   #ls -1 $EventSpace/$eOwner/* | grep _${gef_eID}_
   find $EventSpace/$eOwner -name "*_${gef_eID}_" | tail -1
}

eOwnerSetCheck() {
   if [ _$eOwner = "_" ]; then
      eOwner=`whoami`
      fi
   
   if [ ! -d $EventSpace/$eOwner ]; then
      mkdir $EventSpace/$eOwner 2> /dev/null
      if [ ! -d $EventSpace/$eOwner ]; then
         echo Event Space Not Available : $EventSpace/$eOwner - ERROR
         exit 0
      fi
   fi
}


if [ $Command = "prepare" ]; then
   $0 check ${EventOwnerID} > /dev/null
   if [ $? -eq 1 ]; then
      echo Event Already Exist : no action - ${EventOwnerID}  - WARNING
      exit 0
      else
      $0 set ${EventOwnerID}tmp 
      if [ $? -eq 1 ]; then
         exit 1
         else
         exit 0
         fi
      fi
   fi


if [ $Command == "activation" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi

   $0 set ${EventOwnerID} `GetEventFile ${eID}tmp`
   if [ $? -eq 1 ]; then
      rm -f `GetEventFile ${eID}tmp` 
      fi
   fi


if [ $Command == "set" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi
   
   echo Event Setting ${eOwner}:${eID}   - `date +%Y%m%d-%H%M%S` 

   #if [ ! -d $EventSpace/$eOwner ]; then
   #   echo Event Space Not Available : $EventSpace/$eOwner - ERROR
   #   exit 0
   #   fi

   $0 check ${eOwner}:${eID} > /dev/null
   if [ $? -eq 1 ]; then
      echo Event Already Exist : no action - ${EventOwnerID} - WARNING
      exit 0
      else
      NewFileEvent=$EventSpace/$eOwner/`date +%Y%m%d%H%M%S`_${eID}_
      #date -u > $NewFileEvent
      if [ _${EventBody} != _ ] && [ -f $EventBody ]; then
         cat $EventBody >> $NewFileEvent
         else
         date -u > $NewFileEvent
         fi
      exit 1
      fi
   fi


if [ $Command == "appendmsg" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi

   echo Event Append Msg ${eOwner}:${eID}tmp  \"$EventBody\" - `date +%Y%m%d-%H%M%S`

   #if [ ! -d $EventSpace/$eOwner ]; then
   #   echo Event Space Not Available : $EventSpace/$eOwner - ERROR
   #   exit 0
   #   fi

   $0 check ${eOwner}:${eID}tmp > /dev/null
   if [ $? -eq 1 ]; then
      searchresult=`GetEventFile ${eID}tmp` #`ls -1 $EventSpace/$eOwner/* | grep _${eID}_ | tail -1`
      echo $EventBody >> $searchresult
      exit 1
      else
      echo Event Append Msg : fails, no event to access - ${EventOwnerID}tmp  - ERROR
      exit 0 
      fi
   fi


if [ $Command == "readall" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck > /dev/null
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi

   #echo Event Read All Msg ${eOwner}:${eID}  \"$EventBody\" - `date +%Y%m%d-%H%M%S`

   #if [ ! -d $EventSpace/$eOwner ]; then
   #   #echo Event Space Not Available : $EventSpace/$eOwner - ERROR
   #   exit 0
   #   fi

   if [ ${eID} == "TRUE" ]; then
      exit 1   #the special event TRUE is empty
      fi

   $0 check ${eOwner}:${eID} > /dev/null
   if [ $? -eq 1 ]; then
      searchresult=`GetEventFile ${eID}`
      nline=`cat $searchresult | wc -l`
      cline=2
#      list=""
      while [ $cline -le $nline ]; do
         #list="$list "`
         head  -$cline $searchresult | tail -1
         cline=`expr $cline + 1 `
         done
#      echo $list
      exit 1
   else
#      echo Event Read All Msg : fails, no event to access - ${EventOwnerID} - ERROR
      exit 0
   fi
fi
  
 
if [ $Command == "wait" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi

   echo Event Waiting ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`

   #if [ ! -d $EventSpace/$eOwner ]; then
   #   echo Event Space Not Available : $EventSpace/$eOwner - ERROR
   #   exit 0
   #   fi


   Continua="no"
   $0 check ${eOwner}:${eID} > /dev/null
   if [ $? -eq 1 ]; then
      Continua="si"
      fi
   
   while [ "$Continua" == "no" ] ; do
      echo Event Waiting ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`
      sleep 600

      $0 check ${eOwner}:${eID} > /dev/null
      if [ $? -eq 1 ]; then
         Continua="si"
         fi
      done

   echo Event Found ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`
   exit 1
   fi



if [ $Command == "check" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck
   #if [ _$eOwner = "_" ]; then
   #   eOwner=`whoami`
   #   fi

   #if [ ! -d $EventSpace/$eOwner ]; then
   #   echo Event Space Not Available : $EventSpace/$eOwner - ERROR
   #   exit 0
   #   fi

   if [ ${eID} == "TRUE" ]; then
      echo Event Found ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`
      exit 1
      fi

   searchresult=`GetEventFile ${eID}` #`ls -1 $EventSpace/$eOwner/ | grep _${eID}_ `
   if [  _$searchresult != "_" ]; then
      echo Event Found ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`
      exit 1
      else
      echo Event Not Found ${eOwner}:${eID}  - `date +%Y%m%d-%H%M%S`
      exit 0
      fi
   fi
   


if [ $Command == "gettimestamp" ]; then
   eOwner=`echo $EventOwnerID | cut -d : -f 1`
   eID=`echo $EventOwnerID | cut -d : -f 2`

   eOwnerSetCheck > /dev/null

   if [ ${eID} == "TRUE" ]; then
      exit 1   #the special event TRUE is empty
      fi

   $0 check ${eOwner}:${eID} > /dev/null
   if [ $? -eq 1 ]; then
      searchresult=`GetEventFile ${eID}`
      basename $searchresult | cut -d_ -f1
      exit 1
      else
#      echo Event Read All Msg : fails, no event to access - ${EventOwnerID} - ERROR
      exit 0
      fi

   fi

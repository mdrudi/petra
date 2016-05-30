#!/bin/sh

####################################################################
## This script prepares consecutive simulations
## 
##  Paolo Oddo           paolo.oddo@bo.ingv.it (ex MAKE_SIMU.sh)
##  Massimiliano Drudi   massimiliano.drudi@bo.ingv.it
####################################################################

. `dirname $0`/../envi.sh

cd `dirname $1`
#RunDir=`pwd`
PathDescr=`pwd`/`basename $1`

MyPath=`which $0`
MyDir=`dirname $MyPath`
cd $MyDir

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# parameters import from experiment definition file
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NEMO_NL=empty # bug da sistemare

. ${PathDescr}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# name of the experiment
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

name=`basename ${PathDescr}`

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# structure of the directory
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

WorkingDir="${ScratchDir}/${name}"
#WorkingDirSlash="${ScratchDirSlash}\/${name}"

#LAUNCHINGRUNREPOSITORY="${WorkingDirSlash}\/tmp"
#MODIPSLREPOSITORY="$LAUNCHINGRUNREPOSITORY"
#OUTPUTFILESSTORING="${WorkingDirSlash}\/output"
#EXECUTIONREPOSITORY="${WorkingDirSlash}\/model"
#OUTPUTFILESSTORINGRB="${WorkingDirSlash}\/rebuilt"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# start main loop
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   [ -d $WorkingDir ] || mkdir $WorkingDir
   [ -d $WorkingDir/model ] || mkdir $WorkingDir/model
   [ -d $WorkingDir/output ] || mkdir $WorkingDir/output
   [ -d $WorkingDir/rebuilt ] || mkdir $WorkingDir/rebuilt
   [ -d $WorkingDir/tmp ] || mkdir $WorkingDir/tmp

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# copy outcome from NEMO and WW
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cp -p $PathDescr $WorkingDir/exp-descriptor.sh

PathJday=`which jday.py`
cp -p $PathJday $WorkingDir/tmp/
PathHoursSince=`which hours_since_1970010100.py`
cp -p $PathHoursSince $WorkingDir/tmp/

if [ ! -f $SYS.tocopylist.txt ]; then
      echo `basename $0` - file does not exist : $SYS.tocopylist.txt
      exit 1
fi
IFS=''
while read line ; do
if [ _`echo $line| cut -c1` != "_" -a  _`echo $line| cut -c1` != "_#" ] ; then
  DestFile="."
  if [ _`echo $line |awk '{print $2}'` != '_' ] ; then
      DestFile=`echo $line |awk '{print $2}'`
  fi 
  cmd="cp -p `echo $line |awk '{print $1}'` $WorkingDir/tmp/$DestFile"
  echo $cmd
  eval $cmd
fi
done < $SYS.tocopylist.txt

if [ ! -f $SYS.dimtable.dat ]; then
      echo `basename $0` - file does not exist : $SYS.dimtable.dat
      exit 1
fi

while read col1 ; do
    echo $col1
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col1 |awk '{print $2}'` ;;
#       phys_obc) phys_obc_TEO=`echo $col1 |awk '{print $2}'`  ;;
       wave_rst) wave_rst_TEO=`echo $col1 |awk '{print $2}'`  ;;
       phys_cor) phys_cor_TEO=`echo $col1 |awk '{print $2}'`  ;;
    esac 
done < $SYS.dimtable.dat
echo `dirname $0`/$SYS.dimtable.dat

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# generating the scripts
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

first_time_step=1

check_file()
{
##### CHECK IF EXIST THE FILE #####
if [ -f $1 ]; then
   echo "RESTART OK"
#   touch restart_nemo.ok
   else
   echo "THERE IS NOT THE FILE " $1
#   touch restart_nemo.ko
   exit 1
fi
}
check_dimfile()
{
##### CHECK ON THE RIGHT DIMENSION ##### 
sizeR=`ls -l ${1} | awk '{print $5}'`
if [ "_${sizeR}" != "_${2}" ]; then
   echo "WRONG DIMENSION OF " $1
#   touch restart_nemo.ko
   exit 1
else
   echo "GOOD DIMENSION OF " $1
#   touch restart_nemo.ko
fi
}

if [ $timing_start_from_restart = "file" ]; then
   if [ ! -f $phys_rst ]; then
      echo `basename $0` - file does not exist : $phys_rst
      exit 1
   fi
   check_dimfile $phys_rst $phys_rst_TEO
#   if [ ! -f $phys_obc ]; then
#      echo `basename $0` - file does not exist : $phys_obc
#      exit 1
#   fi
#   check_dimfile $phys_obc $phys_obc_TEO
   restart_kt=`ncdump -v kt $phys_rst | grep "kt =" | cut -d" " -f 4`
   restart_ndastp=`ncdump -v ndastp $phys_rst | grep "ndastp =" | cut -d" " -f 4`
   first_time_step=`expr $restart_kt + 1`
   timing_start_time=$restart_ndastp
   DH=`expr $restart_kt \* $NEMOTimestep \/ 3600`
   timing_start_hour=`jdayhour.py ${timing_start_time}00 +$DH | cut -c9-10`
   #echo first_time_step $first_time_step
   echo *****PARAMETERS FROM RESTART FILE
   #echo restart_kt $restart_kt
   #echo restart_ndastp $restart_ndastp
   echo timing_start_time $timing_start_time
   echo timing_start_hour $timing_start_hour
#   Cmd="cp -p $phys_rst $WorkingDir/output/restart.nc_${timing_start_time}${timing_start_hour}" 
   Cmd="ln -sf $phys_rst $WorkingDir/output/restart.nc_${timing_start_time}${timing_start_hour}" #BUG ?
   echo $Cmd
   eval $Cmd
#   Cmd="cp -p $phys_obc $WorkingDir/output/restart.obc_${timing_start_time}${timing_start_hour}"
#   Cmd="ln -sf $phys_obc $WorkingDir/output/restart.obc_${timing_start_time}${timing_start_hour}" #BUG ?
   echo $Cmd
   eval $Cmd
   if [ ! _$wave_rst = "_" ]; then
      if [ -f $wave_rst ]; then
         check_dimfile $wave_rst $wave_rst_TEO
         Cmd="ln -sf $wave_rst  $WorkingDir/output/restart1.ww3_${timing_start_time}${timing_start_hour}"
         echo $Cmd
         eval $Cmd
      fi
   fi
   if [ ! _$phys_cor = "_" ]; then
      if [ -f $phys_cor ]; then
         check_dimfile $phys_cor $phys_cor_TEO
         Cmd="ln -sf $phys_cor $WorkingDir/output/corr.nc_${timing_start_time}${timing_start_hour}"
         echo $Cmd
         eval $Cmd
      fi
   fi
   echo "*****"
   echo
   fi

timing_start_day_hour=${timing_start_time}${timing_start_hour}
timing_end_day_hour=`jdayhour.py ${timing_start_day_hour} ${timing_hours}`
### timing_end_day='20090101'    # from timing_start_time|timing_start_hour + timing_hours
### timing_end_hours='04'        # from timing_start_time|timing_start_hour + timing_hours

#calcolo time step tra due restart NEMO
steps_per_hours=`expr 3600 \/ $NEMOTimestep`
steps_per_simu=`expr $steps_per_hours \* $timing_restart_hours`
# calcolo ultimo time step NEMO
n_time_step=`expr $first_time_step \- 1 + \( $timing_hours \* $steps_per_hours \)`
 
actual_index=1
actual_time_step=$first_time_step
actual_day_hour=$timing_start_day_hour
nnWriteTag=`expr 86400 \/ $NEMOTimestep`
 
#echo $n_time_step
#echo $timing_end_day_hour
#echo $steps_per_simu

#while [ $actual_time_step -le $n_time_step ]
while [ $actual_day_hour -lt $timing_end_day_hour ]
do

   last_step=`expr $actual_time_step \+ $steps_per_simu \- 1`
   if [ $last_step -gt $n_time_step ]; then
      last_step=$n_time_step;
      fi
   last_day_hour=`jdayhour.py ${actual_day_hour} ${timing_restart_hours}`
   if [ $last_day_hour -gt $timing_end_day_hour ]; then
      last_day_hour=$timing_end_day_hour
      fi

   actual_start_day=`echo $actual_day_hour | cut -c1-8 `
   actual_start_hour=`echo $actual_day_hour | cut -c9-10 `
   actual_end_day=`echo $last_day_hour | cut -c1-8 `
   actual_end_hours=`echo $last_day_hour | cut -c9-10 `

   first_m1=`expr $actual_time_step \- 1`
   last_p1=`expr $last_step \+ 1`




   JobExpOut=$WorkingDir/tmp/Job_EXP_${actual_index}

   sh tmp_template/${JobType}_prefix.sh $nodes $cpn $QueueNameNemo ${name}_${actual_index} $actual_index > ${JobExpOut} 

   echo                                 >> ${JobExpOut}
   echo "WORKINGDIR=${WorkingDir}"      >> ${JobExpOut}
   echo . $WorkingDir/exp-descriptor.sh >> ${JobExpOut}

   echo                            >> ${JobExpOut}
   if [ $actual_time_step -eq 1 ] ; then
      echo incasenotfirst=0        >> ${JobExpOut}
   else
      echo incasenotfirst=1        >> ${JobExpOut}
   fi
   echo ACTUALINDEX=$actual_index  >> ${JobExpOut}
   echo TSD=$actual_start_day      >> ${JobExpOut}
   echo TSH=$actual_start_hour     >> ${JobExpOut}
   echo TED=$actual_end_day        >> ${JobExpOut}
   echo TEH=$actual_end_hours      >> ${JobExpOut}
   if [ _$ProductionCycle = _ ]; then
      echo ProductionCycle=`date -u +%Y%m%d`   >> ${JobExpOut}
   fi
   echo                            >> ${JobExpOut}

   cat tmp_template/Job_EXP_template >> ${JobExpOut}




   JobExpOut=$WorkingDir/tmp/Job_EXP_${actual_index}R

   sh tmp_template/${JobType}_prefix.sh $nodes 1 $QueueNameNemo ${name}_${actual_index}R ${actual_index}R > ${JobExpOut}

   echo                                 >> ${JobExpOut}
   echo "WORKINGDIR=${WorkingDir}"      >> ${JobExpOut}
   echo "TSD=${actual_start_day}"       >> ${JobExpOut}
   echo "TED=${actual_end_day}  "       >> ${JobExpOut}
   echo ACTUALINDEX=$actual_index       >> ${JobExpOut}
   echo                                 >> ${JobExpOut}
   cat tmp_template/Job_EXP_Rtemplate   >> ${JobExpOut}


#   sed -e "s/EXP_NAME/${name}_${actual_time_step}/g" \
#       -e "s/PBSQUEUENAMEREBUILT/$QueueNameRestart/g" \
#       -e "s/NAME/$actual_time_step/g" \
#       -e "s/OUTPUTFILESSTORINGRB/$OUTPUTFILESSTORINGRB/g" \
#       -e "s/OUTPUTFILESSTORING/$OUTPUTFILESSTORING/g" \
#       -e "s/MODIPSLREPOSITORY/$MODIPSLREPOSITORY/g" \
#       tmp_template/Job_rebuilt_template > $WorkingDir/tmp/Job_rebuilt_${actual_index}

   if [ $actual_time_step -eq 1 ] ; then

      if [ $NEMO = "yes" ]; then
         sed -e "s/FIRSTIMESTEP/$actual_time_step/" \
             -e "s/LASTTIMESTEP/$last_step/" \
             -e "s/INITIALCALENDARDATE/$timing_start_time/" \
             -e "s/RST-TRUE-FALSE/false/" \
             -e "s/RST-NUMBER-0-2/0/" \
             -e "s/EXPERIMENT/$name/" \
             -e "s/NTCPUS/$nemo_n_mpi_proc/" \
             -e "s/CLIM-INIT/true/" \
             -e "s/RNRDTTAG/$NEMOTimestep/" \
             -e "s/NNWRITETAG/$nnWriteTag/" \
             -e "s*WORKINGDIR*$WorkingDir*" \
             $NEMO_NL > $WorkingDir/tmp/namelist_${actual_index}
         fi

      else

      if [ $NEMO = "yes" ]; then
         sed -e "s/FIRSTIMESTEP/$actual_time_step/g" \
             -e "s/LASTTIMESTEP/$last_step/g" \
             -e "s/INITIALCALENDARDATE/$timing_start_time/" \
             -e "s/RST-TRUE-FALSE/true/g" \
             -e "s/RST-NUMBER-0-2/2/g" \
             -e "s/EXPERIMENT/$name/" \
             -e "s/NTCPUS/$nemo_n_mpi_proc/" \
             -e "s/CLIM-INIT/false/" \
             -e "s/RNRDTTAG/$NEMOTimestep/" \
             -e "s/NNWRITETAG/$nnWriteTag/" \
             -e "s*WORKINGDIR*$WorkingDir*" \
             $NEMO_NL > $WorkingDir/tmp/namelist_${actual_index}
         fi

   fi


actual_index=`expr $actual_index + 1`
actual_time_step=`expr $actual_time_step \+ $steps_per_simu `
actual_day_hour=`jdayhour.py ${actual_day_hour} ${timing_restart_hours}`

done


sed -e "s/ACTUALINDEX/$actual_index/g" \
    -e "s/TED/$actual_end_day/g" \
    -e "s/TEH/$actual_end_hours/g" \
   tmp_template/exp_template.sh > $WorkingDir/tmp/${name}.sh

echo "New experiment ready in directory : $WorkingDir "
echo "Script : $WorkingDir/tmp/${name}.sh "

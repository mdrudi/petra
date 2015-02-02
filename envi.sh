
backdir=`pwd`
exedir=`dirname $0`
Cmd="cd $exedir/.."
#echo $Cmd
eval $Cmd
petra_root=`pwd`    #`dirname $0`
#petra_root=`dirname $petra_root`   #root dir for PETRA
Cmd="cd $backdir"
#echo $Cmd
eval $Cmd

PETRAComponentName=ComponentNameToDefine

FileTransfer=${petra_root}/transf.wrapper   #DO NOT CHANGE
FTLogDir=/tmp/`whoami`/transf.file_log

EventMng=${petra_root}/eventmng             #DO NOT CHANGE
EVEventSpace=/tmp/eventmng

petra_aux=${petra_root}/aux                 #DO NOT CHANGE

TIComponentName=transf.indata
TransfIndata=${petra_root}/transf           #DO NOT CHANGE
TILogDir=/tmp/`whoami`/transf.indata_log

SCComponentName=scheduler
SchedulerDir=${petra_root}/scheduler        #DO NOT CHANGE
SCWorkDirBase=/srv/data/`whoami`/scheduler_work
SCLogDir=/tmp/`whoami`/scheduler_log

MNComponentName=monit
MonitDir=${petra_root}/monit                #DO NOT CHANGE
MNLogDir=/tmp/`whoami`/monit_log


if [ _$petra_custom != _ ] ; then
   if [ -f $petra_custom ]; then
      echo Including $petra_custom
      . $petra_custom
   fi
fi

pebc=${petra_root}/exp_build_pack                       #DO NOT CHANGE
pmc=${petra_root}/motu-client-python-1.0.2/src/python   #DO NOT CHANGE - here is the file motu-client.py

export PATH;PATH=${petra_aux}:${pebc}:${pmc}:$PATH


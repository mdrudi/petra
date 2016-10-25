cd `dirname $0`
DimTable=`ls *dimtable.dat`
cd ..
ExpDir=`pwd`

exec 1> ${ExpDir}/log.txt  2>&1
echo $$ > ${ExpDir}/pid

while read col1 col2 ; do
    echo $col1 - $col2
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col2 |awk '{print $1}'` ;;
#       phys_obc) phys_obc_TEO=`echo $col2 |awk '{print $1}'`  ;;
       wave_rst) wave_rst_TEO=`echo $col2 |awk '{print $1}'`  ;;
       phys_cor) phys_cor_TEO=`echo $col2 |awk '{print $1}'`  ;;
    esac 
done < `dirname $0`/$DimTable

check_file()
{
   ##### CHECK IF EXIST THE FILE #####
   if [ -f $1 ]; then
      echo "THERE IS THE FILE $1"
   else 
      echo "THERE IS NOT THE FILE " $1
      exit 1 
   fi
}

check_dimfile()
{
   ##### CHECK ON THE RIGHT DIMENSION ##### 
   sizeR=`ls -l ${1} | awk '{print $5}'`
   if [ "_${sizeR}" != "_${2}" ]; then
      echo "WRONG DIMENSION OF " $1
      exit 1
   else
      echo "GOOD DIMENSION OF " $1
   fi
}

rebuild_output()
{
   echo Starting index R${1} - `date -u `
   bsub -K < Job_EXP_R${1}
   excode=$?
   echo End index R${1} - `date -u ` , bsub exit code : $excode
   sleep 5
   pexJobId=`cat ${ExpDir}/output/index_R${1}.jobid`
   bhist -l $pexJobId > ${ExpDir}/output/bhist_R${1}_${pexJobId}

   d_bb=${2}
   d_1=${3}
   # create monthly folder to save the outputs
   if [ 'OUTPUTSORT' == 'yes' ]; then
      move_file ${d_bb:0:6}
   fi
}

rebuild_restart()
{
   bsub -K < Job_EXP_B${1}
   excode=$?
   echo End index B${1} - `date -u ` , bsub exit code : $excode
   sleep 5
   pexJobId=`cat ${ExpDir}/output/index_B${1}.jobid`
   bhist -l $pexJobId > ${ExpDir}/output/bhist_B${1}_${pexJobId}

   check_file ${ExpDir}/output/restart.nc_${2}
   check_dimfile ${ExpDir}/output/restart.nc_${2} $phys_rst_TEO
   
  # rm_restart ${2}
}

rm_restart(){
   echo
   echo Removing partial restart file for day ${1} - `date -u `
   Cmd="rm ${ExpDir}/output/restart_*.nc_${1}12"  # TODO is 12 always the same??
   echo $Cmd
   eval $Cmd
   echo
}

move_file(){

   month_folder=${1}
   if [ ! -d "${ExpDir}/output/${month_folder}" ]; then
      Cmd="mkdir ${ExpDir}/output/${month_folder}"
      echo $Cmd
      eval $Cmd
   fi

   echo Moving files to folder ${month_folder}
   Cmd="mv ${ExpDir}/output/*_1*_grid_?.n* ${ExpDir}/output/${month_folder}/."
   echo $Cmd
   eval $Cmd
   echo
   Cmd="mv ${ExpDir}/output/index_*.jobid ${ExpDir}/output/mpiexec.log_* ${ExpDir}/output/bhist_* ${ExpDir}/output/adout_* ${ExpDir}/output/aderr_* ${ExpDir}/output/*.output_* ${ExpDir}/output/solver.stat_* ${ExpDir}/output/${month_folder}/."
   echo $Cmd
   eval $Cmd
   echo     
}

echo
echo ExpDir = $ExpDir
echo
Cmd="rm -f ${ExpDir}/model/*"
echo $Cmd
eval $Cmd



last_a=`expr ACTUALINDEX - 1`
bb=1
delta_day=`expr 0 - 1`
echo


cd ${ExpDir}/tmp
./sec_counter.py TagSecCounterS_init

for aa in `seq 1 $last_a`; do

   DAY_aa=`sed -n "/^TED=/ {s///p;q;}" ${ExpDir}/tmp/Job_EXP_P${aa}`  # extract the day  
   if [ -f ${ExpDir}/tmp/Job_EXP_B${bb} ] ; then
      DAY_bb=`sed -n "/^ACTUALDAY=/ {s///p;q;}" ${ExpDir}/tmp/Job_EXP_B${bb}`  # extract the day to rebuild the restart
   fi
   
# ------------  Start the simulation of one day

   while [ ! -f ${ExpDir}/output/index_P${aa}.done ] && [ ! -f ${ExpDir}/output/index_P${aa}.error ]; do
      echo Starting index P$aa - `date -u `
      bsub -W WALLTIME -K <Job_EXP_P${aa}
      excode=$?
      echo End index P${aa} - `date -u ` , bsub exit code : $excode
      ./sec_counter.py TagSecCounterS_pjob_done
      sleep 5
      pexJobId=`cat ${ExpDir}/model/index_P${aa}.jobid`
      bhist -l $pexJobId > ${ExpDir}/output/bhist_P${aa}_${pexJobId}
   done

# -----------  Rebuild the partial outputs if all went ok

   if [ -f ${ExpDir}/output/index_P${aa}.error ]; then
      echo End index P$aa - ERROR - `date -u`
      echo
      exit
   else
      #delta_day=`expr 0 - 1`
      DAY_1=`jday.py ${DAY_aa} ${delta_day}`
      rebuild_output ${aa} ${DAY_bb:0:8} ${DAY_1} &
      echo
   fi

# -----------  Rebuild the restart
   
   if [ "${DAY_aa}" == "${DAY_bb:0:8}" ] ; then
      
      echo Starting index B${bb} - `date -u `
      rebuild_restart ${bb} ${DAY_bb} &   
      bb=`expr $bb + 1`
   fi


# -----------  Remove the partial restart files

   DAY_rm=`jday.py ${DAY_aa} ${delta_day}`
 
   if [ ${aa} -gt 1 ] ; then
      if [ "${DAY_rm}" != "${DAY_bb:0:8}" ] ; then
         echo
         echo aa is ${aa} , DAY_aa is ${DAY_aa} , DAY_bb is ${DAY_bb:0:8} 
         echo DAY_rm is ${DAY_rm}
         echo
         rm_restart ${DAY_rm}
      fi
   fi

while [ -f ${ExpDir}/pause ]; do sleep 60; done

done

# last partial restarts to remove
Cmd="ls -1 ${ExpDir}/output/restart_*"
echo $Cmd
eval $Cmd
if [ `echo $?` -eq 0 ]; then
   echo
   echo Removing the remaining partial files
   Cmd="rm ${ExpDir}/output/restart_*"
   echo $Cmd
   eval $Cmd
fi

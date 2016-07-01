cd `dirname $0`
DimTable=`ls *dimtable.dat`
cd ..
ExpDir=`pwd`

exec 1> ${ExpDir}/log.txt  2>&1


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
   echo "THERE IS THE FILE"
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

post_proc()
{
echo Starting index R$aa - `date -u `
bsub -K < Job_EXP_R${1}
excode=$?
echo End index R${1} - `date -u ` , bsub exit code : $excode
sleep 5
pexJobId=`cat ${ExpDir}/output/index_R${aa}.jobid`
bhist -l $pexJobId > ${ExpDir}/output/bhist_R${1}_${pexJobId}
}


echo
echo ExpDir = $ExpDir
echo
Cmd="rm -f ${ExpDir}/model/*"
echo $Cmd
eval $Cmd

last_a=`expr ACTUALINDEX - 1`
echo

cd ${ExpDir}/tmp
./sec_counter.py TagSecCounterS_init

for aa in `seq 1 $last_a`; do

   while [ ! -f ${ExpDir}/model/index_P${aa}.done ] && [ ! -f ${ExpDir}/model/index_P${aa}.error ]; do
      echo Starting index P$aa - `date -u `
      bsub -W 20 -K <Job_EXP_P${aa}
      excode=$?
      echo End index P${aa} - `date -u ` , bsub exit code : $excode
      ./sec_counter.py TagSecCounterS_pjob_done
      sleep 5
      pexJobId=`cat ${ExpDir}/model/index_P${aa}.jobid`
      bhist -l $pexJobId > ${ExpDir}/output/bhist_P${aa}_${pexJobId}
   done

   #date -u
   #if [ $aa -eq 1 ] ; then
   #   bsub < Job_EXP_R${aa}
      #echo job name: `cat Job_EXP_${aa}R | grep "BSUB -J" | awk '{ print $3 }'`
      #sleep 5
      #jobidR=`cat ${ExpDir}/output/indexR_${aa}.jobid`
   #else
   #   a1=`expr $aa - 1`
   #   prev_jobname=`cat Job_EXP_R${a1} | grep "BSUB -J" | awk '{ print $3 }'`
   #   echo prev job name: $prev_jobname
   #   prev_jobid=`cat ${ExpDir}/output/indexR_${a1}.jobid`
   #   echo prev job id: $prev_jobid
   #   if [ $aa -eq $last_a ] ; then
   #      bsub -K -w "done(${prev_jobname})" < Job_EXP_R${aa}
   #   else
   #      bsub -w "done(${prev_jobname})" < Job_EXP_R${aa}
      #sleep 5
      #jobidR=`cat ${ExpDir}/output/indexR_${aa}.jobid`
   #   fi
   #fi   
   #date -u

   if [ -f ${ExpDir}/model/index_P${aa}.error ]; then
      echo End index P$aa - ERROR - `date -u`
      echo
      exit
   else
      #bsub -K < Job_EXP_R${aa} &
      post_proc ${aa} &
      #echo End index P$aa - COMPLEted - `date -u`
      echo
   fi

done

echo Wait for end of all sub-process - `date -u`
wait
echo End of all sub-process - `date -u`

Cmd="cd ${ExpDir}/output"
echo $Cmd
eval $Cmd

Cmd="${ExpDir}/tmp/rebuild -o rebuilt_file.nc restart_*.nc_TEDTEH"
echo $Cmd
eval $Cmd

check_file rebuilt_file.nc
check_dimfile rebuilt_file.nc $phys_rst_TEO

Cmd="mv rebuilt_file.nc restart.nc_TEDTEH"
echo $Cmd
eval $Cmd

if [ -f restart.nc_TEDTEH ] ; then
    Cmd="rm restart_*.nc_TEDTEH"
    echo $Cmd
    eval $Cmd
    fi

#while [ ! -f ${ExpDir}/output/indexR_${last_a}.jobid ] ; do
#      Cmd="waiting `cat ${ExpDir}/tmp/Job_EXP_R${last_a} | grep 'BSUB -J' | awk '{ print $3 }'`"
#      echo $Cmd    
#      sleep 60
#done


echo End of rebuild - `date -u`


cd `dirname $0`
DimTable=`ls *.dimtable.dat`
cd ..
ExpDir=`pwd`

exec 1> ${ExpDir}/log.txt  2>&1


while read col1 col2 ; do
    echo $col1 - $col2
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col2 |awk '{print $1}'` ;;
       phys_obc) phys_obc_TEO=`echo $col2 |awk '{print $1}'`  ;;
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


CallRebuild() {
   Cmd="cd ${ExpDir}/output"
   echo $Cmd
   eval $Cmd
   ListMasterCR=`ls *_T_0000.nc *_V_0000.nc *_U_0000.nc *_W_0000.nc `
   for FileMasterCR in $ListMasterCR; do
      NumCharsCR=`echo $FileMasterCR | wc -c` 
      NumCharsCRm9=`expr $NumCharsCR - 9`
      FileMasterCRT=`echo $FileMasterCR | cut -c-${NumCharsCRm9}`
      if [ ! -f ${FileMasterCRT}.nc ]; then
         echo FileMasterCR= $FileMasterCR
###### Just To Manage a Bug in NEMO - START
         NumFilesCR=`ls ${FileMasterCRT}_????.nc | wc -l`
         for FileLeafCR in `ls ${FileMasterCRT}_????.nc`; do
            Cmd="ncatted -a DOMAIN_number_total,global,o,l,${NumFilesCR} $FileLeafCR"
            echo $Cmd
            eval $Cmd
         done
###### Just To Manage a Bug in NEMO - END
         Cmd="${ExpDir}/tmp/rebuild -o ${FileMasterCRT}.nc ${FileMasterCRT}_????.nc"
         echo $Cmd
         eval $Cmd
      fi
   done   
}

echo
echo ExpDir = $ExpDir
echo
Cmd="rm -f ${ExpDir}/model/*"
echo $Cmd
eval $Cmd

last_a=`expr ACTUALINDEX - 1`
echo


for aa in `seq 1 $last_a`; do

   #echo Starting index $aa - `date -u `
   cd ${ExpDir}/tmp

   #bsub<Job_EXP_${aa} 

   while [ ! -f ${ExpDir}/model/index_${aa}.done ] && [ ! -f ${ExpDir}/model/index_${aa}.error ]; do
      #sleep 60

      echo Starting index $aa - `date -u `
      #bsub -W 60 -I <Job_EXP_${aa}
      bsub -W 35 -K <Job_EXP_${aa}

      echo bsub exit code : $?

      sleep 5
      pexJobId=`cat ${ExpDir}/model/index_${aa}.jobid`
      bhist -l $pexJobId > ${ExpDir}/output/bhist_${aa}_${pexJobId}

   done

   date -u
#   CallRebuild
   bsub -K <Job_EXP_${aa}R
   date -u

   if [ -f ${ExpDir}/model/index_${aa}.error ]; then
      echo ERROR - `date -u`
      echo
      exit
   else
      echo Completed index $aa - `date -u`
      echo
   fi

done

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

date -u


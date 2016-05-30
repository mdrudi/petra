TED=$1
TEH=$2
WORKINGDIR=$3
TCPUN=$4
ACTUALINDEX=$5
INSITUActive=$6

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- to copy on a storage machine
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

R_SORTIE_OCE=$WORKINGDIR/output
R_EXPER=$WORKINGDIR/tmp
tcpun=$TCPUN

DPUT=mv

while read col1 col2 ; do
    echo $col1 - $col2
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col2 |awk '{print $1}'` ;;
#       phys_obc) phys_obc_TEO=`echo $col2 |awk '{print $1}'`  ;;
       wave_rst) wave_rst_TEO=`echo $col2 |awk '{print $1}'`  ;;
       phys_cor) phys_cor_TEO=`echo $col2 |awk '{print $1}'`  ;;
    esac 
done < `dirname $0`/`basename $0 | cut -d. -f1`.dimtable.dat

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

[ -d ${R_SORTIE_OCE} ] || mkdir -p ${R_SORTIE_OCE}

#- Save pe restart file
tcpum1=`expr $tcpun - 1`
for aa in `seq 0 $tcpum1`; do
   cpuname=`printf "%0*d\n" 4 $aa`
   $DPUT *_*_restartout_$cpuname.nc ${R_SORTIE_OCE}/restart_$cpuname.nc_${TED}${TEH}
   done

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- Save ocean output files
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$DPUT ocean.output ${R_SORTIE_OCE}/ocean.output_${TED}${TEH}
$DPUT solver.stat ${R_SORTIE_OCE}/solver.stat_${TED}${TEH}
$DPUT timing.output ${R_SORTIE_OCE}/timing.output_${TED}${TEH}

mv *_grid_*.nc ${R_SORTIE_OCE}/.


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- Save corrections and observations
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#### CHECK ON MISFIT EXISTENCE ##### 
check_mis()
{
if [ -f $1 ] ; then
   $DPUT $1 $2
#else
#   echo '-9999' > $2
fi
}

if [ _$INSITUActive == '_yes' ] ; then
   check_file obs.dat 
   check_file corr_eta.nc 
   check_file corr_tem.nc 
   check_file corr_sal.nc 
   check_file corr_uvl.nc 
   check_file corr_vvl.nc  
   ncks -A  corr_eta.nc corr_tem.nc
   ncks -A  corr_tem.nc corr_sal.nc
   ncks -A  corr_sal.nc corr_uvl.nc
   ncks -A  corr_uvl.nc corr_vvl.nc
   mv corr_vvl.nc corr.nc
   check_file corr.nc
   check_dimfile corr.nc $phys_cor_TEO
   rm corr_*.nc
   #$DPUT mldn.nc ${R_SORTIE_OCE}/mldn.nc_${TED}${TEH}
   $DPUT corr.nc ${R_SORTIE_OCE}/corr.nc_${TED}${TEH}
   check_file ${R_SORTIE_OCE}/corr.nc_${TED}${TEH}
   check_dimfile ${R_SORTIE_OCE}/corr.nc_${TED}${TEH} $phys_cor_TEO
   $DPUT obs.dat ${R_SORTIE_OCE}/obs_1.dat_${TED}${TEH}
   check_mis sla_mis.dat ${R_SORTIE_OCE}/sla_mis.dat_${TED}${TEH}
   check_mis arg_mis.dat ${R_SORTIE_OCE}/arg_mis.dat_${TED}${TEH}
   check_mis xbt_mis.dat ${R_SORTIE_OCE}/xbt_mis.dat_${TED}${TEH}
   check_mis gld_mis.dat ${R_SORTIE_OCE}/gld_mis.dat_${TED}${TEH}
   check_mis sst_mis.dat ${R_SORTIE_OCE}/sst_mis.dat_${TED}${TEH}
   $DPUT obs_stat.dat ${R_SORTIE_OCE}/obs_stat.dat_${TED}${TEH}
   $DPUT argo_rejc.dat ${R_SORTIE_OCE}/argo_rejc.dat_${TED}${TEH}
   $DPUT glider_rejc.dat ${R_SORTIE_OCE}/glider_rejc.dat_${TED}${TEH}
   $DPUT sla_rejc.dat ${R_SORTIE_OCE}/sla_rejc.dat_${TED}${TEH}
   $DPUT xbt_rejc.dat ${R_SORTIE_OCE}/xbt_rejc.dat_${TED}${TEH}
fi


#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- Save ftrace file
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# BUG - non puo' essere l'ultima istruzione [ -f ftrace.out* ] && $DPUT ftrace.out* ${R_SORTIE_OCE}/.

#if [ -d $WORKINGDIR/model/wind ]; then
#   rm -f $WORKINGDIR/model/wind/*
#   rmdir $WORKINGDIR/model/wind
#   fi




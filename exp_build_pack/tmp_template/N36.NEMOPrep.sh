TSD=$1
TSH=$2
TED=$3
TEH=$4
ProdCycle=$5
path_s=$6
DATA0=$7
DATA1=$8
DATA2=$9
actual_index=${10}
tcpun=${11}
incasenotfirst=${12}
INSITUActive=${13}
SSTActive=${14}

########################################################################
##
##      Script to run the Mediterranean implementeation for MFS project
##
##            Paolo Oddo, INGV Operational Oceanography Group
##
##
#########################################################################

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# print echo of commands before and after shell interpretation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

date
set -vx

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- Launching run repository
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

R_EXPER=${path_s}/tmp

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- modipsl repository
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

R_EXEDIR=$R_EXPER

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- output files storing 
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

R_SORTIE_OCE=$path_s/output

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- execution repository
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

R_TMP=$path_s/model

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d ${R_TMP} ] || mkdir ${R_TMP}
cd ${R_TMP}
#rm *nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#--  get the executable
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#ln -s ${R_EXEDIR}/opa opa.xx
#ln -s ${R_EXEDIR}/ioserver ioserver.xx

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
## --  Copy ancillary files
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#- Namelist for the configuration 
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

cp ${R_EXPER}/namelist_${actual_index} namelist_ref
touch namelist_cfg
cp ${R_EXPER}/field_def.xml  field_def.xml
cp ${R_EXPER}/iodef.xml      iodef.xml
cp ${R_EXPER}/domain_def.xml domain_def.xml
cp ${R_EXPER}/rebuild        rebuild
cp ${R_EXPER}/flio_rbld.exe  flio_rbld.exe

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Link static variables (ECMWF land-sea mask and bathymetry)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

ln -fs ${DATA0}/bathy_meter_open_nemo3.nc bathy_meter.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Link climatology for relaxation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 


# N.B.: eas1_SIM_*_y2013.nc are temperature and salinity fields extracted from 20130101 EAS1
#       output in simulation mode
ln -fs ${DATA0}/eas1_SIM_theta_y2013.nc  data_1m_potential_temperature_nomask_y2013.nc
ln -fs ${DATA0}/eas1_SIM_sal_y2013.nc  data_1m_salinity_nomask_y2013.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link Rivers file
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ln -fs ${DATA0}/runoff_MFS_positive_EAS1_v1.nc runoff_1m_nomask.nc
#ln -fs ${DATA0}/runoff_MFS_positive.nc runoff_1m_nomask.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link restart files (ocean and lateral open boundary)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

while read col1 ; do
    #echo $col1
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col1 |awk '{print $2}'` ;;
#       phys_obc) phys_obc_TEO=`echo $col1 |awk '{print $2}'`  ;;
       wave_rst) wave_rst_TEO=`echo $col1 |awk '{print $2}'`  ;;
       phys_cor) phys_cor_TEO=`echo $col1 |awk '{print $2}'`  ;;
    esac 
done < `dirname $0`/`basename $0 | cut -d. -f1`.dimtable.dat

check_file()
{
##### CHECK IF EXIST THE FILE #####
if [ -f $1 ]; then
   echo "RESTART OK"
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

if [ $incasenotfirst -eq 1 ]; then

   #INCASENOTFIRST
   #check_file ${R_SORTIE_OCE}/restart.obc_${TSD}${TSH}
   #ln -fs ${R_SORTIE_OCE}/restart.obc_${TSD}${TSH} restart.obc

   if [ -f ${R_SORTIE_OCE}/restart.nc_${TSD}${TSH} ]; then
      check_file ${R_SORTIE_OCE}/restart.nc_${TSD}${TSH} 
      ln -fs ${R_SORTIE_OCE}/restart.nc_${TSD}${TSH} restartin.nc
   
   else

      tcpum1=`expr $tcpun - 1`
      for aa in `seq 0 $tcpum1`; do 
         cpuname=`printf "%0*d\n" 4 $aa`
         #INCASENOTFIRST 
         ln -fs ${R_SORTIE_OCE}/restart_$cpuname.nc_${TSD}${TSH} restartin_$cpuname.nc
      done

   fi

fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link BDY files 
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#ln -fs ${DATA2}/BDY_DAILY/coordinates.bdy.nc coordinates.bdy.nc
ln -fs ${DATA0}/coordinates.bdy.nc coordinates.bdy.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link WIND
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ -d ${R_TMP}/wind ] || mkdir ${R_TMP}/wind

mkdir -p ${R_TMP}/wind/in   ; rm -f ${R_TMP}/wind/in/*
mkdir -p ${R_TMP}/wind/work ; rm -f ${R_TMP}/wind/work/*

cd ${R_TMP}/wind/in 
touch ${R_TMP}/wind/in/startday.$TSD
touch ${R_TMP}/wind/in/procday.$ProdCycle
EndDay=$TED
if [ $TED -eq $TSD ] ; then
    EndDay=`jday.py $TED +1`  # per risolvere bug esperimenti 12h
    touch ${R_TMP}/wind/in/endday.$EndDay
else
    touch ${R_TMP}/wind/in/endday.$TED
fi

if [ $TED -ge $ProdCycle ] ; then 
   
   for file in `ls -1 ${DATA1}/ECMWF18/NETCDF/$ProdCycle/*.nc` ; do
       ln -s $file 
       done

   sh $R_EXPER/ecmwf2NEMO-fc.sh  ${R_TMP}/wind/in ${R_TMP}/wind/work ${R_TMP}/wind/work ${R_TMP}/wind
     
         
     if [ $TSD -ge `jday.py $ProdCycle +0` ] &&  [ $TSD -le `jday.py $ProdCycle +2` ] ; then
        id0=`echo $TSD | cut -c 7-8`
        id1=`echo $TED | cut -c 7-8`
        name=`find ${R_TMP}/wind/ -name ecmwf_y*d${id0}.nc_8rec`
        if [[ ! -z $name ]] ; then
          mv $name `dirname $name`/`basename $name | cut -d_ -f1-2`
        fi
        name=`find ${R_TMP}/wind/  -name ecmwf_y*d${id1}.nc_8rec`
        if [[ ! -z $name ]] ; then
          mv $name `dirname $name`/`basename $name | cut -d_ -f1-2`
        fi
     fi
    
else
   day=$TSD
   #while [ $day -ne `jday.py $TED +1` ] ; do
   while [ $day -le $EndDay ] ; do
        day1=`jday.py $day +1`
        name=`echo $day-ECMWF---*-MEDATL-b${day1}_an-fv05.00.nc`
        file=`find ${DATA1}/ECMWF18/NETCDF -name $name | tail -1`
        if [ _$file = "_" ]; then
           name=`echo $day-ECMWF---*-MEDATL-b${day}_antmp-fv05.00.nc`
           file=`find ${DATA1}/ECMWF18/NETCDF -name $name | tail -1`
        fi
        echo link to $file
        ln -fs $file
        day=$day1
        done
  
   sh $R_EXPER/ecmwf2NEMO-an.sh  ${R_TMP}/wind/in ${R_TMP}/wind/work ${R_TMP}/wind/work ${R_TMP}/wind
fi

cd ${R_TMP}/wind

rm -f  ${R_TMP}/wind/in/*   ; rmdir  ${R_TMP}/wind/in   
rm -f  ${R_TMP}/wind/work/* ; rmdir  ${R_TMP}/wind/work


for file in `ls ${DATA0}/ECMWF_nc/*reshape* ${DATA0}/ECMWF_nc/precip_cmap.nc `; do
   ln -fs $file
   done   


cd ${R_TMP}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link SST
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ _$SSTActive == '_yes' ] ; then

   [ -d ${R_TMP}/sst ] || mkdir ${R_TMP}/sst

   mkdir -p ${R_TMP}/sst/in   ; rm -f ${R_TMP}/sst/in/*
   mkdir -p ${R_TMP}/sst/work ; rm -f ${R_TMP}/sst/work/*
   cd ${R_TMP}/sst/in
   
   idate=$TSD
   endp1=`jday.py $TED +1`
   while [ $idate -le $endp1  ] ; do 
      name=`echo  ${idate}000000-GOS-L4_GHRSST-SSTfnd-OISST_HR_NRT-MED-v02.0-fv02.0.nc`
      cmd=`find ${DATA1}/SST_L4 -name $name `
      cnt=1
      while [ _$cmd == '_' -a $cnt -le 4 ] ; do
            datebefore=`jday.py $idate -$cnt`
            echo $name 'not found: linking sst of '$datebefore
            pname=`echo  ${datebefore}000000-GOS-L4_GHRSST-SSTfnd-OISST_HR_NRT-MED-v02.0-fv02.0.nc` 
            cmd=` find ${DATA1}/SST_L4 -name $pname `
            cnt=`expr $cnt + 1`  
      done
      
      ln -s $cmd $name
      idate=`jday.py $idate +1`
   done
    
   sh $R_EXPER/sst2NEMO.sh  ${R_TMP}/sst/in ${R_TMP}/sst/work ${R_TMP}/sst/work ${R_TMP}
    
   rm -rf ${R_TMP}/sst/* ; rmdir ${R_TMP}/sst
     
fi  #end of SSTActive







if [ _$INSITUActive == '_yes' ] ; then

   cd ${R_TMP}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link observations
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   GRDINP=${DATA0}/grids
   EOFINP=${DATA0}/EOF
   
   [ -d ${R_TMP}/insitu ] || mkdir ${R_TMP}/insitu

   mkdir -p ${R_TMP}/insitu/work ; rm -f ${R_TMP}/insitu/work/*

   touch ${R_TMP}/insitu/work/startday.$TSD
   touch ${R_TMP}/insitu/work/endday.$TED

   sh $R_EXPER/insitu2NEMO.sh ${DATA1} ${R_TMP}/insitu/work ${R_TMP}/insitu/work ${R_TMP}

   rm ${R_TMP}/insitu/work/startday.$TSD ${R_TMP}/insitu/work/endday.$TED
   rmdir ${R_TMP}/insitu/work
   rmdir ${R_TMP}/insitu
   
   if [ $TSD -ge 20140324 ] ; then
      ln -fs $GRDINP/mdt_v2.nc mdt.nc
   else
      ln -fs $GRDINP/MFS_16_72_n.nc mdt.nc
   fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link corrections
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      
      if [ $incasenotfirst -eq 1 ]; then
          if [ -f $R_SORTIE_OCE/corr.nc_${TSD}${TSH} ] ; then
             ln -fs $R_SORTIE_OCE/corr.nc_${TSD}${TSH} corr.nc
          fi
      else
          check_file $R_SORTIE_OCE/corr.nc_${TSD}${TSH} 
          check_dimfile $R_SORTIE_OCE/corr.nc_${TSD}${TSH} $phys_cor_TEO
          ln -fs $R_SORTIE_OCE/corr.nc_${TSD}${TSH} corr.nc
      fi

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# load files for 3dvar execution time
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Load grids

   ln -fs $GRDINP/MFS_16_72_n.nc grid1.nc

# Load EOfs

	yyyymm=`expr $TSD / 100`
	nyear=`expr $yyyymm / 100`
	nmonth=`expr $yyyymm - $nyear \* 100`

   if test $nmonth -eq 01 ; then
      ln -fs $EOFINP/eof01.nc eofs.nc
   elif test $nmonth -eq 02; then
      ln -fs $EOFINP/eof02.nc eofs.nc
   elif test $nmonth -eq 03; then
      ln -fs $EOFINP/eof03.nc eofs.nc
   elif test $nmonth -eq 04; then
      ln -fs $EOFINP/eof04.nc eofs.nc
   elif test $nmonth -eq 05; then
      ln -fs $EOFINP/eof05.nc eofs.nc
   elif test $nmonth -eq 06; then
      ln -fs $EOFINP/eof06.nc eofs.nc
   elif test $nmonth -eq 07; then
      ln -fs $EOFINP/eof07.nc eofs.nc
   elif test $nmonth -eq 08; then
      ln -fs $EOFINP/eof08.nc eofs.nc
   elif test $nmonth -eq 09; then
      ln -fs $EOFINP/eof09.nc eofs.nc
   elif test $nmonth -eq 10; then
      ln -fs $EOFINP/eof10.nc eofs.nc
   elif test $nmonth -eq 11 ; then
      ln -fs $EOFINP/eof11.nc eofs.nc
   elif test $nmonth -eq 12; then
      ln -fs $EOFINP/eof12.nc eofs.nc
   fi
fi #end of INSITUActive
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

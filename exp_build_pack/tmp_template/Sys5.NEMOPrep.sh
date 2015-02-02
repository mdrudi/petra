TSD=$1
TSH=$2
TED=$3
TEH=$4
ProdCycle=$5
path_s=$6
DATA0=$7
DATA1=$8
actual_index=$9
tcpun=${10}
incasenotfirst=${11}
INSITUActive=${12}
SSTActive=${13}

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

cp ${R_EXPER}/namelist_${actual_index} namelist
cp ${R_EXPER}/xmlio_server.def xmlio_server.def
cp ${R_EXPER}/iodef.xml iodef.xml

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Link static variables (ECMWF land-sea mask and bathymetry)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

ln -fs ${DATA0}/bathy_meter_open_nemo3.nc bathy_meter.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Link climatology for relaxation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

ln -fs ${DATA0}/theta_medatlas_nemo4.nc data_1m_potential_temperature_nomask.nc
ln -fs ${DATA0}/sal_medatlas_nemo4.nc data_1m_salinity_nomask.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link Rivers file
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ln -fs ${DATA0}/runoff_MFS_positive.nc runoff_1m_nomask.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link restart files (ocean and lateral open boundary)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

while read col1 ; do
    #echo $col1
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col1 |awk '{print $2}'` ;;
       phys_obc) phys_obc_TEO=`echo $col1 |awk '{print $2}'`  ;;
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
   check_file ${R_SORTIE_OCE}/restart.obc_${TSD}${TSH}
   ln -fs ${R_SORTIE_OCE}/restart.obc_${TSD}${TSH} restart.obc

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
# link LOBC files 
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ln -fs ${DATA0}/LOBC_CLIM/obcwest_TS_merc_clim4.nc obcwest_TS.nc
ln -fs ${DATA0}/LOBC_CLIM/obcwest_U_merc_clim4.nc  obcwest_U.nc
ln -fs ${DATA0}/LOBC_CLIM/obcwest_V_merc_clim4.nc  obcwest_V.nc

ln -fs ${DATA0}/LOBC_CLIM/obcnorth_TS_merc_clim4.nc obcnorth_TS.nc
ln -fs ${DATA0}/LOBC_CLIM/obcnorth_V_merc_clim4.nc  obcnorth_V.nc
ln -fs ${DATA0}/LOBC_CLIM/obcnorth_U_merc_clim4.nc  obcnorth_U.nc

ln -fs ${DATA0}/LOBC_CLIM/obcsouth_TS_merc_clim4.nc obcsouth_TS.nc
ln -fs ${DATA0}/LOBC_CLIM/obcsouth_V_merc_clim4.nc obcsouth_V.nc
ln -fs ${DATA0}/LOBC_CLIM/obcsouth_U_merc_clim4.nc obcsouth_U.nc

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# link WIND
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

[ -d ${R_TMP}/wind ] || mkdir ${R_TMP}/wind

mkdir -p ${R_TMP}/wind/in   ; rm -f ${R_TMP}/wind/in/*
mkdir -p ${R_TMP}/wind/work ; rm -f ${R_TMP}/wind/work/*

cd ${R_TMP}/wind/in 
touch ${R_TMP}/wind/in/startday.$TSD
EndDay=$TED
if [ $TED -eq $TSD ] ; then
    EndDay=`jday.py $TED +1`  # per risolvere bug esperimenti 12h
    touch ${R_TMP}/wind/in/endday.$EndDay
else
    touch ${R_TMP}/wind/in/endday.$TED
fi

if [ $TED -ge $ProdCycle ] ; then
   echo "FORECAST"
   if [ $TSD -lt $ProdCycle ] ; then
      for hs in 00 03 06 09 12 15 18 21 ; do
          name=`echo ingv_${TSD}${hs}.grb.bz2`
          file=`find ${DATA1}/COSMO -name $name | tail -1`
          if [ _$file != "_" ]; then
             echo link to $file
             ln -fs $file
          fi
      done
   fi
   for hs in 00 03 06 09 ; do
       name=`echo ingv_${ProdCycle}${hs}.grb.bz2`
       file=`find ${DATA1}/COSMO -name $name | tail -1`
       if [ _$file != "_" ]; then
           echo link to $file
           ln -fs $file
       fi
   done
   for file in `ls -1 ${DATA1}/COSMO/$ProdCycle/COSMOME_${ProdCycle}12.tar.bz2` ; do
       echo link to $file
       ln -s $file
       done
   sh $R_EXPER/cosmo2NEMO-fc.sh  ${R_TMP}/wind/in/ ${R_TMP}/wind/work/ ${R_TMP}/wind/work/ ${R_TMP}/wind/

else
   day=$TSD
   echo "ANALYSIS"
   #while [ $day -ne `jday.py $TED +1` ] ; do
   while [ $day -le $EndDay ] ; do
        day1=`jday.py $day +1`
        for hs in 00 03 06 09 12 15 18 21 ; do
            name=`echo ingv_${day}${hs}.grb.bz2`
            file=`find ${DATA1}/COSMO -name $name | tail -1`
            if [ _$file != "_" ]; then
                echo link to $file
                ln -fs $file
            fi
        done
        day=$day1
   done

   sh $R_EXPER/cosmo2NEMO-an.sh  ${R_TMP}/wind/in/ ${R_TMP}/wind/work/ ${R_TMP}/wind/work/ ${R_TMP}/wind/
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

   ln -fs $GRDINP/MFS_16_72_n.nc mdt.nc

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

   if test $nmonth -le 03 ; then
      ln -fs $EOFINP/WINTER_Med_eof.nc eofs.nc
   elif test $nmonth -le 06; then
      ln -fs $EOFINP/SPRING_Med_eof.nc eofs.nc
   elif test $nmonth -le 09; then
      ln -fs $EOFINP/SUMMER_Med_eof.nc eofs.nc
   elif test $nmonth -le 12; then
      ln -fs $EOFINP/AUTUMN_Med_eof.nc eofs.nc
   fi

fi #end of INSITUActive
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


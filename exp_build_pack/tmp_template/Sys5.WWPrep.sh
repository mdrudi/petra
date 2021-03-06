#!/bin/sh

TSD=$1
TSH=$2
TED=$3
TEH=$4
ProdCycle=$5
path_s=$6
DATA0=$7
DATA1=$8
incasenotfirst=$9

step=1
hrp1=`expr $TSH + 1` #salvo da t=1 (no write restart)

time_output_grid=3600
nsec=`expr $step \* 86400 `
nout=`expr $nsec \/ $time_output_grid`

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

# 0. Preparations -----------------------------------------------------------

  set -e

# 0.a Set-up path 

  R_TMP="${path_s}/model"
  R_EXPER="${path_s}/tmp"
  R_SORTIE_OCE=$path_s/output

  cd $R_TMP

  echo ' ' ; echo ' '
  echo '                  ======> MFS RUN WAVEWATCH III <====== '
  echo '                    ==================================   '
  echo '                                     expanded status map '
  echo ' '

# 1. Grid pre-processor -----------------------------------------------------


  echo ' '
  echo '+--------------------+'
  echo '|  Grid preprocessor |'
  echo '+--------------------+'
  echo ' '


  cp $DATA0/BATHY/Med.depth_ascii $R_TMP/.
  cp $DATA0/BATHY/Med.mask_ascii $R_TMP/.
  cp $R_EXPER/ww3_grid.inp $R_TMP/.
  echo "   Screen ouput routed to $R_TMP/ww3_grid.out"
  $R_EXPER/ww3_grid > $R_TMP/ww3_grid.out


# 2. Initial conditions -----------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '| Initial conditions |'
  echo '+--------------------+'
  echo ' '


if [ $incasenotfirst -eq 1  -a  -f $R_SORTIE_OCE/restart1.ww3_${TSD}${TSH} ]; then
  echo "Linking restart $R_SORTIE_OCE/restart1.ww3_${TSD}${TSH}"
  check_file $R_SORTIE_OCE/restart1.ww3_${TSD}${TSH}
  ln -s $R_SORTIE_OCE/restart1.ww3_${TSD}${TSH} $R_TMP/restart.ww3

  else
  cp $R_EXPER/ww3_strt.inp $R_TMP/.
  echo "   Screen output routed to $R_TMP/ww3_strt.out"
  $R_EXPER/ww3_strt > $R_TMP/ww3_strt.out

  fi

# 3. Input fields -----------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '| Input data         |'
  echo '+--------------------+'
  echo ' '


[ -d ${R_TMP}/wind ] || mkdir ${R_TMP}/wind

mkdir -p ${R_TMP}/wind/in   
mkdir -p ${R_TMP}/wind/work

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
   sh $R_EXPER/cosmo2WW-fc.sh  ${R_TMP}/wind/in/ ${R_TMP}/wind/work/ ${R_TMP}/wind/work/ ${R_TMP}/wind/

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

   sh $R_EXPER/cosmo2WW-an.sh  ${R_TMP}/wind/in/ ${R_TMP}/wind/work/ ${R_TMP}/wind/work/ ${R_TMP}/wind/
fi

  
  cd ${R_TMP}
    
  rm -f  ${R_TMP}/wind/in/*   ; rmdir  ${R_TMP}/wind/in   
  rm -f  ${R_TMP}/wind/work/* ; rmdir  ${R_TMP}/wind/work
    
  mv ${R_TMP}/wind/ww3_wind.ascii ${R_TMP}/.   
  cp $R_EXPER/ww3_prep.inp $R_TMP/.
  
  echo "   Screen ouput routed to $R_TMP/ww3_prep.out"
  $R_EXPER/ww3_prep > $R_TMP/ww3_prep.out


# 4. Main program -----------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '|    Main program    |'
  echo '+--------------------+'
  echo ' '

  cp $R_EXPER/ww3_shel_template.inp.cdw $R_TMP/.
  sed -e "s/act_date_in/$TSD/g"     \
      -e "s/act_date_fi/$TED/g" \
      -e "s/hourR/$TSH/g" \
      -e "s/hourS/$hrp1/g" \
      -e "s/hourE/$TEH/g" \
      -e "s/time_output/$time_output_grid/g" \
       $R_TMP/ww3_shel_template.inp.cdw > $R_TMP/ww3_shel.inp

  echo "   Screen ouput routed to $R_TMP/ww3_shel.inp"

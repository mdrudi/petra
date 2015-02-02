#!/bin/sh

TSD=$1
TSH=$2
TED=$3
TEH=$4
path_s=$5
DATA0=$6


hrp1=`expr $TSH + 1` #salvo da t=1 (no write restart)
time_output_grid=3600
startH=`hours_since_1970010100.py $TSD$TSH`
endH=`hours_since_1970010100.py $TED$TEH`
nout=`expr $endH - $startH`

# 0. Preparations -----------------------------------------------------------
  
  set -e
  
# 0.a Set-up path 

  R_TMP="${path_s}/model"
  R_EXPER="${path_s}/tmp"
  R_SORTIE_OCE=$path_s/output

  cd $R_TMP
 
while read col1 col2 ; do
    #echo $col1 - $col2
    case `echo $col1 |awk '{print $1}'` in
       phys_rst) phys_rst_TEO=`echo $col2 |awk '{print $1}'` ;;
       phys_obc) phys_obc_TEO=`echo $col2 |awk '{print $1}'`  ;;
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
 
  echo ' ' ; echo "   Output file log.ww3 routed to $R_SORTIE_OCE"
  mv $R_TMP/log.ww3 $R_SORTIE_OCE/log.ww3_$TED$TEH

#    echo "   Output file test[nnn].ww3 routed to $R_SORTIE_OCE"
#    mv test*.ww3 $R_SORTIE_OCE/.

# 4. Gridded output ---------------------------------------------------------

  echo ' '
  echo '+--------------------+'
  echo '|   Gridded output   |'
  echo '+--------------------+'
  echo ' '

  sed -e "s/act_date_in/$TSD/g"     \
      -e "s/hour2/$hrp1/g" \
      -e "s/time_output/$time_output_grid/g" \
      -e "s/nstep/$nout/g" \
       $R_EXPER/ww3_outf_template.inp > $R_TMP/ww3_outf.inp

  echo "   Screen ouput routed to $R_SORTIE_OCE/ww3_outf.out"
  rm -f $R_TMP/out_grd.nc
  $R_EXPER/ww3_outf > $R_SORTIE_OCE/ww3_outf.out
  

# 6. End, cleaning up -------------------------------------------------------
  
  rm $R_TMP/out_grd.ww3 
  check_file $R_TMP/restart1.ww3
  check_dimfile $R_TMP/restart1.ww3 $wave_rst_TEO
  mv $R_TMP/restart1.ww3 $R_SORTIE_OCE/restart1.ww3_$TED$TEH
  check_file $R_SORTIE_OCE/restart1.ww3_$TED$TEH
  check_dimfile $R_SORTIE_OCE/restart1.ww3_$TED$TEH $wave_rst_TEO
  check_file $R_TMP/out_grd.nc
  mv $R_TMP/out_grd.nc $R_SORTIE_OCE/ww3.out_$TED$TEH.nc
  check_file $R_SORTIE_OCE/ww3.out_$TED$TEH.nc

  echo ' ' ; echo ' '
  echo '                  ======>  END OF WAVEWATCH III  <====== '
  echo '                    ==================================   '
  echo ' '


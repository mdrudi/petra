#!/bin/sh

DIRIN=$1
DIRWORK=$2
DIRLOG=$3
DIROUT=$4

cd `dirname $0`
DIRBIN=`pwd`

DAYS=`ls -1 ${DIRWORK}/startday.*`
TSD=`basename $DAYS | cut -d . -f2`
DAYF=`ls -1 ${DIRWORK}/endday.*`
TED=`basename $DAYF | cut -d . -f2`
TOD=`jday.py ${TSD} -1`
TFD=`jday.py ${TED} +2`

TCD=$TOD
while [ $TCD != $TFD ] ; do
   Cmd="cp ${DIRIN}/INS_ARGO/${TCD}/GL_LATEST_PR_PF* ${DIRWORK}/."  ; eval $Cmd  2> /dev/null #; echo $Cmd 
   Cmd="cp ${DIRIN}/INS_XBT/${TCD}/GL_LATEST_PR_BA* ${DIRWORK}/. "  ; eval $Cmd  2> /dev/null #; echo $Cmd
   Cmd="cp ${DIRIN}/INS_CTD/${TCD}/GL_LATEST_PR_CT* ${DIRWORK}/. "  ; eval $Cmd  2> /dev/null #; echo $Cmd
   slaal=`ls ${DIRIN}/SLA_NRT20_AL/nrt_med_al_sla_vfec_${TCD}*.nc 2> /dev/null | tail -1`
   Cmd=" cp ${slaal} ${DIRWORK}/." ; eval $Cmd  2> /dev/null #; echo $Cmd
   slaj2=`ls ${DIRIN}/SLA_NRT20_J2/nrt_med_j2_sla_vfec_${TCD}*.nc 2> /dev/null | tail -1 ` 
   Cmd="cp ${slaj2} ${DIRWORK}/. " ;  eval $Cmd  2> /dev/null #; echo $Cmd
   slac2=`ls ${DIRIN}/SLA_NRT20_C2/nrt_med_c2_sla_vfec_${TCD}*.nc 2> /dev/null | tail -1`
   Cmd=" cp ${slac2} ${DIRWORK}/. " ; eval $Cmd  2> /dev/null #; echo $Cmd
   TCD=`jday.py $TCD +1`
done

cd ${DIRWORK}

####  ARGO  ####
echo $TSD

if [ -f ${DIRIN}/INS_ARGO/${TSD}.ARGO.dat ] ; then
   cp ${DIRIN}/INS_ARGO/${TSD}.ARGO.dat $DIROUT/ARGO.dat 
else 
  Cmd="ls -1 GL_LATEST_PR_PF* > ${DIRWORK}/listARGO.txt" ; eval $Cmd  2> /dev/null #; echo $Cmd
  #ls -1 GL_LATEST_PR_CT* >> ${DIRWORK}/listARGO.txt
  for FileName in `cat ${DIRWORK}/listARGO.txt` ; do 
     ${DIRBIN}/prep_ARGO_3dvar_V3.exe $DIRWORK $DIRWORK $FileName $TSD 
  done
  counter=`wc -l "${DIRWORK}/${TSD}.ARGO.dat" | awk '{print $1'}`
  echo $counter > ${DIRWORK}/nlinesARGO.txt 
  cat ${DIRWORK}/nlinesARGO.txt ${DIRWORK}/${TSD}.ARGO.dat > ${DIROUT}/ARGO.dat
  rm -f ${DIRWORK}/nlinesARGO.txt ${DIRWORK}/${TSD}.ARGO.dat ${DIRWORK}/listARGO.txt
  rm -f ${DIRWORK}/GL_LATEST_PR_PF* ${DIRWORK}/GL_LATEST_PR_CT*
fi
####  XBT  ####
if [ -f ${DIRIN}/INS_XBT/${TSD}.XBT.dat ] ; then
   cp ${DIRIN}/INS_XBT/${TSD}.XBT.dat $DIROUT/XBT.dat
else
 Cmd="ls -1 GL_LATEST_PR_BA* > ${DIRWORK}/listXBT.txt "  ; eval $Cmd  2> /dev/null #; echo $Cmd
 if [ `ls -l ${DIRWORK}/listXBT.txt 2> /dev/null | awk '{print $5}'` -ne 0 ] ; then
    for FileName in `cat ${DIRWORK}/listXBT.txt` ; do 
        ${DIRBIN}/prep_XBT_3dvar_V3.exe $DIRWORK $DIRWORK $FileName $TSD   
    done
    counter=`wc -l "${DIRWORK}/${TSD}.XBT.dat" | awk '{print $1'}`
    echo $counter > ${DIRWORK}/nlinesXBT.txt   
    cat ${DIRWORK}/nlinesXBT.txt ${DIRWORK}/${TSD}.XBT.dat > ${DIROUT}/XBT.dat
 else
    counter=`wc -l "${DIRWORK}/listXBT.txt" | awk '{print $1'}`
    echo $counter > ${DIROUT}/XBT.dat 
 fi
 rm -f ${DIRWORK}/nlinesXBT.txt ${DIRWORK}/${TSD}.XBT.dat
 rm -f ${DIRWORK}/GL_LATEST_PR_BA* ${DIRWORK}/listXBT.txt
fi

#### SLA ####
if [ -f ${DIRIN}/SLA/${TSD}.SLA.dat ] ; then
   cp ${DIRIN}/SLA/${TSD}.SLA.dat $DIROUT/SLA.dat
else
#  cp ${DIRBIN}/med_ref20yto7y.nc ${DIRWORK}/.
  Cmd="ls -1 nrt_med_*.nc > ${DIRWORK}/listSLA.txt " ; eval $Cmd  2> /dev/null #; echo $Cmd
  if [ `ls -l ${DIRWORK}/listSLA.txt  2> /dev/null | awk '{print $5}'` -ne 0 ] ; then
     for FileName in `cat ${DIRWORK}/listSLA.txt` ; do
          cp ${DIRBIN}/med_ref20yto7y.nc ${DIRWORK}/.
#        file=`basename $FileName | cut -d . -f1`
#        unzip $FileName
#        if [ -f ${file}.nc.gz ]; then
#           gzip -d ${file}.nc.gz
#           filesat=${file}.nc
#        else
#           reldate=`basename $FileName | cut -d . -f1 | cut -d _ -f8`
#           ndate=`jday.py ${reldate} -1`
#           innmfile=`basename $FileName | cut -d . -f1 | cut -d _ -f1,2,3,4,5,6,7`
#           file=${innmfile}_${ndate}
#        #   echo $file
#           gzip -d ${file}.nc.gz
#           filesat=${file}.nc
#        fi
#        echo ${filesat}
        echo $FileName
        ${DIRBIN}/prep_SLA20_3dvar_V3.exe $DIRWORK $DIRWORK ${FileName} $TSD 
     done
     counter=`wc -l "${DIRWORK}/${TSD}.SLA.dat" | awk '{print $1'}`
     echo $counter > ${DIRWORK}/nlinesSLA.txt
     cat ${DIRWORK}/nlinesSLA.txt ${DIRWORK}/${TSD}.SLA.dat > ${DIROUT}/SLA.dat
  else
     counter=`wc -l "${DIRWORK}/listSLA.txt" | awk '{print $1'}`
     echo $counter > ${DIROUT}/SLA.dat
  fi
rm -f ${DIRWORK}/nlinesSLA.txt ${DIRWORK}/${TSD}.SLA.dat 
rm -f ${DIRWORK}/nrt_mfstep_* ${DIRWORK}/listSLA.txt
rm -f ${DIRWORK}/*.txt   
fi

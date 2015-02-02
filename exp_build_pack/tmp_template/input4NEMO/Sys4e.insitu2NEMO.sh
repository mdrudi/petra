#!/bin/bash

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

######## VERTICAL PROFILE #######
TCD=$TOD
while [ $TCD != $TFD ] ; do
   cp ${DIRIN}/INS_ARGO/${TCD}/*_LATEST_PR_PF* ${DIRWORK}/.
   cp ${DIRIN}/INS_XBT/${TCD}/*_LATEST_PR_BA* ${DIRWORK}/.
   cp ${DIRIN}/INS_CTD/${TCD}/*_LATEST_PR_CT* ${DIRWORK}/. 
   cp ${DIRIN}/INS_GLIDER/${TCD}/*_LATEST_PR_GL* ${DIRWORK}/.
   TCD=`jday.py $TCD +1`
done

cd ${DIRWORK}

####  ARGO  ####
echo $TSD

if [ -f ${DIRIN}/INS_ARGO/${TSD}.ARGO.dat ] ; then
   cp ${DIRIN}/INS_ARGO/${TSD}.ARGO.dat $DIROUT/ARGO.dat 
else 
ls -1 *_LATEST_PR_PF* > ${DIRWORK}/listARGO.txt
if [ `ls -l ${DIRWORK}/listARGO.txt | awk '{print $5}'` -ne 0 ] ; then  
 #ls -1 GL_LATEST_PR_CT* >> ${DIRWORK}/listARGO.txt
  for FileName in `cat ${DIRWORK}/listARGO.txt` ; do 
     ${DIRBIN}/prep_ARGO_3dvar_V3.exe $DIRWORK $DIRWORK $FileName $TSD 
  done
  counter=`wc -l "${DIRWORK}/${TSD}.ARGO.dat" | awk '{print $1'}`
  echo $counter > ${DIRWORK}/nlinesARGO.txt 
  cat ${DIRWORK}/nlinesARGO.txt ${DIRWORK}/${TSD}.ARGO.dat > ${DIROUT}/ARGO.dat
else
  counter=`wc -l "${DIRWORK}/listARGO.txt" | awk '{print $1'}`
  echo $counter > ${DIROUT}/ARGO.dat
fi
  rm ${DIRWORK}/nlinesARGO.txt ${DIRWORK}/${TSD}.ARGO.dat ${DIRWORK}/listARGO.txt
  rm ${DIRWORK}/*_LATEST_PR_PF* ${DIRWORK}/*_LATEST_PR_CT*
fi
#### GLIDER ####
echo $TSD

#echo 0 > ${DIROUT}/GLIDER.dat
if [ -f ${DIRIN}/INS_GLIDER/${TSD}.GLIDER.dat ] ; then
   cp ${DIRIN}/INS_GLIDER/${TSD}.GLIDER.dat $DIROUT/GLIDER.dat
else
ls -1 *_LATEST_PR_GL* > ${DIRWORK}/listGLIDER.txt
if [ `ls -l ${DIRWORK}/listGLIDER.txt | awk '{print $5}'` -ne 0 ] ; then
  for FileName in `cat ${DIRWORK}/listGLIDER.txt` ; do
     ${DIRBIN}/prep_GLIDER_3dvar_V4.exe $DIRWORK $DIRWORK $FileName $TSD
  done
  counter=`wc -l "${DIRWORK}/${TSD}.GLIDER.dat" | awk '{print $1'}`
  echo $counter > ${DIRWORK}/nlinesGLIDER.txt
  cat ${DIRWORK}/nlinesGLIDER.txt ${DIRWORK}/${TSD}.GLIDER.dat > ${DIROUT}/GLIDER.dat
else
   counter=`wc -l "${DIRWORK}/listGLIDER.txt" | awk '{print $1'}`
   echo $counter > ${DIROUT}/GLIDER.dat
fi
rm ${DIRWORK}/nlinesGLIDER.txt ${DIRWORK}/${TSD}.GLIDER.dat ${DIRWORK}/listGLIDER.txt
rm ${DIRWORK}/*_LATEST_PR_GL*
fi
####  XBT  ####
if [ -f ${DIRIN}/INS_XBT/${TSD}.XBT.dat ] ; then
   cp ${DIRIN}/INS_XBT/${TSD}.XBT.dat $DIROUT/XBT.dat
else
ls -1 *_LATEST_PR_BA* > ${DIRWORK}/listXBT.txt
if [ `ls -l ${DIRWORK}/listXBT.txt | awk '{print $5}'` -ne 0 ] ; then
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
rm ${DIRWORK}/nlinesXBT.txt ${DIRWORK}/${TSD}.XBT.dat
rm ${DIRWORK}/*_LATEST_PR_BA* ${DIRWORK}/listXBT.txt
fi
#### SLA ####
TCD=$TOD


if [ -f ${DIRIN}/SLA/${TSD}.SLA.dat ] ; then
   cp ${DIRIN}/SLA/${TSD}.SLA.dat $DIROUT/SLA.dat
else
while [ $TCD != $TFD ] ; do
   for dirsat in AL J2 C2 ; do
      cp ${DIRBIN}/med_ref20yto7y.nc ${DIRWORK}/.
      SlaName=`echo $dirsat | tr '[:upper:]' '[:lower:]'`
      sla1=`ls ${DIRIN}/SLA_NRT20_${dirsat}/nrt_med_${SlaName}_sla_vfec_${TCD}*.nc | tail -1`
      echo $sla1
      cp ${sla1} ${DIRWORK}/.
      sla1b=`ls ${DIRIN}/SLA_TPS20_${dirsat}/nrt_med_${SlaName}_sla_assim_vxxc_${TCD}*.nc | tail -1`
      echo $sla1b
      cp ${sla1b} ${DIRWORK}/.
#      for files in `ls *.zip` ; do
#          unzip $files
#      done
#      rm *.zip
#      gzip -d *.gz
      slauno=`find nrt_med_${SlaName}_sla_vfec_${TCD}*.nc | tail -1`
      if [ "$slauno" != '' ] ; then
         sladue=`find nrt_med_${SlaName}_sla_assim_vxxc_${TCD}*.nc | tail -1`
         if [ "$sladue" != '' ] ; then
#      slauno=`basename ${sla1}`
#      sladue=`basename ${sla1b}`
            echo $slauno
            echo $sladue
            echo "${DIRBIN}/prep_SLA20_3dvar_V4.exe $DIRWORK $DIRWORK ${slauno} ${sladue} $TSD"
            ${DIRBIN}/prep_SLA20_3dvar_V4.exe $DIRWORK $DIRWORK ${slauno} ${sladue} $TSD
         else
            echo "No TAPAS for $TCD sat=$dirsat"
         fi
      else
         echo "No SLA for $TCD sat=$dirsat"
      fi
   done
TCD=`jday.py $TCD +1`
done
if [ -f ${DIRWORK}/${TSD}.SLA.dat ] ; then
counter=`wc -l "${DIRWORK}/${TSD}.SLA.dat" | awk '{print $1'}`
echo $counter > ${DIRWORK}/nlinesSLA.txt
cat ${DIRWORK}/nlinesSLA.txt ${DIRWORK}/${TSD}.SLA.dat > ${DIROUT}/SLA.dat
else
   touch ${DIRWORK}/listSLA.txt
   counter=`wc -l "${DIRWORK}/listSLA.txt" | awk '{print $1'}`
   echo $counter > ${DIROUT}/SLA.dat
fi
fi
rm ${DIRWORK}/nlinesSLA.txt ${DIRWORK}/${TSD}.SLA.dat
rm ${DIRWORK}/nrt_* ${DIRWORK}/listSLA.txt
rm ${DIRWORK}/*.txt


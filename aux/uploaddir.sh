#!/bin/sh
#esempio : sh uploaddir.sh MFS_SYS4c/ mfsprod arch-181.s.cmcc.bo.it .
# la dir locale MFS_SYS4c , viene trasferita in mfsprod@arch-181.s.cmcc.bo.it:.

LOCALDIR=$1
REMOTEUSER=$2
REMOTEHOST=$3
REMOTEDIR=$4

ncftpput -R -v -m  -y -o useCLNT=0,useFEAT=0 -u ${REMOTEUSER} ${REMOTEHOST} ${REMOTEDIR} ${LOCALDIR}
eeee=$?
if [ $eeee -ne 0 ]; then
   echo ERRORE $eeee
   exit 1
   fi


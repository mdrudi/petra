CPUPN=$1
PBSQUEUENAME=$2
EXP_NAME=$3
ACTUALINDEX=$4


echo \#!/bin/bash
echo \#BSUB -n ${CPUPN}
echo \#BSUB -R "span[ptile=16]"
echo \#BSUB -q ${PBSQUEUENAME} 
echo \#BSUB -J ${EXP_NAME}
echo \#BSUB -a poe
echo \#BSUB -e ../output/aderr_${ACTUALINDEX}_%J
echo \#BSUB -o ../output/adout_${ACTUALINDEX}_%J
echo 
echo export TagMPIRUN=mpirun.lsf

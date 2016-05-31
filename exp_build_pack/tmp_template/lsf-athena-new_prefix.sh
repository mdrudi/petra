NODES=$1
CPUPN=$2
PBSQUEUENAME=$3
EXP_NAME=$4
ACTUALINDEX=$5


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

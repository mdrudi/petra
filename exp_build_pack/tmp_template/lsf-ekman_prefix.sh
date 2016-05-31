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
echo \#BSUB -e ../output/aderr_${ACTUALINDEX}_%J
echo \#BSUB -o ../output/adout_${ACTUALINDEX}_%J
echo \#BSUB -R "infiniband==up"
echo 
echo export INTELMPI_TOP=/srv/intel/impi/4.1.0.024/intel64
echo export PATH=/srv/intel/impi/4.1.0.024/intel64/bin:$PATH
echo export I_MPI_HYDRA_BOOTSTRAP=lsf
echo export I_MPI_HYDRA_BRANCH_COUNT=`expr $CPUPN / 16` \#64 is number of hosts, i.e., 1024/16
echo export I_MPI_LSF_USE_COLLECTIVE_LAUNCH=1

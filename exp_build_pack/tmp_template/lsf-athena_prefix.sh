CPUPN=$1
PBSQUEUENAME=$2
EXP_NAME=$3
ACTUALINDEX=$4


echo \#!/bin/bash
echo \#BSUB -n ${CPUPN}
echo \#BSUB -R "span[ptile=16]"
echo \#BSUB -q ${PBSQUEUENAME} 
echo \#BSUB -J ${EXP_NAME}
echo \#BSUB -e ../output/aderr_${ACTUALINDEX}_%J
echo \#BSUB -o ../output/adout_${ACTUALINDEX}_%J
echo 
#echo export INTELMPI_TOP=/users/home/opt/intel/impi/5.0.3.048/intel64
echo export I_MPI_HYDRA_BOOTSTRAP=lsf
echo export I_MPI_HYDRA_BRANCH_COUNT=`expr $CPUPN / 16` \#64 is number of hosts, i.e., 1024/16
echo export I_MPI_LSF_USE_COLLECTIVE_LAUNCH=1
echo export TagMPIRUN=mpiexec.hydra

echo module purge
echo module load NETCDF/netcdf-4.3
echo module load NETCDF/netcdf-4.3_parallel
echo module load HDF5/hdf5-1.8.11
echo module load NCO/nco-4.2.5
echo module list
echo export PATH=/users/home/opt/intel/impi/5.0.3.048/intel64/bin:\$PATH

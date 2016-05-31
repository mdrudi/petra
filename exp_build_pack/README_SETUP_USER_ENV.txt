
Ekman
---------1

source /etc/profile.d/modules.sh
module load intel
module load cdo




Athena
---------1

# User specific environment and startup programs

PATH=$PATH:$HOME/local/bin:$HOME/local/share:$HOME/local/include
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/local/lib
LD_RUN_PATH=$LD_RUN_PATH:$HOME/local/lib
export PATH
export LD_LIBRARY_PATH


# colore prompt
export PS1='\[\e[0;36m\][athena]\[\e[0;38m\][$PWD]> '
#eval `dircolors $HOME/.dir_colors`

# load modules Athena
module purge
module load ANACONDA2/python2.7
#module load INTEL/intel_xe_2015.3.187
#module load IMPI/intel_mpi_5.0.3.048
#module load NCVIEW/ncview-2.1.2
module load NETCDF/netcdf-4.3
module load NCO/nco-4.2.5
#module load NCO/nco-4.4.9
module load CDO/cdo-1.6.4
#module load NCL/ncl_ncarg-6.1.2
#module load HDF5/hdf5-1.8.11_parallel
module load NETCDF/netcdf-4.3_parallel
#module load NETCDF/parallel-netcdf-1.3.1
#module load MELD/meld-1.6.1
module list

# avoid problems with stack, memory and core size
ulimit -s unlimited
ulimit -m unlimited
ulimit -c unlimited


# Setting for NEMO compilation
 export NETCDF="/users/home/opt/netcdf/netcdf-4.3"


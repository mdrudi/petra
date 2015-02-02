#!/bin/sh
# Makefile pilot

cd `dirname $0`
DIR0=`pwd`

module load intel

for subdir in change_DOMAIN_number_total input4NEMO  ecmwf2NEMO  ecmwf2WW cosmo2NEMO cosmo2WW ; do 
    
    echo
    Cmd="cd $DIR0/$subdir" ; echo $Cmd ; eval $Cmd
    if [ $subdir != "cosmo2NEMO" ] && [ $subdir != "cosmo2WW" ] ; then
       Cmd="make clean ; make"; echo $Cmd ; eval $Cmd
    else
       if [ $subdir == "cosmo2NEMO" ] ; then
          Cmd="cd emos_000392"   ; echo $Cmd ; eval $Cmd
          Cmd="make clean"; echo $Cmd ; eval $Cmd
          echo
          echo "==NOTE== Now you have to answer to some questions. The answers are:"
          echo "1)y (gfortran/gcc compiler)"
          echo "2)y (64 bit reals)"
          echo "3)n (no grib_api)"
          echo "4). (library will be placed in the current dir)"
          echo 
          Cmd="./build_library "; echo $Cmd ; eval $Cmd
          #Cmd="make ARCH=linux CNAME=_gfortran A64=A64"; echo $Cmd ; eval $Cmd
          Cmd="./install"; echo $Cmd ; eval $Cmd
          Cmd="cd .. "; echo $Cmd ; eval $Cmd
          Cmd="make clean ; make path=. "; echo $Cmd ; eval $Cmd
          echo
          Cmd="make -f Makefile2 clean ; make -f Makefile2"; echo $Cmd ; eval $Cmd
          echo
          Cmd="cd wgrib.dir "; echo $Cmd ; eval $Cmd
          Cmd="make"; echo $Cmd ; eval $Cmd
       fi
       if [ $subdir == "cosmo2WW" ] ; then
          Cmd="ln -fs ../cosmo2NEMO/geofield.exe . "; echo $Cmd ; eval $Cmd
          Cmd="ln -fs ../cosmo2NEMO/wgrib . "; echo $Cmd ; eval $Cmd
          Cmd="make clean ; make"; echo $Cmd ; eval $Cmd
       fi  
    fi
    echo
    


done

SHELL = /bin/sh

############################################################################
#
#        Makefile for input4NEMO 
#
############################################################################
#
#    Copyright 2014 Giacomo Girardi, INGV, Bologna
#
############################################################################
#
# INTEL 
F90 = /srv/intel/impi/4.1.0.024/intel64/bin/mpiifort
P_P = -Dopt_netcdf
P_C = cpp -traditional-cpp
F_O = -c 
F_L = $(F90)
    
RM  = rm -f
                    
EXTINC = -I/srv/lib/netcdf-last/include
EXTLIB = -L/srv/lib/netcdf-last/lib -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lcurl
#LD_LIBRARY_PATH=/srv/intel/impi/4.1.0.024/intel64/lib /usr/lib64/openmpi/lib /srv/lsf/8.0/linux2.6-glibc2.3-x86_64/lib
#INC_PARAMS=$(foreach d, $(LD_LIBRARY_PATH), -I$d)


#GFORTRAN
F90 = gfortran
P_P = -Dopt_netcdf
P_C = cpp -traditional-cpp
F_O = -c 
F_L = $(F90)

INC_PARAMS = /usr/lib64/gfortran/modules /usr/include/
EXTINC = $(foreach d, $(INC_PARAMS), -I$d)
EXTLIB = -L/usr/lib64 -lnetcdf -lnetcdff



SRC = prep_SLA20_3dvar_V3.f90 prep_SLA20_3dvar_V4.f90 prep_ARGO_3dvar_V3.f90 prep_XBT_3dvar_V3.f90  prep_SLA_3dvar_V3.f90 prep_SLA_3dvar_V4.f90 prep_GLIDER_3dvar_V4.f90

OBJS = $(SRC:.f90=.o)
EXEC = $(SRC:.f90=.exe)


all: $(EXEC)
	@echo $(EXEC) are compiled

$(EXEC) :
	$(F_L)  $(@:.exe=.f90)  -o $@  $(EXTINC) $(EXTLIB) 

#$(EXEC) : $(OBJS)
#	$(F_L)  $(@:.exe=.o)  -o $@ $(EXTLIB) 

.f90.o :
	$(F90) $(F_O) $(P_P) $(EXTINC)  -o $@ $<
 
%.o: %.f90 
	$(F90) $(F_O) $(P_P) $(EXTINC)  -o $@ $<
	
clean:
	$(RM) *.o *.mod $(EXEC)

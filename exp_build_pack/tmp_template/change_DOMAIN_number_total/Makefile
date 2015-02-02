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



SRC = change_DOMAIN_number_total.f90

OBJS = $(SRC:.F90=.o)
EXEC = change_DOMAIN_number_total


all: $(EXEC)
	@echo $(EXEC) is compiled

$(EXEC) :
	$(F_L)  $(SRC)  -o $(EXEC)  $(EXTINC) $(EXTLIB) 

#$(EXEC) : $(OBJS)
#	$(F_L)  $(@:.exe=.o)  -o $@ $(EXTLIB) 

.F90.o :
	$(F90) $(F_O) $(P_P) $(EXTINC)  -o $@ $<
 
%.o: %.F90 
	$(F90) $(F_O) $(P_P) $(EXTINC)  -o $@ $<
	
clean:
	$(RM) *.o *.mod $(EXEC)
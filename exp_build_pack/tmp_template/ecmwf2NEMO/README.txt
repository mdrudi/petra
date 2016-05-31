Giacomo Girardi, 03/07/2012
---------------------------

ecmwf2NEMO-20120703.tar.gz 
 

 
Requisiti: nco installato
           librerie netcdf 

*)Dipendenze:
Il pacchetto va inserito in coda all'esecuzione del pacchetto ECMWF che prepara giornalmente in formato NetCDF i forzanti atmosferici.


*)Sintassi: 

sh ecmwf2NEMO-an.sh /mnt/nfs0/tmp/girardi/ecmwf2NEMO/in /mnt/nfs0/tmp/girardi/ecmwf2NEMO/work /mnt/nfs0/tmp/girardi/ecmwf2NEMO/work /mnt/nfs0/tmp/girardi/ecmwf2NEMO/out

sh ecmwf2NEMO-fc.sh /mnt/nfs0/tmp/girardi/ecmwf2NEMO/in /mnt/nfs0/tmp/girardi/ecmwf2NEMO/work /mnt/nfs0/tmp/girardi/ecmwf2NEMO/work /mnt/nfs0/tmp/girardi/ecmwf2NEMO/out

ecmwf2NEMO-an.sh  e ecmwf2NEMO-fc.sh richiamano ecmwf2NEMO.sh il quale riassembla gli ecmwf e applica seaoverland.exe

./seaoverland.exe﻿in.nc nome_var nlon nlat ntime in.nc(in cui e' contenuto nome_var_maschera) nome_var_maschera


*)Portabilita':

ecmwf2NEMO.sh va adattata solo se cambiano il nome delle coordinate e delle variabili nel file di input. 
seaoverland.F90 E' stato implementato per variabili superficiali.
                Il numero di loop e' stato stabilito pari a 15. (riga 108)

*) Installazione:
brachetto: g95 -o seaoverland.exe seaoverland.F90 -lnetcdf -I/usr/local/include
brunello:  f90 -o seaoverland.exe seaoverland.F90 -I/home/girardi/bin/include -L/home/girardi/bin/lib -lnetcdf
      

      
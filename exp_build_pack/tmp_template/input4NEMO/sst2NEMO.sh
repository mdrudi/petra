#!/bin/sh
## Shift SST di input su griglia modello NEMO MFS16 
## Giacomo Girardi, 12.02.2013

InDir=$1
WorkDir=$2
LogDir=$3
OutDir=$4

BinDir=`dirname $0`

Cmd="cd $WorkDir"
echo $Cmd
eval $Cmd


for InFile in `ls -1 $InDir/*.nc` ; do
  if [ -f $InFile ] ; then

	Cmd="rm -f *.nc lat2 boundary rest"
	echo $Cmd
	eval $Cmd

	AnalysedDay=`basename $InFile | cut -c 1-8`
	yyyy=`echo $AnalysedDay | cut -c"1-4"`
        mm=`echo $AnalysedDay | cut -b"5 6"`
	dd=`echo $AnalysedDay | cut -b"7 8"`

	Cmd="ncks -O -d lat,0,251 -v analysed_sst,analysis_error  $InFile 1.nc "
	echo $Cmd
	eval $Cmd

	Cmd="ncatted -h -a ,lat,d,, -a ,lon,d,, -a ,global,d,, -a ,analysed_sst,d,,  -a ,analysis_error,d,, 1.nc  "
	echo $Cmd
	eval $Cmd

	Cmd="ncatted -a scale_factor,analysed_sst,c,f,0.01 -a units,analysed_sst,c,c,'Celsius'  -a _FillValue,analysed_sst,c,s,-99 1.nc "
	echo $Cmd
	eval $Cmd
	Cmd="ncatted -a scale_factor,analysis_error,c,f,0.01 -a units,analysis_error,c,c,'Celsius'  -a _FillValue,analysis_error,c,s,-99 1.nc "
	echo $Cmd
	eval $Cmd  

	Cmd="cdo setmissval,0 1.nc 2.nc"
	echo $Cmd
	eval $Cmd 

	Cmd="ncks -O -d lat,1 -v analysed_sst,analysis_error  2.nc lat2"
	echo $Cmd
	eval $Cmd

	Cmd="ncks -O -d lat,0 -v analysed_sst,analysis_error  2.nc boundary"
	echo $Cmd
	eval $Cmd

	Cmd="ncks -O -d lat,1,251 -v analysed_sst,analysis_error  2.nc rest"
	echo $Cmd
	eval $Cmd


	Cmd="ncap -O -s 'lat=30.25'   lat2 lat2"
	echo $Cmd
	eval $Cmd
	Cmd="ncecat -O -h lat2 lat2"
	echo $Cmd
	eval $Cmd
	Cmd="ncpdq -O -h -a lat,record lat2 lat2"
	echo $Cmd
	eval $Cmd

	Cmd="ncap -O -s 'lat=30.1875'   boundary boundary"
	echo $Cmd
	eval $Cmd
	Cmd="ncecat -O -h boundary boundary"
	echo $Cmd
	eval $Cmd
	Cmd="ncpdq -O -h -a lat,record boundary boundary"
	echo $Cmd
	eval $Cmd

	Cmd="ncecat -O -h rest shift.nc "
	echo $Cmd
	eval $Cmd
	Cmd="ncpdq -O -h -a lat,record shift.nc  shift.nc "
	echo $Cmd
	eval $Cmd
	Cmd="ncrcat -O  boundary lat2 south.nc "
	echo $Cmd
	eval $Cmd


	Cmd="ncrcat -O  south.nc shift.nc new.nc "
	echo $Cmd
	eval $Cmd
	Cmd="ncwa -O -a record new.nc new.nc"
	echo $Cmd
	eval $Cmd
	Cmd="ncpdq -O -h -a time,lat new.nc new.nc"
	echo $Cmd
	eval $Cmd

	Cmd="ncrename -h -d lon,x -d lat,y new.nc"
	echo $Cmd
	eval $Cmd

	Cmd="ncatted  -a units,analysed_sst,c,c,'Celsius' -a units,analysis_error,c,c,'Celsius' new.nc"
	echo $Cmd
	eval $Cmd

	Cmd="ncks -O -v analysed_sst,analysis_error new.nc new.nc"
	echo $Cmd
	eval $Cmd

	Cmd="ncbo -O -y mlt new.nc $BinDir/Tmask.nc new.nc"
	echo $Cmd
	eval $Cmd

	OutName=`echo sst_data_y${yyyy}m${mm}d${dd}.nc`
	Cmd="mv new.nc ${OutDir}/${OutName}"   
	echo $Cmd
	eval $Cmd

 fi
done

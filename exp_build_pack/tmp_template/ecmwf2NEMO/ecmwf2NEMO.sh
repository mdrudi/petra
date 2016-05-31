#!/bin/sh

## Giacomo Girardi, 19.06.2012
##
InDir=$1
WorkDir=$2
LogDir=$3
OutDir=$4
TypeFc=$5

BinDir=`dirname $0`
export PATH=$PATH:$BinDir

##### Applicazione SeaOverLand #######

SeaOverLand () {


for par in u10 v10 clc msl t2 rh precip ; do

   Cmd="$BinDir/seaoverland.exe $1 $par 489 145 $3 $1 LSM "
   echo $Cmd
   eval $Cmd

done


}
########
CheckLogs () {

ncrename -d lat,y -d lon,x  $1 	  #-d time,time_counter -v time,time_counter
ncrename -v U10M,u10 -v V10M,v10 -v TCC,clc -v MSL,msl -v T2M,t2 -v D2M,rh $1

Cmd="SeaOverLand $1 $3 $4"
echo $Cmd
eval $Cmd

grep -i 'ERROR' $OutDir/log_ecmwf2NEMO.txt > err.log
grep -i 'STOP'  $OutDir/log_ecmwf2NEMO.txt >> err.log
   if [ `wc -l err.log | awk '{ print $1 }'` -eq 0 ]; then
	   
	  Cmd="ncpdq -O -a -y $1 $2"   # reverse y
	  echo $Cmd
      eval $Cmd
   else
	  echo "ERROR(s) found! STOP"
	  cat err.log
	  exit
   fi
}


Cmd="cd $WorkDir"
echo $Cmd
eval $Cmd

# Clear the logfile  
>$OutDir/log_ecmwf2NEMO.txt  

pipe1="$OutDir/mypipe1.$$"
pipe2="$OutDir/mypipe2.$$"
trap 'rm "$pipe1" "$pipe2"' EXIT
mkfifo "$pipe1"
mkfifo "$pipe2"
tee -a $OutDir/log_ecmwf2NEMO.txt < "$pipe1" &
tee -a $OutDir/log_ecmwf2NEMO.txt >&2 < "$pipe2" &

# Redirect all script output to a logfile as well as their normal locations  
exec >"$pipe1"
exec 2>"$pipe2"

Cmd="ls -la $InDir"
echo $Cmd
eval $Cmd

ProcDay=`ls -1 $InDir/*nc |head -1`
ForecastDay=`basename $ProcDay | cut -d - -f 7 |cut -d _ -f1 |cut -c 2-9`
echo '----ForecastDay('${TypeFc}'):'${ForecastDay}'----'

StartDay=`basename $InDir/startday.* | cut -d . -f2`
EndDay=`basename $InDir/endday.* | cut -d . -f2`

         
for FileAn in `ls -1 $InDir/*_an-fv05.00.nc ` ; do

 	yyyy=`basename $FileAn | cut -c"1-4"`
 	mm=`basename $FileAn | cut -b"5 6"`
 	dd=`basename $FileAn | cut -b"7 8"`
    today_i=${yyyy}${mm}${dd}
    echo $today_i
    
    Cmd="rm -f err.log tmp.nc" ; echo $Cmd ; eval $Cmd
      
    if [ $today_i -ge $StartDay ] && [ $today_i -le $EndDay ] ; then
 	  Cmd="cp $FileAn tmp.nc" ; echo $Cmd ; eval $Cmd

 	  OutName=`echo ecmwf_y${yyyy}m${mm}d${dd}.nc`
 	  Cmd="CheckLogs tmp.nc ${OutDir}/${OutName} an 4"
 	  echo $Cmd
 	  eval $Cmd
 	  
 	fi
done




for FileAn in `ls -1 $InDir/*_antmp-fv05.00.nc` ; do

        yyyy=`basename $FileAn | cut -c"1-4"`
        mm=`basename $FileAn | cut -b"5 6"`
        dd=`basename $FileAn | cut -b"7 8"`
    today_i=${yyyy}${mm}${dd}
    echo $today_i

    Cmd="rm -f err.log tmp.nc" ; echo $Cmd ; eval $Cmd

    if [ $today_i -ge $StartDay ] && [ $today_i -le $EndDay ] && [ $TypeFc == 'an' ] ; then
          Cmd="cp $FileAn tmp.nc"
          echo $Cmd
          eval $Cmd

          OutName=`echo ecmwf_y${yyyy}m${mm}d${dd}.nc`
          Cmd="CheckLogs tmp.nc ${OutDir}/${OutName} an 3"
          echo $Cmd
          eval $Cmd

    fi
done



if [ $TypeFc == 'fc' ] ; then

   FileFc=`ls -1 $InDir/*b${ForecastDay}_fc12*.nc`	
   FileAn=`ls -1 $InDir/*b${ForecastDay}_antmp*.nc`


   for i in 0 1 2 3 4 5 6 7 8 9 10 ; do

         today_i=`jday.py $ForecastDay +$i`
         echo $today_i
#
         yyyyi=`echo $today_i | cut -c"1-4"`
         mi=`echo $today_i | cut -b"5 6"`
         di=`echo $today_i | cut -b"7 8"`
         OutName=`echo "ecmwf_y"${yyyyi}"m"${mi}"d"${di}".nc"`
         
         if [ $today_i -ge $StartDay ] && [ $today_i -le $EndDay ] ; then
             todo=1
         else
             todo=0
         fi
           
#
   Cmd="rm -f err.log fc* rec* tmp.nc"
   echo $Cmd
   eval $Cmd

   ntime=4
   if [ $i -eq 0 ] && [ $todo -eq 1 ]; then 
   
     #file con 4 record per il  giorno di SM
      Cmd="cp $FileAn tmp.nc"       ;echo $Cmd;eval $Cmd
#      Cmd="ncks -x -v time,lat,lon $FileAn tmp.nc"       ;echo $Cmd;eval $Cmd                    #analisi h 00 ,06 , 12
      Cmd="ncks -d time,6. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc.nc"  ;echo $Cmd;eval $Cmd   #ore 18 del primo giorno fc
      Cmd="ncap -O -s 'time[time]=18' fc.nc fc_time.nc"  ;echo $Cmd;eval $Cmd
      Cmd="ncrcat tmp.nc fc_time.nc fc${i}.nc"           ;echo $Cmd;eval $Cmd
      echo
     #file con 8 record per il primo giorno di FC 
      Cmd="ncks -d time,0 -x -v lat,lon $FileAn rec1.nc" ;echo $Cmd;eval $Cmd     #analisi h 00 
      Cmd="ncks -d time,0 -x -v lat,lon $FileAn rec2.nc" ;echo $Cmd;eval $Cmd     #analisi h 03 = 00
      Cmd="ncap -O -s 'time[time]=3' rec2.nc rec2.nc"    ;echo $Cmd;eval $Cmd
      Cmd="ncks -d time,1 -x -v lat,lon $FileAn rec3.nc" ;echo $Cmd;eval $Cmd     #analisi h 06
      Cmd="ncks -d time,1 -x -v lat,lon $FileAn rec4.nc" ;echo $Cmd;eval $Cmd	  #analisi h 09 = 06
      Cmd="ncap -O -s 'time[time]=9' rec4.nc rec4.nc"    ;echo $Cmd;eval $Cmd
      Cmd="ncks -d time,2 -x -v lat,lon $FileAn rec5.nc ";echo $Cmd;eval $Cmd     #analisi h 12 
      Cmd="ncks -d time,3. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc15.nc" ;echo $Cmd;eval $Cmd #ore 15 del primo giorno fc
      Cmd="ncap2 -O -s 'time[time]=15' fc15.nc fc15.nc" ;echo $Cmd;eval $Cmd
      Cmd="ncks -d time,6. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc18.nc" ;echo $Cmd;eval $Cmd #ore 18 del primo giorno fc
      Cmd="ncap2 -O -s 'time[time]=18' fc18.nc fc18.nc" ;echo $Cmd;eval $Cmd
      Cmd="ncks -d time,9. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc21.nc" ;echo $Cmd;eval $Cmd #ore 21 del primo giorno fc
      Cmd="ncap2 -O -s 'time[time]=21' fc21.nc fc21.nc" ;echo $Cmd;eval $Cmd
      Cmd="ncrcat -O rec*.nc fc15.nc fc18.nc fc21.nc fc${i}.nc_8rec" ;echo $Cmd;eval $Cmd
  
      Cmd="CheckLogs fc${i}.nc_8rec ${OutDir}/${OutName}_8rec $TypeFc 8"
      echo $Cmd
      eval $Cmd   
   fi
   
   if [ $i -ge 1  -a $i -le 2 ] && [ $todo -eq 1 ]; then 
    
      ntime=8 
      n1=`expr 24 \* $i - 12`  
       Cmd="ncks -d time,${n1}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_h00" ;echo $Cmd;eval $Cmd
      for nn in 3 6 9 12 15 18 21 ; do
      n2=`expr $n1 + ${nn}`
       Cmd="ncks -d time,${n2}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_h${nn}" ;echo $Cmd;eval $Cmd
      done
       Cmd="ncrcat -O fc${i}.nc_h00 fc${i}.nc_h3 fc${i}.nc_h6 fc${i}.nc_h9 fc${i}.nc_h12 fc${i}.nc_h15 fc${i}.nc_h18 fc${i}.nc_h21 fc${i}.nc" ; echo $Cmd ; eval $Cmd
       Cmd="rm -f fc${i}.nc_h*" ; echo $Cmd ; eval $Cmd 
       #ncap2 -O -s 'time(:)={0,3,6,9,12,15,18,21}' fc${i}.nc fc${i}.nc
   fi
   if [ $i -eq 3 ] && [ $todo -eq 1 ]; then 
    
      n1=`expr 24 \* $i - 12`  
      n2=`expr $n1 + 18`
      n3=`expr $n1 + 12`
      n4=`expr $n1 + 6`
      
       Cmd="ncks -d time,${n1}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_00" ;echo $Cmd;eval $Cmd   #0  
       Cmd="ncks -d time,${n4}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_06" ;echo $Cmd;eval $Cmd   #6
       Cmd="ncks -d time,${n3}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_12" ;echo $Cmd;eval $Cmd   #12
       Cmd="ncks -d time,${n2}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_18" ;echo $Cmd;eval $Cmd       # 18
       Cmd="ncrcat -O fc${i}.nc_* fc${i}.nc" ;echo $Cmd;eval $Cmd	  # 4 record	
       n5=`expr $n1 + 3`
       Cmd="ncks -d time,${n5}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_03" ;echo $Cmd;eval $Cmd #3
       n6=`expr $n1 + 9`
       Cmd="ncks -d time,${n6}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_09" ;echo $Cmd;eval $Cmd #9
       Cmd="ncks -d time,${n3}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_15=12" ;echo $Cmd;eval $Cmd  #15
       hr=`expr $n3 + 3`
       Cmd="ncap -O -s 'time[time]=$hr' fc${i}.nc_15=12 fc${i}.nc_15=12" ; echo $Cmd ; eval $Cmd
       #Cmd="ncrcat -O fc${i}.nc_00-12 fc${i}.nc_15=12 5rec.nc" ; echo $Cmd ; eval $Cmd 
       hr=`expr $n3 + 6`
#       Cmd="ncks -d time,${hr}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_18" ; echo $Cmd;eval $Cmd
       #ncrcat -O 5rec.nc fc${i}.nc_hr18 6rec.nc
       Cmd="ncks -d time,${hr}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_21=18"; echo $Cmd;eval $Cmd
       hr=`expr $hr + 3`
       Cmd="ncap -O -s 'time[time]=$hr' fc${i}.nc_21=18 fc${i}.nc_21=18" ; echo $Cmd ; eval $Cmd
       Cmd="ncrcat -O fc${i}.nc_00 fc${i}.nc_03 fc${i}.nc_06 fc${i}.nc_09 fc${i}.nc_12 fc${i}.nc_15=12 fc${i}.nc_18 fc${i}.nc_21=18 fc${i}.nc_8rec" ; echo $Cmd ; eval $Cmd       						   #8 record
  
      Cmd="CheckLogs fc${i}.nc_8rec ${OutDir}/${OutName}_8rec $TypeFc 8"    
      echo $Cmd
      eval $Cmd
  
   fi
   if [ $i -ge 4 -a $i -le 9 ] && [ $todo -eq 1 ]; then 
    
      n1=`expr 24 \* $i - 12`  
      n2=`expr $n1 + 6`
      n3=`expr $n1 + 12`
      n4=`expr $n1 + 18`
      
       Cmd="ncks -d time,${n1}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_00"; echo $Cmd ; eval $Cmd
       Cmd="ncks -d time,${n2}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_06"; echo $Cmd ; eval $Cmd
       Cmd="ncks -d time,${n3}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_12"; echo $Cmd ; eval $Cmd
       Cmd="ncks -d time,${n4}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_18"; echo $Cmd ; eval $Cmd
       Cmd="ncrcat -O fc${i}.nc_00 fc${i}.nc_06 fc${i}.nc_12 fc${i}.nc_18 fc${i}.nc" ; echo $Cmd ; eval $Cmd 
  fi
   if [ $i -eq 10 ] && [ $todo -eq 1 ] ; then 
    
      n1=`expr 24 \* $i - 12`  
      n2=`expr $n1 + 6`
      n3=`expr $n1 + 12`
    
       Cmd="ncks -d time,${n1}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_00" ; echo $Cmd; eval $Cmd
       Cmd="ncks -d time,${n2}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_06" ; echo $Cmd; eval $Cmd
       Cmd="ncks -d time,${n3}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_12" ; echo $Cmd; eval $Cmd
       Cmd="ncrcat -O fc${i}.nc_00 fc${i}.nc_06 fc${i}.nc_12 fc${i}.nc" ; echo $Cmd ; eval $Cmd
      ntime=3 
      #Cmd="ncks -d time,${n2}. -x -v SSRD,STRD,SSR,STR,LSP,CP $FileFc fc${i}.nc_hr12" ; echo $Cmd; eval $Cmd
      #hr=`expr $n2 + 6`
      #Cmd="ncap -O -s 'time[time]=$hr' fc${i}.nc_hr12 fc${i}.nc_hr12" ; echo $Cmd ; eval $Cmd
      #Cmd="ncrcat -O fc${i}.nc fc${i}.nc_hr12 fc${i}.nc " ; echo $Cmd; eval $Cmd
   fi
 
   if [ $todo -eq 1 ] ; then 
      Cmd="CheckLogs fc${i}.nc ${OutDir}/${OutName} $TypeFc $ntime"
      echo $Cmd
      eval $Cmd
   fi
 done


fi #end of Forecast

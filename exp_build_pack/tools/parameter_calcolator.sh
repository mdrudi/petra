#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# starting time of the first simulation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
start_time='20040107'

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# starting time of the last simulation
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
endin_time='20041231'

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# length of each simulation in days
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
simu_length='1'

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# time-step for the physical model
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
time_step='600'

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# convert to julian
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
start_jul=`./yday-ref-01-01-1970.py $start_time -0`
endin_jul=`./yday-ref-01-01-1970.py $endin_time -0`
#start_jul=`/home/oddo/bin/my_jday $start_time -0`
#endin_jul=`/home/oddo/bin/my_jday $endin_time -0`
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

n_days=`expr $endin_jul \- $start_jul`

n_time_step=`expr  $n_days \* 86400 `

n_time_step=`expr  $n_time_step \/ $time_step `

steps_per_simu=`expr $simu_length \* 86400 `

steps_per_simu=`expr $steps_per_simu \/ $time_step `

echo ---CALIBRATION INPUT---
echo start_time = 20040107
echo endin_time = 20041231
echo simu_length = 3
echo time_step = 600
echo 
echo ----CALIBRATION OUTPUT PARAMETER----
echo start_time = 20040107
echo n_time_step = 51696
echo steps_per_simu = 432
echo 
echo 

echo ---INPUT--- 
echo start_time = $start_time
echo endin_time = $endin_time
echo simu_length = $simu_length
echo time_step = $time_step
echo
echo ----OUTPUT PARAMETER----
echo start_time = $start_time
echo n_time_step = $n_time_step
echo steps_per_simu = $steps_per_simu 
echo

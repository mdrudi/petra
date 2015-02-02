#date -u "+%Y/%m/%d:%H:%M:%S %z"
timestamp=$1

if [ $timestamp == 'now' ]; then
   timestamp=`now-YYYYMMDDHHMMSS.sh`
   fi

tsYYYY=`echo $timestamp | cut -c1-4`
tsMM=`echo $timestamp | cut -c5-6`
tsDD=`echo $timestamp | cut -c7-8`
tsHH=`echo $timestamp | cut -c9-10`
tsMm=`echo $timestamp | cut -c11-12`
tsSS=`echo $timestamp | cut -c13-14`

echo ${tsYYYY}/${tsMM}/${tsDD}:${tsHH}:${tsMm}:${tsSS}

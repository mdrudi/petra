#!/bin/sh
#esempio di utilizzo : sh checktransf.sh SLA > /{PATH}/SLA.md5sum

DIR=`basename $1`
cd `dirname $1`

echo "---------1" 
for file in `find $DIR -type f | sort -u` ; do
       md5sum $file 
done
echo "---------1"

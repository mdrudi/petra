#!/bin/sh
host=`head -1 $1 | tail -1 | awk '{print $2}'`
user=`head -2 $1 | tail -1 | awk '{print $2}'`
pass=`head -3 $1 | tail -1 | awk '{print $2}'`
ncftp -u ${user} -p ${pass} ftp://${host}${2} <<EOF
rm $3
EOF

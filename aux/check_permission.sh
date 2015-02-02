#!/bin/sh

NotWrite () {

descr=$1
nchar=$2
char=$3

if [  $nchar -eq 3  -o  $nchar -eq 6  -o  $nchar -eq 9  ] && [ _$char != '_-' ]; then
   echo $descr  "user writable:" $perm instead of -r--r--r-- 
   cmd="chmod -w $riga" ; echo $cmd ; eval $cmd
fi

}

cd `dirname $0`
MyPath=`pwd`
OpPath=`dirname $MyPath | cut -d/ -f1-4` #$HOME/MFS_SYS4C
cd $OpPath
list="$HOME/tmplist.txt"
ls -d Lp*/* cosmo*/* forcing*/* indata*/*  > $list
nline=`cat $list | wc -l `
line=1
  while [ $line -le $nline ] ; do
      riga=`cat $list | head -$line | tail -1`
      dir=`dirname $riga`  
      descr=`basename $riga`
      if [ -d $riga ] ; then
         cmd="ls -l $dir | grep '${descr}$' | awk '{print \$1}'" #; echo $cmd
         perm=`eval $cmd`
      else
         cmd="ls -l $riga | awk '{print \$1}'" #; echo $cmd 
         perm=`eval $cmd` 
      fi    
      if [ `echo $descr | cut -d. -f2` == "upload" ]  ; then
               for nchar in `seq 1 10` ; do
                   char=`echo $perm | cut -c $nchar`
          
                  NotWrite $descr $nchar $char
                  if [ $nchar -ge 8 ] && [ _$char != '_-' ]; then
                     echo $descr "readable from o:" `echo $perm | cut -c 8-10` instead of ---
                     cmd="chmod o-r $riga" ; echo $cmd ; eval $cmd
                  fi
                  if [ $nchar -eq 4  -o  $nchar -eq 7  -o  $nchar -eq 10 ] && [ _$char == '_x' ]; then
                     echo $descr "should be not executable :"  $perm  instead of -r--r----- 
                     cmd="chmod -x $riga" ; echo $cmd ; eval $cmd
                  fi
               done
       else
               if [  `echo $perm | cut -c 1` == 'd'  ] ; then
                    if  [ $perm != "dr-xr-xr-x" ] ; then
                         echo $descr "is a directory with " $perm instead of dr-xr-xr-x : change to 555    
                         cmd="chmod 555 $riga" ; echo $cmd ; eval $cmd
                    fi
               else 
                  for nchar in `seq 1 10` ; do
                   char=`echo $perm | cut -c $nchar`
                   NotWrite $descr $nchar $char
                   if [  $nchar -eq 2  -o  $nchar -eq 5  -o  $nchar -eq 8  ] && [ _$char != '_r' ]; then
                     echo $descr "not readable from users:" $perm instead of -r--r--r--
                     cmd="chmod +r $riga" ; echo $cmd ; eval $cmd
                   fi
                  
                 done
             fi
        fi
     line=`expr $line + 1`
  done

rm -f $list

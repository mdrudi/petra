#!/bin/sh

if [ $1 = "list" ]; then
   echo ingv2.txt 
   fi

if [ $1 = "dest" ]; then
   # $2=ProcDay
   # $3=LineNumber
   #echo `sh $0 rolloff_dest`/$2
   echo /home/`whoami`/transf.indata/PO/$2
   fi

if [ $1 = "hstart" ]; then
   echo ${2}0025
   fi

if [ $1 = "netcfg" ]; then
   echo host http://www.smr.arpa.emr.it/esterni/daphne/
   echo user XXXXX
   echo pass XXXXX
   fi

if [ $1 = "prot" ]; then
   echo http
   fi

if [ $1 = "rolloff" ]; then
   echo 3
   fi

if [ $1 = "rolloff_dest" ]; then
   echo /home/`whoami`/transf.indata/PO/"*"
   fi


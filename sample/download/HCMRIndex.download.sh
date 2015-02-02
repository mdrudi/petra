#!/bin/sh

if [ $1 = "list" ]; then
   echo pub/index_latest.txt
   fi

if [ $1 = "dest" ]; then
   echo /home/`whoami`/transf.indata/HCMRIndex/$2
   fi

if [ $1 = "hstart" ]; then
   echo ${2}0025
   fi

if [ $1 = "netcfg" ]; then
   echo host medinsitu.hcmr.gr 
   echo user XXXXXX 
   echo pass XXXXXX
   fi

if [ $1 = "prot" ]; then
   echo ftp
   fi

if [ $1 = "rolloff" ]; then
   echo 4
   fi

if [ $1 = "rolloff_dest" ]; then
   echo /home/`whoami`/transf.indata/HCMRIndex/"*"
   fi


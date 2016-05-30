#! /usr/bin/env python

import sys

lnum=list()

instr=sys.stdin.readline().replace("\r","").replace("\n","").replace(" ","").replace("\t","")
num_instr=int(instr)
#print num_instr
while instr :
   #print instr
   instr=sys.stdin.readline().replace("\r","").replace("\n","").replace(" ","").replace("\t","")
   try :
      #print int(instr)
      delta=int(instr)-num_instr
      #print delta
      num_instr=int(instr)
      lnum.append(delta)
   except :
      pass
#print lnum
for item in lnum : 
   sys.stdout.write(str(item))
   sys.stdout.write(',')
sys.stdout.write('\n')

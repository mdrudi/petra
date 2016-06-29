# ls /scratch/test/drudi/exp/eas1_t0tri/output/adout_* | sh delta.sh TagSecCounterP
# echo output/adout_1_500471 | delta.sh TagSecCounter
#
# per mettere i numeri in colonna :
# ls eas1_t0qua/log.txt | delta.sh TagSec | tr "," "\n"

pro() {
   cut -d '-' -f 2 | cut -d ' ' -f3 | delta.py
   }


while read filename ; do
   grep $1 $filename | pro
   done

#cd path/expname
#how_long.sh
for file in `ls -rt $1/output/bhist_*`; do tail -2 $file | head -1 | cut -c21-24 ; done

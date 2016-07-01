#cd path/expname
#how_long.sh
#for file in `ls -rt $1/output/bhist_*`; do tail -2 $file | head -1 | cut -c21-24 ; done
#ls p1.0-72/output/bhist_P* -rt | how_long.sh
while read file; do tail -2 $file | head -1 | cut -c21-24 ; done

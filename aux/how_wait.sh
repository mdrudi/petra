#cd path/expname
#how_wait.sh
#for file in `ls -rt $1/output/bhist_*`; do tail -2 $file | head -1 | cut -c3-7 ; done
#ls p1.0-72/output/bhist_P* -rt | how_wait.sh
while read file; do tail -2 $file | head -1 | cut -c3-7 ; done

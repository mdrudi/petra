#cd path/expname
#how_real.sh
#for file in `ls -rt $1/output/bhist_*`; do tail -2 $file | head -1 | cut -c57- ; done
#ls p1.0-72/output/bhist_P* -rt | how_real.sh
while read file; do tail -2 $file | head -1 | cut -c57- ; done

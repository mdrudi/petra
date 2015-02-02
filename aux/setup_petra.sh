petra_custom=$1;export petra_custom

. `dirname $0`/../envi.sh

export EventMng

echo
echo FTLogDir=$FTLogDir
echo TILogDir=$TILogDir
echo SCLogDir=$SCLogDir
echo SCWorkDirBase=$SCWorkDirBase
echo EVEventSpace=$EVEventSpace
echo MNLogDir=$MNLogDir
echo

list=" `dirname $FTLogDir` `dirname $TILogDir` `dirname $SCLogDir` `dirname $SCWorkDirBase` `dirname $EVEventSpace` `dirname $MNLogDir`"

for dir in $list; do
   if [ ! -d $dir ]; then
      echo WARNING missing dir $dir
   fi
done

echo
echo START NEW bash SESSION....
echo

bash

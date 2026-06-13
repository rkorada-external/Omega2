#set -x 
struct=$1
h=$2
fl=$3
maxLine=$4

#gcc -fpreprocessed -dD -E /scor/scoromega/otec/sc/estserv.h > estserv.h_woc

#echo
#echo "displayBinaryFile.sh " $struct $h $fl $maxLine $struct

$DUTI/scripts/displayBinaryFile/displayBinaryFile.py $h $struct   > desc.txt 
$DUTI/scripts/displayBinaryFile/displayBinaryFile.exe desc.txt  $fl   $struct $maxLine


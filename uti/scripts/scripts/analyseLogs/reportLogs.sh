#set -x
dir_exe=`dirname $0`
rm $DFILT/ElapsesStep.txt
rm $DFILT/ElapsesChain.txt
files="$1"
echo files	
for log in `ls "$1"`
do
	dn="$(dirname $log)"
	bn="$(basename $log)"
	dt=`echo $bn |  cut -d'_' -f4 | cut -c1-8` 
	${dir_exe}/reportLogs1.py $dn $bn $dt 
done

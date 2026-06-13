#set -x
rm $DFILT/ElapsesStep.txt
rm $DFILT/ElapsesChain.txt
files=$1
echo $files	
for log in `ls $1`
do
	#echo "--------------------$log  -----------"
	dn="$(dirname $log)"
	bn="$(basename $log)"
	dt=`ls -tr $log | head -1 | cut -d '_' -f5 | cut -c1-8` 
	/scor/scoromega/runnable/uti/scripts/analyseLogs/reportLogs1.py $dn $bn $dt 
done

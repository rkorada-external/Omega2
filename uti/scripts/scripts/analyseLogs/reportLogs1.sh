rep=$1
#set -x
rm $DFILT/ElapsesStep.txt
rm $DFILT/ElapsesChain.txt
for log in `ls $rep  | grep "P_ST\|P_ES\|P_RT\|P_DW" `
do
	#echo $log
	#dn="$(dirname $log)"
	#bn="$(basename $log)"
	dt=`ls -tr $rep/$log | head -1 | cut -d '_' -f5 | cut -c1-8` 
	/scor/scoromega/runnable/uti/scripts/analyseLogs/reportLogs1.py  $rep  $log $dt
done

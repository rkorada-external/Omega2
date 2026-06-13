#set -x
files=$1
dlog=$2
dt0=$3

for chain in `cat $files`
do	
	cd $dlog 
	for log in `ls *_${chain}*$dt0*.log`	
	do 
		dn="$(dirname $log)"
		dn=.
		bn="$(basename $log)"
		dt=`ls -tr $log | head -1 | cut -d '_' -f4 | cut -c1-8` 
		/scor/scoromega/runnable/uti/scripts/analyseLogs/reportLogs.py $dn $bn $dt 
	done
	cd - 
done

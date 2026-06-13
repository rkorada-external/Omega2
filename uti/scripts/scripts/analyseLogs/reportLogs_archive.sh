#set -x
rm ElapsesStep.txt
rm ElapsesChain.txt

for log in `ls /scordata02_archivage_dcvprdobbatch/ubeu/DLOG_20190930.zip`
#for log in  `ls /scordata02_archivage_dcvprdobbatch/ubeu/DLOG_*.zip`
do
	bn="$(basename $log)"
    if [ "$bn" \> "DLOG_20171200" ]; 
	then
		rm tmp/*
		unzip -jo $log   -d tmp
		dt=`ls -tr tmp | head -1 | cut -d '_' -f4 | cut -c1-8` 
		echo "date: " $dt
		reportLogs.py tmp/ 'P_*.log' $dt 
	fi
done

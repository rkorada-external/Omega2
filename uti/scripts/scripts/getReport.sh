#!/bin/ksh
#set -x
rm tmpReport.dat

#csvFile=/scor/scoromega/delivery/OM2.DELIVERY/OM2.3F_DELIVERY_ITK.csv
csvFile=$1
for rev in `svn log $csvFile | grep '^r[0-9]* ' | cut -d" " -f1 | cut -d'r' -f2` 
do
	#if  [  $rev  -gt 385984 ] ;	then
		#echo $rev ">"  "385984"
		svn cat -r $rev $csvFile  | dos2unix |sed -e s'/,/;/g' | awk -v rev=$rev 'BEGIN{FS=";"; } { print $0";"rev}' >> tmpReport.dat
	#fi
done

sort -u tmpReport.dat | grep '^o...'  > tmpReport2.dat

getReport.py

sort -u tmpReport3.dat > report_`date +"%Y-%m-%d_%H:%M"`.csv 

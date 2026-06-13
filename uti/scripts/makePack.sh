#!/bin/ksh
#set -x
rm tmp.dat

#csvFile=/scor/scoromega/delivery/OM2.DELIVERY/OM2.3F_DELIVERY_ITK.csv
csvFile=$1
for rev in `svn log $csvFile | grep '^r[0-9]* ' | cut -d" " -f1 | cut -d'r' -f2` 
do
	#if  [  $rev  -gt 385984 ] ;	then
		#echo $rev ">"  "385984"
		svn cat -r $rev $csvFile  | dos2unix | awk -v rev=$rev 'BEGIN{FS=";"; } { print $0";"rev}' >> tmp.dat
	#fi
done

sort -u tmp.dat | grep '^o...'  > tmp2.dat

/scor/scoromega/runnable/uti/scripts/makePack.py $2

sort -u tmp3.dat > PackUAT_`date +"%Y-%m-%d_%H:%M"`.csv 

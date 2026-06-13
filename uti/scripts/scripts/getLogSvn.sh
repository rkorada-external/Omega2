
#set -x
# getLogSvn.sh 4C 2022-12-21


branche=$1
rev=`echo "$2 + 1"| bc`
env=$3
root_delivery="/scor/scoromega/delivery/${branche}_DELIVERY/"

fic=/scor/scoromega/delivery/${branche}_DELIVERY/OM2.DELIVERY/OM2.${branche}_DELIVERY_AZ${env}.csv

# pour le tester sur une seule ligne 
#grep ESFC3690.c $fic > /tmp/tmp1.dat
#fic="/tmp/tmp1.dat"

rm /tmp/info.txt
for fs in `cut -d";" -f1,3 $fic`
do
	f=`echo "$fs"| cut -d";" -f1`
	spira=`echo " $fs"|grep -Eo '[0-9]{5,6}'`
	if [ -e "$root_delivery/$f" ]
	then
		echo "#-#-#- $root_delivery/$f;$spira" >> /tmp/info.txt
		svn log -r${rev}:head $root_delivery/$f >> /tmp/info.txt	
	fi
done

grep -v '^$' /tmp/info.txt > /tmp/info2.txt 

root=`dirname $0`
${root}/getAllRevisons.py  /tmp/info2.txt ${branche} > /tmp/out.dat
bcp  BTRAV..SVN_REVISIONS_${branche} in /tmp/out.dat -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t';' -errr -Jiso_1


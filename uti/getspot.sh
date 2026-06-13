#!/bin/ksh

MAILTO=tdauby@scor.com
LOGDIR=/scor01/livraison/archive/prd/log

cd $LOGDIR
{
echo "spot;date;files"

grep -- "--spot " *.log | sed -e's/.*spot//g'|sed -e's/-.*//g'|
tr ' ' '\n' | grep . | sort -u | while read spot ; do
	components=""
	grep -- "--spot " *.log | grep -w $spot | cut -d : -f1 | while read fichier ; do
		components="$components
$(sed -e'/Fichier(s)/,/Erreurs/ !d' $fichier | egrep -v 'Fichier|Erreurs')"
		date=$(echo $fichier | cut -d_ -f3)
	done
	echo "\"$spot\";\"$date\";\"$(echo $components|sort -u)\""
done

} | sort -t ';' -k2n | uuencode spot.csv| mailx $MAILTO

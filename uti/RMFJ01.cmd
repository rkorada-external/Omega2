#!/bin/ksh
# Management of RMF files
#
# First step : 
# 	ZIP yesterday's files
#
# Second step : 
#	Print fo lists and backup files in directory $RMF_SAVE 
# 
# 
# set -x
# call generic functions
. ${DUTI}/fctgen.cmd

# Initialise JOB
JOBINIT

NSTEP=${NJOB}_05
# initialisation of variables
while test -f ${RMF_SAVE}/RMF_*_START_BATCH_PROCESS
do
	export liste=`ls ${RMF_SAVE}/RMF_* | awk 'BEGIN {FS="_"; OFS="_"; bFound=0 }
	{ if ($2 == "0000") bFound ++;
	
	  if (bFound == 1) print; }'` > ${DTMP}/RMF_${IB}.lst
	JDATE=`echo $liste | cut -d"_" -f3`
	# ZIP des fichiers
	echo
	echo Zip des fichiers du $JDATE
	echo
	# set -x
	cd ${RMF_SAVE}
	${PKZIPDIR}/pkzip RMFJ_${JDATE}.zip $liste
	RC=$?
	if [ $RC != 0 ]
	then
	echo probleme lors du zip
	else
	rm $liste
	fi
done

# PRINT LISTS and BACKUP 


# Move of files  *.FAILED et *.SUCCESS into  ${RMF_SAVE}
# et copy of files *.INRUN into ${RMF_SAVE}

echo ***
echo Move of files *.FAILED* et *.SUCCESS* into ${RMF_SAVE}
echo and copy of files *.INRUN into ${RMF_SAVE}
echo ***
# Making comands file 
# set -x
while test -f ${DRMF}/RMF_*START_BATCH_PROCESS
do
ls ${DRMF}/RMF_* | awk  'BEGIN {FS="_"; OFS="_"; bFound=0 }
	{ if ($2 == "0000") bFound ++;
	
	  if (bFound == 1) print; }' > ${DTMP}/RMF_${IB}.lst
nawk -F"_" '
BEGIN {       }
{ if ($NF == "SUCCESS" || $NF == "SUCCESS-WARNING" || $NF == "FAILED" || $NF == "FAILED-WARNING" || $NF == "PROCESS" )
	{print "mv ", $1"_"$2"*"$NF,"  ${RMF_SAVE}" }}
{if ($NF == "INRUN" )
	{print "cp ", $1"_"$2"*"$NF," ${RMF_SAVE}" }} ' ${DTMP}/RMF_${IB}.lst >> ${DTMP}/RMF_${IB}.tmp

chmod 755 ${DTMP}/RMF_${IB}.tmp

# execution  of commands files
${DTMP}/RMF_${IB}.tmp

# delete of temporaries files
rm ${DTMP}/RMF_${IB}.tmp
rm ${DTMP}/RMF_${IB}.lst
done
echo 
echo create of file START_BATCH_PROCESS for this day
echo

echo ${HOSTNAME} > ${DRMF}/RMF_0000_${DATE_YYYYMMDDHHMMSS}_START_BATCH_PROCESS

# End of Job
JOBEND


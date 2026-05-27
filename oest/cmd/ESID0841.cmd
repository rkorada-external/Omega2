#!/bin/ksh
#=============================================================================
#Description            : Upload Cash-flows on Dummy Treaties
#Name of Script         : ESID0841
#date of Creation       : 04/07/2014
#Author                 : Ashish Kumar Singh
#X-wiki 		: http://dcvprdxiki/xwiki/bin/view/SCOR+OMEGA+v2/EVT-EST-SOL-32488
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#Recupere arguments d'entree
SSD_CF=${2}
USR_CF=${3}

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_01
# Convert DOS-style carriage returns into Unix-style line feeds
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
# [002]
dos2unix -n ${DUSERS}/ESID0841_${SSD_CF}.txt ${DFILT}/${NSTEP}_${IB}.dat

sed 's/\(.*\)/\1~'"${USR_CF}"'/' ${DFILT}/${NSTEP}_${IB}.dat > ${DFILT}/ESID0841_${SSD_CF}_${NSTEP}_${IB}_tmp
awk '{ print $0"~"NR }' ${DFILT}/ESID0841_${SSD_CF}_${NSTEP}_${IB}_tmp > ${DFILT}/ESID0841_${SSD_CF}_${NSTEP}_${IB}_tmp2

mv ${DFILT}/ESID0841_${SSD_CF}_${NSTEP}_${IB}_tmp2 ${DFILT}/ESID0841_${SSD_CF}.txt


NSTEP=${NJOB}_05
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Delete work table BTRAV..EST_ESID0841_SIICASHFLOWS" 
ISQL_BASE="BTRAV"
ISQL_QRY="DELETE FROM BTRAV..EST_ESID0841_SIICASHFLOWS  WHERE CREUSR_CF = '${USR_CF}' "
ISQL

NSTEP=${NJOB}_10
LIBEL="BCP IN of the awaiting file in BTRAV..EST_ESID0841_SIICASHFLOWS"
BCP_WAY="IN"; BCP_VER=""
BCP_I=${DFILT}/ESID0841_${SSD_CF}.txt
BCP_TABLE=BTRAV..EST_ESID0841_SIICASHFLOWS
BCP


NSTEP=${NJOB}_15
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Execute SP BEST..PiTPROJECSII"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PiTPROJECSII ${SSD_CF}, '${USR_CF}'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PiTPROJECSI.log
ISQL


NSTEP=${NJOB}_20
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL ${DUSERS}/*ESID0841*.dat
RMFIL ${DFILT}/ESID0841*

JOBEND

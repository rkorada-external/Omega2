#!/bin/ksh
#=========================================================================================
# Application Name      : ESTIMATION - FILE LOADING FROM EST-LIFE NEW BUSINESS FILE
# SHELL script name     : ESID0881.cmd
# Creation date         : 10/12/2015
# Author                : Capgemini (P.-E. Marx)
# description           : Asynchronous Job launched by the TP used to load New Business
#------------------------------------------------------------------------------------------
#   05/08/2017   SA        : [31752] -  Tag BTEC..TTASKQUEUE for anomaly condition.
#=========================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#Input parameters
LOADING_MODE=1
SSD_CF=$3
ESB_CF=$4
USR_CF=$2
FILE_DATE_CRD=${5}
LNCH_DATE_TIME="$6 $7"

# Job Initialisation
JOBINIT

awk -F "~" 'BEGIN{OFS="~";}{print $1,$2,$3,$4,$5,NR}' ${DUSERS}/${PCH}ESID0881_${SSD_CF}_${ESB_CF}_${USR_CF}_${FILE_DATE_CRD}.dat > ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat

NSTEP=${NJOB}_04
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 1"
ISQL


NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete perimeter of old entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0881_PERIMETER
          where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and USR_CF = '${USR_CF}'"
ISQL


NSTEP=${NJOB}_06
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete of old entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0881_TESTLIFNEWBIZ
          where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and CREUSR_CF = '${USR_CF}'"
ISQL


NSTEP=${NJOB}_07
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete of old entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0881_NEWBIZVAL"
ISQL


NSTEP=${NJOB}_08
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete old error entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0881_TCTRANO
          where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and SEG_NF = '${USR_CF}'"
ISQL


NSTEP=${NJOB}_10
#Exec Ksh to Rename the New Business file
#-----------------------------------------------------------------------------
if test -s ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
then
  LIBEL=" Exec Ksh to Rename the New Business file "
  dos2unix ${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
  EXECKSH " mv "${DFILT}/${NJOB}_AWK_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
                                      ${DFILT}/${NSTEP}_${IB}_ESID0881_${SSD_CF}_${USR_CF}.dat"
fi


NSTEP=${NJOB}_15
# Begin sort
#-----------------------------------------------------------------
LIBEL="Sort input file according to contract/section/acy"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_10_${IB}_ESID0881_${SSD_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 2:1 - 2:EN, ACY_NF 3:1 - 3:EN, NUMLINE_NT 6:1 - 6:EN
/KEYS   CTR_NF, SEC_NF, ACY_NF, NUMLINE_NT
exit
EOF
SORT


NSTEP=${NJOB}_20
# Begin awk
#------------------------------------------------------------------------------
LIBEL="Add relevant data to the input file"
AWK_I=${DFILT}/${NJOB}_15_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
         {print ${SSD_CF},${ESB_CF},\$1,0,\$2,\$3,\$4,"",\$5,"${USR_CF}",\$6}
exit
EOF
AWK

NSTEP=${NJOB}_25
# Begin shell
#------------------------------------------------------------------------------
LIBEL="Checking for duplicate row"
cat ${DFILT}/${NJOB}_20_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | awk 'x[$3,$5,$6,$7]++' FS="~" | awk 'BEGIN{FS="~"}{print $3"~0~"$5"~1~"'${SSD_CF}'"~N~""'${USR_CF}'""~126~"$11"~1~""'${ESB_CF}'""~"$6"~"$6;}' > ${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_30
# Begin cut
#------------------------------------------------------------------------------
LIBEL="Generate estimation file perimeter - cut and uniq"
awk '!x[$3,$5,$11]++' FS="~"  ${DFILT}/${NJOB}_20_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat | cut -d "~" -f3,5,11 > ${DFILT}/${NSTEP}_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_35
# Begin sed
#------------------------------------------------------------------------------
LIBEL="Complete estimation file perimeter with SSD_CF - ESB_CF - USR_CF"
sed 's/\(.*\)/\1~''0~1~'"${SSD_CF}"'~'"${ESB_CF}"'~'"${USR_CF}"~0~0~0~0~0'/' ${DFILT}/${NJOB}_30_UNIQ_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat > ${DFILT}/${NSTEP}_SED_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


NSTEP=${NJOB}_40
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import in temporary base the estimation file perimeter BCP IN into BTRAV..EST_ESID0881_PERIMETER"
BCP_WAY="IN"; BCP_VER=""
#BCP_TRUNCATE=NO
BCP_I=${DFILT}/${NJOB}_35_SED_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0881_PERIMETER"
BCP


NSTEP=${NJOB}_45
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Check for errors in BTRAV..EST_ESID0881_PERIMETER"
ISQL_BASE="BTRAV"
ISQL_QRY="execute BEST..PsLIFEST_17 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


NSTEP=${NJOB}_50
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="Retrieve the existing New Business data"
BCP_WAY="OUT";
BCP_VER="+";
BCP_O=${DFILT}/${NSTEP}_${IB}_EXTRACT_LIFE_EST_NEW_BIZ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_QRY="execute BEST..PsLIFNEWBIZ_01_O2 '', 0, 0, 0, 'E', ${SSD_CF}, ${ESB_CF},'${USR_CF}',${LOADING_MODE}"
BCP


NSTEP=${NJOB}_55
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0881_NEWBIZVAL"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_50_${IB}_EXTRACT_LIFE_EST_NEW_BIZ_${SSD_CF}_${ESB_CF}_${USR_CF}.dat"
BCP_TABLE=BTRAV..EST_ESID0881_NEWBIZVAL
BCP


NSTEP=${NJOB}_60
#  Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0881_TESTLIFNEWBIZ"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_SORT_${IB}_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0881_TESTLIFNEWBIZ"
BCP


NSTEP=${NJOB}_65
#  Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0881_TCTRANO"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_${IB}_TCTRANO_OUTPUT_FILE_${SSD_CF}_${ESB_CF}_${USR_CF}.dat
BCP_TABLE="BTRAV..EST_ESID0881_TCTRANO"
BCP


NSTEP=${NJOB}_70
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Conformity control of New Business entries"
ISQL_BASE="BEST"
ISQL_QRY="exec PiLIFNEWBIZ_02 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL

#-- [31752] 
NSTEP=${NJOB}_80
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT='N' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         
ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best23a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If exists lines into table best..TCTRANO, create a warning message and update TASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_85
    LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
    # Call the Tool box function to set the status to 10-Completed with Anomaly	
    MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	
    STEPWARNING 10
fi
#-- [31752] 

NSTEP=${NJOB}_85
# Begin SQL
#------------------------------------------------------------------------------
LIBEL="Update the status of the file loading in TLOADEST"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PuTLOADEST_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}', 10"
ISQL

NSTEP=${NJOB}_90
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


JOBEND

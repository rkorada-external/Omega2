#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - CONTROLE DE COHERENCE
#                                 de service ( disquette utilisateurs )
# nom du script SHELL           : ESID0861.cmd
# revision                      : $Revision:   1.5  $
# date de creation              : 10 March 2015 
# auteur                        : Sonal Bhombe
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Estimates P&C Cat Cover Upload File 
#
#  Asynchronous Job
#------------------------------------------------------------------------------------------
#   05/08/2017   SA        : [31752] -  Tag BTEC..TTASKQUEUE for anomaly condition.
#-----------------------------------------------------------------------------
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


#Recupere arguments d'entree
USR_CF=$2
SSD_CF=$3
DATE_T=$4
BALSH_D=$5
LNCH_DATE_TIME="$6 $7"
NUMLINE_NT=0
ERRORCOD_CT=""
RCATCVR_NT=""


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete of old entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0861_TCTRANO  
          where SSD_CF=${SSD_CF} and USR_CF='${USR_CF}'"
ISQL

NSTEP=${NJOB}_07
#Exec Ksh to Rename the IBNR file
#-----------------------------------------------------------------------------
if test -s ${DIBNR}/ESID0861_${SSD_CF}_${USR_CF}_${DATE_T}*.dat
then
  LIBEL=" Exec Ksh to Rename the IBNR file "
  dos2unix ${DIBNR}/ESID0861_${SSD_CF}_${USR_CF}_${DATE_T}.dat
  EXECKSH " mv "${DIBNR}/ESID0861_${SSD_CF}_${USR_CF}_${DATE_T}.dat"
                                      ${DFILT}/${NSTEP}_${IB}_ESID0861_${SSD_CF}_${USR_CF}_${DATE_T}.dat"
fi


NSTEP=${NJOB}_08
# Introduction of NUMLINE_NT,RCATCVR_NT and ERRORCOD_CT in the input File
#----------------------------------------------------------------------------
LIBEL="Introduction of NUMLINE_NT,RCATCVR_NT and ERRORCOD_CT in the input File"
AWK_I=${DFILT}/${NJOB}_07_${IB}_ESID0861_${SSD_CF}_${USR_CF}_${DATE_T}.dat
AWK_PARAM=" ERRORCOD_CT=${ERRORCOD_CT}  RCATCVR_NT=${RCATCVR_NT} NUMLINE_NT=${NUMLINE_NT}"
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_SVC_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN {
 FS="~"
 OFS="~"
}
{
   NUMLINE_NT=NUMLINE_NT+1;
   \$10=\$10"~"NUMLINE_NT"~"RCATCVR_NT"~"ERRORCOD_CT;
  
   print \$0;
}
exit
EOF
AWK


NSTEP=${NJOB}_10
#  BCP IN in BTRAV..EST_ESID0861_TRETCATCVR 
#------------------------------------------------------------------------------
LIBEL="BCP IN of the special entries file in BTRAV..EST_ESID0861_TRETCATCVR"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_08_${IB}_AWK_SVC_O.dat
BCP_TABLE="BTRAV..EST_ESID0861_TRETCATCVR"
BCP


NSTEP=${NJOB}_15
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Conformity control of special entries"
ISQL_BASE="BEST"
ISQL_QRY="exec PuRETCATCVR_01_O2  ${SSD_CF}, '${USR_CF}', '${BALSH_D}'"
ISQL

#-- [31752] 
NSTEP=${NJOB}_20
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT='C' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         
ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best21a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If exists lines into table best..TCTRANO, create a warning message and update TASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_25
    LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'
    # Call the Tool box function to set the status to 10-Completed with Anomaly	
    MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"	
    STEPWARNING 10
fi

NSTEP=${NJOB}_30
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND



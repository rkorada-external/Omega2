#! /bin/ksh
#============================================================================================
# Application Name         : ESTIMATION - FILE LOADING FROM EST-LIFE ESTIMATION FILE
# SHELL script name        : ESID0814.cmd
# Creation date            : 10/03/2014
# Author                   : Ashish Kumar Singh 
# description              : Asynchronous Job launched by the TP used to load estimation file
#============================================================================================
# trace UNIX
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd


# Get input parameters
USR_CF=$1
SSD_CF=$2
ESB_CF=$3


# Job Initialisation
JOBINIT

export TMP_DFILT=${DFILT}/temp/${SSD_CF}_${ESB_CF}_${USR_CF}

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="On delete les anomalies du traitement precedent"
ISQL_BASE="BEST"
ISQL_QRY="delete BEST..TCTRANO where SEG_NF='${USR_CF}' and SSD_CF=${SSD_CF} and SEGTYP_CT='L'"
ISQL


NSTEP=${NJOB}_10
#----------------------------------------------------------------------------
LIBEL="BCP IN BEST...TCTRANO"
BCP_WAY="IN"; BCP_VER="" 
BCP_I="${TMP_DFILT}/TCTRANO_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BEST..TCTRANO
BCP


NSTEP=${NJOB}_15
#----------------------------------------------------------------------------
LIBEL="BCP IN BEST...TLIFEST"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${TMP_DFILT}/TLIFEST_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BEST..TLIFEST
BCP


NSTEP=${NJOB}_20
#----------------------------------------------------------------------------
LIBEL="BCP IN BEST...TLIFPEN"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${TMP_DFILT}/TLIFPEN_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BEST..TLIFPEN
BCP


NSTEP=${NJOB}_25
#----------------------------------------------------------------------------
LIBEL="BCP IN BEST...TLIFMOD"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${TMP_DFILT}/TLIFMOD_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BEST..TLIFMOD
BCP


NSTEP=${NJOB}_30
#----------------------------------------------------------------------------
LIBEL="BCP IN BEST...TLIFMOD2"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${TMP_DFILT}/TLIFMOD2_BCPIN_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BEST..TLIFMOD2
BCP


NSTEP=${NJOB}_35
#----------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0814_TLIFMOD2"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE="YES"
BCP_I="${TMP_DFILT}/TLIFMOD2_UPDATE_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BTRAV..EST_ESID0814_TLIFMOD2
BCP


NSTEP=${NJOB}_40
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PuLIFMOD2_02_O2 to save data in BEST..LIFMOD2 from data in BTRAV..EST_ESID0814_TLIFMOD2"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuLIFMOD2_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


NSTEP=${NJOB}_45
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PiCTRANO_02_O2 to save data in BEST..TCTRANO from data BTRAV..EST_ESID0811_TCTRANO"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PiCTRANO_02_O2 ${SSD_CF}, ${ESB_CF}, '${USR_CF}'"
ISQL


NSTEP=${NJOB}_50
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete work table BTRAV..EST_ESID0814_THRESHOLD"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0814_THRESHOLD where USR_CF = '${USR_CF}' and ESB_CF = ${ESB_CF} and SSD_CF = ${SSD_CF}"
ISQL


NSTEP=${NJOB}_55
#----------------------------------------------------------------------------
LIBEL="BCP IN BTRAV..EST_ESID0814_THRESHOLD"
BCP_WAY="IN"; BCP_VER=""
BCP_I="${TMP_DFILT}/EST_ESID0814_THRESHOLD_BCPIN_${USR_CF}_${SSD_CF}_${ESB_CF}.dat"
BCP_TABLE=BTRAV..EST_ESID0814_THRESHOLD
BCP


NSTEP=${NJOB}_60
# Begin webservice
#----------------------------------------------------------------------------
LIBEL="Life Estimate Contracts"
WS_BATCH_NAME=BAT36454
WS_PARAMS_TEXT << EOF
USR_CF          ${USR_CF}
SSD_CF          ${SSD_CF}
ESB_CF          ${ESB_CF}
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
WS_BATCH


NSTEP=${NJOB}_65
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"
RMFIL "${DFILT}/${PCH}*_ESID0812_*_${IB}*.dat"
RMFIL "${DFILT}/${PCH}*_ESID0813_*_${IB}*.dat"
RMFIL ${DUSERS}/${PCH}ESID0811_${SSD_CF}_${ESB_CF}_${USR_CF}.dat


# END of JOB
JOBEND


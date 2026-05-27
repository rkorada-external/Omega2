#!/bin/ksh
#=============================================================================
# nom de l'application		: complete accounts Insertion 
# nom du script SHELL		  : CPTJ1002.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 02/10/2019
# auteur			            : C. SOCIE
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Raise success/failure on batch CPTD0912
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

# Entry parameter
# -------------------------------------
DATEJOUR=$1
V_DATE_JOUR=$2
ADRESSE=$3
DEL_REP_DAYS=$4
USER_NAME=`id -un`

NSTEP=${NJOB}_10
#-----------------------------------------------------------
LIBEL="Switch on server ${SRV2}"
SWITCH_SRV ${SRV2}

NSTEP=${NJOB}_15
# Begin rm
#-----------------------------------------------------------------------------
LIBEL="Step to remove current days files if any."
RMFIL "${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.dat"
RMFIL "${DTRANSFER}/${REMOTE_SITE}/to/${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.zip"
RMFIL "${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.dat"
RMFIL "${DTRANSFER}/${REMOTE_SITE}/to/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.zip"


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="BCP out BSTA..TSUIVINTACC, BSTA..TANOINTACC"
ISQL_BASE="BSTA"
ISQL_O=${DFILT}/${NSTEP}_ISQL_TSUIVINTACC_05.log
ISQL_QRY="execute BSTA..PsTSUIVINTACC_05 '${USER_NAME}','${V_DATE_JOUR}'"
ISQL


NSTEP=${NJOB}_25
# ------------------------------------
LIBEL='BCP out BTRAVI..BSTA_TSGLAGEACIN01'
BCP_WAY="OUT"; BCP_VER="";BCP_SPECIAL_OPT=""
BCP_O=${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.dat
BCP_TABLE=BTRAVI..BSTA_TSGLAGEACIN01
BCP

NSTEP=${NJOB}_30
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP


NSTEP=${NJOB}_35
# ------------------------------------
LIBEL='BCP out BTRAVI..BSTA_TSGLAGEACIN02'
BCP_WAY="OUT"; BCP_VER="+";BCP_SPECIAL_OPT=""
BCP_O=${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.dat
BCP_QRY="select * from BTRAVI..BSTA_TSGLAGEACIN02 order by MESSTHM_C, SSD_CF, ESB_CF, INTEG_D, NUMFIC_NT, NUMLIGNE_NT"
BCP

NSTEP=${NJOB}_40
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP

NSTEP=${NJOB}_45
# Reporting 
#-----------------------------------------------------------------------------
LIBEL=" file-loading Reporting "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=$DFILT/${NJOB}_ctlfile.dat
BCP_QRY="execute BSTA..PsTSUIVINTACC_04 'ESTIMATION', '${USER_NAME}', '${DTRANSFER}/${REMOTE_SITE}','${V_DATE_JOUR}','${ENV_PREFIX}'"
BCP

NSTEP=${NJOB}_50
# Mailing 
#-----------------------------------------------------------------------------
LIBEL="Mailing to user"
MAIL_ADR=${ADRESSE}
MAIL_SUBJECT="${ENV_PREFIX}-ESTIMATION: FILE-LOADING REPORT ON ${DATEJOUR}"
MAIL_FILE=``
MAIL_CONTENT=$DFILT/${NJOB}_ctlfile.dat
SENDMAIL

NSTEP=${NJOB}_55
# Begin rm
#-----------------------------------------------------------------
LIBEL="Delete of temporary file "
RMFIL "${DFILT}/${NCHAIN}_*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN0*_${V_DATE_JOUR}.dat"
EXECKSH "find ${DTRANSFER}/${REMOTE_SITE}/to/${ENV_PREFIX}_${SITE_ID}_GEACIN0*.zip -type f -mtime +${DEL_REP_DAYS} -print -delete"

# Closing the Job
JOBEND
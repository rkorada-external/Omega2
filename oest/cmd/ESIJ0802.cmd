#!/bin/ksh
#========================================================================================================
# nom de l'application          : ESTIMATIONS - ENVOI MAIL COMPTE-RENDU INTEGRATION FICHIER
# nom du script SHELL           : ESIJ0802.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01/06/2012
# auteur                        : L. RAKOTOZAFY
# fiche spot                    :23860
#                               :spot:23860     LRAK
# references des specifications :
#---------------------------------------------------------------------------------------------------------
# description
#   
#Job appelé par ESIJ0800.cmd
#---------------------------------------------------------------------------------------------------------
# historique des modifications
# 07/10/2014  usuaksh  Spot #27483  Modified to include the GEACIN01/GEACIN02 reporting data generation.
# 13/01/2015  usuaksh  Spot #27968  Modified the email Notification Title.
# 19/09/2019  usuaksh  Spot #80575  Parameterized SGLA in the report file name and specified an order for BSTA_TSGLAGEACIN02.
# 22/07/2020  s.Behague spira:88748 - I17: ESIJ0800 - Mailing: Loading report
# 22/07/2020  S.Behague :spira:87212 - IFRS17- REQ.LIF.01: AE interface for Life from SAS - lot2
#=========================================================================================================
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


NSTEP=${NJOB}_27
# Ventilation of file by name
#--------------------------------
LIBEL="Ventilation of file by name"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN01_O_${V_DATE_JOUR}.dat 1000 1"
SORT_O2="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN01_O_CSMENGINE_${V_DATE_JOUR}.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	NOMFICHIER      6:1 - 6:
/CONDITION CSMENGINE ( NOMFICHIER CT "CSMENGINE" )
/OUTFILE ${SORT_O}
/OMIT CSMENGINE
/OUTFILE ${SORT_O2}
/INCLUDE CSMENGINE
exit
EOF
SORT

NSTEP=${NJOB}_30
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN01_O_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_${SITE_ID}_GEACIN01_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP

NSTEP=${NJOB}_31
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN01_O_CSMENGINE_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_CSM_${HOST_PRDSIT}_GEACIN01_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP


NSTEP=${NJOB}_35
# ------------------------------------
LIBEL='BCP out BTRAVI..BSTA_TSGLAGEACIN02'
BCP_WAY="OUT"; BCP_VER="+";BCP_SPECIAL_OPT=""
BCP_O=${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.dat
BCP_QRY="select * from BTRAVI..BSTA_TSGLAGEACIN02 order by MESSTHM_C, SSD_CF, ESB_CF, INTEG_D, NUMFIC_NT, NUMLIGNE_NT"
BCP

NSTEP=${NJOB}_37
# Ventilation of file by name
#--------------------------------
LIBEL="Ventilation of file by name"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN02_O_${V_DATE_JOUR}.dat 1000 1"
SORT_O2="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN02_O_CSMENGINE_${V_DATE_JOUR}.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	NOMFICHIER      9:1 - 9:
/CONDITION CSMENGINE ( NOMFICHIER CT "CSMENGINE" )
/OUTFILE ${SORT_O}
/OMIT CSMENGINE
/OUTFILE ${SORT_O2}
/INCLUDE CSMENGINE
exit
EOF
SORT


NSTEP=${NJOB}_40
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN02_O_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_${SITE_ID}_GEACIN02_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP

NSTEP=${NJOB}_41
# ZIP
#----------------------------------------------------------------------------
LIBEL="Beginning of a ZIP session"
ZIP_MODE="Z"
ZIP_ODIR="${DTRANSFER}/${REMOTE_SITE}/to"
ZIP_I="${DFILT}/${ENV_PREFIX}_${SITE_ID}_${IB}_GEACIN02_O_CSMENGINE_${V_DATE_JOUR}.dat"
ZIP_O="${ENV_PREFIX}_CSM_${HOST_PRDSIT}_GEACIN02_${V_DATE_JOUR}.zip"
ZIP_OPT=""
ZIP

NSTEP=${NJOB}_55
# Reporting 
#-----------------------------------------------------------------------------
LIBEL=" file-loading Reporting "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=$DFILT/${NJOB}_ctlfile.dat
BCP_QRY="execute BSTA..PsTSUIVINTACC_04 'ESTIMATION', '${USER_NAME}', '${DTRANSFER}/${REMOTE_SITE}','${V_DATE_JOUR}','${ENV_PREFIX}'"
BCP

NSTEP=${NJOB}_58
# Reporting 
#-----------------------------------------------------------------------------
LIBEL=" file-loading Reporting "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=$DFILT/${NJOB}_ctlfilecsm.dat
BCP_QRY="execute BSTA..PsTSUIVINTACC_04 'ESTCSMENG', '${USER_NAME}', '${DTRANSFER}/${REMOTE_SITE}','${V_DATE_JOUR}','${ENV_PREFIX}'"
BCP

TMP_USER=`echo $DTRANSFER | awk -F"/" '{ print $4} '`


NSTEP=${NJOB}_60
# Mailing 
#-----------------------------------------------------------------------------
LIBEL="Mailing to user"
MAIL_ADR=${ADRESSE}
MAIL_SUBJECT="${ENV_PREFIX}-ESTIMATION: FILE-LOADING REPORT ON ${DATEJOUR}"
MAIL_FILE=``
MAIL_CONTENT=$DFILT/${NJOB}_ctlfile.dat
SENDMAIL

NSTEP=${NJOB}_65
# Mailing 
#-----------------------------------------------------------------------------
LIBEL="Mailing to user"
MAIL_ADR=${ADRESSECSM}
MAIL_SUBJECT="${ENV_PREFIX}-I17 ESTIMATION: FILE-LOADING REPORT ON ${DATEJOUR}"
MAIL_FILE=``
MAIL_CONTENT=$DFILT/${NJOB}_ctlfilecsm.dat
SENDMAIL


NSTEP=${NJOB}_70
# move CSM file 
#-----------------------------------------------------------------
LIBEL="move CSM file "
EXECKSH "mv ${DTRANSFER}/${REMOTE_SITE}/to/${ENV_PREFIX}_CSM*.zip ${DTRANSFER}/${CSM_SITE}/to/"

NSTEP=${NJOB}_75
# Begin rm
#-----------------------------------------------------------------
LIBEL="Delete of temporary file "
RMFIL "${DFILT}/${NCHAIN}_*_${IB}_*.dat"
RMFIL "${DFILT}/${ENV_PREFIX}_${SITE_ID}_GEACIN0*_${V_DATE_JOUR}.dat"
EXECKSH "find ${DTRANSFER}/${REMOTE_SITE}/to/${ENV_PREFIX}_${SITE_ID}_GEACIN0*.zip -type f -mtime +${DEL_REP_DAYS} -print -delete"

# Closing the Job
JOBEND
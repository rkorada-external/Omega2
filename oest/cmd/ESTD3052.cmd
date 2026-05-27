#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3052.cmd
# revision:                       $Revision: 1.2 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# mise a dispo pour site recepteur
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  15/06/2009  Roger Cassis      :spot:17532 -  Si pas de donnees a extraire on stoppe le job sans Abort
#  03/12/2009  Roger Cassis      :spot:18415 -> Ajout transfert fichier Plan_Vie LIFSTAREP_PLAN
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd
. ${DUTI}/fcttransfer.cmd

# Entry parameters

# Job initialisation
JOBINIT

# Fichiers d'emission interne envoyes aux filiales

# GTA_TRANSFP.dat

if [ ! -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_GTA_TRANSFP.dat" ] &&
   [ ! -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_CURGTA_TRANSFP.dat" ] &&
   [ ! -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat" ]

then
  ECHO_LOG "---> No Data to process because Input files are empty - Stop processing"
  JOBEND
fi

if [ -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_GTA_TRANSFP.dat" ]
then

	NSTEP=${NJOB}_04
	LIBEL="Erase temporary files"
	RMFIL "${DFILT}/${NJOB}_10_*_GTA_TRANSFP.dat"

	NSTEP=${NJOB}_05
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_GTA_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA_TRANSFP.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_10
	# Split file by subsidiary
	#-----------------------------------------------------------------------------
	LIBEL="Split TL file by subsidiary"
	SPLIT_PREFIX=${NJOB}_05
	SPLIT_PREFIX_NEW=${NSTEP}
	SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_GTA_TRANSFP.dat
	SPLIT_FILE

	NSTEP=${NJOB}_15
	# Concat file names
	#-----------------------------------------------------------------------------
	LIBEL="Concat file names"
	STR_CAT_PREFIX="${DFILT}/${NJOB}_10_*_GTA_TRANSFP.dat"
	STR_CAT

	NSTEP=${NJOB}_20
	# Send files
	#-----------------------------------------------------------------------------
	LIBEL="Send files to pool"
	SEND_POOL_PREFIX="${NJOB}_10_.*_${IB}"
	SEND_POOL_FILES="${DFILT}/${NJOB}_10_*_GTA_TRANSFP.dat"
	SEND_POOL_TYPE="SSD"
	SEND_POOL

fi

# CURGTA_TRANSFP.dat

if [ -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_CURGTA_TRANSFP.dat" ]
then

	NSTEP=${NJOB}_24
	LIBEL="Erase temporary files"
	RMFIL "${DFILT}/${NJOB}_30_*_CURGTA_TRANSFP.dat"

	NSTEP=${NJOB}_25
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_CURGTA_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_TRANSFP.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_30
	# Split file by subsidiary
	#-----------------------------------------------------------------------------
	LIBEL="Split TL file by subsidiary"
	SPLIT_PREFIX=${NJOB}_25
	SPLIT_PREFIX_NEW=${NSTEP}
	SPLIT_I=${DFILT}/${NJOB}_25_${IB}_SORT_CURGTA_TRANSFP.dat
	SPLIT_FILE

	NSTEP=${NJOB}_35
	# Concat file names
	#-----------------------------------------------------------------------------
	LIBEL="Concat file names"
	STR_CAT_PREFIX="${DFILT}/${NJOB}_30_*_CURGTA_TRANSFP.dat"
	STR_CAT

	NSTEP=${NJOB}_40
	# Send files
	#-----------------------------------------------------------------------------
	LIBEL="Send files to pool"
	SEND_POOL_PREFIX="${NJOB}_30_.*_${IB}"
	SEND_POOL_FILES="${DFILT}/${NJOB}_30_*_CURGTA_TRANSFP.dat"
	SEND_POOL_TYPE="SSD"
	SEND_POOL

fi

# LIFSTAREP_PLAN_TRANSFP.dat

if [ -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat" ]
then

	NSTEP=${NJOB}_44
	LIBEL="Erase temporary files"
	RMFIL "${DFILT}/${NJOB}_50_*_LIFSTAREP_PLAN_TRANSFP.dat"

	NSTEP=${NJOB}_45
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFSTAREP_PLAN_TRANSFP.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 2:1 - 2: EN,
        AUTRES 1:1 - 33:
/KEYS SSD_CF
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, AUTRES
exit
EOF
	SORT

	NSTEP=${NJOB}_50
	# Split file by subsidiary
	#-----------------------------------------------------------------------------
	LIBEL="Split TL file by subsidiary"
	SPLIT_PREFIX=${NJOB}_45
	SPLIT_PREFIX_NEW=${NSTEP}
	SPLIT_I=${DFILT}/${NJOB}_45_${IB}_SORT_LIFSTAREP_PLAN_TRANSFP.dat
	SPLIT_FILE

	NSTEP=${NJOB}_55
	# Concat file names
	#-----------------------------------------------------------------------------
	LIBEL="Concat file names"
	STR_CAT_PREFIX="${DFILT}/${NJOB}_50_*_LIFSTAREP_PLAN_TRANSFP.dat"
	STR_CAT

	NSTEP=${NJOB}_60
	# Send files
	#-----------------------------------------------------------------------------
	LIBEL="Send files to pool"
	SEND_POOL_PREFIX="${NJOB}_50_.*_${IB}"
	SEND_POOL_FILES="${DFILT}/${NJOB}_50_*_LIFSTAREP_PLAN_TRANSFP.dat"
	SEND_POOL_TYPE="SSD"
	SEND_POOL

	NSTEP=${NJOB}_65
	# Begin Remove
	#--------------------------------------------------------------------------
	LIBEL="cp ${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat ${DFILI}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat"
	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat ${DFILI}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat"

	NSTEP=${NJOB}_70
	# Sauvegarde ZIP! des Fichiers xxxxLIFSTAREP_PLANx Générés par la Chaîne ESTD3050
	#----------------------------------------------------------------------------
	LIBEL="ZIP Fichier ${DFILI}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat"
	ZIP_ODIR=""
	ZIP_I="${DFILI}/${ENV_PREFIX}_ESTD3050_ESTD3051_LIFSTAREP_PLAN_TRANSFP.dat"
	ZIP_O="${DSAV}/${SVG}_${ENV_PREFIX}_ESTD3050_LIFSTAREP_PLAN.dat.zip"
	ZIP_OPT=""
	ZIP_MODE="Z"
	ZIP

fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

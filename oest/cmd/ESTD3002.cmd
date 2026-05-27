#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3002.cmd
# revision:                       $Revision: 1.4 $
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
#  03/12/2009  Roger Cassis      :spot:18415 -> Mise à jour parametres plus utilises
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd
. ${DUTI}/fcttransfer.cmd

# Entry parameters
TRANSFESB=${1}

# Job initialisation
JOBINIT

# Fichiers d'emission interne envoyes aux filiales

# GTA_TRANSFP.dat

if [ ! -s "${DFILT}/${PCH}ESTD3000_ESTD3001_GTA_TRANSFP.dat" ] &&
   [ ! -s ${DFILT}/${PCH}ESTD3000_ESTD3001_CURGTA_TRANSFP.dat ] &&
   [ ! -s ${DFILT}/${PCH}ESTD3000_ESTD3001_ARCSTATGTA_TRANSFP.dat ]
then
  ECHO_LOG "---> No Data to process because Input files are empty - Stop processing"
  JOBEND
fi

if [ -s "${DFILT}/${PCH}ESTD3000_ESTD3001_GTA_TRANSFP.dat" ]
then

	NSTEP=${NJOB}_05
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${PCH}ESTD3000_ESTD3001_GTA_TRANSFP.dat 1000 1"
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

#SEND_POOL_FILES=${STR_CAT_O}
# CURGTA_TRANSFP.dat

if [ -s ${DFILT}/${PCH}ESTD3000_ESTD3001_CURGTA_TRANSFP.dat ]
then

	NSTEP=${NJOB}_25
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${PCH}ESTD3000_ESTD3001_CURGTA_TRANSFP.dat 1000 1"
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

# ARCSTATGTA_TRANSFP.dat

if [ -s ${DFILT}/${PCH}ESTD3000_ESTD3001_ARCSTATGTA_TRANSFP.dat ]
then

	NSTEP=${NJOB}_45
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${PCH}ESTD3000_ESTD3001_ARCSTATGTA_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_TRANSFP.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_50
	# Split file by subsidiary
	#-----------------------------------------------------------------------------
	LIBEL="Split TL file by subsidiary"
	SPLIT_PREFIX=${NJOB}_45
	SPLIT_PREFIX_NEW=${NSTEP}
	SPLIT_I=${DFILT}/${NJOB}_45_${IB}_SORT_ARCSTATGTA_TRANSFP.dat
	SPLIT_FILE

	NSTEP=${NJOB}_55
	# Concat file names
	#-----------------------------------------------------------------------------
	LIBEL="Concat file names"
	STR_CAT_PREFIX="${DFILT}/${NJOB}_50_*_ARCSTATGTA_TRANSFP.dat"
	STR_CAT

	NSTEP=${NJOB}_60
	# Send files
	#-----------------------------------------------------------------------------
	LIBEL="Send files to pool"
	SEND_POOL_PREFIX="${NJOB}_50_.*_${IB}"
	SEND_POOL_FILES="${DFILT}/${NJOB}_50_*_ARCSTATGTA_TRANSFP.dat"
	SEND_POOL_TYPE="SSD"
	SEND_POOL

fi

if [ -s ${DFILT}/${PCH}ESTD3000_ESTD3001_TACCSTAT_TRANSFP.dat -a "${TRANSFESB}" = "0" ]
then

	NSTEP=${NJOB}_65
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort TL file according to subsidiary"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${PCH}ESTD3000_ESTD3001_TACCSTAT_TRANSFP.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TACCSTAT_TRANSFP.dat"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_70
	# Split file by subsidiary
	#-----------------------------------------------------------------------------
	LIBEL="Split TL file by subsidiary"
	SPLIT_PREFIX=${NJOB}_65
	SPLIT_PREFIX_NEW=${NSTEP}
	SPLIT_I=${DFILT}/${NJOB}_65_${IB}_SORT_TACCSTAT_TRANSFP.dat
	SPLIT_FILE

	NSTEP=${NJOB}_75
	# Concat file names
	#-----------------------------------------------------------------------------
	LIBEL="Concat file names"
	STR_CAT_PREFIX="${DFILT}/${NJOB}_70_*_TACCSTAT_TRANSFP.dat"
	STR_CAT

	NSTEP=${NJOB}_80
	# Send files
	#-----------------------------------------------------------------------------
	LIBEL="Send files to pool"
	SEND_POOL_PREFIX="${NJOB}_70_.*_${IB}"
	SEND_POOL_FILES="${DFILT}/${NJOB}_70_*_TACCSTAT_TRANSFP.dat"
	SEND_POOL_TYPE="SSD"
	SEND_POOL

fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_95
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${PCH}ESTD3000_ESTD3001_*TRANSFP.dat"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
#RMFIL "${DFILT}/${NJOB}_*.dat"

JOBEND

 
#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - ZIP fichiers delta traitement post omega
#                                 ZIP des fichiers delta envoyés a People soft
# nom du scipt SHELL		: ESPD9991.cmd
# evision			: 5.1
# date de ceation		: 08/09/2005
# auteu			: J. Ribot
# eferences des specifications	:
#-----------------------------------------------------------------------------
# desciption
#   ZIP
#
# Job launched by ESPD9990.cmd
#-----------------------------------------------------------------------------
# histoiques des modifications
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupee arguments d'entree
# Get input parameters
BOOKING_D=$1
CONSOYEA=$2
CONSOMTH=$3
CRE_D=$4
DBCLO_D=$5

export CLOPRD=`printf "%04d%02d" ${CONSOYEA} ${CONSOMTH}`

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin ZIP
#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session"
	ZIP_MODE="Z"
  ZIP_I="${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGT*_${BOOKING_D}_${CLOPRD}_*.dat"
	ZIP_O="${DARCH}/${PCH}ESPD7000_CMGT_${BOOKING_D}_${CLOPRD}_${DBCLO_D}_${CRE_D}.arc"
	ZIP

NSTEP=${NJOB}_20
# RM FILE
#-----------------------------------------------------------------
LIBEL="RM of the permanent files"
RMFIL "${DFILP}/${PCH}ESPD7000_${CLOPRD}_CMGT*_${BOOKING_D}_${CLOPRD}_*.dat"


JOBEND


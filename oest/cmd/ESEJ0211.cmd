#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION  - CONTROLE DES ESTIMATIONS
#                                 Edition de la liste des affaires par segment
# nom du script SHELL		: ESEJ0211.cmd
# revision			: $Revision:   1.7  $
# date de creation		: 12/05/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0320.DOC
#-----------------------------------------------------------------------------
# description
#   Print-out list of contracts for a segment after a PB request
#
# job launched by ESEJ0210.cmd or asynchron
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
USR_CF=$1
PRT_CF=$2
SEG_NF_PRM=$3
SEGTYP_CT_PRM=$4
SSD_CF_PRM=$5
VRS_NF_PRM=$6
LAG_CF_PRM=$7
DATE_PRM=$8

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Making Segment's list file
#------------------------------------------------------------------------------
LIBEL="Making Segment's list file" 
SQR_PRG="ESTR0320"
SQR_O=${DFILT}/${NSTEP}_${IB}_${SQR_PRG}_O.dat
SQR_PARAM="${SEG_NF_PRM} ${SEGTYP_CT_PRM} ${SSD_CF_PRM} ${VRS_NF_PRM} ${LAG_CF_PRM} ${DATE_PRM}"
SQR_BASE="BEST"
SQR

NSTEP=${NJOB}_07
# Get printer id from user
#------------------------------------------------------------------------------
LIBEL="Get printer id from user"
GET_PRTID_FROMUSER ${USR_CF}

NSTEP=${NJOB}_10
# Starpage printing
#------------------------------------------------------------------------------
LIBEL="Starpage printing"
PRN_NAME=${PRTID}
PRN_I=${DFILT}/${NJOB}_05_${IB}_ESTR0320_O.dat
PRN_FMT="estr0320"	#fichier .sp .sjp
PRN

NSTEP=${NJOB}_15
# Step to remove temporary job files
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary job files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND

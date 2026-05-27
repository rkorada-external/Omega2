#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - CONTROLE DES ESTIMATIONS 
#                                 Edition de la liste des segments
# nom du script SHELL		: ESEJ0201.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 28/04/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0310.DOC
#-----------------------------------------------------------------------------
# description
#   Segments list print-out
#
# job launched by ESEJ200.cmd or asynchron
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
# In this job, the parameters are:
USR_CF=$1
PRT_CF=$2
SEGTYP_CT_PRM=$3
SSD_CF_PRM=$4
VRS_NF_PRM=$5
LAG_CF_PRM=$6
DATE_PRM=$7

# Job Initialization
JOBINIT


NSTEP=${NJOB}_05
# Making Segment's list file
#------------------------------------------------------------------------------
LIBEL="Making Segment's list file" 
SQR_PRG="ESTR0310"
SQR_O=${DFILT}/${NSTEP}_${IB}_${SQR_PRG}_O.dat
SQR_PARAM="${SEGTYP_CT_PRM} ${SSD_CF_PRM} ${VRS_NF_PRM} ${LAG_CF_PRM} ${DATE_PRM}"
SQR_BASE="BEST"
SQR

NSTEP=${NJOB}_07
# Get printer id from user
#------------------------------------------------------------------------------
LIBEL="Get printer id from user"
GET_PRTID_FROMUSER ${USR_CF}

NSTEP=${NJOB}_10
#Starpage printing
#------------------------------------------------------------------------------
LIBEL="Starpage printing"
PRN_NAME=${PRTID}
PRN_I=${DFILT}/${NJOB}_05_${IB}_ESTR0310_O.dat
PRN_FMT="estr0310"	#fichier .sp .sjp
PRN

NSTEP=${NJOB}_15
#Step to remove temporary job files
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary job files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

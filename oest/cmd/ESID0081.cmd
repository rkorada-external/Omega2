#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Update TBOPAR en mode Asynchrone
# nom du script SHELL		: ESID0091.cmd
# revision			: $Revision:   1.10  $
# date de creation		: 26/02/2004
# auteur			: MDJ
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# launched by Daemon Procedure 
#-----------------------------------------------------------------------------
# historiques des modifications :
# JJ/MM/AA	Par		Commentaires
# --------	--------------	------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

USR_DEM=$1
SSD_DEM=$2
CRE_D_PRM=$3

# Job Initialisation
JOBINIT

# Environ
. $DENV/EST.env

NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=" FREQJOB File Generation"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FREQJOB_O.dat
BCP_QRY="execute BEST..PtREQJOB_01 '${CRE_D_PRM}'"
BCP


NSTEP=${NJOB}_10
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

if [ -s ${DFILT}/${NJOB}_05_${IB}_BCP_FREQJOB_O.dat ] ; then

# Get input parameters from FREQJOB
set `GETPRM ${DFILT}/${NJOB}_05_${IB}_BCP_FREQJOB_O.dat`
USR_CF=${1}
CLOPER_LS=${2}
BLSYEA_NF=${3}
BLSMTH_NF=${4}
CLO_D=${5}

NSTEP=${NJOB}_15
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=" Update or insert lines in TBOPAR for closing tables "
ISQL_BASE="BSTA"
ISQL_QRY="execute PtTBOPAR_01 '${USR_CF}', '${CLOPER_LS}', ${BLSYEA_NF}, ${BLSMTH_NF}, '${CLO_D}' "
ISQL



NSTEP=${NJOB}_20
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in server"
SWITCH_SRV ${SRV_DEFAULT}


NSTEP=${NJOB}_25
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Update of Request table for Booking Load" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOB_05 '${CRE_D_PRM}', ${BLSYEA_NF}, ${BLSMTH_NF}, '${CLO_D}'"
ISQL


fi

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

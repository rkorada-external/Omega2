#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS
#                                 ecritures post omega
# nom du script SHELL		: ESID8901.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 05/10/1998
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# Input files
#       EST_FCTRSTAT		DFILP
#       EST_FSEGSTAT		DFILP
#
# job launched by ESPD8900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 06/12/2012 R. cassis :spot:24041 - Solvency 2
#[002] 12/09/2013 Florent      :spot:25427 Closing batches adaptation for centralization, maj step 30,50
#[003] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
SUFFTABLE=$1
NORME=$2

TCTRSTAT=TCTRSTAT_${SUFFTABLE}
TSEGSTAT=TSEGSTAT_${SUFFTABLE}
ICTRSTAT=ICTRSTAT_${SUFFTABLE}_00
ISEGSTAT=ISEGSTAT_${SUFFTABLE}_00
echo ${TCTRSTAT}

#if [ "${NORME}" = "EBS" ]
#then
#	PRS_CF=730
#	EPO_FSEGSTATSO=${EPO_FSEGSTATSOSII}
#	EPO_FCTRSTATSO=${EPO_FCTRSTATSOSII}
#else
#	PRS_CF=710
#	EPO_FSEGSTATSO=${EPO_FSEGSTATSO}
#	EPO_FCTRSTATSO=${EPO_FCTRSTATSO}
#fi

NSTEP=${NJOB}_05
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

########################
# Update of Infocenter #
########################

NSTEP=${NJOB}_30
#--------------------------------
LIBEL="filling BSAR..${TCTRSTAT} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EPO_FCTRSTATSO}
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TCTRSTAT}"
BCP

NSTEP=${NJOB}_50
# Begin Bcp
#--------------------------------
LIBEL="filling BSAR..${TSEGSTAT} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EPO_FSEGSTATSO}
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TSEGSTAT}"
BCP

NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND

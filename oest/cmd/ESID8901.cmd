#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS
#                                 Generation of a perimeter file
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
# job launched by ESID8900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[004] Florent      12/09/2013 :spot:25427 Closing batches adaptation for centralization, maj step 30,50
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CLODAT_D=$5

NSTEP=${NJOB}_05
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TCTRSTAT table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TCTRSTAT', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TCTRSTAT results is
CTRSTAT=`cat ${ISQL_FRES} | sed -e s/\ //g`
TCTRSTAT=T${CTRSTAT}

NSTEP=${NJOB}_15
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TSEGSTAT table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TSEGSTAT', '${CLODAT_D}',
                              ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TSEGSTAT results is
SEGSTAT=`cat ${ISQL_FRES} | sed -e s/\ //g`
TSEGSTAT=T${SEGSTAT}


########################
# Update of Infocenter #
########################

NSTEP=${NJOB}_30
#--------------------------------
LIBEL="filling BSAR..${TCTRSTAT} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FCTRSTAT}
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TCTRSTAT}"
BCP

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TCTRSTAT', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_50
#--------------------------------
LIBEL="filling BSAR..${TSEGSTAT} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FSEGSTAT}
BCP_TABLE="BSAR..${TSEGSTAT}"
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TSEGSTAT', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND

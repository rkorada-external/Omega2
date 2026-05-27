#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 injection des GTA et GTR ( SNEM ) dans l'infocentre
# nom du script SHELL		: ESID8802.cmd
# revision			: $Revision:   1.5  $
# date de creation		: 10/06/98
# auteur			: C.G.I.
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Injection of the SNEM Acceptance and Retrocession TL files into the infocenter
#
# Input files
#       EST_FSNEMHIST0		DFILP
#       EST_FTECLEDASNEM	DFILI
#       EST_FTECLEDRSNEM	DFILI
#
# launched by ESID8800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01] 12/09/2013 Florent  :spot:25427 Closing batches adaptation for centralization, maj step 25,45,60
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
CLODAT_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TTECLEDASNEM table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDASNEM', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDASNEM results is
TECLEDASNEM=`cat ${ISQL_FRES} | sed -e s/\ //g`
TTECLEDASNEM=T${TECLEDASNEM}

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TTECLEDRSNEM table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDRSNEM', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDRSNEM results is
TECLEDRSNEM=`cat ${ISQL_FRES} | sed -e s/\ //g`
TTECLEDRSNEM=T${TECLEDRSNEM}

NSTEP=${NJOB}_25
# filling TTECLEDASNEM table
#--------------------------------
LIBEL="filling ${TTECLEDASNEM} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FTECLEDASNEM}
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDASNEM}"
BCP

NSTEP=${NJOB}_35
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDASNEM', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_45
# filling TTECLEDRSNEM table
#--------------------------------
LIBEL="filling ${TTECLEDRSNEM} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FTECLEDRSNEM}
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDRSNEM}"
BCP

NSTEP=${NJOB}_55
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDRSNEM', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_60
# filling TSNEMHIST table
#--------------------------------
LIBEL="filling TSNEMHIST table"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_I=${EST_FSNEMHIST0}
BCP_TABLE="BSAR..TSNEMHIST"
BCP

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_65
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Extraction des reglements
#                                 retrocession
# nom du script SHELL		: ESID0066.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 20/05/99
# auteur			: 
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description
#   Extracting tables
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2


NSTEP=${NJOB}_10
# Begin bcp+ out
#----------------------------------------------------------------------------
LIBEL="bcp out of BTRAV..TRGLCOMPTA, export for accounting system"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_MGTS}
BCP_QRY="exec BCTA..PtRgComptaGen_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
BCP

JOBEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: DTRIG.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 05/05/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# Extract and drop triggers of one database
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT_SYB $0 $*

# Get Input Parameters
SRV=$2
BASE=$3

# Launch applicative job DTRIG01
NJOB="DROPTRIG"
JOBINIT
(${DUTI}/DTRIG01.cmd ${SRV} ${BASE} 2>&1; STEPEND $?) | ${TEE}
CHAINEND

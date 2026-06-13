#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: CTRIG.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 05/05/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
#  Create triggers on one database
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT_SYB $0 $*

# Get Input Parameters
SRVfrom=$2
BASE=$3
SRVto=$4  # optional parameter

# Launch applicative job CTRIG01
NJOB="CREATRIG"
JOBINIT
(${DUTI}/CTRIG01.cmd ${SRVfrom} ${BASE} ${SRVto} 2>&1; STEPEND $?) | ${TEE}
CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: DBCC.cmd
# revision			: $Revision: 1.1 $
# date de creation		: 05/05/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# DBCC on a database
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
CHECK=$4

# Launch applicative job DBCC0001
NJOB="DBCC"
JOBINIT
(${DSYBBIN}/dbcc.sh ${SRV} ${BASE} ${CHECK} 2>&1;STEPEND $?) | ${TEE}
CHAINEND

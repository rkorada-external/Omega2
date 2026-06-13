#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: DBCC_MULTI.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 13/08/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# Concurrent DBCC on each database of a server
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

# Launch applicative job dbcc.sh concurrently
NJOB="DBCC_MULTI"
JOBINIT
(${DSYBBIN}/dbcc_multi.sh ${SRV} 2>&1; STEPEND $?) | ${TEE}
CHAINEND

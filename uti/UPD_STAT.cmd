#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: UPD_STAT.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 05/05/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
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

# Launch applicative job upd_stat.sh
NJOB="UPD_STAT"
JOBINIT
(${DSYBBIN}/dba_update_stat.sh -S ${SRV} -v ${BASE} 2>&1; STEPEND $?) | ${TEE}
CHAINEND

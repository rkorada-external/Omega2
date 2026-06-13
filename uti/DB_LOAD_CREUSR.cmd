#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: LOAD_CREUSR.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 18/10/1999
# auteur			: VC
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# load d'une database d'un serveur sur un autre suivi d'un create users
# syntaxe:
#	LOAD_CREUSER {SRV_ORIG} {SRV_TGT} {BASE}
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get Input Parameters
SRV_ORIG=${2}
SRV_TGT=${3}
BASE=${4}

# Chain Initialization variables
CHAININIT_SYB $0 $*

# Launch applicative job LOAD
NJOB="LOAD_${BASE}"
JOBINIT
(${DSYBBIN}/dba_load_database.ksh -F ${SRV_ORIG} -T ${SRV_TGT} -D ${BASE} -s -n2 2>&1;STEPEND $?) | ${TEE}

CHAINEND

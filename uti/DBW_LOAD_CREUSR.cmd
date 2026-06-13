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
PFX_SRV=`expr substr ${SRV_TGT} 1 3`

# Chain Initialization variables
CHAININIT_SYB $0 $*

# Launch applicative job LSTUSER
NJOB="LSTUSER_${BASE}"
JOBINIT
(${DSYBBIN}/dropusr.sh ${SRV_TGT} ${BASE} > ${DSYBTMP}/${SRV_TGT}.${BASE}.dropuser.tmp 2>&1;STEPEND $?) | ${TEE}
chmod 755 ${DSYBTMP}/${SRV_TGT}.${BASE}.dropuser.tmp

# Launch applicative job DROPUSER
NJOB="DROPUSR_${BASE}"
JOBINIT
(${DSYBTMP}/${SRV_TGT}.${BASE}.dropuser.tmp 2>&1;STEPEND $?) | ${TEE}

# Launch applicative job LOAD
NJOB="LOAD_${BASE}"
JOBINIT
(${DSYBBIN}/loadinf_weekly.sh ${SRV_ORIG} ${SRV_TGT} ${BASE} 2>&1;STEPEND $?) | ${TEE}

# Launch applicative job CREUSER
NJOB="CREUSER_${BASE}"
JOBINIT
(${DSYBBIN}/creusr.sh ${SRV_TGT} ${BASE} 2>&1;STEPEND $?) | ${TEE}

# delete temporary files
NJOB="RMFIL_${BASE}"
RMFIL "${DSYBTMP}/${SRV_TGT}.${BASE}.dropuser.tmp"

CHAINEND

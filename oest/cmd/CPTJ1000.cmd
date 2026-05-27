#!/bin/ksh
#=============================================================================
# nom de l'application		: complete accounts Insertion 
# nom du script SHELL		  : CPTJ1000.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 02/10/2019
# auteur			            : C. SOCIE
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Insert file in data using CPDT0912
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/CPTJ1000.prm`
ADRESSE=$1
DEL_REP_DAYS=$2
USER_CF=$3

# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`


# Launch applicative job CPTJ1001
NJOB="CPTJ1001"
LOOP_JOB_POOL ${DCMD}/CPTJ1001.cmd SITE ${REMOTE_SITE} ${USER_CF} ${DATEJOUR} 2>&1 | ${TEE}

# Launch applicative job CPTJ1002
NJOB="CPTJ1002"
. ${DCMD}/CPTJ1002.cmd ${DATEJOUR} ${V_DATE_JOUR} ${ADRESSE}  ${DEL_REP_DAYS} 2>&1 | ${TEE}

# Closing the Chain
CHAINEND

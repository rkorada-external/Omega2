#!/bin/ksh
#=============================================================================
# nom de l'application		: DATABASE ADMINISTRATION
# nom du script SHELL		: GETANO00.cmd
# revision			: $Revision: 1.1 $
# date de creation		: 05/05/1998
# auteur			: JP
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# Get Ano files for all failed in the previous night according to $DRMF/save
# In the environment file, the followind variables must be defined :
#  NCHAIN : Chain name
#  ENV    : 1st environnement label (ex: P)
#  ENV_LL : Environnement label     (ex: PRODUCTION)
#  MACHINE: Machine 
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get Input Parameters
# They are stored in the .env file

# Launch applicative job GETANO01
NJOB="GETANO"
${DUTI}/GETANO01.cmd 2>&1 | ${TEE}
CHAINEND


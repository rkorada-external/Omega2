#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL		: ESTO2910.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 23/10/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Chain of retrocession reversal and carried forward entries generation
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recupere les parametres d'entree
set `GETPRM ${DPRM}/ESTO2910.prm`
CLODAT_D=$1
CRE_D=$2
BALSHEY_NF=$3

# Launch applicative job ESTO2901
NJOB="ESTO2911"
${DCMD}/ESTO2911.cmd ${CLODAT_D} ${CRE_D} ${BALSHEY_NF} 2>&1 | ${TEE}

CHAINEND

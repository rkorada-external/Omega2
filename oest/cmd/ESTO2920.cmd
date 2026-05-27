#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL		: ESTO2920.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 07/04/98
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
set `GETPRM ${DPRM}/ESTO2920.prm`
CLODAT_D=$1
SSD_CF=$2
CRE_D=$3
BALSHEY_NF=$4

# Launch applicative job ESTO2921
NJOB="ESTO2921"
${DCMD}/ESTO2921.cmd ${CLODAT_D} ${SSD_CF} ${CRE_D} ${BALSHEY_NF} 2>&1 | ${TEE}

CHAINEND

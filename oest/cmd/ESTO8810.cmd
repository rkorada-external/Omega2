#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Remontee sous BO ( Ouverture 98 )
# nom du script SHELL		: ESTO8810.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 26/10/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESTO8811
NJOB="ESTO8811"
${DCMD}/ESTO8811.cmd 2>&1 | ${TEE}

CHAINEND

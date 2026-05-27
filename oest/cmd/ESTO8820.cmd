#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Remontee sous BO ( Ouverture 98 )
# nom du script SHELL		: ESTO8820.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 07/04/98
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


# Launch applicative job ESTO8821
NJOB="ESTO8821"
${DCMD}/ESTO8821.cmd 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Remove transaction of 2,3,4,12 subsidiary in TDRYTRN table 
# nom du script SHELL		: ESIJ6990.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 17/02/98
# auteur			: (M.NAJI)
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

# Launch applicative job ESIJ0091
NJOB="ESIJ6991"
${DCMD}/ESIJ6991.cmd 2>&1 | ${TEE}

CHAINEND

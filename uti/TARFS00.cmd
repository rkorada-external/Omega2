#!/bin/ksh
#=============================================================================
# nom de l'application		: EXPLOITATION -  
# description			: tar fs 
#				  
# nom du script SHELL		: TARFS00.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 30/01/98
# auteur			: SCOR
# references des specifications	: 
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch job TARFS01.cmd
NJOB="TARFS01"
${DUTI}/TARFS01.cmd 2>&1 | ${TEE}

CHAINEND

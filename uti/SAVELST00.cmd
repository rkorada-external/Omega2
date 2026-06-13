#!/bin/ksh
#=============================================================================
# nom de l'application		: EXPLOITATION -  
# description			:sauvegarde des listes pouvant etre reimprimees 
#				  
# nom du script SHELL		: SAVELST00.cmd
# revision			: $Revision: 1.1 $
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

# Launch job SAVELST01.cmd
NJOB="SAVELST01"
${DUTI}/SAVELST01.cmd 2>&1 | ${TEE}

CHAINEND

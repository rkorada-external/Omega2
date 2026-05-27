#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine de reprise des fiers GT pour ajouter
#                                 le champs retintamt_m (retro interne)
# nom du script SHELL		: ESTD7000.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 04/03/03
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description  REPRISE
#
# Launch applicative jobs ESTD7001
#
#-----------------------------------------------------------------------------
# historique des modifications
#	Modification le
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESID7001
NJOB="ESTD7001"
${DCMD}/ESTD7001.cmd  2>&1 | ${TEE}


# Launch applicative job ESID7002
NJOB="ESTD7002"
${DCMD}/ESTD7002.cmd  2>&1 | ${TEE}

CHAINEND

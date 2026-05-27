#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS 
#                                 Chaine d'edition de la liste des anomalies
#                                 sur segment
# nom du script SHELL		: ESEJ0240.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 12/05/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0350.DOC
#-----------------------------------------------------------------------------
# description 
#   Print-out list of anomalies on segment after a PB request
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESEJ0241
NJOB="ESEJ0241"
LOOP_AS_PRINT ${DCMD}/ESEJ0241.cmd 2>&1 | ${TEE}

CHAINEND

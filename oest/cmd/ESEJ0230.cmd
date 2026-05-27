#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - CONTROLE DES ESTIMATIONS
#                                 Chaine d'edition de la liste des anomalies 
#                                 sur contrat
# nom du script SHELL		: ESEJ0230.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 30/04/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0340.DOC
#-----------------------------------------------------------------------------
# description
#   Print-out anomalies on contract after a PB request
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESEJ0231
NJOB="ESEJ0231"
LOOP_AS_PRINT ${DCMD}/ESEJ0231.cmd 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - CONTROLE DES ESTIMATIONS
#                                 Chaine d'edition de la liste des exercices
#                                 d'un segment
# nom du script SHELL		: ESEJ0220.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 12/05/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0330.DOC
#-----------------------------------------------------------------------------
# description
#   Print-out list of underwriting years of a segment after a PB request
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESEJ0221
NJOB="ESEJ0221"
LOOP_AS_PRINT ${DCMD}/ESEJ0221.cmd 2>&1 | ${TEE}

CHAINEND

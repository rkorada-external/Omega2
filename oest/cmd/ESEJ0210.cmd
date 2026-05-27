#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - CONTROLE DES ESTIMATIONS 
#                                 Chaine d'edition de la liste des affaires par
#                                 segment
# nom du script SHELL		: ESEJ0210.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 12/05/97
# auteur			: C.G.I. (P.HOUEE)
# references des specifications	: ESTJ0320.DOC
#-----------------------------------------------------------------------------
# description 
#   Print-out list of contracts for a segment after a PB request 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESEJ0211
NJOB="ESEJ0211"
LOOP_AS_PRINT ${DCMD}/ESEJ0211.cmd 2>&1 | ${TEE}

CHAINEND

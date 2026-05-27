#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS 
#                                 Chaine d'edition de la liste des segments
# nom du script SHELL		: ESEJ0200.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 28/04/97
# auteur			: CGI (P.HOUEE)
# references des specifications	: ESTJ0310.DOC
#-----------------------------------------------------------------------------
# description
#   Print-out list of segments after a PB request
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESEJ0201
NJOB="ESEJ0201"
LOOP_AS_PRINT ${DCMD}/ESEJ0201.cmd 2>&1 | ${TEE}

CHAINEND

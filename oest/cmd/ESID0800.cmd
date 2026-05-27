#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DE COHERENCE 
#                                 Chaine de controles de coherence des ecritures 
#				  de service ( disquette utilisateurs )
# nom du script SHELL		: ESID0800.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 22/10/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Conformity control of special entries
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}` 
CRE_D=$4


# Launch applicative job ESID0801
NJOB="ESID0801"
${DCMD}/ESID0801.cmd ${CRE_D} 2>&1 | ${TEE}


CHAINEND

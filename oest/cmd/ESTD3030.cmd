#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3030.cmd
# revision: $Revision:           1.1  $
# date de creation:              08/02/2007
# auteur:                        J.Ribot
# references des specifications : SPOT EST13720
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# cumul des fichiers créés par ESTD3020 aux fichiers GT CURGT STAGT
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#Entry parameters
set `GETPRM ${DPRM}/ESTD3030.prm`
IN_OUT=${1}


# Saving Files GTx (GT)                                      save des fichiers gt
export NUMFILE="GT"
NJOB="ESTD3031"
${DCMD}/ESTD3031.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Cat (GT , CURGT) Files                       integration des fichiers
NJOB="ESTD3032"
${DCMD}/ESTD3032.cmd ${IN_OUT} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND

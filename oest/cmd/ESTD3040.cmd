#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3040.cmd
# revision: $Revision:           1.1  $
# date de creation:              05/10/2007
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert Indiens
#
# generation de lignes a partir du fichier des transferts :
#
# des mvts a inserer dans CURGTA avec signe opposé (pour annuler bilan en cours)
# des mvts a inserer dans ARCSTATGTA au 31/12/bilan-1
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
set `GETPRM ${DPRM}/ESTD3040.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}

# Saving Files CURGTx (CURGT)                               save des fichiers curgt
export NUMFILE="CURGT"
NJOB="ESTD3041"
${DCMD}/ESTD3041.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files STATGTx                                  save des fichiers statgt
export NUMFILE="STATGT"
NJOB="ESTD3041"
#${DCMD}/ESTD3041.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files ARCSTATGTx                                  save des fichiers arcstatgt
export NUMFILE="ARCSTATGT"
NJOB="ESTD3041"
${DCMD}/ESTD3041.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Cat (CURGTA, ARCSTATGTA) Files                       integration des fichiers
NJOB="ESTD3042"
${DCMD}/ESTD3042.cmd ${BLCSHT_D} ${BALSHEY_NF} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND

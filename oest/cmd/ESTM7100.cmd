#!/bin/ksh
#=============================================================================
# nom de l'application: ESTIMATIONS
#Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL: ESTM7100.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 27/02/2006
# auteur                        : M.DJELLOULI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Transfert Corée Vie - Concaténation CURGTx et ARCSTATGTx
#-----------------------------------------------------------------------------
# historique des modifications
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#    14/03/2006    M.DJELLOULI  Inclusion CURGTx dans le Sauvegardes
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Saving Files GTx (GT)
export NUMFILE="GT"
NJOB="ESTM7101"
${DCMD}/ESTM7101.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files CURGTx (CURGT)
export NUMFILE="CURGT"
NJOB="ESTM7101"
${DCMD}/ESTM7101.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

# Saving Files ARCSTATGTx
export NUMFILE="ARCSTATGT"
NJOB="ESTD7101B"
${DCMD}/ESTM7101.cmd ${NUMFILE} 2>&1 | ${TEE}
# -------------------------------------------------------------------------------


# Cat (GT , CURGT, ARCSTATGT) Files
NJOB="ESTM7102"
${DCMD}/ESTM7102.cmd 2>&1 | ${TEE}
# -------------------------------------------------------------------------------

CHAINEND

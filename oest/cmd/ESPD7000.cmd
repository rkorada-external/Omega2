	#!/bin/ksh
#=============================================================================
# nom de l'application		     : ESTIMATIONS - INVENTAIRE
#                                 Chaine generation des mouvements
#                                 comptables pour People Soft ecriture post omega
# nom du script SHELL		     : ESPD7000.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 29/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#
#
# Launch applicative jobs ESCD9001 ESPD7001
#
#-----------------------------------------------------------------------------
# historique des modifications
#
#[001] 04/11/2015 R. Cassis     :spot:29654 Gestion plan2 pour le Post-omega.
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1
# Get entry parameters
# ${EST_PARAM} is a global environment variable
#SSDs0 subsidiaries of all closing years
#CLODAT0_D closing year label
#[001]
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
CLODAT0_D=$8
SEGTYP_CT=${11}
BOOKING_D=${18}
CONSOYEA=${22}
CONSOMTH=${23}

NJOB="ESCD9001"

. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${CONSOYEA} ${CONSOMTH} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${BOOKING_D}

# Launch applicative job ESPD7001
NJOB="ESPD7001"
${DCMD}/ESPD7001.cmd  ${BOOKING_D} ${CONSOYEA} ${CONSOMTH} ${CRE_D} ${DBCLO_D} 2>&1 | ${TEE}

CHAINEND

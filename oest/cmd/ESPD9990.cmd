#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - ZIP fichiers delta traitement post omega
#                                 ZIP des fichiers delta envoyés a People soft
# nom du script SHELL		: ESPD9990.cmd
# revision			: 5.1
# date de creation		: 08/09/2005
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   ZIP
#-----------------------------------------------------------------------------
# historique des modifications
#
# 17/11/2005   J. Ribot ajout appel du ESID9991.cmd
#[001] 04/11/2015 R. Cassis     :spot:29654 Gestion plan2 pour le Post-omega.
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#[001]
# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
CRE_D=$5
DBCLO_D=$6
CLODAT0_D=$8
BOOKING_D=${18}
CONSOYEA=${22}
CONSOMTH=${23}
SUFFTABLE=${27}

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${CONSOYEA} ${CONSOMTH} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${BOOKING_D}

# Launch applicative job ESPD9991
NJOB="ESPD9991"
${DCMD}/ESPD9991.cmd ${BOOKING_D} ${CONSOYEA} ${CONSOMTH} ${CRE_D} ${DBCLO_D} 2>&1 | ${TEE}

#------------------------------------------------------------------------------
# Commutation transactions calculation
#------------------------------------------------------------------------------

TRIM='4Q'

if [ ${CONSOMTH} = "3"   ]
then
TRIM='1Q'
fi

if [ ${CONSOMTH} = "6"   ]
then
TRIM='2Q'
fi

if [ ${CONSOMTH} = "9"   ]
then
TRIM='3Q'
fi

# Launch applicative job ESID9991
NJOB="ESID9991"
${DCMD}/ESID9991.cmd ${CONSOYEA} ${CONSOMTH} ${CLODAT0_D} "${TRIM}${CONSOYEA}" ${SUFFTABLE} 2>&1 | ${TEE}


CHAINEND

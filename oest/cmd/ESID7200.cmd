#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATIONS - INVENTAIRE
#                               Chaine d'extraction mensuelle VISMA
# nom du script SHELL		: ESID7200.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 18/09/2008
# auteur			        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description   VISMA MONTHLY EXTRACTION
# Launch applicative jobs ESCD9001 ESID7201
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#Get the input arguments
set `GETPRM ${DPRM}/ESID7200.prm`
MANU=${1}


if [ "$MANU" != "GO" ]
then
    # Get entry parameters
    # ${EST_PARAM} is a global environment variable
    set `GETPRM ${EST_PARAM}`
    SSDs0=$1
    BALSHTYEA_NF=$2
    BALSHTMTH_NF=$3
    CRE_D=$4
    DBCLO_D=$5
    CLODAT0_D=$6
    SEGTYP_CT=$8
    ACCOUNT_D=${10}
    BOOKING_D=${30}
    
    NJOB="ESCD9001"
    # Launch applicative job ESCD9001
    . ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${CLODAT0_D}
else
    echo
    echo
    echo "      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "      ----------------------------------------------------"
    echo "      !!!    Lancement du ESID7200 en mode MANUEL      !!!"
    echo "      Ne pas oublier de remettre MANU à NOGO dans le .prm "
    echo "      ----------------------------------------------------"
    echo "      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
    echo

    export EST_GTASW=${DFILP}/${ENV_PREFIX}_ESIJ7000_GTASW.dat
    export EST_GTRSW=${DFILP}/${ENV_PREFIX}_ESIJ7000_GTRSW.dat
fi

# Launch applicative job ESID7201
NJOB="ESID7201"
${DCMD}/ESID7201.cmd 2>&1 | ${TEE}

CHAINEND


#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine d'integration des mouvements 
#                                 comptables dans le GT quotidien 
# nom du script SHELL		: ESID7000.cmd
# revision			: $Revision: 1.1.1.1 $
# date de creation		: 01/08/97
# auteur			: C.G.I. (M.NAJI)
# references des specifications	: ESARC02F.doc
#-----------------------------------------------------------------------------
# description
#   Accounting transaction integration in daily LT ( set 28 )
#
# Launch applicative jobs ESCD9001 ESID7001
#
#-----------------------------------------------------------------------------
# historique des modifications
#	Modification le 14/08/1998 par M.NAJI
#---------------
#MODIFICATION   : [002]
#Auteur         : D.GATIBELZA
#Date           : 21/07/2010
#Version        : 10.1
#Description    : ESTDOM19231 V10 Inventaires de janvier sans taux sur Bilan en cours
#                 - au closing annuel, charger le taux de d�cembre YY dans janvier YY+1
#[003]  11/03/2011  Roger Cassis      :spot:21408 - Ajout job ESID7003 pour traitement de controle sur le CURGTA
#[004]  20/12/2022  DaD               :spira:108272 - Split ARCSTATGTA
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1
# Get entry parameters
# ${EST_PARAM} is a global environment variable
#SSDs0 subsidiaries of all closing years
#CLODAT0_D closing year label
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT0_D=$6
SEGTYP_CT=$8

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT0_D} ${CLODAT0_D}       

# Launch applicative job ESID7001
NJOB="ESID7001"
${DCMD}/ESID7001.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

#[002]
# Launch applicative job ESID7002
NJOB="ESID7002"
${DCMD}/ESID7002.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

#[003]
# Launch applicative job ESID7003
NJOB="ESID7003"
${DCMD}/ESID7003.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

#[004]
if [ ${PARM_IS_YEARLY} = "Y" ]
then
    ##########################################################################
    ECHO_LOG "#===> COMPTABILISATION ANNUELLE POS IFRS"
    ##########################################################################

    # Launch applicative job ESFJ0011 - Split ARCSTATGTA
    NJOB="ESFJ0011"
    ${DCMD}/ESFJ0011.cmd $DFILP/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat 4 2>&1 | ${TEE}
fi


CHAINEND

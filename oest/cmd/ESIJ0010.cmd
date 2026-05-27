#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Chaine d'integration des mouvements comptables dans le GT quotidien 
# nom du script SHELL            : ESIJ0010.cmd
# revision                       : $Revision:   1.2  $
# date de creation               : 01/08/97	
# auteur                         : S.LLORENTE
# references des specifications  : 
#-----------------------------------------------------------------------------
# description
#   Accounting transaction integration in daily LT ( set 28 )
#
# Launch applicative jobs ESIJ0011
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001]  01/02/2012   R. CASSIS  :spot:23329 - Gestion du déclenchement ONEGL et paramétrage optionnel du mode Simu
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#[001]
# test if transmitted parameter
if test $2
then
   P_PROCESSONEGL_CT=$2
fi

# Chain Initialization variables
CHAININIT $0 $1
# Get entry parameters
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

#[001]
set `GETPRM ${DPRM}/ESIJ0010.prm`
PROCESSONEGL_CT=${1}

#[001]
# parm parameters affected
if [ "${P_PROCESSONEGL_CT}" != "" ]
then
   PROCESSONEGL_CT=${P_PROCESSONEGL_CT}
   echo "# --> PROCESSONEGL_CT option transmitted by processing command parm field : ${PROCESSONEGL_CT}"  2>&1 | ${TEE}
fi

#[001]
NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

#[001]
# Launch applicative job ESIJ0011
NJOB="ESIJ0011"
${DCMD}/ESIJ0011.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} ${DBCLO_D} ${PROCESSONEGL_CT} 2>&1 | ${TEE}

CHAINEND

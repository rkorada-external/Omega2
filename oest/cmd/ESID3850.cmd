#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID3850.cmd
# date de creation              : 14/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 01/12/2011 Roger Cassis  :spot:22859  Ajout parametre pour declencher le process OneGl
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# test if transmitted parameter
if test $2
then
   P_PROCESSONEGL_CT=$2
fi

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

set `GETPRM ${DPRM}/ESID3850.prm`
PROCESSONEGL_CT=${1}

# parm parameters affected
if [ "${P_PROCESSONEGL_CT}" != "" ]
then
   PROCESSONEGL_CT=${P_PROCESSONEGL_CT}
   echo "# --> PROCESSONEGL_CT option transmitted by processing command parm field : ${PROCESSONEGL_CT}"  2>&1 | ${TEE}
fi

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID3851
NJOB="ESID3851"
${DCMD}/ESID3851.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${PROCESSONEGL_CT} 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESPD3850.cmd
# date de creation              : 14/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 01/12/2011 Roger Cassis  :spot:22859  Ajout parametre pour declencher le process OneGl
#[002] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
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

IDF_CT="$2"

set `GETPRM ${DPRM}/ESPD3850.prm`
PROCESSONEGL_CT=${1}

# parm parameters affected
if [ "${P_PROCESSONEGL_CT}" != "" ]
then
   PROCESSONEGL_CT=${P_PROCESSONEGL_CT}
   echo "# --> PROCESSONEGL_CT option transmitted by processing command parm field : ${PROCESSONEGL_CT}"  2>&1 | ${TEE}
fi

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

# Launch applicative job ESPD3851
NJOB="ESPD3851"
${DCMD}/ESPD3851.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PROCESSONEGL_CT} 2>&1 | ${TEE}

CHAINEND

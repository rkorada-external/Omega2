#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESPD3860.cmd
# date de creation              : 14/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:  :spot:21408 - Extract Ftecleda file from OneGl
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 26/08/2011 R. CASSIS  :spot:22435 Parametrage pour Reception du fichier sur le serveur ONEGL.
#[002] 19/03/2012 R. Cassis  :spot:23567 Ajustage sur noms de fichiers
#[003] 14/12/2017 R. Cassis  :spira:66593 Ajoute option de reprise FORCE_CT pour prendre le fichier MVT meme si erreurs détectées
#[004] 19/07/2019 R. Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[005] 20/01/2022 R. Cassis  :spira:96729 Get prm for SAP_IN varaible
#[006] 03/02/2022  T. DEUTSCH   :spira:100097 Add prm option to take SAP file
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

#[006]
IDF_CT=$2

#[002][006]
# Get entry parameters
#set `GETPRM ${EST_PARAM}`
#SSDs0=$1
#SSDs=$2
#BALSHTYEA_NF=$3
#BALSHTMTH_NF=$4
#CRE_D=$5
#DBCLO_D=$6
#ICLODAT_D=$7
#CLODAT_D=$8
#INVCONSO_D=${21}
#CONSOYEA=${22}
#CONSOMTH=${23}

#[006]
set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`
ENV_SAP_PROD=${1}
ENV_SAP_TST=${2}

NJOB="ESCD9001"
#[006]
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

#[002] [003] [004] [006]
# Launch applicative job ESPD3861
NJOB="ESPD3861"
${DCMD}/ESPD3861.cmd "${PARM_CRE_D}" "${PARM_CONSOYEA}" "${PARM_CONSOMTH}" "${PARM_INVCONSO_D}" "${ENV_SAP_PROD}" "${ENV_SAP_TST}" 2>&1 | ${TEE}

CHAINEND

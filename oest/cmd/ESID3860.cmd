#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID3860.cmd
# date de creation              : 14/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:  :spot:21408 - Extract Ftecleda file from OneGl
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] Dch : réactivation des traitements TEFJ0011 et ESID3861
#[002] 24/08/2011  R. Cassis    :spot:22435 Parametrage pour Reception du fichier sur le serveur ONEGL.
#[003] 03/05/2012 Roger Cassis  :spot:23699 On execute le ESID3861 dans tous les cas, suppression de la condition FRA1
#                                           CLODAT_D est pris au lieu de ICLODAT_D
#[004] 01/02/2016 Roger Cassis  :spot:30154 Ajoute option de reprise FORCE_CT pour prendre le fichier MVT meme si erreurs détectées
#[005] 19/07/2019 Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[006] 20/01/2022 Roger Cassis  :spira:96729 Get prm for SAP_IN varaible
#[007]  03/02/2022  T. DEUTSCH   :spira:100097 Add prm option to take SAP file
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

#[007]
IDF_CT=$2

#[007]
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

#[007]
set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`
ENV_SAP_PROD=${1}
ENV_SAP_TST=${2}

NJOB="ESCD9001"
#[007]
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

#[003] [005] [007]  
# Launch applicative job ESID3861
NJOB="ESID3861"
${DCMD}/ESID3861.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${ENV_SAP_PROD} ${ENV_SAP_TST} 2>&1 | ${TEE}

CHAINEND

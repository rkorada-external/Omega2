#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Chaine de mise a jour des versements
# nom du script SHELL           : ESID8500.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 08/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Chain of updating of the cessions
#
# Launch applicative jobs ESCD9001 ESID8501
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 16/12/2011 Roger Cassis   :spot:22862 - Ajout job ESID8502
#[002] 11/09/2018 MZM            :spira:70805 4Q2018 technical booking error on INT  - Ajout de la date en parametre dans le STEP 05
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
#[002]
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SPECEND_D=$7
SEGTYP_CT=${20}
SSDACC_LL=${60}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID8501
NJOB="ESID8501"
${DCMD}/ESID8501.cmd ${CLODAT_D} ${BALSHTMTH_NF} ${SSDACC_LL} ${SEGTYP_CT} ${BALSHTYEA_NF} ${SPECEND_D} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID8502
NJOB="ESID8502"
${DCMD}/ESID8502.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

CHAINEND

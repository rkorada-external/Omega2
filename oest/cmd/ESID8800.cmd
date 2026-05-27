#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			: Injection des GTA et GTR dans l'infocentre 
# nom du script SHELL           : ESID8800.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 31/10/1997
# auteur                        : LE ROY ( CGI )
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Injection of rows into the infocenter
#
# Launch applicative jobs ESCD9001 ESID8801 8802
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 16/02/2018 R. Cassis :spira:67175 Désactivation du chargement de la TTECLEDxSNEM, donc du job ESID8802. 
#[002] 16/03/2022 M. NAJI :spira:103098 remplacment des anciens parametres par les nouveaux 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

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

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${PARM_SSDCLO_LL} ${PARM_SSDCLO_LL} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_CRE_D} ${PARM_DBCLO_D} ${PARM_CLODAT_D} ${PARM_ICLODAT_D}

# Launch applicative job ESID8801
NJOB="ESID8801"
${DCMD}/ESID8801.cmd ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_ICLODAT_D} 2>&1 | ${TEE}

#[001]
# Launch applicative job ESID8802
#NJOB="ESID8802"
#${DCMD}/ESID8802.cmd ${PARM_CRE_D} ${PARM_ICLODAT_D}  ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} 2>&1 | ${TEE}

CHAINEND

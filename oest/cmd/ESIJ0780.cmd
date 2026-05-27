#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESIJ0780.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 19/03/2020 (jour 2 du confinement)
# auteur			            : S.Behague
# spira                   : 82196
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# historique des modifications
# [01] - S.Behague :spira:82196 - création
# [02] - S.Behague :spira:82196 - Ajout rename et dezippe des fichiers en entree
# [03] - S.Behague :spira:94442 I17: AE - Delta used IFRS 4 closing date instead of IFRS 17 one
# [04] - 09/03/2023 S.Behague :spira:104207 AE SAS - Improve error management
# [05] - 24/07/2023 S.Behague :US6234 Spira 111627 - L&H- SAS/Omega-Dedicated interface job for SAS
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

set `GETPRM ${EST_PARAM}`
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$6

#[03]
#. ${EST_PARAMI17}

#Get input parameters of ESCJ0000.prm
set `GETPRM ${DPRM}/ESCJ0000.prm`
CRE_D=$1

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/ESIJ0780.prm`
ADRESSE=$1
DEL_REP_DAYS=$2

# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`

# Launch applicative job ESIJ0781
NJOB="ESIJ0781"
${DCMD}/ESIJ0781.cmd ${CRE_D}


if [ ! -f $DFILT/${ENV_PREFIX}_ESIJ0780_CHAINEND_${IB}.txt ]
then
# Launch applicative job ESIJ0782
NJOB="ESIJ0782"
#LOOP_JOB_POOL ${DCMD}/ESIJ0782.cmd SITE ${REMOTE_SITE} ${BALSHTYEA_NF} ${CLODAT_D} ${BALSHTMTH_NF} 2>&1 | ${TEE}
LOOP_JOB_POOL ${DCMD}/ESIJ0782.cmd SITE ${REMOTE_SITE} ${CRE_D} 2>&1 | ${TEE}

rm -f $DFILT/${ENV_PREFIX}_ESIJ0780_CHAINEND_${IB}.txt

fi 

if [ -f ${DABORT}/${NCHAIN}_${IB}.wng ]
then
	export MAX_RETURN_CODE=99
fi

rm -f $DFILT/${ENV_PREFIX}_ESIJ0780_CHAINEND_${IB}.txt



# Closing the Chain
CHAINEND

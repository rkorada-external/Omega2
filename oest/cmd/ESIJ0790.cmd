#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service automatiques
# nom du script SHELL		  : ESIJ0790.cmd
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
set `GETPRM ${DPRM}/ESIJ0790.prm`
ADRESSE=$1
DEL_REP_DAYS=$2

# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`

# Launch applicative job ESIJ0791
NJOB="ESIJ0791"
${DCMD}/ESIJ0791.cmd ${CRE_D}

if [ ! -f $DFILT/${ENV_PREFIX}_ESIJ0790_CHAINEND_${IB}.txt ]
then
# Launch applicative job ESIJ0792
NJOB="ESIJ0792"
#LOOP_JOB_POOL ${DCMD}/ESIJ0792.cmd SITE ${REMOTE_SITE} ${BALSHTYEA_NF} ${CLODAT_D} ${BALSHTMTH_NF} 2>&1 | ${TEE}
LOOP_JOB_POOL ${DCMD}/ESIJ0792.cmd SITE ${REMOTE_SITE} ${CRE_D} 2>&1 | ${TEE}

rm -f $DFILT/${ENV_PREFIX}_ESIJ0790_CHAINEND_${IB}.txt

fi 

if [ -f ${DABORT}/${NCHAIN}_${IB}.wng ]
then
	export MAX_RETURN_CODE=99
fi

rm -f $DFILT/${ENV_PREFIX}_ESIJ0790_CHAINEND_${IB}.txt

# Closing the Chain
CHAINEND

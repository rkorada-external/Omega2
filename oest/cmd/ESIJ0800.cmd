#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service
# nom du script SHELL		  : ESIJ0800.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 01/06/2012
# auteur			            : L. RAKOTOZAFY
# fiche spot              : 23860 
#                         :spot:23860     LRAK
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   File integration of assistance entries
#-----------------------------------------------------------------------------
# historique des modifications
# [01] 21/10/2014  usuaksh  Spot #27483  Modified to pass DEL_REP_DAYS parameter.
# [02] 05/08/2020  s.Behague spira:88748 - I17: ESIJ0800 - Mailing: Loading report
# [03] 14/08/2020  S.Behague spira:87212 - IFRS17- REQ.LIF.01: AE interface for Life from SAS - lot2
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/ESIJ0800.prm`
ADRESSE=$1
ADRESSECSM=$2
DEL_REP_DAYS=$3

# Variable initialisation 
# -------------------------------------
DATEJOUR=`date +"%m/%d/%Y"`
V_DATE_JOUR=`date +"%Y%m%d"`

# Launch applicative job ESIJ0801
NJOB="ESIJ0801"
LOOP_JOB_POOL ${DCMD}/ESIJ0801.cmd SITE ${REMOTE_SITE} 2>&1 | ${TEE}

# Launch applicative job ESIJ0802
NJOB="ESIJ0802"
. ${DCMD}/ESIJ0802.cmd ${DATEJOUR} ${V_DATE_JOUR} ${ADRESSE}  ${DEL_REP_DAYS} 2>&1 | ${TEE}

# Closing the Chain
CHAINEND

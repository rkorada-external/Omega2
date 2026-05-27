#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - MISE A JOUR TREQJOB 
#                                 Mise a jour de la table des demandes PostOmega Final BEST..TREQJOB
# nom du script SHELL		: ESPJ8990.cmd
# revision			: 5.1
# date de creation		: 31/08/2005
# auteur			: M. DJELLOULI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Update of request table
#-----------------------------------------------------------------------------
# historique des modifications
# 
#[001] 04/11/2015 R. Cassis     :spot:29654 Gestion plan2 pour le Post-omega.
#[002] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[003] 25/04/2023 JYP/TD : spira 109440 : when SAP POSTING , check flag CLOSING_REQUEST_CANCELED
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

# Launch applicative job ESFD9001
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}



set `GETPRM ${DPRM}/ESPJ8990_REQUEST_${NORME_CF}.prm`
export CLOSING_REQUEST_CANCELED=${1}


# Launch applicative job ESPJ8991
NJOB="ESPJ8991"
${DCMD}/ESPJ8991.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PARM_DBCLO_D} ${PARM_INVCONSO_D} 2>&1 | ${TEE}


CHAINEND

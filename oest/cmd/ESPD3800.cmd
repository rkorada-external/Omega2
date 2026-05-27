#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Injection des ecritures post omega format GTA et GTR dans l'infocentre
# nom du script SHELL           : ESPD3800.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 16/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#  Injection of rows into the infocenter
#
# Launch applicative jobs ESCD9001 ESPD3801 3802
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 26/04/2011
#Version        : 11.1
#Description    : 1GL
#[002]  05/05/2011  R. CASSIS     :spot:21408 - Ajout parametres annee mois dans ESPD3801
#[003]  24/07/2012  R. CASSIS     :spot:23802 - SOLVENCY.
#[004]  31/07/2012  L. Rakotozafy :spot:24041 - Solvency II, corrections techniques
#[005]  15/05/2013  R. Cassis     :spot:25171 - Ajout test sur condition 2 pour traitement EBS. 
#[006] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[007] 23/05/2016 R. Cassis :spot:30635  mise a jour du commentaire du job execute en mode Social EBS
#[008] 21/09/2016 R. Cassis :spot:31263  Modification tests de conditions pour traitement du CONSO EBS
#[009] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[011] 19/04/2022 : RC  :spira:101543 Ajout du TYPEINV dans les noms de jobs.
#[012] 04/04/2025 : Mr JYP : spira 112324 : rounding estimates amounts calculations
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

export IDF_CT=$2
NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}


#[003]
if [ ${TYPEINV} = "POS" ]
then
	# Traitement du POS (SOCIAL)
	if [ ${NORME_CF} = "I4I" ] 
	then
		# Launch applicative job ESPD3801  SOCIAL IFRS
		# [002]
		NJOB="ESPD3801"
		${DCMD}/ESPD3801.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} 2>&1 | ${TEE}
	else
		# Launch applicative job ESPD3802  SOCIAL EBS [007]
		NJOB="ESPD3802EBS${TYPEINV}"
		${DCMD}/ESPD3802.cmd ${PARM_CRE_D} ${TYPEINV} EBS ${PARM_CONSOYEA} ${PARM_CONSOMTH} 2>&1 | ${TEE}
	fi
else
	#[008]
	# Traitement du POC (CONSO)
	if [ ${NORME_CF} = "I4I"  ] 
	then
		# Launch applicative job ESPD3802   CONSO IFRS
		NJOB="ESPD3802I4I${TYPEINV}"
		${DCMD}/ESPD3802.cmd ${PARM_CRE_D} ${TYPEINV} IFRS ${PARM_ICLODAT_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} 2>&1 | ${TEE}
	else
		# Launch applicative job ESPD3802   CONSO EBS
		#[005]
		NJOB="ESPD3802EBS${TYPEINV}"
		${DCMD}/ESPD3802.cmd ${PARM_CRE_D} ${TYPEINV} EBS ${PARM_ICLODAT_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} 2>&1 | ${TEE}
	fi
fi

# Launch applicative job for rounding split 
NJOB="ESFD3934${TYPEINV}"
${DCMD}/ESFD3934.cmd 2>&1 | ${TEE}
	
CHAINEND

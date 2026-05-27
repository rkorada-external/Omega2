#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE (chargement post omega TTECLEDSII)
# nom du script SHELL           : ESPD8600.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10/07/2012
# auteur                        : P. Pezout
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   :spot:23802 Generation of Infocenter tables
#
# Launch applicative jobs ESCD9001 ESID8601
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 19/10/2012 R. Cassis :spot:24041: Adaptations Solvency
#[002] 07/06/2016 R. Cassis :spot:30713  Ajout parm INVCONSO_D pour Archivage fichier POCE
#[003] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[004] 08/07/2021 D. DA SILVA TEIXEIRA : SPIRA 91532 Change parm INVCONSO_D -> CLODAT_D
#[005] 08/07/2021 D. DA SILVA TEIXEIRA : SPIRA 91532 Change parm CLODAT_D -> INVCONSO_D
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

#if [ "${EST_ESPD8600_COND1}" = "Y" ]
#then
#	TYPEINV=POS
#else
#	TYPEINV=POC
#fi

#[002]
#[005] Change PARM_CLODAT_D -> PARM_INVCONSO_D
# Launch applicative job ESPD3901
NJOB="ESPD8601"
${DCMD}/ESID8601.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV} ${PARM_SUFFTABLE} ${PARM_INVCONSO_D} 2>&1 | ${TEE}

CHAINEND

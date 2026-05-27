#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			: Injection des GTA et GTR dans l'infocentre ecritures post omega
# nom du script SHELL           : ESPD8800.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 16/06/2005
# auteur                        : J/ Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  Injection of rows into the infocenter
#
# Launch applicative jobs ESCD9001 ESPD8801 8802
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 20/09/2011  R. Cassis :spot:22637 - Modif temporaire pour Post Omega
#[002] 20/10/2011  R. Cassis :spot:22752 - Suppression Modif temporaire pour Post Omega - ajout dates en parametre pour ESPD8801
#[003] 07/12/2012  R. Cassis :spot:24041 - SOLVENCY 2
#[004] 22/12/2020 : M.NAJI :. SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


#[002]
# Launch applicative job ESPD8801
NJOB="ESPD8801"
${DCMD}/ESPD8801.cmd ${PARM_SUFFTABLE} ${PARM_CRE_D} ${PARM_INVCONSO_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${NORME_CF} 2>&1 | ${TEE}

CHAINEND

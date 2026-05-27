#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESPD8100.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : Roger Cassis
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative jobs ESCD9001 ESID8101
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 23/02/2016 R. Cassis :spot:30246 - Ajout gestion des Ultimates et Suppression fichiers avant le ESCD9001
#[002] 22/12/2020 : M.NAJI: . SPIRA 91531 
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

# Pour tests
#BALSHTYEA_NF=2015
#BALSHTMTH_NF=12
#CRE_D=20151216
#CLODAT_D=20151231

#[001]
NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*.dat"

NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

NORME=IFRS
if [ "${NORME_CF}" = "EBS" ]
then
	NORME=EBS
fi

# Launch applicative job ESPD8101
NJOB="ESID8101"
${DCMD}/ESID8101.cmd ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_ICLODAT_D} ${PARM_ICLODAT_D} ${PARM_INVCONSO_D} ${NORME} ${TYPEINV} 2>&1 | ${TEE}

CHAINEND

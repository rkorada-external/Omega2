#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESPD8200.cmd
# revision                      : 
# date de creation              : 14/09/2021
# auteur                        : Michael SEKBRAOUDINE
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative jobs ESFD9001 ESID8101
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 14/09/2021	: spira 98775 : séparation ESPD8100 IFRS et EBS
#[002] 01/07/2022 D.Teixeira Spira: 104403 - Add new job ESID8102 Controle Period and Closing type 
#[003] 14/11/2023 JYP/TD Spira: 110842 - for booking POCE do not check with ESID8102 
#[004] 06/08/2025 Mr JYP :US 5559 : SERQS split files by site , SII part
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

	# SII split by site
	NJOB="ESFD3937${TYPEINV}"
	${DCMD}/ESFD3937.cmd $EST_FTECLEDSII $ESF_FTECLEDSII_TOAS $ESF_FTECLEDSII_TOEU $ESF_FTECLEDSII_TOAM  $ESF_FTECLEDSII_FROMAS $ESF_FTECLEDSII_FROMEU $ESF_FTECLEDSII_FROMAM  2>&1 | ${TEE}

	NJOB="ESFD3937${TYPEINV}"
	${DCMD}/ESFD3937.cmd $EST_GTSII_RISKMARGIN $ESF_SII_RISKMARGIN_TOAS $ESF_SII_RISKMARGIN_TOEU $ESF_SII_RISKMARGIN_TOAM  $ESF_SII_RISKMARGIN_FROMAS $ESF_SII_RISKMARGIN_FROMEU $ESF_SII_RISKMARGIN_FROMAM  2>&1 | ${TEE}

fi

# Launch applicative job ESPD8101
NJOB="ESID8101"
${DCMD}/ESID8101.cmd ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_ICLODAT_D} ${PARM_ICLODAT_D} ${PARM_INVCONSO_D} ${NORME} ${TYPEINV} 2>&1 | ${TEE}


if [ "${param_IsEpoComptaRequestF}" = "Y" -a "${TYPEINV}" = "POC" -a "${NORME_CF}" = "EBS" ]
then
    echo -e "\n /!\ No period checks ESID8102 when Booking POCE \n"
else
	# Launch applicative job ESPD8102
	NJOB="ESID8102"
	${DCMD}/ESID8102.cmd ${NORME} 2>&1 | ${TEE}
fi 

CHAINEND

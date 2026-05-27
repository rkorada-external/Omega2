#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Rejets / Reconduction (ecritures post omega)
# nom du script SHELL           : ESPD2900.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 21/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Chain of retrocession reversal and carried forward entries generation
#-----------------------------------------------------------------------------
# historique des modifications
#
#   02/11/2006   J. Ribot  SPOT 13321 remplace le parametre BOOKING_D=${18} par INVCONSO_D=${21}
#                               dans la recuperation des parametres et dans l'appel ESPD2901.cmd
#[001] 21/06/2017 R. Cassis :spira:60427 Add ESPD2902 for POS EBS annual opening, ESPD2901 is used for POS IFRS only
#[002] 10/02/2021 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[003] 06/05/2021 L. DOAN :spira: 96045 EBS Gaapcode missing
#[004] 16/08/2021 JYP     :spira: 98350/94896 Granularity : add product code for retro 
#[005] 28/01/2022 R.Cassis :spira: 101117 Chain is not processed for EBS opening now.
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EPO_TOTGTAA
#	EPO_TOTGTAR
#	EPO_TOTGTR
# Output files
#	EPO_DLREJGTAA
#	EPO_DLREJGTAR
#	EPO_DLREJGTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


export IDF_CT="$2"

# Launch applicative job ESCD9001
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

#[002]
if [ "${NORME_CF}" = "I4I" ] 
then

	# Launch applicative job ESPD2901 - Annual opening for POS IFRS
	NJOB="ESPD2901"
	${DCMD}/ESPD2901.cmd ${PARM_INVCONSO_D} ${PARM_CONSOMTH} 2>&1 | ${TEE}
	EPO_DLREJGTAA=${EPO_DLREJGTAASO}
	EPO_DLREJGTAR=${EPO_DLREJGTARSO}
	EPO_DLREJGTR=${EPO_DLREJGTRSO}
#[005]
#else
#
#	# Launch applicative job ESPD2902 - Annual opening for POS EBS
#	NJOB="ESPD2902"
#	${DCMD}/ESPD2902.cmd ${PARM_INVCONSO_D} ${PARM_CONSOMTH} 2>&1 | ${TEE}
#	
#	EPO_DLREJGTAA=${EPO_DLREJGTAASIISO}
#        EPO_DLREJGTAR=${EPO_DLREJGTARSIISO}
#        EPO_DLREJGTR=${EPO_DLREJGTRSIISO}
#
fi


PARALLEL_JOB_INIT 3

# Launch applicative job on EPO_DLREJGTAA
NJOB="ESFD3813_EPO_DLREJGTAA"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EPO_DLREJGTAA} ${EPO_GAAPCOD_MAPPING}"


# Launch applicative job on EPO_DLREJGTAR
NJOB="ESFD3813_EPO_DLREJGTAR"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EPO_DLREJGTAR} ${EPO_GAAPCOD_MAPPING}"

# Launch applicative job on EPO_DLREJGTAR
NJOB="ESFD3813_EPO_DLREJGTR"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EPO_DLREJGTR} ${EPO_GAAPCOD_MAPPING}"


PARALLEL_JOB_END

PARALLEL_JOB_INIT 3

# Launch applicative job on EPO_DLREJGTAA
NJOB="ESFD3817_EPO_DLREJGTAA"
PARALLEL_JOB "${DCMD}/ESFD3817.cmd ${EPO_DLREJGTAA} ${ESF_FCTRI17PRD_NEW}"


# Launch applicative job on EPO_DLREJGTAR
NJOB="ESFD3817_EPO_DLREJGTAR"
PARALLEL_JOB "${DCMD}/ESFD3817.cmd ${EPO_DLREJGTAR} ${ESF_FCTRI17PRD_NEW}"

# Launch applicative job on EPO_DLREJGTR
NJOB="ESFD3818_EPO_DLREJGTR"
PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${EPO_DLREJGTR} ${ESF_FCTRI17PRD_NEW}"


PARALLEL_JOB_END

CHAINEND

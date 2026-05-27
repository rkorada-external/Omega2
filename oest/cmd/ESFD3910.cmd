#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 : BDA- Impact on AE Life IFRS17
# Revision                      : $Revision:   1.0  $
# Date de creation              : 30/06/2020
# Auteur                        : S.Behague
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#[002] 10/09/2020 JYP : Spira 83104 : add product catalog ESF_FCTRI17PRD_NEW  
#[003] 29/01/2021 JYP : SPIRA 91991 : Life files NOT yet implemented for I17L/P
#[004] 28/04/2021 SBE : SPIRA 93345 : I17 : RETRO - Life SAP posting - Copy
#[005] 27/07/2021 JYP : SPIRA 94896 : add I17PRODCOD_CT code into TTECLEDR
#[006] 08/03/2023 SBE : SPIRA 109160: IFRS17 LIFE - IFRS4 Reversal - Counterparty issue
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}




# temporary code, waiting for Life file from spiras 92905 92903
if  [ "${NORME_CF}" = "I17P" ] ||  [ "${NORME_CF}" = "I17L" ]
then
	if [ ! -f ${ESF_FTECLEDA_I17AELIFE} ]
	then
        ECHO_LOG "ESF_FTECLEDA_I17AELIFE=${ESF_FTECLEDA_I17AELIFE}  does not exist for I17L/P, create an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_I17AELIFE}"
	fi
	if [ ! -f ${ESF_FTECLEDR_I17AELIFE} ]
	then
        ECHO_LOG "ESF_FTECLEDR_I17AELIFE=${ESF_FTECLEDR_I17AELIFE}  does not exist for I17L/P, create an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDR_I17AELIFE}"
	fi
fi

PARALLEL_JOB_INIT 2


NJOB="ESFD3815_FTECLEDA_I17AELIFE"
PARALLEL_JOB "${DCMD}/ESFD3815.cmd ${ESF_FTECLEDA_I17AELIFE} ${ESF_FDETTRS_TXT}"


NJOB="ESFD3816_FTECLEDR_I17AELIFE"
PARALLEL_JOB "${DCMD}/ESFD3816.cmd ${ESF_FTECLEDR_I17AELIFE} ${ESF_FDETTRS_TXT}"


PARALLEL_JOB_END


# Launch applicative job ESFD3911
NJOB="ESFD3911"
${DCMD}/ESFD3811.cmd ${ESF_FTECLEDA_I17AELIFE} ${ESF_GAAPCOD_MAPPING}

# Launch applicative job ESFD3911
NJOB="ESFD3913"
${DCMD}/ESFD3813.cmd ${ESF_FTECLEDR_I17AELIFE} ${ESF_GAAPCOD_MAPPING}

# Launch applicative job ESFD3818_I17_ESF_FTECLEDR
NJOB="ESFD3918_TTECLEDR_LIFE"
${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR_I17AELIFE} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


# Launch applicative job ESFD3819_I17_ESF_FTECLEDA
NJOB="ESFD3919_TTECLEDA_LIFE"
${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA_I17AELIFE} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


CHAINEND

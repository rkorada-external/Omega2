#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : GAAPCODE TRANSFORMATION
# Revision                      : $Revision:   1.0  $
# Date de creation              : 04/01/2020
# Auteur                        : Linh.DOAN
# References des specifications : REQ 20.1
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- GAAP Code Conversion
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           04/01/2020      Linh DOAN      83101 			BDA- REQ20.1 - Transaction mapping 
# [002] 27/01/2020      Linh DOAN      83101                    BDA- REQ20.1 - add delta file
# [003]	07/06/2021 Linh DOAN : SPIRA 92996 GLT IFRS17- Missing field in TTECLEDA and TTECLEDR format
# [004] 28/11/2022 : SPIRA 107125: MZM : REQ20.1 - RA / RR View - REQ 20.1 GENERER FTECLEDR A PARTIR DU FTECLEDA
# [005] 17/01/2024 M.NAJI: SPIRA 111009   OPTIM : get data de l'ancien ESFD4037 à mettre le plus hat dans VTOM et en // 
#====================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#----------------------------------------------------------------------------
# FUNCTION: DECRYPT_PASSWD
# $1:  encrypted text
# Subject: decrypt text
#---------------------------------------------------------------------------


#pour tester
#IDF_CT=
#	IFRS4: IFR4_GAP_MAP_STD
#	EBS: EBS_GAP_MAP_STD
#	IFRS17: I17G_GAP_MAP_STD


IDF_CT=$2
export LIFE=`echo ${IDF_CT} | awk -F_ '{ print $4 }'`

NJOB="ESFD9001_${IDF_CT}"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#Create FGAAPMAP


#cp ${ESF_FTECLEDA_IN} ${ESF_FTECLEDA_OUT}
#cp ${ESF_FTECLEDR_IN}  ${ESF_FTECLEDR_OUT}


NJOB="ESFD4033_1_${NORME_CF}"
${DCMD}/ESFD4033_1.cmd  2>&1 | ${TEE}



PARALLEL_JOB_INIT 3 

    NJOB="ESFD4033_2I4_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4033_2I4.cmd  

    NJOB="ESFD4033_3EBS_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4033_3EBS.cmd 

    NJOB="ESFD4033_4I17_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4033_4I17.cmd 

PARALLEL_JOB_END



PARALLEL_JOB_INIT 4

    NJOB="ESFD4033_5ALL_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4033_5ALL.cmd  


    NJOB="ESFD4035_2I4_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4035_2I4.cmd  

    NJOB="ESFD4035_3EBS_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4035_3EBS.cmd  

    NJOB="ESFD4035_4I17_${NORME_CF}"
    PARALLEL_JOB ${DCMD}/ESFD4035_4I17.cmd  

PARALLEL_JOB_END

NJOB="ESFD4035_5ALL_${NORME_CF}"
${DCMD}/ESFD4035_5ALL.cmd  2>&1 | ${TEE}


NJOB="ESFD4071"
${DCMD}/ESFD4071.cmd 2>&1 | ${TEE}

NJOB="ESFD4072"
${DCMD}/ESFD4072.cmd 2>&1 | ${TEE}

PARALLEL_JOB_INIT 2

    NJOB="ESFD4073_ASSUMED"
    PARALLEL_JOB "${DCMD}/ESFD4073.cmd ${DFILT}/${NCHAIN}_ESFD4072_20_${IB}_FTECLEDAA.dat ${ESF_FTECLEDAA}"

    NJOB="ESFD4073_RETRO"
    PARALLEL_JOB "${DCMD}/ESFD4073.cmd ${DFILT}/${NCHAIN}_ESFD4072_60_${IB}_FTECLEDAR_CLI.dat ${ESF_FTECLEDAR}" 

PARALLEL_JOB_END

PARALLEL_JOB_INIT 2

    NJOB="ESFD4074"
    PARALLEL_JOB  ${DCMD}/ESFD4074.cmd 

    NJOB="ESFD4075"
    PARALLEL_JOB  ${DCMD}/ESFD4075.cmd 

PARALLEL_JOB_END



CHAINEND

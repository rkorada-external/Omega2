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
#====================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


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


NJOB="ESFD4031_${NORME_CF}"
${DCMD}/ESFD4031.cmd "${ESF_FGAAPMAP_ASSUMED}" "${ESF_FGAAPMAP_RETRO}"


if [ "X${LIFE}" == "XLIF" ]
then
PARALLEL_JOB_INIT 2

NJOB="ESFD4034_${NORME_CF}_ESF_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD4034.cmd ${EST_FTECLEDA} ${EPO_FTECLEDA} ${ESF_FTECLEDA} ${ESF_FGAAPMAP_ASSUMED} ${ESF_FTECLEDA_OUT} ${ESF_FTECLEDA_DELTA}"

NJOB="ESFD4036_${NORME_CF}_ESF_FTECLEDR"
PARALLEL_JOB "${DCMD}/ESFD4036.cmd ${EST_FTECLEDR} ${EPO_FTECLEDR} ${ESF_FTECLEDR} ${ESF_FGAAPMAP_RETRO} ${ESF_FTECLEDR_OUT} ${ESF_FTECLEDR_DELTA}"

PARALLEL_JOB_END

else


NJOB="ESFD4033_${NORME_CF}_ESF_FTECLEDA"
${DCMD}/ESFD4033.cmd ${EST_FTECLEDA} ${EPO_FTECLEDA} ${ESF_FTECLEDA} ${ESF_FGAAPMAP_ASSUMED} ${ESF_FTECLEDA_OUT} ${ESF_FTECLEDA_DELTA} 2>&1 | ${TEE}


#[004]
NJOB="ESFD4035_${NORME_CF}_ESF_FTECLEDR"
${DCMD}/ESFD4035.cmd ${EST_FTECLEDR} ${EPO_FTECLEDR} ${ESF_FTECLEDR} ${ESF_FGAAPMAP_RETRO} ${ESF_FTECLEDR_OUT} ${ESF_FTECLEDR_DELTA} 2>&1 | ${TEE} 

if [[ "${NORME_CF}" = I17* ]]
then
	NJOB="ESFD4037_${NORME_CF}"
	${DCMD}/ESFD4037.cmd ${ESF_FTECLEDA_OUT} ${ESF_FTECLEDR_OUT} 2>&1 | ${TEE}
fi
fi





CHAINEND

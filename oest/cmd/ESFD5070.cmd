#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS - MERGE BBNI   
# nom du script SHELL           : ESFD5070.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15/04/2025
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  SPIRA 101493:  MERGE Des Fichiers EBS et EBS-BBNI 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]  11/07/2025 : MZM : US5637 Transcodification EBS ==> EBS INI 
#===============================================================================
#set -x

IDF_CT=$2


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

if [ ${IDF_CT} = "EBS_ESFD5070" ] 
then

# Launch applicative job ESFD5071 FOR Transcodification EBS ==> BBNI
NJOB="ESFD5071"
${DCMD}/ESFD5071.cmd   2>&1 | ${TEE} 

fi


if [ ${IDF_CT} = "EBS_ESFD5070_INI" ]
then

# Launch applicative job ESFD5072 FOR Transcodification EBS ==> EBS INI 
# And generate files To Update TSECIFRS AND TRETIFRS in ESPD8000 CHAIN

NJOB="ESFD5072"
${DCMD}/ESFD5072.cmd   2>&1 | ${TEE}

fi


if [ ${IDF_CT} = "EBS_ESFD5070_ALL" ]
then

# Launch applicative job ESFD5073 FOR MERGE ALL  EBS ==> TO UPDATE TTECLEDA/R/SII
NJOB="ESFD5073"
${DCMD}/ESFD5073.cmd   2>&1 | ${TEE}


CHAINEND

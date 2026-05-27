#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : Merge cashflow and discount files GTSII format
# Nom du script SHELL           : ESFD3730.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 20/04/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# Merge cashflow and discount files
#  - filtre  Maintenance Expenses cashflow 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           07/03/2019      Linh DOAN      77663 			Merge cashflow and discount files IFRS17
#       [002]           19/02/2021      Linh DOAN      85522 			technical cashflow flux
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#IDF_CT=I17G_SII_MRG_INI et  I17G_SII_MRG_STD 

IDF_CT=$2




NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#PER_CT=${TYPEINV}

if [ "${CONTEXT_CT}" = INI ]
then
	 # REQ 08.01 :Merge IFRS17 cashflow and discount files
        NJOB="ESFD3833${TYPEINV}"
        ${DCMD}/ESFD3833.cmd ${IDF_CT}  2>&1 | ${TEE}

else

	# REQ 08.01 :Merge IFRS17 cashflow and discount files
	NJOB="ESFD3831${TYPEINV}"
	${DCMD}/ESFD3831.cmd ${IDF_CT}  2>&1 | ${TEE}

fi

CHAINEND
 

 

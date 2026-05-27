#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : Merge cashflow and discount files
# Nom du script SHELL           : ESFD3730.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 15/04/2019
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
#       [002]           14/10/2020      Linh DOAN      84655                    Merge cashflow of AoC
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester
#IDF_CT=I17G_SII_ALL_STD

IDF_CT=$2



NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#PER_CT=${TYPEINV}


if [[ "${IDF_CT}" =~ I17(G|L|P)_SII_ALL_AOC ]]
then

        # REQ 08.01 :Merge IFRS17 cashflow of Aoc
        NJOB="ESFD3733${TYPEINV}"
        ${DCMD}/ESFD3733.cmd   2>&1 | ${TEE}

else
	# REQ 08.01 :Merge IFRS17 cashflow and discount files of IFRS17
        NJOB="ESFD3731${TYPEINV}"
        ${DCMD}/ESFD3731.cmd   2>&1 | ${TEE}


fi



CHAINEND
 

 

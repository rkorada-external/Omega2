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
#       [001]           25/11/2019      Linh DOAN      77663 			Booking cashflows and accouting files
#       [002]           19/04/2024      MZM            111540 		ESFD8600 - TTECLED tables upload in closing extended period
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester
#IDF_CT=I17G_OMG_DW_STD (FOR ALL NORME)

#IDF_CT=I17L_OMG_DW_POX  FOR I17L AND I17P DURING POSX

IDF_CT=$2




NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#PER_CT=${TYPEINV}

if [ "${IDF_CT}" =  "I17G_OMG_DW_STD" ]
then

# REQ 08.01 : Booking ifrs17 files to infocenter
NJOB="ESFD8601"
${DCMD}/ESFD8601.cmd  2>&1 | ${TEE}

fi

if [ "${IDF_CT}" =  "I17L_OMG_DW_STD" ]
then

# REQ 08.01 : Booking ifrs17 files POSX to infocenter

NJOB="ESFD8602"
${DCMD}/ESFD8602.cmd  2>&1 | ${TEE}

fi

CHAINEND
 

 

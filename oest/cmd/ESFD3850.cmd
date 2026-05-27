#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Interface SAP-IFRS17 : Send GTL EBS and IFRS17 files to SAP
# Nom du script SHELL           : ESFD3850.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 12/05/2020
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
#       [001]           12/05/2020      Linh DOAN      xxxx 			Send GTL EBS and IFRS17 files to SAP
#====================================================================================================
#set -x

IDF_CT="$2"

# Call generic functions
. ${DUTI}/fctgen.cmd

# test if transmitted parameter
if test $3
then
   P_PROCESSONEGL_CT=$3
fi


# Chain Initialization variables
CHAININIT $0 $1


#IDF_CT=I17G_OMG_SAP_STD

#IDF_CT="$2"

set `GETPRM ${DPRM}/ESFD3850.prm`
PROCESSONEGL_CT=${1}


# parm parameters affected
if [ "${P_PROCESSONEGL_CT}" != "" ]
then
   PROCESSONEGL_CT=${P_PROCESSONEGL_CT}
   echo "# --> PROCESSONEGL_CT option transmitted by processing command parm field : ${PROCESSONEGL_CT}"  2>&1 | ${TEE}
fi

echo "IDF=$IDF_CT"

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

#PER_CT=${TYPEINV}

NJOB="ESFD3851${TYPEINV}"
${DCMD}/ESFD3851.cmd ${PROCESSONEGL_CT}  2>&1 | ${TEE}


CHAINEND
 

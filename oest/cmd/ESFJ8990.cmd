#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 REQ1000.13- IFRS 17- Closing plan generation 
# Nom du script SHELL           : ESFJ8990.cmd
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
#       [001]           19/02/2020      Linh DOAN      83904 			REQ1000.13- IFRS 17- Closing plan generation
#       [002]           25/04/2023      JYP/TD         109440           when SAP POSTING , check flag CLOSING_REQUEST_CANCELED
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester
#IDF_CT=I17G_OMG_CLO_STD

IDF_CT=$2


NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


set `GETPRM ${DPRM}/ESFJ8990_REQUEST_${NORME_CF}.prm`
export CLOSING_REQUEST_CANCELED=${1}


# REQ1000.13- IFRS 17- Closing plan I17G
NJOB="ESFJ8991"
${DCMD}/ESFJ8991.cmd 2>&1 | ${TEE}


CHAINEND
 

 

#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Spira 87876 : Merge GTL files from INI and STD
# Nom du script SHELL           : ESFD3870.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 17/07/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# Merge GLT files
#	- CSM
#	- from INI block
# 	- from STD block		
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           17/07/2020      Linh DOAN      87876 			Merge GLT files  from INI and STD to form an unique GLT of IFRS17 Closing
#       [002]           19/07/2023      MZM            110198  Generation of CSM LC ENDING Files
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#IDF_CT=I17G_GLT_ALL_STD

IDF_CT=$2




NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#PER_CT=${TYPEINV}

# REQ 08.01 :Merge IFRS17 GLT files of INI and STD closings
NJOB="ESFD3871${TYPEINV}"
${DCMD}/ESFD3871.cmd ${IDF_CT}  2>&1 | ${TEE}


## [002]

if [ "${IDF_CT}" = "I17G_GLT_ALL_STD" ] || [ "${IDF_CT}" = "I17P_GLT_ALL_STD" ] || [ "${IDF_CT}" = "I17L_GLT_ALL_STD" ] || [ "${IDF_CT}" = "I17S_GLT_ALL_STD" ]
then	

# Generation of LC and CSM ENDING File
NJOB="ESFD3872${TYPEINV}"
${DCMD}/ESFD3872.cmd ${IDF_CT}  2>&1 | ${TEE}

fi

CHAINEND

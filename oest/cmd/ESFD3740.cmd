#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.2 : Maintenance Expenses Paid
# Nom du script SHELL           : ESFD3740.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 07/03/2019
# Auteur                        : L.EL-FAHIM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# SPIRA 71570 : REQ 11.02 - IFRS17- Closing schedule : new chain to calculate mainteance Expenses Paid:
#  - Calculation of Mainteance Expenses Paid
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#	[001] 		07/03/2019 		L.ELFAHIM 	SPIRA : 71570 	Maintenance Expenses Paid Calculation
#	[002]		10/08/2020		N.DOAN		SPIRA : 87876 	REQ08.01- Discount accounting rules review 	
#	[003]		05/11/2020      N.DOAN		SPIRA : 90492 	add Quarterly Written Premium
# 	[004]    	19/02/2021      N.DOAN  	SPIRA : 85522 	technical cashflow flux
#	[005]    	16/09/2021      LEL   		SPIRA	97351  	MOVE CONTENT OF JOB ESID3741 TO ESFD3630
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
#set `GETPRM ${EST_PARAM}`
#SSDs0=$1
#SSDs=$2
#BALSHTYEA_NF=$3
#BALSHTMTH_NF=$4
#CRE_D=$5
#DBCLO_D=$6
#ICLODAT_D=$7
#CLODAT_D=$8
            
IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd  ${IDF_CT}



#CHAINEND
########################################################################


 # Launch applicative job for TL genenration using PRSMAP
NJOB="ESFD3742${TYPEINV}_${CONTEXT_CT}"
${DCMD}/ESFD3742.cmd  2>&1 | ${TEE}


if [ "${CONTEXT_CT}" = "STD" ]
then

	# Launch applicative job for TL STD genenration
        NJOB="ESFD3744${TYPEINV}_${CONTEXT_CT}"
        ${DCMD}/ESFD3744.cmd  2>&1 | ${TEE}
	
	# Launch quarterly written premium extraction
	NJOB="ESFD3747${TYPEINV}_${CONTEXT_CT}"
	${DCMD}/ESFD3747.cmd  2>&1 | ${TEE}


else # INI context

	 # Launch applicative job for TL INI genenration
        NJOB="ESFD3743${TYPEINV}_${CONTEXT_CT}"
        ${DCMD}/ESFD3743.cmd  2>&1 | ${TEE}


	# Launch applicative job for futures transformation
        NJOB="ESFD3745${TYPEINV}_${CONTEXT_CT}"
        ${DCMD}/ESFD3745.cmd  2>&1 | ${TEE}

	# Launch applicative job for NDIC transformation
        NJOB="ESFD3746${TYPEINV}_${CONTEXT_CT}"
        ${DCMD}/ESFD3746.cmd  2>&1 | ${TEE}

fi

 # Launch applicative job for TL merge
 NJOB="ESFD3741${TYPEINV}_${CONTEXT_CT}"
 ${DCMD}/ESFD3741.cmd  2>&1 | ${TEE}


CHAINEND
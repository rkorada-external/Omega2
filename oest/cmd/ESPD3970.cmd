#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 88638
# Revision                      : $Revision:   1.0  $
# Date de creation              : 06/10/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           07/10/2020      Linh DOAN      88638 			SAP feedback
#       [002]           31/07/2025      Sir JYP        5559 			US 5559 spira 113075 : SERQS split files by site
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester


IDF_CT=$2



NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd "${IDF_CT}" 

# Launch applicative job for TL merge
NJOB="ESPD3971${TYPEINV}"
${DCMD}/ESPD3971.cmd 2>&1 | ${TEE}


#=========================================== split TTECLEDR only for EBS
if [  ${NORME_CF} = "EBS" ]
then
	NJOB="ESFD3936R${TYPEINV}"
	${DCMD}/ESFD3936.cmd $ESF_FTECLEDR_MRG  $ESF_FTECLEDR_TOAS $ESF_FTECLEDR_TOEU $ESF_FTECLEDR_TOAM  $ESF_FTECLEDR_FROMAS $ESF_FTECLEDR_FROMEU $ESF_FTECLEDR_FROMAM   2>&1 | ${TEE}


	PARALLEL_JOB_INIT 2
	if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
	then	
			NJOB="ESFD3813_${NORME_CF}_AS"
			PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS} ${EPO_GAAPCOD_MAPPING_FROMAS}"
	fi			
	if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
	then	
			NJOB="ESFD3813_${NORME_CF}_EU"
			PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU} ${EPO_GAAPCOD_MAPPING_FROMEU}"
	fi 
	if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
	then	
			NJOB="ESFD3813_${NORME_CF}_AM"
			PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM} ${EPO_GAAPCOD_MAPPING_FROMAM}"
	fi
	PARALLEL_JOB_END
	
	PARALLEL_JOB_INIT 2	  
	if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
	then
		NJOB="ESFD3818_${NORME_CF}_AS"
		PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS}  ${ESF_FCTRI17PRD_FROMAS}"		
	fi	
	if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
	then	
		NJOB="ESFD3818_${NORME_CF}_EU"
		PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}  ${ESF_FCTRI17PRD_FROMEU}"
	fi 
	if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
	then
		NJOB="ESFD3818_${NORME_CF}_AM"
		PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}  ${ESF_FCTRI17PRD_FROMAM}"	
	fi 
	PARALLEL_JOB_END

fi 
#=========================================== End split TTECLEDR only for EBS


CHAINEND

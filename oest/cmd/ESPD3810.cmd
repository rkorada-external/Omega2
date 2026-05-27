#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 : BDA- Impact on Omega closing
# Revision                      : $Revision:   1.0  $
# Date de creation              : 09/04/2020
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
#       [001]           09/04/2020      Linh DOAN      83103 			        BDA- Impact on Omega closing
#	[002]               01/07/2020      Linh DOAN      83103			        fix NJOB
# 	[003]		        23/03/2021	    Linh DOAN      91531  			        fix mapping		
#   [004]               16/08/2021      JYP            98350/94896              Granularity : add product code for retro
#   [006]               14/12/2021      Mr JYP         101025                   override I17PRODCOD_CT code into TTECLEDR
#   [007]               19/07/2022      Mr JYP         105114                   update POCE/POCI ANNUL_MVT file
#   [008]               21/07/2022      Mr JYP         105114                   update POCE/POCI ANNUL_MVT file
#   [009]               26/07/2023      Mr JYP         110061                   update product code for MTH file
#   [010]               10/02/2026      Mr JYP         US8270                   SERQS RA SAP Phase1  
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester
#	EBS: EBS_GLT_GAP_STD


IDF_CT=$2



NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


if [ "${TYPEINV}" = "POC" ]  && [ "${NORME_CF}" = "I4I" ]
then 
 
            # Launch applicative job for TL split by site
             NJOB="ESFD3935${TYPEINV}"
             ${DCMD}/ESFD3935.cmd $EPO_FTECLEDA $ESF_FTECLEDA_MVT_TOAS $ESF_FTECLEDA_MVT_TOEU $ESF_FTECLEDA_MVT_TOAM  $ESF_FTECLEDA_MVT_FROMAS $ESF_FTECLEDA_MVT_FROMEU $ESF_FTECLEDA_MVT_FROMAM  2>&1 | ${TEE}
             
            
            #----------------- Launch applicative job GAAP_CODE on external files 
            PARALLEL_JOB_INIT 2
            
            if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
            then
            	NJOB="ESFD3811_${NORME_CF}_AS"
            	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAS}/$ESF_FTECLEDA_MVT_TOAS  ${EPO_GAAPCOD_MAPPING_FROMAS}"
            fi 
            if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
            then
            	NJOB="ESFD3811_${NORME_CF}_EU"
            	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPEU}/$ESF_FTECLEDA_MVT_TOEU ${EPO_GAAPCOD_MAPPING_FROMEU}"
            fi 
            if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
            then
            	NJOB="ESFD3811_${NORME_CF}_AM"
            	PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAM}/$ESF_FTECLEDA_MVT_TOAM ${EPO_GAAPCOD_MAPPING_FROMAM}"
            fi 
            PARALLEL_JOB_END

fi 


PARALLEL_JOB_INIT 2

# Launch applicative job ESFD3810_EBS_FTECLEDA
NJOB="ESFD3811_EPO_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${ESF_FTECLEDA_MVT_LOCALSIT} ${EPO_GAAPCOD_MAPPING}"


# Launch applicative job ESFD3810_EBS_FTECLEDR
NJOB="ESFD3813_EPO_FTECLEDR"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EPO_FTECLEDR} ${EPO_GAAPCOD_MAPPING}"

PARALLEL_JOB_END


PARALLEL_JOB_INIT 3

NJOB="ESFD3819_EBS_EPO_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA_MVT_LOCALSIT} ${ESF_FCTRI17PRD_NEW}"

NJOB="ESFD3819_FTECLEDA_MTH"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${EST_FTECLEDA_MTH} ${ESF_FCTRI17PRD_NEW}"


NJOB="ESFD3818_EBS_EPO_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${EPO_FTECLEDR} ${ESF_FCTRI17PRD_NEW}"

PARALLEL_JOB_END


########## START : update specific file POCI/POCE   ############################
if [ -s "$EPO_FTECLEDACO_ANNULMVT" ] && [ "$TYPEINV" = "POC" ]
then

NJOB="ESFD3811_ANNULMVT_POC"
${DCMD}/ESFD3811.cmd ${EPO_FTECLEDACO_ANNULMVT} ${EPO_GAAPCOD_MAPPING}  2>&1 | ${TEE}

NJOB="ESFD3819_ANNULMVT_POC"
${DCMD}/ESFD3819.cmd ${EPO_FTECLEDACO_ANNULMVT} ${ESF_FCTRI17PRD_NEW}  2>&1 | ${TEE}

fi 
########## END : update specific file POCI/POCE ############################




# Launch applicative job ESFD3949_EBS_ESF_FTECLEDA
NJOB="ESFD3949_EBSA"
${DCMD}/ESFD3949.cmd ${ESF_FTECLEDA_MVT_LOCALSIT} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}



# Launch applicative job ESFD3949_EBS_ESF_FTECLEDA
NJOB="ESFD3948_EBSR"
${DCMD}/ESFD3948.cmd ${EPO_FTECLEDR} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


CHAINEND

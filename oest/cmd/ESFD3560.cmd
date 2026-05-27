#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD3950.cmd
# date de creation              : 17/04/2023
# auteur                        : JYP/TD
#-----------------------------------------------------------------------------
# description:  :spira 109178 : this chain check SAP return file for I17G/P/L when mode=4 (SIMU)
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001]  18/04/2023 JYP/TD :spira:109178: split into 3 jobs for SIMU cases
#[002]  21/04/2023 JYP/TD :spira:109440: flag recover=N here, Y in ESFD3460-recover
#[003]  23/05/2023 JYP/TD :spira:109816: add parameters ${BALSHTYEA_NF}  ${BALSHTMTH_NF} for ESFD3964 
#[004]  24/05/2023 JYP/TD :spira:109832: FS issue, compress file into DFILT
#[005]	18/04/2024 JYP    :spira:111359: manage MDEL file in a specific job
#[006]  25/04/2024 JYP    :spira 111359: manage SIMU IFRS4 and EBS, do not block the closing
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#========= Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


#------------- get parameter SAP -----
if [ "${NORME_CF}" = "I4I" ]
then 
	set `GETPRM ${DPRM}/SAP_I4I_ENV.prm`
	if [[ "${SRV}" = "PRD_TPO2" ]]
	then
			export ENV_SAP=${1}
	else
			export ENV_SAP=${2}
	fi
else
	set `GETPRM ${DPRM}/SAP_ENV.prm`
	if [[ "${SRV}" = "PRD_TPO2" ]]
	then
			export ENV_SAP=${1}
	else
			export ENV_SAP=${2}
	fi
fi 	
#-------------------------------------------------------


if [ "${PARAM_IS_SAP_POSTING}" = "Y" -o "${PARM_IS_COMPTA}" = "Y" ] && [ "${TYPEINV}" != "POC" ]
then
    export MODE="1" # COMPTABILISATION
else
    export MODE="4" # SIMULATION
fi


if [ "$MODE" = "4" -a "${ENV_SAP}" = "1" ]
then

	#================ get input file, return file from SAP
	FLAG_ERR_WARN="W"
	FLAG_FTPMGET="Y"
	FLAG_RECOVER="N" # Y from recover chain ESFD3460
	NJOB="ESFD3962_${NORME_CF}"
	${DCMD}/ESFD3962.cmd "$FLAG_ERR_WARN" "$FLAG_FTPMGET" "$FLAG_RECOVER"  2>&1 | ${TEE}
	
	#================ checks amounts, SAP IDs
	if [ -s ${ESF_FTECLEDA_MVT_TMP} ]
	then

		if [ "${NORME_CF}" = "I4I" ]
		then 	
				FLAG_RETRO_SIGN="Y" 
				GAAP_PRD_RULE="N"
		else 
				FLAG_RETRO_SIGN="N" 
				GAAP_PRD_RULE="Y"				
		fi		
				
		NJOB="ESFD3964_${NORME_CF}"
		${DCMD}/ESFD3964.cmd  "$FLAG_RETRO_SIGN" "$FLAG_ERR_WARN" "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF" "$GAAP_PRD_RULE" 2>&1 | ${TEE}
		
		#-----------------------------------------------------------------
		LIBEL="checks finished RC=$?, rename the copy ESF_FTECLEDA_MVT_TMP=${ESF_FTECLEDA_MVT_TMP} into DFILT "
		EXECKSH_MODE=P
		EXECKSH "mv ${ESF_FTECLEDA_MVT_TMP} $DFILT/${ENV_PREFIX}_ESFD3560_${IDF_CT}_${IB}_FTECLEDA_MVT_TMP.dat "		
			
	else
		echo  -e "\nfile ESF_FTECLEDA_MVT_TMP is empty, checks are NOT done !! \n" >> $FLOG 
		echo  -e "\nfile ESF_FTECLEDA_MVT_TMP is empty, checks are NOT done !! \n" 	
	fi

	#================ clean file on OneGl FTP server
	NJOB="ESFD3967_${NORME_CF}"
	${DCMD}/ESFD3967.cmd  2>&1 | ${TEE}

else
    echo  -e "\nMODE=${MODE} ENV_SAP=${ENV_SAP}, checks are NOT done !! \n" >> $FLOG 
    echo  -e "\nMODE=${MODE} ENV_SAP=${ENV_SAP}, checks are NOT done !! \n" 
fi



CHAINEND

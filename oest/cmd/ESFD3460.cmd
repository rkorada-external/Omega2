#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD3460.cmd
# date de creation              : 18/04/2023
# auteur                        : JYP/TD
#-----------------------------------------------------------------------------
# description:  :spira 109440 : check SAP return files and recover
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001]  20/04/2023 JYP/TD :spira:109440 : check SAP return files and recover
#[002]  23/05/2023 JYP/TD :spira:109816: add parameters ${BALSHTYEA_NF}  ${BALSHTMTH_NF} for ESFD3964 
#[003]	18/04/2024 JYP    :spira:111359: manage MDEL file in a specific job
#[004]  24/04/2024 JYP    :spira 111359: manage SIMU IFRS4 and EBS, do not block the closing
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#========= Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


#========  Chain global parameters 

set `GETPRM ${DPRM}/SAP_ENV.prm`
if [[ "${SRV}" = "PRD_TPO2" ]]
then
	export ENV_SAP=${1}
else
	export ENV_SAP=${2}
fi



if [ "${PARAM_IS_SAP_POSTING}" = "Y" -a "${ENV_SAP}" = "1" ] 
then
    export MODE="1" # COMPTABILISATION
else
    echo  -e "\n/!\ PARAM_IS_SAP_POSTING=$PARAM_IS_SAP_POSTING ENV_SAP=$ENV_SAP , no need checks or recover  ... " >> $FLOG 
    echo  -e "\n/!\ PARAM_IS_SAP_POSTING=$PARAM_IS_SAP_POSTING ENV_SAP=$ENV_SAP , no need checks or recover  ... " 
	CHAINEND
fi

set `GETPRM ${DPRM}/ESFD3460_RECOVERY_${NORME_CF}.prm`
export RECOVERY_MODE=${1}



#================ get input file, return file from SAP
if [ ! -s ${ESF_FTECLEDA_MVT_TMP} ]
then
    RESTART="N"
	FLAG_ERR_WARN="E" 
	FLAG_FTPMGET="Y"
	FLAG_RECOVER="Y"
	NJOB="ESFD3962_${NORME_CF}"
	${DCMD}/ESFD3962.cmd "$FLAG_ERR_WARN" "$FLAG_FTPMGET" "$FLAG_RECOVER"  2>&1  | ${TEE}
	
	if [ -f ${DABORT}/${FRSTN} ]
	then 
		RCODE=`tail -1 ${DABORT}/${FRSTN}  | cut -d";" -f4`
		if [ ! "$RCODE" -eq 0  ]
		then	 
			CHAINEND
		fi
    fi 
	
	
else
    RESTART="Y"
    echo  -e "\n/!\ RESTART mode , continue with previous input file $ESF_FTECLEDA_MVT_TMP ... " >> $FLOG 
    echo  -e "\n/!\ RESTART mode , continue with previous input file $ESF_FTECLEDA_MVT_TMP ... " 
fi


#============  the flag RECOVERY_MODE = Y when FTPGET failed on previous run

set `GETPRM ${DPRM}/ESFD3460_RECOVERY_${NORME_CF}.prm`
export RECOVERY_MODE=${1}
echo -e "\nRECOVERY_MODE=$RECOVERY_MODE ... \n " 
echo -e "\nRECOVERY_MODE=$RECOVERY_MODE ... \n " >> $FLOG 


if [ "$RECOVERY_MODE" = "Y" ]
then
	echo  -e "\nMODE=${MODE} , SAP_FTP_file is processed by ESFD3460 ... \n" >> $FLOG 
	echo  -e "\nMODE=${MODE} , SAP_FTP_file is processed by ESFD3460 ... \n" 
		
	#================ checks amounts, SAP IDs
	if [ "$RESTART" = "N" ] 
	then
		FLAG_RETRO_SIGN="N"
		GAAP_PRD_RULE="Y"
		FLAG_ERR_WARN="E"  # need failure if checks are KO
	
		NJOB="ESFD3964_${NORME_CF}"
		${DCMD}/ESFD3964.cmd  "$FLAG_RETRO_SIGN" "$FLAG_ERR_WARN" "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF" "$GAAP_PRD_RULE"  2>&1 | ${TEE}
	
	else
		echo  -e "\nRESTART=$RESTART MODE=${MODE} , checks are NOT done !! \n" >> $FLOG 
		echo  -e "\nRESTART=$RESTART MODE=${MODE} , checks are NOT done !! \n" 
	fi 



	#================ update perm/archive/POSTING 
	POSTING_UPDATE_CANCELED="N"
	NJOB="ESFD3965_${NORME_CF}"
	${DCMD}/ESFD3965.cmd "$POSTING_UPDATE_CANCELED"  2>&1 | ${TEE}

	#================ close recover mode		
	NJOB="ESFD3966_${NORME_CF}"
	${DCMD}/ESFD3966.cmd   2>&1 | ${TEE}

	#================ close request
	if [ "$NORME_CF" = "EBS" ]
	then 
	    NJOB="ESPJ8991"
		${DCMD}/ESPJ8991.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PARM_DBCLO_D} ${PARM_INVCONSO_D} 2>&1 | ${TEE}
	else 
		NJOB="ESFJ8991"
		${DCMD}/ESFJ8991.cmd 2>&1 | ${TEE}
	fi

	#================ clean file on OneGl FTP server
	NJOB="ESFD3967_${NORME_CF}"
	${DCMD}/ESFD3967.cmd  2>&1 | ${TEE}
	
	
else 
    echo  -e "\nRECOVER_MODE=$RECOVER_MODE, all is OK, FTP file should be processed by ESFD3960 \n" >> $FLOG 
    echo  -e "\nRECOVER_MODE=$RECOVER_MODE, all is OK, FTP file should be processed by ESFD3960 \n" 
fi 


CHAINEND

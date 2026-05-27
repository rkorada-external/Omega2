#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESF3960.cmd
# date de creation              : 22/09/2020
# auteur                        : Linh DOAN
#-----------------------------------------------------------------------------
# description:  :spira 88638 - Extract Ftecleda file from OneGl
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001]  22/09/2020  Linh DOAN  : spira 88638 extract from OneGL
#[002]  26/07/2021  Linh DOAN  : spira 96041 IFRS17 Delta Posting (ESFD3960 for IFRS17 logic)
#[003]  19/08/2021  Linh DOAN  : spira 98185 IFRS17 Delta Posting (ESFD3960 for EBS logic)
#[004]  03/02/2022  T. DEUTSCH :spira:100097 Add prm option to take SAP file
#[005]  14/04/2023  JYP/TD     :spira:109178: split into 3 jobs for SIMU cases
#[006]  17/04/2023  JYP/TD     :spira:109178: add case EBS SIMU mode
#[007]  21/04/2023  JYP/TD     :spira:109440 : when SAP POSTING , check flag from ESFD3460-recover
#[008]  23/05/2023  JYP/TD     :spira:109816: add parameters ${BALSHTYEA_NF}  ${BALSHTMTH_NF} for ESFD3964 
#[009]  30/05/2023  JYP/TD     :spira:109816: nothing to check when SAP is not activated 
#[010]  08/11/2023  JYP/TD     :spira:109414: bugfix , when POC no SAP interface 
#[011]  20/11/2023  JYP/TD     :spira:110891: update mail SAP warnings
#[012]	18/04/2024  JYP        :spira:111359: manage MDEL file in a specific job
#[014]  25/04/2024  JYP        :spira 111359: manage SIMU IFRS4 and EBS, do not block the closing
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#=========
#========= Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

#============
#============  Chain global parameters 
set `GETPRM ${DPRM}/SAP_ENV.prm`
if [[ "${SRV}" = "PRD_TPO2" ]]
then
	export ENV_SAP=${1}
else
	export ENV_SAP=${2}
fi


if [ "${PARAM_IS_SAP_POSTING}" = "Y" -o "${PARM_IS_COMPTA}" = "Y" ] && [ "${TYPEINV}" != "POC" ]
then
    export MODE="1" # COMPTABILISATION
else
    export MODE="4" # SIMULATION
fi


#============
#============ when SAP_POSTING YES, FTP_file can be managed by ESFD3460-recover, so need to check the flag from ESFD3960_PRM
export ESFD3960_PRM=${DPRM}/ESFD3960_SAPPOSTING_${NORME_CF}.prm 
set `GETPRM ${ESFD3960_PRM}`
export POSTING_UPDATE_CANCELED=${1}
echo -e "\n -> flag POSTING_UPDATE_CANCELED = $POSTING_UPDATE_CANCELED : from file = ${ESFD3960_PRM}" >> $FLOG 
echo -e "\n -> flag POSTING_UPDATE_CANCELED = $POSTING_UPDATE_CANCELED : from file = ${ESFD3960_PRM}" 


#============
#============ get input file, return file from SAP or just copy of current MVT file
if [ ! -s ${ESF_FTECLEDA_MVT_TMP} ]
then
    RESTART="N"
	FLAG_ERR_WARN="E" 
	FLAG_RECOVER="N" # Y from recover chain ESFD3460
		
	#===== SIMU file is managed in ESFD3560, when SAP_Posting FTP_file can be managed by ESFD3460_recover
	norme13=`echo "$NORME_CF" | cut -c1-3  `
	if [ "${MODE}" = "4" ]  || [ "$POSTING_UPDATE_CANCELED" = "Y" ] || [ "${TYPEINV}" = "POC" ]
	then
		FLAG_FTPMGET="N"   
	else 
		FLAG_FTPMGET="Y"
	fi 	
		
	NJOB="ESFD3962_${NORME_CF}"
	${DCMD}/ESFD3962.cmd "$FLAG_ERR_WARN" "$FLAG_FTPMGET" "$FLAG_RECOVER"  2>&1 | ${TEE}
else
    RESTART="Y"
    echo  -e "\n/!\ RESTART mode , continue with previous input file $ESF_FTECLEDA_MVT_TMP ... " >> $FLOG 
    echo  -e "\n/!\ RESTART mode , continue with previous input file $ESF_FTECLEDA_MVT_TMP ... " 
fi


#============
#============ checks amounts, SAP IDs
if [ "${ENV_SAP}" = "0" ] || [ "${TYPEINV}" = "POC" ]
then
    echo  -e "\nENV_SAP=${ENV_SAP} TYPEINV=$TYPEINV , checks are NOT done ! \n" >> $FLOG 
    echo  -e "\nENV_SAP=${ENV_SAP} TYPEINV=$TYPEINV , checks are NOT done ! \n" 
else

    if [ "${MODE}" = "1" -a "$RESTART" = "N" ] 
    then
    	FLAG_RETRO_SIGN="N"
 		GAAP_PRD_RULE="Y"
				
    	if [ "${PARM_IS_SAP_POSTING}" = "Y" ]
    	then
    	  FLAG_ERR_WARN="E"  # need failure if checks are KO
    	else 
    	  FLAG_ERR_WARN="W"  # do not fail 
    	fi

        if  [ "$POSTING_UPDATE_CANCELED" = "Y" ] 
    	then 
    	    #=== spira 109440 : SAP POSTING file managed by ESFD3460 when this flag = Y
    		echo  -e "\nPOSTING_UPDATE_CANCELED=$POSTING_UPDATE_CANCELED MODE=${MODE} , checks are NOT done here , FTP_file managed by ESFD3460 !! \n" >> $FLOG 
    		echo  -e "\nPOSTING_UPDATE_CANCELED=$POSTING_UPDATE_CANCELED MODE=${MODE} , checks are NOT done here , FTP_file managed by ESFD3460 !! \n" 	
        else 
    		NJOB="ESFD3964_${NORME_CF}"
    		${DCMD}/ESFD3964.cmd  "$FLAG_RETRO_SIGN" "$FLAG_ERR_WARN" "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF" "$GAAP_PRD_RULE"  2>&1 | ${TEE}
        fi 
    else
        echo  -e "\nRESTART=$RESTART MODE=${MODE} , checks are NOT done !! \n" >> $FLOG 
        echo  -e "\nRESTART=$RESTART MODE=${MODE} , checks are NOT done !! \n" 
    fi 

fi # SAP activated or not

#============
#============ update perm/archive/POSTING  

NJOB="ESFD3965_${NORME_CF}"
${DCMD}/ESFD3965.cmd "$POSTING_UPDATE_CANCELED"  2>&1 | ${TEE}


#============
#============ call FTP_MDEL to clean SAP server

if [ "${MODE}" = "1" ] && [ "$POSTING_UPDATE_CANCELED" != "Y" ]
then
	NJOB="ESFD3967_${NORME_CF}"
	${DCMD}/ESFD3967.cmd  2>&1 | ${TEE}
fi 



CHAINEND

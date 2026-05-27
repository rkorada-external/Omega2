#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 update product code and gaap_code for historical data
# Date de creation              : 04/03/2022
# Auteur                        : JYP
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#
#  - update product code and gaap_code for historical data 
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#[001] 04/03/2022 JYP : Spira 102394 : update product code and gaap_code for historical data 
#[002] 30/03/2022 JYP : Spira 102394 : complete IFRS4 case and bugfix
#[003] 04/04/2022 JYP : Spira 102394 : update gaap_product codes , add log option
#[004] 06/04/2022 JYP : Spira 102394 : check flag transition activated
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
GAAP_PRD_OPT=$3  # GAAP_ONLY / PRD_ONLY / empty=ALL
STAT_OPT=$4      # Y = produce more logs 
DBATOOL_GO=$5    # Y = force execution by DBATOOLS

NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


#check if TRANSITION is activated 
set `GETPRM ${DPRM}/ESFJ0000.prm`
export PARM_IS_TRN=$1

if [ "$PARM_IS_TRN" != "TI17TRAPERMFIL" ] && [ "$DBATOOL_GO" != "Y" ]
then
  echo "TRANSITION is NOT activated , nothing to update "   2>&1 | ${TEE}
  CHAINEND
fi 



NORME_CF13=`echo "$NORME_CF" | cut -c1-3 `

if [ "$NORME_CF" = "EBS" ] || [ "$NORME_CF13" = "I17" ] 
then
	
	if [ -s "$ESF_FTECLEDA_REJ" ] && [ -s "$ESF_FTECLEDR_REJ" ]
	then

		#================== clean gaap and product fields
		NJOB="ESFD1041_13"
		${DCMD}/ESFD1041.cmd $ESF_FTECLEDA_REJ   "118" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
	
		NJOB="ESFD1041_14"
		${DCMD}/ESFD1041.cmd $ESF_FTECLEDR_REJ   "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
	
		#================== apply gaap codes 
		NJOB="ESFD3811_FTECLEDA23"
		${DCMD}/ESFD3811.cmd  ${ESF_FTECLEDA_REJ} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}
		
		NJOB="ESFD3813_FTECLEDR24"
		${DCMD}/ESFD3813.cmd ${ESF_FTECLEDR_REJ} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}
	
		#================== apply product codes
		NJOB="ESFD3819_33"
		${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA_REJ} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
		NJOB="ESFD3818_34"
		${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR_REJ} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
		#================== Logs option
		if [ "$STAT_OPT" = "Y" ]
		then
		    echo "======  GAAP_PROD CODES AFTER : $ESF_FTECLEDA_REJ ===== " 2>&1 | ${TEE}
			cut -d~ -f111 ${ESF_FTECLEDA_REJ} | sort | uniq -c              2>&1 | ${TEE} 
			cut -d~ -f112 ${ESF_FTECLEDA_REJ} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 

		    echo "======  GAAP_PROD CODES AFTER : $ESF_FTECLEDR_REJ ===== " 2>&1 | ${TEE}
			cut -d~ -f64 ${ESF_FTECLEDR_REJ} | sort | uniq -c               2>&1 | ${TEE} 
			cut -d~ -f65 ${ESF_FTECLEDR_REJ} | cut -c1-2 | sort | uniq -c   2>&1 | ${TEE} 
		fi 			
		
	fi

	if [ -s "$ESF_FTECLEDA_OPNG" ] && [ -s "$ESF_FTECLEDR_OPNG" ] 
	then
	
		#================== clean gaap and product fields 
		NJOB="ESFD1041_11"
		${DCMD}/ESFD1041.cmd $ESF_FTECLEDA_OPNG  "118" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
	
		NJOB="ESFD1041_12"
		${DCMD}/ESFD1041.cmd $ESF_FTECLEDR_OPNG  "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
	
		#================== apply gaap codes 	
		NJOB="ESFD3811_FTECLEDA21"
		${DCMD}/ESFD3811.cmd  ${ESF_FTECLEDA_OPNG} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}
		
		NJOB="ESFD3813_FTECLEDR22"
		${DCMD}/ESFD3813.cmd ${ESF_FTECLEDR_OPNG} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}

		#================== apply product codes	
		NJOB="ESFD3819_31"
		${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA_OPNG} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
		NJOB="ESFD3818_32"
		${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR_OPNG} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
		#================== Logs option		
		if [ "$STAT_OPT" = "Y" ]
		then
		    echo "======  GAAP_PROD CODES AFTER : $ESF_FTECLEDA_OPNG ===== " 2>&1 | ${TEE}
			cut -d~ -f111 ${ESF_FTECLEDA_OPNG} | sort | uniq -c              2>&1 | ${TEE} 
			cut -d~ -f112 ${ESF_FTECLEDA_OPNG} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 

		    echo "======  GAAP_PROD CODES AFTER : $ESF_FTECLEDR_OPNG ===== " 2>&1 | ${TEE}
			cut -d~ -f64 ${ESF_FTECLEDR_OPNG} | sort | uniq -c               2>&1 | ${TEE} 
			cut -d~ -f65 ${ESF_FTECLEDR_OPNG} | cut -c1-2 | sort | uniq -c   2>&1 | ${TEE} 
		fi 
	
	fi		

fi


if [ "$NORME_CF" = "I4I" ] 
then

	#================== clean gaap and product fields 
	 
	NJOB="ESFD1041_45"
	${DCMD}/ESFD1041.cmd $EST_CURGTR         "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}

	NJOB="ESFD1041_46"
	${DCMD}/ESFD1041.cmd $EST_CURGTA         "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}

	if [ "$TYPEINV" = "POS" ] || [ "$TYPEINV" = "POC" ] 
	then
	
		if [ -s "$EPO_DLREJGTAASIISO" ] && [ -s "$EPO_DLREJGTARSIISO" ] && [ -s "$EPO_DLREJGTRSIISO" ]
		then
			NJOB="ESFD1041_47"
			${DCMD}/ESFD1041.cmd $EPO_DLREJGTAASIISO "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
		
			NJOB="ESFD1041_48"
			${DCMD}/ESFD1041.cmd $EPO_DLREJGTARSIISO "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
		
			NJOB="ESFD1041_49"
			${DCMD}/ESFD1041.cmd $EPO_DLREJGTRSIISO  "71" "$GAAP_PRD_OPT" "$STAT_OPT" 2>&1 | ${TEE}
		fi
	fi

	#================== apply gaap codes 

	NJOB="ESFD3813_FTECLEDR_55"
	${DCMD}/ESFD3813.cmd $EST_CURGTR ${EST_GAAPCOD_MAPPING}
	
	NJOB="ESFD3813_FTECLEDA_56"
	${DCMD}/ESFD3813.cmd $EST_CURGTA ${EST_GAAPCOD_MAPPING}


	if [ "$TYPEINV" = "POS" ] || [ "$TYPEINV" = "POC" ] 
	then
		if [ -s "$EPO_DLREJGTAASIISO" ] && [ -s "$EPO_DLREJGTARSIISO" ] && [ -s "$EPO_DLREJGTRSIISO" ]
		then
			NJOB="ESFD3818_57"
			${DCMD}/ESFD3813.cmd ${EPO_DLREJGTAASIISO} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}
		
			NJOB="ESFD3818_58"
			${DCMD}/ESFD3813.cmd ${EPO_DLREJGTARSIISO} ${EST_GAAPCOD_MAPPING} 2>&1 | ${TEE}
		
			NJOB="ESFD3817_59"
			${DCMD}/ESFD3813.cmd ${EPO_DLREJGTRSIISO} ${EST_GAAPCOD_MAPPING}  2>&1 | ${TEE}
						
		fi
	fi

	#================== apply product codes 
	
	NJOB="ESFD3818_65"
	${DCMD}/ESFD3818.cmd ${EST_CURGTR} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}

	NJOB="ESFD3817_66"
	${DCMD}/ESFD3817.cmd ${EST_CURGTA} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
	

	#================== Logs option		
	if [ "$STAT_OPT" = "Y" ]
	then
	    echo "======  GAAP_PROD CODES AFTER : $EST_CURGTR ===== " 2>&1 | ${TEE}
		cut -d~ -f64 ${EST_CURGTR} | sort | uniq -c              2>&1 | ${TEE} 
		cut -d~ -f65 ${EST_CURGTR} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 
	    echo "======  GAAP_PROD CODES AFTER : $EST_CURGTA ===== " 2>&1 | ${TEE}
		cut -d~ -f64 ${EST_CURGTA} | sort | uniq -c              2>&1 | ${TEE} 
		cut -d~ -f65 ${EST_CURGTA} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 
	fi
	
	

	if [ "$TYPEINV" = "POS" ] || [ "$TYPEINV" = "POC" ] 
	then
		if [ -s "$EPO_DLREJGTAASIISO" ] && [ -s "$EPO_DLREJGTARSIISO" ] && [ -s "$EPO_DLREJGTRSIISO" ]
		then
			NJOB="ESFD3818_67"
			${DCMD}/ESFD3818.cmd ${EPO_DLREJGTAASIISO} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
			NJOB="ESFD3818_68"
			${DCMD}/ESFD3818.cmd ${EPO_DLREJGTARSIISO} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
		
			NJOB="ESFD3817_69"
			${DCMD}/ESFD3817.cmd ${EPO_DLREJGTRSIISO} ${ESF_FCTRI17PRD} 2>&1 | ${TEE}
			
		#================== Logs option		
		if [ "$STAT_OPT" = "Y" ]
		then
		    echo "======  GAAP_PROD CODES AFTER : $EPO_DLREJGTAASIISO ===== " 2>&1 | ${TEE}
			cut -d~ -f64 ${EPO_DLREJGTAASIISO} | sort | uniq -c              2>&1 | ${TEE} 
			cut -d~ -f65 ${EPO_DLREJGTAASIISO} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 

		    echo "======  GAAP_PROD CODES AFTER : $EPO_DLREJGTARSIISO ===== " 2>&1 | ${TEE}
			cut -d~ -f64 ${EPO_DLREJGTARSIISO} | sort | uniq -c              2>&1 | ${TEE} 
			cut -d~ -f65 ${EPO_DLREJGTARSIISO} | cut -c1-2 | sort | uniq -c  2>&1 | ${TEE} 

		    echo "======  GAAP_PROD CODES AFTER : $EPO_DLREJGTRSIISO ===== " 2>&1 | ${TEE}
			cut -d~ -f64 ${EPO_DLREJGTRSIISO} | sort | uniq -c               2>&1 | ${TEE} 
			cut -d~ -f65 ${EPO_DLREJGTRSIISO} | cut -c1-2 | sort | uniq -c   2>&1 | ${TEE} 
		fi 
		
			
		fi
	fi

fi




CHAINEND

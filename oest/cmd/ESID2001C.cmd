#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
#								 ENrichissement de du fichier EST_DTSTATGTAA avec les taux CUR et  EGPCUR , et FTRSLNK, FTDETTRS	
# nom du script SHELL          : ESID2001C.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 24/12/2019 
# auteur                       : M.NAJI 
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===========================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
SEGTYP_CT=$4
ICLODAT_D=$5
SSDs=$6
SSDVRS_LL=$7
LSTCLODAT_LL=$8
SSDDEL_LL=$9

# enrichissement de EST_FDETTRS avec EST_FTRSLNK.ACMTRS_NT
NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="enrichissement de EST_FDETTRS avec EST_FTRSLNK.ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDETTRS_TXT}"
SORT_O="${DFILT}/${NSTEP}_${IB}_FDETTRS_FTRSLNK.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DETTRS_DETTRS_CF  1:1 -  1:,
		DETTRS_TRSTYP_CT  3:1 - 3:,
		TRSLNK_PRS_CF	  1:1 - 1:,
        TRSLNK_ACMTRS_NT  2:1 -  2:,
        TRSLNK_DETTRS_CF  3:1 -  3:
/DERIVEDFIELD   DETTRS_PRS_CF   "710"
/joinkeys 
       DETTRS_DETTRS_CF ,
	   DETTRS_PRS_CF
/INFILE ${EST_FTRSLNK_TXT}  1000 1 "~"
/joinkeys 
       TRSLNK_DETTRS_CF,
	   TRSLNK_PRS_CF
/JOIN UNPAIRED LEFTSIDE	   
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:DETTRS_DETTRS_CF
	,leftside:DETTRS_TRSTYP_CT
	,rightside:TRSLNK_ACMTRS_NT  
exit	
EOF
SORT


# enrichissement EST_DTSTATGTAAF avec 	PER_NAT_CF, PER_CTRNAT_CT, PER_UWORG_CF, PER_PCPCUR_CF, PER_EGPCUR_CF, CURQUOT_RATE ,PERPRMD_PRMDUECUR_CF
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="enrichissement EST_DTSTATGTAAF avec 	PER_NAT_CF, PER_CTRNAT_CT, PER_UWORG_CF, PER_PCPCUR_CF, PER_EGPCUR_CF, CURQUOT_RATE ,PERPRMD_PRMDUECUR_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_EXTEND} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DTSTATGTAAF_EXTEND1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DETTRS_DETTRS_CF  1:1 -  1:,
	PER_CTR_NF 				1:1 - 1:,
	PER_END_NT				2:1 - 2:, 
	PER_SEC_NF				3:1 - 3:,
	PER_UWY_NF				4:1 - 4:,
	PER_UW_NT 				5:1 - 5:,
	PER_CTRRET_B			6:1 - 6: ,  
	PER_NAT_CF 				7:1 - 7:  ,
	PER_CTRNAT_CT   		8:1 - 8:,
	PER_UWORG_CF			9:1 - 9: ,
	PER_EGPCUR_CF   		10:1 -10:,
	PER_SECACCSTS_CT   		11:1 - 11:, 
	PER_PCPRSKTRY_CF   		12:1 - 12:,
	PER_EGPCUR_RATE    		13:1 - 13 :, 
	PER_LOB_CF     			14:1 - 14 :, 
	PER_RECBRK_B			15:1 - 15 :, 
	CMP_ACY_NF 				16:1 - 16:,
	CMP_SCOENDMTH_NF 		17:1 - 17:,
	ALL_COLS_PER			1:1 - 16:,
	GT_CTR_NF 				 8:1 - 8:,
	GT_END_NT 				 9:1 - 9:,
	GT_SEC_NF 				10:1 - 10:,
	GT_UWY_NF 				11:1 - 11:,
	GT_UW_NT  				12:1 - 12:,
	SCOSTRMTH_NF    		15:1 - 15:EN,
	SCOENDMTH_NF    		16:1 - 16:EN,
	CLM_NF          		17:1 - 17:,
	BEFORE_SCOSTRMTH_NF 	1:1 - 14: ,
	AFTER_SCOENDMTH_NF		17:1 - 71:
/DERIVEDFIELD   GT_CTRRET_B   "0"
/DERIVEDFIELD SCOENDMTH_NF_FORMATE   SCOENDMTH_NF (99)
/DERIVEDFIELD SCOSTRMTH_NF_FORMATE   SCOSTRMTH_NF (99)
/DERIVEDFIELD sep "~"
/INFILE ${DFILT}/${NCHAIN}_ESID2001B_45_${IB}_IADPERICASE_TERM_EXTEND.dat  1000 1 "~" 
/joinkeys 
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,  
	PER_UW_NT ,
	PER_CTRRET_B
/INFILE ${EST_DTSTATGTAA}  1000 1 "~"
/INFILE ${EST_MVTPNAC}  1000 1 "~"
/joinkeys 
	GT_CTR_NF,
	GT_END_NT,
	GT_SEC_NF,
	GT_UWY_NF,
	GT_UW_NT ,
	GT_CTRRET_B	 
/OUTFILE ${SORT_O}
/REFORMAT 
	 rightside:BEFORE_SCOSTRMTH_NF  
	,rightside:SCOSTRMTH_NF_FORMATE
	,sep
	,rightside:SCOENDMTH_NF_FORMATE
	,sep
	,rightside:AFTER_SCOENDMTH_NF
	,leftside:PER_NAT_CF 		        
	,leftside:PER_CTRNAT_CT             
	,leftside:PER_UWORG_CF	            
	,leftside:PER_EGPCUR_CF             
	,leftside:PER_SECACCSTS_CT          
	,leftside:PER_PCPRSKTRY_CF			
	,leftside:PER_EGPCUR_RATE           
	,leftside:PER_LOB_CF     			
	,leftside:PER_RECBRK_B				
	,leftside:CMP_ACY_NF 		        
	,leftside:CMP_SCOENDMTH_NF 	        
exit	
EOF
SORT


# enrichissement enrichissement EST_DTSTATGTAAF avec DETTRS_TRSTYP_CT, TRSLNK_ACMTRS_NT
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="enrichissement EST_DTSTATGTAAF avec DETTRS_TRSTYP_CT, TRSLNK_ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DTSTATGTAAF_EXTEND1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DTSTATGTAAF_EXTEND2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	DETTRS_DETTRS_CF			1:1 - 1: ,
	DETTRS_TRSTYP_CT			2:1 - 2: ,
	TRSLNK_ACMTRS_NT            3:1 - 3:,
	GT_TRNCOD_CF				6:1 - 6: ,	
	GT_ALL_COLS 				1:1 - 82:
/joinkeys 
	GT_TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FDETTRS_FTRSLNK.dat  1000 1 "~"
/joinkeys 
	DETTRS_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE	   
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside: GT_ALL_COLS   
	,rightside:DETTRS_TRSTYP_CT  
	,rightside:TRSLNK_ACMTRS_NT  
exit	
EOF
SORT


# enrichissement enrichissement EST_DTSTATGTAAF avec le taux GT_CUR_CF
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="enrichissement EST_DTSTATGTAAF avec DETTRS_TRSTYP_CT, TRSLNK_ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_DTSTATGTAAF_EXTEND2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DTSTATGTAAF_EXTEND3.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		GT_SSD_CF			1:1	- 1:,	
        GT_BALSHEY_NF		3:1 - 3:,
        GT_CUR_CF    		18:1 - 18:,
		GT_ALL_COLS 		1:1 - 84:,
        CURQUOT_SSD_CF   		1:1 -  1:,
        CURQUOT_CUR_CF   		2:1 -  2:,
        CURQUOT_UWY_NF   		3:1 -  3:,
        CURQUOT_RATE     		4:1 -  4:
/joinkeys 
	   GT_SSD_CF
	  ,GT_CUR_CF
	  ,GT_BALSHEY_NF
/INFILE ${EST_FCURQUOT_TXT}   1000 1 "~"
/joinkeys 
	    CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
	   ,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE	   
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:GT_ALL_COLS        
	,rightside:CURQUOT_RATE  
exit	
EOF
SORT


# enrichissement enrichissement EST_DTSTATGTAAF avec le taux PER_EGPCUR_CF
NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="enrichissement EST_DTSTATGTAAF avec DETTRS_TRSTYP_CT, TRSLNK_ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_DTSTATGTAAF_EXTEND3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DTSTATGTAAF_EXTEND4.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		GT_SSD_CF			1:1	- 1:,	
        GT_BALSHEY_NF		3:1 - 3:,
        PER_EGPCUR_CF    	75:1 - 75:,
		GT_ALL_COLS 		1:1 - 85:,
        CURQUOT_SSD_CF   		1:1 -  1:,
        CURQUOT_CUR_CF   		2:1 -  2:,
        CURQUOT_UWY_NF   		3:1 -  3:,
        CURQUOT_RATE     		4:1 -  4:
/joinkeys 
       GT_SSD_CF
	  ,PER_EGPCUR_CF
	  ,GT_BALSHEY_NF
/INFILE ${EST_FCURQUOT_TXT}   1000 1 "~"
/joinkeys 
	    CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
	   ,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE	   
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:GT_ALL_COLS        
	,rightside:CURQUOT_RATE  
exit	
EOF
SORT

NSTEP=${NJOB}_50
#Introduction transactions, complete accounts, and conversion
#in EGPI currency
#-----------------------------------------------------------------------------
LIBEL="Introduction  transaction, complete accounting and \
conversion in EGPI currency"
PRG=ESTC1005A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_40_${IB}_DTSTATGTAAF_EXTEND4.dat"
export ${PRG}_O1=${EST_DGTAA}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_DSUMGTAASNEM.dat  
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_DSUMGTAAREC.dat
EXECPRG

# Summarize transactions
NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Summarize transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_DSUMGTAAREC.dat"
SORT_O="${EST_DSUMGTAAREC}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF    8:1 - 8:,
        END_NT    9:1 - 9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT   12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF    14:1 - 14:,
        SCOSTRMTH_NF  15:1 - 15:EN,
        SCOENDMTH_NF  16:1 - 16:EN,
        CLM_NF    17:1 - 17:,
		ACMTRS_NT 42:1 - 42:,
        ACMAMT_M  43:1 - 43: EN 15/3,
        ACMCUR_CF 44:1 - 44:,
		PER_SECACCSTS_CT	45:1 	- 	45:,
		BEFORE_AM			1:1		-	42:	
/KEYS
            CTR_NF			,
            END_NT			,
            SEC_NF			,
            UWY_NF			,
            UW_NT			,
            ACY_NF			,
            SCOENDMTH_NF	,
            SCOSTRMTH_NF	,
            OCCYEA_NF		,
            CLM_NF			,
			ACMTRS_NT		
/SUMMARIZE TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT BEFORE_AM, ACMAMT_MC, ACMCUR_CF
exit	
EOF
SORT


# Summarize transactions
NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Summarize transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_DSUMGTAASNEM.dat"
SORT_O="${EST_DSUMGTAASNEM_ESTC1005A}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		ESB_CF    2:1 - 2:,
        BALSHEY_NF  3:1 - 3:,
        BALSHRMTH_NF  4:1 - 4:,
        BALSHRDAY_NF  5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF  7:1 - 7:,
        CTR_NF    8:1 - 8:,
        END_NT    9:1 - 9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT   12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF    14:1 - 14:,
        SCOSTRMTH_NF  15:1 - 15:,
        SCOENDMTH_NF  16:1 - 16:,
        CLM_NF    17:1 - 17:,
        CUR_CF    18:1 - 18:,
        AMT_M   19:1 - 19:,
        CED_NF    20:1 - 20:,
        BRK_NF    21:1 - 21:,
        PAY_NF    22:1 - 22:,
        KEY_NF    23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:,
        RETOCCYEA_NF  29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF    33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M  35:1 - 35:,
        PLC_NT    36:1 - 36:,
        RTO_NF    37:1 - 37:,
        INT_NF    38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        ACMTRS_NT 42:1 - 42:,
        ACMAMT_M  43:1 - 43: EN 15/3,
        ACMCUR_CF 44:1 - 44:,
		PER_SECACCSTS_CT	45:1 	- 	45:,
		BEFORE_AM			1:1		-	42:	
/KEYS
            CTR_NF			,
            END_NT			,
            SEC_NF			,
            UWY_NF			,
            UW_NT			,
			ACMTRS_NT			
/CONDITION COND_SECACCSTS_NOT_9 PER_SECACCSTS_CT != "9"   
/SUMMARIZE TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_SECACCSTS_NOT_9
/REFORMAT BEFORE_AM, ACMAMT_MC, ACMCUR_CF
exit	
EOF
SORT




# Summarize transactions
NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Summarize transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DGTAA}"
SORT_O="${EST_DSUMGTAA}"
SORT_O2="${EST_DSUMGTAA_TERM}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		ESB_CF    2:1 - 2:,
        BALSHEY_NF  3:1 - 3:,
        BALSHRMTH_NF  4:1 - 4:,
        BALSHRDAY_NF  5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF  7:1 - 7:,
        CTR_NF    8:1 - 8:,
        END_NT    9:1 - 9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT   12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF    14:1 - 14:,
        SCOSTRMTH_NF  15:1 - 15:EN,
        SCOENDMTH_NF  16:1 - 16:EN,
        CLM_NF    17:1 - 17:,
        CUR_CF    18:1 - 18:,
        AMT_M   19:1 - 19:,
        CED_NF    20:1 - 20:,
        BRK_NF    21:1 - 21:,
        PAY_NF    22:1 - 22:,
        KEY_NF    23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:,
        RETOCCYEA_NF  29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF    33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M  35:1 - 35:,
        PLC_NT    36:1 - 36:,
        RTO_NF    37:1 - 37:,
        INT_NF    38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        ACMTRS_NT 42:1 - 42:,
        ACMAMT_M  43:1 - 43: EN 15/3,
        ACMCUR_CF 44:1 - 44:,
		PER_SECACCSTS_CT	45:1 	- 	45:,
		BEFORE_AM			1:1		-	42:	
/KEYS
            CTR_NF			,
            END_NT			,
            SEC_NF			,
            UWY_NF			,
            UW_NT			,
            ACY_NF			,
            SCOENDMTH_NF		,
            SCOSTRMTH_NF		,
            OCCYEA_NF		,
            CLM_NF			,
			ACMTRS_NT			,
			PER_SECACCSTS_CT
/CONDITION COND_SECACCSTS_NOT_9 PER_SECACCSTS_CT != "9"   
/CONDITION COND_SECACCSTS_9 PER_SECACCSTS_CT = "9"   
/SUMMARIZE TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_SECACCSTS_NOT_9
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE COND_SECACCSTS_9
/REFORMAT BEFORE_AM, ACMAMT_MC, ACMCUR_CF
exit	
EOF
SORT

JOBEND

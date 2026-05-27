# APPLICATION NAME          		: TRANSITION
# JOB NAME             				: ESFT0004.cmd
# CREATION DATE              		: 15/07/2020
# AUTHOR                        	: L.ELFAHIM
#===================================================================================================================
#-------------------------------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 84240 - TRANSITION MANAGEMENT :
#-------------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#===================================================================================================================
# 	<JJ/MM/AAAA>   	<AUTHOR>   	<SPIRA> 	<DESCRIPTION OF A CHANGE>
#	16/07/2020		LEL			84240		DEVELOPMENT OF INITIAL VERSION	
#	10/06/2021		LEL			96349 		FOR RETRO NP USE LOB STANDARD & DO NOY USE QUARTER	
# 10/01/2022 	  MZM  	SPIRA : 99999  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#===================================================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

ECHO_LOG ""                                                                                  
ECHO_LOG "#==============================================================================================="                                      
ECHO_LOG "#....................... INPUTS ................................................................"
ECHO_LOG "#===> EST_DLCUMGTAAR .....................: ${EST_DLCUMGTAAR}"       
ECHO_LOG "#===> EST_IADPERICASE ....................: ${EST_IADPERICASE}"
ECHO_LOG "#===> ESF_IRDPERICASE_NP .................: ${ESF_IRDPERICASE_NP}"         
ECHO_LOG "#....................... OUTPUT ................................................................" 
ECHO_LOG "#===> EST_DLCUMGTAAR .....................: ${EST_DLCUMGTAAR}"                   
ECHO_LOG "#==============================================================================================="  

NSTEP=${NJOB}_05
LIBEL="ENRICH EST_DLCUMGTAAR : ADD RETCTRCAT_CF TO DISTINGUISH RETRO NP CONTRACTS..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCUMGTAAR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ENRICHED.dat 2000 1"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 		24:1 	- 24:,
	RETEND_NT 		25:1 	- 25:,
	RETSEC_NF   	26:1 	- 26:,
	RTY_NF   		27:1 	- 27:,
	RETUW_NT   		28:1 	- 28:,
	CTR_NF 			3:1 	- 3:,
	END_NT   		4:1 	- 4:,
	SEC_NF 			5:1 	- 5:,          
	UWY_NF     		6:1 	- 6:,         
	UW_NT			7:1 	- 7:,
	RETCTRCAT_CF 	107:1 	- 107:,
	FILLER         	1:1  	- 52:	  								
/JOINKEYS 
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,	
	RTY_NF,
	RETUW_NT	
/INFILE ${ESF_IRDPERICASE_NP} 2000 1 "~"
/JOINKEYS
	CTR_NF, 
	END_NT,   
	SEC_NF, 	        
	UWY_NF,     	        
	UW_NT	
/JOIN UNPAIRED LEFTSIDE               
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:RETCTRCAT_CF
exit
EOF
SORT

NSTEP=${NJOB}_10
LIBEL="FILTER EST_DLCUMGTAAR : EXTRACT RETRO NP ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_DLCUMGTAAR_ENRICHED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ASSUMED.dat 2000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_RETRO_NP.dat 2000 1"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTRCAT_CF 	53:1 	- 53:,
	FILLER         	1:1  	- 52:	  
/CONDITION ASSUMED_RETP RETCTRCAT_CF != '02' 																
/CONDITION RETRO_NP RETCTRCAT_CF = '02' 												
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ASSUMED_RETP
/REFORMAT FILLER
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE RETRO_NP
/REFORMAT FILLER
/COPY      
exit
EOF
SORT

NSTEP=${NJOB}_20
LIBEL="TRANSITION PURPOSE : ADD REFERENCE QUARTER to SEG_NF GT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_ASSUMED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ASSUMED.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          8:1  	-  8:,
	END_NT          9:1  	-  9:,
	SEC_NF          10:1  	-  10:,
	UWY_NF          11:1  	-  11:,
	UW_NT           12:1  	-  12:,
	FILLER        	1:1  	-  52:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	REF_Q			208:1	-  208:
/JOINKEYS
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     
/INFILE ${EST_IADPERICASE} 2000 1 "~"
/JOINKEYS
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT	
/JOIN UNPAIRED LEFTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	LEFTSIDE:FILLER,
	RIGHTSIDE:REF_Q
exit
EOF
SORT

NSTEP=${NJOB}_30
LIBEL="CONCATENATE SEG_NF && UWY + REFERENCE QUARTER "
AWK_I="${DFILT}/${NJOB}_20_${IB}_DLCUMGTAAR_ASSUMED.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ASSUMED.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS ="\~" }
		{ for( i=1;i<=50;i++ ){ printf "%s", \$i "~" };{ print \$46 \$53 \$11 "~" \$52 } }
exit
EOF
AWK

NSTEP=${NJOB}_40
LIBEL="MERGE DLCUMGTAAR files "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_DLCUMGTAAR_ASSUMED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_RETRO_NP.dat 2000 1"
SORT_O="${EST_DLCUMGTAAR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:,
	BALSHRMTH_NF      4:1 -  4:EN,
	BALSHRDAY_NF      5:1 -  5:EN,
	TRNCOD_CF         6:1 -  6:,
	TRNCOD34_CF       6:3 -  6:4,
	DBLTRNCOD_CF      7:1 -  7:,
	CTR_NF            8:1 -  8:,
	END_NT            9:1 -  9:EN,
	SEC_NF           10:1 - 10:EN,
	UWY_NF           11:1 - 11:,
	UW_NT            12:1 - 12:EN,
	OCCYEA_NF        13:1 - 13:,
	ACY_NF           14:1 - 14:,
	SCOSTRMTH_NF     15:1 - 15:EN,
	SCOENDMTH_NF     16:1 - 16:EN,
	CLM_NF           17:1 - 17:,
	CUR_CF           18:1 - 18:,
	AMT_M            19:1 - 19:EN 15/3,
	CED_NF           20:1 - 20:,
	BRK_NF           21:1 - 21:,
	PAY_NF           22:1 - 22:,
	KEY_NF           23:1 - 23:,
	RETCTR_NF        24:1 - 24:,
	RETEND_NT        25:1 - 25:EN,
	RETSEC_NF        26:1 - 26:EN,
	RTY_NF           27:1 - 27:,
	RETUW_NT         28:1 - 28:EN,
	RETOCCYEA_NF     29:1 - 29:,
	RETACY_NF        30:1 - 30:,
	RETSCOSTRMTH_NF  31:1 - 31:EN,
	RETSCOENDMTH_NF  32:1 - 32:EN,
	RCL_NF           33:1 - 33:,
	RETCUR_CF        34:1 - 34:,
	RETAMT_M         35:1 - 35:EN 15/3,
	PLC_NT           36:1 - 36:,
	RTO_NF           37:1 - 37:,
	INT_NF           38:1 - 38:,
	RETPAY_NF        39:1 - 39:,
	RETKEY_CF        40:1 - 40:,
	RETINTAMT_M      41:1 - 41:EN 15/3,
	ACMTRS_NT        42:1 - 42:,
	ACMAMT_M         43:1 - 43:EN 15/3,
	ACMCUR_CF        44:1 - 44:,
	PRS_CF           45:1 - 45:,
	SEG_NF           46:1 - 46:,
	LOB_CF           47:1 - 47:,
	NAT_CF           48:1 - 48:,
	TYP_CT           49:1 - 49:,
	PATTYP_CF        50:1 - 50:,
	SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS 	
	SSD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT,
	RTO_NF,
	ACMCUR_CF,
	ACMTRS_NT,
	TYP_CT,
	ACMTRS3_NT 
/OUTFILE ${SORT_O}
exit
EOF
SORT

JOBEND
# APPLICATION NAME          		: TRANSITION
# JOB NAME             				: ESFT0005.cmd
# REVISION                     		: 1.0 
# CREATION DATE              		: 29/10/2020
# AUTHOR                        	: L.ELFAHIM
#=========================================================================================================
#---------------------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 85404 - TRANSITION MANAGEMENT :
#
#---------------------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#=========================================================================================================
#	29/10/2020		LEL		SPIRA : 85404		DEVELOPMENT OF INITIAL VERSION
#	29/12/2020		LEL		SPIRA : 91111		ADAPT TRANSITION TREATMENT
#=========================================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

ECHO_LOG ""                                                                                  
ECHO_LOG "#==============================================================================================="                                      
ECHO_LOG "#....................... INPUTS ................................................................"
ECHO_LOG "#===> EST_DLCUMGTAAR_ITD.....................: ${EST_DLCUMGTAAR_ITD}"       
ECHO_LOG "#....................... OUTPUT ................................................................"
ECHO_LOG "#===> .................................... NONE ................................................" 
ECHO_LOG "#==============================================================================================="  

#===================================================
#			ITD PREPARATION for TRANSITION
#===================================================
NSTEP=${NJOB}_10
LIBEL="RETRIEVE WP ITD AT TRANSITION"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCUMGTAAR_ITD} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ITD_ASSUMED.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_ITD_RETRO.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CLOSTYP_NF			17:1 - 17:,
	TYP_CT            	49:1 - 49:,
	ACMTRSL3      		52:1 - 52:, 	
	FILLER      		1:1  - 77:    
/CONDITION ASSUMED	TYP_CT = 'A' AND ACMTRSL3 = "1010" AND CLOSTYP_NF = "I" 
/CONDITION RETRO	TYP_CT = 'R' AND ACMTRSL3 = "1010" AND CLOSTYP_NF = "I" 																					
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ASSUMED
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE RETRO
/COPY 
exit
EOF
SORT

#---------------------------------------
# Files preparation for TRANSITION mode
#---------------------------------------
PARALLEL_INIT 3
NSTEP=${NJOB}_20
LIBEL="SORT WP ITD TRANSITION ASSUMED..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_ITD_ASSUMED.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ASSUMED_ITD_TRANSITION.dat"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF         	8:1  - 8:,
	END_NT        	9:1  - 9:EN,
	SEC_NF      	10:1 - 10:EN,
	UWY_NF       	11:1 - 11:,
	UW_NT        	12:1 - 12:EN,
	FILLER         	1:1  - 77:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER
exit
EOF
PARALLEL SORT

NSTEP=${NJOB}_30
LIBEL="SORT WP ITD TRANSITION RETRO NP..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_ITD_RETRO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETNP_ITD_TRANSITION.dat"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 			24:1 - 24:,
	RETEND_NT 			25:1 - 25:EN,
	RETSEC_NF 			26:1 - 26:EN,
	RTY_NF 				27:1 - 27:,
	RETUW_NT 			28:1 - 28:EN,
	PLC_NT				36:1 - 36:EN,
	NAT_CF				48:1 - 48:,
	FILLER         		1:1  - 77:
/KEYS   
	RETCTR_NF, 	
	RETEND_NT, 	
	RETSEC_NF, 	
	RTY_NF, 		
	RETUW_NT, 		
	PLC_NT
/CONDITION RETNP_ITD_TRN NAT_CF = "30" OR NAT_CF = "31" OR NAT_CF = "32" OR NAT_CF = "40" OR NAT_CF = "41" 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETNP_ITD_TRN
/REFORMAT FILLER	
exit
EOF
PARALLEL SORT

NSTEP=${NJOB}_40
LIBEL="SORT WP ITD TRANSITION RETRO P..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_ITD_RETRO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETP_ITD_TRANSITION.dat"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF           	8:1  - 8:,
	END_NT           	9:1  - 9:EN,
	SEC_NF           	10:1 - 10:EN,
	UWY_NF           	11:1 - 11:,
	UW_NT            	12:1 - 12:EN,
	RETCTR_NF 			24:1 - 24:,
	RETEND_NT 			25:1 - 25:EN,
	RETSEC_NF 			26:1 - 26:EN,
	RTY_NF 				27:1 - 27:,
	RETUW_NT 			28:1 - 28:EN,
	PLC_NT				36:1 - 36:EN,
	NAT_CF				48:1 - 48:,		
	FILLER         		1:1  - 77:
/KEYS
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
	PLC_NT
/CONDITION RETP_ITD_TRN NAT_CF = "10" OR NAT_CF = "11" OR NAT_CF = "12" OR NAT_CF = "20" OR
						NAT_CF = "21" OR NAT_CF = "22" OR NAT_CF = "23"
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETP_ITD_TRN
/REFORMAT FILLER
exit
EOF
PARALLEL SORT
PARALLEL_END

JOBEND
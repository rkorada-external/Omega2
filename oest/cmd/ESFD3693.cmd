#!/bin/ksh
#================================================================================================
# APPLICATION NAME          		: IFRS17 REVENUE&CSM CALCULATION
# CHAIN                 			: ESFD3693.cmd
# REVISION                     		: V1.0 
# CREATION DATE              		: 22/12/2020
# AUTHOR                        	: L.ELFAHIM
#================================================================================================
#------------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 91111 - REQ 11.06 - IFRS17 REVENUE&CSM CALCULATION :
# CSF FILES PREPARATION
#------------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#=================================================================================================================================
# 	<JJ/MM/AAAA>   	<AUTHOR>   	<SPIRA> 	<DESCRIPTION OF A CHANGE>
#	22/12/2020		LEL			91111		DEVELOPMENT OF INITIAL VERSION
#=================================================================================================================================
#set -x

# CALL GENERIC FUNCTIONS
. ${DUTI}/fctgen.cmd
#================================================================================================

# Job Initialisation
JOBINIT

ECHO_LOG ""                                                                                  
ECHO_LOG "#=================================================================================="                           
ECHO_LOG "#===> NORME..................................: ${NORME}" 
ECHO_LOG "#===> TYPEINV................................: ${TYPEINV}"                                
ECHO_LOG "#===> TYPEINV0...............................: ${TYPEINV0}"                                         
ECHO_LOG "#===> NORME_CF...............................: ${NORME_CF}"                                                       
ECHO_LOG "#===> PARM_ICLODAT_D.........................: $PARM_ICLODAT_D"
ECHO_LOG "#===> PARM_PREV_ICLODAT_D....................: $PARM_PREV_ICLODAT_D"
ECHO_LOG "#....................... INPUT ..........................................." 
ECHO_LOG "#===> ESF_GTSII_CASHFLOW_INI.................: ${ESF_GTSII_CASHFLOW_INI}"
ECHO_LOG "#===> EPO_GTSII_GLOBAL_CASHFLOW..............: ${EPO_GTSII_GLOBAL_CASHFLOW}"                
ECHO_LOG "#===> EPO_GTSII_GLOBAL_CASHFLOW_PREV.........: ${EPO_GTSII_GLOBAL_CASHFLOW_PREV}"                                                    
ECHO_LOG "#....................... OUTPUT ..........................................."
ECHO_LOG "#===> NONE...................................: ${NONE}"               
ECHO_LOG "#=================================================================================="  

if [  ! -f "${EPO_GTSII_GLOBAL_CASHFLOW_PREV}"  ]
then
	ECHO_LOG "EPO_GTSII_GLOBAL_CASHFLOW_PREV=${EPO_GTSII_GLOBAL_CASHFLOW_PREV} does not exist, create an empty file"  
	EXECKSH "touch ${EPO_GTSII_GLOBAL_CASHFLOW_PREV}"	
fi

#===============================================================
# 		PREPARATION DES FICHIERS CASHFLOW Q, Q-1 et INI
#===============================================================
NSTEP=${NJOB}_10
LIBEL="RETRIEVE FUTURE PREMIUM AND FUTURE RETRO PREMIUM CURRENT PERIOD : CSF~PRACC and CSF~PRRET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_GTSII_GLOBAL_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CASHFLOW_ASSUMED_Q.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_CASHFLOW_RETRO_Q.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	GROUPING    	45:1 	- 45:,
	PATCAT_CT		52:1 	- 52:,
	PATTYP_CT		53:1 	- 53:,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/CONDITION ASSUMED( PATCAT_CT CT "CSF" AND GROUPING = "751" AND PATTYP_CT = "PRACC" AND ( ACMTRS3 = "1051" OR ACMTRS3 = "2051" OR ACMTRS3 = "1010" OR ACMTRS3 = "1053"))
/CONDITION RETRO( PATCAT_CT CT "CSF" AND GROUPING = "751" AND PATTYP_CT = "PRRET" AND ( ACMTRS3 = "1051" OR ACMTRS3 = "2051" OR ACMTRS3 = "2054" OR ACMTRS3 = "1010" OR ACMTRS3 = "1053"))																					
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ASSUMED
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE RETRO
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_20
LIBEL="RETRIEVE FUTURE PREMIUM AND FUTURE RETRO PREMIUM PREVIOUS PERIOD : CSF~PRACC and CSF~PRRET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_GTSII_GLOBAL_CASHFLOW_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CASHFLOW_ASSUMED_PREVQ.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_CASHFLOW_RETRO_PREVQ.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	GROUPING    	45:1 	- 45:,
	PATCAT_CT		52:1 	- 52:,
	PATTYP_CT		53:1 	- 53:,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/CONDITION ASSUMED( PATCAT_CT CT "CSF" AND GROUPING = "751" AND PATTYP_CT = "PRACC" AND (ACMTRS3 = "1051" OR ACMTRS3 = "1010" OR ACMTRS3 = "1053"))
/CONDITION RETRO( PATCAT_CT CT "CSF" AND GROUPING = "751" AND PATTYP_CT = "PRRET" AND (ACMTRS3 = "1051" OR ACMTRS3 = "1010" OR ACMTRS3 = "1053"))																					
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ASSUMED
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE RETRO
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_30
LIBEL="RETRIEVE CSF ASSUMED and RETRO INI : CSF~PRACC and CSF~PRRET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_CASHFLOW_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CASHFLOW_ASSUMED_INI.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_CASHFLOW_RETRO_INI.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	GROUPING    	45:1 	- 45:,
	PATCAT_CT		52:1 	- 52:,
	PATTYP_CT		53:1 	- 53:,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/CONDITION COND_ACCEPT( PATCAT_CT CT "CSF" AND GROUPING = "751" AND ACMTRS3 = "1051" AND PATTYP_CT = "PRACC" )
/CONDITION COND_RETRO( PATCAT_CT CT "CSF" AND GROUPING = "751" AND ACMTRS3 = "1051" AND PATTYP_CT = "PRRET" )																					
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_ACCEPT
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE COND_RETRO
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_40
LIBEL="SORT ASSUMED CASHFLOW FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CASHFLOW_ASSUMED_Q.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_ASSUMED_Q.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACMTRS3
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_50
LIBEL="SORT ASSUMED CASHFLOW Q-1 FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_CASHFLOW_ASSUMED_PREVQ.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_ASSUMED_PREVQ.dat" 
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACMTRS3
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_60
LIBEL="SORT RETRO P CASHFLOW FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CASHFLOW_RETRO_Q.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RET_P_Q.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF    	8:1 	- 8:,
	END_NT     	9:1 	- 9:EN,
	SEC_NF     	10:1 	- 10:EN,
	UWY_NF     	11:1 	- 11:,
	UW_NT   	12:1 	- 12:EN,
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	FILLER		1:1		- 124:	
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
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_70
LIBEL="SORT RETRO NP CASHFLOW FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CASHFLOW_RETRO_Q.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RET_NP_Q.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	FILLER		1:1		- 124:	
/KEYS 	 	
	RETCTR_NF, 	
	RETEND_NT, 	
	RETSEC_NF, 		
	RTY_NF, 	
	RETUW_NT, 	
	PLC_NT	
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_80
LIBEL="SORT RETRO P CASHFLOW Q-1 FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_CASHFLOW_RETRO_PREVQ.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RET_P_PREVQ.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF     	8:1 	- 8:,
	END_NT    	9:1 	- 9:EN,
	SEC_NF     	10:1 	- 10:EN,
	UWY_NF     	11:1 	- 11:,
	UW_NT      	12:1 	- 12:EN,
	CUR_CF		18:1 	- 18:,
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	FILLER		1:1		- 124:	
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
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_90
LIBEL="SORT RETRO NP CASHFLOW Q-1 FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_CASHFLOW_RETRO_PREVQ.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RET_NP_PREVQ.dat"  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	FILLER		1:1		- 124:	
/KEYS 	    	
	RETCTR_NF, 	
	RETEND_NT, 	
	RETSEC_NF, 		
	RTY_NF, 	
	RETUW_NT, 	
	PLC_NT	
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_100
LIBEL="SORT ASSUMED CASHFLOW INI FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_CASHFLOW_ASSUMED_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_ASSUMED_INI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACMTRS3
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_110
LIBEL="SORT RETRO P CASHFLOW INI FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_CASHFLOW_RETRO_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RETRO_P_INI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF    	8:1 	- 8:,
	END_NT     	9:1 	- 9:EN,
	SEC_NF     	10:1 	- 10:EN,
	UWY_NF     	11:1 	- 11:,
	UW_NT   	12:1 	- 12:EN,
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	ACMTRS3		124:1 	- 124:,
	FILLER		1:1		- 124:	
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
	PLC_NT,
	ACMTRS3	
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_120
LIBEL="SORT RETRO NP CASHFLOW INI FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_CASHFLOW_RETRO_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_RETRO_NP_INI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF    	8:1 	- 8:,
	END_NT     	9:1 	- 9:EN,
	SEC_NF     	10:1 	- 10:EN,
	UWY_NF     	11:1 	- 11:,
	UW_NT   	12:1 	- 12:EN,
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	RECUR_CF	34:1 	- 34:,
	PLC_NT		36:1 	- 36:EN,
	ACMCUR_CF	44:1 	- 44:,
	ACMTRS3		124:1 	- 124:,
	FILLER		1:1		- 124:	
/KEYS 	  	
	RETCTR_NF, 	
	RETEND_NT, 	
	RETSEC_NF, 		
	RTY_NF, 	
	RETUW_NT, 	
	PLC_NT,
	ACMTRS3	
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

JOBEND
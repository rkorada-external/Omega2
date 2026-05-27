#!/bin/ksh
#=============================================================================================================================
# APPLICATION NAME          	: ESTIMATIONS - INVENTAIRE
# MODULE NAME                  	: IFRS17 REQ 11.2 : MAINTENANCE EXPENSES CSF CALCULATION
# JOB NAME           			: ESID3631.cmd
# REVISION                      : 1.0  
# CREATION DATE             	: 20/02/2019
# AUTORS                        : L.ELFAHIM 
#-----------------------------------------------------------------------------------------------------------------------------
# DESCRIPTION
#  REQ 11.02 - IFRS17- CLOSING SCHEDULE : NEW JOB TO CALCULATE EXPENSES MAINTENANCE :
#  - INFLATED INCURRED MAINTENANCE EXPENSES PROSPECTIVE STOCK
#  - INFLATED REMAINING MAINTENANCE EXPENSES PROSPECTIVE STOCK
#  - BOTH MANAGEMENT - CLOSING STANDARD AND AT INCEPTION - REQ11.7
#
#-----------------------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY
#=============================================================================================================================
#	<INDIX>		<JJ/MM/AAAA>	<AUTOR>  	<SPIRA>		<MODIFICATION DESCRIPTION>
#	[000] 		20/02/2019		LEL 		71570		Developpement de la version initiale
#	[001]		24/07/2019		LEL			79992		Filtres et Jointures des fichiers
#	[002]		06/09/2019		LEL			70537		Manage Closing at Inception
#	[003]		10/09/2019		LEL			79992		Manage PARM_ICLODAT_D 
#	[004] 		30/12/2019 		LEL 		82888 		To keep temporay files for each instance ( STD vs INI )
#   [005]      	09/01/2020  	C.SOCIE   	82575     	Change the using norm as SII to ALLNO
#	[006]  		26/02/2020  	LEL     	84954      	Correction SII files size to 2000
#	[007]    	16/03/2020  	LEL     	85431    	Correction MARKET
#	[008]     	25/05/2020  	LEL     	82888      	Store of temporay files Managed by "Boite à outils" 
#	[009]     	10/09/2020  	LEL     	82888      	Code Organization  
#   [010]       18/11/2020      JYP     	83609       bugfix move 2 DFILI files into mapping 
#   [011]       15/02/2021      NLD        	90978       Technical change of DUMMY and ONEROUS cashflow
#   [012]       22/02/2021      M.NAJI    	91531       Modification provisoir pour debloquer le closing
#   [013]       24/05/2021      LEL      	96522       LOCAL- Expenses filter on pericase
#==============================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
ICLODAT_D=$1
TYPEINV=$2

# Job Initialisation
JOBINIT

ECHO_LOG ""                                                                                  
ECHO_LOG "#========================================================================="   
ECHO_LOG "#===> TYPEINV ............................: ${TYPEINV}"                                
ECHO_LOG "#===> NORME ..............................: ${NORME}"                                  
ECHO_LOG "#===> NORME_CF ...........................: ${NORME_CF}"                                                                       
ECHO_LOG "#===> ICLODAT_D ..........................: ${ICLODAT_D}"                                                       
ECHO_LOG "#....................... INPUT ..........................................."
ECHO_LOG "#===> EST_FULAERAT .......................: ${EST_FULAERAT}"         
ECHO_LOG "#===> EPO_GTSII_GLOBAL_CASHFLOW ..........: ${EPO_GTSII_GLOBAL_CASHFLOW}"                                        
ECHO_LOG "#....................... OUTPUT ..........................................."   
ECHO_LOG "#===> ESF_GTSII_CASHFLOW .................: ${ESF_GTSII_CASHFLOW}"
ECHO_LOG "#===> ESF_MAINTENANCE_EXPENSES ...........: ${ESF_MAINTENANCE_EXPENSES}"            
ECHO_LOG "#========================================================================="  

NSTEP=${NJOB}_01
LIBEL="SPLIT CASHFLOW EBS to ASSUMED & RETRO for PERICASE FILTERING PURPOSE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_GTSII_GLOBAL_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_GLOBAL_CASHFLOW_RETRO.dat 2000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_GTSII_GLOBAL_CASHFLOW_ASSUMED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TYP_CT		49:1 	- 49:,
	FILLER    	1:1  	- 124:
/CONDITION COND_RETRO TYP_CT CT 'R' 
/CONDITION COND_ASSUMED TYP_CT CT 'A'  
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_RETRO
/REFORMAT FILLER
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE COND_ASSUMED
/REFORMAT FILLER
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_02
LIBEL="FILTER ASSUMED CSF FILE USING IADPERICASE by NORME ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_GTSII_GLOBAL_CASHFLOW_ASSUMED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_CASHFLOW_ASSUMED_FILTRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CUM_CTR_NF      8:1  	-  8:,
	CUM_END_NT      9:1  	-  9:,
	CUM_SEC_NF      10:1 	-  10:,
	CUM_UWY_NF      11:1 	-  11:,
	CUM_UW_NT       12:1 	-  12:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	FILTER        	1:1  	-  124:
/JOINKEYS
	CUM_CTR_NF,
	CUM_END_NT,
	CUM_SEC_NF,
	CUM_UWY_NF,
	CUM_UW_NT
/INFILE ${EPO_IADPERICASE} 1000 1 "~"
/JOINKEYS
	PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF,
	PER_UW_NT 
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILTER
exit
EOF
SORT

NSTEP=${NJOB}_03
LIBEL="FILTER RETRO CSF FILE USING IRDPERICASE by NORME ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_GTSII_GLOBAL_CASHFLOW_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_CASHFLOW_RETRO_FILTRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 		24:1 	- 24:,
	RETEND_NT 		25:1 	- 25:,
	RETSEC_NF 		26:1 	- 26:,
	RTY_NF 			27:1 	- 27:,
	RETUW_NT 		28:1 	- 28:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	FILTER        	1:1  	-  124:
/JOINKEYS
	RETCTR_NF,    
	RETEND_NT,    
	RETSEC_NF,    
	RTY_NF,    
	RETUW_NT
/INFILE ${EST_IRDPERICASE} 1000 1 "~"
/JOINKEYS
	PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF,
	PER_UW_NT 
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILTER
exit
EOF
SORT

NSTEP=${NJOB}_05
LIBEL="FILTER CSF ASSUMED : KEEPING ONLY GROUPING ACMTRS = 314"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02_${IB}_GTSII_CASHFLOW_ASSUMED_FILTRED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MAIN_EXPENSES_FILTRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF  		8:1 	- 8:,
	END_NT         	9:1 	- 9:EN,
	SEC_NF       	10:1 	- 10:EN,
	UWY_NF       	11:1 	- 11:,
	UW_NT        	12:1 	- 12:EN,
	ACMTRS2_NF		42:1 	- 42:,
	ACMAMT_MNT		43:1 	- 43:EN 15/3,
	FILLER1			1:1 	- 42:,
	TOTAUX_MNT		123:1 	- 123:EN 15/3,
	NORM_CF    		50:1 	- 50:,
	PATCAT_CT		52:1 	- 52:,
	PATTYP_CT		53:1 	- 53:,
	FILLER2			44:1 	- 122:,
	ACMTRS3_NF		124:1 	- 124:
/DERIVEDFIELD ACMAMT_MC ACMAMT_MNT COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_MNT COMPRESS	
/CONDITION GROUPING ( NORM_CF CT "ALLNO" AND PATCAT_CT CT "CSF" AND PATTYP_CT CT "INF" AND ACMTRS2_NF = "314" AND "${CONTEXT_CT}" = "STD") 
					OR 
					( NORM_CF CT "ALLNO" AND PATCAT_CT CT "CSF" AND PATTYP_CT CT "INF" AND ACMTRS3_NF = "3115" AND "${CONTEXT_CT}" = "INI") 
/OUTFILE ${SORT_O}
/INCLUDE GROUPING
/REFORMAT 
	FILLER1,
	ACMAMT_MC,
	FILLER2,
	TOTAUX_MC,
	ACMTRS3_NF
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_15
LIBEL="ENRICHISSEMENT de ESF_MAINTENANCE_EXPENSES par ESF_FMARKET..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_MAIN_EXPENSES_FILTRED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MAIN_EXPENSES_ENRICHED_MARKET.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CUM_CTR_NF      8:1  -  8:,
	CUM_END_NT      9:1  -  9:,
	CUM_SEC_NF      10:1 -  10:,
	CUM_UWY_NF      11:1 -  11:,
	CUM_UW_NT       12:1 -  12:,
	FILTER        	1:1  -  124:,
	CTR_NF          1:1  -  1:,
	END_NT          2:1  -  2:,
	SEC_NF          3:1  -  3:,
	UWY_NF          4:1  -  4:,
	UW_NT           5:1  -  5:,
	MRKUNT_NT    	8:1  -  8:
/JOINKEYS
	CUM_CTR_NF,
	CUM_END_NT,
	CUM_SEC_NF,
	CUM_UWY_NF,
	CUM_UW_NT
/INFILE ${ESF_FMARKET} 1000 1 "~"
/JOINKEYS
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
	LEFTSIDE:FILTER,
	RIGHTSIDE:MRKUNT_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
LIBEL="ENRICHISSEMENT de ESF_MAINTENANCE_EXPENSES par ESF_FEXPRAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_MAIN_EXPENSES_ENRICHED_MARKET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MAIN_EXPENSES_ENRICHED_RATIO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CML_SSD_CF              1:1   -  1:,
	CML_ESB_CF              2:1   -  2:,
	CML_NAT_CF              48:1  -  48:,
	MRKUNT_NT               125:1 -  125:,
	FILTER                	1:1   -  125:,
	SSD_CF                  1:1   -  1:,
	ESB_CF                  2:1   -  2:,
	SGMT_LL					4:1   -  4:,
	SGMT_LS                 5:1   -  5:,
	CTRNAT_CT               7:1   -  7:,
	MAINT_RAT               9:1   -  9:EN 15/3
/JOINKEYS
	CML_SSD_CF,
	CML_ESB_CF,
	CML_NAT_CF,
	MRKUNT_NT
/INFILE ${ESF_FEXPRAT} 1000 1 "~"
/JOINKEYS
	SSD_CF,
	ESB_CF,
	CTRNAT_CT,
	SGMT_LS	
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
	LEFTSIDE:FILTER,
	RIGHTSIDE:MAINT_RAT
exit
EOF
SORT

NSTEP=${NJOB}_30
LIBEL="MAINTENANCE EXPENSES PREPARATION : sort ESF_MAINTENANCE_EXPENSES_ENRICHI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_MAIN_EXPENSES_ENRICHED_RATIO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MAINTENANCE_EXPENSES.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS	
	SSD_CF      1:1 -  1:EN,
	ESB_CF      2:1 -  2:EN      
/KEYS 	
	SSD_CF,
	ESB_CF  
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_40
LIBEL="MAINTENANCE EXPENSES PREPARATION : sort EST_FULAERAT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FULAERAT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ULAERAT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS	
	SSD_CF    	1:1 -  1:EN,
	ESB_CF   	2:1 -  2:EN      
/KEYS	
	SSD_CF,
	ESB_CF  
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_50
LIBEL="MAINTENANCE EXPENSES PREPARATION: Incurred maintenance / Remaining maintenance "
PRG=ESTC1090
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME_CF ${NORME_CF}
CLODAT_D ${PARM_ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_MAINTENANCE_EXPENSES.dat
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_ULAERAT_O.dat 
export ${PRG}_O1=${ESF_MAINTENANCE_EXPENSES}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_MAINTENANCE_EXPENSES_ANO.dat 
EXECPRG

NSTEP=${NJOB}_60
LIBEL="MERGE NEW LINES CREATED TO GLOBAL CASHFLOW FILERED ASSUMED & RETRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_MAINTENANCE_EXPENSES} 2000 1"
SORT_I2="${DFILT}/${NJOB}_02_${IB}_GTSII_CASHFLOW_ASSUMED_FILTRED.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_03_${IB}_GTSII_CASHFLOW_RETRO_FILTRED.dat 2000 1"
SORT_O="${ESF_GTSII_CASHFLOW}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CUM_CTR_NF        	8:1 	- 8:,
	CUM_END_NT      	9:1 	- 9:EN,
	CUM_SEC_NF          10:1 	- 10:EN,
	CUM_UWY_NF        	11:1 	- 11:,
	CUM_UW_NT          	12:1 	- 12:EN,
	FILLER1				1:1 	- 18:,
	CML_AMT_MC			19:1 	- 19:EN,
	FILLER2				20:1 	- 34:,
	CML_RETAMT_MC		35:1 	- 35:EN,
	FILLER3				36:1 	- 40:,
	CML_RETINTAMT_MC	41:1 	- 41:EN,
	CML_ACMTRS_NT		42:1 	- 42:,
	CML_ACMAMT_MC		43:1 	- 43:EN,
    FILLER4				44:1 	- 122:,
	CML_TOTAUX_MC		123:1 	- 123:EN,
	CML_ACMTRS3			124:1 	- 124:
/DERIVEDFIELD AMT_MC CML_AMT_MC COMPRESS
/DERIVEDFIELD RETAMT_MC CML_RETAMT_MC COMPRESS
/DERIVEDFIELD RETINTAMT_MC CML_RETINTAMT_MC COMPRESS
/DERIVEDFIELD ACMAMT_MC CML_ACMAMT_MC COMPRESS
/DERIVEDFIELD TOTAUX_MC CML_TOTAUX_MC COMPRESS	
/OUTFILE ${SORT_O}
/REFORMAT 
	FILLER1,
	AMT_MC,
	FILLER2,
	RETAMT_MC,
	FILLER3,
	RETINTAMT_MC,
	CML_ACMTRS_NT,
	ACMAMT_MC,
	FILLER4,
	TOTAUX_MC,
	CML_ACMTRS3
/COPY
exit
EOF
SORT

JOBEND
#!/bin/ksh
#=================================================================================================================
# APPLICATION NAME          	: ESTIMATIONS - INVENTAIRE
# MODULE NAME                  	: IFRS17 REQ 11.3 : RETRO NP EXPENSES CALCULATION
# JOB NAME           			: ESFD3672.cmd
# REVISION                      : 1.0  
# CREATION DATE             	: 27/01/2020
# AUTOR                         : L.ELFAHIM
#-----------------------------------------------------------------------------------------------------------------
# DESCRIPTION :
#  SPIRA 79102 : REQ 11.3 - RETRO NP EXPENSES CALCULATION
#  SPIRA XXXXX : BOTH MANAGEMENT - CLOSING STANDARD AND AT INCEPTION - REQ11.7.2
#-----------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY
#=================================================================================================================
#<INDIX>	<JJ/MM/AAAA>	<AUTOR>	<SPIRA>		<MODIFICATION DESCRIPTION>
#[001] 		27/01/2020		LEL 	79102 		DEVELOPMENT OF INITIAL VERSION 
#[002]    	24/03/2020  	LEL   	79102 		DO NOT TAKE INTO ACCOUNT TRNCODE AT INCEPTION
#[003]    	27/03/2020  	LEL   	79102  		EXTRACT NEW RET_FEXPRAT FOR RETRO NP
#[004] 		13/05/2020  	CS 		83206  		REQ 11.7 - For contract incepting before closing date adapt the pattern 
#[005] 		03/06/2020  	LEL 	82720  		Add STEP TRANSITION MANAGEMENT
#[005] 		13/08/2020  	LEL 	87876  		Manage GT files RETRO EXPENSES 
#[006]     	31/08/2020  	CS    	88975  		IFRS17 add Retropericase to ESTC1056A
#[007]   	10/09/2020  	LEL    	88975  		Code Organization
#[008]     	11/09/2020  	LEL    	89816  		ADD PARAMS : CONTEXT and ICLODAT to ESTC1056A program
#[009]  	06/01/2021      LEL   	92596      	Integrate future AE in expense calculation
#[010]		15/02/2021      NLD     90978    	Technical change of DUMMY and ONEROUS cashflow
#[010]     	03/05/2021      NLD     85522     	copy  DUMMY and ONEROUS cashflows
#[011]		31/05/2021 		LEL	    95130		Mapping change : set CONTEXT=TRN for TRANSITION
#[012]		14/06/2021		LEL		96349 		FOR RETRO NP USE LOB STANDARD & DO NOY USE QUARTER
#[027]  	08/09/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION	
#=================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Get input parameters
ICLODAT_D=$1
TYPEINV=$2
CRE_D=$3

TRIM_NF=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`

ECHO_LOG ""                                                                                  
ECHO_LOG "#======================================================================================="
ECHO_LOG "#===> NORME .........................................: ${NORME}"   
ECHO_LOG "#===> TYPEINV .......................................: ${TYPEINV}"                                                                 
ECHO_LOG "#===> NORME_CF ......................................: ${NORME_CF}"                                               
ECHO_LOG "#===> ICLODAT_D .....................................: ${ICLODAT_D}"                                                 
ECHO_LOG "#....................... INPUT ..........................................."                   
ECHO_LOG "#===> EPO_FCURQUOT ..................................: ${EPO_FCURQUOT}"
ECHO_LOG "#===> EST_FPLACEMT22 ................................: ${EST_FPLACEMT22}"
ECHO_LOG "#===> EST_IRDPERICASE ...............................: ${EST_IRDPERICASE}"
ECHO_LOG "#===> ESF_RET_FEXPRAT ...............................: ${ESF_RET_FEXPRAT}" 
ECHO_LOG "#===> EST_FCLIENT_TXT ...............................: ${EST_FCLIENT_TXT}" 
ECHO_LOG "#===> EST_FCURQUOT_TXT ..............................: ${EST_FCURQUOT_TXT}"
ECHO_LOG "#===> EPO_IRDPERICASE0 ..............................: ${EPO_IRDPERICASE0}" 
ECHO_LOG "#===> EST_FBOPRSLNK_TXT .............................: ${EST_FBOPRSLNK_TXT}" 
ECHO_LOG "#===> ESF_GTSII_ONE_STD .............................: ${ESF_GTSII_ONE_STD}" 
ECHO_LOG "#===> ESF_GTSII_DUMMY_STD ...........................: ${ESF_GTSII_DUMMY_STD}"
ECHO_LOG "#===> EST_CSF_NDIC_AMOUNT ...........................: ${EST_CSF_NDIC_AMOUNT}" 
ECHO_LOG "#===> EST_FSEGPATTERN_CSF ...........................: ${EST_FSEGPATTERN_CSF}"
ECHO_LOG "#===> EST_IADPERICASE_STD ...........................: ${EST_IADPERICASE_STD}" 
ECHO_LOG "#===> EPO_IRDPERICASE0_TRN ..........................: ${EPO_IRDPERICASE0_TRN}"                                               
ECHO_LOG "#....................... OUTPUT ..........................................." 
ECHO_LOG "#===> ESF_RETRO_EXPENSES ............................: ${ESF_RETRO_EXPENSES}"                               
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW .....................: ${ESF_GTSII_GLOBAL_CASHFLOW}"                
ECHO_LOG "#========================================================================================"

NSTEP=${NJOB}_05
LIBEL="TOUCH FILES NOT FOUND"
if [  ! -f "${EST_CSF_NDIC_AMOUNT}"  ]
then
	ECHO_LOG "EST_CSF_NDIC_AMOUNT : DOES NOT EXIST, CREATE AN EMPTY FILE"
	EXECKSH "touch ${EST_CSF_NDIC_AMOUNT}"
fi

if [  ! -f "${ESF_GTSII_ONE_STD}"  ]
then
	ECHO_LOG "ESF_GTSII_ONE_STD : DOES NOT EXIST, CREATE AN EMPTY FILE"
	EXECKSH "touch ${ESF_GTSII_ONE_STD}"
fi

if [  ! -f "${ESF_GTSII_DUMMY_STD}"  ]
then
	ECHO_LOG "ESF_GTSII_DUMMY_STD : DOES NOT EXIST, CREATE AN EMPTY FILE"
	EXECKSH "touch ${ESF_GTSII_DUMMY_STD}"
fi

NSTEP=${NJOB}_10
LIBEL="Filter and Enrichment OF IRDPERICASE : KEEP ONLY RETRO NP MVTS..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IRDPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_NP.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	RETCTR_NF  		3:1 	- 3:,
	RETEND_NT   	4:1 	- 4:EN,
	RETSEC_NF  		5:1 	- 5:EN,
	RTY_NF  		6:1 	- 6:,
	RETUW_NT		7:1 	- 7:EN,
	RETCTRCAT_CF 	107:1 	- 107:,
	FILLER  		1:1 	- 206: 
/CONDITION RETRO_NP RETCTRCAT_CF = "02"
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/REFORMAT FILLER
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_20
LIBEL="Enrichment OF IRDPERICASE BY ESF_FPLACEMT2..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_IRDPERICASE_NP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PLA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	RETCTR_NF 	3:1 	- 3:,
	RETEND_NT   4:1 	- 4:,
	RETSEC_NF 	5:1 	- 5:,          
	RTY_NF     	6:1 	- 6:,         
	RETUW_NT	7:1 	- 7:,
	CTR_NF 		3:1 	- 3:,
	SEC_NF 		5:1 	- 5:,
	UWY_NF 		6:1 	- 6:,    
	PLC_NT 		8:1 	- 8:EN,                        
	RTO_NF    	11:1 	- 11:,
	INT_NF 		12:1 	- 12:,
	PAY_NF    	13:1 	- 13:,
	KEY_CF    	14:1 	- 14:,
	FILLER    	1:1 	- 207:		          
/JOINKEYS 
	RETCTR_NF,
	RETSEC_NF,	
	RTY_NF        		
/INFILE ${EST_FPLACEMT22} 1000 1 "~"
/JOINKEYS
	CTR_NF,
	SEC_NF,	
	UWY_NF
/JOIN UNPAIRED LEFTSIDE               
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:PLC_NT,RTO_NF,INT_NF,PAY_NF,KEY_CF 
exit
EOF
SORT

NSTEP=${NJOB}_30
LIBEL="ENRICHMENT OF RETRO NP PERICASE BY ESF_RET_FEXPRAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_IRDPERICASE_PLA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_RAT_Q.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETSSD_CF  	1:1    	- 1:,
	RETCTR_NF  	3:1 	- 3:,
	RETEND_NT   4:1 	- 4:,
	RETSEC_NF  	5:1 	- 5:,  
	RTY_NF  	6:1 	- 6:,
	RETUW_NT	7:1 	- 7:,
	RETESB_CF	8:1 	- 8:,
	RETNAT_CT	85:1	- 85:,
	FILLER   	1:1    	- 212:,
	SSD_CF     	1:1    	- 1:,
	ESB_CF      2:1    	- 2:,
	CTRNAT_CT  	5:1    	- 5:,
	ACQ_RATIO 	6:1    	- 6:
/JOINKEYS
	RETSSD_CF,
	RETESB_CF,
	RETNAT_CT
/INFILE ${ESF_RET_FEXPRAT} 1000 1 "~"
/JOINKEYS
	SSD_CF,
	ESB_CF,
	CTRNAT_CT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:ACQ_RATIO
exit
EOF
SORT

NSTEP=${NJOB}_40
LIBEL="ENRICHMENT OF RETRO NP PERICASE BY EST_FCLIENT_TXT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_IRDPERICASE_RAT_Q.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_CLISSD.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RTO_NF       	209:1  	-  209:,
	CLI_NF          1:1   	-  1:,
	CLISSD_CF       2:1   	-  2:,
	FILLER        	1:1   	-  214:
/JOINKEYS
	RTO_NF
/INFILE ${EST_FCLIENT_TXT} 1000 1 "~"
/JOINKEYS
	CLI_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:CLISSD_CF
exit
EOF
SORT 

NSTEP=${NJOB}_50
LIBEL="Sort RETRO NP IRDPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_IRDPERICASE_CLISSD.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_NP.dat 1000 1"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	RETCTR_NF  	3:1 	- 3:,
	RETEND_NT   4:1 	- 4:EN,
	RETSEC_NF  	5:1 	- 5:EN,
	RTY_NF  	6:1 	- 6:,
	RETUW_NT	7:1 	- 7:EN,
	PLC_NT 		208:1 	- 208:EN,                        
	RTO_NF    	209:1 	- 209:,              
	FILLER  	1:1 	- 215:
/KEYS 	
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT
/SUMMARIZE	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_60
LIBEL="RETRO NP EXPENSES CALCULATIONS..." 
PRG=ESFC3672
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME ${NORME_CF}
CLODAT_D ${PARM_ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_IRDPERICASE_NP.dat
export ${PRG}_I2=${DFILT}/${PCH}ESFD3630_ESFD3671_${TYPEINV}_70_${IB}_SORT_CASHFLOW_RETRO.dat
export ${PRG}_I3=${EPO_FCURQUOT}
export ${PRG}_O1=${ESF_RETRO_EXPENSES}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETRO_EXPENSES_ANO.dat
EXECPRG

#---------------------------------------------------------------------
# 		RETRO EXPENSES CASHFLOW CALCULATION
#---------------------------------------------------------------------
NSTEP=${NJOB}_70
LIBEL="EXTEND EST_FBOPRSLNK_TXT WITH PARM1 OF ESF_FPRSMAP_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	ACMTRSL3_NT    	5:1 	- 5:,
	ACMTRS_NT       2:1 	- 2:,
	PARM1          	3:1  	- 3:,
	FILLER         	1:1  	- 14:
/JOINKEYS
	ACMTRSL3_NT
/INFILE ${ESF_FPRSMAP_TXT} 500 1 "~"
/JOINKEYS
	ACMTRS_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:PARM1
exit
EOF
SORT

NSTEP=${NJOB}_80
LIBEL="FORMAT RETRO EXPENSES FILE FOR ESTC1051A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_RETRO_EXPENSES} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_EXPENSES.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD2_CF		6:1 	- 6:7,
	RETCTR_NF       24:1 	- 24:,
	RETEND_NT       25:1 	- 25:EN,
	RETSEC_NF       26:1 	- 26:EN,
	RTY_NF          27:1 	- 27:,
	RETUW_NT        28:1 	- 28:EN,
	PLC_NT          36:1 	- 36:,
	FILLER			1:1  	- 42:
/KEYS	
	RETCTR_NF,	
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT	
/DERIVEDFIELD ORICOD_LS "${NORME_CF}GTA" 
/DERIVEDFIELD 15_CHAMPS "~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT 	
	FILLER,
	15_CHAMPS,
	ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_90
LIBEL="EXTEND GTR WITH ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT OF EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_EXPENSES.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	FBOPRSLNK_DETTRS_CF 9:1 	- 9:,
	DETTRS_CF        	6:1 	- 6:,
	ACMTRSL2_NT     	4:1 	- 4:,
	ACMTRSL3_NT     	5:1 	- 5:,
	TRNTYP_CT      		14:1 	- 14:,
	PARM1              	15:1 	- 15:,
	FILLER           	1:1  	- 57:
/JOINKEYS
	FBOPRSLNK_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_80_${IB}_SORT_RETRO_EXPENSES.dat 1000 1 "~"
/JOINKEYS
	DETTRS_CF
/JOIN UNPAIRED RIGHTSIDE
/DERIVEDFIELD EMPTY "~"
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:FILLER,
	LEFTSIDE:ACMTRSL3_NT,
	LEFTSIDE:ACMTRSL2_NT,
	LEFTSIDE:ACMTRSL3_NT,
	LEFTSIDE:TRNTYP_CT,
	LEFTSIDE:ACMTRSL3_NT,
	LEFTSIDE:PARM1
exit
EOF
SORT

NSTEP=${NJOB}_100
LIBEL="RETRO EXPENSES PREPARATION : sort RETRO EXPENSES FILE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_RETRO_EXPENSES.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_EXPENSES.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	SSD_CF  	1:1 	-  1:EN,
	ESB_CF    	2:1 	-  2:EN,
	CTR_NF 		24:1 	-  24:,
	END_NT 		25:1 	-  25:EN,
	SEC_NF   	26:1 	-  26:EN,
	UWY_NF  	27:1 	-  27:,
	UW_NT   	28:1 	-  28:EN,
	PLC_NT		36:1 	-  36:EN,
	FILLER     	1:1 	-  73:
/KEYS   
	CTR_NF,                                 
	END_NT,                    
	SEC_NF,   		 
	UWY_NF,   
	UW_NT,
	PLC_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_110
LIBEL="RETRO EXPENSES PREPARATION : FORMAT RETRO_EXPENSES FILE..."
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_IRDPERICASE_NP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_RETRO_EXPENSES.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_GTESTCUMUL_RET.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG

if [ ${PARM_IS_TRN} == 'YES' ]
then
	CONTEXT_CT=TRN
fi

#[004] add I3  
NSTEP=${NJOB}_120
LIBEL="RETRO EXPENSES PREPARATION : CSF PRRET CALCULATION..."
PATTERN_CATEGORY="CSF  "
PRG=ESTC1056A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
CONTEXT ${CONTEXT_CT}
CLODAT_D ${PARM_ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_GTESTCUMUL_RET.dat
export ${PRG}_I2=${EST_FSEGPATTERN_CSF}
export ${PRG}_I3=${EST_IADPERICASE_STD}
export ${PRG}_I4=${EST_IRDPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056A_CASHFLOW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056A_REMAINTOPAY_ULAE.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
EXECPRG

NSTEP=${NJOB}_130
LIBEL="RETRO EXPENSES PREPARATION : ADD NORME..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_120_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_ACQ_EXPENSES_RET_INI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	FILLER1 	1:1  	- 49:,
	ACMAMT_MC	43:1	- 43:EN 15/3,
	NORME		6:8  	- 6:8,
	FILLER2		50:1 	- 124:
/CONDITION AMNT_NOT_NULL ACMAMT_MC != 0	
/CONDITION NORME_I NORME = "I"
/CONDITION NORME_K NORME = "K"
/CONDITION NORME_M NORME = "M"
/DERIVEDFIELD NORME_CF if NORME_I then "I17G" else if NORME_K then "I17P" else if NORME_M then "I17L" else "I17G"
/INCLUDE AMNT_NOT_NULL
/OUTFILE ${SORT_O}
/REFORMAT 
	FILLER1,
	NORME_CF,
	FILLER2
/COPY	
exit
EOF
SORT

NSTEP=${NJOB}_140
LIBEL="MERGE RETRO CASHFLOW FILE WITH GLOBAL_CASHFLOW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_130_${IB}_ACQ_EXPENSES_RET_INI.dat 2000 1"
SORT_I2="$DFILT/${ENV_PREFIX}_ESFD3630_ESFD3671_${TYPEINV}_190_${IB}_ACQ_EXPENSES_ASSUMED_INI.dat 2000 1"
SORT_I3="${EST_CSF_NDIC_AMOUNT} 2000 1"
SORT_I4="${ESF_GTSII_ONE_STD} 2000 1"
SORT_I5="${ESF_GTSII_DUMMY_STD} 2000 1"
SORT_I6="${ESF_GTSII_CASHFLOW} 2000 1"
SORT_O="${ESF_GTSII_GLOBAL_CASHFLOW}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER  1:1 - 124:  
/OUTFILE ${SORT_O}
/REFORMAT FILLER
/COPY
exit
EOF
SORT

JOBEND
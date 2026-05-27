#!/bin/ksh
#===============================================================================================================
# APPLICATION NAME          	: ESTIMATIONS - INVENTAIRE
# MODULE NAME                  	: IFRS17 REQ 11.1 : EXPENSES MANAGEMENT
# JOB NAME           			: ESFD3671.cmd
# REVISION                      : 1.0  
# CREATION DATE             	: 26/11/2018
# AUTORS                        : LEL 
#---------------------------------------------------------------------------------------------------------------
# DESCRIPTION :
#  SPIRA 69814 : REQ 11.01 - IFRS17- CLOSING SCHEDULE : NEW JOB TO CALCULATE EXPENSES AMOUNTS
#  SPIRA 70537 : BOTH MANAGEMENT - CLOSING STANDARD AND AT INCEPTION - REQ11.7
#
#----------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY
#================================================================================================================
#<INDIX>	<JJ/MM/AAAA>	<AUTOR>	<SPIRA>		<MODIFICATION DESCRIPTION>
#[001] 		26/11/2018 		JYP 	69814  		new job for expenses calculation
#[002] 		12/04/2019 		JYP 	69814  		move steps from chain to jobs
#[003] 		15/04/2019 		JYP 	69814  		bugfix TMP filenames
#[004] 		25/04/2019 		JYP 	69814  		bugfix EST_IGTAA0 missing
#[005] 		31/07/2019 		TY  	11.1   		Many new step for IFRS17
#[006] 		03/09/2019 		JYP 	69814  		use EPO_DLDGTAA/EST_IGTAA0 from mapping I17G
#[007] 		01/08/2019 		LEL 	75803  		Revue many steps after updating FEXPRAT and FMARKET
#[008] 		06/09/2019 		LEL 	70537  		Integration at Inception mode
#[009] 		13/09/2019 		LEL 	77798  		Take into account only ACMAMT_MC <> 0  for CSF/PRACC
#[010] 		15/11/2019 		LEL 	82609  		Change rule R01-03 and remove Rule R01-04
#[011] 		30/12/2019 		LEL 	82888  		To keep temporay files for each instance ( STD vs INI )
#[012] 		02/01/2020 		LEL 	82884  		105 wrongly used instead of 1051 - UPR ignored if FP=0 and other 
#[013] 		08/01/2020 		LEL 	82884  		Change Input file in order to retrieve UPR Ending
#[014]    	21/01/2020  	CS      82557    	EBS - Future - Currency
#[015]    	24/03/2020  	LEL     79102    	DO NOT TAKE INTO ACCOUNT TRNCODE AT INCEPTION
#[016] 		13/05/2020  	CS 		83206     	REQ 11.7 - For contract incepting before closing date adapt the pattern
#[017] 		03/06/2020  	LEL 	82720  		Add STEP TRANSITION MANAGEMENT
#[018] 		30/07/2020  	LEL 	88830  		INTEGRATION NDIC FILE
#[019]     	31/08/2020  	CS      88975  		IFRS17 add Retropericase to ESTC1056A
#[020]     	10/09/2020  	LEL   	88975  		Code Organization
#[021]     	11/09/2020  	LEL   	89816  		ADD PARAMS : CONTEXT and ICLODAT to ESTC1056A program
#[022]    	18/11/2020      JYP   	83609       bugfix move 2 DFILI files into mapping 
#[023]   	06/01/2021      LEL   	92596       Integrate future AE in expense calculation
#[024]		15/02/2021 		NLD	    90978		Technical change of DUMMY and ONEROUS cashflow : remove old NDIC
#[025]		10/05/2021 		LEL	    96217		Mapping change : Use IFRS17 PERICASE instead of EBS PERICASE
#[026]		31/05/2021 		LEL	    95130		Mapping change : I3 of ESTCA056A & set CONTEXT=TRN for TRANSITION
#[027]    	06/09/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION
#[028]     	13/10/2021      LEL    	99572       NO MORE IAE CALCULATION ON RETRO
#[029]    	10/01/2022 		MZM  	91532  		Bug Fix : Taille Syncsort de 1000 ==> 2000
#[030]     	17/01/2022     	DaD     100401      Bug Fix : reformat GLOBAL_CASHFLOW file when the contract is empty
#[031]    	09/03/2022 		MZM  	SPIRA:101825   :I17 - Expenses calculation for Granularity Individual CR
#[032]    	07/04/2022 		MZM  	SPIRA:101825   :Update Filter condition on PERICASE : Modif [031] Annule
#[033]    	12/04/2022 		JYP  	SPIRA:101825   : update porfolio , use 901 for individual
#[034] 			07/07/2022  	JBD		Spira:104778   : Build new closing for I17S norm
#[035]      08/07/2022      JYP     SPIRA:105497   : add a specific sort for transition file
#[036]      29/07/2022      JYP     SPIRA:105497   : fix regression from 104778
#================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Get input parameters
ICLODAT_D=$1
TYPEINV=$2
CRE_D=$3

CLOPRD=`echo ${ICLODAT_D} | awk '{print substr($0,1,6)}'`
TRIM_NF=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`

export ICLODAT_YEAR=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,1,4)}'` 	#[013]

ECHO_LOG ""                                                                                  
ECHO_LOG "#==================================================================="
ECHO_LOG "#===> NORME ...........................: ${NORME}"  
ECHO_LOG "#===> TYPEINV .........................: ${TYPEINV}"                                                                  
ECHO_LOG "#===> NORME_CF ........................: ${NORME_CF}"                                                                               
ECHO_LOG "#===> ICLODAT_D .......................: ${ICLODAT_D}"           
ECHO_LOG "#===> PARM_IS_TRN .....................: ${PARM_IS_TRN} "                                                                                            
ECHO_LOG "#....................... INPUT ......................................"                
ECHO_LOG "#===> EPO_FCTRGRO .....................: ${EPO_FCTRGRO}"                          
ECHO_LOG "#===> EST_FCLIENT_TXT .................: ${EST_FCLIENT_TXT}"   
ECHO_LOG "#===> EPO_IADPERICASE .................: ${EPO_IADPERICASE}"                                     
ECHO_LOG "#===> EST_IRDPERICASE .................: ${EST_IRDPERICASE}"
ECHO_LOG "#===> ESF_FPRSMAP_TXT .................: ${ESF_FPRSMAP_TXT}"
ECHO_LOG "#===> EST_FCURQUOT_TXT ................: ${EST_FCURQUOT_TXT}"
ECHO_LOG "#===> EST_FBOPRSLNK_TXT ...............: ${EST_FBOPRSLNK_TXT}"
ECHO_LOG "#===> ESF_RATIO_TEXPRAT ...............: ${ESF_RATIO_TEXPRAT}" 
ECHO_LOG "#===> ESF_GTSII_ONE_STD ...............: ${ESF_GTSII_ONE_STD}"
ECHO_LOG "#===> ESF_GTSII_CASHFLOW ..............: ${ESF_GTSII_CASHFLOW}"  
ECHO_LOG "#===> ESF_GTSII_DUMMY_STD .............: ${ESF_GTSII_DUMMY_STD}"
ECHO_LOG "#===> EST_CSF_NDIC_AMOUNT .............: ${EST_CSF_NDIC_AMOUNT}"  
ECHO_LOG "#===> EST_FSEGPATTERN_CSF .............: ${EST_FSEGPATTERN_CSF}"
ECHO_LOG "#===> EST_IADPERICASE_STD .............: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EPO_IADPERICASE_TRN .............: ${EPO_IADPERICASE_TRN}"
ECHO_LOG "#===> ESF_GTESTCUMUL_ACCRET ...........: ${ESF_GTESTCUMUL_ACCRET}"
ECHO_LOG "#===> ESF_FSEG_TSECIFRS_I17 ...........: ${ESF_FSEG_TSECIFRS_I17}"
ECHO_LOG "#===> EPO_GTSII_GLOBAL_CASHFLOW .......: ${EPO_GTSII_GLOBAL_CASHFLOW}"                                        
ECHO_LOG "#....................... OUTPUT ......................................."   
ECHO_LOG "#===> ESF_EXPENSES ....................: ${ESF_EXPENSES}"
ECHO_LOG "#===> ESF_GTESTCUMUL_ACCRET_TRN .......: ${ESF_GTESTCUMUL_ACCRET_TRN}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW .......: ${ESF_GTSII_GLOBAL_CASHFLOW}" 
ECHO_LOG "#===> ESF_GTESTCUMUL_ACCRET_NOT_TRN ...: ${ESF_GTESTCUMUL_ACCRET_NOT_TRN}"           
ECHO_LOG "#==================================================================="

NSTEP=${NJOB}_05
LIBEL="TOUCH FILES NOT FOUND"
if [  ! -f "${EST_CSF_NDIC_AMOUNT}"  ]
then
	ECHO_LOG "EST_CSF_NDIC_AMOUNT : DOES NOT EXIST, CREATE AN EMPTY FILE"
	touch ${EST_CSF_NDIC_AMOUNT}
fi

if [  ! -f "${ESF_GTSII_ONE_STD}"  ]
then
	ECHO_LOG "ESF_GTSII_ONE_STD : DOES NOT EXIST, CREATE AN EMPTY FILE"
	touch ${ESF_GTSII_ONE_STD}
fi

if [  ! -f "${ESF_GTSII_DUMMY_STD}"  ]
then
	ECHO_LOG "ESF_GTSII_DUMMY_STD : DOES NOT EXIST, CREATE AN EMPTY FILE"
	touch ${ESF_GTSII_DUMMY_STD}
fi


###[031] DEB
##
##NSTEP=${NJOB}_02
###-----------------------------------------------------------------------------
##LIBEL="Sort of EPO_IADPERICASE retrive CR set as Individual"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EPO_IADPERICASE} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS CTR_NF       3:1 -  3:,
##        END_NT       4:1 -  4:EN,
##        SEC_NF       5:1 -  5:EN,
##        UWY_NF       6:1 -  6:,
##        UW_NT        7:1 -  7:EN, 
##        CED_NF       12:1 - 12:,     
##        CTRINC_D     19:1 - 19:,
##				PORTFOLIO    119:1 - 119:,      
##				GRPIFRSLOB_CF    244:1 - 244:,
##				PARIFRSLOB_CF    245:1 - 245:,		
##				LOCIFRSLOB_CF    246:1 - 246:								
##/KEYS   CTR_NF,
##        END_NT,
##        SEC_NF,
##        UWY_NF,
##        UW_NT
##/CONDITION  WITH_CR_INDIV_FOLIO  ( (PORTFOLIO = "901") and (GRPIFRSLOB_CF = "2" ) or (PARIFRSLOB_CF = "2" ) or (LOCIFRSLOB_CF = "2" )  )
##/OUTFILE ${SORT_O} OVERWRITE
##/INCLUDE WITH_CR_INDIV_FOLIO
##exit
##EOF
##SORT

##[031]export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IADPERICASE.dat

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
if [ "$PARM_IS_TRN" = "YES" ]  #specific transition project 
then 

LIBEL="TRANSITION $PARM_IS_TRN : Sort assumed PERICASE for CTRGRO  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADPERICASE} 2000 1"                                   
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF      1:1 - 1:EN,
        CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:,
        SEC_NF      5:1 -  5:,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT
else  # case non-transition 
LIBEL="PARM_IS_TRN=$PARM_IS_TRN : copy assumed PERICASE for CTRGRO  "
EXECKSH_MODE=P
EXECKSH "cp ${EPO_IADPERICASE} ${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat "

fi 




#[005]
NSTEP=${NJOB}_10
#Comparison of period closing and segmentation perimeters
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into Pericase"
PRG=ESTM1004
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_${IDF_CT}_$$.dat
export ${PRG}_I2=${EPO_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG
#[005]


#[031]SORT_I="${DFILT}/${NJOB}_02_${IB}_SORT_IADPERICASE.dat 2000 1"

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="ENRICHISSEMENT DE IADPERICASE PAR BCP_FCLIENT_O..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_CLISSD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CED_NF      12:1  	-  12:,
	CLI_NF      1:1   	-  1:,
	CLISSD_CF	2:1   	-  2:,
	FILLER     	1:1   	-  253:
/JOINKEYS
    CED_NF
/INFILE ${EST_FCLIENT_TXT} 2000 1 "~"
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



NSTEP=${NJOB}_17
#-----------------------------------------------------------------------------
LIBEL="UPDATE PORFOLIO , seg 901 for individual "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FSEG_TSECIFRS_I17}"
SORT_O="${DFILT}/${NSTEP}_${IB}_SEG_TSECIFRS_I17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CSUOE        	1:1  	-  5:,
	CTR_NF      	1:1  	-  1:,
	END_NT      	2:1  	-  2:,
	SEC_NF      	3:1  	-  3:,
	UWY_NF      	4:1  	-  4:,
	UW_NT       	5:1  	-  5:,
	IFRSSEG_CT12	6:1  	-  6:2,
	IFRSSEG     	6:1  	-  6:	
/CONDITION COND_SEG IFRSSEG_CT12 EQ "CR"
/DERIVEDFIELD IFRSSEG_NEW if COND_SEG then "901" else IFRSSEG
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT CSUOE,IFRSSEG_NEW
exit
EOF
SORT




NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="ENRICHISSEMENT DE IADPERICASE PAR ESF_FSEG_TSECIFRS_I17..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_IADPERICASE_CLISSD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_SEG.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	FILLER        	1:1  	-  254:,
	CTR_NF      	1:1  	-  1:,
	END_NT      	2:1  	-  2:,
	SEC_NF      	3:1  	-  3:,
	UWY_NF      	4:1  	-  4:,
	UW_NT       	5:1  	-  5:,
	IFRSSEG_CT		6:1  	-  6:
/JOINKEYS
	PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF,
	PER_UW_NT
/INFILE ${DFILT}/${NJOB}_17_${IB}_SEG_TSECIFRS_I17.dat 2000 1 "~"
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
	RIGHTSIDE:IFRSSEG_CT
exit
EOF
SORT

NSTEP=${NJOB}_26
#-----------------------------------------------------------------
LIBEL="ENRICHISSEMENT DE IADPERICASE PAR RATIO Q ESF_RATIO_TEXPRAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_IADPERICASE_SEG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_RAT_Q.dat 2000 1"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	PER_SSD_CF      1:1    	-  1:,
	PER_ACCESB_C  	8:1    	-  8:,
	PER_CTRNAT_CT	85:1   	-  85:,
	IFRSSEG_CT		255:1  	-  255:,
	FILLER      	1:1    	-  255:,
	SSD_CF   		1:1    	-  1:,
	ESB_CF       	2:1    	-  2:,
	SEG_NF      	3:1    	-  3:,
	CTRNAT_CT     	5:1    	-  5:,
	ACQ_RATIO    	6:1    	-  6:
/JOINKEYS
	PER_SSD_CF,
	PER_ACCESB_C,
	PER_CTRNAT_CT,
	IFRSSEG_CT
/INFILE ${ESF_RATIO_TEXPRAT} 2000 1 "~"
/JOINKEYS
	SSD_CF,
	ESB_CF,
	CTRNAT_CT,
	SEG_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:ACQ_RATIO
exit
EOF
SORT

NSTEP=${NJOB}_60
LIBEL="RETRIEVE FUTURE PREMIUM CURRENT PERIOD : CSF/PRACC/1051"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_GTSII_GLOBAL_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CASHFLOW_ASSUMED.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	PATCAT_CT		52:1 	- 52:,
	PATTYP_CT		53:1 	- 53:,
	ACMTRS3			124:1 	- 124:,
	FILLER        	1:1  	- 124:        
/CONDITION ASSUMED PATCAT_CT CT "CSF" AND PATTYP_CT = "PRACC" AND ACMTRS3 = "1051" 																				
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE ASSUMED
/COPY 
exit
EOF
SORT

NSTEP=${NJOB}_70
LIBEL="SORT ASSUMED CASHFLOW FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_CASHFLOW_ASSUMED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_ASSUMED.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:EN,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:EN,
	FILLER        	1:1  	- 124:        
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="EXPENSES PREPARATION : SORT OF IADPERICASE_ENRICHI..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_26_${IB}_IADPERICASE_RAT_Q.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF      3:1 -  3:,
	END_NT      4:1 -  4:EN,
	SEC_NF      5:1 -  5:EN,
	UWY_NF      6:1 -  6:,
	UW_NT       7:1 -  7:EN
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_100
#-------------------------------------------------------------------------------------
LIBEL="EXPENSES CALCULATIONS : ACQUISITION EXPENSES, REMAINING ACQUISITION EXPENSES..." 
PRG=ESFC3670
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME ${NORME_CF}
CLODAT_D ${PARM_ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_CASHFLOW_ASSUMED.dat
export ${PRG}_O1=${ESF_EXPENSES}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ACQUISITION_EXPENSES_ANO.dat             	                   
EXECPRG

#[005]
NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="EXTEND EST_FBOPRSLNK_TXT with ACMTRS_NT and PARM1 of ESF_FPRSMAP_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	ACMTRSL3_NT    	5:1 	- 5:,
	DETTRS_CF       9:1 	- 9:,
	PRS_CF          1:1  	- 1:,
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
	RIGHTSIDE:ACMTRS_NT,
	RIGHTSIDE:PARM1
exit
EOF
SORT

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="SORT of IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM1004_IADPERICASE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF   	3:1 	-  3:,
	END_NT    	4:1 	-  4:,
	SEC_NF    	5:1 	-  5:EN,
	UWY_NF    	6:1 	-  6:,
	UW_NT     	7:1 	-  7:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="FORMAT EXPENSES FILE for ESTC1051A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EXPENSES} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EXPENSES_GTAAR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD2_CF		6:1 	- 6:7,
	CTR_NF          8:1 	- 8:,
	END_NT          9:1 	- 9:,
	SEC_NF          10:1 	- 10:EN,
	UWY_NF          11:1 	- 11:,
	UW_NT           12:1 	- 12:,
	RETCTR_NF       24:1 	- 24:,
	RETEND_NT       25:1 	- 25:EN,
	RETSEC_NF       26:1 	- 26:EN,
	RTY_NF          27:1 	- 27:,
	RETUW_NT        28:1 	- 28:EN,
	PLC_NT          36:1 	- 36:,
	FILLER			1:1  	- 41:
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
/DERIVEDFIELD ORICOD_LS "${NORME_CF}GTA" 
/DERIVEDFIELD 16_CHAMPS "~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT 	
	FILLER,
	16_CHAMPS,
	ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_150
#----------------------------------------------------------------------------------
LIBEL="EXTEND GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_GTA_CASHFLOW_EXPENSES.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	FBOPRSLNK_DETTRS_CF	9:1 	- 9:,
	DETTRS_CF        	6:1 	- 6:,
	ACMTRSL2_NT     	4:1 	- 4:,
	ACMTRSL3_NT     	5:1 	- 5:,
	TRNTYP_CT      		14:1 	- 14:,
	ACMTRS_NT          	15:1 	- 15:,
	PARM1              	16:1 	- 16:,
	FILLER           	1:1  	- 57:
/JOINKEYS
	FBOPRSLNK_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_140_${IB}_SORT_EXPENSES_GTAAR.dat 2000 1 "~"
/JOINKEYS
	DETTRS_CF
/JOIN UNPAIRED RIGHTSIDE
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:FILLER,
	LEFTSIDE:ACMTRSL3_NT,
	LEFTSIDE:ACMTRSL2_NT,
	LEFTSIDE:ACMTRSL3_NT,
	LEFTSIDE:TRNTYP_CT,
	LEFTSIDE:ACMTRS_NT,
	LEFTSIDE:PARM1
exit
EOF
SORT

NSTEP=${NJOB}_155
#-----------------------------------------------------------------------------
LIBEL="FORMAT EXPENSES file for ESTC1051A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_GTA_CASHFLOW_EXPENSES.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EXPENSES_GTA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF            8:1 -  8:,
	END_NT            9:1 -  9:,
	SEC_NF           10:1 - 10:EN,
	UWY_NF           11:1 - 11:,
	UW_NT            12:1 - 12:,
	RETCTR_NF        24:1 - 24:,
	RETEND_NT        25:1 - 25:EN,
	RETSEC_NF        26:1 - 26:EN,
	RTY_NF           27:1 - 27:,
	RETUW_NT         28:1 - 28:EN,
	PLC_NT           36:1 - 36:
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
exit
EOF
SORT

NSTEP=${NJOB}_160
#---------------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 ACCEPT ADD COLS DATA TO GT FORMAT ACMTRS/LOB/CUR + CONVERSION"
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET_CT A
BALSHTYEA_NF ${PARM_BLCSHTYEA_NF}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_155_${IB}_SORT_EXPENSES_GTA.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${ESF_GTESTCUMUL_ACCRET_NOT_TRN}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG
 
NSTEP=${NJOB}_161
#-----------------------------------------------------------------------------
LIBEL="TRANSITION PURPOSE : ADD REFERENCE QUARTER TO SEG_NF GT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTESTCUMUL_ACCRET_NOT_TRN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          8:1  	-  8:,
	END_NT          9:1  	-  9:,
	SEC_NF          10:1  	-  10:,
	UWY_NF          11:1  	-  11:,
	UW_NT           12:1  	-  12:,
	FILLER        	1:1  	-  63:,
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
/INFILE ${EPO_IADPERICASE_TRN} 2000 1 "~"
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

NSTEP=${NJOB}_162
#-----------------------------------------------------------------------------
LIBEL="CONCATENATE SEG_NF && UWY + REFERENCE QUARTER "
AWK_I="${DFILT}/${NJOB}_161_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat"
AWK_O="${ESF_GTESTCUMUL_ACCRET_TRN}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS ="\~" }
	{ for( i=1;i<=50;i++ ){ printf "%s", \$i "~" };{ print \$46 \$64 \$11 "~" \$52 "~" \$53 "~" \$54 "~" \$55 "~" \$56 "~" \$57 "~" \$58 "~" \$59 "~" \$60 "~" \$61 "~" \$62 "~" \$63 } }
exit
EOF
AWK

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
LIBEL="FORMAT EXPENSES FILE for ESTC1056A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTESTCUMUL_ACCRET} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EXPENSES_GTAAR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF           1:1 -  1:EN,
	CTR_NF           8:1 -  8:,
	END_NT           9:1 -  9:EN,
	SEC_NF          10:1 - 10:EN,
	UWY_NF          11:1 - 11:,
	UW_NT           12:1 - 12:EN,
	RETCTR_NF       24:1 - 24:,
	RETEND_NT       25:1 - 25:EN,
	RETSEC_NF       26:1 - 26:EN,
	RTY_NF          27:1 - 27:,
	RETUW_NT        28:1 - 28:EN,
	PLC_NT          36:1 - 36:,
	RTO_NF          37:1 - 37:,
	ACMTRS_NT       42:1 - 42:,
	ACMCUR_CF       44:1 - 44:,
	TYP_CT          49:1 - 49:,
	ACMTRS3_NT     	52:1 - 52:,
	FILLER			1:1  - 52:
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
/REFORMAT FILLER
exit
EOF
SORT

if [ ${PARM_IS_TRN} == 'YES' ]
then
	CONTEXT_CT=TRN
fi

#[016] ADD I3  
PATTERN_CATEGORY="CSF  "
NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="CSF CALCULATION PRACC"
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
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_SORT_EXPENSES_GTAAR.dat
export ${PRG}_I2=${EST_FSEGPATTERN_CSF}
export ${PRG}_I3=${EST_IADPERICASE_STD}
export ${PRG}_I4=${EST_IRDPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056A_CASHFLOW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056A_REMAINTOPAY_ULAE.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
EXECPRG

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="ADD NORME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_180_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_ACQ_EXPENSES_ASSUMED_INI.dat 2000 1"
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
/DERIVEDFIELD NORME_CF if NORME_I then "${NORME_CF}" else if NORME_K then "I17P" else if NORME_M then "I17L" else "I17G"
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

NSTEP=${NJOB}_200
LIBEL="MERGE ALL CASHFLOW files CALCULATED WITH GLOBAL_CASHFLOW FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_190_${IB}_ACQ_EXPENSES_ASSUMED_INI.dat 2000 1"
SORT_I2="${EST_CSF_NDIC_AMOUNT} 2000 1"
SORT_I3="${ESF_GTSII_ONE_STD} 2000 1"
SORT_I4="${ESF_GTSII_DUMMY_STD} 2000 1"
SORT_I5="${ESF_GTSII_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_GLOBAL_CASHFLOW.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF  8:1 -  8:,
        FILLER_1  1:1 - 7:,
        FILLER_2  9:1 - 124:,
        FILLER  1:1 - 124:
/DERIVEDFIELD CTR_NFC CTR_NF COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER_1,CTR_NFC,FILLER_2
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_210
LIBEL="REFORMAT GLOBAL_CASHFLOW FILES"
AWK_I="${DFILT}/${NJOB}_200_${IB}_GTSII_GLOBAL_CASHFLOW.dat"
AWK_O="${ESF_GTSII_GLOBAL_CASHFLOW}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if ( \$8 == "")
    {
        \$8 = "";
        \$9 = "";
        \$10 = "";
        \$11 = "";
        \$12 = "";
    }

    print \$0; 
  }
exit
EOF
echo ${AWK_CMD}
cat ${AWK_CMD}
AWK

JOBEND
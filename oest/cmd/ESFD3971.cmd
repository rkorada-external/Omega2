#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3971.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20\10\2020
# auteur                        : Charles SOCIE
#-----------------------------------------------------------------------------
# description
#  NDIC Cashflow calculation
#
#-----------------------------------------------------------------------------
#   [001]        10/01/2022 MZM  	SPIRA : 91532  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#		[002]		 		07/07/2022  JBD		Spira : 104778  Build new closing for I17S norm
#   [003]       12/07/2022  MZM  	SPIRA : 104857 NDIC - IO for retro T&C
#   [004]       18/10/2022  DAD  	SPIRA : 107323 NDIC cash flow - remove filter applied on internal assumed contracts
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

TRIM_NF=`echo ${PARM_ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`

export ICLODAT_YEAR=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,1,4)}'` 

if [ ${PARM_IS_TRN} = "YES" ]
then 
	CONTEXT_CT=TRN
fi

ECHO_LOG ""                                                                                  
ECHO_LOG "#========================================================================="   
ECHO_LOG "#===> TYPEINV ............................: ${TYPEINV}"                                                                  
if [ ${NORME_CF} = "EBS" ] 
then
	NORME_CF_TO_USE="I17G"
else
	NORME_CF_TO_USE="${NORME_CF}"
fi

ECHO_LOG "#===> NORME_CF ...........................: ${NORME_CF}"                                                                                                                         
ECHO_LOG "#===> PARM_ICLODAT_D .....................: ${PARM_ICLODAT_D}" 
ECHO_LOG "#===> PARM_BLCSHTYEA_NF ..................: ${PARM_BLCSHTYEA_NF}" 
ECHO_LOG "#===> CONTEXT_CT .........................: ${CONTEXT_CT}"
ECHO_LOG "#===> PARM_IS_TRN ........................: ${PARM_IS_TRN}" 
ECHO_LOG "#....................... INPUT ..........................................."              
ECHO_LOG "#===> EST_FBOPRSLNK_TXT ..................: ${EST_FBOPRSLNK_TXT}"                  
ECHO_LOG "#===> EPO_IADPERICASE ....................: ${EPO_IADPERICASE}"                                                 
ECHO_LOG "#===> EST_FSEGPATTERN_CSF ................: ${EST_FSEGPATTERN_CSF}"
ECHO_LOG "#===> EPO_FCTRGRO ........................: ${EPO_FCTRGRO}"
ECHO_LOG "#===> ESF_FPRSMAP_TXT ....................: ${ESF_FPRSMAP_TXT}"
ECHO_LOG "#===> EST_IADPERICASE_STD ................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_ACC_NDIC_AMOUNT ................: ${EST_ACC_NDIC_AMOUNT}"
ECHO_LOG "#===> EST_ACC_NDIC_RETRO_AMOUNT ..........: ${EST_ACC_NDIC_RETRO_AMOUNT}" 
ECHO_LOG "#===> EST_FCURQUOT_TXT ...................: ${EST_FCURQUOT_TXT}"  
ECHO_LOG "#===> EST_IRDPERICASE0 ...................: ${EST_IRDPERICASE0}" 
ECHO_LOG "#===> ESF_IRDPERICASE_NP .................: ${ESF_IRDPERICASE_NP}"                         
ECHO_LOG "#===> ESF_IADVPERICASE_P .................: ${ESF_IADVPERICASE_P}" 
ECHO_LOG "#===> ESF_DLREGTAR .......................: ${ESF_DLREGTAR}"                          
ECHO_LOG "#....................... OUTPUT ..........................................."  
ECHO_LOG "#===> NDIC_CASHFLOW ......................: ${NDIC_CASHFLOW}"               
ECHO_LOG "#========================================================================="  


if [ ! -s ${EST_ACC_NDIC_AMOUNT} ]
then
NSTEP=${NJOB}_00A
#------------------------------------------------------------------------------
LIBEL="touch ${EST_ACC_NDIC_AMOUNT}"
EXECKSH "touch ${EST_ACC_NDIC_AMOUNT}"

fi


if [ ! -s ${EST_ACC_NDIC_RETRO_AMOUNT} ]
then
NSTEP=${NJOB}_00B
#------------------------------------------------------------------------------
LIBEL="touch ${EST_ACC_NDIC_RETRO_AMOUNT}"
EXECKSH "touch ${EST_ACC_NDIC_RETRO_AMOUNT}"

fi

if [ ! -s ${ESF_DLREGTAR} ]
then
NSTEP=${NJOB}_00C
#------------------------------------------------------------------------------
LIBEL="touch ${ESF_DLREGTAR}"
EXECKSH "touch ${ESF_DLREGTAR}"

fi

## [003] Prise en compte des AI RETRO

NSTEP=${NJOB}_05
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge A and R files and add columns"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_ACC_NDIC_AMOUNT}
SORT_I2=${EST_ACC_NDIC_RETRO_AMOUNT}
SORT_I3=${ESF_DLREGTAR}
SORT_O=${DFILT}/${NSTEP}_${IB}_MERGE_NDIC_FILE.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	BALSHEY_NF		3:1 - 3:,
	BALSHRMTH_NF	4:1 - 4:,
	BALSHRDAY_NF	5:1 - 5:,
	TRNCOD_CF		6:1 - 6:,
	DBLTRNCOD_CF	7:1 - 7:,
	CTR_NF			8:1 - 8:,
	END_DT			9:1 - 9:,
	SEC_NF			10:1 - 10:,
	UWY_NF			11:1 - 11:,
	UW_NT			12:1 - 12:,
	OCCYEA_NF		13:1 - 13:,
	ACY_NF			14:1 - 14:,
	SCOSTRMTH_NF	15:1 - 15:,
	SCOENDMTH_NF	16:1 - 16:,
	CLM_NF			17:1 - 17:,
	CUR_CF			18:1 - 18:,
	AMT_M			19:1 - 19:,
	CED_NF			20:1 - 20:,
	BRK_NF			21:1 - 21:,
	PAY_NF			22:1 - 22:,
	KEY_NF			23:1 - 23:,
	RETCTR_NF		24:1 - 24:,
	RETEND_NT		25:1 - 25:,
	RETSEC_NF		26:1 - 26:,
	RTY_NF			27:1 - 27:,
	RETUW_NT		28:1 - 28:,
	RETOCCYEA_NF	29:1 - 29:,
	RETACY_NF		30:1 - 30:,
	RETSCOSTRMTH_NF	31:1 - 31:,
	RETSCOENDMTH_NF	32:1 - 32:,
	RCL_NF			33:1 - 33:,
	RETCUR_CF		34:1 - 34:,
	RETAMT_M		35:1 - 35:,
	PLC_NT			36:1 - 36:,
	RTO_NF			37:1 - 37:,
	INT_NF			38:1 - 38:,
	RETPAY_NF		39:1 - 39:,
	RETKEY_CF		40:1 - 40:,
	RETINTAMT_M		41:1 - 41:,
	FILLER			1:1 - 41:
/DERIVEDFIELD CHAIN1_VIDE 1"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER
     ,CHAIN1_VIDE
exit
EOF
SORT


NSTEP=${NJOB}_10
#Comparison of period closing and segmentation perimeters
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into Pericase"
PRG=ESTM1004
export ${PRG}_I1=${EPO_IADPERICASE}
export ${PRG}_I2=${EPO_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG


NSTEP=${NJOB}_15
# Extend EST_FBOPRSLNK_TXT with ACMTRS_NT and PARM1 of ESF_FPRSMAP_TXT
#-----------------------------------------------------------------------------
LIBEL="Extend EST_FBOPRSLNK_TXT with ACMTRS_NT and PARM1 of ESF_FPRSMAP_TXT"
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

#   [004]
NSTEP=${NJOB}_20
# Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE"
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
	UW_NT     	7:1 	-  7:,
	CTRRET_B   20:1		- 20:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Format EXPENSES file for ESTC1051A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_MERGE_NDIC_FILE.dat
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
/DERIVEDFIELD ORICOD_LS "${NORME_CF_TO_USE}GTA" 
/DERIVEDFIELD 16_CHAMPS "~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT 	
	FILLER,
	16_CHAMPS,
	ORICOD_LS
exit
EOF
SORT


NSTEP=${NJOB}_30
# Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT
#---------------------------------------------------------------------------
LIBEL="Extend GTAAR with ACMTRSL2_NT, ACMTRSL3_NT, TRNTYP_CT  of EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_FBOPRSLNK_FPRSMAP.dat 2000 1 "
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
/INFILE ${DFILT}/${NJOB}_25_${IB}_SORT_EXPENSES_GTAAR.dat 2000 1 "~"
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


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Format EXPENSES file for ESTC1051A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_GTA_CASHFLOW_EXPENSES.dat 2000 1"
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


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 ACCEPT Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET_CT A
BALSHTYEA_NF ${PARM_BLCSHTYEA_NF}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_35_${IB}_SORT_EXPENSES_GTA.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_CSF_AGREGATES_ESTC1051_A.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG



NSTEP=${NJOB}_44
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into RETRO_P Pericase"
PRG=ESTM1004
export ${PRG}_I1=${ESF_IADVPERICASE_P}
export ${PRG}_I2=${EPO_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADVPERICASEP.dat
EXECPRG

NSTEP=${NJOB}_45
touch ${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDPERICASE IRDPERICASE_NP IADVPERICASE_P "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 2000 1"
SORT_I2="${ESF_IRDPERICASE_NP} 2000 1"
SORT_I3="${DFILT}/${NJOB}_44_${IB}_${PRG}_IADVPERICASEP.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 SORT OF retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_CSF_AGREGATES_ESTC1051_A.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
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
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
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
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "") OR TYP_CT != "A" 
/OUTFILE ${SORT_O}
/INCLUDE LOB
exit
EOF
SORT


NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 RETROCESSION Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${PARM_BLCSHTYEA_NF}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_IRDPERICASE_O.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_I3=${EST_FCURQUOT_TXT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat # Sortie Accept ou retro selon valeur ACCRET
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG

if [ ${CONTEXT_CT} = "TRN" ]
then 

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="TRANSITION PURPOSE : ADD REFERENCE QUARTER TO SEG_NF GT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat 2000 1"
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
/INFILE ${EST_IADPERICASE_STD} 2000 1 "~"
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

NSTEP=${NJOB}_61
LIBEL="CONCATENATE SEG_NF && UWY + REFERENCE QUARTER "
AWK_I="${DFILT}/${NJOB}_60_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS ="\~" }
		{ for( i=1;i<=50;i++ ){ printf "%s", \$i "~" };{ print \$46 \$64 \$11 "~" \$52 "~" \$53 "~" \$54 "~" \$55 "~" \$56 "~" \$57 "~" \$58 "~" \$59 "~" \$60 "~" \$61 "~" \$62 "~" \$63 } }
exit
EOF
AWK

NSTEP=${NJOB}_62
#------------------------------------------------------------------------------
LIBEL="delete duplicate"
sort -u ${DFILT}/${NJOB}_61_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat > ${DFILT}/${NSTEP}_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat

else 

NSTEP=${NJOB}_62B
#------------------------------------------------------------------------------
LIBEL="delete duplicate"
sort -u ${DFILT}/${NJOB}_55_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat > ${DFILT}/${NJOB}_62_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat

fi


PATTERN_CATEGORY="CSF  "
NSTEP=${NJOB}_65
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
export ${PRG}_I1=${DFILT}/${NJOB}_62_${IB}_ESTC1051A_GTESTCUMUL_ACCRET.dat
export ${PRG}_I2=${EST_FSEGPATTERN_CSF}
export ${PRG}_I3=${EST_IADPERICASE_STD}
export ${PRG}_I4=${EST_IRDPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056A_CASHFLOW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056A_REMAINTOPAY_ULAE.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
EXECPRG

if [ ${NORME_CF} = "EBS" ]
then 

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="ADD NORME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_65_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O=${NDIC_CASHFLOW}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	FILLER1 	1:1  	- 41:,
	ACMTRS_MC	42:1	- 42:,
	FILLER2		43:1	- 49:,
	ACMAMT_MC	43:1	- 43:EN 15/3,
	PRS_CF      45:1 	- 45:,
	NORME		6:8  	- 6:8,
	FILLER3		50:1 	- 124:
/CONDITION AMNT_NOT_NULL ACMAMT_MC != 0	
/CONDITION ACMTRS221 PRS_CF = "751"
/DERIVEDFIELD NORME_CF "ALLNO"
/DERIVEDFIELD ACMTRS_MT if ACMTRS221 then "221" else ACMTRS_MC
/INCLUDE AMNT_NOT_NULL
/OUTFILE ${SORT_O}
/REFORMAT 
	FILLER1,
	ACMTRS_MT,
	FILLER2,
	NORME_CF,
	FILLER3
/COPY	
exit
EOF
SORT

else

NSTEP=${NJOB}_70B
#-----------------------------------------------------------------------------
LIBEL="ADD NORME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_65_${IB}_ESTC1056A_CASHFLOW.dat 2000 1"
SORT_O=${NDIC_CASHFLOW}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	FILLER1 	1:1  	- 41:,
	ACMTRS_MC	42:1	- 42:,
	FILLER2		43:1	- 49:,
	ACMAMT_MC	43:1	- 43:EN 15/3,
	PRS_CF      45:1 	- 45:,
	NORME		6:8  	- 6:8,
	FILLER3		50:1 	- 124:
/CONDITION AMNT_NOT_NULL ACMAMT_MC != 0	
/CONDITION ACMTRS221 PRS_CF = "751"
/CONDITION NORME_I NORME = "I"
/CONDITION NORME_K NORME = "K"
/CONDITION NORME_M NORME = "M"
/DERIVEDFIELD NORME_CF if NORME_I then "${NORME_CF}" else if NORME_K then "I17P" else if NORME_M then "I17L" else "I17G"
/DERIVEDFIELD ACMTRS_MT if ACMTRS221 then "221" else ACMTRS_MC
/INCLUDE AMNT_NOT_NULL
/OUTFILE ${SORT_O}
/REFORMAT 
	FILLER1,
	ACMTRS_MT,
	FILLER2,
	NORME_CF,
	FILLER3
/COPY	
exit
EOF
SORT

fi


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

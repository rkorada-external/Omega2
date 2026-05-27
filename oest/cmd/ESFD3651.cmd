#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 12.1
# nom du script SHELL           : ESFD3651.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10/04/2019
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
# REQ 12.01 - IFRS17- Closing schedule : Risk Adjustment 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 10/04/2019 JYP : Spira 70377 : Creation 
#[002] 08/07/2019 JYP : Spira 70377 : add file FMARKET that contains field GRPGRP3_NT
#[003] 13/08/2019 JYP : Spira 70377 : bugfix GRPGRP3_NT
#[004] 21/08/2019 JYP : Spira 70377 : rename mappings
#[005] 26/08/2019 JYP : spira 70377 : add EPO_FCTRGRO
#[006] 27/08/2019 JYP : spira 70377 : bugfix filter SII ESCOMPTE file with 301/320
#[007] 28/08/2019 JYP : spira 70377 : filter RARAT on NORME_CF
#[008] 08/10/2019 JYP : spira 70377 : bugfix sort ESF_FRARAT
#[009] 25/10/2019 LEL : spira 81978 : bugfix make calculation steps for total amount
#[010] 30/10/2019 JYP : spira 81988 : bugfix sort GTSII input file
#[011] 31/10/2019 JYP : spira 81988 : bugfix RETRO case
#[012] 19/02/2020 JYP : spira 82575 : longer records to accept
#[013] 25/02/2020 JYP : spira 79070 : req 11.7.2: retroP retroNP at inception
#[014] 31/03/2020 JYP : spira 79070 : retroP at inception / use EBS PERICASE retroP
#[015] 01/07/2020 JYP : spira 87296 : retroP pattern not applied
#[016] 02/07/2020 JYP : spira 87296 : retroP bugfix ratio SSD
#[017] 04/08/2020 JYP : spira 88234 : use grouping 751 3201 3010
#[018] 11/08/2020 JYP : spira 87296 : retroP bugfix CTRGRO SEG_NF
#[019] 22/09/2020 JYP : spira 89815 : bugfix sort sec > 10 to match with CTRGRO
#[020] 23/03/2021 JYP : spira 94626 : bugfix retro keys
#[021] 14/05/2021 JYP : spira 94976 : transition specific lob for retroNP
#[022] 20/05/2021 JYP : spira 96349 : transition specific lob+refquarter for retroNP
#[023] 30/06/2021 JYP : spira 96654 : retroNP total amount issue
#[024] 30/06/2021 JYP : spira 97016 : retroNP some RAD missing 
#[024] 10/01/2022 MZM  	SPIRA : 91532  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#[025] 28/03/2022 DaD  	SPIRA : 102222  Bug Fix : Enrichment NAT_CT of PERICASE (Retro P & NP)
#[026] 15/10/2025 M.NAJI  US59  US6929  remove SSDs filter in step 30 
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


# Parameters
IDF_CT=$1

# level for ESFC3650.log : 0=default/minimum  1=medium  >=2 more detailled
if [ -z "$2" ]  
then 
	DEBUGLEVEL=0
else
	if let $2 2>/dev/null   # check numeric
	then 
		DEBUGLEVEL=$2
	else
		DEBUGLEVEL=0
	fi 
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> DEBUGLEVEL (ESFC3650.log)..: ${DEBUGLEVEL} (0=default/minimum  1=medium  >=2 more detailled) "
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D"
ECHO_LOG "#===> PARM_IS_TRN ...............: $PARM_IS_TRN "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_FRARAT ................: $ESF_FRARAT   "
ECHO_LOG "#===> ESF_FMARKET ...............: $ESF_FMARKET   "
ECHO_LOG "#===> EPO_IADPERICASE ...........: $EPO_IADPERICASE   "
ECHO_LOG "#===> EPO_IRDPERICASE0 ..........: $EPO_IRDPERICASE0   "
ECHO_LOG "#===> ESF_IRDPERICASE_NP ........: $ESF_IRDPERICASE_NP "
ECHO_LOG "#===> ESF_IADVPERICASE_P ........: $ESF_IADVPERICASE_P  "
ECHO_LOG "#===> EPO_FSEGPATTERN_ICR .......: $EPO_FSEGPATTERN_ICR   "
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE ........: $ESF_GTSII_ESCOMPTE   "
ECHO_LOG "#===> EPO_FCTRGRO ...............: $EPO_FCTRGRO "
ECHO_LOG "#===> ESF_FUWRETSEC .............: $ESF_FUWRETSEC "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> ESF_GTSII_CASHFLOW .........: $ESF_GTSII_CASHFLOW "
ECHO_LOG "#===> ESF_GTSII_CASHFLOW_WK ......: $ESF_GTSII_CASHFLOW_WK"
ECHO_LOG "#===> ESF_TOTAL_CASHFLOW_WK ......: ${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat "

ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Filter PERICASE retroP retroNP $EPO_IRDPERICASE0 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IRDPERICASE0} 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_${IDF_CT}_IRDPERICASE0_P.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${IDF_CT}_IRDPERICASE0_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:EN,
        SEC_NF      5:1 -  5:EN,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN,
        CTRTYP_CT   188:1 - 188:,		
	    CTRNAT_CT   85:1 - 85:
/CONDITION COND_RETRONP CTRNAT_CT = "N" AND CTRTYP_CT = "RET"
/CONDITION COND_RETROP CTRNAT_CT = "P" AND CTRTYP_CT = "RET"
/OUTFILE ${SORT_O}
/INCLUDE COND_RETROP 
/OUTFILE ${SORT_O2}
/INCLUDE COND_RETRONP 
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


if [ "${CONTEXT_CT}" = "INI" ] # filter for closing at Inception only
then

NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Filter PERICASE retroNP Inception  "
EXECKSH_MODE=P
EXECKSH " >  ${DFILT}/${NJOB}_05_${IB}_${IDF_CT}_IRDPERICASE0_NP.dat "

fi
	



NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="RiskADJ PREPARATION : Sort assumed PERICASE for CTRGRO  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADPERICASE} 2000 1"                                           # Assumed
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF      1:1 - 1:EN,
		CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:,
        SEC_NF      5:1 -  5:,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN,
        PLC_NT 	    36:1 - 36:EN,
        CTRTYP_CT   188:1 - 188:,	
	    CTRNAT_CT   85:1 - 85:,
        RTO_NF 	    37:1 - 37:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_11
#-----------------------------------------------------------------------------
LIBEL="RiskADJ PREPARATION : merge and sort retro P+NP PERICASE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`                                     
SORT_I="${DFILT}/${NJOB}_05_${IB}_${IDF_CT}_IRDPERICASE0_NP.dat 2000 1"       # retroNP quaterly closing 
SORT_I2="${ESF_IRDPERICASE_NP} 2000 1"                                        # retroNP closing at inception
SORT_I3="${DFILT}/${NJOB}_05_${IB}_${IDF_CT}_IRDPERICASE0_P.dat 2000 1"       # retroP
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF      1:1 - 1:EN,
	    CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:EN,
        SEC_NF      5:1 -  5:EN,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN,
        CTRTYP_CT   188:1 - 188:,		
		CTRNAT_CT   85:1 - 85:
/KEYS   CTR_NF,
        UWY_NF,
        SEC_NF,
        END_NT,
        UW_NT
exit
EOF
SORT



NSTEP=${NJOB}_12
#Comparison of period closing and segmentation perimeters
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into IADPericase"
PRG=ESTM1004
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_${IDF_CT}.dat
export ${PRG}_I2=${EPO_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O_${IDF_CT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O_${IDF_CT}.dat
export ${PRG}_O3=${DFILT}/${NJOB}_12_${IB}_SORT_IADPERICASE_${IDF_CT}.dat
EXECPRG


NSTEP=${NJOB}_13
#-----------------------------------------------------------------------------
LIBEL="RiskADJ PREPARATION : Sort assumed PERICASE for ESFC3650  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_12_${IB}_SORT_IADPERICASE_${IDF_CT}.dat 2000 1"       
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF      1:1 - 1:EN,
		CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:EN,
        SEC_NF      5:1 -  5:EN,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN,
        PLC_NT 	    36:1 - 36:EN,
        CTRTYP_CT   188:1 - 188:,	
	    CTRNAT_CT   85:1 - 85:,
        RTO_NF 	    37:1 - 37:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT



NSTEP=${NJOB}_14
#----------------------------------------------------------------------------
LIBEL="Merge of PERICASE Assumed and Retro : keeping each sort "
EXECKSH_MODE=P
EXECKSH "cat ${DFILT}/${NJOB}_13_${IB}_SORT_IADPERICASE_${IDF_CT}.dat ${DFILT}/${NJOB}_11_${IB}_SORT_IRDPERICASE_${IDF_CT}.dat  >> ${DFILT}/${NJOB}_14_${IB}_SORT_ALLPERICASE_${IDF_CT}.dat"




NSTEP=${NJOB}_18
#---------------------------------------------------------------BEGIN SORT
LIBEL="ENRICHISSEMENT du Discount Input file ESF_GTSII_ESCOMPTE avec ESF_MARKET "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$ESF_GTSII_ESCOMPTE 2000 1"
SORT_O="$DFILT/${NJOB}_18_${IB}_GTSII_MARKET_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF          8:1 -  8:,
        GT_END_NT          9:1 -  9:,
        GT_SEC_NF         10:1 - 10:,
        GT_UWY_NF         11:1 - 11:,
        GT_UW_NT          12:1 - 12:,
        ALL_COLS        1:1     -  124:,
        CTR_NF          1:1     -  1:,
        END_NT          2:1     -  2:,
        SEC_NF          3:1     -  3:,
        UWY_NF          4:1     -  4:,
        UW_NT           5:1     -  5:,
        GRPGRP3_NT      10:1    -  10:
/joinkeys
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT
/INFILE $ESF_FMARKET 2000 1 "~"
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:GRPGRP3_NT
exit
EOF
SORT


NSTEP=${NJOB}_19
#---------------------------------------------------------------
LIBEL="ENRICHISSEMENT du Discount Input file ESF_GTSII_ESCOMPTE avec CTRGRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_18_${IB}_GTSII_MARKET_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_19_${IB}_GTSII_MARKET_SEGNF_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF          8:1 -  8:,
        GT_END_NT          9:1 -  9:,
        GT_SEC_NF         10:1 - 10:,
        GT_UWY_NF         11:1 - 11:,
        GT_UW_NT          12:1 - 12:,
        ALL_COLS        1:1     -  125:,
        CTR_NF          1:1     -  1:,
        END_NT          2:1     -  2:,
        SEC_NF          3:1     -  3:,
        SEG_NF          7:1     -  7:,
        UWY_NF          21:1    -  21:
/joinkeys
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
		GT_UWY_NF
/INFILE ${EPO_FCTRGRO} 2000 1 "~"
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
		UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:SEG_NF
exit
EOF
SORT


NSTEP=${NJOB}_19B
#---------------------------------------------------------------
LIBEL="ENRICHISSEMENT du Discount Input file ESF_GTSII_ESCOMPTE  Assumed data (for retroP) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_19_${IB}_GTSII_MARKET_SEGNF_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_19B_${IB}_GTSII_ENRICHI_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
     GT_CTR_NF     8:1 -  8:,
     GT_END_NT     9:1 -  9:,
     GT_SEC_NF     10:1 - 10:,
     GT_UWY_NF     11:1 - 11:,
     GT_UW_NT      12:1 - 12:,
     ALL_COLS      1:1 -  126:,
	 PER_SSD_CF    1:1 -  1:,
     PER_CTR_NF    3:1 -  3:,
     PER_END_NT    4:1 -  4:,
     PER_SEC_NF    5:1 -  5:,
     PER_UWY_NF    6:1 -  6:,
     PER_UW_NT     7:1 -  7:,
     PER_CTRNAT_CT 85:1 -  85:
/joinkeys
     GT_CTR_NF,
     GT_END_NT,
     GT_SEC_NF,
     GT_UWY_NF,
     GT_UW_NT 
/INFILE ${EPO_IADPERICASE} 2000 1 "~"
/joinkeys
     PER_CTR_NF,
     PER_END_NT,
     PER_SEC_NF,
     PER_UWY_NF,
     PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:PER_CTRNAT_CT,PER_SSD_CF
exit
EOF
SORT


#[025]
NSTEP=${NJOB}_19C
#---------------------------------------------------------------
LIBEL="Enrichment NAT_CT of PERICASE for GTSII (Retro P & NP)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_19B_${IB}_GTSII_ENRICHI_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_19C_${IB}_GTSII_ENRICHI_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
     RET_CTR_NF     24:1 -  24:,
     RET_END_NT     25:1 -  25:,
     RET_SEC_NF     26:1 - 26:,
     RET_UWY_NF     27:1 - 27:,
     RET_UW_NT      28:1 - 28:,
     ALL_COLS      1:1 -  128:,
     PER_CTR_NF    3:1 -  3:,
     PER_END_NT    4:1 -  4:,
     PER_SEC_NF    5:1 -  5:,
     PER_UWY_NF    6:1 -  6:,
     PER_UW_NT     7:1 -  7:,
     PER_CTRNAT_CT 85:1 -  85:
/joinkeys
     RET_CTR_NF,
     RET_END_NT,
     RET_SEC_NF,
     RET_UWY_NF,
     RET_UW_NT 
/INFILE ${DFILT}/${NJOB}_11_${IB}_SORT_IRDPERICASE_${IDF_CT}.dat 2000 1 "~"
/joinkeys
     PER_CTR_NF,
     PER_END_NT,
     PER_SEC_NF,
     PER_UWY_NF,
     PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:PER_CTRNAT_CT
exit
EOF
SORT


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="RiskADJ PREPARATION : split and sort of GTSII DISCOUNT FILE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_19C_${IB}_GTSII_ENRICHI_${IDF_CT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIA_${IDF_CT}.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIRP_${IDF_CT}.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIRNP_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF          8:1 -  8:,
        END_NT          9:1 -  9:EN,
        SEC_NF         10:1 - 10:EN,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:EN,
        RETCTR_NF      24:1 - 24:,
        PLC_NT         36:1 - 36:EN,
        RTO_NF         37:1 - 37:,
        NORME_CF       50:1 - 50:,
        PATCAT_CT      52:1 - 52:,
        PATTYP_CT      53:1 - 53:3,
        ACMTRS_NT      42:1 - 42:,
        CML_NAT_CF     48:1 - 48:,
        CML_TYP_CT     49:1 - 49:1,
        ACMTRS3_NT     124:1 - 124:1,
        CML_CTRNAT_CT  129:1 - 129:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_RA_INPUT_A   (ACMTRS3_NT = "3010" OR ACMTRS3_NT = "3201") AND CML_TYP_CT = "A" AND PATCAT_CT = "DSC" AND (PATTYP_CT = "DSI" OR PATTYP_CT = "LKI") AND NORME_CF = "${NORME_CF}" AND RETCTR_NF = ""
/CONDITION COND_RA_INPUT_RP  (ACMTRS3_NT = "3010" OR ACMTRS3_NT = "3201") AND CML_TYP_CT = "R" AND PATCAT_CT = "DSC" AND (PATTYP_CT = "DSI" OR PATTYP_CT = "LKI") AND NORME_CF = "${NORME_CF}" AND CTR_NF != "" AND RETCTR_NF != "" AND CML_CTRNAT_CT = "P"
/CONDITION COND_RA_INPUTR_NP (ACMTRS3_NT = "3010" OR ACMTRS3_NT = "3201") AND CML_TYP_CT = "R" AND PATCAT_CT = "DSC" AND (PATTYP_CT = "DSI" OR PATTYP_CT = "LKI") AND NORME_CF = "${NORME_CF}" AND RETCTR_NF != "" AND CML_CTRNAT_CT = "N"
/OUTFILE ${SORT_O}
/INCLUDE COND_RA_INPUT_A  
/OUTFILE ${SORT_O2}
/INCLUDE COND_RA_INPUT_RP  
/OUTFILE ${SORT_O3}
/INCLUDE COND_RA_INPUTR_NP  
exit
EOF
SORT



NSTEP=${NJOB}_23
#-----------------------------------------------------------------------------
LIBEL="Sort GTSII Assumed File "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTSIIA_${IDF_CT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIA_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF          8:1 -  8:,
        END_NT          9:1 -  9:EN,
        SEC_NF         10:1 - 10:EN,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_24
#-----------------------------------------------------------------------------
LIBEL="Sort GTSII RetroP File "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTSIIRP_${IDF_CT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIRP_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
		CML_NAT_CF       48:1 - 48:,
        CML_TYP_CT       49:1 - 49:1	
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        RETEND_NT,
        RETUW_NT,
		PLC_NT,
		RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Sort GTSII RetroNP File "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTSIIRNP_${IDF_CT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSIIRNP_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
		CML_NAT_CF       48:1 - 48:,
        CML_TYP_CT       49:1 - 49:1	
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        RETEND_NT,
        RETUW_NT,
		PLC_NT,
		RTO_NF
exit
EOF
SORT




NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Filter RATIOS file with SSD_CF : ${EST_SORT_CONDITION}  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FRARAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FRARAT_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 		1:1 - 1: EN,
        ESB_CF 		2:1 - 2: EN,
        SEG_NF 		3:1 - 3: ,
        NORME_CF	4:1 - 4: ,
        CTRNAT_CT 	5:1 - 5: ,
        DOMAIN_CF 	6:1 - 6: ,
        SGMT_LS   	9:1 - 9:
/KEYS   SSD_CF,
        ESB_CF,
        SGMT_LS,
        CTRNAT_CT,
        DOMAIN_CF
/CONDITION INVENTAIRE  NORME_CF = "${NORME_CF}"
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O}
exit
EOF
SORT    


NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Risk Adjustement calculation " 
PRG=ESFC3650
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME ${NORME_CF}
PATCAT_CT ${PATCAT_CT}
PATTYP_CT ${PATTYP_CT}
CONTEXT_CT ${CONTEXT_CT}
ICLODAT_D ${PARM_ICLODAT_D}
DEBUG_LEVEL ${DEBUGLEVEL}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_14_${IB}_SORT_ALLPERICASE_${IDF_CT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_23_${IB}_SORT_GTSIIA_${IDF_CT}.dat
export ${PRG}_I3=${DFILT}/${NJOB}_30_${IB}_SORT_FRARAT_${IDF_CT}.dat
export ${PRG}_I5=${DFILT}/${NJOB}_25_${IB}_SORT_GTSIIRNP_${IDF_CT}.dat
export ${PRG}_I6=${ESF_FUWRETSEC}
export ${PRG}_I7=${DFILT}/${NJOB}_24_${IB}_SORT_GTSIIRP_${IDF_CT}.dat
export ${PRG}_O1=${ESF_GTSII_CASHFLOW_WK}
export ${PRG}_O2=${DFILT}/${NSTEP}_${PRG}_${IB}_${IDF_CT}.log
export ${PRG}_O3=${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat


ECHO_LOG ""
ECHO_LOG "#=========================================================================="
ECHO_LOG "PRG:$DEXE/ESFC3650.exe"
ECHO_LOG "ESFC3650_PRM=${FPRM}                                                          "
ECHO_LOG "ESFC3650_I1=${NJOB}_14_${IB}_SORT_ALLPERICASE_${IDF_CT}.dat"
ECHO_LOG "ESFC3650_I2=${NJOB}_23_${IB}_SORT_GTSIIA_${IDF_CT}.dat "
ECHO_LOG "ESFC3650_I3=${NJOB}_30_${IB}_SORT_FRARAT_${IDF_CT}.dat "
ECHO_LOG "ESFC3650_I5=${NJOB}_25_${IB}_SORT_GTSIIRNP_${IDF_CT}.dat "
ECHO_LOG "ESFC3650_I6=${ESF_FUWRETSEC} "
ECHO_LOG "ESFC3650_I7=${NJOB}_24_${IB}_SORT_GTSIIRP_${IDF_CT}.dat "
ECHO_LOG "ESFC3650_O1=${ESF_GTSII_CASHFLOW_WK}                       "
ECHO_LOG "ESFC3650_O2=${NSTEP}_${PRG}_${IB}_${IDF_CT}.log        "
ECHO_LOG "ESFC3650_O3=${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat"
ECHO_LOG "#=========================================================================="
EXECPRG


ECHO_LOG "#=== Nombre de lignes $ESF_GTSII_CASHFLOW_WK et ${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat "
wc -l $ESF_GTSII_CASHFLOW_WK
wc -l ${DFILI}/${ENV_PREFIX}_ESFD3650_${IDF_CT}_TOTAL_CASHFLOW_WK.dat



JOBEND
                     

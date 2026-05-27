#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Ventilation des S/P
# nom du script SHELL		: ESED0301.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 23/06/1997
# auteur			: CGI
# references des specifications	: ESTSEG06.doc
#-----------------------------------------------------------------------------
# description
#   Loss ratio or losses breakdown
#
# job launch by ESED0300.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01]  24/01/2003     J.Ribot    ajout colonne RETINTAMT_M  step35
# [02] 11/09/2018 MZM     :spira:70805 4Q2018 technical booking error on INT  - Ajout de la date en parametre dans le STEP 05 - Ajout de la date en parametre dans le STEP 05 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
SEGTYPULT_CT=$2
SSDULT_LL=$3
VRS_LL=$4

#Segmentation parameter
OPTION='S'

##############################
# Tables Download into files #
##############################

NSTEP=${NJOB}_05
#Loading subsidiaries list into BTRAV..TESTSSDTMP
#-----------------------------------------------------------------------------
LIBEL="Loading subsidiaries list into BTRAV..TESTSSDTMP"
#[02]ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDULT_LL}', '${SEGTYPULT_CT}'"
ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDULT_LL}', '${SEGTYPULT_CT}', '${CRE_D}'"
ISQL_BASE="BEST"
ISQL

NSTEP=${NJOB}_10
# TCTRGRO Table BEST..TCTRGRO download
#-----------------------------------------------------------------------------
LIBEL="Generation of FCTRGRO file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CTRGRO_O.dat
BCP_QRY="execute BEST..PsSECTION_10 '${OPTION}', '${SEGTYPULT_CT}'"
BCP

NSTEP=${NJOB}_15
# TCTRULT Table BEST..TCTRULT download
#-----------------------------------------------------------------------------
LIBEL="Generation of FCTRULT file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CTRULT_O.dat
BCP_QRY="execute BEST..PsCTRULT_01 '${OPTION}'"
BCP

NSTEP=${NJOB}_20
# TSEGEST Table BEST..TSEGEST download
#-----------------------------------------------------------------------------
LIBEL="Generation of FSEGEST file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_SEGEST_O.dat
BCP_QRY="execute BEST..PsSECTION_13 '${OPTION}', '${SEGTYPULT_CT}'"
BCP


###################################
# Preparing PERICASE and TSTATGTA #
###################################

NSTEP=${NJOB}_25
# Screen of SADPERICASE0
#-----------------------------------------------------------------------------
LIBEL="SADPERICASE0 ==> SADPERICASE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_SADPERICASE0} 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN, SEGTYP_CT 2:1 - 2:, CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT EQ "${SEGTYPULT_CT}"
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_30
# Screen of SADPERIFR0
#-----------------------------------------------------------------------------
LIBEL="SADPERIFR0 ==> SADPERIFR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_SADPERIFR0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIFR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 12:1 - 12:EN, CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:, SEGTYP_CT 11:1 - 11:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT EQ "${SEGTYPULT_CT}"
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_35
# Screen of ARCSTATGTA, STATGTA and GTA
#-----------------------------------------------------------------------------
LIBEL="EST_ARCTATGTA + EST_STATGTA + EST_GTA ==> EST_TSTATGTA..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_STATGTA} 1000 1"
SORT_I2="${EST_GTA} 1000 1"
SORT_I3="${EST_ARCSTATGTA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TSTATGTA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, ESB_CF 2:1 - 2:, BALSHEY_NF 3:1 - 3:, BALSHRMTH_NF 4:1 - 4:, BALSHRDAY_NF 5:1 - 5:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, AMT_M 19:1 - 19: EN 30/3, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, TRNCOD_CF, BALSHEY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/INCLUDE INVENTAIRE
/OUTFILE ${DFILT}/${NSTEP}_${IB}_SORT_TSTATGTA_O.dat
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_M
exit
EOF
SORT

############################
# Calculation of losses    #
############################

NSTEP=${NJOB}_40
# Introduction of accumulation transaction and conversion in EGPI currency
#------------------------------------------------------------------------------
LIBEL="Introduction of accumulation transaction and conversion in EGPI currency"
PRG=ESTC1023
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_35_${IB}_SORT_TSTATGTA_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTCUMUL_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SADPERICASE_O.dat
EXECPRG

NSTEP=${NJOB}_45
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_PERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_35_${IB}_SORT_TSTATGTA_O.dat

NSTEP=${NJOB}_50
#Sort of FGT file by Contract/Endorsement/UW Year/Sequence Number/Occurency Year
#-----------------------------------------------------------------------------
LIBEL="TL file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC1023_GTCUMUL_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC1023_GTCUMUL_O.dat

NSTEP=${NJOB}_60
# FCTRGRO file sort by Contract/Endorsement/Section
#-----------------------------------------------------------------------------
LIBEL="FCTRGRO file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_BCP_CTRGRO_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CTRGRO_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:,
	UWY_NF 21:1 - 21:

/KEYS CTR_NF, END_NT, SEC_NF,
	UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_65
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_CTRGRO_O.dat

NSTEP=${NJOB}_70
#Accumulation of TL transaction codes amounts
#-----------------------------------------------------------------------------
LIBEL="Accumulation of TL transaction codes amounts"
PRG=ESTC0601
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_GT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_60_${IB}_SORT_CTRGRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
EXECPRG

NSTEP=${NJOB}_75
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_GT_O.dat


NSTEP=${NJOB}_80
#Accumulation of TL amounts by occurence U/W year
#-----------------------------------------------------------------------------
LIBEL="Accumulation of TL amounts by occurence U/W year"
PRG=ESTC0602
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_ESTC0601_GT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O.dat
EXECPRG

NSTEP=${NJOB}_85
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC0601_GT_O.dat

NSTEP=${NJOB}_90
#FCTRULT file sort by Contract/Endorsement/Section/UW Year/Underwriting number
#-----------------------------------------------------------------------------
LIBEL="FCTRULT file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_CTRULT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CTRULT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_95
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_BCP_CTRULT_O.dat

NSTEP=${NJOB}_100
#SADPERICASE file sort by Contract/Endorsement/Section/UW Year/Underwriting number
#-----------------------------------------------------------------------------
LIBEL="SADPERICASE file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC1023_SADPERICASE_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_105
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC1023_SADPERICASE_O.dat

NSTEP=${NJOB}_110
#Regrouping of amounts of FCTRULT and FGT files in the perimeter
#-----------------------------------------------------------------------------
LIBEL="Generation of treaties draft file"
PRG=ESTC0603
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
SEGTYPULT_CT $SEGTYPULT_CT
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_CTRULT_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_80_${IB}_ESTC0602_GT_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_60_${IB}_SORT_CTRGRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRAV_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASE_O.dat
EXECPRG

NSTEP=${NJOB}_115
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_PERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC0602_GT_O.dat

NSTEP=${NJOB}_120
#PERICASETRAV File Sort by Segment/UW Year/Currency
#-----------------------------------------------------------------------------
LIBEL="Treaties draft file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_110_${IB}_ESTC0603_PERICASETRAV_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASETRAV_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:, EGPCUR_CF 6:1 - 6:, SEG_NF 9:1 - 9:
/KEYS SEG_NF, UWY_NF, EGPCUR_CF, CTR_NF, END_NT, SEC_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_125
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC0603_PERICASETRAV_O.dat

NSTEP=${NJOB}_130
# FSEGEST file sort by Segment/UW Year
#-----------------------------------------------------------------------------
#SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_SEGEST_O.dat
LIBEL="FSEGEST file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_BCP_SEGEST_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF 2:1 - 2:, UWY_NF 3:1 - 3:
/KEYS SEG_NF, UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_135
#Calculation of lost ratio by Segment/UW Year
#-----------------------------------------------------------------------------
LIBEL="Generation of segments draft file"
PRG=ESTC0604
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
SEGTYPULT_CT $SEGTYPULT_CT
CRE_D $CRE_D
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_PERICASETRAV_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_130_${IB}_SORT_SEGEST_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SEGESTTRAV1_O.dat
EXECPRG

NSTEP=${NJOB}_140
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_SEGEST_O.dat

NSTEP=${NJOB}_145
#Calculation of losses by Segment/UW Year/Currency
#-----------------------------------------------------------------------------
LIBEL="Generation of segments draft file"
PRG=ESTC0605
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
SEGTYPULT_CT $SEGTYPULT_CT
CRE_D $CRE_D
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_PERICASETRAV_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_135_${IB}_ESTC0604_SEGESTTRAV1_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SEGESTTRAV2_O.dat
EXECPRG

NSTEP=${NJOB}_150
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_135_${IB}_ESTC0604_SEGESTTRAV1_O.dat

NSTEP=${NJOB}_155
#PERICASE file sort by Segment/UW Year/Currency
#-----------------------------------------------------------------------------
LIBEL="PERICASE file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC0603_PERICASE_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF 80:1 - 80:, UWY_NF 6:1 - 6:, EGPCUR_CF  23:1 - 23:, CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UW_NT 7:1 - 7:
/KEYS SEG_NF, UWY_NF, EGPCUR_CF, CTR_NF, END_NT, SEC_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_160
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC0603_PERICASE_O.dat

NSTEP=${NJOB}_165
#Indroducting segments in SADPERIFR file
#-----------------------------------------------------------------------------
LIBEL="Indroducting segments in SADPERIFR file"
PRG=ESTC0607
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERIFR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_60_${IB}_SORT_CTRGRO_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_90_${IB}_SORT_CTRULT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIFR_O.dat
EXECPRG

NSTEP=${NJOB}_170
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_PERIFR_O.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_CTRGRO_O.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_CTRULT_O.dat

NSTEP=${NJOB}_175
#SADPERIFR file sort by Segment/UW Year
#-----------------------------------------------------------------------------
LIBEL="SADPERIFR file sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_165_${IB}_ESTC0607_PERIFR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERIFR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF 11:1 - 11:, UWY_NF 4:1 - 4:, CUR_CF 12:1 - 12:, CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UW_NT 5:1 - 5:
/KEYS SEG_NF, UWY_NF, CUR_CF, CTR_NF, END_NT, SEC_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_180
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_165_${IB}_ESTC0607_PERIFR_O.dat

NSTEP=${NJOB}_185
#Calculation of claims
#-----------------------------------------------------------------------------
LIBEL="Calculation of claims"
PRG=ESTC0606
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
SEGTYPULT_CT $SEGTYPULT_CT
CRE_D $CRE_D
SSDULT_LL $SSDULT_LL
VRS_LL $VRS_LL
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_PERICASETRAV_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_145_${IB}_ESTC0605_SEGESTTRAV2_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_155_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_175_${IB}_SORT_PERIFR_O.dat
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRULT_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FAMLIA_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_SECTION_O.dat
EXECPRG

NSTEP=${NJOB}_190
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_SORT_PERICASETRAV_O.dat
RMFIL ${DFILT}/${NJOB}_145_${IB}_ESTC0605_SEGESTTRAV2_O.dat
RMFIL ${DFILT}/${NJOB}_155_${IB}_SORT_PERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_175_${IB}_SORT_PERIFR_O.dat


# jobend provisoire
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"
JOBEND

###################
# Tables Loading  #
###################

NSTEP=${NJOB}_195
#table TCTRULT update
#-----------------------------------------------------------------------------
LIBEL="table TCTRULT update"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_185_${IB}_ESTC0606_CTRULT_O.dat
BCP_TABLE="BEST..TCTRULT"
BCP

NSTEP=${NJOB}_200
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_ESTC0606_CTRULT_O.dat

NSTEP=${NJOB}_205
#Deletion of ESTSECTION table
#-----------------------------------------------------------------------------
LIBEL="Deletion of ESTSECTION table"
ISQL_QRY="TRUNCATE TABLE BTRAV..ESTSECTION"
ISQL_BASE="BTRAV"
ISQL

NSTEP=${NJOB}_210
#Deletion of ESTFAMLIA table
#-----------------------------------------------------------------------------
LIBEL="Deletion of ESTFAMLIA table"
ISQL_QRY="TRUNCATE TABLE BTRAV..ESTFAMLIA"
ISQL_BASE="BTRAV"
ISQL

NSTEP=${NJOB}_215
#Table ESTSECTION loading
#-----------------------------------------------------------------------------
LIBEL="Table ESTSECTION loading"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_185_${IB}_ESTC0606_SECTION_O.dat
BCP_TABLE="BTRAV..ESTSECTION"
BCP

NSTEP=${NJOB}_220
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_ESTC0606_SECTION_O.dat

NSTEP=${NJOB}_225
#Table ESTFAMLIA loading
#-----------------------------------------------------------------------------
LIBEL="Table ESTFAMLIA loading"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_185_${IB}_ESTC0606_FAMLIA_O.dat
BCP_TABLE="BTRAV..ESTFAMLIA"
BCP

NSTEP=${NJOB}_230
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_ESTC0606_FAMLIA_O.dat

NSTEP=${NJOB}_235
#TSECTION tables update
#-----------------------------------------------------------------------------
LIBEL="TSECTION tables update"
ISQL_TRIGGERS_OFF="YES"
ISQL_QRY="exec PsSECTION_37"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_240
#TFAMLIA tables update
#-----------------------------------------------------------------------------
LIBEL="TFAMLIA tables update"
ISQL_TRIGGERS_OFF="YES"
ISQL_QRY="exec PsSECTION_36"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_245
#Deletion of ESTSECTION table
#-----------------------------------------------------------------------------
LIBEL="Deletion of ESTSECTION table"
ISQL_QRY="TRUNCATE TABLE BTRAV..ESTSECTION"
ISQL_BASE="BTRAV"
ISQL

NSTEP=${NJOB}_250
#Deletion of ESTFAMLIA table
#-----------------------------------------------------------------------------
LIBEL="Deletion of ESTFAMLIA table"
ISQL_QRY="TRUNCATE TABLE BTRAV..ESTFAMLIA"
ISQL_BASE="BTRAV"
ISQL

NSTEP=${NJOB}_255
#Deletion of TESTSSDTMP table
#-----------------------------------------------------------------------------
LIBEL="Deletion of TESTSSDTMP table"
ISQL_QRY="TRUNCATE TABLE BTRAV..TESTSSDTMP"
ISQL_BASE="BTRAV"
ISQL


NSTEP=${NJOB}_255
#Update of TREQJOB table
#-----------------------------------------------------------------------------
LIBEL="Update of TREQJOB table"
ISQL_QRY="update BEST..TREQJOB  set LAUNCH_D = ${CRE_D} where reqcod_ct ='S' and launch_d = null "
ISQL_BASE="BTRAV"
ISQL

########################################
# Deletion of Temporary Files          #
########################################

NSTEP=${NJOB}_265
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND

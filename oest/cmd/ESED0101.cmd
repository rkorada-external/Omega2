#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                  Versionnage
# nom du script SHELL            : ESED0101.cmd
# revision                       : $Revision:   1.16  $
# date de creation               : 05/06/1997
# auteur                         : CGI
# references des specifications  : ESTSEG02.DOC
#-----------------------------------------------------------------------------
# description
#   Launch versionning
#
# Job asynchrone launched
#-----------------------------------------------------------------------------
# historiques des modifications
# 22/02/99 M.Lopez(IBM) Test si l'OPTION est egale a 0 
#[02] 14/02/2014 R. Cassis :spot:25427 - Centralisation des bases
#[03] 16/10/2014 Florent :spot:27466 La nouvelle segmentation n'utilise plus le périmètre du ESCD0001
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
USR_CF=${1}
SSD_CF=${2}
VRS_NF=${3}
SEGTYP_CT=${4}
OPTION=${5}
CRE_D=${6}

ECHO_LOG "---------------------------------------"
ECHO_LOG "----------  Parametres du Job  ----------"
ECHO_LOG "---------------------------------------"
ECHO_LOG "==> USR_CF.........: ${USR_CF}"
ECHO_LOG "==> SSD_CF.........: ${SSD_CF}"
ECHO_LOG "==> VRS_NF.........: ${VRS_NF}"
ECHO_LOG "==> SEGTYP_CT......: ${SEGTYP_CT}"
ECHO_LOG "==> OPTION.........: ${OPTION}"
ECHO_LOG "==> CRE_D..........: ${CRE_D}"
ECHO_LOG "---------------------------------------"

NSTEP=${NJOB}_10
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_15
# Bcp : selecting BSAR..TSEGEST
#--------------------------------
LIBEL="Transferring table BSAR..TSEGEST into file with the format of BEST..TSEGEST" 
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BSTA..PsSEGEST_01 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', '${CRE_D}'"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TSEGEST_O.dat
BCP

NSTEP=${NJOB}_20
# Bcp : selecting BSAR..TLABOCY
#--------------------------------
LIBEL="Transferring table BSAR..TLABOCY into file with the format of BEST..TLABOCY" 
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BSTA..PsLABOCY_01 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', '${CRE_D}'"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TLABOCY_O.dat
BCP

NSTEP=${NJOB}_25
# Bcp out
#--------------------------------
LIBEL="Transferring table BSAR..TIBNRSUP into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select TRN_NT, ACCTYP_NF, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, RETAUTGEN_B, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, GEMPRMPAY_NF, GANPAYORD_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RETRTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ACCTRN_NT, COMMAC_LL, CRE_D, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF from BSAR..TIBNRSUP where SSD_CF = ${SSD_CF}"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FINFOIBNRSUP_O.dat
BCP

if [ "${OPTION}" = "1" ]
then

   NSTEP=${NJOB}_30
   #--------------------------------
   LIBEL="Transferring table BSAR..TSEGEST into file with the format of BEST..TSEGMENT" 
   BCP_WAY="OUT"
   BCP_VER="+"
   BCP_QRY="exec BSTA..PsSEGMENT_01 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}'"
   BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TSEGMENT_O.dat
   BCP

   NSTEP=${NJOB}_35
   #--------------------------------
   LIBEL="Transferring table BSAR..TCTRGRO into file with format for BEST"
   BCP_WAY="OUT"
   BCP_VER="+"
   BCP_QRY="exec BSAR..PsTCTRGRO_EST ${SSD_CF},'${SEGTYP_CT}',${VRS_NF}"
   BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BSAR_TCTRGRO_O.dat
   BCP

   NSTEP=${NJOB}_40
   #--------------------------------
   LIBEL="Create the EST_FINFOSEGPOR/TSEGPOR from perimeter, BMIS"
   BCP_WAY="OUT"
   BCP_VER="+"
   BCP_QRY="exec BSAR..PsTSEGPOR_EST ${SSD_CF},'${SEGTYP_CT}'"
   BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_SEGPOR_O.dat
   BCP

   NSTEP=${NJOB}_50
   # Generation of a file in BEST..TCTRANO format
   #--------------------------------
   LIBEL="Generation of a file in BEST..TCTRANO format"
   FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
VRS_NF ${VRS_NF}
exit
EOF
   PRG=ESTC0110
   export ${PRG}_PRM=${FPRM}
   export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_BCP_BSAR_TCTRGRO_O.dat
   export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_BCP_SEGPOR_O.dat
   export ${PRG}_I3=${DFILT}/${NJOB}_30_${IB}_BCP_TSEGMENT_O.dat
   export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TCTRANO_O.dat
   EXECPRG

   NSTEP=${NJOB}_60
   #-----------------------------------------------------------------------------
   LIBEL="Deletion of Temporary Files"
   RMFIL "${DFILT}/${NJOB}_40_${IB}_BCP_SEGPOR_O.dat"
fi

NSTEP=${NJOB}_70
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in production server"
SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_85
# Delete of working table
#--------------------------------
LIBEL="Truncate of BTRAV..TESTUTISUD"
ISQL_QRY="truncate table BTRAV..TESTUTISUD"
ISQL_BASE='BEST'
ISQL   

NSTEP=${NJOB}_90
# Generation of TESTUTISUD table
#--------------------------------
LIBEL="Generation of TESTUTISUD table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_25_${IB}_BCP_FINFOIBNRSUP_O.dat
BCP_TABLE="BTRAV..TESTUTISUD"
BCP    

NSTEP=${NJOB}_95
# Current estimate table delete
#--------------------------------
LIBEL="Current estimate table delete"
ISQL_QRY="exec PdCTRGRO_01 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', ${OPTION}"
ISQL_BASE='BEST'
ISQL

if [ "${OPTION}" = "1" ]
then
   NSTEP=${NJOB}_99
   #--------------------------------
   ECHO_LOG "Take out the last field to have the same format as BEST..TCTRGRO"
   cut -d~ -f 1-20 ${DFILT}/${NJOB}_35_${IB}_BCP_BSAR_TCTRGRO_O.dat > ${DFILT}/${NSTEP}_${IB}_CUT_BSAR_TCTRGRO_O.dat

   NSTEP=${NJOB}_100
   #--------------------------------
   LIBEL="BCP in BEST..TCTRGRO"
   BCP_WAY="IN"
   BCP_VER=""
   BCP_I=${DFILT}/${NJOB}_99_${IB}_CUT_BSAR_TCTRGRO_O.dat
   BCP_TABLE="BEST..TCTRGRO"
   BCP    

   NSTEP=${NJOB}_105
   #--------------------------------
   LIBEL="BCP in BEST..TSEGMENT"
   BCP_WAY="IN"
   BCP_VER=""
   BCP_I=${DFILT}/${NJOB}_30_${IB}_BCP_TSEGMENT_O.dat
   BCP_TABLE="BEST..TSEGMENT"
   BCP    

   NSTEP=${NJOB}_110
   #--------------------------------
   LIBEL="BCP in BEST..TCTRANO"
   BCP_WAY="IN"
   BCP_VER=""
   BCP_I=${DFILT}/${NJOB}_50_${IB}_ESTC0110_TCTRANO_O.dat
   BCP_TABLE="BEST..TCTRANO"
   BCP    
fi

NSTEP=${NJOB}_115
#--------------------------------
LIBEL="BCP in BEST..TSEGEST"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_15_${IB}_BCP_TSEGEST_O.dat
BCP_TABLE="BEST..TSEGEST"
BCP    

NSTEP=${NJOB}_120
# BCP in BEST..TLABOCY
#--------------------------------
LIBEL="BCP in BEST..TLABOCY"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_BCP_TLABOCY_O.dat
BCP_TABLE="BEST..TLABOCY"
BCP    

NSTEP=${NJOB}_125
# Current estimate table update
#--------------------------------
LIBEL="Current estimate table update"
ISQL_QRY="exec PiCTRGRO_03 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', ${OPTION}"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_130
# Special entries from IBNR tool 
#--------------------------------
LIBEL="Special entries from IBNR tool"
ISQL_QRY="exec PiACCSUP_03 ${SSD_CF}"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

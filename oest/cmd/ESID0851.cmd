#! /bin/ksh
#=============================================================================
# application name              : Impirt ULAE or Risk Margin
# Shell script                  : ESID0851.cmd
# Rreation date                 : 2014-06-25
# Author                        : Ashish Kumar Singh
# Specifications                : http://dcvprdxiki/xwiki/bin/view/SCOR+OMEGA+v2/BTH-EST-807176
#-----------------------------------------------------------------------------
# Description
#   Asynchronous job to upload Import Ulae or Risk Margin file
# Modifications
#--------------
# 001 KBhimasen - Spira#109188 - New input parameters are passed and added in Step#25&26
# 002 20/03/2024 - DAD - spira:110913 - new column CTRNAT_CT, UWY_NF, LOBN2_NF added
#===============================================================================
# set -x
  
  
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd
. ${DUTI}/fctws.cmd
  
  
# Initialisation of the Job
NJOB="ESID0851"
JOBINIT
  
USR_CF=${1}
DATA_TYPE=${2}
INPUT_FILE=${3}
CRE_DATE=${4}
CLOS_DATE=${5}
CLOS_PER=${6}
SEG_VER=${7}
LOB_VER=${8}


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> USR_CF..........................: ${USR_CF}"
ECHO_LOG "#===> SEG_VER.........................: ${SEG_VER}"
ECHO_LOG "#===> CRE_DATE........................: ${CRE_DATE}  "
ECHO_LOG "#===> DATA_TYPE.......................: ${DATA_TYPE}  "
ECHO_LOG "#===> CLOS_PER........................: ${CLOS_PER}"
ECHO_LOG "#===> CLOS_DATE.......................: ${CLOS_DATE}"
ECHO_LOG "#===> LOB_VER.........................: ${LOB_VER}"


ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> INPUT_FILE......................: ${INPUT_FILE}"

ECHO_LOG "#========================================================================="
  

NSTEP=${NJOB}_05
# Convert DOS-style carriage returns into Unix-style line feeds
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
INPUT_FILE="ESID0851.txt"
dos2unix -n ${DUSERS}/${INPUT_FILE} ${DFILT}/${NSTEP}_${IB}.dat
  
  
if [ ${DATA_TYPE} = "ULAERAT" ]
then
{
  
  NSTEP=${NJOB}_10
  # Truncate ULAE Ratio Working Table BTRAV..EST_ESID0851_ULAERAT
  #------------------------------------------------------------------------------
  LIBEL="Truncate ULAE Ratio Working Table BTRAV..EST_ESID0851_ULAERAT"
  ISQL_BASE="BTRAV"
  ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
  ISQL_QRY="truncate table BTRAV..EST_ESID0851_ULAERAT"
  ISQL
  
  # [002]
  NSTEP=${NJOB}_15
  # Add CRE_DATE and USR_CF in ULAE Ratio File"
  #------------------------------------------------------------------------------
  sed 1d ${DFILT}/${NJOB}_05_${IB}.dat > ${DFILT}/${NSTEP}_${IB}.dat_tmp1
  awk -F"\t" 'BEGIN{OFS="~";} {print $1,$2,$3,$4,$5,$6}' ${DFILT}/${NSTEP}_${IB}.dat_tmp1 > ${DFILT}/${NSTEP}_${IB}.dat_tmp2
  awk -F "~" -v var1="$CRE_DATE" -v var2="$USR_CF" 'BEGIN{OFS="~";} {printf "%d~%d~%2.8f~%s~%s~%s~%d~%d\n",$1,$2,$6,var1,var2,$3,$4,$5}' ${DFILT}/${NSTEP}_${IB}.dat_tmp2 > ${DFILT}/${NSTEP}_${IB}_AWK.dat

  
  NSTEP=${NJOB}_20
  # BCP IN ULAE RATIO FILE IN BTRAV..EST_ESID0851_ULAERAT
  #------------------------------------------------------------------------------
  LIBEL="Load ULAE Ratio File in BTRAV..EST_ESID0851_ULAERAT"
  BCP_WAY="IN"; BCP_VER=""
  BCP_I=${DFILT}/${NJOB}_15_${IB}_AWK.dat
  BCP_TABLE="BTRAV..EST_ESID0851_ULAERAT"
  BCP
  
  
  NSTEP=${NJOB}_25
  # Update ULAE Ratio Table BEST..TULAERAT
  #------------------------------------------------------------------------------
  LIBEL="Update ULAE Ratio Table BEST..TULAERAT"
  ISQL_BASE="BEST"
  ISQL_QRY="execute PtULAERAT_01 '${CRE_DATE}', '${CLOS_DATE}', '${CLOS_PER}'"
  ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
  ISQL
  
}
elif [ ${DATA_TYPE} = "RSKMRGAMT" ]
then
{
  
  NSTEP=${NJOB}_11
  # Truncate Risk Margin Working Table BTRAV..EST_ESID0851_RSKMRGAMT
  #------------------------------------------------------------------------------
  LIBEL="Truncate Risk Margin Working Table BTRAV..EST_ESID0851_RSKMRGAMT"
  ISQL_BASE="BTRAV"
  ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
  ISQL_QRY="truncate table BTRAV..EST_ESID0851_RSKMRGAMT"
  ISQL
  
  
  NSTEP=${NJOB}_16
  # Add CRE_DATE and USR_CF in Risk Margin File
  #------------------------------------------------------------------------------
  # [002]
  sed 1d ${DFILT}/${NJOB}_05_${IB}.dat > ${DFILT}/${NSTEP}_${IB}.dat_tmp1
  awk -F"\t" 'BEGIN{OFS="~";} {print $1,$2,$3,$4,$5}' ${DFILT}/${NSTEP}_${IB}.dat_tmp1 > ${DFILT}/${NSTEP}_${IB}.dat_tmp2
  awk -F "~" -v var1="$CRE_DATE" -v var2="$USR_CF" -v var3="$SEG_VER" -v var4="$LOB_VER" 'BEGIN{OFS="~";} {printf "%d~%d~%d~%d~%s~%18.3f~%s~%s~%s\n",var3,$1,var4,$2,$3,$4,$5,var2,var1}' ${DFILT}/${NSTEP}_${IB}.dat_tmp2 > ${DFILT}/${NSTEP}_${IB}_AWK.dat


  NSTEP=${NJOB}_21
  # BCP IN RISK MARGIN FILE IN BTRAV..EST_ESID0851_RSKMRGAMT
  #------------------------------------------------------------------------------
  LIBEL="Load Risk Margin File in BTRAV..EST_ESID0851_RSKMRGAMT"
  BCP_WAY="IN"; BCP_VER=""
  BCP_I=${DFILT}/${NJOB}_16_${IB}_AWK.dat
  BCP_TABLE="BTRAV..EST_ESID0851_RSKMRGAMT"
  BCP
  
  
  NSTEP=${NJOB}_26
  # Update Risk Margin Table BEST..TRSKMRGSSD
  #------------------------------------------------------------------------------
  LIBEL="Update Risk Margin Amount Table BEST..TRSKMRGSSD"
  ISQL_BASE="BEST"
  ISQL_QRY="execute PtRSKMRG_01 '${CRE_DATE}', '${CLOS_DATE}', '${CLOS_PER}'"
  ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
  ISQL
}
fi
  
  
NSTEP=${NJOB}_30
# Begin rm
#--------------------------------------------------------
LIBEL="Delete job temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND


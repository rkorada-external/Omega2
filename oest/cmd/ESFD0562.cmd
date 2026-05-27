#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD0562.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 11/07/2025
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
#-=-=-=-=-=-=-=-=-=-=-=
# Input files
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IADPERICASE0 ............: ${EST_IADPERICASE0}"
ECHO_LOG "#===> EST_IAVPERICASE0 ............: ${EST_IAVPERICASE0}"
ECHO_LOG "#===> EST_FCESSION0 ............: ${EST_FCESSION0}"
ECHO_LOG "#===> EST_FCPLACC0 ............: ${EST_FCPLACC0}"
ECHO_LOG "#===> EST_FPLACEMT0 ............: ${EST_FPLACEMT0}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
# Output files
ECHO_LOG "#===> EST_IADVPERICASE ............: ${EST_IADVPERICASE}"
ECHO_LOG "#===> EST_FCESSION ............: ${EST_FCESSION}"
ECHO_LOG "#===> EST_FCPLACC ............: ${EST_FCPLACC}"
ECHO_LOG "#===> EST_FPLACEMT ............: ${EST_FPLACEMT}"
#-=-=-=-=-=-=-=-=-=-=-=
#
# Job launched by ESFD0560.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#[001] 17/07/2025 S.Behague US5603: SAS AE load- CSUOE control based on pericase - Spira 111627
#[002] 17/07/2026 Dasari Venkata US5606: L&H SAS/OMega PAI SSD/ESB data integration logic review - Spira 111803
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Calculation of freeze date"
ISQL_BASE="BEST"
ISQL_QRY="SELECT case when ('$PARM_CRE_D' > dateadd(day, ${X_DAYS} * -1, '${PARAM_CUR_PSTOMGEND17_D}') ) then 'KO' else 'OK' end"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

is_Ok=`cat ${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat | sed -r 's/ //g'`

if [ "X${is_Ok}" = "XOK" ]
then
  NSTEP=${NJOB}_10
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IADVPERICASE} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17G_IAVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT

  NSTEP=${NJOB}_15
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IRDVPERICASE} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17G_IRVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT

  NSTEP=${NJOB}_20
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IADVPERICASE_I17L} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17L_IAVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT

  NSTEP=${NJOB}_25
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IRDVPERICASE_I17L} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17L_IRVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT

  NSTEP=${NJOB}_30
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IADVPERICASE_I17P} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17P_IAVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT

  NSTEP=${NJOB}_35
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IRDVPERICASE_I17P} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17P_IRVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF            3:1 -   3:,
    SEC_NF            5:1 -   5:,
    UWY_NF            6:1 -   6:,
    LOBACC_CF	       38:1 -  38:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE ( LOBACC_CF="30" OR LOBACC_CF="31" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE
  exit
EOF
  SORT
  NSTEP=${NJOB}_40
  # Copy of PERICASE
  #-----------------------------------------------------------------------------
  LIBEL="Copy of PERICASE"
  cp ${DFILT}/${NJOB}_10_${IB}_I17G_IAVPERICASE_LIFE.dat ${EST_SHARED_IAVPERICASE}
  cp ${DFILT}/${NJOB}_15_${IB}_I17G_IRVPERICASE_LIFE.dat ${EST_SHARED_IRVPERICASE}
  cp ${DFILT}/${NJOB}_20_${IB}_I17L_IAVPERICASE_LIFE.dat ${EST_SHARED_IAVPERICASE_I17L}
  cp ${DFILT}/${NJOB}_25_${IB}_I17L_IRVPERICASE_LIFE.dat ${EST_SHARED_IRVPERICASE_I17L}
  cp ${DFILT}/${NJOB}_30_${IB}_I17P_IAVPERICASE_LIFE.dat ${EST_SHARED_IAVPERICASE_I17P}
  cp ${DFILT}/${NJOB}_35_${IB}_I17P_IRVPERICASE_LIFE.dat ${EST_SHARED_IRVPERICASE_I17P}
  
  # Mise a disposition de SAS
  cp ${EST_SHARED_IAVPERICASE} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_IRVPERICASE} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_IAVPERICASE_I17L} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_IRVPERICASE_I17L} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_IAVPERICASE_I17P} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_IRVPERICASE_I17P} ${DTRANSFER}/${REMOTE_SITE}/to

  NSTEP=${NJOB}_45
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_SHARED_IAVPERICASE} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17G_IADVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF                   3:1 -   3:,
    SEC_NF                   5:1 -   5:,
    UWY_NF                   6:1 -   6:,
    CTRSTS_CT                99:1 - 99:,
    GRPINISTS_CT     228:1 - 228:,
    PARINISTS_CT     229:1 - 229:,
    LOCINISTS_CT     230:1 - 230:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE_PERICASE (( GRPINISTS_CT="" OR GRPINISTS_CT="1" ) 
    OR ( PARINISTS_CT="" OR PARINISTS_CT="1" ) 
    OR ( LOCINISTS_CT="" OR LOCINISTS_CT="1" ))
    AND ( CTRSTS_CT = "14" or CTRSTS_CT = "16" or CTRSTS_CT = "17" or CTRSTS_CT = "19" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE_PERICASE
  exit
EOF
  SORT

    NSTEP=${NJOB}_50
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_SHARED_IAVPERICASE_I17L} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17L_IADVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF                   3:1 -   3:,
    SEC_NF                   5:1 -   5:,
    UWY_NF                   6:1 -   6:,
    CTRSTS_CT                99:1 - 99:,
    GRPINISTS_CT     228:1 - 228:,
    PARINISTS_CT     229:1 - 229:,
    LOCINISTS_CT     230:1 - 230:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE_PERICASE (( GRPINISTS_CT="" OR GRPINISTS_CT="1" ) 
    OR ( PARINISTS_CT="" OR PARINISTS_CT="1" ) 
    OR ( LOCINISTS_CT="" OR LOCINISTS_CT="1" ))
    AND ( CTRSTS_CT = "14" or CTRSTS_CT = "16" or CTRSTS_CT = "17" or CTRSTS_CT = "19" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE_PERICASE
  exit
EOF
  SORT

    NSTEP=${NJOB}_55
  #------------------------------------------------------------------------------------
  LIBEL="Include Life contracts"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_SHARED_IAVPERICASE_I17P} 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_I17P_IADVPERICASE_LIFE.dat 2000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
    CTR_NF                   3:1 -   3:,
    SEC_NF                   5:1 -   5:,
    UWY_NF                   6:1 -   6:,
    CTRSTS_CT                99:1 - 99:,
    GRPINISTS_CT     228:1 - 228:,
    PARINISTS_CT     229:1 - 229:,
    LOCINISTS_CT     230:1 - 230:
  /KEYS CTR_NF,SEC_NF, UWY_NF
  /CONDITION LIFE_PERICASE (( GRPINISTS_CT="" OR GRPINISTS_CT="1" ) 
    OR ( PARINISTS_CT="" OR PARINISTS_CT="1" ) 
    OR ( LOCINISTS_CT="" OR LOCINISTS_CT="1" ))
    AND ( CTRSTS_CT = "14" or CTRSTS_CT = "16" or CTRSTS_CT = "17" or CTRSTS_CT = "19" )
  /OUTFILE ${SORT_O} OVERWRITE
  /INCLUDE LIFE_PERICASE
  exit
EOF
  SORT


  NSTEP=${NJOB}_60
  # Copy of INI PERICASE
  #-----------------------------------------------------------------------------
  LIBEL="Copy of INI PERICASE"

  cp ${DFILT}/${NJOB}_45_${IB}_I17G_IAVPERICASE_LIFE.dat ${EST_SHARED_INI_PERICASE}
  cp ${DFILT}/${NJOB}_50_${IB}_I17L_IAVPERICASE_LIFE.dat ${EST_SHARED_INI_PERICASE_I17L}
  cp ${DFILT}/${NJOB}_55_${IB}_I17P_IAVPERICASE_LIFE.dat ${EST_SHARED_INI_PERICASE_I17P}
  
  # Mise a disposition de SAS
  cp ${EST_SHARED_INI_PERICASE} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_INI_PERICASE_I17L} ${DTRANSFER}/${REMOTE_SITE}/to
  cp ${EST_SHARED_INI_PERICASE_I17P} ${DTRANSFER}/${REMOTE_SITE}/to


fi

NSTEP=${NJOB}_195
# Rm of temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND


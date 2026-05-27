#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Gestion des ecritures de services
# nom du script SHELL		: ESID0091.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 02/10/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   special entries treatment ( set 78 )
#
# Job launched by TP
#-----------------------------------------------------------------------------
# historiques des modifications :
# 11/02/03  J. Ribot step40 et 80  ajout prise en compte colonne retintamt_m
# 26/04/05  M.DJELLOULI : SPOT 5084 - MOD03
#                                    Ajout de la Zone SPEENTTYP_CF de TACCSUP
#                                    Modification du STEP 40
#                                    Modification du STEP 75
#                                    Modification du STEP 80
# 27/04/05  M.DJELLOULI : SPOT 11445 - STEP 35
#                                                      EST_ESIJ0090_TACCSUP remplace TESTACCSUP
#                                                      EST_ESIJ0090_TESTCES remplace TESTCES
#                                                      EST_ESIJ0090_TESTPLC remplace  TESTPLC
#                                    Modification du STEP 35
# 24/06/05  M.DJELLOULI : SPOT 5085 - MOD04
#                                    Ajout de la Zone SPEENTNAT_CT de TACCSUP
#                                    Modification du STEP 40
#                                    Modification du STEP 75
#                                    Modification du STEP 80
# 13/03/06  M.DJELLOULI : SPOT 5084 - MOD05
#                                    STEP 60 : Remplacer ESTC2303 par ESTC2333
#                                    STEP 65 : Remplacer ESTC2303 par ESTC2333
#                                    STEP 75 : Remplacer ESTC2304 par ESTC2334
#                                    STEP 78 : Remplacer ESTC2304 par ESTC2334
# 17/07/2012 Florent :spot:23390 Solvency II, ajout gestion d'un record plus grand à cause de commentaires sur les sort venant de TACCSUP
#[010] 14/02/2014 R. cassis :spot:25427 - Adaptation du batch à la centralisation
#[011] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
#[012] 25/02/2016 -=Dch=-	  :spot:29162 Impact Retro P&C -> bcp IADVPERICASE ajout pour ESTC2333
#[013] 27/01/2017 DFI       :spira:58935 Correction erreur de syntaxe lors de la recherche des fichiers
#      01/02/2017                        Correction motif de recherche du IADVPERICASE (on prend l'annuel)       
#[014] 25/10/2017 R. cassis :spira:61508 Ajout option A dans prog ESTC2333 (A=autre/L=Local)
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# variables necessaires au traitement ( proc stockées, prog C, ... )
CRE_D=$2
CTR_NF=$3
END_NT=$4
SEC_NF=$5
UWY_NF=$6
UW_NT=$7
CUR_CF=$8
CLODAT_D=$9
BALSHEY_NF=${10}
PERTYP_CT=${11}
BALSHTMTH_NF=${12}
DBCLO_D=${13}
TRN_NT=${14}

ECHO_LOG "---------------------------------------"
ECHO_LOG "----------  Parametres du Job  ----------"
ECHO_LOG "---------------------------------------"
ECHO_LOG "==> CRE_D..........: ${CRE_D}"
ECHO_LOG "==> CTR_NF.........: ${CTR_NF}"
ECHO_LOG "==> END_NT.........: ${END_NT}"
ECHO_LOG "==> SEC_NF.........: ${SEC_NF}"
ECHO_LOG "==> UWY_NF.........: ${UWY_NF}"
ECHO_LOG "==> UW_NT..........: ${UW_NT}"
ECHO_LOG "==> CUR_CF.........: ${CUR_CF}"
ECHO_LOG "==> CLODAT_D.......: ${CLODAT_D}"
ECHO_LOG "==> BALSHEY_NF.....: ${BALSHEY_NF}"
ECHO_LOG "==> PERTYP_CT......: ${PERTYP_CT}"
ECHO_LOG "==> BALSHTMTH_NF...: ${BALSHTMTH_NF}"
ECHO_LOG "==> DBCLO_D........: ${DBCLO_D}"
ECHO_LOG "==> TRN_NT.........: ${TRN_NT}"
ECHO_LOG "---------------------------------------"

JOBINIT

NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="Extraction du login selon la filiale"
ISQL_QRY=`CFTMP`
ISQL_BASE=BREF
# -b pas de header -h0 zéro ligne après le header, séparateur ~
ISQL_SPECIAL_OPT="-b -h0 -s~"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
cat << EOF > ${ISQL_QRY}
set nocount on
declare
 @SSD_CF USSD_CF
,@USR_CF UUSR_CF

if exists(select 1 from BTRT..TCONTR where CTR_NF='${CTR_NF}')
  select @SSD_CF=a.SSD_CF,@USR_CF=BATCHUSER_CF from BREF..TBATCHSSD a, BTRT..TCONTR b where CTR_NF='${CTR_NF}' and a.SSD_CF=b.SSD_CF
else
  select @SSD_CF=a.SSD_CF,@USR_CF=BATCHUSER_CF from BREF..TBATCHSSD a, BFAC..TCONTR b where CTR_NF='${CTR_NF}' and a.SSD_CF=b.SSD_CF

if @USR_CF=null or @SSD_CF=null
  raiserror 20009 'Unable to get subsidiary and/or batchuser from contract ${CTR_NF}'
else
  select @SSD_CF,lower(@USR_CF)
go
EOF
ISQL

#Affectation des variables login et fichiers
SSD_CF=`cat ${ISQL_O}|cut -d "~" -f2`
EST_LOGIN=`cat ${ISQL_O}|cut -d "~" -f3`
EST_FCES=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESID2500_FCES_*.dat`
EST_FPLC=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESID2500_FPLC_*.dat`
EST_FDETTRS=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESCJ0060_FDETTRS_*.dat`
EST_FRETTRF=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESCJ0060_FRETTRF_*.dat`
EST_FCURCVSNI=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESCJ0060_FCURCVSNI_*.dat`
EST_FCURQUOT=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESCJ0060_FCURQUOT.dat`
EST_FCURCVSN=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESCJ0060_FCURCVSN_*.dat`
EST_IADVPERICASE=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESID0560_IADVPERICASE_[0-9]*1231_*.dat`  #[013]
EST_FTRANSCODE=`ls -rt ${DSCORDATA}/${EST_LOGIN}/interm/*_ESCJ0060_FTRANSCODE_*.dat`    #[013]

ECHO_LOG "---------------------------------------"
ECHO_LOG "---------  Variables affectees  ---------"
ECHO_LOG "---------------------------------------"
ECHO_LOG "==> SSD_CF...........: ${SSD_CF}"
ECHO_LOG "==> EST_LOGIN........: ${EST_LOGIN}"
ECHO_LOG "==> EST_FCES.........: ${EST_FCES}"
ECHO_LOG "==> EST_FPLC.........: ${EST_FPLC}"
ECHO_LOG "==> EST_FDETTRS......: ${EST_FDETTRS}"
ECHO_LOG "==> EST_FRETTRF......: ${EST_FRETTRF}"
ECHO_LOG "==> EST_FCURCVSNI....: ${EST_FCURCVSNI}"
ECHO_LOG "==> EST_FCURQUOT.....: ${EST_FCURQUOT}"
ECHO_LOG "==> EST_FCURCVSN.....: ${EST_FCURCVSN}"
ECHO_LOG "==> EST_IADVPERICASE.: ${EST_IADVPERICASE}"
ECHO_LOG "==> EST_FTRANSCODE...: ${EST_FTRANSCODE}"
ECHO_LOG "---------------------------------------"

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FACCSUP_O.dat
BCP_QRY="exec BEST..PiESTACCSUP_03 '${CRE_D}', ${TRN_NT}"
BCP

if [ ${PERTYP_CT} = "H" ]
then

  NSTEP=${NJOB}_10
  # This step is launched only outside service period
  #------------------------------------------------------------------------------
  LIBEL="Data preparation for the cessions file"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCES_O.dat
  BCP_QRY="exec BEST..PiESTCES_02 '${CTR_NF}', ${END_NT}, ${SEC_NF}, ${UWY_NF}, ${UW_NT}, '${CUR_CF}'"
  BCP

  NSTEP=${NJOB}_15
  # This step is launched only outside service period
  #------------------------------------------------------------------------------
  LIBEL="Data preparation for the placements file"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FPLC_O.dat
  BCP_QRY="exec BEST..PiESTPLC_01"
  BCP

  NSTEP=${NJOB}_20
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="Sort of versements file"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I=${DFILT}/${NJOB}_10_${IB}_BCP_FCES_O.dat
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
  INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:, RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7:, RETSEC_NF 8:1 - 8:, RTY_NF 9:1 - 9:, RETUW_NT 10:1 - 10:
/KEYS   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
  SORT

  NSTEP=${NJOB}_25
  # Begin sort
  #-----------------------------------------------------------------------------
  LIBEL="Sort of placements file"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_FPLC_O.dat
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLC_O.dat
  INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:, RETUW_NT 7:1 - 7:, PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_30
  # Temporary files deletion
  LIBEL="Temporary files deletion"
  RMFIL ${DFILT}/${NJOB}_15_${IB}_BCP_FPLC_O.dat
  RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_FCES_O.dat

  # Positionnement des variables d'environnement
  export ESTV_FCES_SER=${DFILT}/${NJOB}_20_${IB}_SORT_FCES_O.dat
  export ESTV_FPLC_SER=${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat

else

  # Environmental variables point to the last main Closing Period Process
  export ESTV_FCES_SER=${EST_FCES}
  export ESTV_FPLC_SER=${EST_FPLC}

fi

NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Working tables truncate"
ISQL_BASE="BEST"
ISQL_QRY="truncate table BTRAV..EST_ESIJ0090_TACCSUP  truncate table BTRAV..EST_ESIJ0090_TESTCES  truncate table BTRAV..EST_ESIJ0090_TESTPLC"
ISQL

#[011]
NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Transformation of service writing file into LT format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FACCSUP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRN_NT 1:1 - 1:
       ,ACCTYP_NF 2:1 - 2:
       ,SSD_CF 3:1 - 3:
       ,ESB_CF 4:1 - 4:
       ,ENTPERY_NF 5:1 - 5:
       ,ENTPERMTH_NF 6:1 - 6:
       ,BALSHEY_NF 7:1 - 7:
       ,BALSHRMTH_NF 8:1 - 8:
       ,BALSHRDAY_NF 9:1 - 9:
       ,VALPERY_NF 10:1 - 10:
       ,VALPERMTH_NF 11:1 - 11:
       ,TRNCOD_CF 12:1 - 12:
       ,DBLTRNCOD_CF 13:1 - 13:
       ,CTR_NF 15:1 - 15:
       ,END_NT 16:1 - 16:
       ,SEC_NF 17:1 - 17:
       ,UWY_NF 18:1 - 18:
       ,UW_NT 19:1 - 19:
       ,OCCYEA_NF 20:1 - 20:
       ,ACY_NF 21:1 - 21:
       ,SCOSTRMTH_NF 22:1 - 22:
       ,SCOENDMTH_NF 23:1 - 23:
       ,CLM_NF 24:1 - 24:
       ,CUR_CF 25:1 - 25:
       ,AMT_M 26:1 - 26:
       ,CED_NF 27:1 - 27:
       ,BRK_NF 28:1 - 28:
       ,PAY_NF 29:1 - 29:
       ,KEY_NF 30:1 - 30:
       ,RETCTR_NF 31:1 - 31:
       ,RETEND_NT 32:1 - 32:
       ,RETSEC_NF 33:1 - 33:
       ,RTY_NF 34:1 - 34:
       ,RETUW_NT 35:1 - 35:
       ,PLC_NT 36:1 - 36:
       ,RETOCCYEA_NF 37:1 - 37:
       ,RETACY_NF 38:1 - 38:
       ,RETSCOSTRMTH_NF 39:1 - 39:
       ,RETSCOENDMTH_NF 40:1 - 40:
       ,RCL_NF 41:1 - 41:
       ,RETCUR_CF 42:1 - 42:
       ,RETAMT_M 43:1 - 43:
       ,RTO_NF 44:1 - 44:
       ,INT_NF 45:1 - 45:
       ,RETPAY_NF 46:1 - 46:
       ,RETKEY_CF 47:1 - 47:
       ,COMMAC_LL 49:1 - 49:
       ,SPEENTTYP_CF 54:1 - 54:
       ,SPEENTNAT_CT 55:1 - 55:
       ,EVT_NF 56:1 - 56:
       ,REVT_NF 57:1 - 57:
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD SEPA "~"
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, TRNCOD_CF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CUR_CF
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ZERO, SEPA, ENTPERY_NF, ENTPERMTH_NF, VALPERY_NF, VALPERMTH_NF, TRN_NT, ACCTYP_NF, COMMAC_LL, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT

NSTEP=${NJOB}_45
# Temporary file deletion
#------------------------------------------------------------------------------
LIBEL="Temporary file deletion"
#RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_FACCSUP_O.dat

#[014]
NSTEP=${NJOB}_50
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of versements operator"
PRG=ESTC2333
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 1
TYPETRAIT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${ESTV_FCES_SER}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat
EXECPRG

NSTEP=${NJOB}_55
# Temporary files deletion
#------------------------------------------------------------------------------
LIBEL="Temporary files deletion"
#RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of LT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, TRNCOD_CF, CUR_CF, RETOCCYEA_NF, RCL_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT , OCCYEA_NF, CLM_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_65
# Temporary file deletion
#------------------------------------------------------------------------------
LIBEL="Temporary file deletion"
#RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat

NSTEP=${NJOB}_70
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2334
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 0
BALSHEY_NF ${BALSHEY_NF}
GTE_B 1
PRS_CF 50
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${ESTV_FPLC_SER}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2.dat
EXECPRG

NSTEP=${NJOB}_72
# Temporary files deletion
#------------------------------------------------------------------------------
LIBEL="Temporary files deletion"
#RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTAR100_O.dat

#[011]
NSTEP=${NJOB}_75
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTAR_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTARMAJ_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        ENTPERY_NF 42:1 - 42:,
        ENTPERMTH_NF 43:1 - 43:,
        VALPERY_NF 44:1 - 44:,
        VALPERMTH_NF 45:1 - 45:,
        TRN_NT 46:1 - 46:,
        ACCTYP_NF 47:1 - 47:,
        BALSHEY_NF 48:1 - 48:,
        BALSHRMTH_NF 49:1 - 49:,
        BALSHRDAY_NF 50:1 - 50:,
        COMMAC_LL 51:1 - 51:,
        SPEENTTYP_CF 52:1 - 52:,
        SPEENTNAT_CT 53:1 - 53:,
        EVT_NF 54:1 - 54:,
        REVT_NF 55:1 - 55:
/KEYS   SSD_CF,
        ESB_CF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ENTPERY_NF,
        ENTPERMTH_NF,
        VALPERY_NF,
        VALPERMTH_NF,
        TRN_NT,
        ACCTYP_NF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        COMMAC_LL,
        SPEENTTYP_CF,
        SPEENTNAT_CT,
        EVT_NF,
        REVT_NF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_78
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
#RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTAR_O1.dat
#RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTARMAJ_O2.dat

#[011]
NSTEP=${NJOB}_80
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of LT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, AMT_M 19:1 - 19:, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:, ENTPERY_NF 42:1 - 42:, ENTPERMTH_NF 43:1 - 43:, VALPERY_NF 44:1 - 44:, VALPERMTH_NF 45:1 - 45:, TRN_NT 46:1 - 46:, ACCTYP_NF 47:1 - 47:, BALSHEY_NF 48:1 - 48:, BALSHRMTH_NF 49:1 - 49:, BALSHRDAY_NF 50:1 - 50:, COMMAC_LL 51:1 - 51:, SPEENTTYP_CF 52:1 - 52:, SPEENTNAT_CT 53:1 - 53:, EVT_NF 54:1 - 54:, REVT_NF 55:1 - 55:
/COPY
/CONDITION TYP1 ACCTYP_NF EQ "1"
/DERIVEDFIELD SEPA "~"
/DERIVEDFIELD TYP_NF IF TYP1 THEN "00" ELSE "98" CHAR 2
/DERIVEDFIELD ZERO "0" CHAR 1
/DERIVEDFIELD VIDE ""
/DERIVEDFIELD CRE_D "${CRE_D}"
/DERIVEDFIELD LSTUPDUSR_CF "AG"
/OUTFILE ${SORT_O}
/REFORMAT TYP_NF, SEPA, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, ZERO, SEPA, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, TRN_NT, COMMAC_LL, CRE_D, SEPA, VIDE, SEPA, CRE_D, SEPA, LSTUPDUSR_CF, SEPA, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT

NSTEP=${NJOB}_85
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_SORT_FACCSUP_O.dat

NSTEP=${NJOB}_90
# Selection of the largest TRN_NT from TACCSUP
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from TACCSUP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select max(TRN_NT) from BEST..TACCSUP"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O.dat
BCP

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${BCP_O}`

NSTEP=${NJOB}_95
# Adding an identity column to the Acceptance TL
#-----------------------------------------------------------------------------
LIBEL="Adding an identity column to the Accetance TL"
PRG=ESTC8800
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TRN_NT ${TRNMAX_NT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_FACCSUP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCSUP_O.dat
EXECPRG

NSTEP=${NJOB}_100
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_FACCSUP_O.dat

NSTEP=${NJOB}_105
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Transfer of service writing file into BEST..TACCSUP table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_95_${IB}_ESTC8800_FACCSUP_O.dat
BCP_TABLE="BEST..TACCSUP"
BCP

NSTEP=${NJOB}_110
# Update of double entry transaction code
#------------------------------------------------------------------------------
LIBEL="Update of double entry transaction code"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuACCSUP_02 ${TRNMAX_NT}"
ISQL

NSTEP=${NJOB}_115
# Deletion of temporary files
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
#RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

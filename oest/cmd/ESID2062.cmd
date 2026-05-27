#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 italian TOTGTAR blanking accumulation
# nom du script SHELL		: ESID2062.cmd
# revision			: $Revision:   1.18  $
# date de creation		: 22/11/2004
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   creation italian TOTGTAR blanking accumulation
#
# Input files
#       EST_TOTGTAA       DFILP
#       EST_FCES            DFILI
#       EST_FDETTRS         DFILP
#       EST_FRETTRF         DFILP
#       EST_FPLC            DFILP
#       EST_FCURCVSNI       DFILP
#       EST_FCURQUOT        DFILP
#       EST_FCURCVSN        DFILP
#
# Output files
#       EST_DLTOTITGTAR      DFILI
#
# Launch C program ESTC2303 ESTC2304
#
# job launched by ESID2060.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 29/06/2012 R. CASSIS     :spot:23802 - Gzip fichiers pour optimisation
#[002] 05/10/2015 -=Dch=-       :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[003] 27/04/2016 R. CASSIS     :spot:30516 - nouveau format Gt et Gzip fichiers pour optimisation
#[004] 30/10/2019 M. NAJI       :spot:81838 - Commenter le zip de EST_IGTAAF
#[005] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Recupere arguments d'entree
BALSHTYEA_NF=$1
CLODAT_D=$2

# Calcul de la date BILAN - 1
BALSHTYEA1_NF=`expr ${BALSHTYEA_NF} - 1`

# Initialise JOB
JOBINIT

NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="SORT ${EST_TOTGTAA} & extract PNAFAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O1.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
	      BALSHRMTH_NF  4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5:EN,
	      TRNCOD_CF 6:1 - 6:,
	      TRNCOD1_CF 6:1 - 6:1 ,
	      TRNCOD2_CF 6:2 - 6:2 EN,
	      TRNCOD2C_CF 6:2 - 6:2 ,
	      TRNCOD8_CF 6:8 - 6:8 EN,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
/CONDITION PNAFAR ( TRNCOD_CF = "1C410000" or TRNCOD_CF = "1C430000")
/OUTFILE ${SORT_O}
/INCLUDE PNAFAR
/REFORMAT SSD_CF,
             ESB_CF,
             BALSHEY_NF,
             BALSHRMTH_NF,
             BALSHRDAY_NF,
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
             AMT_M,
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
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF
exit
EOF
SORT

# ajout step

NSTEP=${NJOB}_10
# Begin sort
#----------------------------------------------------------------------------
LIBEL="SORT  TOTGTAA_O1 & UWY = BALSHTYEA_NF  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
	      BALSHRMTH_NF  4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5:EN,
	      TRNCOD_CF 6:1 - 6:,
	      TRNCOD1_CF 6:1 - 6:1 ,
	      TRNCOD2_CF 6:2 - 6:2 EN,
	      TRNCOD2C_CF 6:2 - 6:2 ,
	      TRNCOD8_CF 6:8 - 6:8 EN,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
/DERIVEDFIELD UWY "${BALSHTYEA1_NF}~"
/CONDITION MOD_UWY UWY_NF = "${BALSHTYEA_NF}"
/OUTFILE ${SORT_O}
/INCLUDE MOD_UWY
/REFORMAT SSD_CF,
             ESB_CF,
             BALSHEY_NF,
             BALSHRMTH_NF,
             BALSHRDAY_NF,
             TRNCOD_CF,
             DBLTRNCOD_CF,
             CTR_NF,
             END_NT,
             SEC_NF,
             UWY,
             UW_NT,
             OCCYEA_NF,
             ACY_NF,
             SCOSTRMTH_NF,
             SCOENDMTH_NF,
             CLM_NF,
             CUR_CF,
             AMT_M,
             CED_NF,
             BRK_NF,
             PAY_NF,
             KEY_NF,
             RETCTR_NF,
             RETEND_NT,
             RETSEC_NF,
             UWY,
             RETUW_NT,
             RETOCCYEA_NF,
             RETACY_NF,
             RETSCOSTRMTH_NF,
             RETSCOENDMTH_NF,
             RCL_NF,
             RETCUR_CF,
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin sort
#----------------------------------------------------------------------------
LIBEL="SORT  TOTGTAA_O1 & UWY = BALSHTYEA_NF  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O3.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
	      BALSHRMTH_NF  4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5:EN,
	      TRNCOD_CF 6:1 - 6:,
	      TRNCOD1_CF 6:1 - 6:1 ,
	      TRNCOD2_CF 6:2 - 6:2 EN,
	      TRNCOD2C_CF 6:2 - 6:2 ,
	      TRNCOD8_CF 6:8 - 6:8 EN,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
/CONDITION MOD_UWY UWY_NF = "${BALSHTYEA_NF}"
/OUTFILE ${SORT_O}
/OMIT MOD_UWY
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin sort
#----------------------------------------------------------------------------
LIBEL="MERGE TOTGTAA_O2 & TOTGTAA_O3 ==> TOTGTAA_O4 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAA_O2.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_TOTGTAA_O3.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O4.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
	      BALSHRMTH_NF  4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5:EN,
	      TRNCOD_CF 6:1 - 6:,
	      TRNCOD1_CF 6:1 - 6:1 ,
	      TRNCOD2_CF 6:2 - 6:2 EN,
	      TRNCOD2C_CF 6:2 - 6:2 ,
	      TRNCOD8_CF 6:8 - 6:8 EN,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_O1.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_TOTGTAA_O2.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_TOTGTAA_O3.dat

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCES_O1.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3: ,
        UWY_NF 4:1 - 4: ,
        UW_NT 5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF 9:1 - 9: ,
        RETUW_NT 10:1 - 10:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION RETP95 ( RETCTR_NF EQ "06P000095" OR RETCTR_NF EQ "06P000101" )
/INCLUDE RETP95
exit
EOF
SORT


NSTEP=${NJOB}_35
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying cessions..."
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_TOTGTAA_O4.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FCES_O1.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARPNAF_O.dat
EXECPRG

NSTEP=${NJOB}_40
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_TOTGTAA_O4.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FCES_O1.dat

NSTEP=${NJOB}_45
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% retro TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_35_${IB}_ESTC2303_GTARPNAF_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARPNAF_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12: ,
        OCCYEA_NF 13:1 - 13: ,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16: ,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25: ,
        RETSEC_NF 26:1 - 26: ,
        RETRTY_NF 27:1 - 27: ,
        RETUW_NT 28:1 - 28: ,
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT ,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
exit
EOF
SORT


NSTEP=${NJOB}_50
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_35_${IB}_ESTC2303_GTARPNAF_O.dat

NSTEP=${NJOB}_55
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying placements..."
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 1
CURQUOT_YEAR ${BALSHTYEA_NF}
GTE_B 0
PRS 50 
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_GTARPNAF_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARPNAF_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJPNAF_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRPNAF_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJPNAF_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_45_${IB}_SORT_GTARPNAF_O.dat     > ${DFILT}/${NJOB}_45_SORT_GTARPNAF_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTARPNAF_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTARPNAF_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJPNAF_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTARMAJPNAF_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRPNAF_O3.dat     > ${DFILT}/${NSTEP}_${PRG}_GTRPNAF_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJPNAF_O4.dat  > ${DFILT}/${NSTEP}_${PRG}_GTRMAJPNAF_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_60
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_GTARPNAF_O.dat

NSTEP=${NJOB}_65
# Begin sort
#----------------------------------------------------------------------------
LIBEL="SORT  GTARPNAF_O1 & ACY = BALSHTYEA_NF - 1 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTARPNAF_O1.dat 1000 1"
SORT_O=${EST_DLTOTITGTAR}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
	      BALSHRMTH_NF  4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5:EN,
	      TRNCOD_CF 6:1 - 6:,
	      TRNCOD1_CF 6:1 - 6:1 ,
	      TRNCOD2_CF 6:2 - 6:2 EN,
	      TRNCOD2C_CF 6:2 - 6:2 ,
	      TRNCOD8_CF 6:8 - 6:8 EN,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        BALSHTYEA1_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        BALSHTYEA1_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      TRN_NT,
      RETROAUTO_B
/DERIVEDFIELD ACY "${BALSHTYEA1_NF}~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
             ESB_CF,
             BALSHEY_NF,
             BALSHRMTH_NF,
             BALSHRDAY_NF,
             TRNCOD_CF,
             DBLTRNCOD_CF,
             CTR_NF,
             END_NT,
             SEC_NF,
             UWY_NF,
             UW_NT,
             OCCYEA_NF,
             ACY,
             SCOSTRMTH_NF,
             SCOENDMTH_NF,
             CLM_NF,
             CUR_CF,
             AMT_M,
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
             ACY,
             RETSCOSTRMTH_NF,
             RETSCOENDMTH_NF,
             RCL_NF,
             RETCUR_CF,
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF,
             RETINTAMT_M
exit
EOF
SORT

#[001]
#[004]
NSTEP=${NJOB}_69
# gzip du fichier pour optimisation
#------------------------------------------------------------------------------
LIBEL="gzip fichiers pour optimisation"
EXECKSH_MODE=P
RMFIL "${EST_IGTAAF}.gz"
#
#EXECKSH "gzip ${EST_IGTAAF}"

NSTEP=${NJOB}_70
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTARPNAF_O1.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTARMAJPNAF_O2.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTRPNAF_O3.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTRMAJPNAF_O4.dat

JOBEND


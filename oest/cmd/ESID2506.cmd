#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Retrocession closing period process
# nom du script SHELL		: ESID2506.cmd
# revision			: $Revision:   1.4  $
# date de creation		: 05/08/1998
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description :
#
#   This job computes four Technical Ledger (TL) files :
#   - retrocession-per-acceptance (AR) TL of outstanding Retro file for
#   RP Fac UPR and DAC (EST_DLRTFGTAR)
#   - retrocession-per-retrocessionnaire (RR) TL of outstanding Retro file for
#   RP Fac UPR and DAC (EST_DLRTFGTR)
#
#
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_MVTPNA_O.dat
# 		   ${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
#  		   ${EST_DLRTFGTAR}
#		   ${DFILT}/${NSTEP}_${IB}_SORT_DLRTFGTR_O.dat
#		   ${EST_DLRTFGTR}
#  		   ${DFILT}/${NSTEP}_${IB}_SORT_MVTPNA_O.dat
#
#
#
# Launch C programs ESTC2303 and ESTC2304
# JOB LAUNCHED BY : ESID2500.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   30/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m
#[002] 24/07/2012 R. Cassis  :spot:23802 Solvency - Ajout 16 champs dans tris
#[003] 05/10/2015 -=Dch=-  :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[004] 02/02/2016 Florent  :spot:29066 GT à 71 colonnes
#[005] 02/05/2016 R. Cassis :spot:30516 Ajout dans les clés des tris les colonnes trn_nt et retroauto_b
#[006] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
BALSHTYEA_NF=$1
ICLODAT_D=$2

ICLODAT_YEA=`echo "${ICLODAT_D}" | cut -c1-4`
ICLODAT_MTH=`echo "${ICLODAT_D}" | cut -c5-6`
ICLODAT_DAY=`echo "${ICLODAT_D}" | cut -c7-8`

echo ${ICLODAT_D}
echo ${ICLODAT_YEA}
echo ${ICLODAT_MTH}
echo ${ICLODAT_DAY}


#[002]
NSTEP=${NJOB}_05
# Begin sort
#[003]
#-----------------------------------------------------------------------------
LIBEL="Sort and filter of UPR FAC file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_MVTPNA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_MVTPNA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD8_CF 6:8 - 6:8,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12: ,
        OCCYEA_NF 13:1 - 13: ,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16: ,
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
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32: ,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        FIN 42:1 - 71:
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
/DERIVEDFIELD ZERO "0.000~"  CHAR 6
/CONDITION BILAN ( BALSHEY_NF = ${ICLODAT_YEA} and
           BALSHRMTH_NF = ${ICLODAT_MTH} and
           BALSHRDAY_NF = ${ICLODAT_DAY} ) and ( TRNCOD8_CF = "0" )
/OUTFILE ${SORT_O}
/INCLUDE BILAN
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
          RETKEY_CF,
          ZERO,
          FIN
          
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Filter of cessions file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCES}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTRCAT_CF 16:1 - 16: EN
/COPY
/CONDITION RPFAC ( RETCTRCAT_CF = 5 or RETCTRCAT_CF = 7 or RETCTRCAT_CF = 8)
/INCLUDE RPFAC
exit
EOF
SORT


NSTEP=${NJOB}_15
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying cessions..."
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_MVTPNA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_FCES_O.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_20
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_MVTPNA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FCES_O.dat

NSTEP=${NJOB}_25
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% retro TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC2303_GTAR100_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
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

NSTEP=${NJOB}_30
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_35
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
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRTFGTAR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRTFMAJGTAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_GTAR100_O.dat       > ${DFILT}/${NJOB}_25_SORT_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DLRTFGTAR_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_DLRTFGTAR_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DLRTFMAJGTAR_O2.dat > ${DFILT}/${NSTEP}_${PRG}_DLRTFMAJGTAR_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat          > ${DFILT}/${NSTEP}_${PRG}_GTR_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat       > ${DFILT}/${NSTEP}_${PRG}_GTRMAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_37
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_GTAR100_O.dat


NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_35_${IB}_ESTC2304_DLRTFGTAR_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLRTFGTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
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
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
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
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_42
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_35_${IB}_ESTC2304_DLRTFGTAR_O1.dat


NSTEP=${NJOB}_45
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Transformation of transaction code suffix 0 -> 4"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_DLRTFGTAR_O.dat"
SORT_O="${EST_DLRTFGTAR}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 5:,
        TRNCOD_CF 6:1 - 6:7,
        FILLER2 7:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/COPY
/DERIVEDFIELD SUFFIXE "4"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,
          TRNCOD_CF,
          SUFFIXE,
          SEPARATEUR,
          FILLER2,
          RETKEY_CF,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_50
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_DLRTFGTAR_O.dat

NSTEP=${NJOB}_55
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_ESTC2304_GTR_O3.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRTFGTR_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12: ,
        OCCYEA_NF 13:1 - 13: ,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16: ,
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
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32: ,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_30_COLS 42:1 - 71:
/KEYS TRNCOD_CF,
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
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
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
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_60
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_35_${IB}_ESTC2304_GTR_O3.dat

NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Transformation of transaction code suffix 0 -> 4"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_DLRTFGTR_O.dat"
SORT_O="${EST_DLRTFGTR}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 5:,
        TRNCOD_CF 6:1 - 6:7,
        FILLER2 7:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/COPY
/DERIVEDFIELD SUFFIXE "4"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,
          TRNCOD_CF,
          SUFFIXE,
          SEPARATEUR,
          FILLER2,
          RETKEY_CF,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


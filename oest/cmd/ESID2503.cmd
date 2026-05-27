#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES
#                                 Retrocession closing period process
# nom du script SHELL           : ESID2503.cmd
# revision                      : $Revision:   1.3  $
# date de creation              : 06/10/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# Description :
#  Generation of Technical Ledgers (TL) files from outsanding retro transactions
#
#   This job computes four TL files :
#   - Retrocession per acceptance (AR) TL of outsanding 100% retro
#     transactions (EST_DLRTCGTAR)
#   - Retrocession per retrocessionaire (RR) TL of outsanding 100% retro
#     transactions (EST_DLRTCGTR)
#   - Retrocession per acceptance (AR) TL of outsanding input and calculated
#     transactions (EST_DLRTGTAR)
#   - Retrocession per retrocessionaire (RR) TL of outsanding input and
#     calculated transactions (EST_DLRTGTR)
#
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_TOUTTRAA_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_TOUTTRAI_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_GT100_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_GTPART_O.dat
#		   ${EST_DLRTCGTAR}
#	      ${EST_DLRTCGTR}
#
# Launch C programs ESTC2307,2309,2304 and 2310
#
# JOB LAUNCHED BY : ESID2500.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   30/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m
#[02] 08/06/2012 R. CASSIS     :spot:23802 - Gzip fichier pour optimisation Solvency
#[03] 11/03/2014 R. CASSIS     :spot:25427 - Gzip fichiers temporaires pour debug
#[04] 02/02/2016 Florent  :spot:29066 GT à 71 colonnes
#[05] 30/10/2019 M. NAJI  :spot:81838 - Commenter les gzip de EST_FOUTTRAI
#[06] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
BALSHTYEA_NF=$1
CLODAT_D=$2

ECHO_LOG "---------------------------------------"
ECHO_LOG "==> BALSHTYEA_NF........: ${BALSHTYEA_NF}"
ECHO_LOG "==> CLODAT_D............: ${CLODAT_D}"
ECHO_LOG "---------------------------------------"

NSTEP=${NJOB}_05
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sorting 100% outsdanding retrocession transactions..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FOUTTRAA}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOUTTRAA_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RTY_NF 2:1 - 2: ,
        RETSEC_NF 3:1 - 3:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sorting outstanding calculated and input transactions..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FOUTTRAI}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOUTTRAI_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 2:1 - 2:,
        RTY_NF 3:1 - 3: ,
        RETSEC_NF 5:1 - 5:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_15
# gzip du fichier pour optimisation
#------------------------------------------------------------------------------
LIBEL="gzip fichiers pour optimisation"
EXECKSH_MODE=P
RMFIL ${EST_FOUTTRAI}.gz
#EXECKSH "gzip ${EST_FOUTTRAI}"

NSTEP=${NJOB}_20
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Screening outstanding transactions..."
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT ${CLODAT_D}
exit
EOF
PRG=ESTC2307
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_TOUTTRAA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_10_${IB}_SORT_TOUTTRAI_O.dat
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT100_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTPART_O2.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_TOUTTRAA_O.dat   > ${DFILT}/${NJOB}_05_SORT_TOUTTRAA_O.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_TOUTTRAI_O.dat   > ${DFILT}/${NJOB}_10_SORT_TOUTTRAI_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT100_O1.dat     > ${DFILT}/${NSTEP}_ESTC2307_GT100_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTPART_O2.dat    > ${DFILT}/${NSTEP}_ESTC2307_GTPART_O2.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_TOUTTRAA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_TOUTTRAI_O.dat

#[002]
NSTEP=${NJOB}_30
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sorting 100% outstanding retro transactions file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2307_GT100_O1.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT100_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF    8:1 -  8:,
        END_NT    9:1 -  9:,
        SEC_NF   10:1 - 10:,
        UWY_NF   11:1 - 11:,
        UW_NT    12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_35
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC2307_GT100_O1.dat

#[002]
NSTEP=${NJOB}_40
# Begin sort
[004]
#------------------------------------------------------------------------------
LIBEL="Sorting outstanding calculated and input transactions file... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2307_GTPART_O2.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTPART_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_45
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC2307_GTPART_O2.dat

NSTEP=${NJOB}_50
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Get cedant/intermediary/payee/key numbers from the perimeter..."
PRG=ESTC2309
export ${PRG}_I1=${EST_IADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_GT100_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_40_${IB}_SORT_GTPART_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT100_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTPART_O2.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_GT100_O.dat      > ${DFILT}/${NJOB}_30_SORT_GT100_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_GTPART_O.dat     > ${DFILT}/${NJOB}_40_SORT_GTPART_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT100_O1.dat     > ${DFILT}/${NSTEP}_ESTC2309_GT100_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTPART_O2.dat    > ${DFILT}/${NSTEP}_ESTC2309_GTPART_O2.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_55
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_GT100_O.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTPART_O.dat

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% outsdanting retro transactions file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2309_GT100_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GT100_O.dat
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
        RTY_NF 27:1 - 27: ,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
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
      SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_65
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2309_GT100_O.dat

NSTEP=${NJOB}_70
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Generation of TL files from 100% outsanding retro transactions"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 1
CURQUOT_YEAR ${BALSHTYEA_NF}
GTE_B 0 
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_GT100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}

export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ100_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR100_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ100_O4.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_GT100_O.dat        > ${DFILT}/${NJOB}_60_SORT_GT100_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat     > ${DFILT}/${NSTEP}_ESTC2304_GTAR100_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ100_O2.dat  > ${DFILT}/${NSTEP}_ESTC2304_GTARMAJ100_O2.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTR100_O3.dat      > ${DFILT}/${NSTEP}_ESTC2304_GTR100_O3.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ100_O4.dat   > ${DFILT}/${NSTEP}_ESTC2304_GTRMAJ100_O4.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_72
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GT100_O.dat


NSTEP=${NJOB}_75
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTAR100_O1.dat 1 1000"
SORT_I2=${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTARMAJ100_O2.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTPART_O.dat 1 1000"
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
        RETINTAMT_M 41:1 - 41: EN 15/3
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
        PLC_NT
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
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTAR100_O1.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTARMAJ100_O2.dat

NSTEP=${NJOB}_80
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merging AR TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_GTPART_O.dat 1000 1"
SORT_O="${EST_DLRTCGTAR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_85
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_75_${IB}__SORT_GTPART_O.dat

NSTEP=${NJOB}_90
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merging and summarizing RR TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTR100_O3.dat
SORT_I2=${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTRMAJ100_O4.dat
SORT_O="${EST_DLRTCGTR} OVERWRITE"
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
        RETINTAMT_M 41:1 - 41: EN 15/3,
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
      PLC_NT
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

NSTEP=${NJOB}_95
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTR100_O3.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2304_GTRMAJ100_O4.dat

NSTEP=${NJOB}_100
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting outsdanding calculated and input transactions..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2309_GTPART_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTPART_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25: ,
        RETSEC_NF 26:1 - 26: ,
        RTY_NF 27:1 - 27: ,
        RETUW_NT 28:1 - 28: ,
        PLC_NT 36:1 - 36:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_105
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2309_GTPART_O2.dat

NSTEP=${NJOB}_110
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Generation of TL files from outstanding calculated and input transactions"
PRG=ESTC2310
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_GTPART_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTPART_O.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_GTPART_O.dat  > ${DFILT}/${NJOB}_100_SORT_GTPART_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2310_GTPART_O.dat > ${DFILT}/${NSTEP}_ESTC2310_GTPART_O.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_115
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_GTPART_O.dat

#[002]
NSTEP=${NJOB}_120
# Begin sort
#[004]
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_110_${IB}_ESTC2310_GTPART_O.dat
SORT_O="${EST_DLRTGTAR} OVERWRITE"
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
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RCL_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      TRNCOD_CF,
      RETCUR_CF,
      PLC_NT
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SEP "~"
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
          AMT_MC,
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
          SEP,
          SEP,
          SEP,
          SEP,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_125
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_110_${IB}_ESTC2310_GTPART_O.dat
SORT_O="${EST_DLRTGTR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        DBLTRNCOD_CF 7:1 - 7: ,
        TRNCOD_CF 6:1 - 6:,
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
        RETKEY_CF 40:1 -40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RCL_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      TRNCOD_CF,
      RETCUR_CF,
      PLC_NT
/SUMMARIZE  TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD SEP "~"
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
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
          SEP,
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

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_130
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

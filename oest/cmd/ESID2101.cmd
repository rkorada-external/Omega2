#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Closing period process for SNEM
# nom du script SHELL		: ESID2101.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 05/08/1998
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description :
#
#   This job computes three Technical Ledger (TL) files :
#   - acceptance (AA) TL of estimates for SNEM
#   - retrocession-per-acceptance (AR) TL of estimates and actualized
#     not including raised commissions (EST_DLGTARSNEM)
#   - retrocession-per-retrocessionnaire (RR) TL of estimates and actualized
#     not including raised commissions (EST_DLGTRSNEM)
#
#   and a working file of SNEM (EST_DLFTSNEMHIST)
#
# Input files
#       EST_DLDGTAA                   DFILP
#       EST_DLGTAASNEM        DFILI
#       EST_DLRGTAA           DFILI
#       EST_DSUMGTAASNEM              DFILP
#       EST_FCES                      DFILP
#       EST_FCURCVSNI         DFILI
#       EST_FCURQUOT                  DFILP
#       EST_FDETTRS           DFILI
#       EST_FLOARATSNEM               DFILP
#       EST_FPLC                      DFILP
#       EST_FRETTRF           DFILI
#       EST_FSNEMHIST                 DFILP
#       EST_PERICASESNEM              DFILP
#
# Output files
#       EST_DLFTSNEMHIST     DFILI
#       EST_DLGTAASNEM       DFILI
#       EST_DLGTARSNEM       DFILI
#       EST_DLGTRSNEM        DFILI
#
# Launch C program ESTC2303 ESTC2304 ESTM1011
#
# JOB LAUNCHED BY : ESID2100.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01] 31/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m
# [02] 05/10/2015 -=Dch=-  :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
# [03] 01/02/2016 Florent  :spot:29066 GT à 71 colonnes
# [04] 26/04/2016 Roger    :spot:30516 GT à 71 colonnes (pas le CLM_NF dans le tri avant ESTC2304 car trn_nt et retroauto_b sont priotitaires)
# [005] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
ICLODAT_D=$1
BALSHTYEA_NF=$2


NSTEP=${NJOB}_00
#Last version of ESID2000 files deletion
#-----------------------------------------------------------------
 RMFIL "  `dirname ${EST_DLFTSNEMHIST}`/${PCH}ESID2100_DLFTSNEMHIST*.dat
 `dirname ${EST_DLGTAASNEM}`/${PCH}ESID2100_DLGTAASNEM*.dat
 `dirname ${EST_DLGTRSNEM}`/${PCH}ESID2100_DLGTRSNEM*.dat
 `dirname ${EST_DLGTARSNEM}`/${PCH}ESID2100_DLGTARSNEM*.dat"

NSTEP=${NJOB}_02
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Compute of SNEMs"
PRG=ESTM1011
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_FCURQUOT}
export ${PRG}_I2=${EST_PERICASESNEM}
export ${PRG}_I3=${EST_FSNEMHIST}
export ${PRG}_I4=${EST_DSUMGTAASNEM}
export ${PRG}_I5=${EST_DLDGTAA}
export ${PRG}_I6=${EST_DLRGTAA}
export ${PRG}_I7=${EST_FLOARATSNEM}
export ${PRG}_O1=${EST_DLFTSNEMHIST}
export ${PRG}_O2=${EST_DLGTAASNEM}
EXECPRG

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merging and sorting acceptance TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTAASNEM}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        TRNCOD_CF 6:1 - 6:,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:
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

NSTEP=${NJOB}_10
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
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${EST_FCES}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_15
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat

NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% retro TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat
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
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25: ,
        RETSEC_NF 26:1 - 26: ,
        RETRTY_NF 27:1 - 27: ,
        RETUW_NT 28:1 - 28: ,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
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

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_30
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
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_GTAR100_O.dat  > ${DFILT}/${NJOB}_20_SORT_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTAR_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTARMAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat     > ${DFILT}/${NSTEP}_${PRG}_GTR_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat  > ${DFILT}/${NSTEP}_${PRG}_GTRMAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_33
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary & permanent files deletion ..."
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_35
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR_O1.dat
SORT_O="${EST_DLGTARSNEM}"
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
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_38
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR_O1.dat

NSTEP=${NJOB}_40
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTR_O3.dat"
SORT_O="${EST_DLGTRSNEM} OVERWRITE"
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
        FILLER_14_COLS 42:1 - 55:,
        TRN_NT 56:1 - 56:,
        FILLER_1_COLS 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_13_COLS 59:1 - 71:
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
          FILLER_14_COLS,
          TRN_NT,
          FILLER_1_COLS,
          RETROAUTO_B,
          FILLER_13_COLS
exit
EOF
SORT

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_55
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Retrocession closing period process
# nom du script SHELL		: ESID2505.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 06/10/1997
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description :
#   Taking into account of cedent's reserves from a non proportional
#   treaty or from a facultative in a pool
#
#   This job computes 2 Technical Ledger (TL) files :
#   - retrocession-per-acceptance (AR) TL of non proportional and facultatives
#     reserves (EST_DLRPGTAR)
#   - retrocession-per-retrocessionnaire (RR) TL of non proportional and
#     facultatives reserves (EST_DLRPGTAR)
#
#
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
#		   ${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
#                  ${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat
#
#
#
# Launch C programs ESTC2311,2303,2304 and 2312
# JOB LAUNCHED BY: ESID2500.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#[01] 30/01/2003 J. Ribot    ajout gestion colonne retintamt_m
#[02] 14/03/2011 R. CASSIS   :spot:21408 - Reduction des fichiers au format GT 41 col.
#[03] 09/05/2011 D.GATIBELZA :spot:21408 OneLedger
#[04] 24/07/2012 R. Cassis   :spot:23802 Solvency - Ajout 16 champs dans tris
#[05] 05/10/2015 -=Dch=-     :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[06] 02/02/2016 Florent     :spot:29066 GT à 71 colonnes
#[07] 12/05/2016 -=Dch=-     :spot:29162 - Suppression des step 75 et 85 et remplacement des sorties des steps 65 et 72 par EST_DLRPGTAR et ESTDLRPGTR
#[08] 02/05/2016 R. Cassis :spot:30516 Ajout dans les clés des tris les colonnes trn_nt et retroauto_b
#[09] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
BALSHTYEA_NF=$1
CLODAT_D=$2


#[002] Reduction au format 41 col
NSTEP=${NJOB}_05
# Begin sort*
#[003] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAAF} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF    8:1 - 8:,
        END_NT    9:1 - 9:,
        SEC_NF   10:1 - 10:,
        UWY_NF   11:1 - 11:,
        UW_NT    12:1 - 12:,
        FIELD_41  1:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/REFORMAT FIELD_41    
exit
EOF
SORT


NSTEP=${NJOB}_10
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Selection of acceptance reserves NP and facultatives..."
PRG=ESTC2311
export ${PRG}_I1=${EST_IADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat
export ${PRG}_I3=${EST_FRETPAR}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAA_O.dat
EXECPRG

NSTEP=${NJOB}_15
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat

#(004]
NSTEP=${NJOB}_20
# Begin sort
#[003] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Summarizing acceptance TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2311_GTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat OVERWRITE"
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
        AMT_M 19:1 - 19:EN 15/3,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
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
      CLM_NF,
      CUR_CF,
      OCCYEA_NF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
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
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M,
          FIN
exit
EOF
SORT

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2311_GTAA_O.dat

NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Screening cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCES}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTRCAT_CF 16:1 - 16:
/CONDITION POOLRETRO RETCTRCAT_CF EQ "01"
/INCLUDE POOLRETRO
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_35
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Applying cessions..."
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_CES_O.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_40
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAA_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_CES_O.dat

NSTEP=${NJOB}_45
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% retro TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_ESTC2303_GTAR100_O.dat 1000 1"
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
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
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
      UW_NT,
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
RMFIL ${DFILT}/${NJOB}_35_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_55
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Applying placements..."
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
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_GTAR100_O.dat
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
gzip -c ${DFILT}/${NJOB}_45_${IB}_SORT_GTAR100_O.dat  > ${DFILT}/${NJOB}_45_SORT_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTAR_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTARMAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat     > ${DFILT}/${NSTEP}_${PRG}_GTR_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat  > ${DFILT}/${NSTEP}_${PRG}_GTRMAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_60
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_65
# Begin sort
#[003] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Summarizing RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTR_O3.dat 1000 1"
#SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat
SORT_O=${EST_DLRPGTR}
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
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE  TOTAL RETAMT_M,
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

NSTEP=${NJOB}_70
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTR_O3.dat

NSTEP=${NJOB}_72
# Begin sort
#[003] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTAR_O1.dat 1000 1"
#SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O.dat
SORT_O=${EST_DLRPGTAR}
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

NSTEP=${NJOB}_73
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTAR_O1.dat

NSTEP=${NJOB}_75
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Transformation of reserves transaction codes into estimates in AR TL..."
PRG=ESTC2312
export ${PRG}_I1=${DFILT}/${NJOB}_72_${IB}_SORT_GTAR_O.dat
export ${PRG}_I2=${EST_FRETPAR}
export ${PRG}_O1=${EST_DLRPGTAR}
#EXECPRG

NSTEP=${NJOB}_80
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2304_GTAR_O1.dat

NSTEP=${NJOB}_85
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Transformation of reserves transaction codes into estimates in RR TL..."
PRG=ESTC2312
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_GTR_O.dat
export ${PRG}_I2=${EST_FRETPAR}
export ${PRG}_O1=${EST_DLRPGTR}
#EXECPRG

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_90
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


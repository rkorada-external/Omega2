#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD1802.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 01/07/2020
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# Input files
#       EST_FACCSUP       DFILI
#       EST_FCES                  DFILP
#       EST_FCURCVSNI     DFILI
#       EST_FCURQUOT              DFILP
#       EST_FDETTRS       DFILI
#       EST_FPLC                  DFILP
#       EST_FRETTRF       DFILI
#
# Output files
#       EST_DLSGTAA       DFILI
#       EST_DLSGTAR       DFILI
#       EST_DLSGTR        DFILI
#
# Job launched by ESFD1800.cmd
#
# Launch C programs ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 27/04/2021 S.Behague : SPIRA 93345 - I17 : RETRO - Life SAP posting - Copy
# [002] 10/10/2022 S.Behague :spira:106934: Life - I17 - RTO Missing (RA View)
# [003] 17/11/2022 S.Behague :spira:107797: Life - I17 - RTO Missing - Complementary issue
# [004] 13/03/2023 S.Behague / MZM:spira:109117 Harmonisation LIfe FPLATXCUMALL ==> FPLATXCUM Et Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
#EST_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FCTRGRO.dat 1000 1 OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN, 
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF    21:1 - 21:,
       	SEGTYP_CT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Merge of OADVPERICASE and IADVPERICASE Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_IADVPERICASE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Merge of ORDVPERICASE0 and IRDVPERICASE0 Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_IRDVPERICASE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
  SORT


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTAA.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        LIGNEGT 1:1 - 39: ,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File format TTCLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTAR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        FILLER_30_COLS  42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_GTAR0 ( TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4" ) 
/INCLUDE COND_GTAR0
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger to format TTCLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD1_CF       6:1 -  6:1,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        LIGNEGT          1:1 - 39: ,
        RETKEY_CF       40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/CONDITION COND_GTR (TRNCOD1_CF EQ "2" or TRNCOD1_CF EQ "4") AND ${EST_SORT_CONDITION}
/DERIVEDFIELD AJOUT_11_COLS 11"~"
/INCLUDE COND_GTR
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_11_COLS,
          FILLER_16_COLS
exit
EOF
SORT

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_O_IADVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_O_DLSGTAA.dat
export ${PRG}_I3=${DFILT}/${NJOB}_10_${IB}_SORT_O_FCTRGRO.dat
export ${PRG}_I4=${EST_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_40_${IB}_SORT_O_DLSGTAR.dat
export ${PRG}_I6=${EST_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_FTECLEDA_01.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_FTECLEDAR_02.dat
EXECPRG


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8801_SORT_FTECLEDAR_02.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# File generation in TTECLEDR and TTECLEDA tables format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_O_IRDVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_50_${IB}_SORT_O_DLSGTR.dat
export ${PRG}_I4=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG


NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8801_SORT_FTECLEDA_01.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_80_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_80_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
#SORT_O="${ESF_FTECLEDA_I17AELIFE}"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_I17AELIFE_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN 15/3,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 88:1 - 88:EN 15/3
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_95
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2:EN,
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT 

#[004]

NSTEP=${NJOB}_95C
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM CUM
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_95_${IB}_FPLATXCUM.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_90_${IB}_FTECLEDA_I17AELIFE_O.dat"
export ${PRG}_O1=${ESF_FTECLEDA_I17AELIFE}
EXECPRG


#----------------------------------------
# FTECLEDR
#----------------------------------------
  
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25: EN,
        RETSEC_NF   26:1 - 26: EN,
        RTY_NF      27:1 - 27: EN,
        RETUW_NT    28:1 - 28: EN,
        PLC_NT      36:1 - 36: EN
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT


NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
# Update of SSDRTO_B ( internal retrocession )
#[003] remplacement du fichier ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_FPLC_O.dat par ${EST_FPLACEMT2}
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${EST_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
LIBEL="Internal reference addition in the new FTECLEDR file"
PRG=ESTC8804
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_ESTC8803_FTECLEDR_O.dat
export ${PRG}_I2=${EST_FSSDACTR}
export ${PRG}_O1=${ESF_FTECLEDR_I17AELIFE}
EXECPRG


JOBEND


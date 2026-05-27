#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Formatage des ecritures post omega Local GTA et GTR au format GLT
# nom du script SHELL           : ESLD3801.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Formatage des ecritures post omega Local GTA et GTR au format GLT
#
# Input files
#       ESL_DLSGTAALO
#       ESL_DLSGTARLO
#       ESL_DLSGTRLO
#       ESL_DLREJGTAALO
#       ESL_DLREJGTARLO
#       ESL_DLREJGTRLO
#       ESL_FCLIENT
#       ESL_FCPLACC
#       ESL_FCTRGRO
#       ESL_FDETTRS
#       ESL_FPLACEMT2
#       ESL_FSOBBLOB
#       ESL_FSSDACTR
#       ESL_FTECLEDRLO
#       ESL_OIADVPERICASE
#       ESL_OIRDVPERICASE
#       ESL_FSUBTRS
#
# Output files
#       ESL_FTECLEDALO_MVT
#       ESL_FTECLEDALO_MTH
#       ESL_FTECLEDRLO
#
# launched by ESLD3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#---------------
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
BLCSHTYEALOC_NF=$4
BLCSHTMTHLOC_NF=$5

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CRE_D.................: ${CRE_D}"
ECHO_LOG "#===> CONSOYEA..............: ${CONSOYEA}"
ECHO_LOG "#===> CONSOMTH..............: ${CONSOMTH}"
ECHO_LOG "#===> BLCSHTYEALOC_NF.......: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF.......: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> ESL_DLSGTAALO.........: ${ESL_DLSGTAALO}"
ECHO_LOG "#===> ESL_DLSGTARLO.........: ${ESL_DLSGTARLO}"
ECHO_LOG "#===> ESL_DLSGTRLO..........: ${ESL_DLSGTRLO}"
ECHO_LOG "#===> ESL_DLREJGTAALO.......: ${ESL_DLREJGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTARLO.......: ${ESL_DLREJGTARLO}"
ECHO_LOG "#===> ESL_DLREJGTRLO........: ${ESL_DLREJGTRLO}"
ECHO_LOG "#===> ESL_FDETTRS...........: ${ESL_FDETTRS}"
ECHO_LOG "#===> ESL_FCTRGRO...........: ${ESL_FCTRGRO}"
ECHO_LOG "#===> ESL_FCPLACC...........: ${ESL_FCPLACC}"
ECHO_LOG "#===> ESL_FSOBBLOB..........: ${ESL_FSOBBLOB}"
ECHO_LOG "#===> ESL_FCLIENT...........: ${ESL_FCLIENT}"
ECHO_LOG "#===> ESL_FPLACEMT2.........: ${ESL_FPLACEMT2}"
ECHO_LOG "#===> ESL_FSUBTRS...........: ${ESL_FSUBTRS}"
ECHO_LOG "#===> ESL_FSSDACTR..........: ${ESL_FSSDACTR}"
ECHO_LOG "#===> ESL_OIADVPERICASE.....: ${ESL_OIADVPERICASE}"
ECHO_LOG "#===> ESL_OIRDVPERICASE.....: ${ESL_OIRDVPERICASE}"
ECHO_LOG "#========================================================================="

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTAALO} 1000 1"
SORT_I2="${ESL_DLREJGTAALO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAALO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD_CF        6:1 -  6:,
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
/DERIVEDFIELD USER "LocP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_BILAN BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE COND_BILAN
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

NSTEP=${NJOB}_20
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTARLO} 1000 1"
SORT_I2="${ESL_DLREJGTARLO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARLO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD_CF        6:1 -  6:,
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
/DERIVEDFIELD USER "LocP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_BILAN BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE COND_BILAN
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

NSTEP=${NJOB}_30
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in DLSGTAALO in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAALO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAALO.dat
EXECPRG

NSTEP=${NJOB}_40
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in DLSGTARLO in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_DLSGTARLO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARLO.dat
EXECPRG

NSTEP=${NJOB}_50
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${ESL_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_ESTM7603_DLSGTAALO.dat
export ${PRG}_I3=${ESL_FCTRGRO}
export ${PRG}_I4=${ESL_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_40_${IB}_ESTM7603_DLSGTARLO.dat
export ${PRG}_I6=${ESL_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAALO_O.dat    > ${DFILT}/${NJOB}_10_SORT_DLSGTAALO_O.dat.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_DLSGTARLO_O.dat    > ${DFILT}/${NJOB}_20_SORT_DLSGTARLO_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTM7603_DLSGTARLO.dat  > ${DFILT}/${NJOB}_40_ESTM7603_DLSGTARLO.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC8801_FTECLEDAA_O1.dat > ${DFILT}/${NJOB}_50_ESTC8801_FTECLEDAA_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC8801_FTECLEDAR_O2.dat > ${DFILT}/${NJOB}_50_ESTC8801_FTECLEDAR_O2.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_60
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTRLO} 1000 1"
SORT_I2="${ESL_DLREJGTRLO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRLO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "LocP~"
/DERIVEDFIELD AJOUT_11_COLS 11"~"
/CONDITION COND_BILAN BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE COND_BILAN
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

NSTEP=${NJOB}_70
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in DLSGTRLO in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTRLO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRLO.dat
EXECPRG

NSTEP=${NJOB}_80
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC8801_FTECLEDAR_O2.dat > ${DFILT}/${NJOB}_50_ESTC8801_FTECLEDAR_O2.dat.gz
#------------------------------------------------------------------------------
NSTEP=${NJOB}_90
# File generation in TTECLEDR table format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${ESL_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTRLO.dat
export ${PRG}_I4=${ESL_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDA tables format for Retro data"
PRG=ESTC8806
export ${PRG}_I1=${ESL_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTRLO_O.dat   > ${DFILT}/${NJOB}_60_SORT_DLSGTRLO_O.dat.gz 
gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTRLO.dat > ${DFILT}/${NJOB}_70_ESTM7603_DLSGTRLO.dat.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat  > ${DFILT}/${NJOB}_80_SORT_FTECLEDAR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_120
# Update of SSDRTO_B ( internal retrocession )
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${ESL_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDR_O1.dat > ${DFILT}/${NJOB}_90_ESTC8802_FTECLEDR_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_SORT_FTECLEDR_O.dat      > ${DFILT}/${NJOB}_110_SORT_FTECLEDR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC8803_FTECLEDR_O.dat  > ${DFILT}/${NJOB}_120_ESTC8803_FTECLEDR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_130
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_SORT_FTECLEDR_O.dat

NSTEP=${NJOB}_140
# Création du fichier ESL_FTECLEDALO_MVT
#------------------------------------------------------------------------------
LIBEL="Création du fichier ESL_FTECLEDALO_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_100_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDALO_MVT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS COLS1        1:1 -  88:,
        TRN_NT     103:1 - 103:,
        COLS2      105:1 - 118:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD NEW_ORICOL_LS "LOCAL~" 
/OUTFILE ${SORT_O}
/REFORMAT COLS1,PLUS_14_CHAMPS,TRN_NT,NEW_ORICOL_LS,COLS2
exit
EOF
SORT

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDAR_O2.dat > ${DFILT}/${NJOB}_90_ESTC8802_FTECLEDAR_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat > ${DFILT}/${NJOB}_100_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_150
# Merge FTECLEDA_CUR and FTECLEDA_MVT
#--------------------------------
LIBEL="Sort FTECLEDALO_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_FTECLEDALO_MVT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDALO_MVT.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 15/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 15/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	COLS1             1:1 -  18:,
	COLS2            20:1 -  34:,
	COLS3            36:1 -  87:,
	COLS4            89:1 - 118:
	
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
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
	CUR_CF,
	CED_NF,
	RETCTR_NF,
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
	RTO_NF,
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) and BALSHEY_NF > 0
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT COLS1, AMT_MC, COLS2, RETAMT_MC, COLS3, RETINTAMT_MC, COLS4
exit
EOF
SORT

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_140_${IB}_FTECLEDALO_MVT.dat  > ${DFILT}/${NJOB}_140_FTECLEDALO_MVT.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_FTECLEDALO_MVT.dat  > ${DFILT}/${NJOB}_150_FTECLEDALO_MVT.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_160
# Split ESL_FTECLEDALO_MVT
#-----------------------------------------------------------------------------
LIBEL="Omit Analitics from ESL_FTECLEDALO_MVT "
PRG=ESTC8807
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_FTECLEDALO_MVT.dat
export ${PRG}_I2=${ESL_FSUBTRS}
export ${PRG}_O1=${ESL_FTECLEDALO_MVT}
export ${PRG}_O2=${ESL_FTECLEDALO_MTH}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_FTECLEDALO_REP.dat  # la sortie REP ne nous interresse pas ici
EXECPRG

NSTEP=${NJOB}_165
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Touch ${ESL_FTECLEDALO} for next job"
EXECKSH_MODE=P
EXECKSH "touch ${ESL_FTECLEDALO}"

NSTEP=${NJOB}_170
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Sort new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_180
# Internal reference addition in the new FTECLEDR file
#-----------------------------------------------------------------------------
LIBEL="Internal reference addition in the new FTECLEDR file"
PRG=ESTC8804
export ${PRG}_I1=${DFILT}/${NJOB}_170_${IB}_MERGE_FTECLEDR_O.dat
export ${PRG}_I2=${ESL_FSSDACTR}
export ${PRG}_O1=${ESL_FTECLEDRLO}
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC8803_FTECLEDR_O.dat > ${DFILT}/${NJOB}_120_ESTC8803_FTECLEDR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_FTECLEDALO_MVT.dat      > ${DFILT}/${NJOB}_150_FTECLEDALO_MVT.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_MERGE_FTECLEDR_O.dat    > ${DFILT}/${NJOB}_170_MERGE_FTECLEDR_O.dat.gz
#------------------------------------------------------------------------------

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_200
NSTEP=${NJOB}_26
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

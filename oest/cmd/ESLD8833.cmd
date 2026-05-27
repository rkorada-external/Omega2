#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Ajout des ecritures locales trimestrielles et annuelles aux fichiers GT
# nom du script SHELL           : ESLD8833.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#    Ajout des ecritures locales trimestrielles et annuelles aux fichiers GTA et GTR
#
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT

# Parameters
CONSOYEA=$1
CONSOMTH=$2
INVCONSO_D=$3
CRE_D=$4

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CONSOYEA................: ${CONSOYEA}"
ECHO_LOG "#===> CONSOMTH................: ${CONSOMTH}"
ECHO_LOG "#===> INVCONSO_D..............: ${INVCONSO_D}"
ECHO_LOG "#===> COND1..COMPTA ANNUELLE..: ${EST_ESLD8830_COND1}"
ECHO_LOG "#===> ESL_FTECLEDALO_MVT......: ${ESL_FTECLEDALO_MVT}"
ECHO_LOG "#===> ESL_DLSGTRLO............: ${ESL_DLSGTRLO}"
ECHO_LOG "#===> ESL_DLREJGTAALO.........: ${ESL_DLREJGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTARLO.........: ${ESL_DLREJGTARLO}"
ECHO_LOG "#===> ESL_DLREJGTRLO..........: ${ESL_DLREJGTRLO}"
ECHO_LOG "#===> EST_CURGTALO............: ${EST_CURGTALO}"
ECHO_LOG "#===> EST_CURGTRLO............: ${EST_CURGTRLO}"
ECHO_LOG "#===> EST_STATGTALO...........: ${EST_STATGTALO}"
ECHO_LOG "#===> EST_STATGTRLO...........: ${EST_STATGTRLO}"
ECHO_LOG "#===> EST_ARCSTATGTA..........: ${EST_ARCSTATGTA}"
ECHO_LOG "#===> EST_ARCSTATGTR..........: ${EST_ARCSTATGTR}"
ECHO_LOG "#===> EST_GTALO...............: ${EST_GTALO}"
ECHO_LOG "#===> EST_GTRLO...............: ${EST_GTRLO}"
ECHO_LOG "#===> ESL_CRVPERICASE0........: ${ESL_CRVPERICASE0}"
ECHO_LOG "#========================================================================="

if [ "${EST_ESLD8830_COND1}" = "N" ]
then

  NSTEP=${NJOB}_00
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="reformat du ${ESL_FTECLEDALO_MVT} en fichier CURGTA"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${ESL_FTECLEDALO_MVT} 1000  1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD      1:1 -  40:,
        PLUS_16_CHAMPS      88:1 - 103:,
        FILLER_14_COLS     105:1 - 118:
/DERIVEDFIELD ORICOD_LS "CURGTA_PO~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD, PLUS_16_CHAMPS, ORICOD_LS, FILLER_14_COLS
exit
EOF
  SORT

  NSTEP=${NJOB}_01
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTALO} ${ESL_DLSGTAALO} ${ESL_DLSGTARLO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTALO}    1000 1"
  SORT_I2="${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_05
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTRLO} ${ESL_DLSGTRLO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTRLO}  1000 1"
  SORT_I2="${ESL_DLSGTRLO} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/REFORMAT FIELD1,RETINTAMT,FIN_COLS
exit
EOF
  SORT

  NSTEP=${NJOB}_10
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="Split DLSGTAALO + DLSGTARLO ==>  GTAA, GTAAR "
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O1.dat
  SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD8_CF   6:8 - 6:8
/CONDITION AVANT_PERIODE_ACC ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
                             ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3") AND
                             ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )
/CONDITION AVANT_PERIODE_RETRO ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
                               ( TRNCOD1_CF = "2" or TRNCOD1_CF = "4") AND
                               ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE_ACC

/OUTFILE ${SORT_O2}
/INCLUDE AVANT_PERIODE_RETRO

/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_15
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="APPEND CURGTA"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAR_O2.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF ,
      RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_20
  #Dividing of STATGTR in retrocession by acceptance life and non-life
  #-----------------------------------------------------------------------------
  LIBEL="Eliminating Non-life transactions of GTAR"
  PRG=ESTM7606
  export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_GTAR_O1.dat
  export ${PRG}_I2=${ESL_CRVPERICASE0}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
  export ${PRG}_O3=${ESL_GTRANO}
  EXECPRG

  NSTEP=${NJOB}_25
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation & SORT of files ${EST_STATGTALO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAA_O1.dat 512 1"
  SORT_I2="${DFILT}/${NJOB}_20_${IB}_ESTM7606_GTAR_O2.dat 512 1"
  SORT_I3="${EST_STATGTALO} 512 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_STATGTA_O.dat 512 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
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
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:
/KEYS
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
        OCCYEA_NF ,
        ACY_NF ,
        SCOSTRMTH_NF ,
        SCOENDMTH_NF ,
        CLM_NF,
        CUR_CF
exit
EOF
  SORT

  NSTEP=${NJOB}_30
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_STATGTRLO} ${ESL_DLSGTRLO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_STATGTRLO}  1000 1"
  SORT_I2="${ESL_DLSGTRLO} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_STATGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/REFORMAT FIELD1, RETINTAMT, FIN_COLS
exit
EOF
  SORT

  NSTEP=${NJOB}_35
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTALO + DLSGTAxLO ==> EST_CURGTALO"
  EXECKSH "mv ${DFILT}/${NJOB}_01_${IB}_CURGTA_O.dat ${EST_CURGTALO}"

  NSTEP=${NJOB}_40
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTRLO + ${DFILT}/${NJOB}_05_${IB}_CURGTR_O.dat ==> EST_CURGTRLO"
  EXECKSH "mv ${DFILT}/${NJOB}_05_${IB}_CURGTR_O.dat ${EST_CURGTRLO}"

  NSTEP=${NJOB}_45
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_STATGTALO + DLSGTAxLO ==> EST_STATGTALO"
  EXECKSH "mv ${DFILT}/${NJOB}_25_${IB}_STATGTA_O.dat ${EST_STATGTALO}"

  NSTEP=${NJOB}_50
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_STATGTRLO + ${DFILT}/${NJOB}_30_${IB}_STATGTR_O.dat ==> EST_STATGTRLO"
  EXECKSH "mv ${DFILT}/${NJOB}_30_${IB}_STATGTR_O.dat ${EST_STATGTRLO}"

fi

if [ ${EST_ESLD8830_COND1} = "Y" ]
then
  # COMPTABILISATION ANNUELLE
  NSTEP=${NJOB}_60
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="Split ESL_FTECLEDALO_MVT ==>  GTAA, GTAAR "
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${ESL_FTECLEDALO_MVT} 1000  1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O1.dat
  SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1 ,
        TRNCOD2C_CF  6:2 - 6:2 ,
        TRNCOD8_CF   6:8 - 6:8
/CONDITION AVANT_PERIODE_ACC  ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
        ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3") AND
        ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )
/CONDITION AVANT_PERIODE_RETRO  ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
        ( TRNCOD1_CF = "2" or TRNCOD1_CF = "4") AND
        ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )

/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE_ACC

/OUTFILE ${SORT_O2}
/INCLUDE AVANT_PERIODE_RETRO

/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_65
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="APPEND CURGTA"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTAR_O2.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF ,
        RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_70
  #Dividing of STATGTR in retrocession by acceptance life and non-life
  #-----------------------------------------------------------------------------
  LIBEL="Eliminating Non-life transactions of GTAR"
  PRG=ESTM7606
  export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_GTAR_O1.dat
  export ${PRG}_I2=${ESL_CRVPERICASE0}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
  export ${PRG}_O3=${ESL_GTRANO}
  EXECPRG

  NSTEP=${NJOB}_75
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files GTAx"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_ARCSTATGTA} 1000 1"
  SORT_I2="${DFILT}/${NJOB}_60_${IB}_SORT_GTAA_O1.dat 1000 1"
  SORT_I3="${DFILT}/${NJOB}_70_${IB}_ESTM7606_GTAR_O2.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  SSD_CF 1:1 - 1:,
  ESB_CF 2:1 - 2:,
  BALSHEY_NF 3:1 - 3:,
  BALSHRMTH_NF 4:1 - 4:,
  BALSHRDAY_NF 5:1 - 5:,
  TRNCOD_CF 6:1 - 6:,
  TRNCOD1_CF 6:1 - 6:1,
  TRNCOD8_CF 6:8 - 6:8 EN ,
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
  RETOCCYEA_NF 29:1 - 29:,
  RETACY_NF 30:1 - 30:,
  RETSCOSTRMTH_NF 31:1 - 31:,
  RETSCOENDMTH_NF 32:1 - 32:,
  RCL_NF 33:1 - 33:,
  RETCUR_CF 34:1 - 34:,
  RETAMT_M 35:1 - 35:EN 15/3,
  PLC_NT 36:1 - 36:,
  RTO_NF 37:1 - 37:,
  INT_NF 38:1 - 38:,
  RETPAY_NF 39:1 - 39:,
  RETKEY_CF 40:1 - 40:,
  RETINTAMT_M 41:1 - 41:EN 15/3
/KEYS
  CTR_NF ,
  END_NT ,
  SEC_NF ,
  UWY_NF ,
  UW_NT ,
  OCCYEA_NF ,
  ACY_NF ,
  SCOSTRMTH_NF ,
  SCOENDMTH_NF ,
  CLM_NF,
  CUR_CF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF ,
  RETUW_NT,
  SSD_CF ,
  ESB_CF ,
  BALSHEY_NF,
  TRNCOD_CF,
  DBLTRNCOD_CF ,
  CED_NF ,
  BRK_NF ,
  PAY_NF ,
  KEY_NF ,
  RETOCCYEA_NF ,
  RETACY_NF ,
  RETSCOSTRMTH_NF ,
  RETSCOENDMTH_NF ,
  RCL_NF ,
  RETCUR_CF ,
  PLC_NT ,
  RTO_NF ,
  INT_NF ,
  RETPAY_NF ,
  RETKEY_CF
exit
EOF
  SORT

  NSTEP=${NJOB}_80
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="${ESL_DLSGTRLO} ==> CURGTR"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${ESL_DLSGTRLO} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY      3:1 -  3: EN,
        BALSHTMTH    4:1 -  4: EN,
        TRNCOD_CF    6:1 -  6:,
        TRNCOD1_CF   6:1 -  6:1,
        TRNCOD2C_CF  6:2 -  6:2,
        TRNCOD8_CF   6:8 -  6:8,
        FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/CONDITION AVANT_PERIODE  ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH})
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/REFORMAT FIELD1, RETINTAMT, FIN_COLS
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_82
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="SORT GTR "
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_CURGTR_O.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF ,
      RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_85
  #Dividing of STATGTR in retrocession by acceptance life and non-life
  #-----------------------------------------------------------------------------
  LIBEL="Eliminating Non-life transactions of GTR"
  PRG=ESTM7606
  export ${PRG}_I1=${DFILT}/${NJOB}_82_${IB}_SORT_GTR_O.dat
  export ${PRG}_I2=${ESL_CRVPERICASE0}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O2.dat
  export ${PRG}_O3=${ESL_GTRANO}
  EXECPRG

  NSTEP=${NJOB}_90
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_ARCSTATGTR} ${ESL_FTECLEDR}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_85_${IB}_ESTM7606_GTR_O2.dat 1000 1"
  SORT_I2="${EST_ARCSTATGTR} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:
/KEYS
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF ,
  RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_100
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_GTALO} ${ESL_DLREJGTAALO} ${ESL_DLREJGTARLO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_GTALO}    1000 1"
  SORT_I2="${ESL_DLREJGTAALO} 1000 1"
  SORT_I3="${ESL_DLREJGTARLO} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_GTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_110
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_GTRLO} ${ESL_DLREJGTRLO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${ESL_DLREJGTRLO} 1000 1"
  SORT_I2="${EST_GTRLO}  1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_GTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_115
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTA + DLSGTAxLO ==> EST_ARCSTATGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_75_${IB}_SORT_ARCSTATGTA_O.dat ${EST_ARCSTATGTA}"

  NSTEP=${NJOB}_120
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTR + DLSGTRLO ==> EST_ARCSTATGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_90_${IB}_SORT_ARCSTATGTR_O.dat ${EST_ARCSTATGTR}"

  NSTEP=${NJOB}_125
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTALO + DLREJGTAxLO ==> EST_GTALO"
  EXECKSH "mv ${DFILT}/${NJOB}_100_${IB}_GTA_O.dat ${EST_GTALO}"

  NSTEP=${NJOB}_130
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTRLO + ESL_DLREJGTRLO ==> EST_GTRLO"
  EXECKSH "mv ${DFILT}/${NJOB}_110_${IB}_GTR_O.dat ${EST_GTRLO}"

fi

NSTEP=${NJOB}_140
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree"
EXECKSH_MODE=P
gzip -c ${ESL_DLSGTAALO}      > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTAALO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLSGTARLO}      > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTARLO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLSGTRLO}       > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTRLO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLREJGTAALO}    > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTAALO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLREJGTARLO}    > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTARLO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLREJGTRLO}     > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTRLO_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_FTECLEDALO_MVT} > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDALO_MVT_${INVCONSO_D}.dat.gz
gzip -c ${ESL_FTECLEDALO_MTH} > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDALO_MTH_${INVCONSO_D}.dat.gz
gzip -c ${ESL_FTECLEDRLO}     > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRLO_${INVCONSO_D}.dat.gz

RMFIL "${ESL_FTECLEDALO_MVT}"
EXECKSH "touch ${ESL_FTECLEDALO_MVT}"

#[006]  Dch
NSTEP=${NJOB}_150
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND

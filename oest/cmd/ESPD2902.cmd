#!/bin/ksh
#=============================================================================
# nom de l'application         : ESTIMATIONS - INVENTAIRE
#                                Ouvertures annuelles du POS EBS
# nom du script SHELL          : ESPD2902.cmd
# revision                     : $Revision: 1.5 $
# date de creation             : 21/06/2017
# auteur                       : R. Cassis
# references des specifications: spira:60427
#-----------------------------------------------------------------------------
# description
#   Retrocession reversal and carried forward entries generation for POS EBS
#
# job launched by ESPD2900.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 03/10/2018 Roger Cassis :spira:60427 Filtre les clotures sur date AAAA/12/31
#[002] 11/10/2019 Roger Cassis :spira:67176-80329 Les données EBS sont filtrées dans le awk pour toute l'année mais pas uniquement année/12/31
#[003] 01/09/2020 Roger cassis :spira:88186 All opening generated data are taken from output EBS files
#[004] 22/10/2020 Roger cassis :spira:66261 - Add SSD_CF key in SORT process
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

datej=`date '+%Y%m%d%H%M%S'`

# Parameters
INVCONSO_D=$1
CONSOMTH=$2

INVYEAR=`echo ${INVCONSO_D} | cut -c1-4`
NORME="EBS"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> INVCONSO_D.........: ${INVCONSO_D}"
ECHO_LOG "#===> CONSOMTH...........: ${CONSOMTH}"
ECHO_LOG "#===> INVYEAR............: ${INVYEAR}"
ECHO_LOG "#===> NORME..............: ${NORME}"
ECHO_LOG "#===> EPO_FDETTRS........: ${EPO_FDETTRS}"
ECHO_LOG "#===> EPO_FTECLEDASO_EBS.: ${EPO_FTECLEDASO_EBS}"
ECHO_LOG "#===> EPO_FTECLEDRSO.....: ${EPO_FTECLEDRSO}"
ECHO_LOG "#===> EPO_FTECLEDASIISO..: ${EPO_FTECLEDASIISO}"
ECHO_LOG "#===> EPO_FTECLEDRSIISO..: ${EPO_FTECLEDRSIISO}"
ECHO_LOG "#===> EPO_DLREJGTAASIISO.: ${EPO_DLREJGTAASIISO}"
ECHO_LOG "#===> EPO_DLREJGTARSIISO.: ${EPO_DLREJGTARSIISO}"
ECHO_LOG "#===> EPO_DLREJGTRSIISO..: ${EPO_DLREJGTRSIISO}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_20
# Filtering clotures AR on 4Q month...
#-----------------------------------------------------------------------------
LIBEL="Filtering clotures AR on 4Q month..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDASIISO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASIISO_O.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF         3:1 -   3: EN,
        BALSHRMTH_NF       4:1 -   4: EN,
        CTR_NF             8:1 -   8:,
        ACY_NF            14:1 -  14:,
        SCOSTRMTH_NF      15:1 -  15: EN,
        SCOENDMTH_NF      16:1 -  16: EN,
        RETCTR_NF         24:1 -  24:,
        RETACY_NF         30:1 -  30:,
        RETSCOSTRMTH_NF   31:1 -  31: EN,
        RETSCOENDMTH_NF   32:1 -  32: EN,
        cols1              1:1 -  13:,
        cols2             17:1 -  29:,
        cols3             33:1 - 118:
/CONDITION bilan BALSHEY_NF = ${INVYEAR} AND BALSHRMTH_NF > 9
/CONDITION acy ACY_NF = "" AND CTR_NF != ""
/CONDITION retacy RETACY_NF = "" AND RETCTR_NF != ""
/DERIVEDFIELD ACY2_NF if acy then "${INVYEAR}" else ACY_NF
/DERIVEDFIELD SCOENDMTH2_NF if acy then 12 else SCOENDMTH_NF
/DERIVEDFIELD SCOSTRMTH2_NF if acy then 12 else SCOSTRMTH_NF
/DERIVEDFIELD RETACY2_NF if retacy then "${INVYEAR}" else RETACY_NF
/DERIVEDFIELD RETSCOENDMTH2_NF if retacy then 12 else RETSCOENDMTH_NF
/DERIVEDFIELD RETSCOSTRMTH2_NF if retacy then 12 else RETSCOSTRMTH_NF
/OUTFILE ${SORT_O}
/INCLUDE bilan
/REFORMAT cols1,ACY2_NF,SCOSTRMTH2_NF,SCOENDMTH2_NF,cols2,RETACY2_NF,RETSCOSTRMTH2_NF,RETSCOENDMTH2_NF,cols3
/COPY
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_30
# Current sort file FTECLEDASIISO
#-----------------------------------------------------------------------------
LIBEL="Current sort file FTECLEDASIISO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDASIISO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASIISO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_50
# Filtering clotures RR on 4Q month...
#-----------------------------------------------------------------------------
LIBEL="Filtering clotures RR on 4Q month..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDRSIISO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDRSIISO_O.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF         3:1 -   3: EN,
        BALSHRMTH_NF       4:1 -   4: EN,
        CTR_NF             8:1 -   8:,
        ACY_NF            14:1 -  14:,
        SCOSTRMTH_NF      15:1 -  15: EN,
        SCOENDMTH_NF      16:1 -  16: EN,
        RETCTR_NF         24:1 -  24:,
        RETACY_NF         30:1 -  30:,
        RETSCOSTRMTH_NF   31:1 -  31: EN,
        RETSCOENDMTH_NF   32:1 -  32: EN,
        cols1              1:1 -  13:,
        cols2             17:1 -  29:,
        cols3             33:1 -  71:
/CONDITION bilan BALSHEY_NF = ${INVYEAR} AND BALSHRMTH_NF > 9
/CONDITION acy ACY_NF = "" AND CTR_NF != ""
/CONDITION retacy RETACY_NF = "" AND RETCTR_NF != ""
/DERIVEDFIELD ACY2_NF if acy then "${INVYEAR}" else ACY_NF
/DERIVEDFIELD SCOENDMTH2_NF if acy then 12 else SCOENDMTH_NF
/DERIVEDFIELD SCOSTRMTH2_NF if acy then 12 else SCOSTRMTH_NF
/DERIVEDFIELD RETACY2_NF if retacy then "${INVYEAR}" else RETACY_NF
/DERIVEDFIELD RETSCOENDMTH2_NF if retacy then 12 else RETSCOENDMTH_NF
/DERIVEDFIELD RETSCOSTRMTH2_NF if retacy then 12 else RETSCOSTRMTH_NF
/OUTFILE ${SORT_O}
/INCLUDE bilan
/REFORMAT cols1,ACY2_NF,SCOSTRMTH2_NF,SCOENDMTH2_NF,cols2,RETACY2_NF,RETSCOSTRMTH2_NF,RETSCOENDMTH2_NF,cols3
/COPY
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_60
# Current sort file FTECLEDRSIISO
#-----------------------------------------------------------------------------
LIBEL="Current sort file FTECLEDRSIISO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDRSIISO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDRSIISO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_70
# Acceptance retrocession reversal and carried forward of previous balance sheetin the book
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
TYPFIC GLTAR
exit
EOF
export ${PRG}_PRM=${FPRM}
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDASIISO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARSO_O.dat
set +x
EXECPRG

NSTEP=${NJOB}_80
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
set -x
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_ESTM7602b_DLSGTARSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARSO_O.dat
set +x
EXECPRG

NSTEP=${NJOB}_90
# Acceptance retrocession reversal and carried forward of previous balance sheetin the book
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
TYPFIC GLTRR
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_FTECLEDRSIISO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRSO_O.dat
EXECPRG

NSTEP=${NJOB}_100
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_ESTM7602b_DLSGTRSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRSO_O.dat
EXECPRG

NSTEP=${NJOB}_110
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Formatage du FTECLEDA au format CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTM7603_DLSGTARSO_O.dat 800  1"
SORT_O="${EPO_DLREJGTAASIISO} OVERWRITE"
SORT_O2="${EPO_DLREJGTARSIISO} OVERWRITE"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD     1:1 -  40:,
        BALSHEY             3:1 -   3: EN,
        BALSHTMTH           4:1 -   4: EN,
        BALSHTDAY           5:1 -   5: EN,
        TRNCOD_CF           6:1 -   6:,
        TRNCOD1_CF          6:1 -   6:1,
        TRNCOD8_CF          6:8 -   6:8,
        RETINTAMT_M        88:1 -  88:,
        PLUS_13_CHAMPS     89:1 - 101:,
        KeyReconciliation 102:1 - 102:,
        TRN_NT            103:1 - 103:,
        FILLER_14_COLS    105:1 - 118:
/DERIVEDFIELD  ORICOD_LS "CURGTA~"
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/CONDITION GTAA TRNCOD1_CF = "1" OR TRNCOD1_CF = "3"
/CONDITION GTAR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
/OUTFILE ${SORT_O}
/INCLUDE GTAA
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FILLER_14_COLS
/OUTFILE ${SORT_O2}
/INCLUDE GTAR
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FILLER_14_COLS
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_120
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Formatage du FTECLEDR au format CURGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTM7603_DLSGTRSO_O.dat 800  1"
SORT_O="${EPO_DLREJGTRSIISO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY      3:1 -  3: EN,
        BALSHTMTH    4:1 -  4: EN,
        TRNCOD_CF    6:1 -  6:,
        TRNCOD1_CF   6:1 -  6:1,
        TRNCOD2C_CF  6:2 -  6:2,
        TRNCOD8_CF   6:8 -  6:8,
        FIELD1       1:1 - 40:,
        TRN_NT      56:1 - 56:,
        FIN_COLS    58:1 - 71:
/DERIVEDFIELD RETINTAMT "0.000~"
/DERIVEDFIELD  ORICOD_LS "EBSGTR~"
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT FIELD1, RETINTAMT,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FIN_COLS
/COPY
exit
EOF
SORT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Archiving annual data files"
gzip -c ${EPO_DLREJGTAASIISO}  > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTAASIISO_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREJGTARSIISO}  > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTARSIISO_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREJGTRSIISO}   > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTRSIISO_${INVCONSO_D}.dat.gz
ECHO_LOG "#========================================================================="

JOBEND


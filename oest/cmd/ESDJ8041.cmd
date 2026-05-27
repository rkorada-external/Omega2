#!/bin/ksh
#=============================================================================
# nom de l'application          :
# nom du script SHELL           : ESDJ8041.cmd
# revision                      : 
# date de creation              : 03/08/2015
# auteur                        : GBO
# references des specifications :
#-----------------------------------------------------------------------------
# description : generation and export in Sql of Gap for EST26A.
#
# start by ESDJ8040.cmd.
#
#
#   ENTER :
#
#     EST_CMPCALC
#     EST_FSUBTRS
#     EST_TGAPTHR
#     EST_TCALL
#
#   EXIT :
#
#     EST_NOTIFICATIONS
#     EST_GAP_LIFEST_GT
#
#-----------------------------------------------------------------------------
# historique des modifications :
# [001]     MBO     01/03/2016  spot30277: Nettoyage des fichiers $DFILT
# [002]     MBO     17/03/2016  spot30277: Conservation de certains fichiers en .gz
# [003]     MMA     21/04/2016  Spot 30506  SPIRA 45213  Correction de l'identification interne de la notification. Suppression de la STEP 149 devenue obselète
#                                                        AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWY/UWGRP
# [004]     MMA     13/04/2016  SPOT 31090  SPIRA 048161 Révision de l'identification externe de la notification
#                                                        AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWGRP
# [005] 23/11/2016 MMA SPIRA 57378: Correction sur le tri du fichier de seuil et le CMPCALC afin de corriger les erreurs de rupture dans l'ESTC8040
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters

MODE=$1
CLODAT_D=$2
DATE=$3
VAC_NT=$4


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_010
# Sort CMPCALC
# [005]
#------------------------------------------------------------------------------

LIBEL="Sort CMPCALC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_CMPCALC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CMPCALC.dat"
set +x
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CUR_CF 9:1 - 9:
/KEYS SSD_CF,
      ESB_CF,
      CUR_CF
exit
EOF
SORT



  NSTEP=${NJOB}_025
  # Sort TGAPTHR into TSEUIL
  # [005]
  #------------------------------------------------------------------------------
  LIBEL="Sort TGAPTHR into TSEUIL"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_TGAPTHR}"
  SORT_O="${DFILT}/${NSTEP}_${IB}_TSEUIL.dat"
  INPUT_TEXT ${SORT_CMD} <<EOF
  /FIELDS SSD_CF 1:1 - 1:,
          ESB_CF 2:1 - 2:,
          CUR_CF 3:1 - 3:
  /KEYS SSD_CF,
        ESB_CF,
        CUR_CF
  exit
EOF
SORT

  NSTEP=${NJOB}_050
  # Execute ESTC8040
  #------------------------------------------------------------------------------
  LIBEL="Apply tresholds"
  PRG=ESTC8040
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} <<EOF
  MODE ${MODE}
  CLODAT_D ${CLODAT_D}
  DATE ${DATE}
  VAC_NT ${VAC_NT}
  exit
EOF
set -x
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_CMPCALC.dat
  export ${PRG}_I2=${DFILT}/${NJOB}_025_${IB}_TSEUIL.dat
  export ${PRG}_I3=${EST_TCALL}
  export ${PRG}_I4=${EST_FCURQUOT}
  export ${PRG}_I5=${EST_SUBTRS}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_GAP_LIFEST_GT.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_ANOFILE.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat
set +x
  EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_GAP_LIFEST_GT.dat > ${DFILT}/${NSTEP}_${IB}_GAP_LIFEST_GT.dat.gz #[002]
gzip -c ${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat.gz #[002]


NSTEP=${NJOB}_80
# Supprime les lignes de jour (en cas de relance du job)
#------------------------------------------------------------------------------
LIBEL="Supprime les lignes de jour dans la table TGAPACCPRO"
ISQL_QRY="DELETE FROM BEST..TGAPACCPRO FROM BEST..TGAPACCPRO a, BREF..TBATCHSSD b WHERE a.SSD_CF = b.SSD_CF AND b.BATCHUSER_CF = suser_name() AND  GAP_D>='`date +%Y%m%d`' AND VAC_NT=${VAC_NT}"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_90
# Delete the twins lines in NOTIFICATIONS
# [003]  Révision de l'identification interne de la notification AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWY/UWGRP
# [004]  Révision de l'identification externe de la notification AVANT : SSD/ESB/UWGRP  => APRES : SSD/ESB/CTR/SEC/UWGRP
#------------------------------------------------------------------------------
LIBEL="Summurize NOTIFICATIONS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_NOTIFICATION.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1: EN,
        ESB_CF    2:1 - 2: EN,
        CTR_NF    3:1 - 3:,
        SEC_NF    4:1 - 4:,
        UWGRP_CF  6:1 - 6:
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      SEC_NF,
      UWGRP_CF
/CONDITION A_UWGRP UWGRP_CF NE ""
/SUM
/OUTFILE ${SORT_O}
/INCLUDE A_UWGRP
/REFORMAT SSD_CF, ESB_CF, CTR_NF, SEC_NF, UWGRP_CF
exit
EOF
SORT
gzip -c ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat.gz #[002]

NSTEP=${NJOB}_100
# Do BCPIN
#------------------------------------------------------------------------------
LIBEL="filling TGAPACCPRO table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_050_${IB}_GAP_LIFEST_GT.dat
BCP_TRUNCATE=NO
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TGAPACCPRO"
BCP


NSTEP=${NJOB}_140
# Inserting LSTUPDUSR from TACCTRN into TGAPACCPRO
#------------------------------------------------------------------------------
LIBEL="Inserting LSTUPDUSR from TACCTRN into TGAPACCPRO"
ISQL_QRY="execute BEST..PuGAPACCPRO_LSTUPDUSR"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_150
#----------------------------------------------------------------------------
LIBEL="Appel de la notification"
WS_BATCH_NAME=EST26817822 # Nom du prog JAVA
WS_PARAMS_TEXT <<EOF
INPUT_FILE     ${DFILT}/${NJOB}_90_${IB}_NOTIFICATION_ACCEPT.dat
EOF
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat

WS_BATCH

NSTEP=${NJOB}_155
#------------------------------------------
# Suppression des fichiers temporaires
#------------------------------------------
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[001]

NSTEP=${NJOB}_160
# Removal checked line in TCALL
#------------------------------------------------------------------------
LIBEL="Removal of already processed lines"
ISQL_QRY="DELETE FROM BEST..TCALL FROM BEST..TCALL a, BREF..TBATCHSSD b WHERE a.TREATED_B = 1 AND a.SSD_CF = b.SSD_CF AND b.BATCHUSER_CF = suser_name()"
ISQL_BASE="BEST"
ISQL

JOBEND

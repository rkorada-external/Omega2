#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - Non Proportionnel Cat Cover / Assistance Entry
# nom du script SHELL            : ESIJ2001.cmd
# revision                       :
# date de creation               : 27/01/2015
# auteur                         : F. Bourdeau
# references des specifications  : :spot:28139
#-----------------------------------------------------------------------------
# description
#   Automatisation du calcul des écritures service de Rétrocession
#   création des écritures service dans TACCSUP quand dans TRETCATCVR on a BOOKING_B=1 and a.TRN_NT=null and ULTAMT_M=(RETCEDAMT_M+TRNAMT_M)
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#[01] Florent :spot:29163 correcitions sur la boucle du DIARY
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

ICLODAT_D=$1
POST_OMEGA=$2

ECHO_LOG "ICLODAT_D  ${ICLODAT_D}"
ECHO_LOG "POST_OMEGA ${POST_OMEGA}"

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Creation of new AE from CAT COVER for TACCSUP"
ISQL_BASE="BEST"
ISQL_QRY="exec PtRETCATCVR_ACCSUP_01 '${ICLODAT_D}', ${POST_OMEGA}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_RETCATCVR_ACCSUP_01_O.log
ISQL

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Update TACCSUP for the CAT COVER"
ISQL_BASE="BEST"
ISQL_QRY="exec PtRETCATCVR_ACCSUP_02 '${ICLODAT_D}', ${POST_OMEGA}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_RETCATCVR_ACCSUP_02_O.log
ISQL

if [ "${POST_OMEGA}" == "0" ]; then
  NSTEP=${NJOB}_30
  #------------------------------------------------------------------------------
  LIBEL="Get the new CAT COVER from RETRO accounting"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_QRY="exec BEST..PtRETCATCVR_ACC_01 '${ICLODAT_D}'"
  BCP_O=${DFILT}/${NSTEP}_${IB}_ISQL_RETCATCVR_ACC_O.dat
  BCP
  #Fichier pour le journal - diary
  if [ -s ${DFILT}/${NSTEP}_${IB}_ISQL_RETCATCVR_ACC_O.dat ]; then
    # Read the data file from the previous step line by line and call the web service.
    NUM_ANO=0
    cat ${DFILT}/${NJOB}_30_${IB}_ISQL_RETCATCVR_ACC_O.dat | while read line
    do
      NUM_ANO=$(expr ${NUM_ANO} + 1)
      NSTEP=${NJOB}_40_${NUM_ANO}

      OBJECT_ID=`echo $line | awk -F"~" '{print $1}'`
      NOTIFTYP_NT=`echo $line | awk -F~ '{print $2}'`
      USR_CF=`echo $line | awk -F~ '{print $3}'`
      NOTIFCONTEXT_LL=`echo $line | awk -F~ '{print $4}'`

      WS_STATUS_MSG="OBJECT_ID=${OBJECT_ID}, NOTIFTYP_NT=${NOTIFTYP_NT}, USR_CF=${USR_CF}, NOTIFCONTEXT_LL=${NOTIFCONTEXT_LL}"
      LIBEL="Calling Web service for diary with ${WS_STATUS_MSG}" 
    
      WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
      WS_BATCH_NAME=RFRJ1030
      STEPEND_CONTINUE="YES"
      WARNING="YES"
      WS_PARAMS_TEXT << EOF
OBJECT_ID ${OBJECT_ID}
NOTIFTYP_NT ${NOTIFTYP_NT}
USR_CF ${USR_CF}
EOF
      WS_BATCH
      # Capture the return value from the web service.
      WS_STATUS=$?
      if [ ${WS_STATUS} != 0 ]
      then
        echo "WARNING! ${NJOB} returned ${WS_STATUS} for ${WS_STATUS_MSG}" >> ${DFILT}/${NSTEP}_${IB}.wng
      fi
    done
  fi
fi

JOBEND

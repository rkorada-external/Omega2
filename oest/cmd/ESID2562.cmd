#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                           Impression des Anomalies VENTILATION NP - 12055
# nom du script SHELL		: ESID2562.cmd
# revision			: $Revision:   6.1
# date de creation		: 22/02/2006
# auteur			: M.DJELLOULI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Impression des Anomalies VENTILATION NP
#
# job launched by ESID2560.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#-----------------------------------------------------------------------------
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd
. ${DCMD}/ESCD9002.cmd


# Initialise JOB
JOBINIT

#Recuperation des parametres
# LOOP_AS_PRINT donne par defaut tjs le user en premier parametre

USR_CF=$1
RETCTR_NF=$2
ACCYER_NF=$3
RTO_NF=$4
SSD_CF=$5
DATE_T=$6


NSTEP=${NJOB}_10
# Merge of Anomalies Files from ESID2561 / ESTC8805
#-----------------------------------------------------------------------------
LIBEL="Merge of dVGTAr and dDVGTAr in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESID2561_47_${IB}_ESTC8805_SORT_IGTAR1_O.ano 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESID2561_53_${IB}_ESTC8805_DLTOTGTAR_O.ano 1000 1"
if [ ! -s ${DFILT}/${NCHAIN}_ESID2561_49_${IB}_ESTC8805_SORT_IGTAR2_O.ano ]
then
    SORT_I3="${DFILT}/${NCHAIN}_ESID2561_49_${IB}_ESTC8805_SORT_IGTAR2_O.ano 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTR2562.dat APPEND"
INPUT_TEXT $SORT_CMD <<EOF
exit
EOF
SORT

NSTEP=${NJOB}_20
#if no file generated...
#---------------------------------------------------------------
if [ ! -s ${DFILT}/${NJOB}_10_${IB}_ESTR2562.dat ]
then
  JOBEND
fi

NSTEP=${NJOB}_30
# Get the printer code from the subsidiary
# Cela permet de recuperer le PRDSIT, GEOSIT et PRT_CF necessaire pour l'envoi du .pdf sur le bon serveur INTRANET
# On a une édition à sortir par site, PARIS;MUTRE;NY;SGP
#------------------------------------------------------------------------------
if [ ${HOST_PRDSIT} = FRA1 ];
then
SSD_CF=2
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = FRAM ];
then
SSD_CF=9
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = USA1 ];
then
SSD_CF=10
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = SGP1 ];
then
SSD_CF=20
GET_PRTID_FROMSSD ${SSD_CF}
fi

NSTEP=${NJOB}_38
LIBEL="Formatting of the data"
WS_BATCH_NAME=ESTR2562
WS_PARAMS_TEXT << EOF
EOF
WS_INPUT_FILE=${DFILT}/${NJOB}_10_${IB}_ESTR2562.dat
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}.dat
WS_BATCH

NSTEP=${NJOB}_40
# Starting Printing Files
#---------------------------------------------------------------
LIBEL="Start printing"
WS_REPORT_NAME=ESTR2562
WS_PARAMS_TEXT << EOF
SSD_CF          ${SSD_CF}
ACTION          WEB
EOF
WS_INPUT_FILE=${DFILT}/${NJOB}_38_${IB}_ESTR2562.dat
WS_REPORT

#NSTEP=${NJOB}_40
## Impression TEST WEB redirigé vers Email
##---------------------------------------------------------------
#LIBEL="Start printing"
#PRN_OUT=PRINT
#PRN_NAME=mail:FRXNT32
#PRN_TYPE=STARPDF
#PRT_NAME=${PRTID}
#PRN_I=${DFILT}/${NJOB}_10_${IB}_ESTR2562.dat
#PRN_FMT="ESTR2562"
#PRN

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_50
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NCHAIN}_ESID2561_*_${IB}_ESTC8805*.ano"


#!/bin/ksh
#=============================================================================
# nom ²de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 Reception retrocession interne
# nom du script SHELL		: ESID2051.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 08/09/1997
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#      Internal retrocession reception
# job lance par ESID2050.cmd
#
#
# output file sort  ${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
#
#
# Launch C programs ESTM7604
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  J Ribot    10/07/2003  ajout parametre CRE_D et ajout sortie O2 ESTM7604
#   01/ 06 / 04 J. Ribot ajout step 08 13 pour garder et reintegrer les enregistrements
#                        des filiales non presentes dans l'inventaire (SOPT 4935)
#[03] 30/05/2012 Roger Cassis    :spot:23802 - Modifications pour Solvency - 16 champs sur fichier GT
#[04] 16/01/2013 P. Pezout       :spot:24041 - Modifications pour Solvency 
#[05] 14/04/2015 Julien FONTANA  :spot:28559 - Ajout Step 11 ESTC3701
#[06] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
CRE_D=$1

# Initialisation of the Job
JOBINIT

# pour le créer s'il n'existe pas
touch ${EST_DLRGTAA}

NSTEP=${NJOB}_080
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


NSTEP=${NJOB}_100
#Syncro perimetre / retro interne
#------------------------------------------------------------------------------
LIBEL="Formatting of the data"
WS_BATCH_NAME=ESPD2050
WS_INPUT_FILE=${DFILT}/${NJOB}_040_${IB}_ESTM7604_ANOS_O.dat
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_ANOS_O.dat
WS_BATCH


NSTEP=${NJOB}_120
#subject : Print out on INTRANET
#--------------------------------------------------------------------------
LIBEL="Print out on INTRANET"
WS_REPORT_NAME=ESPD2050
WS_PARAMS_TEXT << EOF
SSD_CF          ${SSD_CF}
ACTION          WEB
EOF
WS_INPUT_FILE=${DFILT}/${NJOB}_19_${IB}_ESID2050_ANOS_O.dat
WS_REPORT


NSTEP=${NJOB}_140
# Delete temporary files of the job
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"


JOBEND
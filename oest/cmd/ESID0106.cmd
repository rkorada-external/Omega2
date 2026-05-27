#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATION - CONTROLE DE COHERENCE
# nom du script SHELL  : ESID0100.cmd
# date de creation     : 13/06/2012
# auteur               : Florent
# references des specifications	: :spot:23390 SOLVENCY II
#-----------------------------------------------------------------------------
# description
#   control et fabrication du fichier pour la chaîne de calcul des taux
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] Florent 30/10/2012 :spot:24041 Solvency II
# [02] Florent 11/06/2015 :spot:28941 gestion INF
# [03] Florent 27/05/2016 :spot:30976 gestion du DSI !
# [04] KBhimasen 28/07/2021	:Spira#85174 Closing calendar- Impact on patterns load	: Changes in step#10
# [05] KBhimasen 28/09/2021	:Spira#96840 Discount - Illiquidity segment management	: Changes in step#10
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

USR_CF=${1}
CRE_D="${2}"
TYPE_FICHIER=${3}
PER_CF=${4}
ICLODAT_D=${5}

#Paramètres en plus du ESID0821
if [ "$6" != "" ]
then
  LAG_CF=${6}
fi
if [ "$7" != "" ]
then
  SSD_CF=${7}
fi
if [ "$8" != "" ]
then
  LIGNES=${8}
fi

JOBINIT

if [ "${TYPE_FICHIER}" = "CUM"  -o "${TYPE_FICHIER}" = "DSC" -o "${TYPE_FICHIER}" = "ICV"  -o "${TYPE_FICHIER}" = "INF" ]
then
  NSTEP=${NJOB}_10
  #------------------------------------------------------------------------------
  LIBEL="Coherence checks and make the file for ${TYPE_FICHIER}"
  BCP_WAY="OUT"; BCP_VER="+"
  BCP_QRY="exec BEST..PtPATTERNSII_btrav_ano '${LAG_CF}',${SSD_CF},'${CRE_D}','${USR_CF}',${LIGNES},0,'${TYPE_FICHIER}',1, '${ICLODAT_D}', '${PER_CF}', ''  "
  BCP_O=${EST_FPATTERNSII_USER}
  BCP

  NSTEP=${NJOB}_15
  #------------------------------------------------------------------------------
  LIBEL="Get the Pattern file for ${TYPE_FICHIER}"
  BCP_WAY="OUT"; BCP_VER="+"
  BCP_O=${EST_FPATTERNSII_REF}
  BCP_QRY="exec BEST..PsFPATTERNSII_01 '${TYPE_FICHIER}'"
  BCP

  if [ "${TYPE_FICHIER}" = "DSC" ]
  then
    NSTEP=${NJOB}_50
    #------------------------------------------------------------------------------
    LIBEL="Get the LOB SII file for ${TYPE_FICHIER}"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_QRY="exec BEST..PsFLOBSII_01 '${CRE_D}'"
    BCP_O=${EST_FLOBSII}
    BCP
  fi

else
  EST_LOCK=${DFILT}/${ENV_PREFIX}_ESID0101_EST_FPATTERNSII_${TYPE_FICHIER}_LOCK.dat

  NSTEP=${NJOB}_20
  #------------------------------------------------------------------------------
  LIBEL="Create Lock file in ${EST_LOCK}"
  integer ATTENTE
  ATTENTE=0
  while [ -f ${EST_LOCK} ]
  do
    # wait 1 second and increment the time wait
    sleep 1
    let ATTENTE=ATTENTE+1
    if [ $ATTENTE -ge 3600 ]
    then
      ECHO_LOG "Erreur dans l'attente du verrou sur ${EST_LOCK}"
      STEPEND 1
    fi
  done
  EXECKSH "echo '1' > ${EST_LOCK}"

  NSTEP=${NJOB}_30
  #------------------------------------------------------------------------------
  LIBEL="Get the Pattern file ${TYPE_FICHIER}"
  BCP_WAY="OUT"; BCP_VER="+"
  BCP_O=${EST_FPATTERNSII_REF}
  BCP_QRY="exec BEST..PsFPATTERNSII_01 '${TYPE_FICHIER}'"
  BCP

  if [ "${TYPE_FICHIER}" = "DSI" ]
  then
    NSTEP=${NJOB}_40
    #------------------------------------------------------------------------------
    LIBEL="Get the DSC Pattern file for DSI"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_QRY="exec BEST..PsFPATTERNSII_01 'DSI_DSC'"
    BCP_O=${EST_FPATTERNSII_BASE}
    BCP

    NSTEP=${NJOB}_50
    #------------------------------------------------------------------------------
    LIBEL="Get the LOB SII file for DSI"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_QRY="exec BEST..PsFLOBSII_01 '${CRE_D}'"
    BCP_O=${EST_FLOBSII}
    BCP
  fi

  if [ "${TYPE_FICHIER}" = "BDT" ]
  then
    NSTEP=${NJOB}_60
    #------------------------------------------------------------------------------
    LIBEL="Get the RATING SII file for BDT"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_QRY="exec BEST..PsFRATINGSII_01 '${CRE_D}'"
    BCP_O=${EST_FRATINGSII}
    BCP
  fi

  NSTEP=${NJOB}_70
  #------------------------------------------------------------------------------
  LIBEL="Suppression du verrou de fichier ${EST_LOCK}"
  RMFIL "${EST_LOCK}"
fi

JOBEND

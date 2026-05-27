#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATION - CONTROLE DE COHERENCE
# nom du script SHELL  : ESID0100.cmd
# date de creation     : 13/06/2012
# auteur               : Florent
# references des specifications	: :spot:23390 SOLVENCY II
#-----------------------------------------------------------------------------
# description
#   control et fabrication du fichier pour la cha�ne de calcul des taux
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 17/08/2012 :spot:24041 Florent         Ajout param�tres pour le ESID0103
#[02] 21/10/2013 :spot:26391 Cyrille Despret Modification du test sur le type ICV : meme traitement que pour CUM
#                                              Avant dans l'ecran d'import des fichiers de patterns, on avait 3 choix :
#                                                - CUM (Cumulative patterns pour Premiuims and claims)
#                                                - ICV (Incurred patterns pour IBNR)
#                                                - DSC (Interest and liquidity rates - Discount)
#                                              Desormais, les patterns CUM et ICV sont tous dans 1 meme fichier
#                                              Dans le fichier importe, une colonne "Rate Pattern Type" indique le type de donnee a traiter
#                                              Donc quel que soit le type de fichier (CUM et ICV) le traitement est commun
#                                              Dans le futur, le choix ICV sera retire de l'ecran d'import
#[03] 09/10/2014 :spot:27789 Florent suppression du ' dans les param�tres CRE_D et ICLODAT_D
#[04] 29/04/2015 :spot:26391 Florent gestion de l'ICV
#[05] 11/06/2015 :spot:28941 Florent gestion INF
#[05] 13/05/2016 :spot:30543 Florent gestion du DSI !
#[06] 26/09/2019 KBagwe : #80560 :- REQ3.3.1 - Change in CSF (CUM and ICV) pattern Upload (complement to 62221 ). Pass closing date to ESID102
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

USR_CF=${2}
CRE_D=`echo "${3}" | cut -d "'" -f2`
TYPE_FICHIER=${4}
PER_CF=${5}
ICLODAT_D=`echo ${6} | cut -d "'" -f2`

#Param�tres en plus du ESID0821
if [ "$7" != "" ]
then
  LAG_CF=${7}
fi
if [ "$8" != "" ]
then
  SSD_CF=${8}
fi
if [ "$9" != "" ]
then
  LIGNES=${9}
fi
if [ "$10" != "" ]
then
  NORME_CF=${10}
fi

CHAININIT $0 $1

#--------------- Initialisation des variables de la chaine
export EST_FRATINGSII=${DFILT}/${NCHAIN}_${IB}_00_EST_FRATINGSII.dat
export EST_FLOBSII=${DFILT}/${NCHAIN}_${IB}_00_EST_FLOBSII.dat
export EST_FPATTERNSII_REF=${DFILT}/${NCHAIN}_${IB}_00_FPATTERNSII_REF_${TYPE_FICHIER}.dat  #fichier de r�f�rence pour le d�doublonneur
export EST_FPATTERNSII_BASE=${DFILT}/${NCHAIN}_${IB}_00_FPATTERNSII_BASE_${TYPE_FICHIER}.dat #patterns de la base pour recalcul du DSI
export EST_FPATTERNSII_USER=${DFILT}/${NCHAIN}_${IB}_00_FPATTERNSII_USER_${TYPE_FICHIER}.dat #nouveaux patterns � traiter fichier en sortie du ESID0106/ en entr�e du ESID0101
export EST_FPATSEGSII_DUPLI=${DFILT}/${NCHAIN}_${IB}_30_FPATSEGSII_DUPLI_${TYPE_FICHIER}.dat  #fichier trace du ESID0101 pour les doublons
export EST_FPATSEGSII_NEW=${DFILT}/${NCHAIN}_${IB}_30_FPATSEGSII_NEW_${TYPE_FICHIER}.dat    #fichier trace des nouveaux patterns

if [ "${TYPE_FICHIER}" = "CUM"  -o "${TYPE_FICHIER}" = "DSC" -o "${TYPE_FICHIER}" = "ICV" -o "${TYPE_FICHIER}" = "INF" ]
then
  export EST_FPATTERNSII_DDBL_IN=${EST_FPATTERNSII_USER}
  export EST_FPATTERNSII_DDBL_OUT=${DFILT}/${NCHAIN}_${IB}_10_FPATTERNSII_DDBL_OUT_${TYPE_FICHIER}.dat  #d�doublonneur en sortie
  export EST_FPATTERNSII_CALC_IN=${EST_FPATTERNSII_DDBL_OUT}
  export EST_FPATTERNSII_CALC_OUT=${DFILT}/${NCHAIN}_${IB}_20_FPATTERNSII_CALC_OUT_${TYPE_FICHIER}.dat  #Sortie du calcul des patterns
  export EST_FPATTERNSII_OUT_1=${EST_FPATTERNSII_DDBL_OUT}
  export EST_FPATTERNSII_OUT_2=${EST_FPATTERNSII_CALC_OUT}
else # type de fichier DSI ou BDT
  export EST_FPATTERNSII_CALC_IN=${EST_FPATTERNSII_BASE}
  export EST_FPATTERNSII_CALC_OUT=${DFILT}/${NCHAIN}_${IB}_10_FPATTERNSII_CALC_OUT_${TYPE_FICHIER}.dat
  export EST_FPATTERNSII_DDBL_IN=${EST_FPATTERNSII_CALC_OUT}
  export EST_FPATTERNSII_DDBL_OUT=${DFILT}/${NCHAIN}_${IB}_20_FPATTERNSII_DDBL_OUT_${TYPE_FICHIER}.dat
  export EST_FPATTERNSII_OUT_1=${EST_FPATTERNSII_DDBL_OUT}
  export EST_FPATTERNSII_OUT_2=""
fi

JOB_LOG_OUTPUT="TEE"
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> USR_CF............: ${USR_CF}"
ECHO_LOG "#===> CRE_D.............: ${CRE_D}"
ECHO_LOG "#===> TYPE_FICHIER......: ${TYPE_FICHIER}"
ECHO_LOG "#===> PER_CF............: ${PER_CF}"
ECHO_LOG "#===> ICLODAT_D.........: ${ICLODAT_D}"
ECHO_LOG "#===> NORME_CF..........: ${NORME_CF}"
ECHO_LOG "#===> SSD_CF..........: ${SSD_CF}"
ECHO_LOG ""
ECHO_LOG "#===> EST_FRATINGSII............: ${EST_FRATINGSII}"
ECHO_LOG "#===> EST_FLOBSII...............: ${EST_FLOBSII}"
ECHO_LOG "#===> EST_FPATTERNSII_REF.......: ${EST_FPATTERNSII_REF}"
ECHO_LOG "#===> EST_FPATTERNSII_BASE......: ${EST_FPATTERNSII_BASE}"
ECHO_LOG "#===> EST_FPATTERNSII_USER......: ${EST_FPATTERNSII_USER}"
ECHO_LOG "#===> EST_FPATSEGSII_DUPLI......: ${EST_FPATSEGSII_DUPLI}"
ECHO_LOG "#===> EST_FPATSEGSII_NEW........: ${EST_FPATSEGSII_NEW}"
ECHO_LOG "#===> EST_FPATTERNSII_DDBL_IN...: ${EST_FPATTERNSII_DDBL_IN}"
ECHO_LOG "#===> EST_FPATTERNSII_DDBL_OUT..: ${EST_FPATTERNSII_DDBL_OUT}"
ECHO_LOG "#===> EST_FPATTERNSII_CALC_IN...: ${EST_FPATTERNSII_CALC_IN}"
ECHO_LOG "#===> EST_FPATTERNSII_CALC_OUT..: ${EST_FPATTERNSII_CALC_OUT}"
ECHO_LOG "#===> EST_FPATTERNSII_OUT_1.....: ${EST_FPATTERNSII_OUT_1}"
ECHO_LOG "#===> EST_FPATTERNSII_OUT_2.....: ${EST_FPATTERNSII_OUT_2}"
ECHO_LOG "#========================================================================="
JOB_LOG_OUTPUT=""

NJOB=ESID0106
${DCMD}/ESID0106.cmd ${USR_CF} "${CRE_D}" ${TYPE_FICHIER} ${PER_CF} ${ICLODAT_D} ${LAG_CF} ${SSD_CF} ${LIGNES} 2>&1 | ${TEE}

if [ "${TYPE_FICHIER}" = "CUM"  -o "${TYPE_FICHIER}" = "DSC" -o "${TYPE_FICHIER}" = "ICV" -o "${TYPE_FICHIER}" = "INF" ]
then
  NJOB=ESID0101
  ${DCMD}/ESID0101.cmd ${TYPE_FICHIER} 2>&1 | ${TEE}

  if [ -s ${EST_FPATTERNSII_DDBL_OUT} ]
  then
    if [ "${TYPE_FICHIER}" = "CUM" -o "${TYPE_FICHIER}" = "ICV" ]
    then
      #--------------- Initialisation des variables de la chaine
      NJOB=ESID0102
      ${DCMD}/ESID0102.cmd ${TYPE_FICHIER} ${ICLODAT_D} 2>&1 | ${TEE}
    fi

    if [ "${TYPE_FICHIER}" = "DSC" -o "${TYPE_FICHIER}" = "INF" ]
    then
      NJOB=ESID0103
      ${DCMD}/ESID0103.cmd ${USR_CF} "${CRE_D}" ${TYPE_FICHIER} 2>&1 | ${TEE}
    fi
  fi
# ------------------------------- type de fichier DSI ou BDT ----------------------------------------------------
else
  if [ "${TYPE_FICHIER}" = "DSI" ]
  then
    if [ ! -s ${EST_FPATTERNSII_CALC_IN} ]
    then
      ECHO_LOG "# Fichier ${EST_FPATTERNSII_CALC_IN} venant du ${NJOB} vide !"
      CHAINEND
    fi
    NJOB=ESID0103
    ${DCMD}/ESID0103.cmd ${USR_CF} "${CRE_D}" ${TYPE_FICHIER} 2>&1 | ${TEE}
  fi

  if [ "${TYPE_FICHIER}" = "BDT" ]
  then
    NJOB=ESID0104
    ${DCMD}/ESID0104.cmd ${USR_CF} "${CRE_D}" 2>&1 | ${TEE}
  fi

  if [ ! -s ${EST_FPATTERNSII_CALC_OUT} ]
  then
    ECHO_LOG "# Fichier ${EST_FPATTERNSII_CALC_OUT} venant du ${NJOB} vide !"
    CHAINEND
  fi

  NJOB=ESID0101
  ${DCMD}/ESID0101.cmd ${TYPE_FICHIER} 2>&1 | ${TEE}
fi

NJOB=ESID0105
${DCMD}/ESID0105.cmd ${USR_CF} ${TYPE_FICHIER} "${CRE_D}" ${PER_CF} ${ICLODAT_D} ${NORME_CF} 2>&1 | ${TEE}

CHAINEND

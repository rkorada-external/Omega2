#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATION - CONTROLE DE COHERENCE
# nom du script SHELL  : ESID0821.cmd
# date de creation     : 18/04/2012
# auteur               : Florent
# references des specifications	: :spot:23390 SOLVENCY II
#-----------------------------------------------------------------------------
# description
#   control et fabrication du fichier pour la chaîne de calcul des taux
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] Florent 09/10/2012 :spot:24041 appel de la chaîne comme daemon
#===============================================================================
# set -x

#Recupere arguments d'entree
USR_CF=${1}
LAG_CF=${2}
SSD_CF=${3}
CRE_D="${4}"
LIGNES=${5}
TYPE_FICHIER=${6}
PER_CF=${7}
ICLODAT_D=${8}
NORME_CF=${9}

# execution de la profile globale pour reaffecter les variables communes
. /etc/profile

# execution de la profile user pour reaffecter les variables specifiques au user
. ~/.profile

# reaffectation de la variable LAUNCHER pour ne pas etre considere comme un asynchrone lance par le daemon
export LAUNCHER=`whoami`

# controle et envoi du cmd demande si autorise a etre soumis par le demon
${DCMD}/ESID0100.cmd = ${USR_CF} "${CRE_D}" ${TYPE_FICHIER} ${PER_CF} ${ICLODAT_D} ${LAG_CF} ${SSD_CF} ${LIGNES} ${NORME_CF}

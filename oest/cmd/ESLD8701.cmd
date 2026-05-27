#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Ajoute fichier MTH au fichier MVT et met a jour ESL_EPOSOCLO_CUR
# nom du script SHELL           : ESLD8701.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#   Ajoute fichier MTH au fichier MVT
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#===============================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 


# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# ARCHIVAGE
#----------------------------------------------------------------------------
LIBEL="Archive to DSAVE : ${ESL_FTECLEDALO_MVT}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESL_FTECLEDALO_MVT} > ${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDALO_MVT_O.dat.gz"

NSTEP=${NJOB}_20
# Merge des fichiers ESL_FTECLEDALO_MTH et ESL_FTECLEDALO_MVT
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers ${ESL_FTECLEDALO_MTH} et ${ESL_FTECLEDALO_MVT} dans ${ESL_FTECLEDALO}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_FTECLEDALO_MVT} 1000"
SORT_I2="${ESL_FTECLEDALO_MTH} 1000"
SORT_O="${ESL_FTECLEDALO} 1000"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
# ARCHIVAGE
#----------------------------------------------------------------------------
LIBEL="Archive last file to DSAVE : ${ESL_FTECLEDALO}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESL_FTECLEDALO} > ${DSAV}/${SVG}_${ENV_PREFIX}_ESLD3800_FTECLEDALO.dat.gz"

NSTEP=${NJOB}_40
# Move
#----------------------------------------------------------------------------
LIBEL="Move ${ESL_EPOSOCLO_CURNEW} to ${ESL_EPOSOCLO_CUR}"
EXECKSH_MODE=P
EXECKSH "mv ${ESL_EPOSOCLO_CURNEW} ${ESL_EPOSOCLO_CUR}"

NSTEP=${NJOB}_50
# Move
#----------------------------------------------------------------------------
LIBEL="Move ${ESL_DLREJGTAALO_CURNEW} to ${ESL_DLREJGTAALO_CUR}"
EXECKSH_MODE=P
EXECKSH "mv ${ESL_DLREJGTAALO_CURNEW} ${ESL_DLREJGTAALO_CUR}"
EXECKSH "mv ${ESL_DLREJGTARLO_CURNEW} ${ESL_DLREJGTARLO_CUR}"
EXECKSH "mv ${ESL_DLREJGTRLO_CURNEW} ${ESL_DLREJGTRLO_CUR}"

JOBEND



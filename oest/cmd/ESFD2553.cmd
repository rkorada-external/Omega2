#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESFD2553.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 29/06/2020
# auteur                        : Charles Socie
#-----------------------------------------------------------------------------
# Description :
#  Split and send acceptance DLEIFTECLEDSII to retrocessionnaire subsidiaries
#
# job launched by ESID2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd
. ${DUTI}/fcttransfer.cmd

# Get parameters
TYPEINV=$1
NORME=$2

# Job initialisation
JOBINIT               


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME_CF}"
ECHO_LOG "#===> NCHAIN.................: ${NCHAIN}"
ECHO_LOG "#===> STR_CAT_O..............: ${STR_CAT_O}"
ECHO_LOG "#===> ESF_DLEIFTECLEDSIIEI...: ${ESF_DLEIFTECLEDSIIEI}"
ECHO_LOG "#========================================================================="

touch ${ESF_DLEIFTECLEDSIIEI}
# Fichiers d'emission interne envoyes aux filiales

#[005]
NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[002] Passage de 500 a 1000 pour le sort
SORT_I="${ESF_DLEIFTECLEDSIIEI} 1500"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EIFTECLEDSII_O_${NORME_CF}.dat 1500"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/KEYS SSD_CF
exit
EOF
SORT

NSTEP=${NJOB}_10
# Split file by subsidiary
#-----------------------------------------------------------------------------
LIBEL="Split TL file by subsidiary"
SPLIT_PREFIX=${NJOB}_05
SPLIT_PREFIX_NEW=${NSTEP}
SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EIFTECLEDSII_O_${NORME_CF}.dat
SPLIT_FILE

NSTEP=${NJOB}_15
# Concat file names
#-----------------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NJOB}_10_*_${IB}*.dat"
STR_CAT


NSTEP=${NJOB}_20
# Send files
#-----------------------------------------------------------------------------
LIBEL="Send files to pool"
SEND_POOL_PREFIX="${NJOB}_10_.*_${IB}"
SEND_POOL_FILES=${STR_CAT_O}
SEND_POOL_TYPE="SSD"
SEND_POOL


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_25
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


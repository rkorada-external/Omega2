#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESID2022.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 21/06/2004
# auteur                        : J. Ribot
# references des specifications : ESID2020.doc
#-----------------------------------------------------------------------------
# Description :
#  Split and send acceptance TL to retrocessionnaire subsidiaries
#
# Input files
#       EST_DLEIGTAA     DFILI
#
# job launched by ESID2550.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 28/07/2014 ABJ  spot:25773 taille  EST_DLEIEST
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd
. ${DUTI}/fcttransfer.cmd

# Job initialisation
JOBINIT


# Fichiers d'emission interne envoyes aux filiales

#[001]
NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLRLIFEI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLEIEST_O.dat 2000 1"
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
SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_DLEIEST_O.dat
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



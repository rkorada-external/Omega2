#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESID2552.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications : ESTIEI23.doc
#-----------------------------------------------------------------------------
# Description :
#  Split and send acceptance TL to retrocessionnaire subsidiaries
#
# job launched by ESID2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 27/11/2012 R. Cassis  :spot:24516  Solvency 2
#[002] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL

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

#if [ "${TYPEINV}" = "INV" ]
#then
#	#ESID2550
#	EST_DLEIGTAA=${EST_DLEIGTAA}
#else
#	#ESPD2550
#	EST_DLEIGTAA=${EPO_DLEIGTAA}
#fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> EST_DLEIGTAA...........: ${EST_DLEIGTAA}"
ECHO_LOG "#========================================================================="


# Fichiers d'emission interne envoyes aux filiales

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLEIGTAA} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EIGTAA_O.dat"
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
SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EIGTAA_O.dat
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


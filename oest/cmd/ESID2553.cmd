#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESID2553.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : CGI
#-----------------------------------------------------------------------------
# Description :
#  Split and send acceptance DLEIFTECLEDSII to retrocessionnaire subsidiaries
#
# job launched by ESID2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 28/04/2014 PPEZOUT  :spot:26653 Echanges internes Solvency 
#[002] 30/04/2014 CDESPRET :spot:26653 Passage de 500 a  1000 dans le SORT du STEP 05
#[003] 05/05/2014 CDESPRET :spot:26653 Changement temporaire de nom de chaine au STEP 20 (qui devient ESPD3700)
#                                       pour eviter que ce fichier de CSF ne soit fusionne avec le fichier GT lors 
#                                       de la recuperation sur le serveur de destination (ESPD4000)
#[004] 02/11/2015 P PEZOUT  :spot:29615 ajout touch
#[005] 28/06/2016 R. Cassis :spot:30819 Agrandissement taille des enregistrements du tri
#[006] 29/05/2020 M. NAJI   : SPIRA 87595 replace prefix ESPD3700 with ESPD3620
#[007] 29/05/2020 M. NAJI   : SPIRA 87595 revert , replace ESPD3620 par ESPD3700
#[008] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[009] 27/12/2021 M.NAJI: SPIRA 101295 add norme to prefix of chain
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
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> EST_DLEIFTECLEDSIIEI...: ${EST_DLEIFTECLEDSIIEI}"
ECHO_LOG "#========================================================================="

touch ${EST_DLEIFTECLEDSIIEI}
# Fichiers d'emission interne envoyes aux filiales

#[005]
NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[002] Passage de 500 a 1000 pour le sort
SORT_I="${EST_DLEIFTECLEDSIIEI} 1500"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EIFTECLEDSII_O.dat 1500"
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
SPLIT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EIFTECLEDSII_O.dat
SPLIT_FILE


NSTEP=${NJOB}_15
# Concat file names
#-----------------------------------------------------------------------------
LIBEL="Concat file names"
STR_CAT_PREFIX="${DFILT}/${NJOB}_10_*_${IB}*.dat"
STR_CAT

#[009]
NCHAIN=${ENV_PREFIX}_ESPD3700${NORME_CF}  #[006] [007]
NCHAIN_SHORT=ESPD3700   #[006] [007]

NSTEP=${NJOB}_20
# Send files
#-----------------------------------------------------------------------------
LIBEL="Send files to pool"
SEND_POOL_PREFIX="${NJOB}_10_.*_${IB}"
SEND_POOL_FILES=${STR_CAT_O}
SEND_POOL_TYPE="SSD"
SEND_POOL

NCHAIN=${ENV_PREFIX}_ESPD2550
NCHAIN_SHORT=ESPD2550


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_25
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


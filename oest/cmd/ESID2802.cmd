#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Edition balance technique
# nom du script SHELL		: ESID2802.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 01/10/1997
# auteur			: CGI (KUHNA)
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Technical balance print out
#
# job launched by ESID2800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

. ${DCMD}/ESCD9002.cmd

# Initialisation of the Job
JOBINIT


NSTEP=${NJOB}_05
#si pas de fichier genere par le split precedent
#---------------------------------------------------------------
if test ! -s ${DFILT}/${NJOB}_${IB}_ESTR7630_GTSIMP_O.dat
then
  JOBEND
fi

NSTEP=${NJOB}_10
#
#---------------------------------------------------------------
LIBEL="Add last page number on each report page"
FWLP_I=${DFILT}/${NJOB}_${IB}_ESTR7630_GTSIMP_O.dat
FWLP_O=${DFILT}/${NSTEP}_${IB}_ESTR7630_WLP_O.dat
EST_WLP

NSTEP=${NJOB}_15
#
#---------------------------------------------------------------
LIBEL="Remove temporary file"
RMFIL "${DFILT}/${NJOB}_${IB}_ESTR7630_GTSIMP_O.dat"

NSTEP=${NJOB}_20
#subject : etat balance technique
#Modif OG 01/10/02, l'edition ne sortira que ds INTRANET et plus sous papier
#--------------------------------------------------------------------------
LIBEL="Print out launch"
PRT_NAME=${PRTID}
PRN_OUT=WEB
PRN_I=${DFILT}/${NJOB}_10_${IB}_ESTR7630_WLP_O.dat
PRN_FMT="estr7630"
PRN

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_25
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" 

JOBEND

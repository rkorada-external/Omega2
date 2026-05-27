#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Extraction en base de fichiers EST pour les traitements ecritures post omega
# nom du script SHELL           : ESPT0002.cmd
# revision                      :
# date de creation              : 09/10/2015
# auteur                        : R. Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   :spot:28941 Extraction de fichiers en base pour traitements trimestriels Post-Omega.
#
# job launched by ESPT0000.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#=============================================================================
#
#[001] 16/10/2015 R. Cassis  :spot:29514 - correction date INVSERV_D au lieu de INVCONSO_D
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# get input parameters
INVSERV_D=$1

# Job Initialisation
JOBINIT

ECHO_LOG "================================"
ECHO_LOG "--> INVSERV_D = ${INVSERV_D}"
ECHO_LOG "================================"

NSTEP=${NJOB}_10
# Switch to datawharehouse server
#----------------------------------------------------------------------------
LIBEL="Switch to datawharehouse server ${SRV_2}"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_20
#Generation of FCTRGROLESII File
#-----------------------------------------------------------------------------
LIBEL="FCTRGROLESII Segment File Generation from TUWSEC..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EPO_FCTRGROLESII}"
BCP_QRY="execute BSAR..PsRISKMARGIN_SEG '${INVSERV_D}', 'POS'  with recompile"
BCP

NSTEP=${NJOB}_100
#-----------------------------------------------------------------
LIBEL="delete of temporary files.."
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"

JOBEND


#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3062.cmd
# revision:                       $Revision: 1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# save des fichiers gt
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  03/12/2009  Roger Cassis      :spot:18415 -> Mise à jour parametres plus utilises
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
NUMFILE=${1}

NSTEP=${NJOB}_10
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTA
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_${NUMFILE}A.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_${NUMFILE}A.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESIX7000_${NUMFILE}A.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_20
# Sauvegarde ZIP! des Fichiers xxxxGTx Générés par la Chaîne ESTD3060
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTD3060_*_${NUMFILE}A_*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTD3060_*_${NUMFILE}A_*.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESTD3060_${NUMFILE}A_*.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

JOBEND

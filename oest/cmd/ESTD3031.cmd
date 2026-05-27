#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3031.cmd
# revision: $Revision:           1.1  $
# date de creation:              08/02/2007
# auteur:                        J.Ribot
# references des specifications : SPOT EST13720
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# job launched by ESTD3000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
NUMFILE=${1}
GTRETRO=${2}

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
# Sauvegarde ZIP! des Fichiers xxxxGTx Générés par la Chaîne ESTD3020
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTD3020_*_${NUMFILE}*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTD3020_*_${NUMFILE}A*.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESTD3020_${NUMFILE}A.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

JOBEND



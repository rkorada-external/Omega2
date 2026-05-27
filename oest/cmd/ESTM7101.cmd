#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTM7101
#
# nom du script SHELL		: ESTM7101.cmd
# revision			: $Revision:   1.21  $
# date de creation		: 27/02/2006
# auteur			: M. DJELLOULI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#  Sauvegarde des Fichiers CURGTx et ARCSTATGTx avant Transformation
#
# job lance par ESTM7100.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x
# Job Initialisation
JOBINIT

# Parameters
NUMFILE=$1

NSTEP=${NJOB}_10
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTA
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_${NUMFILE}A.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_${NUMFILE}A.dat"
ZIP_O="${DSAV}/svg_${SVG}_${PCH}ESIX7000_${NUMFILE}A.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_20
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTR
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_${NUMFILE}R.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_${NUMFILE}R.dat"
ZIP_O="${DSAV}/svg_${SVG}_${PCH}ESIX7000_${NUMFILE}R.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP


NSTEP=${NJOB}_30
# Sauvegarde ZIP! des Fichiers xxxxGTx Générés par la Chaîne ESTM7000
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTM7000_*_${NUMFILE}*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTM7000_*_${NUMFILE}*.dat"
ZIP_O="${DSAV}/svg_${SVG}_${PCH}ESTM7000_${NUMFILE}.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

JOBEND

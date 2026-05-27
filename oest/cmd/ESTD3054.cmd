#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3054.cmd
# revision:                       $Revision: 1.2 $
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
#  15/06/2009  Roger Cassis      :spot:17532 -  Si pas de donnees a extraire on stoppe le job sans Abort
#  03/12/2009  Roger Cassis      :spot:18415 -> Mise à jour parametres
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters

# Job Initialisation
JOBINIT

# Parameters

if [ ! -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_GTA_TRANSFP.dat" ] &&
   [ ! -s "${DFILT}/${ENV_PREFIX}_ESTD3050_ESTD3051_CURGTA_TRANSFP.dat" ]
then
  ECHO_LOG "---> No Data to process because Input files are empty - Stop processing"
  JOBEND
fi

NSTEP=${NJOB}_10
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTA
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_GTA.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_GTA.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESIX7000_GTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_20
# Sauvegarde ZIP! des Fichiers GTx Générés par la Chaîne ESTD3050
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTD3050_*_GTA*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTD3050_*_GTA*.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESTD3050_GTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_30
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTA
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_CURGTA.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_CURGTA.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESIX7000_CURGTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_40
# Sauvegarde ZIP! des Fichiers CURGTx Générés par la Chaîne ESTD3050
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTD3050_*_CURGTA*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTD3050_*_CURGTA*.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESTD3050_CURGTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_50
# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTA
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILP}/${PCH}ESIX7000_STATGTA.dat"
ZIP_ODIR=""
ZIP_I="${DFILP}/${PCH}ESIX7000_STATGTA.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESIX7000_STATGTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

NSTEP=${NJOB}_60
# Sauvegarde ZIP! des Fichiers STATGTx Générés par la Chaîne ESTD3050
#----------------------------------------------------------------------------
LIBEL="ZIP Fichier ${DFILI}/${PCH}ESTD3050_*_STATGTA*.dat"
ZIP_ODIR=""
ZIP_I="${DFILI}/${PCH}ESTD3050_*_STATGTA*.dat"
ZIP_O="${DSAV}/${SVG}_${PCH}ESTD3050_STATGTA.dat.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP

JOBEND

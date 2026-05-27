#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3041.cmd
# revision: $Revision:           1.1  $
# date de creation:              05/10/2007
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert Indiens
#
# job launched by ESTD3040.cmd
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


JOBEND



#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT  INTER-SITES
# nom du script SHELL:            ESTD3013.cmd
# revision:                       $Revision: 1.1.1.1 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# save des fichiers créés par ESTD3010 et des fichiers GT CURGT STAGT ARCSTATGT
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 19/08/2015 Roger Cassis :spot:29223 Remplace ZIP par gzip
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
LIBEL="gzip Fichier ${DFILP}/${ENV_PREFIX}_ESIX7000_${NUMFILE}A.dat"
EXECKSH_MODE=P
EXECKSH "gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_${NUMFILE}A.dat > ${DSAV}/${SVG}_${ENV_PREFIX}_ESIX7000_${NUMFILE}A.dat.gz"

if [ ${GTRETRO} = "1" ]             # on traite les fichiers retro
then

	NSTEP=${NJOB}_20
	# Sauvegarde ZIP! du Fichier avant Remplacement xxxxGTR
	#----------------------------------------------------------------------------
	LIBEL="gzip Fichier ${DFILP}/${ENV_PREFIX}_ESIX7000_${NUMFILE}R.dat"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_${NUMFILE}R.dat > ${DSAV}/${SVG}_${ENV_PREFIX}_ESIX7000_${NUMFILE}R.dat.gz"

fi

NSTEP=${NJOB}_30
# Sauvegarde ZIP! des Fichiers xxxxGTx Générés par la Chaîne ESTD3010
#----------------------------------------------------------------------------
LIBEL="cp ${DFILI}/${PCH}ESTD3010_*_${NUMFILE}A_*.dat ${DSAV}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILI}/${PCH}ESTD3010_*_${NUMFILE}A_*.dat ${DSAV}"

NSTEP=${NJOB}_40
#Sauvegarde file deletion
#------------------------------------------------
LIBEL="Sauvegarde gz file deletion in progress"
RMFIL "${DSAV}/${PCH}ESTD3010_*_${NUMFILE}A_*.dat.gz"

NSTEP=${NJOB}_50
# Sauvegarde ZIP! des Fichiers xxxxGTx Générés par la Chaîne ESTD3010
#----------------------------------------------------------------------------
LIBEL="gzip ${DSAV}/${PCH}ESTD3010_*_${NUMFILE}A_*.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DSAV}/${PCH}ESTD3010_*_${NUMFILE}A_*.dat"

JOBEND



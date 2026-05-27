#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - Non Proportionnel Cat Cover / Assistance Entry
# nom du script SHELL            : ESIJ2000.cmd
# revision                       :
# date de creation               : 27/01/2015
# auteur                         : R. Cassis
# references des specifications  : :spot:28139
#-----------------------------------------------------------------------------
# description
#   Automatisation du calcul des écritures service de Rétrocession
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#[001] JJ/MM/AAAA prog. name  :spot:xxxxx Commentaires
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
if [ -s ${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM1.dat ]
then
	set `GETPRM ${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM1.dat` 
	ICLODAT_D=${7}
else
	set `GETPRM ${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM0.dat` 
	ICLODAT_D=${102}
fi

# IFRS Closing
POST_OMEGA=0
if [ `grep -c "IsEpo=Y" ${DFILP}/${ENV_PREFIX}_ESCJ0000_PLAN0.dat` -gt 0 ]
then
	# Post Omega Closing
	POST_OMEGA=1
fi

# Launch applicative job ESIJ2001
NJOB="ESIJ2001"
${DCMD}/ESIJ2001.cmd ${ICLODAT_D} ${POST_OMEGA} 2 >&1 | ${TEE}

CHAINEND

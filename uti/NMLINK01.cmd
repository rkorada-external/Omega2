#!/bin/ksh
#=============================================================================
# nom de l'application		: Utilitaire pour enchainement d UP Netmonitor
#                                 
# nom du script SHELL		: NMLINK01.cmd
# revision			: $Revision: 1.1 $
# date de creation		: 27/05/98
# auteur			: S.C.O.R.
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   si un fichier cree par une UP SOS existe, alors exit 12
#
# job launched by NMLINK00.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

NSTEP=${NJOB}_05
#
#-----------------------------------------------------------------------------
LIBEL="Si fichier existe alors exit 12 ..."
EXECKSH_MODE=P
EXECKSH "if test -f ${FNOK}
	then
	echo " l UP precedente s est plante "
	echo " on ne passe pas la suite "
	rm ${FNOK}
	# execution d une commande qui n existe pas pour planter
	aaaa
	fi"

JOBEND

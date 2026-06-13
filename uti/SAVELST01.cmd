#!/bin/ksh
#=============================================================================
# nom de l'application		: EXPLOITATION - 
# description			 sauvegarde des listes pouvant etre reimprimees 
# nom du script SHELL		: SAVELST01.cmd
# revision			: $Revision: 1.1 $
# date de creation		: 30/01/98
# auteur			: S.C.O.R.
# references des specifications	: 
#
# Job launched by SAVELST00.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Begin copy
#-----------------------------------------------------------------------------
LIBEL="mv of *RTCJ0500*.... file"

echo "mv of *RTCJ0500*.... file"
mv $DLST/*RTCJ0500*RTCJ0502*AWK* /save01/save_LST

JOBEND

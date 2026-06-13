#!/bin/ksh
#=============================================================================
# nom de l'application		: EXPLOITATION - 
# nom du script SHELL		: TARFS01.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 30/01/98
# auteur			: S.C.O.R.
# references des specifications	: 
#
# Job launched by TARFS00.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Begin rm
#--------------------------------------------------------
LIBEL="Delete old file tar"
RMFIL "${TAR_FILE}*"

NSTEP=${NJOB}_10
# cd on file system source
#--------------------------------------------------------
LIBEL="cd on file system source"
EXECKSH " cd ${FSDIR}"

NSTEP=${NJOB}_15
# Begin tar
#--------------------------------------------------------
LIBEL="tar file system"
STEPEND_CONTINUE=YES
#EXECKSH " tar cf ${TAR_FILE} . "
EXECKSH "/usr/sfw/bin/gtar -zcf ${TAR_FILE} . "
STEPEND_CONTINUE=NO

NSTEP=${NJOB}_20
# Compress tar file
#--------------------------------------------------------
LIBEL="Compress tar file"                         
#EXECKSH " compress ${TAR_FILE} "

JOBEND

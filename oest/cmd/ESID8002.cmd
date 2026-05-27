#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Restitution d'inventaire acceptation
# nom du script SHELL		: ESID8002.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 02/09/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#    Acceptance closing period restitution
#
# job launched by ESID8000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT




NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Truncate table TCESSION"
ISQL_BASE="BEST"
ISQL_QRY="delete BEST..TCESSION where ${EST_SORT_CONDITION}"
ISQL

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update table TCESSION"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FBESTCESSION}
BCP_TABLE="BEST..TCESSION"
BCP   

NSTEP=${NJOB}_15
# Deletion of FBESTCESSION permanent file
#-----------------------------------------------------------------------------
LIBEL="Deletion FBESTCESSION permanent file ..."
RMFIL ${EST_FBESTCESSION}

JOBEND

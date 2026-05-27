#!/bin/ksh
#=============================================================================
# nom de  l'application		: ESTIMATIONS - INVENTAIRE
#
# nom du script SHELL		: ESID8032.cmd
# revision			         : $Revision: 1.3 $
# date de creation		   : 08/2010
# auteur			            : T.RIPERT
#
#-----------------------------------------------------------------------------
# description              : "Mise à jour SUM at RISK de BEST..TLIFEST"
#
#
# job launched by ESID8030.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
BALSHTYEA_NF=$1
CRE_D=$2
BALSHTMTH_NF=$3


NSTEP=${NJOB}_05
# Begin  isql
#--------------------------------------------------------------------------
LIBEL="Mise à jour SUM at RISK de BEST..TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PtLIFEST_01 0,0,0,0,0,'','0001'"
ISQL

JOBEND

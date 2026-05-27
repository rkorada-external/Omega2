#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Generation fichier Reporting pour RA
# nom du script SHELL           : ESID8110.cmd
# revision                      : 
# date de creation              : 08/04/2016
# auteur                        : Roger Cassis
# references des specifications : :spot:30475
#-----------------------------------------------------------------------------
# Description :
#  Generation d'un fichier de reporting provenant du Bresil pour un chargement dans RA
#
# Launch applicative job ESID8111
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] JJ/MM/AAAA <prog name> :spot:xxxxx - Comment
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

if test $2
then
	ORIGINE_NF=$2
else
	ECHO_LOG "'Origine' file name must be indicated as parm value"
	ECHO_LOG "File processed has this form : $DFILI/X_CNED0010_Origine_SSds_FTECLEDX.dat - Process Stopped"
	CHAINEND
fi

P_BALSHTRIM_NF=""
if test $3
then
	P_BALSHTRIM_NF=$3
fi

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${DPRM}/ESID8110.prm`
BALSHTRIM_NF=$1

if [ "${P_BALSHTRIM_NF}" != "" ]
then
   BALSHTRIM_NF=${P_BALSHTRIM_NF}
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> BALSHTRIM_NF ${BALSHTRIM_NF} sent by parm overides .prm data"
	ECHO_LOG "#========================================================================="
fi

# Launch applicative job ESID8111
NJOB="ESID8111"
${DCMD}/ESID8111.cmd ${ORIGINE_NF} ${BALSHTRIM_NF} 2>&1 | ${TEE}

CHAINEND

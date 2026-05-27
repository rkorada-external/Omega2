#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS - NETTOYAGE TREQJOB
# nom du script SHELL           : ESCJ0010.cmd
# date de creation              : 28/09/2010
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:  Suppression des anciennes demandes non ex�cut�es dans la TREQJOB
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : 
#Date           : 
#Version        : 
#Description    : 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Recovers input parametrs
set `GETPRM ${DPRM}/ESCJ0000.prm` 
CRE_D=$1



IDF_CT="$2"


# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

# suppression des demandes plant�es dans TREQJOB
NJOB="ESCJ0011"
${DCMD}/ESCJ0011.cmd ${CRE_D} 2>&1 | ${TEE}

CHAINEND

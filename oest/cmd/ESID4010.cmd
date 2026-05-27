#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Internal Retro
# nom du script SHELL           : ESID4010.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 15/01/2001
# auteur                        : O.GIRAUX
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Internal Retro
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 22/10/2012 Roger Cassis :spot:24041 - Modifications pour Solvency - ajout parametre INV pour ESID2504
#[002] 20/03/2013 Philippe Pezout :spot:24979 - Modifications pour Solvency - ajout parametre IFRS pour ESID2504
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	
# Output files
#	
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd  

# Chain Initialization variables
CHAININIT $0 $1

# Recovers input parametrs
set `GETPRM ${EST_PARAM}` 
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8 

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D} 

# Launch applicative job ESID2504 
# DLREGTR and DLREMAJGTR Files Generation
#[001]
NJOB="ESID2504"
${DCMD}/ESID2504.cmd ${BALSHTYEA_NF} ${ICLODAT_D} INV IFRS 2>&1 | ${TEE} 

CHAINEND

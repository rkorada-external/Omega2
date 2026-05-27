#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Generation des Annulations
# nom du script SHELL           : ESLD1900.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#    Generation des Annulations
#
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
#===============================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_CURGTA
#	EST_CURGTR
#	EST_GTA
#	EST_GTR
#	EST_IGTAA0
#	EST_IGTAR0
#	EST_IGTR0
# Output files
#	EST_DLAGTAA0
#	EST_DLAGTAR0
#	EST_DLAGTR0
#	EST_IGTAA0
#	EST_IGTAR0
#	EST_IGTR0
#-=-=-=-=-=-=-=-=-=-=-=

# Chain Initialization variables
CHAININIT $0 $1

#  Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
CONSOYEA=${22}
CONSOMTH=${23}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESLD1901
NJOB="ESLD1901"
${DCMD}/ESLD1901.cmd ${CLODAT_D} ${CONSOYEA} ${CONSOMTH} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}
 
# Launch applicative job ESLD1902
NJOB="ESLD1902"
${DCMD}/ESLD1902.cmd ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND

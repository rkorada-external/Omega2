#!/bin/ksh 
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : TNR  des FTECLEDA , FTECLEDR  P&C  et ceux de l'inventaire
# nom du script SHELL           : ESID8711.cmd
# revision                      : 
# date de creation              : 26/02/2020
# auteur                        : M. NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :SPIRA: 81838 - Split Life et P&C
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001]	26/02/2020	M.NAJI  	   :SPIRA 81838 : Split Life et P&C
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}



# Launch applicative job ESID8711 ACCEPT
NJOB="ESID8711"
${DCMD}/ESID8711.cmd  2>&1 | ${TEE}

# Launch applicative job ESID8712 RTRO 
NJOB="ESID8712"
${DCMD}/ESID8712.cmd  2>&1 | ${TEE}

wc -l $DFILT/diff_FTECLEDA.dat $DFILT/diff_FTECLEDR_INTERNE.dat $DFILT/diff_FTECLEDR.dat  2>&1 | ${TEE}

CHAINEND

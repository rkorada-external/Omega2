#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 MAJ de la segmentation
# nom du script SHELL           : ESID8060.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 01/08/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Update of the segmentation (lot 33)
#-----------------------------------------------------------------------------
# historiques des modifications
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
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYP_CT=${20}
SSDACC_LL=${60}
BATCHUSER=${103}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}
 
# Launch applicative job ESID8061
NJOB="ESID8061"
${DCMD}/ESID8061.cmd ${CRE_D} ${CLODAT_D} ${SSDACC_LL} ${SEGTYP_CT} ${BATCHUSER} 2>&1 | ${TEE}

CHAINEND

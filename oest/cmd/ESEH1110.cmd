#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
# nom du script SHELL           : ESEH1110.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 09/09/1998
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of acceptance perimeter
#
#-----------------------------------------------------------------------------
# historiques des modifications
#  01/06/2010   Roger Cassis    :spot:19204 - Optimisation ESEH1100 par parallélisation et découpage en 2 chaines 1100+1110
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Output files
#	EST_IADPERICASE0
#	EST_IAVPERICASE0
#	EST_IADPERIFCT0
#	EST_FCESSION0
#	EST_FPLACEMT0
#	EST_FUNDSTA0
#	EST_FCTRULT0
#	EST_FCTRGRO0
#	EST_FCPLACC0
#       EST_FLORETFACTOR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYP_CT=$8

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

OPTION='Q'

# Launch applicative job ESEH1110
NJOB="ESEH1111"
${DCMD}/ESEH1111.cmd ${OPTION} ${CLODAT_D} ${SEGTYP_CT} 2>&1 | ${TEE}

CHAINEND

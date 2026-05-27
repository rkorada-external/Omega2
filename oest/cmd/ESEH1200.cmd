#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
# nom du script SHELL           : ESEH1200.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01/10/1998
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   	Generation of the Infocenter tables
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FPLACEMT0
#	EST_IADPERICASE0
#	EST_FCESSION0
#	EST_FPLCANT
#	EST_FCESANT
# 	EST_FCTRGRO0
#	EST_FUNDSTA0
#	EST_FCTRULT0
#	EST_IADPERIFCT0
#
# Output files
#
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

OPTION='Q'

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESEH1201
NJOB="ESEH1201"
${DCMD}/ESEH1201.cmd ${OPTION} ${SEGTYP_CT} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE}

CHAINEND

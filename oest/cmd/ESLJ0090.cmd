#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE 
#                                 Extraction des ecritures de services Post Omega Local
# nom du script SHELL           : ESLJ0090.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Extraction et mise a jour dans BEST..TACCSUP des ecritures de service Local
#
# Input files
#       EPO_FCES
#       EPO_FCURCVSN
#       EPO_FCURCVSNI
#       EPO_FCURQUOT
#       EPO_FDETTRS
#       EPO_FPLATXCUM
#       EPO_FPLC
#       EPO_FTRANSCODE
#       EPO_FTRSLNK
#       EPO_IADVPERICASE
#       EPO_OIRDVPERICASE
#
# output files
#	     EPO_EPOLOC
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
CLODAT_D=$8
BOOKING_D=${18}
ENCONSO_D=${20}
INVCONSO_D=${21}
CONSOYEA=${22}
EBSPSTOMGEN_D=${29}
BLCSHTYEALOC_NF=${36}
BLCSHTMTHLOC_NF=${37}

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESLJ0091
NJOB="ESLJ0091"
${DCMD}/ESLJ0091.cmd ${CONSOYEA} ${INVCONSO_D} ${EBSPSTOMGEN_D} ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

# Launch applicative job ESLJ0092
NJOB="ESLJ0092"
${DCMD}/ESLJ0092.cmd ${BLCSHTYEALOC_NF} ${BLCSHTMTHLOC_NF} 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE 
#                                 Mise a jour et formatage des ecritures de service Post Omega Local
# nom du script SHELL           : ESLD1800.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Mise a jour des informations Retrocession et formatage au fichier GT des ecritures de service Local
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
#       EPO_DLSGTAALO
#       EPO_DLSGTARLOSO
#       EPO_DLSGTRLOSO
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

# Get the parameters
set `GETPRM ${EST_PARAM}`

SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
INVCONSO_D=${21}
CONSOYEA=${22}

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESLD1801
NJOB="ESLD1801"
${DCMD}/ESLD1801.cmd ${INVCONSO_D} ${CONSOYEA} 2>&1 | ${TEE}

CHAINEND

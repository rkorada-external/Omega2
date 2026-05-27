#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Gestion des ecritures de services Life IFRS17
#				  Batch quotidien
# nom du script SHELL		: ESFJ0090.cmd
# revision
# date de creation		: 26/08/2020
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#
#-----------------------------------------------------------------------------
# historique des modifications
# [01]  26/08/2029 SBE  :spira:89796 I17 : RETRO - Life SAP posting 
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCES
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FPLC
#	EST_FRETTRF
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


# Launch applicative job ESFJ0091
NJOB="ESFJ0091"
${DCMD}/ESFJ0091.cmd ${PARM_CRE_D} ${PARM_CLODAT_D} ${PARM_BLCSHTYEA_NF} ${PARM_PERTYP_CT} 2>&1 | ${TEE}


CHAINEND

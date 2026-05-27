#!/bin/ksh
#=============================================================================
# nom de l'application		: IFRS17 AE Life
#
# nom du script SHELL		: ESFJ0071.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 24/06/2020
# auteur			: S.Behague
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Extraction file for LIFE AE IFRS17
#   Parametre : I17G_OMG_EX_LIF
# Modifications
# [02]  29/04/2021 SBE  :spira:92905 I17P: Management of Life AE for the Closing norm "LOCAL"
#===============================================================================

#-=-=-=-=-=-=-=-=-=-=-=
# Input files

# Output files
# ESF_FACCSUPI17LIFE
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

#set -x

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
NORME=`echo ${IDF_CT} | awk -F"_" '{ print $1 }'`

# Recovers input parametrs
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESCJ0061
NJOB="ESFD0071"
${DCMD}/ESFD0071.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${NORME} 2>&1 | ${TEE}


CHAINEND

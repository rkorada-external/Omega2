#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
# nom du script SHELL		: ESFD5050.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 06/12/2022
# auteur			: M.SEKBRAOUDINE
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Copy of I17G files for I17S
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	ESF_FACCSUPI17LIFE
#	EST_FCES
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FPLC
#	EST_FRETTRF
# Output files
#	EST_DLSGTAA
#	EST_DLSGTAR
#	EST_DLSGTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD1801
NJOB="ESFD5051"
${DCMD}/ESFD5051.cmd ${PARM_ICLODAT_D} ${PARM_BLCSHTYEA_NF} 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL		: ESID2030.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 
# auteur			: 
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs ESCD9001 and ESID2031
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTR
#	EST_FACCPAR0
#	EST_FCESSION0
#	EST_FCPLACC0
#	EST_FCTRFIC
#	EST_FCURQUOT
#	EST_FDEPOSIT0
#	EST_FINTWIT
#	EST_FLIFDRI
#	EST_FLIFEST0
#	EST_FLSTMTH
#	EST_FPFUNWIT0
#	EST_FPINTWIT0
#	EST_FPLACEMT0
#	EST_FSEGPAR
#	EST_FTRSLNK
#	EST_FVPLACEMT
#	EST_GTR
#	EST_IARVPERICASE0
#	EST_IAVPERICASE0
#	EST_IRVPERICASE0
#	EST_LIFESTNOACC
#	EST_VACCPAR120
#	EST_VLIFEST195
#	EST_VTSTATGTA0
#	EST_GTA
#	EST_CURGTA
# Output files
#	EST_CPLIFDRI
#	EST_CPLIFDRIASC
#	EST_CPLIFEST
#	EST_CRIBLEANO
#	EST_FRATTACHEVOL
#	EST_FVPLACEMT
#	EST_IARVPERICASE0
#	EST_LIFESTNOACC
#	EST_SEGRATANO
#	EST_SRGTC
#	EST_SRGTCB1
#	EST_VACCPAR120
#	EST_VLIFEST195
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID3021
NJOB="ESID3021"
${DCMD}/ESID3021.cmd  ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESID3023
NJOB="ESID3023"
${DCMD}/ESID3023.cmd ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3022
NJOB="ESID3022"
${DCMD}/ESID3022.cmd ${BALSHTYEA_NF}  2>&1 | ${TEE}

# Launch applicative job ESID3023
#NJOB="ESID3023"
#${DCMD}/ESID3023.cmd ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3024
NJOB="ESID3024"
${DCMD}/ESID3024.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3025
NJOB="ESID3025"
${DCMD}/ESID3025.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}

# Launch applicative job ESID3026
NJOB="ESID3026"
${DCMD}/ESID3026.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID3027
NJOB="ESID3027"
${DCMD}/ESID3027.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3028
NJOB="ESID3028"
${DCMD}/ESID3028.cmd ${CRE_D} ${BALSHTYEA_NF} 2>&1 | ${TEE}

CHAINEND


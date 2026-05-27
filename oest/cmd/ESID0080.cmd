#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0080.cmd
# date de creation              : 17/06/2010
# auteur                        : D.GATIBELZA
# references des specifications : Optimisation des batch
#-----------------------------------------------------------------------------
# description
#   :spot:19204 - Launch perimeter and extract tables
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : []
#Auteur         :
#Date           :
#Version        :
#Description    :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
# ${EST_PARAM} is a global environment variable
#SSDs0 subsidiaries of all closing years
#CLODAT_D closing year label
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYP_CT=$8
CLODATMAX_D=${22}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}


# ne fait plus rien
CHAINEND

# SR Life
if [ ${EST_VARIANTE} = "7"   ]
then

	# Launch applicative job ESID0067
	NJOB="ESID0067"
	${DCMD}/ESID0067.cmd   ${SEGTYP_CT} ${BALSHTYEA_NF} ${BALSHTMTH_NF}  2>&1 | ${TEE}

	NJOB="ESID0065"
	${DCMD}/ESID0065.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODATMAX_D} 2>&1 | ${TEE}

	CHAINEND

fi

# Jobs launched if COND1 = N
if [ ${EST_ESID0080_COND1} = "N"  -a ${EST_ESID0080_COND3} = "N" ]
then

	# Launch applicative job ESID0064
	NJOB="ESID0064"
	${DCMD}/ESID0064.cmd 2>&1 | ${TEE}

fi

# Launch applicative job ESID0065
# Modif OG 18/11/02, on ajoute la clodat
NJOB="ESID0065"
${DCMD}/ESID0065.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODATMAX_D} 2>&1 | ${TEE}

# Launch applicative job ESID0066
NJOB="ESID0066"
${DCMD}/ESID0066.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}



CHAINEND

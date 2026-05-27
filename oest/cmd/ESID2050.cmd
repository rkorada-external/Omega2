#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESTD2050.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# Receipt of technical ledgers from retrocessionaire subsidiaries
#
#
# Launch applicative jobs ESCD9001 and ESID2051
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# J Ribot  10/07/2003   ajout CRE_D pour ESID2051
# P PEZOUT  02/11/2015 :spot:29615 EST45 gestion des doubles bouclettes RETRO
# M NAJI   24/03/2020  : SPIRA 81838 Devient commun et on ne garde que ESID2553
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_DLRIGTAA
#	EST_IADVPERICASE
# Output files
#	EST_ANORI
#	EST_DLRGTAA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

# Get parameters
set `GETPRM ${EST_PARAM}`

SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

if [ "${EST_ESPD2550_COND3}" = "Y" ]
then
	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
	#NJOB="ESID2552"
	#${DCMD}/ESID2552.cmd ${TYPEINV} ${NORME} 2>&1 | ${TEE}

	# Launch applicative job ESID2552 if no Request F (not the last day of Social Post Omega)
	NJOB="ESID2553"
	${DCMD}/ESID2553.cmd ${TYPEINV} ${NORME} 2>&1 | ${TEE}
fi

# Launch applicative job ESID2051
#NJOB="ESID2051"
#${DCMD}/ESID2051.cmd ${CRE_D} 2>&1 | ${TEE}

CHAINEND


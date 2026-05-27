#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion des GT acceptation
# nom du script SHELL		: ESID2060.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 02/09/97
# auteur			: CGI
# references des specifications	: Escom02f.doc
#-----------------------------------------------------------------------------
# description
#   Chain of merge of acceptance TL
#
# Launch applicative jobs ESCD9001 ESID2061
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 30/10/2019 M. NAJI       :spot:81838 - ajoute le mode IFRS4 avec un IDF_CT  

#===============================================================================
#
#  J. Ribot 22/11/2004  ajout ESID2062 pour création fichier DLTOTITGTA
#

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

if [ "${IDF_CT}" = "I4_LIFE___" ]
then
        IDF_CT=""
fi


#[001]
if [ "${IDF_CT}" != "" ]
then
	NJOB="ESCD9001"
        # Launch applicative job ESCD9001
        . ${DCMD}/ESFD9001.cmd "${IDF_CT}"
fi



#  Get Entry Parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

if [ "${IDF_CT}" = "" ]
then

	NJOB="ESCD9001"
	# Launch applicative job ESCD9001
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
fi

# Launch applicative job ESID2061
NJOB="ESID2061"
${DCMD}/ESID2061.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF}  ${ICLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID2062
NJOB="ESID2062"
${DCMD}/ESID2062.cmd ${BALSHTYEA_NF} ${CLODAT_D} 2>&1 | ${TEE}

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#							  Remontée périodique des estimations vie en tables	et/ou
#                             Initialisation annuelle
# nom du script SHELL		: ESID8030.cmd
# revision			: $Revision: 1.2 $
# date de creation		: 26/05/97
# auteur			: C.G.I. (C.Chavatte)
# references des specifications	: ESIIV01F.doc
#-----------------------------------------------------------------------------
# description
#   Chain of life table update (set 21)
#-----------------------------------------------------------------------------
# historique des modifications
#  G. BUISSON     08/09/2003    Ajout du parametre BALSHTMTH_NF dans le lancement de
#                              ESID8031.cmd pour eviter de prendre les lignes posterieures
#                              au mois bilan a traiter suite au deblocage des periodes
#                              exceptionnelles
#
#  T.RIPERT       02/08/2010   Ajout ESID8032.cmd alimentation SUM at RISK
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_CPLIFDRI
#	EST_CPLIFEST
#	EST_FRATTACHEVOL
#	EST_IARVPERICASE
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6


# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

# Launch applicative job ESID8031
NJOB="ESID8031"
if [ "${CRE_D}" != "20001231"   ]
then
  ${DCMD}/ESID8031.cmd ${BALSHTYEA_NF} ${CRE_D} ${BALSHTMTH_NF} 2>&1 | ${TEE}
fi

# Launch applicative job ESID8032
NJOB="ESID8032"
#${DCMD}/ESID8032.cmd ${BALSHTYEA_NF} ${CRE_D} ${BALSHTMTH_NF} 2>&1 | ${TEE}

CHAINEND

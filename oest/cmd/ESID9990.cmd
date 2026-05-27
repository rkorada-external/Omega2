#!/bin/ksh
#==============================================================================
#nom de l'application          :
#nom du source                 : ESID9990
#revision                      :
#date de creation              : 18/01/2001
#auteur                        : S. Llorente
#references des spicifications : #################
#squelette de base             :
#------------------------------------------------------------------------------
#description :
#
# Objet : Control by DBCC on each databases of SQL Server
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#    25/10/2005  J. Ribot automatisation de la gestion des paramètres en entrée
#                          suppression  ${DPRM}/ESID9990.prm
#[001] 01/08/2016 R. Cassis :spot:31046 - Ajout variables PARM0 pour Archivage table TTECLEDSII du trimestre -1
#=============================================================================
#set -x

. ${DUTI}/fctgen.cmd


# Chain Initialization variable
CHAININIT $0 $1


# Get parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
CONSOYEA_NF=${34}
SUFFTABLE=${39}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

TYPTAB=W
TRIM='4Q'
TRIMSII='3Q'

if [ ${BALSHTMTH_NF} = "3"   ]
then
	TRIM='1Q'
	TRIMSII='4Q'
fi

if [ ${BALSHTMTH_NF} = "6"   ]
then
	TRIM='2Q'
	TRIMSII='1Q'
fi

if [ ${BALSHTMTH_NF} = "9"   ]
then
	TRIM='3Q'
	TRIMSII='2Q'
fi

#------------------------------------------------------------------------------
# Commutation transactions calculation
#------------------------------------------------------------------------------
# Launch applicative job ESID9991
NJOB="ESID9991"
${DCMD}/ESID9991.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} "${TRIM}${BALSHTYEA_NF}" ${TYPTAB} "${TRIMSII}${CONSOYEA_NF}" ${SUFFTABLE}  2>&1 | ${TEE}


CHAINEND

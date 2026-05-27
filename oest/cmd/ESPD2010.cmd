#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESPD2010.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 16/09/97
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   Non life acceptance closing period process ( set 10 )
#
#   Launch application jobs ESCD9001 and ESID2011-2-3-4  
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 18/04/2012 Roger Cassis :spot:23802 - module de calcul des IBNR pour solvency
#[002] 23/10/2012 Roger Cassis :spot:24041 - Ajustements SOLVENCY
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=


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
CLOTYP_CT=${10}
SEGTYP_CT=${11}
SSDDEL_LL=${12}
LSTCLODAT_LL=${13}
SSDVRS_LL=${14}
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

if [ "${EST_ESPD2000_COND1}" = "Y" ]
then
	TYPEINV=POS
else
	TYPEINV=POC
fi

# Launch applicative job ESID2011
NJOB="ESPD2012"
#${DCMD}/ESID2012.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} EBS ${TYPEINV} 2>&1 | ${TEE}
${DCMD}/ESID2012.cmd ${CRE_D} ${CONSOYEA} ${CLOTYP_CT} ${INVCONSO_D} ${SSDs0} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} EBS ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESID2011
NJOB="ESPD2013"
#${DCMD}/ESID2013.cmd ${TYPEINV} ${ICLODAT_D} 2>&1 | ${TEE}
${DCMD}/ESID2013.cmd ${TYPEINV} ${INVCONSO_D} 2>&1 | ${TEE}

# Launch applicative job ESID2011
NJOB="ESPD2014"
#${DCMD}/ESID2014.cmd ${CRE_D} ${CLOTYP_CT} ${ICLODAT_D} ${EST_VARIANTE} 2>&1 | ${TEE}

CHAINEND


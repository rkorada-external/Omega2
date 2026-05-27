#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESPD2500.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 16/09/97
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description : :spot:24041 nouvelle chaine
#   Non life acceptance closing period process ( set 10 )
#
#   Launch application jobs ESCD9001 and ESID2001-2-3-4  
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[xxx]
#[001] 20/03/2013 Philippe Pezout :spot:24979 SOLVENCY II Ajout norme pour ESID2504
#[002] 21/06/2021  M.NAJI   : Spira 91532 mise en commentaire du calcul de TYPEINV  deja calculé dans leESFD9001 et force NORME=IFRS
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

#if [ "${EST_ESPD2500_COND1}" = "Y" ]
#then
#	TYPEINV=POS
#else
#	TYPEINV=POC
#fi
#if [ "${EST_ESPD2500_COND2}" = "Y" ]  # [003]
#then
#	NORME=EBS
#else
#	NORME=IFRS
#fi

# Launch applicative job ESID2504 
# Application of cessions and placements to the acceptance estimates for proportional retrocession treaties
NJOB="ESPD2504"
#${DCMD}/ESID2504.cmd ${BALSHTYEA_NF} ${ICLODAT_D} ${TYPEINV} 2>&1 | ${TEE} 
${DCMD}/ESID2504.cmd ${CONSOYEA} ${INVCONSO_D} ${TYPEINV} IFRS 2>&1 | ${TEE} 

CHAINEND


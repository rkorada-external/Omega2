#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Envoi de fichiers log pour consultation utilisateur
# nom du script SHELL           : ESPD8050.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 28/04/2015
# auteur                        : R. cassis
# references des specifications : Spira EST57
#-----------------------------------------------------------------------------
# description : 
#   Les fichiers log IBNR généré dan le ESPD2000 est découpé par filiale établissement et envoyé vers le serveur Web pour consultation utilisateur
#
#   Launch application jobs ESCD9001 and ESID8051  
#   :spot:28860
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 21/06/2021  M.NAJI   : Spira 95833 mise en commentaire du calcul de TYPEINV qui est dejà calculé  dans le 9001 et pour avoir le cas INV
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters# Get the parameters
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

#if [ "${EST_ESPD2000_COND1}" = "Y" ]
#then
#	TYPEINV=POS
#else
#	TYPEINV=POC
#fi

# Launch applicative job ESID8051
NJOB="ESID8051"
${DCMD}/ESID8051.cmd ${ICLODAT_D} EBS ${TYPEINV} 2>&1 | ${TEE}

CHAINEND

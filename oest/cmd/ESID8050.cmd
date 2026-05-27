#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Envoi de fichiers log pour consultation utilisateur
# nom du script SHELL           : ESID8050.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 28/04/2015
# auteur                        : R. cassis
# references des specifications : Spira EST57
#-----------------------------------------------------------------------------
# description : 
#   Les fichiers log IBNR et NPSAIS générés dans le ESID2000 sont découpés par filiale et envoyés dans vers le serveur Web pour consultation utilisateur
#
#   Launch application jobs ESCD9001 and ESID8051  
#   :spot:28860
#-----------------------------------------------------------------------------
# historique des modifications :
#[xxx] JJ/MM/AAAA Prog. name   :spot:xxxxx description
#[001] 29/06/2021 M.NAJI : SPIRA 95833 commenté le calcul de NORME et forcer le paramètre à  IFRS
#===============================================================================
#set -x

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

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

#if [ "${EST_ESID2000_COND1}" = "Y" ]     # option EBS ?
#then
#	NORME=EBS
#else
#	NORME=IFRS
#fi

# Launch applicative job ESID8051
NJOB="ESID8051"
${DCMD}/ESID8051.cmd ${ICLODAT_D} IFRS INV 2>&1 | ${TEE}

CHAINEND

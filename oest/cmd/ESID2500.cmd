#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - 
#                                 Retrocession closing period process
# nom du script SHELL           : ESID2500.cmd
# revision                      : $Revision:   1.5  $
# date de creation              : 06/10/1997
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
# 
#
# Launch applicative jobs ESCD9001, ESID2501,2502,2503,2504,2505 and 2506   
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 10/07/2012 Roger Cassis :spot:23802 SOLVENCY II Ajout type inventaire pour ESID2504
#[002] 20/03/2013 Philippe Pezout :spot:24979 SOLVENCY II Ajout norme pour ESID2504
#[003] 31/10/2019 M.NAJI        :spot:81838 - Déplacement du job ESID2501 de ESID2500 vers ESID0560 pour la création de EST_FLPC et EST_FCES
#[004] 29/06/2021 M.NAJI : SPIRA 95833 commente le calcul de NORME et forcer le parametre a IFRS
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

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


# pour le creer s'il n'existe pas
touch ${EST_DLRGTAA}

#[005]
# Launch applicative job ESID2501 
#NJOB="ESID2501"
#${DCMD}/ESID2501.cmd 2>&1 | ${TEE} 

# Launch applicative job ESID2502 
if [ "${EST_ESID2500_COND1}" = "Y" ]
then   
   NJOB="ESID2502"
   ${DCMD}/ESID2502.cmd 2>&1 | ${TEE} 
fi

# Launch applicative job ESID2502 
#if [ "${EST_ESID2500_COND2}" = "Y" ]
#then
#	NORME=EBS
#else
#	NORME=IFRS
#fi

# Launch applicative job ESID2503 
NJOB="ESID2503"
${DCMD}/ESID2503.cmd ${BALSHTYEA_NF} ${ICLODAT_D} 2>&1 | ${TEE} 

# Launch applicative job ESID2504 
NJOB="ESID2504"
${DCMD}/ESID2504.cmd ${BALSHTYEA_NF} ${ICLODAT_D} INV IFRS 2>&1 | ${TEE} 

# Launch applicative job ESID2505 
NJOB="ESID2505"
${DCMD}/ESID2505.cmd ${BALSHTYEA_NF} ${ICLODAT_D} 2>&1 | ${TEE} 

# Launch applicative job ESID2506
NJOB="ESID2506"
${DCMD}/ESID2506.cmd ${BALSHTYEA_NF} ${ICLODAT_D} 2>&1 | ${TEE}


EXECKSH "cp ${EST_DLREGTR} ${EST_DLREGTR_PC}"
EXECKSH "cp ${EST_DLRGTAA} ${EST_DLRGTAA_PC}"
EXECKSH "cp ${EST_DLREMAJGTR} ${EST_DLREMAJGTR_PC}"


CHAINEND

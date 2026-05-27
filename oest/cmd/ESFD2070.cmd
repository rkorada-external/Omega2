#!/bin/ksh
#=============================================================================
# nom de l'application	: ESTIMATIONS - INVENTAIRE
#                       	Inventaire vie
# nom du script SHELL	: ESID2030.cmd
# revision				: $Revision:   1.8  $
# date de creation		: 
# auteur				: 
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Life
#   Launch applicative jobs ESCD9001 and ESID2031
#-----------------------------------------------------------------------------
# historique des modifications
# [001] 14/10/2014 JBG :spot:25773 Ajout du mois bilan pour le ESID3028
# [002] 23/03/2015 J.FONTANA : Spot#28559 -> EST24BT
# [003] 13/08/2015 D.FILLINGER : SPOT # 29221 -> EST41
# [004] 07/03/2016 R.BEN EZZINE :spot:29579 ajout ${CLODAT_D} a l'entree du ESID3027
# [005] 03/06/2016 S.Behague :spot:30300 EST39 
# [006] 14/06/2016 S.ASKRI   spot:30741 traite automatiques
# [007] 22/02/2017 DFI spira 59440 desactivation des calculs automatiques et segmentes
# [008] 21/08/2018 HHH spira 64222 reactivation du Batch ESID3026A (2 passes) sans passer par SEGMENTATION
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

# Passage
PASS1=1
PASS2=2

# Launch applicative job ESCD9001
NJOB="ESCD9001_${IT}"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D} ${IT}

# Launch applicative job ESID3021 -> PLACEMNT + PERICASE
NJOB="ESID3021_${IT}"
${DCMD}/ESID3021.cmd  ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${CLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID3023 -> VLIFEST
NJOB="ESID3023_${IT}"
${DCMD}/ESID3023.cmd ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3022 -> GT
NJOB="ESID3022_${IT}"
${DCMD}/ESID3022.cmd ${BALSHTYEA_NF}  2>&1 | ${TEE}

CHAINEND

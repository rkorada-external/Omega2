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
# [009] 03/02/2021 SBE :spira:93252 [TECH] Closing Life - Optimisation
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
export IT=`echo $2 | awk -F"_" '{ print $2 }'`


# Passage
PASS1=1
PASS2=2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


# Launch applicative job ESID3021 -> PLACEMNT + PERICASE
NJOB="ESID3021_${IT}"
${DCMD}/ESID3021.cmd  ${PARM_BALSHTYEA_NF} ${PARM_BALSHTMTH_NF} ${PARM_CRE_D} ${PARM_ICLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID3023 -> VLIFEST
NJOB="ESID3023_${IT}"
${DCMD}/ESID3023.cmd ${PARM_ICLODAT_D} ${PARM_CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3022 -> GT
NJOB="ESID3022_${IT}"
${DCMD}/ESID3022.cmd ${PARM_BALSHTYEA_NF}  2>&1 | ${TEE}

CHAINEND

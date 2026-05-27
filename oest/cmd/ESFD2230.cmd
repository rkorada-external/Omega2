#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESID2220.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/07/2018
# auteur                        : JYP
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#              for IFRS Losses and IBNR calculation
#
#              Launch application jobs ESCD9001 and ESID2002A
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 20/07/2018 : JYP : creation , copied from ESID2000.cmd
#[002] 25/09/2019 : RC  :spira:65656 ajout cotes dans IDFCT car pas fait.
#[003] 17/10/2019 : M.NAJI : spira 78653 remettre le parallellisme des job qui a ete commente
#[004] 21/10/2019 : RC  :spira:78653 Rajoute TYPEINV dans les noms de job pour qu'ils soient bien reconnus dans le ESFD2003C.
#[005] 24/10/2019 : RC  :spira:81934 Maintenant on met l'IDFCT dans les noms de job au lieu du TYPEINV pour qu'ils soient bien reconnus dans le ESFD2003C.
#[006] 12/1//2022 : M.NAJI  :spira 101406 split du ESFD2220 en ESFD2200,ESFD2230 ESID2210  ==> optimisation
#===================================================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Chain Initialization variables
CHAININIT $0 $1


IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

# Launch applicative job ESFD2003A
NJOB="ESFD2003A${IDF_CT}"
${DCMD}/ESFD2003A.cmd ${TYPEINV} ${PARM_INVCONSO_D}  2>&1 | ${TEE}

# Launch applicative job ESFD2003C
NJOB="ESFD2231${IDF_CT}"
${DCMD}/ESFD2231.cmd ${TYPEINV} ${PARM_INVCONSO_D} 2>&1 | ${TEE}

CHAINEND


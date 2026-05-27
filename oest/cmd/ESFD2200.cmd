#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESFD2200.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 11/01/2022
# auteur                        : MNAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#              for IFRS Losses and IBNR calculation
#
#              Launch application jobs ESCD9001 and ESID2002A
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[006] 12/0//2022 : M.NAJI  :spira:xxxx split du ESFD2220 en ESFD2200 et ESFD2230 ==> ptimisation
#=================================================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Chain Initialization variables
CHAININIT $0 $1


IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"

PARALLEL_JOB_INIT 4

# Launch applicative job ESFD2003B
NJOB="ESFD2003B00${IDF_CT}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 00" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B01${IDF_CT}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 01" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B02${IDF_CT}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 02" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B03${IDF_CT}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 03" 

PARALLEL_JOB_END

# Launch applicative job ESFD2003C
NJOB="ESFD2201${IDF_CT}"
${DCMD}/ESFD2201.cmd  2>&1 | ${TEE}

CHAINEND


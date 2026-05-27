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
#===============================================================================

#set -x




# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
#set `GETPRM ${EST_PARAM}` 

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


NJOB="ESFD9001"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
. ${DCMD}/ESFD9001.cmd ""  

# Launch applicative job ESID2003A
NJOB="ESID2003A"
#${DCMD}/ESID2003A.cmd ${TYPEINV} ${INVCONSO_D} 2>&1 | ${TEE}
${DCMD}/ESID2003A.cmd ${TYPEINV} ${PARM_INVCONSO_D} 2>&1 | ${TEE}



CHAINEND

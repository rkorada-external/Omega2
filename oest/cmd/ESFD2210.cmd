#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESFD2210.cmd
# date de creation              : 09/10/2020
# auteur                        : JYP
#-----------------------------------------------------------------------------
# description :
#              for IBNR calculation
#
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 09/10/2018 : JYP : creation SPIRA 83609: copied from ESID2000.cmd / ESID2210.cmd
#===============================================================================



#set -x


IDF_CT=$2

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
. ${DCMD}/ESFD9001.cmd "$IDF_CT"


# Launch applicative job ESID2002A

if [ "${NORME_CF}" = "IFRS" ]     
then
	NJOB="ESID2002A"
	${DCMD}/ESID2002A.cmd ${PARM_CRE_D} ${PARM_BALSHTYEA_NF} ${PARM_CLOTYP_CT} ${PARM_ICLODAT_D} ${PARM_ISSDCLO_LL} ${PARM_SSDVRS_LL} ${PARM_LSTCLODAT_LL} ${PARM_SSDDEL_LL} IFRS INV 2>&1 | ${TEE}
else
	NJOB="ESID2002A${TYPEINV}"
	${DCMD}/ESID2002A.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CLOTYP_CT} ${PARM_INVCONSO_D} ${PARM_SSDCLO_LL} ${PARM_SSDVRS_LL} ${PARM_LSTCLODAT_LL} ${PARM_SSDDEL_LL} EBS ${PARM_TYPEINV} 2>&1 | ${TEE}
fi 





CHAINEND

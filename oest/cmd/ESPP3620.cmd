#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Solvency - Extract discount + ULAE + Bad debt + GLT feeding 
# nom du script SHELL           : ESPD3620.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28/06/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 069426 : REQ 00.01 - IFRS17- Closing schedule  
#                   split old ESPD3700 in 4 separate chains , 
#                   this new chain manage Extract discount + ULAE + Bad debt + GLT feeding parts 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 28/06/2018 JYP : SPIRA 069426 : new chain for calculation of Extract discount + ULAE + Bad debt + GLT feeding
#[002] 20/04/2020 M.NAJI :SPIRA 86220 optimisation ESPD3620, découpage ESID3703B en plusieurs jobs
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
#set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
INVCONSO_D=${21}
CONSOYEA_NF=${22}
CONSOMTH_NF=${23}


NJOB="ESCD9001_IFRS17"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001_IFRS17.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
. ${DCMD}/ESFD9001.cmd ""  


# Launch applicative job ESPD3621: Incurred pattern application on claims and cashflows accumulation
NJOB="ESPD3621A${TYPEINV}"
${DCMD}/ESPD3621A.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}


PARALLEL_JOB_INIT 3

# Launch applicative job ESPD3622A: Retrocession break down into acceptance and ESB / Cedent enrichment
NJOB="ESPD3622A${TYPEINV}"
${DCMD}/ESPD3622A.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV} 2>&1 | ${TEE}

# Launch applicative job ESPD3623: Reformat and transform Cashflows (SII) into GT transactions 
NJOB="ESPD3623${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3623.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}  ${DFILT}/${NCHAIN}_ESPD3621A${TYPEINV}_260_${IB}_SORT_DLDSIIGTAR.dat "

# Launch applicative job ESPD3624: Reformat and transform Cashflows (SII) into GT transactions 
NJOB="ESPD3624${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3623.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}  ${DFILT}/${NCHAIN}_ESPD3621A${TYPEINV}_269_${IB}_SORT_DLDSIIGTAA.dat "

PARALLEL_JOB_END

###############

PARALLEL_JOB_INIT 2

# Launch applicative job ESPD3624: Reformat and transform Cashflows (SII) into GT transactions 
NJOB="ESPD3625${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3623.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}  ${DFILT}/${NCHAIN}_ESPD3622A${TYPEINV}_269_${IB}_SORT_DLDSIIGTAA.dat "

# Launch applicative job ESPD3624: Reformat and transform Cashflows (SII) into GT transactions DLDSIIGTAA
NJOB="ESPD3626${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESPD3626.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}   "

PARALLEL_JOB_END

# Launch applicative job ESPD3624: TL transactions accumulation
NJOB="ESPD3627${TYPEINV}"
${DCMD}/ESPD3627.cmd ${PARM_CRE_D} ${PARM_INVCONSO_D} ${TYPEINV}  2>&1 | ${TEE}


CHAINEND

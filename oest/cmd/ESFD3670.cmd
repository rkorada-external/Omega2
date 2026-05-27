#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.1 : Expenses Calculation
# nom du script SHELL           : ESFD3670.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26/11/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 69814 : REQ 11.01 - IFRS17- Closing schedule : new chain to calculate Expenses amounts
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 26/11/2018 JYP : SPIRA 69814 : new chain for expenses calculation
[001]  11/04/2019 LEL : SPIRA 69814 : preparation steps for ESFC3670 optimisation  
#[002] 31/05/2019 JYP : SPIRA 69814 : avoid failure for request without TYPINV
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2



# Get entry parameters
set `GETPRM ${EST_PARAM}`
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



NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT} 


# temporary solution, because GO_NOGO is not well managed yet by new archi
if [ ! -z "$TYPEINV" ]
then

# Launch applicative job ESPD3011 Calcul of expenses
NJOB="ESFD3671${TYPEINV}"
${DCMD}/ESFD3671.cmd ${ICLODAT_D} ${TYPEINV} ${CRE_D}  2>&1 | ${TEE}

else
       ECHO_LOG "warning TYPEINV is empty, it should be a closing request error "
fi


CHAINEND


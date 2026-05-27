#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS4 - EBS - IFRS17  
# nom du script SHELL           : ESFD4020.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/10/2020
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 89923 Impact closing (agrégation par CSUOE des mouvements indépendant de la norme)
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 
#===============================================================================
#set -x

IDF_CT=$2
TRN_FLAG=$3

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1



NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


ECHO_LOG "#===> TYPEINV..............................: ${TYPEINV}"
ECHO_LOG "#===> NORME................................: ${NORME}" 
ECHO_LOG "#===> IDF_CT...............................: ${IDF_CT}" 
ECHO_LOG "#===> PARM_CONSOYEA........................: ${PARM_CONSOYEA}"
ECHO_LOG "#===> PARM_CONSOMTH........................: ${PARM_CONSOMTH}" 
ECHO_LOG "#===> PARM_INVCONSO_D .....................: ${PARM_INVCONSO_D}" 
ECHO_LOG "#===> PARM_ICLODAT_D.......................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> TRN_FLAG.............................: ${TRN_FLAG}" 
ECHO_LOG "#===> PARM_DBCLO_D.........................: ${PARM_DBCLO_D}"
ECHO_LOG "#===> PARM_CRE_D...........................: ${PARM_CRE_D}" 

# Launch applicative job ESFD4021 Calcul des Cashflow et valeur escompte
NJOB="ESFD4021${TYPEINV}"
${DCMD}/ESFD4021.cmd  ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${TYPEINV} $IDF_CT ${TRN_FLAG} 2>&1 | ${TEE} 


CHAINEND

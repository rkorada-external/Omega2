#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Gestion des ecritures de services Post Omega
#				  Batch quotidien
# nom du script SHELL		: ESPJ0090.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 16/06/2005
# auteur			: J. Ribot
# references des specifications	: SPOT 5085
#-----------------------------------------------------------------------------
# description
#	 special entries treatment ( set 78 )
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 04/11/2015 R. Cassis     :spot:29654 Gestion plan2 pour le Post-omega.
#[002] 22/12/2020 : M.NAJI : . SPIRA 91531 
#							. prise en compte de l'IDF_CT comme 2ème paramètres de la chaine 
#							. remplacement de ESCD9001 par ESPD9001
#[003] 04/07/2022 JBD     :spira:104778 Build new closing for I17S norm
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCES
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FPLC
#	EST_FRETTRF
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

# Launch applicative job ESFD9001
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT} 




if [ ${IDF_CT} != "I17G_AEE_RPO_INI" ] && [ ${IDF_CT} != "I17S_AEE_RPO_INI" ] &&  [ ${IDF_CT} != "I17P_AEE_RPO_INI" ] &&  [ ${IDF_CT} != "I17L_AEE_RPO_INI" ] &&  [ ${IDF_CT} != "I17G_AEE_RPO_I17" ]  &&  [ ${IDF_CT} != "I17S_AEE_RPO_I17" ]  &&  [ ${IDF_CT} != "I17P_AEE_RPO_I17" ] &&  [ ${IDF_CT} != "I17L_AEE_RPO_I17" ]
then

# Launch applicative job ESPJ0091
NJOB="ESPJ0091"
${DCMD}/ESPJ0091.cmd ${PARM_BOOKING_D} ${PARM_ENCONSO_D} ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${PARM_SUFFTABLE} 2>&1 | ${TEE}

else
# Launch applicative job ESPJ0092 for IFRS_17
NJOB="ESPJ0092"
${DCMD}/ESPJ0092.cmd ${PARM_BOOKING_D} ${PARM_ENCONSO_D} ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${PARM_SUFFTABLE} 2>&1 | ${TEE}

fi

CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESPD0060.cmd
# revision                      : $Revision:   1.21  $
# date de creation              : 16/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   extraction table TACCSUP pour les ecritures POST OMEGA
#-----------------------------------------------------------------------------
# historiques des modifications
#_________________
#MODIFICATION
#Auteur:         JF VDV
#Date:           23/05/2012
#Version:
#Description:    [23390] - SOLVENCY aménagements
#[002] 30/10/2012 Roger Cassis :spot:24041 - Solvency 2
#[003] 16/04/2019 MZM          :spira:70671 Future Retro For NP : Ajout de la ICLODAT
#[004] 22/12/2020 M.NAJI 	   :. SPIRA 91531 
#							 	. supression du mapping en dur dans le job ESPD0061.cmd et adaptaion du mapping
# 								. Ajout de l'IDF_CT 
#[004] 01/04/2021 CAS		  : SPIRA#94906 : Deplacement de la génération des fichiers NCB Assum et Retro dans ce batch
#[005] 26/08/2021 MZM     :spira:95950: Ajout extraction  PARM_BOOKINGNEXT_D
#[006] 16/01/2026 MZM     :US8221 : Prod Q4 2025 - AE BBNI extracted wrongly by normal EBS process (Ajout de ce JOB dans ESPD0060)
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Output files
#	EST_EPOSOCI
#	EST_EPOCONS

#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

if [ "${2}" = "" ]
then
	IDF_CT=${VNORME}_`basename $0 | cut -d"." -f1`
else
	IDF_CT="$2"
fi

NJOB="ESFD9001"
# Launch applicative job ESFD9001
.  ${DCMD}/ESFD9001.cmd  "${IDF_CT}"


NJOB="ESPD0061"
${DCMD}/ESPD0061.cmd ${PARM_BOOKING_D} ${PARM_PSTOMGEN_D} ${PARM_ENCONSO_D} ${PARM_EBSPSTOMGEN_D} ${PARM_CRE_D} ${PARM_INVCONSO_D} ${PARM_CONSOYEA} ${PARM_ICLODAT_D} ${PARM_BOOKINGNEXT_D}  2>&1 | ${TEE}

## The ESFD5062 has been move to ESFD5060

##if [ ${IDF_CT} = "EBS_ESPD0060" ]
##then

##NJOB="ESFD5062"
##${DCMD}/ESFD5062.cmd  2>&1 | ${TEE}

##fi

CHAINEND

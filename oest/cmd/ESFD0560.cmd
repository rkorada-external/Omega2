#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD0560.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 17/02/2021
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# historique des modifications
# [001] 15/07/2025 S.Behague : US5603 - SAS AE load- CSUOE control based on pericase - Spira 111627
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#EST_IADPERICASE0
#EST_IAVPERICASE0
#EST_FCESSION0
#EST_FCPLACC0
#EST_FPLACEMT0
# Output files
#EST_IADVPERICASE
#EST_FCESSION
#EST_FCPLACC
#EST_FPLACEMT
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
export VNORME=`echo $2 | awk -F"_" ' {print $1}'`

# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESFD0560.prm`
export X_DAYS=$1

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Launch applicative job ESFD0561
NJOB="ESFD0561"
${DCMD}/ESFD0561.cmd ${PARM_ICLODAT_D} ${PARM_PSTOMGEND17_D} ${PARM_CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESFD0562
NJOB="ESFD0562"
${DCMD}/ESFD0562.cmd ${PARM_ICLODAT_D} 2>&1 | ${TEE}


CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD1800.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 30/06/2020
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# historique des modifications
# [001] 23/12/2024 S.Behague : SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	ESF_FACCSUPI17LIFE
#	EST_FCES
#	EST_FCURCVSNI
#	EST_FCURQUOT
#	EST_FDETTRS
#	EST_FPLC
#	EST_FRETTRF
# Output files
#	EST_DLSGTAA
#	EST_DLSGTAR
#	EST_DLSGTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2
NORME=`echo $2 | cut -d"_" -f1`

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


if [ ! -e ${EST_SAS_PROJECTION} ] ; then touch ${EST_SAS_PROJECTION}; fi


NB_FILES=`ls ${DTRANSFER}/${REMOTE_SITE}/from/${NOM_PREFIX}*${NORME}*.dat | wc -l`

# Launch applicative job ESFD1805
NJOB="ESFD1805"
for file in `ls ${DTRANSFER}/${REMOTE_SITE}/from/${NOM_PREFIX}*${NORME}*.dat`
do
  # Launch applicative job ESFD1805
	NJOB="ESFD1805"
	${DCMD}/ESFD1805.cmd ${PARM_ICLODAT_D} ${PARM_BLCSHTYEA_NF} ${IDF_CT} ${file} 2>&1 | ${TEE}
	
done

# Launch applicative job ESFD1804
NJOB="ESFD1804"
${DCMD}/ESFD1804.cmd ${PARM_ICLODAT_D} ${PARM_BLCSHTYEA_NF} ${IDF_CT} 2>&1 | ${TEE}
	

# Launch applicative job ESFD1801
NJOB="ESFD1801"
${DCMD}/ESFD1801.cmd ${PARM_ICLODAT_D} ${PARM_BLCSHTYEA_NF} 2>&1 | ${TEE}

# Launch applcative job ESFD1802
NJOB="ESFD1802"
${DCMD}/ESFD1802.cmd 2>&1 | ${TEE}

CHAINEND

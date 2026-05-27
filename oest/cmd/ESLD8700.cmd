#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Gestion des fichiers FTECLEDA_MVT et _CUR
# nom du script SHELL           : ESLD3860.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[002]  25/07/2025  Mr JYP        :US 5559 spira 113075 : SERQS split files by site
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

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
export EST_SORT_CONDITION_AS=`grep EST_SORT_CONDITION_AS $EST_PARAM | cut -d"'" -f2 `
export EST_SORT_CONDITION_EU=`grep EST_SORT_CONDITION_EU $EST_PARAM | cut -d"'" -f2 `
export EST_SORT_CONDITION_AM=`grep EST_SORT_CONDITION_AM $EST_PARAM | cut -d"'" -f2 `


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

#[001]
# Launch applicative job ESLD8701
NJOB="ESLD8701"
${DCMD}/ESLD8701.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} 2>&1 | ${TEE}


PARALLEL_JOB_INIT 2

# Launch applicative job for TL split by site
NJOB="ESFD3935A${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3935.cmd $ESL_FTECLEDALO  $ESF_FTECLEDA_TOAS $ESF_FTECLEDA_TOEU $ESF_FTECLEDA_TOAM  $ESF_FTECLEDA_FROMAS $ESF_FTECLEDA_FROMEU $ESF_FTECLEDA_FROMAM" 

NJOB="ESFD3936R${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3936.cmd $EST_FTECLEDR  $ESF_FTECLEDR_TOAS $ESF_FTECLEDR_TOEU $ESF_FTECLEDR_TOAM  $ESF_FTECLEDR_FROMAS $ESF_FTECLEDR_FROMEU $ESF_FTECLEDR_FROMAM" 

PARALLEL_JOB_END 

#----------------- Launch applicative job GAAP_CODE on external files
PARALLEL_JOB_INIT 4

if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
        NJOB="ESFD3811_${NORME_CF}_AS"
        PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDA_TOAS}  ${EPO_GAAPCOD_MAPPING_FROMAS}"
		
		NJOB="ESFD3813_${NORME_CF}_AS"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS} ${EPO_GAAPCOD_MAPPING_FROMAS}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
        NJOB="ESFD3811_${NORME_CF}_EU"
        PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDA_TOEU} ${EPO_GAAPCOD_MAPPING_FROMEU}"

		NJOB="ESFD3813_${NORME_CF}_EU"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU} ${EPO_GAAPCOD_MAPPING_FROMEU}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
        NJOB="ESFD3811_${NORME_CF}_AM"
        PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDA_TOAM} ${EPO_GAAPCOD_MAPPING_FROMAM}"

		NJOB="ESFD3813_${NORME_CF}_AM"
		PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM} ${EPO_GAAPCOD_MAPPING_FROMAM}"
fi
PARALLEL_JOB_END


#----------------- Launch applicative job PRD_CODE on external files
PARALLEL_JOB_INIT 4
if [ "$DEFAULT_SQL_LOGIN" != "ubas" ]
then
       NJOB="ESFD3819_${NORME_CF}_AS"
       PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDA_TOAS}  ${ESF_FCTRI17PRD_FROMAS}"
	  
       NJOB="ESFD3818_${NORME_CF}_AS"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS}  ${ESF_FCTRI17PRD_FROMAS}"	
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubeu" ]
then
        NJOB="ESFD3819_${NORME_CF}_EU"
        PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDA_TOEU}  ${ESF_FCTRI17PRD_FROMEU}"

       NJOB="ESFD3818_${NORME_CF}_EU"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}  ${ESF_FCTRI17PRD_FROMEU}"
fi
if [ "$DEFAULT_SQL_LOGIN" != "ubam" ]
then
       NJOB="ESFD3819_${NORME_CF}_AM"
       PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDA_TOAM}  ${ESF_FCTRI17PRD_FROMAM}"

       NJOB="ESFD3818_${NORME_CF}_AM"
       PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}  ${ESF_FCTRI17PRD_FROMAM}"
fi
PARALLEL_JOB_END



CHAINEND

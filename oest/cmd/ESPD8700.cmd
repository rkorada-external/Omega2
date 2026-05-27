#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESPD8700.cmd
# date de creation              : 14/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]  05/05/2011  R. CASSIS :spot:21408 - Modification OneGL
#[002]  29/06/2023  Sir JYP   :spira 110061 : apply override products codes
#[003]  10/02/2025  Mr JYP    :spira 112324 : rounding estimates amounts calculations 
#[004]  03/04/2025  Mr JYP    :spira 112324 : rounding estimates amounts calculations 
#[005]  15/07/2025  Mr JYP    :spira 113075 : SERQS split files by site
#[006]  21/07/2025  Mr JYP    :US 5559 spira 113075 : SERQS split files by site
#-----------------------------------------------------------------------------
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

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}

#[001]
# Launch applicative job ESPD8701
NJOB="ESPD8701"
${DCMD}/ESPD8701.cmd ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} 2>&1 | ${TEE}



#------------------- Launch applicative job for TL split by site

PARALLEL_JOB_INIT 2

# Launch applicative job for TL split by site
NJOB="ESFD3935A${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3935.cmd $EST_FTECLEDA  $ESF_FTECLEDA_TOAS $ESF_FTECLEDA_TOEU $ESF_FTECLEDA_TOAM  $ESF_FTECLEDA_FROMAS $ESF_FTECLEDA_FROMEU $ESF_FTECLEDA_FROMAM "

NJOB="ESFD3936R${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3936.cmd $EST_FTECLEDR  $ESF_FTECLEDR_TOAS $ESF_FTECLEDR_TOEU $ESF_FTECLEDR_TOAM  $ESF_FTECLEDR_FROMAS $ESF_FTECLEDR_FROMEU $ESF_FTECLEDR_FROMAM "

PARALLEL_JOB_END


# Launch applicative job ESFD3933 rounding filter
NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  2>&1 | ${TEE}

# Launch applicative job ESFD3949_I4I_ESF_FTECLEDA
NJOB="ESFD3949_POSI"
${DCMD}/ESFD3949.cmd ${ESF_FTECLEDA_LOCAL} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}

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

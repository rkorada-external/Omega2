#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Fusion des fichiers FTECLEDA_CUR et _MVT dans FTECLEDA
# nom du script SHELL           : ESID8700.cmd
# revision                      : 
# date de creation              : 15/03/2011
# auteur                        : R. Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :spot:21408 - Fusion des fichiers FTECLEDA_CUR et FTECLEDA_MVT dans FTECLEDA final
#
# Launch applicative jobs ESCD9001 ESID8701
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[000]  JJ/MM/AAAA  Prog name     :spot:xxxxx - Comments
#[004]	19/08/2019M.NAJI          :SPIRA 80734 - optimisation changer les fichier binaire par des fichiers textes et parallélisation des jobs
#[005]  30/10/2019  M. NAJI        :spot:81838 - ajout du mode IFRS4 avec un IDF_CT
#[006]  07/07/2021  M.NAJI        :SPIRA 97241 prise en compte du split LIFE/P&C ajout du JOB ESID8703 
#[007]  16/12/2021  Mr JYP        :SPIRA 101025  override I17PRODCOD_CT code before RA
#[008]  10/02/2025  Mr JYP        :SPIRA 112324 : rounding estimates amounts calculations 
#[009]  03/04/2025  Mr JYP        :SPIRA 112324 : rounding estimates amounts calculations 
#[010]  29/07/2025  Mr JYP        :US 5559 spira 113075 : SERQS split files by site
#[011]  19/02/2026  Mr JYP        :US 8620 SERQS POS - no more cash flow on estimates IFRS4
#===========================================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

export IDF_CT="$2"


if [ "${IDF_CT}" != "" ]
then
        # Launch applicative job ESCD9001
         NJOB="ESFD9001"
        . ${DCMD}/ESFD9001.cmd "${IDF_CT}"
fi



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

if [ "${IDF_CT}" = "" ]
then
    # Launch applicative job ESCD9001
    NJOB="ESCD9001"
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
fi

set `GETPRM ${DPRM}/CLOSING_ROUNDING.prm`
export ROUNDING_FILTER_FLG=${1}
export ROUNDING_APPLY_MAX_AMT=${2}
export ROUNDING_EXCLUDE_LIMIT_AMT=${3}

PARALLEL_JOB_INIT 2

# Launch applicative job ESID8702 ACCEPT
NJOB="ESID8702A"
PARALLEL_JOB "${DCMD}/ESID8702.cmd $EST_FTECLEDA_CUR $EST_FTECLEDA_MVT $EST_FTECLEDA_MTH $EST_FTECLEDA_REP $EST_FTECLEDA 118"


# Launch applicative job ESID8702 RETRO
NJOB="ESID8702R"
PARALLEL_JOB "${DCMD}/ESID8702.cmd $EST_FTECLEDR_CUR $EST_FTECLEDR_MVT ${DFILP}/empty.dat ${DFILP}/empty.dat $EST_FTECLEDR 71 "

PARALLEL_JOB_END 

PARALLEL_JOB_INIT 2

# Launch applicative job for TL split by site
NJOB="ESFD3935A${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3935.cmd $EST_FTECLEDA  $ESF_FTECLEDA_TOAS $ESF_FTECLEDA_TOEU $ESF_FTECLEDA_TOAM  $ESF_FTECLEDA_FROMAS $ESF_FTECLEDA_FROMEU $ESF_FTECLEDA_FROMAM" 

NJOB="ESFD3936R${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD3936.cmd $EST_FTECLEDR  $ESF_FTECLEDR_TOAS $ESF_FTECLEDR_TOEU $ESF_FTECLEDR_TOAM  $ESF_FTECLEDR_FROMAS $ESF_FTECLEDR_FROMEU $ESF_FTECLEDR_FROMAM" 


PARALLEL_JOB_END 

#----------------- specific EBS 
if [ "${IDF_CT}" != "" ]
then
	# Add EBS to FTECLEDA
	NJOB="ESID8703"
	${DCMD}/ESID8703.cmd  2>&1 | ${TEE} 
else 
	NJOB="ESID8702B"
	${DCMD}/ESID8702.cmd $EST_FTECLEDA_CUR $EST_FTECLEDA_MVT_ALL_SITE $EST_FTECLEDA_MTH $EST_FTECLEDA_REP $EST_FTECLEDA_MULTISITE 118  2>&1 | ${TEE}
fi

#----------------- rounding MTH file 
NJOB="ESFD3933${TYPEINV}"
${DCMD}/ESFD3933.cmd  2>&1 | ${TEE}


#----------------- override default product LOCAL file 
# Launch applicative job ESFD3949_I4I_ESF_FTECLEDA
NJOB="ESFD3949_I4IA"
${DCMD}/ESFD3949.cmd ${ESF_FTECLEDA_LOCAL} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


# Launch applicative job ESFD3949_I4I_ESF_FTECLEDA
NJOB="ESFD3948_I4IR"
${DCMD}/ESFD3948.cmd ${ESF_FTECLEDR_LOCAL} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


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

#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 : BDA- Impact on Omega closing
# Revision                      : $Revision:   1.0  $
# Date de creation              : 09/04/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
#       [001]           09/04/2020      Linh DOAN      83103                    BDA- Impact on Omega closing
#       [002]           09/10/2020      JYP            90629                    Granularity : add product code file
#       [003]           04/05/2021      Linh DOAN      92814                    Gaap Code IFRS 4 - RR	
#       [004]           16/08/2021      JYP            98350                    98350/94896 Granularity : add product code for retro
#       [005]           17/08/2021      JYP            98350                    98350/94896 Granularity : bugfix parallel jobs
#       [006]           15/12/2021      Mr JYP         101025                   override I17PRODCOD_CT code into TTECLEDA
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
#. ${DUTI}/fctprint.cmd
. ${DUTI}/fctpar.cmd

# Chain Initialization variables
CHAININIT $0 $1

                       
#IDF_CT=$2

#NJOB="ESFD9001"
#. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


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



NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}


ECHO_LOG "#===> EST_GAAPCOD_MAPPING .................: ${EST_GAAPCOD_MAPPING}"
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .................: ${ESF_FCTRI17PRD_NEW}"
ECHO_LOG "#===> EST_FTECLEDA_MVT    .................: ${EST_FTECLEDA_MVT}"
ECHO_LOG "#===> EST_FTECLEDA_MTH    .................: ${EST_FTECLEDA_MTH}"
ECHO_LOG "#===> EST_FTECLEDA_REP    .................: ${EST_FTECLEDA_REP}"
ECHO_LOG "#===> EST_FTECLEDR_MVT    .................: ${EST_FTECLEDR_MVT}"
ECHO_LOG "#===> EST_FTECLEDR_CUR    .................: ${EST_FTECLEDR_CUR}"
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR .................: ${ESF_FI17PRODUCT_OVR}"



PARALLEL_JOB_INIT 5

# Launch applicative job ESID3810_FTECLEDA_MVT
NJOB="ESFD3811_EST_FTECLEDA_MVT"
PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${EST_FTECLEDA_MVT} ${EST_GAAPCOD_MAPPING}"

# Launch applicative job ESID3810_FTECLEDA_MTH
NJOB="ESFD3811_EST_FTECLEDA_MTH"
PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${EST_FTECLEDA_MTH} ${EST_GAAPCOD_MAPPING}"

# Launch applicative job ESID3810_FTECLEDA_CUR
NJOB="ESFD3811_EST_FTECLEDA_REP"
PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${EST_FTECLEDA_REP} ${EST_GAAPCOD_MAPPING}"


# Launch applicative job ESID3810_FTECLEDR_MVT
NJOB="ESFD3813_EST_FTECLEDR_MVT"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EST_FTECLEDR_MVT} ${EST_GAAPCOD_MAPPING}"

NJOB="ESFD3813_EST_FTECLEDR_CUR"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${EST_FTECLEDR_CUR} ${EST_GAAPCOD_MAPPING}"


PARALLEL_JOB_END


PARALLEL_JOB_INIT 5
# Launch applicative job ESFD3819
NJOB="ESFD3819_I4I_EST_FTECLEDA_MVT"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${EST_FTECLEDA_MVT} ${ESF_FCTRI17PRD_NEW}"

NJOB="ESFD3819_I4I_EST_FTECLEDA_MTH"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${EST_FTECLEDA_MTH} ${ESF_FCTRI17PRD_NEW}"

NJOB="ESFD3819_I4I_EST_FTECLEDA_REP"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${EST_FTECLEDA_REP} ${ESF_FCTRI17PRD_NEW}"


# Launch applicative job ESFD3818_FTECLEDR_MVT
NJOB="ESFD3818_I4I_EST_FTECLEDR_MVT"
PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${EST_FTECLEDR_MVT} ${ESF_FCTRI17PRD_NEW}"

NJOB="ESFD3818_I4I_EST_FTECLEDR_CUR"
PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${EST_FTECLEDR_CUR} ${ESF_FCTRI17PRD_NEW}"


PARALLEL_JOB_END



# Launch applicative job ESFD3949_I4I_ESF_FTECLEDA
NJOB="ESFD3949_I4I_ESF_FTECLEDA"
${DCMD}/ESFD3949.cmd ${EST_FTECLEDA_MVT} ${ESF_FCTRI17PRD_NEW} 2>&1 | ${TEE}


CHAINEND

#!/bin/ksh
#=============================================================================
# nom de l'application          : 1.04 
#                                 Feeding Job
# nom du script SHELL           : ESEJ2071.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08/10/2020
# auteur                        : KBagwe
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88477  : Main LOB - Feeding the Field I17 Segment / Portfolio for the group process
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#MOD01 09/04/2021 - BKARRI - 88568 : IFRS17: RETRO - Level of aggregation - Standard Grouping of external Retro : Steps - 20,25,30
#
#===============================================================================
#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

NB_BUCKETS=2
PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_05_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Feeding for NORM - I17G, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPIPFOLIO_I17G_ISQL_${BUCKET}_${CTRTYP}.log
ISQL_QRY="exec BEST..PtEGPIPFOLIO 64, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END


NB_BUCKETS=2
PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_10_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Feeding for NORM - I17P, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPIPFOLIO_I17P_ISQL_${BUCKET}_${CTRTYP}.log
ISQL_QRY="exec BEST..PtEGPIPFOLIO 65, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END

NB_BUCKETS=2
PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_15_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Feeding for NORM - I17L, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPIPFOLIO_I17L_ISQL_${BUCKET}_${CTRTYP}.log
ISQL_QRY="exec BEST..PtEGPIPFOLIO 66, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Retro Feeding for NORM - I17G"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtRETEGPIPF_I17G_ISQL.log
ISQL_QRY="exec BEST..PtRETEGPIPF 75"
ISQL

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Retro Feeding for NORM - I17P"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtRETEGPIPF_I17P_ISQL.log
ISQL_QRY="exec BEST..PtRETEGPIPF 76"
ISQL

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Retro Feeding for NORM - I17L"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtRETEGPIPF_I17L_ISQL.log
ISQL_QRY="exec BEST..PtRETEGPIPF 77"
ISQL

JOBEND 

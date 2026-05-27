#!/bin/ksh
#=============================================================================
# nom de l'application          : 1.04 
#                                 Batch MAIN IFRS17 LOB
# nom du script SHELL           : ESEJ2050.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 02/04/2019
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 71007  : REQ 1.04 - IFRS17: batch to calculate Main LOB and Main EGPI
#
#-----------------------------------------------------------------------------
# historiques des modifications
# 15/09/2020 - KBagwe - 89902 :ESEJ2050 - Issue to correct due to parallel mode - too many process id created.Step 25,30,35
#===============================================================================
#[001]
#===============================================================================
# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

NB_BUCKETS=2

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Switch Server Infomega"
SWITCH_SRV ${SRV_2}


PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

	NSTEP=${NJOB}_10_${BUCKET}
	#------------------------------------------------------------------------------
	LIBEL="Extract Segmenttation Information"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_SEG_RESULT_O_${BUCKET}.dat
	BCP_QRY="exec BSEG..PsSEGCM ${BUCKET}"
	PARALLEL BCP
	let BUCKET=${BUCKET}+1
done
PARALLEL_END


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Switch Server TP"
SWITCH_SRV ${SRV_DEFAULT}

touch ${DFILT}/${NJOB}_10_1_${IB}_SEG_RESULT_O_1.dat
touch ${DFILT}/${NJOB}_10_2_${IB}_SEG_RESULT_O_2.dat 

cat ${DFILT}/${NJOB}_10_1_${IB}_SEG_RESULT_O_1.dat ${DFILT}/${NJOB}_10_2_${IB}_SEG_RESULT_O_2.dat > ${DFILT}/${NJOB}_10_${IB}_SEG_RESULT_O_FINAL.dat

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="BCP In BTRAV Table For Seg Result"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_I="${DFILT}/${NJOB}_10_${IB}_SEG_RESULT_O_FINAL.dat"
BCP_TABLE="BTRAV..ESEJ2050_TSEGRUNRES"
BCP

PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_25_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17G, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPICALCI17G_I17G_ISQL_${BUCKET}_${CTRTYP}.log
ISQL_QRY="exec BEST..PtEGPICALCI17G  'I17G', 64, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END


PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_30_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17P, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPICALCI17P_L_I17P_ISQL_${BUCKET}_${BUCKET}.log
ISQL_QRY="exec BEST..PtEGPICALCI17P_L  'I17P', 65, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END


PARALLEL_INIT ${NB_BUCKETS}
typeset -i BUCKET=1
while [ ${BUCKET} -le ${NB_BUCKETS} ]; do

if [ ${BUCKET} -eq 1 ] 
then
CTRTYP=T
else
CTRTYP=F
fi

NSTEP=${NJOB}_35_${NB_BUCKETS}_${CTRTYP}
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17L, BUCKET=${BUCKET} and CTRTYP=${CTRTYP}"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PtEGPICALCI17P_L_I17L_ISQL_${BUCKET}_${CTRTYP}.log
ISQL_QRY="exec BEST..PtEGPICALCI17P_L  'I17L', 66, '${CTRTYP}'"
PARALLEL ISQL

let BUCKET=${BUCKET}+1
done
PARALLEL_END

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Remove Temperory Files"
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 

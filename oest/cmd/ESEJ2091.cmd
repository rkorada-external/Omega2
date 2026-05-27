#!/bin/ksh
#=============================================================================
# nom de l'application          : Portfolio/Sub-Portfolio per norm to be stored on Life IFRS17 Retro subview.
# nom du script SHELL           : ESEJ2091.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/04/2021
# auteur                        : Bhimasen Karri
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88568  : IFRS17: RETRO - Level of aggregation - Standard Grouping of external Retro
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]
#===============================================================================
# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Switch Server Infomega"
SWITCH_SRV ${SRV_2}


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Extract Segmenttation Information"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SEG_RET_RESULT_O.dat
BCP_QRY="exec BSEG..PsPortfolioExtractRet"
BCP


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Switch Server TP"
SWITCH_SRV ${SRV_DEFAULT}


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="BCP In BTRAV Table For Seg Result"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_I="${DFILT}/${NJOB}_10_${IB}_SEG_RET_RESULT_O.dat"
BCP_TABLE="BTRAV..ESEJ2090_TRESULT"
BCP



NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Process Retro Portfolio/Sub-Portfolio Calculation for NORM - I17G(75)"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuRetPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuRetPortfolioCalc 75"
ISQL
 


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Process Retro Portfolio/Sub-Portfolio Calculation for NORM - I17P(76)"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuRetPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuRetPortfolioCalc 76"
ISQL



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Process Retro Portfolio/Sub-Portfolio Calculation for NORM - I17L(77)"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuRetPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuRetPortfolioCalc 77"
ISQL


NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Remove Temperory Files"
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 





















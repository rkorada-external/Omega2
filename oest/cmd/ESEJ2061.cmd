#!/bin/ksh
#=============================================================================
# nom de l'application          : Portfolio/Sub-Portfolio Fetching
# nom du script SHELL           : ESEJ2061.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 09/10/2020
# auteur                        : KBagwe
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88477  : Portfolio/Sub-Portfolio Fetching
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
BCP_O=${DFILT}/${NSTEP}_${IB}_SEG_RESULT_O.dat
BCP_QRY="exec BSEG..PsPortfolioExtract 1"
BCP


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Switch Server TP"
SWITCH_SRV ${SRV_DEFAULT}

touch ${DFILT}/${NJOB}_10_${IB}_SEG_RESULT_O.dat


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="BCP In BTRAV Table For Seg Result"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_I="${DFILT}/${NJOB}_10_${IB}_SEG_RESULT_O.dat"
BCP_TABLE="BTRAV..ESEJ2060_TRESULT"
BCP



NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17G"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuPortfolioCalc 64"
ISQL
 


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17P"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuPortfolioCalc 65"
ISQL



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Process EGPI Calculation for NORM - I17L"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuPortfolioCalc_I17G_ISQL.log
ISQL_QRY="exec BEST..PuPortfolioCalc 66"
ISQL


NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Remove Temperory Files"
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 





















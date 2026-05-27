#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES 
#                                 Update retrocession database
# nom du script SHELL		: ESID8501.cmd
# revision			: $Revision:   1.1  $
# date de creation		: 08/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Updating of the retrocession database 
#   (TCESSION, TACCTRAA and TOUTTRAA tables)
#
# job launched by ESID8500.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] 11/09/2018 MZM     :spira:70805 4Q2018 technical booking error on INT  - Ajout de la date en parametre dans le STEP 05 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CLODAT_D=$1
BALSHTMTH_NF=$2
SSDACC_LL=$3
SEGTYP_CT=$4
BALSHTYEA_NF=$5
SPECEND_D=$6
#[01]
CRE_D=$7

NSTEP=${NJOB}_05
#Loading subsidiaries list into BTRAV..TESTSSDTMP
#-----------------------------------------------------------------------------
LIBEL="Loading subsidiaries list into BTRAV..TESTSSDTMP"
#[01]ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDACC_LL}', '${SEGTYP_CT}'"
ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDACC_LL}', '${SEGTYP_CT}',  '${CRE_D}'"
ISQL_BASE="BEST"
ISQL        

NSTEP=${NJOB}_10
# BRET..TCESSION table update
#-----------------------------------------------------------------------------
LIBEL="TCESSION table update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuCESSION_01 '${CLODAT_D}'"
ISQL

NSTEP=${NJOB}_15
# BRET..TACCTRAA table update
#-----------------------------------------------------------------------------
LIBEL="TACCTRAA table update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuACCTRAA_01 ${BALSHTYEA_NF} " 
ISQL

NSTEP=${NJOB}_20
# BRET..TOUTTRAA table update
#-----------------------------------------------------------------------------
LIBEL="TOUTTRAA table update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuOUTTRAA_01 '${SPECEND_D}'"
ISQL


JOBEND

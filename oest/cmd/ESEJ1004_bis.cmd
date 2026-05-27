#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Mise a jour des bases
# nom du script SHELL		: ESEJ1004_bis.cmd
# revision			: $Revision:   1.10  $
# date de creation		: 23/06/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: ESTIR32F.doc
#-----------------------------------------------------------------------------
# description
#   Bases update (set 32)
#
# job launched by ESEJ9999.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#  09/08/2001: OG Ajout step 8
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get entry parameters
UPDULTTYP_CT=$1
CRE_D=$2
CLODAT_D=$3

# Job Initialisation
JOBINIT

#NSTEP=${NJOB}_05
## Transfer of agenda file ESTRMD.dat into TESTRMD table
##------------------------------------------------------------------------------
#LIBEL="Transfer of agenda file ESTRMD.dat into TESTRMD table"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NCHAIN}_ESEJ1003_10_${IB}_ESTC3206_ESTRMD_O4.dat
#BCP_TABLE="BTRAV..TESTRMD"
#BCP

#NSTEP=${NJOB}_06
## Key table truncate (safety)
##------------------------------------------------------------------------------
#LIBEL="TBESTGTAKEY table truncate for safety"
#ISQL_BASE="BTRAV"
#ISQL_QRY="truncate table BTRAV..TBESTGTAKEY"
#ISQL
#
#NSTEP=${NJOB}_07
## Filling TBESTGTAKEY table
##------------------------------------------------------------------------------
#LIBEL="Filling TBESTGTAKEY table"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NCHAIN}_ESEJ1002_07_${IB}_SORT_ESTCTRGTA_O.dat
#BCP_TABLE="BTRAV..TBESTGTAKEY"
#BCP
#
#NSTEP=${NJOB}_08
## Contracts list deposit
##------------------------------------------------------------------------------
#LIBEL="Addition of Complete Accounts with BALSHEYA > CLODAT_D"
#ISQL_BASE="BEST"
#ISQL_QRY="exec BEST..PiESTGTAKEY_01 '${CLODAT_D}'"
#ISQL
#
#
#NSTEP=${NJOB}_09
## Deletion of temporary files
##------------------------------------------------------------------------------
#LIBEL="Deletion of temporary files"
#RMFIL "${DFILT}/${NCHAIN}_ESEJ1002_07_${IB}_SORT_ESTCTRGTA_O.dat"
#
#NSTEP=${NJOB}_10
## Transfer of underwriting file ESTUW.dat into TESTUW table
##------------------------------------------------------------------------------
#LIBEL="Transfer of underwriting file ESTUW.dat into TESTUW table"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NCHAIN}_ESEJ1003_10_${IB}_ESTC3206_ESTUW_O3.dat
#BCP_TABLE="BTRAV..TESTUW"
#BCP
#
#
#NSTEP=${NJOB}_15
## Transfer of premiums and ultimates claims ESTCTRULT.dat into TESTCTRULT table
##------------------------------------------------------------------------------
#LIBEL="Transfer of premiums and ultimates claims ESTCTRULT.dat into TESTCTRULT table"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NCHAIN}_ESEJ1003_10_${IB}_ESTC3206_ESTCTRULT_O1.dat
#BCP_TABLE="BTRAV..TESTCTRULT"
#BCP



NSTEP=${NJOB}_20
# Transfer of ultimates stats amounts file ESTCPLAMT.dat into TESTCPLAMT table
#------------------------------------------------------------------------------
LIBEL="Transfer of ultimates stats amounts file ESTCPLAMT.dat into TESTCPLAMT table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_ESEJ1003_bis_10_${IB}_ESTC3206_ESTCPLAMT_O2.dat
BCP_TABLE="BTRAV..TESTCPLAMT"
BCP


#NSTEP=${NJOB}_24
## OMEGA base update
##------------------------------------------------------------------------------
#LIBEL="OMEGA base clean up"
#ISQL_BASE="BEST"
#ISQL_QRY="exec BEST..PdAGENDA_01 '${CRE_D}'"
#ISQL

NSTEP=${NJOB}_25
# OMEGA base update
#------------------------------------------------------------------------------
LIBEL="OMEGA base update"
ISQL_BASE="BEST"
ISQL_TRIGGERS_OFF="YES"
ISQL_QRY="exec BEST..PuUNDSTA_01_bis '${UPDULTTYP_CT}'"
ISQL

NSTEP=${NJOB}_30
# Deletion of temporary files
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"


JOBEND

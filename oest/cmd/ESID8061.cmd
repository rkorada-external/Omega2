#!/bin/ksh
#=============================================================================
# nom de l'application : ESTIMATIONS - INVENTAIRE
#                        MAJ de la segmentation
# nom du script SHELL  : ESID8061.cmd
# revision             : $Revision:   1.1  $ 
# date de creation     : 08/1997
# auteur               : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Update of the segmentation (table TVERSION base BEST)
#
# job launched by ESID8060.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications:
# [02] 26/11/2012 PPEZOUT :spot:24041 Solvency, ajouts steps
# [03] 19/02/2018 MZM     :spira:64014 EBS - Actuarial Version Booking - Ajout de la date en parametre dans le STEP 05 
# [04] 31/05/2021 C.SOCIE :spira:91951 EST - ULR copy add new sp PuULR_01
# [05] 12/10/2021 A.RUFFAULT :spira:99072 EST - IFRS17/EBS- Isolate pattern renewal procees in dedicated batch chain
# [06] 28/02/2023 F.CULIOLI :spira:91951 EST - ULR copy add new param BATCHUSER to sp PuULR_01
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CRE_D=$1
CLODAT_D=$2
SSDACC_LL=$3
SEGTYP_CT=$4
BATCHUSER=$5


NSTEP=${NJOB}_05
#Loading subsidiaries list into BTRAV..TESTSSDTMP
#-----------------------------------------------------------------------------
LIBEL="Loading subsidiaries list into BTRAV..TESTSSDTMP"
#[03]  ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDACC_LL}', '${SEGTYP_CT}'"
ISQL_QRY="EXECUTE PsREQJOB_05 '${SSDACC_LL}', '${SEGTYP_CT}', '${CRE_D}'"
ISQL_BASE="BEST"
ISQL
#[03] Fin Modif

NSTEP=${NJOB}_10
# BEST..TVERSION table update
#-----------------------------------------------------------------------------
LIBEL="table TVERSION update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuVERSION_04 '${CLODAT_D}', '${CRE_D}'"
ISQL

# COMPTABILISATION 31/12
if [ ${EST_ESID8060_COND1} = "Y" ]
then
  NSTEP=${NJOB}_15
  # BEST..TCTRULT and TUNDSTA BEST..table delete
  #-----------------------------------------------------------------------------
  LIBEL="BEST..TCTRULT and TUNDSTA BEST..table delete"
  ISQL_BASE="BEST"
  ISQL_QRY="exec PdCTRULT_01"
  ISQL

  NSTEP=${NJOB}_20
  # BEST..TCTRULT table delete
  #-----------------------------------------------------------------------------
  LIBEL="BEST..TCTRULT table delete"
  ISQL_BASE="BEST"
  ISQL_QRY="exec PdCTRULT_02"
  ISQL
fi

#[02] ajout steps
NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="table TCURSII TLOBSII TRATINGSII CLOSING_D update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuSOLVENCY_01 '${CLODAT_D}', '${CRE_D}'"
ISQL

##[05]
##NSTEP=${NJOB}_36
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${CLODAT_D}', '${CRE_D}', 'INV'"
##ISQL
##
NSTEP=${NJOB}_37
#-----------------------------------------------------------------------------
LIBEL="table BEST..TSEGEST update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuULR_01 '${CRE_D}', 'INV', '${BATCHUSER}'"
ISQL

#----------------------------------------------------------------------------
# Connect on the infocenter server
#----------------------------------------------------------------------------
NSTEP=${NJOB}_40
LIBEL="Connect on the infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="table TCURSII TLOBSII TRATINGSII CLOSING_D update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuSOLVENCY_01 '${CLODAT_D}', '${CRE_D}'"
ISQL

##[05]
##NSTEP=${NJOB}_46
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${CLODAT_D}', '${CRE_D}', 'INV'"
##ISQL
##
NSTEP=${NJOB}_47
#-----------------------------------------------------------------------------
LIBEL="table BEST..TSEGEST update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuULR_01 '${CRE_D}', 'INV', '${BATCHUSER}'"
ISQL

JOBEND

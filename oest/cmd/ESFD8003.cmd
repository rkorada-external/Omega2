#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESF8003.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 07\11\2019
# auteur                        : Cyril AVINENS
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ 12.3, REQ 12.7 and REQ12.11 : TSEGPROF table update
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP...........................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"
ECHO_LOG "#===> BATCHUSER........................................................: ${PARM_BATCHUSER}"

ECHO_LOG "#===> ESF_FSEGPROF_INI...............................: ${ESF_FSEGPROF_INI}"
ECHO_LOG "#===> ESF_FSEGPROF_STD...............................: ${ESF_FSEGPROF_STD}"
ECHO_LOG "#===> ESF_FSEGPROF_SEG_STD...........................: ${ESF_FSEGPROF_SEG_STD}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSEGPROF"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSEGPROF"
ISQL

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Load INI file into the working table BTRAV..ESFD8000_TSEGPROF"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSEGPROF_INI}"
BCP_TABLE="BTRAV..ESFD8000_TSEGPROF"
BCP

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Update table BEST..TSEGPROF with data from INI file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSEGPROF_01 '${PARM_ICLODAT_D}','INI','${PARM_BATCHUSER}','${NORME_CF}'"
ISQL

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSEGPROF"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSEGPROF"
ISQL

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Load STD file into the working table BTRAV..ESFD8000_TSEGPROF"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSEGPROF_STD}"
BCP_TABLE="BTRAV..ESFD8000_TSEGPROF"
BCP

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Update table BEST..TSEGPROF with data from STD file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSEGPROF_01 '${PARM_ICLODAT_D}','${TYPEINV}','${PARM_BATCHUSER}','${NORME_CF}'"
ISQL


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------
LIBEL="Delete data from Working Table BTRAV..ESFD8000_TSEGPROF"
ISQL_BASE="BTRAV"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="Delete BTRAV..ESFD8000_TSEGPROF"
ISQL

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Load SEG STD file into the working table BTRAV..ESFD8000_TSEGPROF"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${ESF_FSEGPROF_SEG_STD}"
BCP_TABLE="BTRAV..ESFD8000_TSEGPROF"
BCP

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Update table BEST..TSEGPROF with data from SEG STD file"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec PuSEGPROF_02"
ISQL

JOBEND

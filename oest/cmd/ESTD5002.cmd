#!/bin/ksh
#==============================================================================
#nom de l'application: RETRO 
#nom du source: ESTD5002.cmd 
#revision: $Revision:   1.1  $
#date de creation: 07/2001
#auteur:  O.GIRAUX
#description:  Suppression Mutre et CMR dans BEST ( 22' sur MAIP07)
#
#    Dans l'ordre:
#       - BRET
#       - BEST
#       - BCTA
#       - BTRT
#
#------------------------------------------------------------------------------

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# JOB initialization
JOBINIT


NSTEP=${NJOB}_05
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TACCTRNE"
ISQL_BASE="BEST"
ISQL_QRY="delete TACCTRNE where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_10
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TACCTRTGT"
ISQL_BASE="BEST"
ISQL_QRY="delete TACCTRTGT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_15
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TANASEG"
ISQL_BASE="BEST"
ISQL_QRY="delete TANASEG where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_20
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TAUTPAR"
ISQL_BASE="BEST"
ISQL_QRY="delete TAUTPAR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_25
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TCTRACC"
ISQL_BASE="BEST"
ISQL_QRY="delete TCTRACC where ctr_nf like '08%' or ctr_nf like '09%'" 
ISQL

NSTEP=${NJOB}_30
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TCTRFIC"
ISQL_BASE="BEST"
ISQL_QRY="delete TCTRFIC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_35
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TCTRULT"
ISQL_BASE="BEST"
ISQL_QRY="delete TCTRULT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_40
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TLIFDRI"
ISQL_BASE="BEST"
ISQL_QRY="delete TLIFDRI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_45
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY="delete TLIFEST where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_50
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TREQJOB"
ISQL_BASE="BEST"
ISQL_QRY="delete TREQJOB where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_60
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TRTOSTAE"
ISQL_BASE="BEST"
ISQL_QRY="delete TRTOSTAE where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_65
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TSEGPAR"
ISQL_BASE="BEST"
ISQL_QRY="delete TSEGPAR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_70
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BEST..TCESSION"
ISQL_BASE="BEST"
ISQL_QRY="delete TUNDSTA where ctr_nf like '08%' or ctr_nf like '09%'"
ISQL

JOBEND

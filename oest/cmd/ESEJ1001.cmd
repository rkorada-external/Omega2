#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Constitution des mouvements comptables
# nom du script SHELL		: ESEJ1001.cmd
# revision			: $Revision: 1.2 $
# date de creation		: 19/06/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: ESTIR32F.doc
#-----------------------------------------------------------------------------
# description
#   accounting transaction creation (set 32)
#
# Job launched by ESEJ1000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [002]
#Auteur         : D.GATIBELZA
#Date           : 26/11/2009
#Version        : 9.1
#Description    : ESTDOM15043 Ultimes  Revisions des regles de gestion et corrections de l'écran estimation des ultimes
#                 - Mise aux normes de la table BTRAV TESTCTRULT devient : BTRAV..EST_ULT_ESEJ1000_TCTRULT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialisation
JOBINIT

# Get Input parameter
UPDULTTYP_CT=$1
CLODAT0_D=$2


#[001]
NSTEP=${NJOB}_04
# Begin isql
#-----------------------------------------------------------------
LIBEL="Drop, create table BTRAV..EST_ULT_ESEJ1000_TCTRULT.tab"
ISQL_BASE="BTRAV"
ISQL_QRY=${DDDL}/BTRAV_EST_ULT_ESEJ1000_TCTRULT.tab
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL


NSTEP=${NJOB}_05
# Contracts list deposit 
#------------------------------------------------------------------------------
LIBEL="Contracts list deposit" 
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PtESTCTRLIS_01 '${UPDULTTYP_CT}', '${CLODAT0_D}'"
ISQL

NSTEP=${NJOB}_10
# Transferring draft table TESTCTRLIS into file 
#------------------------------------------------------------------------------
LIBEL="Transferring draft table TESTCTRLIS into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ESTCTRLIS_O.dat
BCP_QRY="exec BEST..PsESTCTRLIS_01"
BCP               

NSTEP=${NJOB}_15
# Transferring draft table TESTRECPAR into file 
#------------------------------------------------------------------------------
LIBEL="Transferring draft table TESTRECPAR into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ESTRECPAR_O.dat
BCP_QRY="exec BEST..PsESTRECPAR_01"
BCP  

NSTEP=${NJOB}_20
# Selection of last conversion rates for subsidiaries 
#------------------------------------------------------------------------------
LIBEL="Selection of last conversion rates for subsidiaries"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ESTEXCCUR_O.dat
BCP_QRY="exec BEST..PiEXCCUR_01"
BCP               
  
NSTEP=${NJOB}_25
# Selection of last ultimate status in premiums and claims
#------------------------------------------------------------------------------
LIBEL="Selection of last ultimate status in premiums and claims"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ESTCTRULT_O.dat
BCP_QRY="exec BEST..PiCTRULT_01"
BCP

NSTEP=${NJOB}_30
# Accumulation transaction codes consultation
#------------------------------------------------------------------------------
LIBEL="Accumulation transaction codes consultation"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ESTTRSLNK_O.dat
BCP_QRY="exec BEST..PiTRSLNK_01"
BCP

NSTEP=${NJOB}_35
# Deletion of draft temporary tables rows
#------------------------------------------------------------------------------
LIBEL="Deletion of draft temporary tables rows" 
ISQL_BASE='BEST'
ISQL_QRY="exec BEST..PdWASH_01"
ISQL

NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of contracts list deposit file" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_BCP_ESTCTRLIS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTCTRLIS_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, UWY_NF 2:1 - 2:, UW_NT 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_45
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of reconstitution parameter file" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_BCP_ESTRECPAR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTRECPAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, UWY_NF 2:1 - 2:, UW_NT 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_50
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of last conversion rates for subsidiaries file" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_BCP_ESTEXCCUR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ESTEXCCUR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, CUR_CF 2:1 - 2:, EXC_Y 3:1 - 3:
/KEYS SSD_CF, CUR_CF, EXC_Y
exit
EOF
SORT

NSTEP=${NJOB}_55
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of of last ultimate status in premiums and claims file" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_BCP_ESTCTRULT_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTCTRULT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, UWY_NF 2:1 - 2:, UW_NT 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT


JOBEND

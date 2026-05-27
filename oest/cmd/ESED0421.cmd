#!/bin/ksh
#==============================================================================
#Application name              : ESTIMATION - LOADING TEXT FILES FROM IBNR TOOL
#			                      TO BSAR
#Source name                   : ESED0421.cmd
#revision                      : $Revision:   1.11  $
#Date of creation              : 22/08/2004
#author                        : M. DJELLOULI
#references 		       :
#
#------------------------------------------------------------------------------
#description : Loading of text files received from the client in worktables
#	       from BSAR first and insert in the production tables after.
#------------------------------------------------------------------------------
#Variables used :
#FILE_HEADER       Name of the files header
#CTRGRO_TYPE       Type of the CTRGRO files (type A)
#SEGEST_TYPE       Type of the SEGEST files (type B)
#LABOCY_TYPE       Type of the LABOCY files (type C)
#WORK_BASE         Name of the estimation database
#PROD_BASE	   Name of the production database
#CTRGRO_TABLE 	   Name of the CTRGRO table (type A)
#SEGEST_TABLE 	   Name of the SEGEST table (type B)
#LABOCY_TABLE 	   Name of the LABOCY table (type C)
#SCHEDULE_TABLE    Name of the scedule table
#DATE              Date with the format CCYY/MM/DD
#STOP_JOB          Boolean which indicate if there's duplicate key in one file
#
#-----------------------------------------------------------------------------
#parameters :
#$2 SSD_CF         SUBSIDARY NUMBER
#$3 SEGTYP_CT      SEGMENT TYPE
#$4 USR_CF         USER NAME
#$5 USR_LAG        USER LANGUAGE
#
#-----------------------------------------------------------------------------
#historique des modifications :
#[01] 09/05/2012 Florent :spot:23390 Solvency II, gestion du type de segment S
#[02] 02/04/2014 Florent :spot:25427 Maj 1B, ordre des paramètres
#=============================================================================
#set -x

# Call generic functions

. ${DUTI}/fctgen.cmd
NJOB="ESED0421"

# Loading the daemon's parameters
USR_CF=${1}
CRE_D=${2}
SSD_CF=${3}
SEGTYP_CT=${4}
USR_CF=${5}
USR_LAG=${6}
VRS_NF=${7}
OPTION=${8}
VRS_NF2=${9}

#TP = st if you want want to have extended log trace
#export TP=st

# Declaration of global variable
FILE_HEADER="ES"
CTRGRO_TYPE="A"
SEGEST_TYPE="B"
LABOCY_TYPE="C"
WORK_BASE="BSAR"
PROD_BASE="BEST"
CTRGRO_TABLE="TCTRGRO"
SEGEST_TABLE="TSEGEST"
LABOCY_TABLE="TLABOCY"
SCHEDULE_TABLE="TESTSCH"
DATE=`date '+%Y/%m/%d'`
STOP_JOB=0
LOGTYP_CT="E"
if [ "$USER_LAG" != "F" ]
then
	DUPKEY_MSG="duplicate key(s) on"
	NBENR_MSG="Wrong data number"
	FORMAT_MSG="Wrong format"
	ROW_MSG="Row"
	COL_MSG="column"
else
	DUPKEY_MSG=" doublon(s) sur "
	NBENR_MSG="Nombre d'enregistrement(s) incorrect(s)"
	FORMAT_MSG="Format incorrect"
	ROW_MSG="Ligne"
	COL_MSG="colonne"
fi
if [ "$SEGTYP_CT" = "A" ] #[001]
then
	SEGTYP_IN=" in('A','S')"
else
	SEGTYP_IN="='"$SEGTYP_CT"'"
fi


# Initialisation of the JOB
JOBINIT

NSTEP=${NJOB}_10
#--------------------------------
# Bcp : selecting into  BEST..TSEGEST
#--------------------------------
LIBEL="Transferring table BEST..TSEGEST into file "
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BEST..PsSEGEST_02 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}'"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TSEGEST_O.dat
BCP

#----------------------------------------------------------------------------
# Connect on the infocenter server
#----------------------------------------------------------------------------
NSTEP=${NJOB}_15
LIBEL="Connect on the infocenter server"
SWITCH_SRV ${SRV_2}


#----------------------------------------------------------------------------
# Executing ISQL procedure to delete data in the table TSEGEST
#----------------------------------------------------------------------------
NSTEP=${NJOB}_20
LIBEL="Executing ISQL procedure to delete data from the table TSEGEST"
ISQL_BASE=${WORK_BASE}
ISQL_QRY="delete BSAR..TSEGEST where SSD_CF = ${SSD_CF} and SEGTYP_CT${SEGTYP_IN}" #[001]
ISQL

#----------------------------------------------------------------------------
# Executing ISQL procedure to delete data in the table TBOSEGMT
#----------------------------------------------------------------------------
NSTEP=${NJOB}_30
LIBEL="Executing ISQL procedure to delete data from the table TBOSEGMT"
ISQL_BASE=${WORK_BASE}
ISQL_QRY="delete BSAR..TBOSEGMT where SSD_CF = ${SSD_CF} and SEGTYP_CT = '${SEGTYP_CT}'"
ISQL

#----------------------------------------------------------------------------
# Execution of the BCP IN TSEGEST
#----------------------------------------------------------------------------
NSTEP=${NJOB}_40
LIBEL="Beginning of a BCP IN TSEGEST"
BCP_WAY=IN
BCP_VER=""
BCP_SPECIAL_OPT=""
BCP_I=${DFILT}/${NJOB}_10_${IB}_BCP_TSEGEST_O.dat
BCP_TABLE="${WORK_BASE}..${SEGEST_TABLE}"
BCP


#-------------------------------------------------------------------------------------------------
# Executing ISQL procedure to create and loadind contracts which are not include in the portfolio
#-------------------------------------------------------------------------------------------------
NSTEP=${NJOB}_50
LIBEL="Executing ISQL procedure to create a false segment with unaffected contracts"
ISQL_BASE="BSTA"
ISQL_QRY="execute PiSEGBA_03 ${SSD_CF},'${SEGTYP_CT}' "
ISQL

#-------------------------------------------------------------------------------------------------
# Executing ISQL procedure to create to add the number fo the subsidiary in name of the segment
#-------------------------------------------------------------------------------------------------
NSTEP=${NJOB}_60
LIBEL="Executing ISQL procedure to create to add SSD_CF to the name of the segment"
ISQL_BASE="BSTA"
ISQL_QRY="execute PuESTSEG_03 ${SSD_CF},'${SEGTYP_CT}' "
ISQL


NJOB="ESED0111"
. ${DCMD}/ESED0111.cmd ${USR_CF} ${SSD_CF} ${VRS_NF2} ${SEGTYP_CT} ${OPTION} ${CRE_D}


# End of the Job
JOBEND

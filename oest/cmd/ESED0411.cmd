#!/bin/ksh
#==============================================================================
#Application name              : ESTIMATION - LOADING TEXT FILES FROM IBNR TOOL 
#			                      TO BSAR
#Source name                   : ESED0411.cmd
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
#[01] 02/04/2014 Florent :spot:25427 Maj 1B, ordre des paramètres
#=============================================================================
#set -x

# Call generic functions 

. ${DUTI}/fctgen.cmd
NJOB="ESED0411"

# Loading the daemon's parameters
USR_CF=${1}
CRE_D=${2}
SSD_CF=${3}
SEGTYP_CT=${4}
USR_CF=${5}
USR_LAG=${6}
SEGTYPE_CF=${7}
VRS_NF=${8}
TYPDELT=${9}

export ERRANO=0
export LAUNCHER="DAEMON"

# Initialisation of the JOB
JOBINIT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Extraction du login selon la filiale"
ISQL_BASE="BREF"
ISQL_QRY="select lower(BATCHUSER_CF) from BREF..TBATCHSSD where SSD_CF=${SSD_CF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#Affectation des variables login et fichiers
EST_LOGIN=`cat ${ISQL_FRES}|cut -c2-5`
EST_SADPERICAS0=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESEJ0000_SADPERICAS0_*.dat|tail -1`
EST_FINFOSEGPOR=`ls -rt ${DSCORDATA}/${EST_LOGIN}/perm/*_ESIX7000_FINFOSEGPOR.dat|tail -1`

ECHO_LOG "----------------------------------------"
ECHO_LOG "---------  Variables affectees ---------"
ECHO_LOG "----------------------------------------"
ECHO_LOG "==> EST_LOGIN...........: ${EST_LOGIN}"
ECHO_LOG "==> EST_SADPERICAS0.....: ${EST_SADPERICAS0}"
ECHO_LOG "==> EST_FINFOSEGPOR.....: ${EST_FINFOSEGPOR}"
ECHO_LOG "---------------------------------------"

##TP = st if you want want to have extended log trace
##export TP=st

# Declaration of global variable
FILE_HEADER="ES"
CTRGRO_TYPE="A"
SEGEST_TYPE="B"
LABOCY_TYPE="C"
WORK_BASE="BSAR"
PROD_BASE="BEST"
CTRGRO_TABLE="TCTRGRO"
SCHEDULE_TABLE="TCTRANO"
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

# Begin program ESTD0401

#----------------------------------------------------------------------------
# Connect on the infocenter server
#----------------------------------------------------------------------------
NSTEP=${NJOB}_10
LIBEL="Connect on the infocenter server"
SWITCH_SRV ${SRV_2}


if [ "$SSD_CF" = "10" ]
then
NSTEP=${NJOB}_20
# Bcp out
#--------------------------------
LIBEL="Transferring table BSAR..TCTRGRO into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="SELECT DISTINCT CTR_NF, 0 as END_NT, SEC_NF, SSD_CF, 'A' as SEGTYP_CT, Convert(char(10), SEG_CODE) as SEG_CODE from BMIS..ACT_SEGMENT_XREF_TABLE where SSD_CF = ${SSD_CF} and SEGTYPE_CF in ( ${SEGTYPE_CF} ) order by CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_CODE"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BSAR_TCTRGRO_O.dat
BCP
fi

if [ "$SSD_CF" != "10" ]
then
NSTEP=${NJOB}_20
# Bcp out
#--------------------------------
LIBEL="Transferring table BSAR..TCTRGRO into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="SELECT DISTINCT CTR_NF, 0 as END_NT, SEC_NF, SSD_CF, 'A' as SEGTYP_CT, Convert(char(8), SEG_CODE) as SEG_CODE from BMIS..ACT_SEGMENT_XREF_TABLE where SSD_CF = ${SSD_CF} and SEGTYPE_CF in ( ${SEGTYPE_CF} ) order by CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_CODE"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BSAR_TCTRGRO_O.dat
BCP
fi


#NSTEP=${NJOB}_20
## Bcp out
##--------------------------------
#LIBEL="Transferring table BSAR..TCTRGRO into file"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_QRY="SELECT DISTINCT CTR_NF, 0 as END_NT, SEC_NF, SSD_CF, 'A' as SEGTYP_CT, Convert(char(8), SEG_CODE) as SEG_CODE from BMIS..ACT_SEGMENT_XREF_TABLE where SSD_CF = ${SSD_CF} and SEGTYPE_CF in ( ${SEGTYPE_CF} ) order by CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_CODE"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BSAR_TCTRGRO_O.dat
#BCP

#----------------------------------------------------------------------------
# CREATION OF THE FILE OF DUPLICATE KEYS FOR TCTRGRO
#----------------------------------------------------------------------------
NSTEP=${NJOB}_30
LIBEL="Get Table anomaly" 
PRG=ESTF0004
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_BCP_BSAR_TCTRGRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_O2.dat
FPRM=`CFTMP`

#----------------------------------------------------------------------------
# Création du fichier paramètre
#----------------------------------------------------------------------------
INPUT_TEXT ${FPRM} << EOF
USR_CF ${USR_CF}
CTRGRO_TYPE ${CTRGRO_TYPE}
DATE ${DATE}
LOGTYP_CT ${LOGTYP_CT}
FORMAT_MSG ${FORMAT_MSG}
DUPKEY_MSG ${DUPKEY_MSG}
ROW_MSG ${ROW_MSG}
COL_MSG ${COL_MSG}
NBENR_MSG ${NBENR_MSG}
VRS_NF ${VRS_NF}
SEGTYP_CT ${SEGTYP_CT}
exit
EOF

#----------------------------------------
# Execution du programme
#----------------------------------------
export ${PRG}_PRM=${FPRM}
EXECPRG

#----------------------------------------------------------------------------
# Enregistrement des Anomalies dans BEST..TCTRANO 
#----------------------------------------------------------------------------
if test -s ${DFILT}/${NJOB}_30_${IB}_ESTF0004_O1.dat
then
    #----------------------------------------------------------------------------
    # Connect on the infocenter server
    #----------------------------------------------------------------------------
    NSTEP=${NJOB}_40
    LIBEL="Switch to the production server"
    SWITCH_SRV ${SRV_DEFAULT}

    NSTEP=${NJOB}_50
    LIBEL="Beginning of a BCP IN TCTRANO"	
    STOP_JOB=1
    BCP_WAY=IN
    BCP_VER=""
    BCP_SPECIAL_OPT="" 
    BCP_I=${DFILT}/${NJOB}_30_${IB}_ESTF0004_O2.dat
    BCP_TABLE="${PROD_BASE}..${SCHEDULE_TABLE}"
    BCP
fi


#----------------------------------------------------------------------------
# If there's one file with duplicate keys then exit
#----------------------------------------------------------------------------
NSTEP=${NJOB}_60
LIBEL="Exit of the job if there is duplicate keys in one one file"
if [ "$STOP_JOB" = "1" ]
then
    RMFIL ${DFILT}/${NJOB}_20_${IB}_BCP_BSAR_TCTRGRO_O.dat
    RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTF0004_O1.dat
    RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTF0004_O2.dat
    JOBEND
fi

# On ne supprime que lors du 1er SEGTYP_CF
if [ "$TYPDELT" = "D" ]
then
#----------------------------------------------------------------------------
# Executing ISQL procedure to delete data in the table TCTRGRO
#----------------------------------------------------------------------------
NSTEP=${NJOB}_70
LIBEL="Executing ISQL procedure to delete data from the table TCTRGRO"
ISQL_BASE=${WORK_BASE}
ISQL_QRY="delete BSAR..TCTRGRO where SSD_CF = ${SSD_CF} and SEGTYP_CT = '${SEGTYP_CT}'"
ISQL

#----------------------------------------------------------------------------
# Executing ISQL procedure to delete data in the table TBOSEGMT
#----------------------------------------------------------------------------
NSTEP=${NJOB}_80
LIBEL="Executing ISQL procedure to delete data from the table TBOSEGMT"
ISQL_BASE=${WORK_BASE}
ISQL_QRY="delete BSAR..TBOSEGMT where SSD_CF = ${SSD_CF} and SEGTYP_CT = '${SEGTYP_CT}'"
ISQL
fi

#----------------------------------------------------------------------------
# Execution of the BCP IN TCTRGRO
#----------------------------------------------------------------------------
NSTEP=${NJOB}_90
LIBEL="Beginning of a BCP IN TCTRGRO"
BCP_WAY=IN
BCP_VER=""
BCP_SPECIAL_OPT="" 
BCP_I=${DFILT}/${NJOB}_20_${IB}_BCP_BSAR_TCTRGRO_O.dat
BCP_TABLE="${WORK_BASE}..${CTRGRO_TABLE}"
BCP

#-------------------------------------------------------------------------------------------------
# Executing ISQL procedure to create and loadind contracts which are not include in the portfolio
#-------------------------------------------------------------------------------------------------
NSTEP=${NJOB}_100
LIBEL="Executing ISQL procedure to create a false segment with unaffected contracts"
ISQL_BASE="BSTA"
ISQL_QRY="execute PiSEGBA_02 ${SSD_CF},'${SEGTYP_CT}' "
ISQL

#-------------------------------------------------------------------------------------------------
# Executing ISQL procedure to create to add the number fo the subsidiary in name of the segment
#-------------------------------------------------------------------------------------------------
NSTEP=${NJOB}_110
LIBEL="Executing ISQL procedure to create to add SSD_CF to the name of the segment"
ISQL_BASE="BSTA"
ISQL_QRY="execute PuESTSEG_02 ${SSD_CF},'${SEGTYP_CT}' "
ISQL


NSTEP=${NJOB}_120
#--------------------------------
# Bcp : selecting into BEST..TSEGMENT FROM BSAR..TSEGEST
#--------------------------------
LIBEL="Transferring table BSAR..TSEGEST into file with the format of BEST..TSEGMENT" 
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BSTA..PsSEGMENT_01 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}'"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TSEGMENT_O.dat
BCP

NSTEP=${NJOB}_130
# Bcp out
#--------------------------------
LIBEL="Transferring table BSAR..TCTRGRO into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select SSD_CF, SEGTYP_CT, CTR_NF, END_NT, SEC_NF, SEG_NF, ${VRS_NF} from BSAR..TCTRGRO where SSD_CF = ${SSD_CF} and SEGTYP_CT = '${SEGTYP_CT}' order by SSD_CF, SEGTYP_CT,  CTR_NF, END_NT, SEC_NF"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BSAR_TCTRGRO_O.dat
BCP


NSTEP=${NJOB}_140
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in production server"
SWITCH_SRV ${SRV_DEFAULT}

export LAUNCHER="DAEMON"

# Environ
. $DENV/EST.env

# Launch applicative job ESCD9001
# NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSD_CF} ${SSD_CF} 0 0 

NSTEP=${NJOB}_150
#Portfolio File Generation with SADPERICAS File
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Portfolio File Generation"
SORT_CMD=`CFTMP`
SORT_I="${EST_SADPERICAS0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SADPERICAS_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3:,
        CED_NF 5:1 - 5:,
        CTRNAT_CF 7:1 - 7:,
        CTRRET_B 8:1 - 8:,
        DIV_NT 9:1 - 9:,
        EXP_D 12:1 - 12:,
        INC_D 13:1 - 13:,
        LOB_CF 15:1 - 15:,
        NAT_CF 16:1 - 16:,
        PCPRSKTRY_CF 19:1 - 19:,
        SEGTYP_CT 23:1 - 23:,
        SOB_CF 24:1 - 24:,
        SSD_CF 25:1 - 25: EN,
        SUBNAT_CF 26:1 - 26:,
        TOP_CF 27:1 - 27:,
        UWGRP_CF 28:1 - 28:
/KEYS  SSD_CF,
       SEGTYP_CT,
       CTR_NF,
       END_NT,
       SEC_NF
/CONDITION FILIALE     SSD_CF EQ ${SSD_CF} 
                   and SEGTYP_CT EQ "${SEGTYP_CT}"
/OUTFILE ${SORT_O}
/INCLUDE FILIALE
/REFORMAT CTR_NF,
             END_NT,
             SEC_NF,
             CED_NF,
             CTRNAT_CF,
             CTRRET_B,
             DIV_NT,
             EXP_D,
             INC_D,
             LOB_CF,
             NAT_CF,
             PCPRSKTRY_CF,
             SEGTYP_CT,
             SOB_CF,
             SSD_CF,
             SUBNAT_CF,
             TOP_CF,
             UWGRP_CF
exit
EOF
SORT

NSTEP=${NJOB}_160
#Portfolio File Generation with FINFOSEGPOR File (Format or BEST..TSEGPOR)
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Portfolio File Generation (Format or BEST..TSEGPOR)"
SORT_CMD=`CFTMP`
SORT_I="${EST_FINFOSEGPOR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TSEGPOR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        SEGTYP_CT 4:1 - 4:,
        SSD_CF 5:1 - 5: EN
/KEYS CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT
/CONDITION FILIALE SSD_CF EQ ${SSD_CF} and SEGTYP_CT EQ "${SEGTYP_CT}"
/INCLUDE   FILIALE
exit
EOF
SORT

NSTEP=${NJOB}_170
# Generation of a file in BEST..TCTRGRO format
#--------------------------------
LIBEL="Generation of a file in BEST..TCTRGRO format"
PRG=ESTC0112
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_SORT_SADPERICAS_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_130_${IB}_BCP_BSAR_TCTRGRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TCTRGRO_O.dat
EXECPRG

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_150_${IB}_SORT_SADPERICAS_O.dat"

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL=""
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_170_${IB}_ESTC0112_TCTRGRO_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TCTRGRO_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
    END_NT 2:1 - 2:,
    SEC_NF 3:1 - 3:,
    SSD_CF 5:1 - 5: EN,
    SEGTYP_CT 6:1 - 6:,
    SEG_NF 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, SSD_CF, SEGTYP_CT, SEG_NF
exit
EOF
SORT

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_170_${IB}_ESTC0112_TCTRGRO_O.dat"

NSTEP=${NJOB}_210
# Generation of a file in BEST..TCTRANO format
#--------------------------------
LIBEL="Generation of a file in BEST..TCTRANO format"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
VRS_NF ${VRS_NF}
exit
EOF
PRG=ESTC0110
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_TCTRGRO_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_160_${IB}_SORT_TSEGPOR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_120_${IB}_BCP_TSEGMENT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TCTRANO_O.dat
EXECPRG

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_160_${IB}_SORT_TSEGPOR_O.dat"


NSTEP=${NJOB}_230
# Current estimate table delete
#--------------------------------
LIBEL="Current estimate table delete avec OPTION 3 "
ISQL_QRY="exec PdCTRGRO_05 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}'"
ISQL_BASE='BEST'
ISQL

NSTEP=${NJOB}_240
# BCP in BEST..TCTRGRO
#--------------------------------
LIBEL="BCP in BEST..TCTRGRO"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_190_${IB}_SORT_TCTRGRO_O.dat
BCP_TABLE="BEST..TCTRGRO"
BCP    

NSTEP=${NJOB}_250
# BCP in BEST..TSEGMENT
#--------------------------------
LIBEL="BCP in BEST..TSEGMENT"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_120_${IB}_BCP_TSEGMENT_O.dat
BCP_TABLE="BEST..TSEGMENT"
BCP    

# Si le fichier n'est pas vide, on initialise la valeur ERRANO à 1 pour la proc PiCTRGRO_04 (PuVersion_06 et PuVersion_07)
if test -s ${DFILT}/${NJOB}_210_${IB}_ESTC0110_TCTRANO_O.dat
then
    export ERRANO=1
fi

NSTEP=${NJOB}_260
# BCP in BEST..TCTRANO
#--------------------------------
LIBEL="BCP in BEST..TCTRANO"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_210_${IB}_ESTC0110_TCTRANO_O.dat
BCP_TABLE="BEST..TCTRANO"
BCP 

STEP=${NJOB}_270
# Current estimate table update
#--------------------------------
LIBEL="Current estimate table update with Option 3"
ISQL_QRY="exec PiCTRGRO_04 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', 3, ${ERRANO}"
ISQL_BASE='BEST'
ISQL

#----------------------------------------------------------------------------
# Removing work files
#----------------------------------------------------------------------------
NSTEP=${NJOB}_280
LIBEL="removing of the temporary files"
RMFIL ${DFILT}/${NJOB}_20_${IB}_BCP_BSAR_TCTRGRO_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTF0004_O1.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTF0004_O2.dat

	
# End of the Job
JOBEND

#!/bin/ksh
#=============================================================================
# name of application    : Technical Accounting - Everest Interface
# name of script SHELL   : CPTJ0001.cmd
# date of creation       : 03/10/2019
# Author                 : Charles SOCIE
#-----------------------------------------------------------------------------
# description
#   
#-------------------------------------------------------------------------------
# History of modifications
#  
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Variable initialisation 
# ------------------------------
#USR_CF='dbo'
USR_CF=`id -un`

USER_CF=$2
CUR_DATE=$3

V_DATE_MONTH=`date +"%m"`
V_DATE_YEAR=`date +"%Y"`


NSTEP=${NJOB}_05
# Begin rm
#-----------------------------------------------------------------
LIBEL="Delete file create by the LOOP "
RMFIL "${DFILT}/${NJOB}_LOOP_*_GETSITES_*.dat"

NSTEP=${NJOB}_10
# SSD_CF and ESB_CF recovery from file name passed as input 
# -------------------------------------------------------------------------------
# filiale
SSD_CF=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f9`
# établissement
ESB_CF=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f10`
ls -ltr ${DFILT}/${NJOB}_LOOP_*.dat


# DEBUT DES PRE-TESTS
NSTEP=${NJOB}_15
# vérifier si SSD_CF et ESB_CF sont numériques
# -----------------------------------------------------------------------------
# Begin isql-bcpmulti
#---------------------------------------------------------------
LIBEL="Check numericity of Subsidiary ${SSD_CF}"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TEST_NUMERIC_SSD_CF_O.dat
BCP_QRY="select isnumeric('${SSD_CF}')"
BCP
SSD_CF_NUMERIC=`cat ${BCP_O}`

NSTEP=${NJOB}_20
# vérifier si SSD_CF et ESB_CF sont numériques 
# Utiliser SSD_CF=ESB_CF=99 fictif de BREF..TESB pour créer en-tête TSUIVINTACC
# -----------------------------------------------------------------------------
LIBEL="Check numericity of Subledger ${ESB_CF}"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TEST_NUMERIC_ESB_CF_O.dat
BCP_QRY="select isnumeric('${ESB_CF}')"
BCP
ESB_CF_NUMERIC=`cat ${BCP_O}`

# SSD et ESB non numérique
if [ "${SSD_CF_NUMERIC}" != "1" -o "${ESB_CF_NUMERIC}" != "1" ]
then
    # filiale et établissement fictifs
    SSD_CF=99
    ESB_CF=99
    USR_CF="unknown"
    BALSHT_D=0
# SSD et ESB numérique
else
    NSTEP=${NJOB}_25
    # vérifier existence SSD_CF et ESB_CF dans BREF..TESB
    #---------------------------------------------------------------
    LIBEL="Check if Subsidiary ${SSD_CF} and Subledger ${ESB_CF} exist in database"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TEST_SSD_ESB_O.dat
    BCP_QRY="select count(1) from BREF..TESB where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF}"
    BCP
    SSD_ESB=`cat ${BCP_O}`
    # SSD et ESB inconnus
    if [ "${SSD_ESB}" != "1" ]
    then
        # filiale et établissement fictifs
        SSD_CF=99
        ESB_CF=99
        USR_CF="unknown"
        BALSHT_D=0
        # SSD et ESB inconnus 
    fi
# SSD et ESB non numérique
fi

NSTEP=${NJOB}_30
# Begin Bcmulti
#----------------------------------------------------------------------------
LIBEL="Get register for TSUIVINTACC : proc BCTA..PtRGCOMPTEUR"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_NUMFIC_NT_TSUIVINTACC.dat
BCP_QRY="execute BCTA..PtRGCOMPTEUR ${SSD_CF}, ${ESB_CF},'TSUIVINTACC',1"
BCP
NUMFIC_NT=`cat ${BCP_O}`

NSTEP=${NJOB}_35
# Fetching Batch User
#---------------------------------------------------------------
LIBEL="fetching batch user"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FETCH_BATCH_USER_O.dat
BCP_QRY="select convert(char(4), BATCHUSER_CF) from bref..tbatchssd where SSD_CF=${SSD_CF}"
BCP
USR_CF="`cat ${BCP_O}`"

NSTEP=${NJOB}_40
#renommer le fichier en entrée
#--------------------------------------------------
NOM_FICHIER=${PCH}CPTD0912_${SSD_CF}_${ESB_CF}_${USR_CF}_${NUMFIC_NT}.dat
LIBEL="Getting the work file ${DFILT}/${NOM_FICHIER}"
EXECKSH "mv ${DFILT}/${NJOB}_LOOP_*.dat ${DFILT}/${NOM_FICHIER}"


NSTEP=${NJOB}_45
# Fetching Batch User
#---------------------------------------------------------------
LIBEL="fetching balancesheet date"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_BALANCESHEET_DATE_O.dat
BCP_QRY="execute BCTA..PsBLCSHTD_02 ${SSD_CF}, ${ESB_CF},0,1, ${V_DATE_MONTH}, ${V_DATE_YEAR}"
BCP
MONTH=`cat ${BCP_O} | cut -d'~' -f1`
YEAR=`cat ${BCP_O} | cut -d'~' -f2`
DAY=`cat ${BCP_O} | cut -d'~' -f4`
BALSHT_D="${YEAR}${MONTH}${DAY}"


NB_RECORD=`cat ${DFILT}/${NOM_FICHIER} | wc -l`


NSTEP=${NJOB}_50
# BEGIN isql
#---------------------------------------------------------------
LIBEL="Insert header - EC status - into TSUIVINTACC for file ${NOM_FICHIER}"
ISQL_BASE="BCTA"
ISQL_QRY="insert into BCTA..TSUIVINTACC
     (NUMFIC_NT,SSD_CF,ESB_CF,USR_CF,NOMFICORIG_LL,NOMFICSERV_LL,INTEG_D,FICSTS_CF,NBLGTOT_NT,NBLGKO_NT,NBANO_NT,MINMVT_NT,MAXMVT_NT,LSTUPDUSR_CF,LSTUPD_D) 
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},'${USR_CF}','${NOM_FICHIER}','${NOM_FICHIER}',getdate(),'EC',${NB_RECORD},0,0,0,0,'${USR_CF}',getdate())"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TSUIVINTACC.log
ISQL

ECHO_LOG "#===> USR_CF......................: ${USR_CF}"
ECHO_LOG "#===> BALSHT_D......................: ${BALSHT_D}"
ECHO_LOG "#===> SSD_CF....................: ${SSD_CF}  "
ECHO_LOG "#===> ESB_CF...................: ${ESB_CF}  "
ECHO_LOG "#===> NUMFIC_NT....................: ${NUMFIC_NT}"
ECHO_LOG "#===> CUR_DATE...................: ${CUR_DATE}"


if [ "${USR_CF}" != "" ] -a [ "${BALSHT_D}" != "" ]
then
	NSTEP=${NJOB}_55
	LIBEL="Calling CPTD0912"
	NJOB="CPTD0912"
	# Launch applicative job CPTJ0000 
	${DCMD}/CPTD0912.cmd "${USR_CF}" "${SSD_CF}" "${ESB_CF}" "${NUMFIC_NT}" "${CUR_DATE}" "${BALSHT_D}" 1 2>&1 | ${TEE}


NSTEP=${NJOB}_60
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="TSUIVINTACC file generation"
BCP_WAY="OUT";BCP_VER="+"
BCP_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat
BCP_QRY="select 'TOBEREPLACE',NUMFIC_NT,SSD_CF,ESB_CF,USR_CF,NOMFICORIG_LL,NOMFICSERV_LL
            ,convert(char(8),INTEG_D,112)+' '+convert(char(8),INTEG_D,108)+substring(convert(char(27),INTEG_D,109),21,4)
            ,FICSTS_CF,NBLGTOT_NT,NBLGKO_NT,NBANO_NT,MINMVT_NT,MAXMVT_NT,LSTUPDUSR_CF
            ,convert(char(8),LSTUPD_D,112)+' '+convert(char(8),LSTUPD_D,108)+substring(convert(char(27),LSTUPD_D,109),21,4),0,0,null
         from BCTA..TSUIVINTACC
         where NUMFIC_NT = ${NUMFIC_NT}
            AND SSD_CF = ${SSD_CF}
            AND ESB_CF = ${ESB_CF}"
BCP

NSTEP=${NJOB}_65
# Begin bcp out
#------------------------------------------------------------------------------
LIBEL="TANOINTACC file generation"
BCP_WAY="OUT";BCP_VER="+"
BCP_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TANOINTACC_O.dat
BCP_QRY="select 'TOBEREPLACE',* from BCTA..TANOINTACC
            where NUMFIC_NT = ${NUMFIC_NT}
            AND SSD_CF = ${SSD_CF}
            AND ESB_CF = ${ESB_CF}"
BCP

NSTEP=${NJOB}_70
#-----------------------------------------------------------
LIBEL="Switch on server ${SRV2}"
SWITCH_SRV ${SRV2}

NSTEP=${NJOB}_75
# Begin BCP IN
#------------------------------------------------------------------------------
V_LABEL=`echo BCP IN of file ${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat into BSTA..TSUIVINTACC`
LIBEL=${V_LABEL}
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat
BCP_TABLE="BSTA..TSUIVINTACC"
BCP

NSTEP=${NJOB}_80
# Begin BCP IN
#------------------------------------------------------------------------------
V_LABEL=`echo BCP IN of file ${DFILT}/${NCHAIN}_BCP_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_TANOINTACC_O.dat into BSTA..TANOINTACC`
LIBEL=${V_LABEL}
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TANOINTACC_O.dat
BCP_TABLE="BSTA..TANOINTACC"
BCP


fi

NSTEP=${NJOB}_85
# Begin rm
#-----------------------------------------------------------------
#LIBEL="Delete of temporary file "
#RMFIL "${DFILT}/${NCHAIN}_*.dat"
#RMFIL "${DFILT}/${ARCHIVE_PREFIX}_${ARCHIVE_DATE}_${NOM_ORIGINE}"


# Closing the Job
JOBEND

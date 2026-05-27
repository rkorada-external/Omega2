#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INTEGRATION FICHIER des ecritures 
#				                    de service
# nom du script SHELL		  : ESIJ0801.cmd
# revision			          : $Revision:   1.0  $
# date de creation		    : 01/06/2012
# auteur			            : L. RAKOTOZAFY
# fiche spot              :23860
#                         :spot:23860     LRAK
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Intégration des fichiers d'écritures de service
#
# Job appelé par ESIJ0800.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# 
#[001] 14/11/2013 R. Cassis :spot:25427 - modifs centralization des bases
#[002] 2014-03-10  usumeme Removed partition option of steps 160 and 165
#[003] SPOT 26889 30/05/2014 Sam Mansour : changed usr_cf from dbo to id -un
#[0004] 13/01/2015  usuaksh  Spot #27968  Added logic for archiving the input file.
#[005] 2015.04.13 usubagr  Spot #28688  Modified column count check (38->40) for added columns EVT_NF and REVT_NF.
#[006] 24/05/2022 S.Behague spira:104079:IFRS17- REQ.LIF.01: AE interface for Life from SAS - Not create AE with delta result is 0
#[007] 6/02/2023  M.NAJI : spira 108028 refonte de la proc PiACCSUP_02 vers PiACCSUP_04
#[008] 18/03/2025 S.Behague spira:111789:Control/Limit SAS data volume in Omega
#[009] 25/06/2025 S.Behague US:5884:Control/Limit SAS AE data volume in Omega- Review AE remove conditions
#[010] 26/11/2025 S.Behague US7362 L&H- SAS AE intégration issue on US last day of closing
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
NOT_DIGITAL=1
UNKNOWN=1
NB_FIELD=1
PROCESSED=1
PRE_TEST=1
CONSISTENCY_STATUS=0
FORMAT_STATUS=1
BATCH_MODE='batch'
TRN_MIN=0

set `GETPRM ${DPRM}/ESCJ0000.prm`
CRE_D=$1

NSTEP=${NJOB}_05
# Begin rm
#-----------------------------------------------------------------
LIBEL="Delete of GETSITES file "
RMFIL "${DFILT}/${NJOB}_LOOP_*_GETSITES_*.dat"

NSTEP=${NJOB}_10
# récupération filiale et établissement du nom de fichier passé en paramètre
# reconstitution du nom original
# -------------------------------------------------------------------------------
# filiale
SSD_CF=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f8`
# établissement
ESB_CF=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f9`
# compteur client
DATE_CLIENT=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f10`
# date
ID_CLIENT=`ls ${DFILT}/${NJOB}_LOOP_*.dat | cut -d'_' -f11`
# nom origine
NOM_ORIGINE=${NOM_PREFIX}_${SSD_CF}_${ESB_CF}_${DATE_CLIENT}_${ID_CLIENT}
#préparer le nom du fichier
PREP_NOM_FICHIER=${NOM_PREFIX}_${SSD_CF}_${ESB_CF}_${DATE_CLIENT}


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
    NOT_DIGITAL=0
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
        UNKNOWN=0
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
BCP_QRY="execute BCTA..PtRGCOMPTEUR ${SSD_CF},${ESB_CF},'TSUIVINTACC',1"
BCP
NUMFIC_NT=`cat ${BCP_O}`

NSTEP=${NJOB}_35
#renommer le fichier en entrée
#--------------------------------------------------
NOM_FICHIER=${PREP_NOM_FICHIER}_${NUMFIC_NT}.dat
LIBEL="Getting the work file ${DFILT}/${NOM_FICHIER}"
EXECKSH "mv ${DFILT}/${NJOB}_LOOP_*.dat ${DFILT}/${PREP_NOM_FICHIER}.dat"

NSTEP=${NJOB}_40
#renommer le fichier en entrée et enlever les ctrl M
#--------------------------------------------------
LIBEL="Removing ctrlM from file ${DFILT}/${NOM_FICHIER}"
EXECKSH_MODE=P
EXECKSH "tr -d '\r' <${DFILT}/${PREP_NOM_FICHIER}.dat> ${DFILT}/${NOM_FICHIER}"
# récupérer le nombre de ligne du fichier
#--------------------------------------------------
NB_RECORD=`cat ${DFILT}/${NOM_FICHIER} | wc -l`

NSTEP=${NJOB}_45
# BEGIN isql
#---------------------------------------------------------------
LIBEL="Insert header - EC status - into TSUIVINTACC for file ${NOM_FICHIER}"
ISQL_BASE="BCTA"
ISQL_QRY="insert into BCTA..TSUIVINTACC
     (NUMFIC_NT,SSD_CF,ESB_CF,USR_CF,NOMFICORIG_LL,NOMFICSERV_LL,INTEG_D,FICSTS_CF,NBLGTOT_NT,NBLGKO_NT,NBANO_NT,MINMVT_NT,MAXMVT_NT,LSTUPDUSR_CF,LSTUPD_D) 
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},'${USR_CF}','${NOM_ORIGINE}','${NOM_FICHIER}',getdate(),'EC',${NB_RECORD},0,0,0,0,'${USR_CF}',getdate())
    "
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TSUIVINTACC.log
ISQL

#Added the step here to closely match the timestamp used in the previous step
#and to keep a copy of the input file before we attempt to validate
ARCHIVE_DATE=`date +"%Y%m%d%H%M%S"`
ARCHIVE_PREFIX=svg

NSTEP=${NJOB}_46
# Copy the file for archival purpose.
#-----------------------------------------------------------------
LIBEL="Copy the file for archival purpose."
EXECKSH "cp ${DFILT}/${NOM_FICHIER} ${DFILT}/${ARCHIVE_PREFIX}_${ARCHIVE_DATE}_${NOM_ORIGINE}"

NSTEP=${NJOB}_47
# Archive the file
#-----------------------------------------------------------------
LIBEL="Archive the file."
EXECKSH_MODE=P
EXECKSH "gzip -c ${DFILT}/${ARCHIVE_PREFIX}_${ARCHIVE_DATE}_${NOM_ORIGINE} > ${DTRANSFER}/${REMOTE_SITE}/fromsave/${ARCHIVE_PREFIX}_${ARCHIVE_DATE}_${NOM_ORIGINE}.gz"

#[001]
NSTEP=${NJOB}_50
# Contrôle nombre de colonne
#-------------------------------------------------------
awk -F"~" '{ if (NF != 40) {print " Column count unlike 40 "}}' ${DFILT}/${NOM_FICHIER}> ${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_NBR_COLONNE_ano.dat
if [ -s  ${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_NBR_COLONNE_ano.dat ]
then 
    NB_FIELD=0
fi

NSTEP=${NJOB}_55
# Begin Bcpmulti
#---------------------------------------------------------------
LIBEL="Check if file is already processed"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TEST_INTEGRE_OK_O.dat
BCP_QRY="select count(1) from BCTA..TSUIVINTACC where SSD_CF=${SSD_CF} and ESB_CF=${ESB_CF} and NOMFICORIG_LL='${NOM_ORIGINE}' and FICSTS_CF='OK'"
BCP
PROCESSED=`cat ${BCP_O}`

# création en-tête pour anomalie
#----------------------------------------------------
if [ "${NB_FIELD}" != "1" -o "${PROCESSED}" != "0" -o "${UNKNOWN}" != "1" -o "${NOT_DIGITAL}" != "1" ]
then
    NSTEP=${NJOB}_60
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Update header - KO status - in TSUIVINTACC for file ${NOM_FICHIER}"
    ISQL_BASE="BCTA"
    ISQL_QRY="
    UPDATE BCTA..TSUIVINTACC
      SET FICSTS_CF    = 'KO',
          NBLGKO_NT    = ${NB_RECORD},
          LSTUPDUSR_CF = '${USR_CF}',
          LSTUPD_D     = getdate()
    WHERE ssd_cf       = ${SSD_CF}
      AND esb_cf       = ${ESB_CF}
      AND numfic_nt    = ${NUMFIC_NT}
      AND FICSTS_CF    = 'EC'
    "
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TSUIVINTACC.log
    ISQL
    # positionner variable anomalie pre-test
    # --------------------------------------
    PRE_TEST=0
fi

# création anomalie pour filiale et établissement non numérique
#--------------------------------------------------------------
if  [ "${NOT_DIGITAL}" != "1" ]
then
    NSTEP=${NJOB}_65
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Insert message 283 into TANOINTACC - Subsidiary or subledger filename is not digital"
    ISQL_BASE="BCTA"
    ISQL_QRY="insert into BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},0,283)
    "
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TANOINTACC.log
    ISQL
fi

# création anomalie pour filiale et établissement inconnus
#----------------------------------------------------------
if [ "${UNKNOWN}" != "1" ]
then
    NSTEP=${NJOB}_70
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Insert message 281 into TANOINTACC - Subsidiary and Subledger unknown"
    ISQL_BASE="BCTA"
    ISQL_QRY="insert into BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},0,281)
    "
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TANOINTACC.log
    ISQL
fi

# création anomalie pour nombre de champs incorrect
#---------------------------------------------------
if [ "${NB_FIELD}" != "1" ]
then
    NSTEP=${NJOB}_75
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Insert message 272 into TANOINTACC - Column count unlike 40"
    ISQL_BASE="BCTA"
    ISQL_QRY="insert into BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},0,272)
    "
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TANOINTACC.log
    ISQL
fi

# création anomalie pour fichier déjà intégré
#----------------------------------------------------------
if [ "${PROCESSED}" != "0" ]
then
    NSTEP=${NJOB}_80
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Insert message 282 into TANOINTACC - File already processed"
    ISQL_BASE="BCTA"
    ISQL_QRY="insert into BCTA..TANOINTACC (NUMFIC_NT,SSD_CF,ESB_CF,NUMLIGNE_NT,MESS_N)
    values (${NUMFIC_NT},${SSD_CF},${ESB_CF},0,282)
    "
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_INSERT_TANOINTACC.log
    ISQL
fi
#FIN DES PRE-TESTS   

# DEBUT PAS D'ANOMALIES DE PRE-TESTS
if [ "${PRE_TEST}" = "1" ]
then
        
    NSTEP=${NJOB}_85
    # Begin isql
    #------------------------------------------------------------------------------
    LIBEL="Delete of old assistance entries"
    ISQL_BASE="BTRAV"
    ISQL_QRY="delete BTRAV..EST_ESID0801_TESTUTISUP
              where SSD_CF=${SSD_CF} and LSTUPDUSR_CF = '${USR_CF}'"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
    ISQL
    
    NSTEP=${NJOB}_90
    #Begin isql
    #-----------------------------------------------------------------------------
    LIBEL="Selection of the largest TRN_NT from BTRAV..EST_ESID0801_TESTUTISUP"
    ISQL_BASE="BTRAV"
    ISQL_QRY="select max(TRN_NT) from BTRAV..EST_ESID0801_TESTUTISUP"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
    ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
    ISQL_RES
    
    #The largest TRN_NT is affected to TRNMAX_NT
    TRNMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`


    NSTEP=${NJOB}_95
    # Suppression des montants a zero (accept et/ou retro)
    #--------------------------------------------------
    LIBEL="Suppression des montants a zero (accept et/ou retro)"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NOM_FICHIER} 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NEW_ACCUP_NOZERO_O.dat 1000 1"
    SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_NEW_ACCUP_ZERO_ANO_O.dat 1000 1"
    INPUT_TEXT $SORT_CMD <<EOF
    /FIELDS CTR_NF 		  	11:1 - 11:,
				    AMT_M         22:1 - 22:EN 15/3,
				    RETCTR_NF     23:1 - 23:,
				    RETAMT_M      35:1 - 35:EN 15/3
    /COPY
    /CONDITION ERROR ( (RETCTR_NF != "" AND RETCTR_NF != "NULL" AND RETAMT_M = 0) OR (CTR_NF != "" AND AMT_M = 0) )
    /OUTFILE ${SORT_O}
    /OMIT ERROR
    /OUTFILE ${SORT_O2}
    /INCLUDE ERROR
    exit
EOF
    SORT

    NSTEP=${NJOB}_100
    # Introduction of TRN_NT and LSTUPDUSR_CF in the Assistance Entries File
    #----------------------------------------------------------------------------
    LIBEL="Introduction of TRN_NT and truncating comment in the Assistance Entries File"
    AWK_I=${DFILT}/${NJOB}_95_${IB}_SORT_NEW_ACCUP_NOZERO_O.dat
    AWK_PARAM=" TRNMAX=${TRNMAX_NT} "
    AWK_O=${DFILT}/${NJOB}_${IB}_AWK_SVC_O.dat
    AWK_CMD=`CFTMP`
    INPUT_TEXT ${AWK_CMD} <<EOF
    BEGIN {
     FS="~"
     OFS="~"
    }
    {
       TRNMAX=TRNMAX+1;
       \$1=TRNMAX"~"\$1;
       if ( length(\$36) > 64 ) \$36 = substr(\$36,1,64);
       print \$0;
    }
    exit
EOF
    AWK
    
    NSTEP=${NJOB}_105
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Truncate table BTRAV..EST_ESIJ0801_TESTUTISUP"
    ISQL_BASE="BTRAV"
    ISQL_QRY="truncate table BTRAV..EST_ESIJ0801_TESTUTISUP"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_TRUNCATE_ESIJ0801_TESTUTISUP.log
    ISQL
    
    NSTEP=${NJOB}_110
    # Begin BCP IN
    #----------------------------------------------------------------------------
    LIBEL="Fill in table BTRAV..EST_ESIJ0801_TESTUTISUP"
    BCP_WAY="IN";BCP_VER=""
    BCP_I=${DFILT}/${NJOB}_${IB}_AWK_SVC_O.dat
    BCP_TABLE="BTRAV..EST_ESIJ0801_TESTUTISUP"
    BCP

    NSTEP=${NJOB}_115
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Format control by BEST..PtTSUIVINTACC_01 "
    ISQL_BASE="BEST"
    ISQL_QRY="execute BEST..PtTSUIVINTACC_01 ${SSD_CF},${ESB_CF},${NUMFIC_NT},'${USR_CF}','${CRE_D}'"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_PROCEDURE_PtTSUIVINTACC_01.log
    ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat
    ISQL_INFO
    # récupération statut de retour
    FORMAT_STATUS=`cat ${ISQL_FRES}`
fi
# FIN PAS D'ANOMALIES DE PRE-TESTS  

# DEBUT PAS D'ANOMALIES DE PRE-TESTS ET DE FORMAT -> test COHERENCE et comptabilisation
if [ "${PRE_TEST}" -eq "1" ] &&
   [ "${FORMAT_STATUS}" -ne "1" ]
then
    NSTEP=${NJOB}_120
    # Begin isql
    #-----------------------------------------------------------------------------
    LIBEL="Insert into BTRAV..BCTA_SUMAMOUNT amount and balance sheet date"
    ISQL_BASE="BTRAV"
    ISQL_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BTRAV_PiTSUIVINTACC_05.log
    ISQL_QRY="execute BCTA..PiTSUIVINTACC_05 'ESTIMATION',${SSD_CF},${ESB_CF},${NUMFIC_NT},'${USR_CF}'"
    ISQL
    
    NSTEP=${NJOB}_125
    # Begin bcp out
    #------------------------------------------------------------------------------
    LIBEL="BTRAV..BCTA_SUMAMOUNT file generation"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_BSTA_TSUIVINTACC_O.dat
    BCP_QRY="select * from BTRAV..BCTA_SUMAMOUNT"
    BCP
    
    NSTEP=${NJOB}_130
    #Begin isql
    #-----------------------------------------------------------------------------
    LIBEL="Selection of the largest TRN_NT from BEST..TACCSUP before insertion"
    ISQL_BASE="BEST"
    ISQL_QRY="select max(TRN_NT)+1 from BEST..TACCSUP"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
    ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
    ISQL_RES
    
    #The largest TRN_NT+1 is affected to TRN_MIN
    TRN_MIN=`cat ${ISQL_FRES}`
    
    
    NSTEP=${NJOB}_135
    # Begin isql
    #------------------------------------------------------------------------------
    LIBEL="Consistency control of assistance entries"
    ISQL_BASE="BEST"
    ISQL_QRY="execute PiACCSUP_04 ${SSD_CF},'${USR_CF}','${BATCH_MODE}','${CRE_D}'"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_PROCEDURE_PiACCSUP_02.log
    ISQL
        
    NSTEP=${NJOB}_140
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Check error in TCTRANO - Update TSUIVINTACC and TANOINTACC"
    ISQL_BASE="BEST"
    ISQL_QRY="execute BEST..PtTSUIVINTACC_02 ${SSD_CF},${ESB_CF},${NUMFIC_NT},'${USR_CF}',${TRN_MIN}"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_PROCEDURE_PtTSUIVINTACC_02.log
    ISQL   
fi
# FIN PAS D'ANOMALIES DE PRE-TESTS ET DE FORMAT -> test COHERENCE et comptabilisation

NSTEP=${NJOB}_145
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="TSUIVINTACC file generation"
BCP_WAY="OUT";BCP_VER="+"
BCP_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat
BCP_QRY="select 'ESTIMATION',NUMFIC_NT,SSD_CF,ESB_CF,USR_CF,NOMFICORIG_LL,NOMFICSERV_LL
            ,convert(char(8),INTEG_D,112)+' '+convert(char(8),INTEG_D,108)+substring(convert(char(27),INTEG_D,109),21,4)
            ,FICSTS_CF,NBLGTOT_NT,NBLGKO_NT,NBANO_NT,MINMVT_NT,MAXMVT_NT,LSTUPDUSR_CF
            ,convert(char(8),LSTUPD_D,112)+' '+convert(char(8),LSTUPD_D,108)+substring(convert(char(27),LSTUPD_D,109),21,4),0,0,null
         from BCTA..TSUIVINTACC
         where NUMFIC_NT = ${NUMFIC_NT}
            AND SSD_CF = ${SSD_CF}
            AND ESB_CF = ${ESB_CF}"
BCP

NSTEP=${NJOB}_150
# Begin bcp out
#------------------------------------------------------------------------------
LIBEL="TANOINTACC file generation"
BCP_WAY="OUT";BCP_VER="+"
BCP_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TANOINTACC_O.dat
BCP_QRY="select 'ESTIMATION',* from BCTA..TANOINTACC
            where NUMFIC_NT = ${NUMFIC_NT}
            AND SSD_CF = ${SSD_CF}
            AND ESB_CF = ${ESB_CF}"
BCP

NSTEP=${NJOB}_155
#-----------------------------------------------------------
LIBEL="Switch on server ${SRV2}"
SWITCH_SRV ${SRV2}

NSTEP=${NJOB}_160
# Begin BCP IN
#------------------------------------------------------------------------------
V_LABEL=`echo BCP IN of file ${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat into BSTA..TSUIVINTACC`
LIBEL=${V_LABEL}
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TSUIVINTACC_O.dat
BCP_TABLE="BSTA..TSUIVINTACC"
BCP

NSTEP=${NJOB}_165
# Begin BCP IN
#------------------------------------------------------------------------------
V_LABEL=`echo BCP IN of file ${DFILT}/${NCHAIN}_BCP_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_TANOINTACC_O.dat into BSTA..TANOINTACC`
LIBEL=${V_LABEL}
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_TANOINTACC_O.dat
BCP_TABLE="BSTA..TANOINTACC"
BCP

# PAS D'ANOMALIES DE PRE-TESTS ET DE FORMAT
if [ "${PRE_TEST}" -eq "1" ] &&
   [ "${FORMAT_STATUS}" -ne "1" ]
then
    NSTEP=${NJOB}_170
    # BEGIN isql
    #---------------------------------------------------------------
    LIBEL="Truncate table BTRAVI..BSTA_TSUIVINTACC"
    ISQL_BASE="BTRAVI"
    ISQL_QRY="truncate table BTRAVI..BSTA_TSUIVINTACC"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_BSTA_TSUIVINTACC.log
    ISQL
    
    NSTEP=${NJOB}_175
    # Begin BCP IN
    #------------------------------------------------------------------------------
    V_LABEL=`echo BCP IN of file ${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_BSTA_TSUIVINTACC_O.dat into BTRAVI..BSTA_TSUIVINTACC`
    LIBEL=${V_LABEL}
    BCP_WAY="IN"
    BCP_VER=""
    BCP_I=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BCP_BSTA_TSUIVINTACC_O.dat
    BCP_TABLE="BTRAVI..BSTA_TSUIVINTACC"
    BCP

    NSTEP=${NJOB}_180
    # Reporting 
    #-----------------------------------------------------------------------------
    LIBEL=" BSTA..TSUIVINTACC amount and balance sheet date updating "
    ISQL_BASE="BTRAVI"
    ISQL_O=${DFILT}/${NCHAIN}_${SSD_CF}_${ESB_CF}_${NUMFIC_NT}_${IB}_BTRAV_PiTSUIVINTACC_05.log
    ISQL_QRY="execute BSTA..PuTSUIVINTACC_06 'ESTIMATION',${SSD_CF},${ESB_CF},${NUMFIC_NT}"
    ISQL
fi

##MIS EN COMMENTAIRE POUR PRODUCTION############################################
##
##NSTEP=${NJOB}_185
### Begin bcp out
###------------------------------------------------------------------------------
##LIBEL="TANOINTACC file generation for anomalies reporting"
##BCP_WAY="OUT";BCP_VER="+"
##BCP_O=${DTRANSFER}/${REMOTE_SITE}/to/${NOM_ORIGINE}_reporting_anomalies_${IB}.dat
##BCP_QRY="select t1.NUMLIGNE_NT,t2.MESS_L 
##            from BSTA..TANOINTACC t1, BREF..TMESSAGE t2 
##            where t1.MESS_N=t2.MESS_N and t1.MESSTHM_C=t2.MESSTHM_C
##                and t2.LANG_C='E' and t1.MESSTHM_C='ESTIMATION' and t1.NUMFIC_NT=${NUMFIC_NT} 
##                and t1.SSD_CF=${SSD_CF} and t1.ESB_CF=${ESB_CF}
##        "
##BCP
##
##NSTEP=${NJOB}_190
###-----------------------------------------------------------------
### Step à supprimer avant la mise en production car sauvegarde inutile
##LIBEL="gzip fichiers pour optimisation espace"
##EXECKSH_MODE=P
##EXECKSH "gzip -c ${DFILT}/${NOM_FICHIER} > ${DTRANSFER}/${REMOTE_SITE}/fromsave/${NOM_ORIGINE}.gz"
##
##MIS EN COMMENTAIRE POUR PRODUCTION############################################

NSTEP=${NJOB}_195
# Begin rm
#-----------------------------------------------------------------
LIBEL="Delete of temporary file "
RMFIL "${DFILT}/${NCHAIN}_*.dat"
RMFIL "${DFILT}/${ARCHIVE_PREFIX}_${ARCHIVE_DATE}_${NOM_ORIGINE}"

# Closing the Job
JOBEND

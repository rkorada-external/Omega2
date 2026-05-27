#!/bin/ksh
#==============================================================================
#Application name : ESTIMATION - LOADING TEXT FILES FROM IBNR TOOL TO BEST
#Source name      : ESED0401.cmd
#revision         : $Revision:   1.11  $
#Date of creation : 25/03/1998
#author           : Patrick de BOELPAEP
#references 		  :
#
#------------------------------------------------------------------------------
#description : Loading of text files received from the client in worktables
#	       from BEST first and insert in the production tables after.
#------------------------------------------------------------------------------
#Variables used :
#FILE_HEADER       Name of the files header
#CTRGRO_TYPE       Type of the CTRGRO files (type A)
#SEGEST_TYPE       Type of the SEGEST files (type B)
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
#   <25/03/1998>   <PADB>    <Creation>
#   <11/05/1998>   <PADB>    < Addition of the step 107 = Creation of a segment of
#                              unaffected contracts >
#[03] 09/05/2012 Florent :spot:23390 Solvency II, gestion du type de segment S
#[04] 25/06/2012 -=Dch=-  :spot:23937 Solvency II , ajout du parametre SEGTYP_CT dans l'appel ESTF0003 step 35
#[05] 27/07/2012 R. Cassis :spot:24041 Solvency II
#[06] modified for Phase 2A Evocard TRA01
#[07] 03/04/2014 Florent :spot:25427 Maj pour compatibilit� avec la segmentation omega 1
#[08] 21/05/2014 Florent :spot:27466 correction pour int�grer le mode batch 2 pour nouvelle segmentation et importation d'uniquement table B
#[09] 12/09/2014 Florent :spot:27466 EST adaptation for SEG export
#[10] 01/06/2015 Florent :spot:28694 Segmentation VIE
#[11] 11/05/2017 Florent :spira:58025 gestion segmentation estimation uniquqment dans base BEST
#[12] 09/08/2017 Roger   :spira:63448 Data extraction for data control are made from Infocenter not TP to be coherent. Correct the command "ls"
#[13] 17/08/2018 Charles :BJTD-CLO-905316 EXT-IFRS17-903277 - REQ 03.05 add three Segment type V, W and X which are respectively the same behavior than A, T and U 
#[14] 16/05/2019 M.NAJI Add sort of TCRGRO file in step 135
#[15] 18/02/2021 HR set status to 10
#[16] 05/05/2021 HR deletion of step setting the file to status 10
#[17] 17/11/2022 JYP:spira:107588 regression IFRS4 ratio from spira 104409  
#[18] 09/08/2023 HR:spira:110303 Closing parameter not available - data change  
#[19] 09/08/2023 HR:spira:110631 Remontée des erreurs sur segment en creation de nouvelle version  
#[20] 18/06/2024 JYP:spira:111723 do not update TSEGEST
#=============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Loading the daemon's parameters
SSD_CF=${2}
#Segments possible A, S, T, U, V, W, X
SEGTYP_CT=${3}
USR_CF=${4}
USR_LAG=${5}
SGT_NT=${6}
VRS_NF=${7}
# [15]
#LNCH_DATE_TIME="${11} ${12}"

#[08] Num�ro de segmentatioon est �gale � -1 si absence de la table A ($CTRGRO_TYPE)
#null si creation de nouvelle version
#* si chargement d' ULR sur une version existante
case ${SGT_NT} in
  -1 )
    MODE_BATCH=2
    LNCH_DATE_TIME="${8}"
    ;;
  null )
    MODE_BATCH=3
    LNCH_DATE_TIME="${11} ${12}"
    ;;
  *)
    MODE_BATCH=1
    LNCH_DATE_TIME="${8}"
    ;;
esac


# TP = st if you want want to have extended log trace
#export TP=st

# Declaration of global variable
FILE_HEADER="ES"
CTRGRO_TYPE="A"
SEGEST_TYPE="B"
DATE=$(date '+%Y-%m-%dT%H:%M:%S')

STOP_JOB=0
LOGTYP_CT="E"
if [ "$USER_LAG" != "F" ]
then
  DUPKEY_MSG="duplicate key(s) on"
  NBENR_MSG="Wrong number of columns"
  FORMAT_MSG="Wrong format"
  ROW_MSG="Row"
  COL_MSG="column"
else
  DUPKEY_MSG=" doublon(s) sur "
  NBENR_MSG="Nombre de colonnes incorrecte"
  FORMAT_MSG="Format incorrect"
  ROW_MSG="Ligne"
  COL_MSG="colonne"
fi

#[005]
if [ "$SEGTYP_CT" = "S" -o "$SEGTYP_CT" = "T" -o "$SEGTYP_CT" = "W" -o "$SEGTYP_CT" = "U" -o "$SEGTYP_CT" = "X" ] #[003] #[013]
then
  SEGTYP_BO="A"
else
  SEGTYP_BO=$SEGTYP_CT
fi

INFOCENTRE_FERME ()
{
# pour le user ubgl uniquement
# r�f�rence pour le nom du fichier log du daemon infocentre dans:
# $DENV/DAE_${INF_SRV}.env
# $DSH/daemon2
#[12]
  INFOCENTRE_LOG=$(ls -rt ${DLOG}/${ENV_PREFIX}_DAE_$(echo ${INF_SRV} 2> /dev/null | sed 's/_/-/' )_bmis_${INF_SRV}_20* | tail -1)
  if [[ "${INFOCENTRE_LOG}" = "" ]]; then
    echo 1
  else
    if [[ $(grep -c KILLDMON ${INFOCENTRE_LOG}) -gt 0 ]];then
      echo 1
    else
      echo 0
    fi
  fi
}

# Custumised Error handling
STEPEND_DISPLAY_ANO=YES
EXCEPTION () {
  EXCEPTION_INIT
  if [[ ${STEP_ERR} -ne 0 ]]; then
    if [[ ${STEP_STOP} =~ _03$ ]];then
      #il faut repasser sur le serveur TP pour remplir la table d'erreur
      SWITCH_SRV ${SRV_DEFAULT}
      ERREUR_MSG="infocentre error, it may be unavailable"
    elif [[ ${STEP_STOP} =~ _00_FERME$ ]];then
      ERREUR_MSG="infocentre unavailable"
    else
      ERREUR_MSG="Technical error on step ${STEP_STOP}"
    fi
    #-----------------------------------------------------------------------------
    LIBEL="insert error message to inform user"
    ISQL_BASE=BEST
    ISQL_QRY="insert BEST..TESTSCH values('${USR_CF}','E','${SSD_CF}/${SEGTYP_CT}/${VRS_NF} ${ERREUR_MSG}',getdate())"
    ISQL
fi
  EXCEPTION_END
}

# Initialisation of the JOB
JOBINIT

#exec fontion SHELL pour remplir le fichier log qui est affich� ci-dessous
INFOCENTRE_FERME

ECHO_LOG "---------------------------------------"
ECHO_LOG "----------  Parametres du Job  ----------"
ECHO_LOG "---------------------------------------"
ECHO_LOG "==> USR_CF..........: ${USR_CF}"
ECHO_LOG "==> SSD_CF..........: ${SSD_CF}"
ECHO_LOG "==> SEGTYP_CT.......: ${SEGTYP_CT}"
ECHO_LOG "==> SGT_NT..........: ${SGT_NT}"
ECHO_LOG "==> VRS_NF..........: ${VRS_NF}"
ECHO_LOG "==> MODE_BATCH......: ${MODE_BATCH}"
ECHO_LOG "==> SEGTYP_BO.......: ${SEGTYP_BO}"
ECHO_LOG "==> DIBNR...........: ${DIBNR}"
ECHO_LOG "==> INFOCENTRE_LOG..: ${INFOCENTRE_LOG:-NO LOG FOUND}"
ECHO_LOG "==> LNCH_DATE_TIME..: ${LNCH_DATE_TIME}"
ECHO_LOG "---------------------------------------"

NSTEP=${NJOB}_00_TESTSCH
#-----------------------------------------------------------------------------
LIBEL="Delete table BEST..TESTSCH for user ${USR_CF}, as it is used for EXCEPTION function"
ISQL_BASE=BEST
ISQL_QRY="delete BEST..TESTSCH where USR_CF='${USR_CF}'"
ISQL

#[003] [005]
if [[ ( ( ( "$SEGTYP_CT" = "A" || "$SEGTYP_CT" = "U" ) && "${MODE_BATCH}" = "1" ) || "${MODE_BATCH}" = "3" ) ]]	#[013]
then
    if [[ $(INFOCENTRE_FERME) -eq 1  ]];then
      NSTEP=${NJOB}_00_FERME
      STEPEND 99
    fi

    NSTEP=${NJOB}_01
    #-----------------------------------------------------------------------------
    LIBEL="SWITCH to infocentre ${SRV_2}"
    SWITCH_SRV ${SRV_2}

    NSTEP=${NJOB}_03
    #-----------------------------------------------------------------------------
    LIBEL="Extract run data for result to snapshot ${SSD_CF},${SEGTYP_CT},${SGT_NT} from BSEG"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_O=${DFILT}/${NSTEP}_${IB}_BSEG_CTRGRO_BCP_O.dat
    BCP_QRY="exec BSAR..PsTCTRGRO_SEG '${SSD_CF}','${SEGTYP_CT}','${SGT_NT}','${VRS_NF}', '${TYPEINV}'"
    BCP

    NSTEP=${NJOB}_05
    #-----------------------------------------------------------------------------
    LIBEL="SWITCH back to default TP ${SRV_DEFAULT}"
    SWITCH_SRV ${SRV_DEFAULT}
  fi

  if [ -s ${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat ]
  then
    #----------------------------------------------------------------------------
    # CREATION OF THE FILE OF DUPLICATE KEYS FOR TCTRGRO
    #----------------------------------------------------------------------------
    NSTEP=${NJOB}_15
    LIBEL="Get Table anomaly"
    PRG=ESTF0001
    export ${PRG}_I1=${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O1.dat
    FPRM=`CFTMP`
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
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    EXECPRG

    #----------------------------------------------------------------------------
    # If there is duplicate keys on TCTRGRO, execution of the BCP IN TESTSCH
    #----------------------------------------------------------------------------

    NSTEP=${NJOB}_20
    LIBEL="Beginning of a BCP IN TESTSCH"
    if [ -s ${DFILT}/${NJOB}_15_${IB}_${PRG}_O1.dat ]
    then
      STOP_JOB=1
      BCP_WAY=IN
      BCP_VER=""
      BCP_SPECIAL_OPT=""
      BCP_I=${DFILT}/${NJOB}_15_${IB}_${PRG}_O1.dat
      BCP_TABLE="BEST..TESTSCH"
      BCP

    fi
fi

if [ "${MODE_BATCH}" != "3" ];then
  #----------------------------------------------------------------------------
  # Execution of the SYNCSORT FOR TSEGEST
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_30
  LIBEL="Sort SEGEST"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I=${DIBNR}/${FILE_HEADER}_${SSD_CF}${SEGTYP_CT}_${SEGEST_TYPE}.txt
  SORT_O=${DFILT}/${NSTEP}_${IB}_TSEGEST_SORT_O1.dat
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:, SEGTYP_CT 2:1 - 2:, SEG_NF 3:1 - 3:, UWY_NF 4:1 - 4:, ACY_NF 13:1 - 13:, FILLER 5:1 - 12:
/KEYS SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, ACY_NF
/DERIVEDFIELD VRS_NF "${VRS_NF}~"
/OUTFILE ${SORT_O}
/REFORMAT VRS_NF, SSD_CF, SEGTYP_CT, SEG_NF, UWY_NF, FILLER, ACY_NF
exit
EOF
  SORT

  # If there is duplicate keys on TSEGEST, execution of the BCP IN TESTSCH
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_31
  LIBEL="Get if subsidiary life"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_QRY="select case when exists(select 1 from BREF..TESB where LIFE_CF=2 and SSD_CF=${SSD_CF}) then 'N' else 'Y' end"
  BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_VIE_O.dat
  BCP

  SSD_VIE=`cat ${BCP_O}`

  ECHO_LOG "==> SSD_VIE........: ${SSD_VIE}"

  #----------------------------------------------------------------------------
  # CREATION OF THE FILE OF DUPLICATE KEYS FOR TSEGEST
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_35
  LIBEL="Get Table anomaly"
  PRG=ESTF0003
  export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_TSEGEST_SORT_O1.dat
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O1.dat
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
USR_CF ${USR_CF}
SEGEST_TYPE ${SEGEST_TYPE}
DATE ${DATE}
LOGTYP_CT ${LOGTYP_CT}
FORMAT_MSG ${FORMAT_MSG}
DUPKEY_MSG ${DUPKEY_MSG}
ROW_MSG ${ROW_MSG}
COL_MSG ${COL_MSG}
NBENR_MSG ${NBENR_MSG}
SEGTYP_CT ${SEGTYP_CT}
SSD_VIE ${SSD_VIE}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  EXECPRG

  #----------------------------------------------------------------------------
  # If there is duplicate keys on TSEGEST, execution of the BCP IN TESTSCH
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_40
  LIBEL="Beginning of a BCP IN TESTSCH"
  if [ -s ${DFILT}/${NJOB}_35_${IB}_${PRG}_O1.dat ]
  then

    STOP_JOB=1

    BCP_WAY=IN
    BCP_VER=""
    BCP_SPECIAL_OPT=""
    BCP_I=${DFILT}/${NJOB}_35_${IB}_${PRG}_O1.dat
    BCP_TABLE="BEST..TESTSCH"
    BCP

  fi

  #----------------------------------------------------------------------------
  # If there's one file with duplicate keys then exit
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_70
  LIBEL="Exit of the job if there is duplicate keys in one one file"
  if [ "$STOP_JOB" = "1" ]
  then
    RMFIL "${DIBNR}/${FILE_HEADER}_${SSD_CF}${SEGTYP_CT}_*.txt ${DFILT}/${NJOB}_*_${IB}_*.dat"
    
    #[15]
    JOB_ID='best04a'

    NSTEP=${NJOB}_71
    LIBEL="Error lines detected"
    LOGWRITE 1 '!!!! ERRORS detected !!!!'
    # Call the Tool box function to set the status to 10-Completed with Anomaly
    MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"
    STEPWARNING 10    

    JOBEND
  fi

  NSTEP=${NJOB}_74
  #----------------------------------------------------------------------------
  LIBEL="Executing ISQL procedure to delete data from the table BTRAV..EST_ESED0401_TSEGEST"
  ISQL_BASE=BTRAV
  ISQL_QRY="delete BTRAV..EST_ESED0401_TSEGEST where SSD_CF=${SSD_CF} and ('${SEGTYP_CT}' = 'A' AND SEGTYP_CT IN ('A', 'V') ) OR ('${SEGTYP_CT}' = 'T' AND SEGTYP_CT IN ('T', 'W')) OR ('${SEGTYP_CT}' = 'U' AND SEGTYP_CT IN ('U', 'X')) OR ('${SEGTYP_CT}' = 'E' AND SEGTYP_CT IN ('E')) OR ('${SEGTYP_CT}'= 'S' AND SEGTYP_CT IN ('S')) "
  ISQL

  #----------------------------------------------------------------------------
  # Execution of the BCP IN TSEGEST
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_75
  LIBEL="Beginning of a BCP IN BTRAV..BTRAV_EST_ESED0401_TSEGEST"
  BCP_WAY=IN
  BCP_VER=""
  BCP_SPECIAL_OPT=""
  BCP_I=${DIBNR}/${FILE_HEADER}_${SSD_CF}${SEGTYP_CT}_${SEGEST_TYPE}.txt
  BCP_TABLE="BTRAV..EST_ESED0401_TSEGEST"
  BCP
fi

#[005]
if [ "$SEGTYP_CT" = "T" -o "$SEGTYP_CT" = "W" -o  "$SEGTYP_CT" = "U" -o  "$SEGTYP_CT" = "X" ]  #[013]
then
  #----------------------------------------------------------------------------
  # Executing ISQL procedure to delete/update data in the table TSEGEST
  #----------------------------------------------------------------------------
  NSTEP=${NJOB}_76
  LIBEL="Executing ISQL procedure to delete and insert data from the table BEST..TSEGEST"
  ISQL_BASE=BEST
  ISQL_QRY="execute BEST..PtSEGEST_01 ${SSD_CF}, '${SEGTYP_CT}', ${VRS_NF}"
  ISQL
else
  if [ "${MODE_BATCH}" -ne 3 ];then
    if [ "$SEGTYP_CT" = "A" -o "$SEGTYP_CT" = "V" ] #[013]
    then
      if [ -s ${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat ]
      then
        #----------------------------------------------------------------------------
        # Executing ISQL procedure to delete data in the table TCTRGRO
        #----------------------------------------------------------------------------
        NSTEP=${NJOB}_81
        LIBEL="Executing ISQL procedure to delete data from the table TCTRGRO"
        ISQL_BASE=BEST
        ISQL_QRY="delete BEST..TCTRGRO where SSD_CF=${SSD_CF} and VRS_NF=${VRS_NF} and ('${SEGTYP_CT}' = 'A' AND SEGTYP_CT IN ('A', 'V') ) OR ('${SEGTYP_CT}' = 'T' AND SEGTYP_CT IN ('T', 'W')) OR ('${SEGTYP_CT}' = 'U' AND SEGTYP_CT IN ('U', 'X')) OR ('${SEGTYP_CT}' = 'E' AND SEGTYP_CT IN ('E')) OR ('${SEGTYP_CT}'= 'S' AND SEGTYP_CT IN ('S')) "
        ISQL

        NSTEP=${NJOB}_82_CUT
        #--------------------------------
        LIBEL="Take out the last field to have the same format as BEST..TCTRGRO"
        EXECKSH_MODE=P
        EXECKSH "cut -d~ -f 1-20,22 ${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat > ${DFILT}/${NJOB}_82_CUT_${IB}_BSEG_CTRGRO_O.dat"

        #----------------------------------------------------------------------------
        # Execution of the BCP IN TCTRGRO
        #----------------------------------------------------------------------------
        NSTEP=${NJOB}_82
        LIBEL="Beginning of a BCP IN TCTRGRO"
        BCP_WAY=IN
        BCP_VER=""
        BCP_SPECIAL_OPT=""
        BCP_I=${DFILT}/${NJOB}_82_CUT_${IB}_BSEG_CTRGRO_O.dat
        BCP_TABLE="BEST..TCTRGRO"
        BCP
      fi
    fi

    #----------------------------------------------------------------------------
    # Executing ISQL procedure to delete data in the table TSEGEST
    #----------------------------------------------------------------------------
    NSTEP=${NJOB}_85
    LIBEL="Executing ISQL procedure to delete data from the table TSEGEST"
    ISQL_BASE=BEST
    ISQL_QRY="delete BEST..TSEGEST where SSD_CF=${SSD_CF} and VRS_NF=${VRS_NF} and ('${SEGTYP_CT}' = 'A' AND SEGTYP_CT IN ('A', 'V') ) OR ('${SEGTYP_CT}' = 'T' AND SEGTYP_CT IN ('T', 'W')) OR ('${SEGTYP_CT}' = 'U' AND SEGTYP_CT IN ('U', 'X')) OR ('${SEGTYP_CT}' = 'E' AND SEGTYP_CT IN ('E')) OR ('${SEGTYP_CT}'= 'S' AND SEGTYP_CT IN ('S')) "
    ISQL

    #-------------------------------------------------------------------------------------------------
    # Executing ISQL procedure to create and loadind contracts which are not include in the portfolio
    #-------------------------------------------------------------------------------------------------
    NSTEP=${NJOB}_107
    LIBEL="Executing ISQL procedure to create a false segment with unaffected contracts"
    ISQL_BASE="BEST"
    ISQL_QRY="execute PiSEGBA_01 ${SSD_CF},'${SEGTYP_CT}', ${VRS_NF} , 'U' "
    ISQL

    #-------------------------------------------------------------------------------------------------
    # Executing ISQL procedure to create to add the number fo the subsidiary in name of the segment
    #-------------------------------------------------------------------------------------------------
    NSTEP=${NJOB}_108
    LIBEL="add SSD_CF to the name of the segment, insert BEST..TSEGEST / TSEGMENT from BTRAV..EST_ESED0401_TSEGEST"
    ISQL_BASE="BEST"
    ISQL_QRY="execute PuESTSEG_01 ${SSD_CF},'${SEGTYP_CT}', ${VRS_NF},'U' "
    ISQL
  fi
fi

if [ "${SEGTYP_CT}" = "A" -o "${SEGTYP_CT}" = "V" -o "${SEGTYP_CT}" = "S" ]
then
  if [ ${MODE_BATCH} -ne 3 ];then
    NSTEP=${NJOB}_125
    #--------------------------------
    LIBEL="Executing ISQL procedure to fetch segment"
    ISQL_BASE="BEST"
    ISQL_QRY="execute PdVERSION_01 ${SSD_CF},'${SEGTYP_CT}' ,${VRS_NF}, ${MODE_BATCH}, ${SGT_NT}"
    ISQL
  fi
  
#  if [ ${MODE_BATCH} -eq 3 ];then
#    NSTEP=${NJOB}_127
#    #-----------------------------------------------------------------------------
#    LIBEL="SWITCH to infocentre ${SRV_2}"
#    SWITCH_SRV ${SRV_2}
#
#    NSTEP=${NJOB}_128
#    #--------------------------------
#    LIBEL="Extraction of TCTRGRO for controls"
#    BCP_WAY="OUT"
#    BCP_VER="+"
#    BCP_QRY="exec BSAR..PsTCTRGRO_SEG '${SSD_CF}','${SEGTYP_CT}','${SGT_NT}','${VRS_NF}'"
#    BCP_O=${DFILT}/${NSTEP}_${IB}_BSAR_CTRGRO_BCP_O.dat
#    BCP
#  
#	NSTEP=${NJOB}_128A
#	#-----------------------------------------------------------------------------
#	#SORT TCTRGRO on CTR/END/SEC/UWY 
#	#-----------------------------------------------------------------------------
#	LIBEL="SORT TCTRGRO on CTR/END/SEC/UWY "
#	SORT_WDIR=${SORTWORK}
#	SORT_CMD=`CFTMP`
#	SORT_I="${DFILT}/${NJOB}_128_${IB}_BSAR_CTRGRO_BCP_O.dat 1000 1"
#	SORT_O="${DFILT}/${NSTEP}_${IB}_BSAR_CTRGRO_BCP_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS	CTR_NF           1:1 -  1:,
#		END_NT           2:1 -  2: EN,
#		SEC_NF           3:1 -  3:  EN,
#		UWY_NF           22:1 -  22: EN
#/KEYS CTR_NF,
#	  END_NT,
#	  SEC_NF,
#	  UWY_NF
#/OUTFILE ${SORT_O}
#exit
#EOF
#	SORT
#    NSTEP=${NJOB}_128B
#    #-----------------------------------------------------------------------------
#    LIBEL="SWITCH back to default TP ${SRV_DEFAULT}"
#    SWITCH_SRV ${SRV_DEFAULT}
#  fi

  if [[ ${MODE_BATCH} =~ (1|3) ]] && [[ "${SEGTYP_CT}" = "A" || "${SEGTYP_CT}" = "V" ]] #[013]
  then
    #[12]
    NSTEP=${NJOB}_129a
    #-----------------------------------------------------------------------------
    LIBEL="SWITCH to infocentre ${SRV_2}"
    SWITCH_SRV ${SRV_2}

    #[12]
    NSTEP=${NJOB}_129
    #--------------------------------
    LIBEL="Extraction of contrats perimeter for controls"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_QRY="exec BSAR..PsTSEGPOR_SEG ${SSD_CF},'${SEGTYP_CT}', '${TYPEINV}'"
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_SEGPOR_O.dat
    BCP

    NSTEP=${NJOB}_130
    #--------------------------------
    LIBEL="Extract BEST..TSEGMENT for controls" 
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_QRY="select * from BEST..TSEGMENT where SSD_CF=${SSD_CF} and  VRS_NF=${VRS_NF} and SEGTYP_CT='${SEGTYP_CT}'"
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TSEGMENT_O.dat
    BCP

    #[12]
    NSTEP=${NJOB}_131
    #-----------------------------------------------------------------------------
    LIBEL="SWITCH back to default TP ${SRV_DEFAULT}"
    SWITCH_SRV ${SRV_DEFAULT}

    if [[ "${MODE_BATCH}" = "1" ||  "${MODE_BATCH}" = "3" ]];then
	NSTEP=${NJOB}_135
	#-----------------------------------------------------------------------------
	#SORT TCTRGRO on CTR/END/SEC/UWY 
	#-----------------------------------------------------------------------------
	LIBEL="SORT TCTRGRO on CTR/END/SEC/UWY "
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_BSEG_CTRGRO_BCP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF           1:1 -  1:,
		END_NT           2:1 -  2: EN,
		SEC_NF           3:1 -  3:  EN,
		UWY_NF           22:1 -  22: EN
/KEYS CTR_NF,
	  END_NT,
	  SEC_NF,
	  UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
	SORT
fi

    NSTEP=${NJOB}_140
    #--------------------------------
    LIBEL="Generation of a file in BEST..TCTRANO format"
    FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
VRS_NF ${VRS_NF}
exit
EOF
    PRG=ESTC0110
    export ${PRG}_PRM=${FPRM}
    #if [ ${MODE_BATCH} -eq 3 ];then
      #vient de la derniere version de segmentation de la filiale BEST..TSEGMENTATION
    #  export ${PRG}_I1=${DFILT}/${NJOB}_128A_${IB}_BSAR_CTRGRO_BCP_O.dat
    #else # vient de la base segmentation sur l'infocentre
      export ${PRG}_I1=${DFILT}/${NJOB}_135_${IB}_BSEG_CTRGRO_BCP_O.dat
    #fi
    export ${PRG}_I2=${DFILT}/${NJOB}_129_${IB}_BCP_SEGPOR_O.dat
    export ${PRG}_I3=${DFILT}/${NJOB}_130_${IB}_BCP_TSEGMENT_O.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TCTRANO_O.dat
    EXECPRG

     NSTEP=${NJOB}_150
     #--------------------------------
     LIBEL="BCP in BEST..TCTRANO"
     BCP_WAY="IN"
     BCP_VER=""
     BCP_I=${DFILT}/${NJOB}_140_${IB}_ESTC0110_TCTRANO_O.dat
     BCP_TABLE="BEST..TCTRANO"
     BCP

  fi

  NSTEP=${NJOB}_160
  #--------------------------------
  LIBEL="Last controls for segment and contract and update version"
  ISQL_QRY="exec PiCTRGRO_03 ${SSD_CF}, ${VRS_NF}, '${SEGTYP_CT}', ${MODE_BATCH}"
  ISQL_BASE='BEST'
  ISQL
  
  #[15]
  if [ ${MODE_BATCH} -eq 1 ];then
  NSTEP=${NJOB}_155
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="Selection of segment issues"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
  BCP_QRY="if Exists (
                  select 1 from BEST..TSEGANO a
            where a.SSD_CF = ${SSD_CF}
            and   a.VRS_NF = ${VRS_NF}
            and   a.SEGTYP_CT = '${SEGTYP_CT}'
            ) select 'errorfound'
            else
              select 'noerror'"
  BCP 

  if [ `grep -c "errorfound" ${DFILT}/${NJOB}_155_${IB}_SQL_O1.dat` -gt 0 ] 
  then

    #[15]
    JOB_ID='best04a'

     NSTEP=${NJOB}_157
     LIBEL="Error lines detected"
     LOGWRITE 1 '!!!! ERRORS detected !!!!'
     # Call the Tool box function to set the status to 10-Completed with Anomaly
     MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"
     STEPWARNING 10

  fi

  fi


  if [ -s ${DFILT}/${NJOB}_140_${IB}_ESTC0110_TCTRANO_O.dat ] 
  then

    #[15]
    JOB_ID='best04a'

     NSTEP=${NJOB}_190
     LIBEL="Error lines detected"
     LOGWRITE 1 '!!!! ERRORS detected !!!!'
     # Call the Tool box function to set the status to 10-Completed with Anomaly
     MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"
     STEPWARNING 10

  fi

fi

#[19]
if [ ${MODE_BATCH} -eq 3 ];then
NSTEP=${NJOB}_200
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of segment issues"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.dat
BCP_QRY="if Exists (
          select 1 from BEST..TSEGANO a
          where a.SSD_CF = ${SSD_CF}
          and   a.VRS_NF = ${VRS_NF}
          and   a.SEGTYP_CT = '${SEGTYP_CT}'
          ) select 'errorfound'
          else
            select 'noerror'"
BCP 

 if [ `grep -c "errorfound" ${DFILT}/${NJOB}_200_${IB}_SQL_O1.dat` -gt 0 ] 
 then
    JOB_ID='best04a'

     NSTEP=${NJOB}_205
     LIBEL="Error lines detected"
     LOGWRITE 1 '!!!! ERRORS detected !!!!'
     # Call the Tool box function to set the status to 10-Completed with Anomaly
     MAJOB "${JOB_ID}" "${USR_CF}" "${LNCH_DATE_TIME}"
     STEPWARNING 10

 fi

fi

#----------------------------------------------------------------------------
# Removing work files
#RMFIL "${DIBNR}/${FILE_HEADER}_${SSD_CF}${SEGTYP_CT}_*.txt ${DFILT}/${NJOB}_*_${IB}_*.dat"
#----------------------------------------------------------------------------
NSTEP=${NJOB}_500
LIBEL="removing of the text files"
RMFIL "${DIBNR}/${FILE_HEADER}_${SSD_CF}${SEGTYP_CT}_*.txt ${DFILT}/${NJOB}_*_${IB}_*.dat"

JOBEND


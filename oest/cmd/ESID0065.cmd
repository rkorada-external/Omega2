#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Extraction des tables acceptation dommages et
#                                 retrocession
# nom du script SHELL		: ESID0065.cmd
# revision			: $Revision: 1.1.1.1 $
# date de creation		: 26/09/97
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description
#   Extracting tables
#-----------------------------------------------------------------------------
# historique des modifications
#
#  J.Ribot   13/01/03     parametre CLODATMAX_D  a la place de CLODAT_D
#                          appel proc BEST..PiESTACCSUP_02
#
#  J.Ribot   13/03/03     creation fichier EST_FPLATXCUM
#  J.Ribot   15/09/03     creation fichier EST_FCALEND pour DWUD0010 et DWUD0030
#  J.Ribot   18/09/03     creation fichier EST_FACCSUP12
#  J.Ribot   31/03/04     creation fichier EST_FLIFPLN
# M.DJELLOULI       28/04/2005   SPOT  11445 - Renommage Table TESTACCSUP en EST_ESIJ0090_TACCSUP
#                                           Modification STEP 12
#  J. Ribot   23/04/2008  Spot 17266  ajout step 23 tri sur le fichier perimetre pour ne plus perdre les sections > 9 lors
#                                      de la creation des fichiers STATGTAR et STAGTR dans ESID7000
#_________________
#MODIFICATION    [008]
#Auteur:         D.GATIBELZA
#Date:           17/01/2011
#Version:        10.2
#Description:    ESTDOM21224 Périmetre de l'interface pour Madrid ; ne pas filtrer par statut du contrat
#________________
#MODIFICATION
#Auteur:         JF VDV
#Date:           23/05/2012
#Description:    [23390] - SOLVENCY aménagements
#[010] 01/06/2012 R. Cassis           :spot:23802   Ajout parametre @TYPE_CF pour Solvency dans proc Psplacemt_35
#                                         Ajout steps d'extraction des patterns
#[011] 14/08/2012 R. Cassis           :spot:24041  Solvency 2 - Ajout step de recup FLOBSII - Autres..
#[012] 08/08/2013 Florent             :spot:25427  Centralisation des bases (filiales)
#[004] 23/10/2013 Cyrille Despret     :spot:26391  Ajout des fichiers Funds WithHeld (FWH) Acceptation (FWHGTA) et retrocession (FWHGTR)
#[005] 22/04/2014 R. Cassis           :spot:25427  Si periode comptabilisation, clodatmax remplacé par clodat des fichiers Funds WithHeld
#[006] 24/04/2014 R. Cassis           :spot:25427  On prend plutot la clodat_d au lieu de clodatmax_d (qui est vide en periode cpt) pour fichiers FWH..
#[007] 23/10/2015 Florent             :spot:29176 Comptabilité Rétro des PNA
#[008] 16/03/2021 M.NAJI              :SPIRA 91531 commenter la suppression de FACCSUP0
#[009] 26/06/2021 M.NAJI              :SPIRA 97241 forcer EST_ESID0060_COND4 a N  le paramètre des proc et remplacer EST_ESID0060_COND4 de NORME_CF='EBS'
#[010] 26/07/2021 M.NAJI              :SPIRA 97271  supression du test pour creer EST_FWHGTA et EST_FWHGTR  tout les les jours
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctws.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODATMAX_D=$3
CRE_D=$4
PER_CF=$5
CLODAT_D=$6

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BALSHTYEA_NF......: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF......: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CLODATMAX_D.......: ${CLODATMAX_D}"
ECHO_LOG "#===> CRE_D.............: ${CRE_D}"
ECHO_LOG "#===> PER_CF............: ${PER_CF}"
ECHO_LOG "#========================================================================="


# ${EST_ESID0060_COND4} Témoin de sélection des ES EBS SPEENTNAT_CT=4

# Jobs launched if COND3 = N
if [ "${EST_ESID0060_COND3}" = "N" ]
then

  NSTEP=${NJOB}_00
  #Last version of ESID0060 files deletion
  #-----------------------------------------------------------------
  #[008] RMFIL "  `dirname ${EST_FACCSUP0}`/${PCH}ESID0060_FACCSUP0*.dat"
  RMFIL "  `dirname ${EST_FACCSUP12}`/${PCH}ESID0060_FACCSUP12*.dat"

  NSTEP=${NJOB}_05
  # Begin bcp
  # Modif OG 07/11/02, on remplace parametre BALSHY et BALSHMTH par CLODAT
  #------------------------------------------------------------------------------
  LIBEL="Selection of service writings and update of service writings table"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FACCSUP0}
  BCP_QRY="exec BEST..PiESTACCSUP_02 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CLODATMAX_D}','N'" #'${EST_ESID0060_COND4}'"
  BCP

  NSTEP=${NJOB}_07
  # Begin bcp
  # Modif JR 18/09/03, on remplace parametre BALSHMTH par 12
  #------------------------------------------------------------------------------
  LIBEL="Selection of service writings and update of service writings table"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FACCSUP12}
  BCP_QRY="exec BEST..PiESTACCSUP_02 ${BALSHTYEA_NF}, 12, '${BALSHTYEA_NF}1231','N'" # '${EST_ESID0060_COND4}'"
  BCP

  NSTEP=${NJOB}_10
  # Begin bcp
  # Ajout JR 31/03/04, on extrait TLIFPLN pour le plan vie
  #------------------------------------------------------------------------------
  LIBEL="Selection of adjust writings table"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FLIFPLN0}
  BCP_QRY="exec BEST..PsESTLIFPLN_01"
  BCP


  NSTEP=${NJOB}_12
  # Begin isql
  #------------------------------------------------------------------------------
  LIBEL="Working table truncate"
  ISQL_BASE="BEST"
  ISQL_QRY="truncate table BTRAV..EST_ESIJ0090_TACCSUP"
  ISQL

  if [ "${EST_VARIANTE}" = "7"   ]
  then
    JOBEND
  fi

else

  NSTEP=${NJOB}_15
  #Last version of ESID0060 files deletion
  #-----------------------------------------------------------------
  RMFIL "  `dirname ${EST_CRVPERICASE0}`/${PCH}ESID0060_CRVPERICASE0*.dat"
  RMFIL "  `dirname ${EST_CADVPERIESB0}`/${PCH}ESID0060_CADVPERIESB0*.dat"

  NSTEP=${NJOB}_20
  #Generation of CRVPERICASE Perimeter File
  #-----------------------------------------------------------------------------
  LIBEL="Current Generation of IRVPERICASE Perimeter File..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CRVPERICASE0_O.dat
  BCP_QRY="execute BEST..PsSECTION_26 "
  BCP

  NSTEP=${NJOB}_23
  #-----------------------------------------------------------------------------
  LIBEL="Current Sort of IRVPERICASE Perimeter File..."
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_20_${IB}_BCP_CRVPERICASE0_O.dat 1000"
  SORT_O=${EST_CRVPERICASE0}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF
exit
EOF
  SORT

#[008]
fi

#[005] [006] (010]
#if [ ${EST_ESID0060_COND3} = "Y" -o ${EST_ESID0060_COND4} = "Y" ]
#if [ ${EST_ESID0060_COND3} = "Y" -o ${NORME_CF} = "EBS" ]
#then
#faire le fichier de depot#[004]
  NSTEP=${NJOB}_25
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="Acceptation Funds Held..."
  CP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FWHGTA}
  BCP_QRY="exec BEST..PsACCTRN_FWH_01 '${CLODAT_D}'"
  BCP
  
  #[004]
  NSTEP=${NJOB}_26
  #Begin isql
  #-----------------------------------------------------------------------------
  IBEL="Retrocession Funds Held..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FWHGTR}
  BCP_QRY="exec BEST..PsRACCTRN_FWH_01 '${CLODAT_D}'"
  BCP
#fi


#[008] supprimmer les conditions sur les traites/fac ( utiliser le même périmetre pour le MGTAR ( 2560 ) //          where ctrsts_ct in ( 14, 16, 17, 19)
#[008] ajouter un select sur TSECTION_DEL où la clé n'existe pas déjà dans BFAC..TCONTR
NSTEP=${NJOB}_29
#Generation of CADVPERIESB0 File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of CADVPERIESB0 Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$DFILT/${NSTEP}_${IB}_CADVPERIESB0_O.dat"
BCP_QRY="select ctr_nf,end_nt,uwy_nf,uw_nt,accesb_cf
 from BFAC..TCONTR a, BREF..TBATCHSSD c
  where a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()

select a.ctr_nf,a.end_nt,a.uwy_nf,a.uw_nt,a.accesb_cf
 from BFAC..TSECTION_DEL a, BREF..TBATCHSSD c
  where not exists(select 1 from BFAC..TCONTR b where b.ctr_nf=a.ctr_nf and b.end_nt=a.end_nt and b.uwy_nf=a.uwy_nf and b.uw_nt=a.uw_nt)
    and a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()

select ctr_nf,end_nt,uwy_nf,uw_nt,accesb_cf
 from btrt..tcontr a, BREF..TBATCHSSD c
  where a.SSD_CF=c.SSD_CF
    and c.BATCHUSER_CF=suser_name()"
BCP

NSTEP=${NJOB}_30
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of CADVPERIESB0 -> EST_CADVPERIESB0 perimeter file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_29_${IB}_CADVPERIESB0_O.dat"
SORT_O="${EST_CADVPERIESB0}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        UW_NT  4:1 - 4:
/KEYS CTR_NF, END_NT, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_35
#-----------------------------------------------------------------
LIBEL="delete of files CADVPERIESB0"
RMFIL "${DFILT}/${NJOB}_29_${IB}_CADVPERIESB0_O.dat"

#[008]fi

NSTEP=${NJOB}_40
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="cumul placements"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FPLATXCUM0}"
BCP_QRY="execute BRET..PsPLACEMT_35"
BCP

NSTEP=${NJOB}_45
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the END quarter month processed"
ISQL_BASE="BREF"
ISQL_QRY="execute BREF..PsCALEND_03"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
ISQL_FRES="${EST_FCALEND}"
ISQL_NOWARNING="YES"
ISQL_RES

#[010]
NSTEP=${NJOB}_50
# Begin BCP OUT
#------------------------------------------------------------------------------
LIBEL="cumul placements"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EST_FPLATXCUMALL0}"
BCP_QRY="execute BRET..PsPLACEMT_35 'ALL'"
BCP

#if [ "${EST_ESID0060_COND3}" = "N" -o "${EST_ESID0060_COND4}" = "Y" ]
if [ ${EST_ESID0060_COND3} = "Y" -o ${NORME_CF} = "EBS" ]
then

  # [23390] - ajout
  NSTEP=${NJOB}_55
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FCURSII File..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FCURSII}
  BCP_QRY="exec BEST..PsFCURSII_01 '${CLODATMAX_D}'"
  BCP

  # [23390] - ajout
  NSTEP=${NJOB}_60
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FRATINGSII File..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FRATINGRTO}
  BCP_QRY="exec BEST..PsFRATINGRTO_01"
  BCP

  #[010]
  NSTEP=${NJOB}_65
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FSEGPATTERN File for BDT..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FSEGPATTERN_BDT}
  BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'BDT', ${BALSHTYEA_NF}, '${PER_CF}', '${CLODATMAX_D}'"
  BCP

  #[010]
  NSTEP=${NJOB}_70
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FSEGPATTERN File for CSF..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FSEGPATTERN_CSF}
  BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'CSF', ${BALSHTYEA_NF}, '${PER_CF}', '${CLODATMAX_D}'"
  BCP

  #[010]
  NSTEP=${NJOB}_75
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FSEGPATTERN File for ICR..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FSEGPATTERN_ICR}
  BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'ICR', ${BALSHTYEA_NF}, '${PER_CF}', '${CLODATMAX_D}'"
  BCP


  #[010]
  NSTEP=${NJOB}_80
  #Begin isql
  #-----------------------------------------------------------------------------
  LIBEL="SOLVENCY Generation of FSEGPATTERN File for DSC..."
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${EST_FSEGPATTERN_DSC}
  BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'DSC', ${BALSHTYEA_NF}, '${PER_CF}', '${CLODATMAX_D}'"
  BCP

fi

#[011]
CRE_D2=`date '+%Y%m%d %H:%M:%S'`

NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Get the LOB SII file for DSI"
BCP_WAY="OUT"; BCP_VER="+"
BCP_QRY="exec BEST..PsFLOBSII_01 '${CRE_D2}'"
BCP_O=${DFILP}/${ENV_PREFIX}_ESID0831_EST_FLOBSII.dat
BCP

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Extraction des Anomalies des PNA"
BCP_WAY="OUT"; BCP_VER="+"
BCP_QRY="execute BEST..PsACCRET_01 '${CLODAT_D}',1"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PNA_ANO_O1.dat
BCP

#Fichier pour le journal - diary
if [ -s ${DFILT}/${NJOB}_100_${IB}_BCP_PNA_ANO_O1.dat ]; then
  # Read the data file from the previous step line by line and call the web service.
  NUM_ANO=0
  cat ${DFILT}/${NJOB}_100_${IB}_BCP_PNA_ANO_O1.dat | while read line
  do
    NUM_ANO=$(expr ${NUM_ANO} + 1)
    NSTEP=${NJOB}_110_${NUM_ANO}

    OBJECT_ID=`echo $line | awk -F"~" '{print $1}'`
    NOTIFTYP_NT=`echo $line | awk -F~ '{print $2}'`
    USR_CF=`echo $line | awk -F~ '{print $3}'`
    NOTIFCONTEXT_LL=`echo $line | awk -F~ '{print $4}'`

    WS_STATUS_MSG="OBJECT_ID=${OBJECT_ID}, NOTIFTYP_NT=${NOTIFTYP_NT}, USR_CF=${USR_CF}, NOTIFCONTEXT_LL=${NOTIFCONTEXT_LL}"
    LIBEL="Calling Web service for diary with ${WS_STATUS_MSG}" 
  
    WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
    WS_BATCH_NAME=RFRJ1030
    STEPEND_CONTINUE="YES"
    WARNING="YES"
    WS_PARAMS_TEXT << EOF
OBJECT_ID ${OBJECT_ID}
NOTIFTYP_NT ${NOTIFTYP_NT}
USR_CF ${USR_CF}
EOF
    WS_BATCH
    # Capture the return value from the web service.
    WS_STATUS=$?
    if [ ${WS_STATUS} != 0 ]
    then
      echo "WARNING! ${NJOB} returned ${WS_STATUS} for ${WS_STATUS_MSG}" >> ${DFILT}/${NSTEP}_${IB}.wng
    fi
  done
fi

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Extraction des PNA"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_RETPNAGTR}
BCP_QRY="execute BEST..PsACCRET_01 '${CLODAT_D}',0"
BCP


NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="Extraction des LOGS PNARETRO"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_PNARETRO}
BCP_QRY="execute BEST..PsACCRET_01 '${CLODAT_D}',0,1"
BCP



JOBEND

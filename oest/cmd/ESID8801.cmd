#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                  injection des GTA et GTR dans l'infocentre
# nom du script SHELL            : ESID8801.cmd
# revision                       : $Revision: 1.5 $
# date de creation               : 02/10/97
# auteur                         : C.G.I.
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#   Injection of the Acceptance and Retrocession TL files into the infocenter
#
# Input files
#       EST_FTECLEDA               DFILP
#       EST_FTECLEDR               DFILP
#
# Output files
#
#
# launched by ESID8800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#	- modifs du 13/03/98 suite a l'evol "analyse du GT en infocentre" effectuees
# par M.HA-THUC
#
#	- Modifs du 23/09/98 suite � l'evol du parametrege des tables TTECLEDA et TTECLEDR
#
# - Modifs du 01/04/03 J. Ribot
#    ajout gestion du 2�me index TTECLEDA
#    DROP des 2 index table TTECLEDA et recreation des 2 index
#       dont le 1er en CLUSTERED INDEX
#    modif du .env  {  export BCPIN_SPECIAL_OPT_CHAIN="-b50000"  }
#
# - Modif du 12/02/2004 M. DJELLOULI
#    STEP 15 : On ajoute le test sur RETINTAMT_M <> 0
#
# - Modif du 26/03/2004   Roger Cassis
#    STEPs 85-90 Ajout gestion de l'ouverture de l'Infocentre mondial
#--------------
# MODIFICATION   : [006]
# Auteur         : D.GATIBELZA
# Date           : 08/09/2008
# Version        : 8.1
# Description    : ESTDOM16005 ajout d'un index sur ttecled dans job esid8900
#--------------
# MODIFICATION   : [007]
# Auteur         : D.GATIBELZA
# Date           : 17/09/2008
# Version        : 8.1
# Description    : ESTDOM16061 cr�ation index ITECLEDA_E_03 sur TTECLEDA
#-------------
#  J.Ribot       [008]  19/05/2009 SPOT17420 ajout DBLTRNCOD_CF cumul TTECLEDA TTECLEDR
#--------------
# MODIFICATION   : [009]
# Auteur         : D.GATIBELZA
# Date           : 04/02/2010
# Version        : 9.1
# Description    : ESTDOM13711 Avoir dans le GLT les montants r�tro interne par filiale
#---------------
#MODIFICATION   : [DOMDOMDOMDOM !!!!!]
#Auteur         : D.GATIBELZA
#Date           : 07/02/2011
#Version        : 11.1
#Description    : 1GL   temporaire, � retirer apr�s le changement de MPD !!
#[010]  15/03/2011  R. CASSIS     :spot:21408 - On ajoute colonne ZZRECONKEY_CF, on supprime le 1er tri qui est fait dans le ESID8700
#                                               On ne fait plus le dernier step qui met a jour le RTO_nf.
#[011] 12/09/2013 Florent    :spot:25427 Closing batches adaptation for centralization, maj step 70 et 45
#[012] 22/04/2014 R. Cassis  :spot:25427  - Modifications pour omega2 -1b Suppression appel aux procs OSW
#[013] 24/03/2016 R. Cassis  :spot:29066  - Modification fichier GT - ajout de colonnes dans la cl� du tri
#[014] 23/01/2017 R. Cassis  :spot:xxxxx Ajout modification du DWUJ0530.prm
#[015] 03/03/2017 Florent    :spira:59607 - ajout filiale dans le tri de TTECLEDA et R
#[016] 07/04/2017 R. Cassis  :spira:59651 Toutes les tables gerees par DWUJ0530 sont optionnelles dans le prm.
#[017] 14/01/2020 S. Behague :spira:81819 Apolo QE: feeding of SCOSTRMTH_NF and SCOENDMTH_NF in TTECLEDA
#[018] 05/10/2021 L. Doan    :spira:91532 - reverse desactivate ESID8800
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TTECLEDA table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDA', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDA results is
TECLEDA=`cat ${ISQL_FRES} | sed -e s/\ //g`
TTECLEDA=T${TECLEDA}

if [ "${PARM_IS_PARALLEL_RUN}" = "Y" ]
then
        ECHO_LOG "TTECLED*  are loaded by DBLOAD. Ending Job..."
        JOBEND
fi


NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Determination of the TTECLEDR table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDR', '${CLODAT_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDR results is
TECLEDR=`cat ${ISQL_FRES} | sed -e s/\ //g`
TTECLEDR=T${TECLEDR}

NSTEP=${NJOB}_13
#--------------------------------
LIBEL="Separate Yearly Quarterly"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_OY.dat 1000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_OQ.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESTCRB_CT       75:1 -  75:
/CONDITION ESTCRB ESTCRB_CT EQ "T" OR ESTCRB_CT EQ "U"
/OUTFILE ${SORT_O}
/OMIT ESTCRB
/OUTFILE ${SORT_O1}
/INCLUDE ESTCRB
exit
EOF
SORT

#[013]
NSTEP=${NJOB}_15
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_13_${IB}_SORT_TECLEDA_OY.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_OY.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 15/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
	RETINTAMT_M      88:1 -  88:EN 15/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) and BALSHEY_NF > 0
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M , TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_20
# Sort of the FTECLEDA File on TTECLEDA_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDA File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_OY.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_13_${IB}_SORT_TECLEDA_OQ.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_OTHERS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
	ESB_CF 2:1 - 2: EN,
	TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O2}
/OMIT INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_25
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_O.dat

#[013]
NSTEP=${NJOB}_30
# summarize TTECLEDR by BALSHTDAY, BALSHTMTH
#-------------------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	DBLTRNCOD_CF      7:1 -  7:,
	RETCTR_NF        24:1 - 24:,
	RETEND_NT        25:1 - 25:,
	RETSEC_NF        26:1 - 26:,
	RTY_NF           27:1 - 27:,
	RETUW_NT         28:1 - 28:,
	RETOCCYEA_NF     29:1 - 29:EN,
	RETACY_NF        30:1 - 30:EN,
	RETSCOSTRMTH_NF  31:1 - 31:EN,
	RETSCOENDMTH_NF  32:1 - 32:EN,
	RETCUR_CF        34:1 - 34:,
	RETAMT_M         35:1 - 35:EN 15/3,
	PLC_NT           36:1 - 36:,
	RTO_NF           37:1 - 37:,
	TRN_NT           56:1 - 56:,
	ORICOD_LS        57:1 - 57:,
	RETROAUTO_B      58:1 - 58:,
	SPEENTNAT_CT     59:1 - 59:,
	EVT_NF           60:1 - 60:,
	REVT_NF          61:1 - 61:,
	RETARDRETINT_B   62:1 - 62:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION RETAMT_M NE 0
/SUMMARIZE  TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_35
# Sort of the FTECLEDR File on TTECLEDR_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_TECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
	ESB_CF 2:1 - 2: EN,
	TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_40
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_TECLEDR_O.dat

NSTEP=${NJOB}_45
# filling TTECLEDA table
#--------------------------------
LIBEL="filling ${TTECLEDA} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDA}"
BCP

NSTEP=${NJOB}_50
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDA', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_55
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA_O.dat

NSTEP=${NJOB}_60
#--------------------------------
LIBEL="filling ${TTECLEDR} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_35_${IB}_SORT_FTECLEDR_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDR}"
BCP

NSTEP=${NJOB}_65
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDR', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

#[010]
##------------------------------------------------------------------------------
##[009]
#NSTEP=${NJOB}_100
## Mise � jour TTECLEDA
##------------------------------------------------------------------------------
#LIBEL="Update on BSAR..${TTECLEDA}"
#ISQL_QRY=`CFTMP`
#ISQL_BASE=BSAR
#ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
#INPUT_TEXT ${ISQL_QRY} <<EOF
#USE BSAR
#go
#update BSAR..${TTECLEDA}
#   set RTO_NF = b.RTO_NF
#from BSAR..${TTECLEDA} a, BRET..TPLACEMT b
#where a.RETCTR_NF = b.RETCTR_NF
#  and a.RETRTY_NF = b.RTY_NF
#  and a.PLC_NT    = b.PLC_NT
#  and b.HIS_B     = 0
#exit
#EOF
#ISQL

#[014]
if [ -f ${DPRM}/DWUJ0530.prm ]; then
	
	LETTER_IFRS=`echo ${TTECLEDA} | cut -d_ -f2`

	ECHO_LOG "#=============================================================================="
	ECHO_LOG "#===> CLODAT_D ........: ${CLODAT_D}"
	ECHO_LOG "#===> LETTER_IFRS .....: ${LETTER_IFRS}"
	ECHO_LOG "#=============================================================================="

	NSTEP=${NJOB}_100
	#-----------------------------------------------------------------------------
	LIBEL="Update DWUJ0530.prm"
	AWK_I=${DPRM}/DWUJ0530.prm
	AWK_O=${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat
	AWK_PARAM=" -v srv=SRV_TABLES -v dateSrv=${CLODAT_D} -v ifrs=LETTER_IFRS -v letterIfrs=${LETTER_IFRS} "
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
			{
				split(\$0,tab," ");
				if (tab[1] == srv)
				{
					split(tab[2],tab2,"|");
					\$0 = srv " " tab2[1] "|" dateSrv "|" tab2[3];
				}
				if (tab[1] == ifrs)
				{
					split(tab[2],tab2,"|");
					\$0 = ifrs " " letterIfrs "|" tab2[2];
				}
				print \$0;
			}
	exit
EOF
	AWK

	gzip -c ${DPRM}/DWUJ0530.prm > ${DFILT}/${NCHAIN}_${IB}_DWUJ0530prm.dat.gz
	gzip -c ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat > ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat.gz
	
	NSTEP=${NJOB}_110
	# copie fichiers
	#------------------------------------------------------------------------------
	LIBEL="move ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat to ${DPRM}/DWUJ0530.prm"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat ${DPRM}/DWUJ0530.prm"
	
fi


#########################
# Erase temporary files #
# [009] Step 95 -> 110
#########################
NSTEP=${NJOB}_120
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

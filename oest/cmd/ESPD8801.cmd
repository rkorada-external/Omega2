#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 injection des GTA et GTR dans l'infocentre
#                                   ( ecritures post omega)
# nom du script SHELL		: ESPD8801.cmd
# revision			: $Revision: 1.4 $
# date de creation		: 02/10/97
# auteur			: C.G.I.
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Injection of the Acceptance and Retrocession TL files into the infocenter
#
# Input files
#       EPO_FTECLEDASO               DFILP
#       EPO_FTECLEDRSO               DFILP
#
# Output files
#
#
# launched by ESID8800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#_________________
#[001] 24/09/2008 D.GATIBELZA ESTDOM16100 création index ITECLEDA_E_03 et ITECLEDA_E_02 sur TTECLEDA dans ESPD8800
#[002] 19/05/2009 J.Ribot     SPOT17420 ajout DBLTRNCOD_CF cumul TTECLEDA TTECLEDR
#[003] 27/04/2011 D.GATIBELZA ESTDOM21408 OneLedger - :spot:21408
#[004] 20/10/2011 R. Cassis  :spot:22752 - Recup dates en parametre et ajout steps de maj tbopar
#[005] 22/12/2012 R. Cassis  :spot:22859 - Ajout cre_d dans cle de tri-somme tecleda.
#[006] 24/07/2012 R. Cassis  :spot:23802 - Solvency
#[007] 29/10/2012 R. Cassis  :spot:24041 - Solvency
#[008] 12/09/2013 Florent    :spot:25427 Closing batches adaptation for centralization, maj step 45,70
#[009] 24/03/2016 R. Cassis  :spot:29066  - Modification fichier GT - ajout de colonnes dans la clé du tri
#[010] 03/03/2017 Florent    :spira:59607  - ajout filiale dans le tri de TTECLEDA et R
#[010] 23/01/2017 R. Cassis  :spira:59651 Ajout modification du DWUJ0530.prm
#[011] 03/12/2019 SPIRA 81496: Roger/JYP:  Mise a jour de l'etablissement dans FTECLEDASO sur FTECLEDASO_EBS a partir de Pericase
#[012] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#[002]
# Get input parameters
SUFFTABLE=$1
CRE_D=$2
INVCONSO_D=$3
CONSOYEA=$4
CONSOMTH=$5
NORME=$6

# Job Initialisation
JOBINIT

TTECLEDA=TTECLEDA_${SUFFTABLE}
TTECLEDR=TTECLEDR_${SUFFTABLE}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME..............: ${NORME}"
ECHO_LOG "#===> TTECLEDA...........: ${TTECLEDA}"
ECHO_LOG "#===> EPO_FTECLEDASO_EBS...........: ${EPO_FTECLEDASO_EBS}"
ECHO_LOG "#===> EPO_FTECLEDASO...........: ${EPO_FTECLEDASO}"
ECHO_LOG "#===> TTECLEDR...........: ${TTECLEDR}"
ECHO_LOG "#========================================================================="

#[003]
#[005]
#[006]
#[009]
NSTEP=${NJOB}_15
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${NORME}" = "EBS" ]
then
SORT_I="${EPO_FTECLEDASO_EBS} 1000 1"
else
SORT_I="${EPO_FTECLEDASO} 1000 1"
fi

if [ "${NORME}" = "EBS" ]
then
	SORT_I2="${EPO_FTECLEDASIISO} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_O.dat 1000 1"
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
  CRE_D            41:1 -  41:,
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
  CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
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
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_23
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_TECLEDA_O.dat

#[006]
#[009]
NSTEP=${NJOB}_25
#-------------------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDRSO} 1000 1"
if [ "${NORME}" = "EBS" ]
then
	SORT_I2="${EPO_FTECLEDRSIISO} 1000 1"
fi
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
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_30
# Sort of the FTECLEDR File on TTECLEDR_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_TECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_33
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_TECLEDR_O.dat

NSTEP=${NJOB}_45
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

#[004]
NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDA', '${INVCONSO_D}',
		${CONSOYEA}, ${CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_58
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA_O.dat

NSTEP=${NJOB}_70
# filling TTECLEDR table
#--------------------------------
LIBEL="filling ${TTECLEDR} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDR_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDR}"
BCP

#[004]
NSTEP=${NJOB}_80
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDR', '${INVCONSO_D}',
		${CONSOYEA}, ${CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

#[010]
if [ -f ${DPRM}/DWUJ0530.prm ]; then
	
	LETTER_POST=${SUFFTABLE}

	ECHO_LOG "#=============================================================================="
	ECHO_LOG "#===> LETTER_POST .....: ${LETTER_POST}"
	ECHO_LOG "#=============================================================================="

	NSTEP=${NJOB}_90
	#-----------------------------------------------------------------------------
	LIBEL="Update DWUJ0530.prm for LETTER_POST = ${LETTER_POST}"
	AWK_I=${DPRM}/DWUJ0530.prm
	AWK_O=${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat
	AWK_PARAM=" -v post=LETTER_POST -v letterPost=${LETTER_POST} "
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
			{
				split(\$0,tab," ");
				if (tab[1] == post)
				{
					split(tab[2],tab2,"|");
					\$0 = post " " letterPost "|" tab2[2];
				}
				print \$0;
			}
	exit
EOF
	AWK

	gzip -c ${DPRM}/DWUJ0530.prm > ${DFILT}/${NCHAIN}_${IB}_DWUJ0530prm.dat.gz
	gzip -c ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat > ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat.gz
	
	NSTEP=${NJOB}_100
	# copie fichiers
	#------------------------------------------------------------------------------
	LIBEL="move ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat to ${DPRM}/DWUJ0530.prm"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${NCHAIN}_${IB}_DWUJ0530.dat ${DPRM}/DWUJ0530.prm"
	
fi


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_110
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                  Injection des resultats des calculs solvency et IFRS17 dans l'infocentre
# nom du script SHELL            : ESFD8601.cmd
# revision                       : $Revision: 1.0 $
# date de creation               : 22/11/2019
# auteur                         : L. DOAN
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   :spira:77079 Injection of the Acceptance and Retrocession TL files into the infocenter
#   :spira:77663 Injection of cashflow files into the infocenter
#   :spira:82684 Optimization of RA generation 		
#    
#
# Input files : ESB and IFRS17
#       ESF_FTECLEDSII                 DFILP
#       EPO_FTECLEDSII		       DFILP	
#       ESF_FTECLEDA                   DFILP
#       EPO_FTECLEDA		       DFILP
#       ESF_FTECLEDR                   DFILP	 
#       EPO_FTECLEDR		       DFILP
#			
# Output files
#
# launched by ESFD8600.cmd 
#
#-----------------------------------------------------------------------------
#[002] 31/07/2012 -=Dch=-   :spot:24041 remplacement de TECLEDA par TECLEDASII
#[003] 29/01/2013 R. Cassis :spot:24659 Suppression donnees avec commit pour gestion syslog sybase
#[004] 13/08/2013 P. Coppin :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
#[005] 30/10/2013 Florent   :spot:25726  Maj pour prendre en compte l'existence d'une autre clodat_d dans TTECLEDSII
#[006] 16/05/2014 Roger     :spot:26778  Correction requete d'extraction des donn�es EBS
#[007] 26/11/2014 Roger     :spot:27857  Correct sql query to select a.*
#[008] 23/09/2015 Philippe  :spot:28941 
#[009] 07/06/2016 Roger     :spot:30713  Archivage fichier POCE
#[010] 12/08/2016 Roger     :spot:31046  Fiabilise le chargement de la table en cas de reprise
#[011] 06/10/2016 Roger     :spot:31302  Gestion fichiers GTSII_RISKMARGINCO et GTSII_RISKMARGINSO
#[012] 19/12/2016 Roger     :spot:21263  correction affectation du fichier POC
#[013] 17/04/2019 Linh      :spira:77663 Upload TTECLEDSII IFRS17 to infocenter : adapted from ESID8601.cmd
#[014] 22/11/2019 Linh      :spira:77079 Upload TTECLEDA/R IFRS17 to infocenter only on DEV, ITK and CNV
#[015] 02/05/2020 Linh      :spira:82684 Slit of upload TTECLEDA/R
#[016] 28/05/2020 Linh      :spira:85741: add RISKMARGIN 
#[017] 28/05/2020 Linh      :spira:87121: add CSM LC
#[018] 19/09/2020 Linh      :spira:83014: remove CSM LC 
#[019] 17/12/2020 Linh      :spira:91994: Local - IFRS17L/IFRS1P Omega/RA  interface
#[019] 20/01/2021 Linh      :spira:91531: Fix param
#[020] 20/01/2021 Linh      :spira:91531: Fix ITK server for Azure
#[021] 26/03/2021 Linh      :spira:91531: remove EST_FTECLEDA[R]CO_ANNULMVT
#[022] 30/04/2021 Linh 	    :spira:96040: remove doublon AE Life IFRS17
#[023] 03/05/2021 S.Behague :spira:93345: I17 : RETRO - Life SAP posting - Copy + Suite remove Linh, on enl�ve aussi I6 du step 60
#[021] 26/05/2021 Linh      :spira:91531: truncate  SEG_NF
#[022] 22/06/2021 L. DOAN   :spira:97241: parallel closing
#[023] 05/11/2021 B. LAGHA  :spira:91532: Add {IN2,INT,MAI} to the consition of filling  TTECLEDA and TTECLEDR tables.
#[024] 11/06/2025 MZM       :spira:111672: Add Filter on SSD on  TTECLEDSII step _20
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters

CRE_D=${PARM_CRE_D}
BALSHTYEA_NF=${PARM_BALSHTYEA_NF}
BALSHTMTH_NF=${PARM_BALSHTMTH_NF}
SUFFTABLE=${PARM_SUFFTABLE}
#PER_CF=${TYPEINV}

CLODAT_D=${PARM_ICLODAT_D}
INVCONSO_D=${PARM_INVCONSO_D}
EST_FTECLEDSII=${EPO_FTECLEDSII}
EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGIN}

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV.............: ${TYPEINV}"
ECHO_LOG "#===> CLODAT_D............: ${CLODAT_D}"
ECHO_LOG "#===> INVCONSO_D..........: ${INVCONSO_D}"
ECHO_LOG "#===> SUFFTABLE...........: ${SUFFTABLE}"
ECHO_LOG "#===> BALSHTYEA_NF........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CRE_D...............: ${CRE_D}"
ECHO_LOG "#========================================================================="

TTECLEDSII=TTECLEDSII_${SUFFTABLE}
TTECLEDA=TTECLEDA_${SUFFTABLE}
TTECLEDR=TTECLEDR_${SUFFTABLE}

ECHO_LOG ""
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> EPO_FTECLEDSII.........: ${EPO_FTECLEDSII}"
#ECHO_LOG "#===> EPO_GTSII_RISKMARGINSO: ${EPO_GTSII_RISKMARGINSO}"
#ECHO_LOG "#===> EPO_FTECLEDSIICO......: ${EPO_FTECLEDSIICO}"
#ECHO_LOG "#===> EPO_GTSII_RISKMARGINCO: ${EPO_GTSII_RISKMARGINCO}"
#ECHO_LOG "#===> EPO_GTSII_RISKMARGIN..: ${EPO_GTSII_RISKMARGIN}"

ECHO_LOG "#===> EST_FTECLEDA........: ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_FTECLEDR........: ${EST_FTECLEDR}"
ECHO_LOG "#===> TTECLEDA_I17G............: ${TTECLEDA_I17G}"
ECHO_LOG "#===> TTECLEDR_I17G............: ${TTECLEDR_I17G}"
ECHO_LOG "#===> TTECLEDA_I17L............: ${TTECLEDA_I17L}"
ECHO_LOG "#===> TTECLEDR_I17L............: ${TTECLEDR_I17L}"
ECHO_LOG "#===> TTECLEDA_I17P............: ${TTECLEDA_I17P}"
ECHO_LOG "#===> TTECLEDR_I17P............: ${TTECLEDR_I17P}"
ECHO_LOG "#===> TTECLEDA_I17S............: ${TTECLEDA_I17S}"
ECHO_LOG "#===> TTECLEDR_I17S............: ${TTECLEDR_I17S}"

ECHO_LOG "#===> TTECLEDSII..........: ${TTECLEDSII}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17G......: ${ESF_FTECLEDSII_I17G}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17L......: ${ESF_FTECLEDSII_I17L}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17P......: ${ESF_FTECLEDSII_I17P}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17s......: ${ESF_FTECLEDSII_I17S}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_5
LIBEL="MANAGE UNFOUND FILES " 

if [ ! -f "${EPO_FTECLEDSII}" ]
then
    EXECKSH "touch ${EPO_FTECLEDSII}"
fi


if [ ! -f "${EST_FTECLEDA}" ]
then
    EXECKSH "touch ${EST_FTECLEDA}"
fi

if [ ! -f "${EST_FTECLEDR}" ]
then
    EXECKSH "touch ${EST_FTECLEDR}"
fi


if [ ! -f "${EST_FTECLEDASII}" ]
then
    EXECKSH "touch ${EST_FTECLEDASII}"
fi

if [ ! -f "${EST_FTECLEDRSII}" ]
then
    EXECKSH "touch ${EST_FTECLEDRSII}"
fi


if [ ! -f "${EPO_GTSII_RISKMARGIN}" ]
then
    EXECKSH "touch ${EPO_GTSII_RISKMARGIN}"
fi


if [ ! -f "${ESF_FTECLEDSII_I17G}" ]
then
    EXECKSH "touch ${ESF_FTECLEDSII_I17G}"
fi

if [ ! -f "${ESF_FTECLEDSII_I17S}" ]
then
    EXECKSH "touch ${ESF_FTECLEDSII_I17S}"
fi

if [ ! -f "${ESF_FTECLEDSII_I17P}" ]
then
    EXECKSH "touch ${ESF_FTECLEDSII_I17P}"
fi

if [ ! -f "${ESF_FTECLEDSII_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDSII_I17L}"
fi


if [ ! -f "${ESF_FTECLEDA_I17G}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17G}"
fi

if [ ! -f "${ESF_FTECLEDA_I17S}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17S}"
fi

if [ ! -f "${ESF_FTECLEDA_I17P}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17P}"
fi

if [ ! -f "${ESF_FTECLEDA_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17L}"
fi


if [ ! -f "${ESF_FTECLEDR_I17G}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17G}"
fi

if [ ! -f "${ESF_FTECLEDR_I17S}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17S}"
fi

if [ ! -f "${ESF_FTECLEDR_I17P}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17P}"
fi

if [ ! -f "${ESF_FTECLEDR_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17L}"
fi




load=n
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="touch ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"

export EST_FTECLEDSII="${DFILP}/empty.dat"

if [ "${TYPEINV}" != "INV" ]
then
	#[012]
	trim=`head -1 ${EPO_FTECLEDSII} | cut -d~ -f3`

	# On recharge SO et CO si le trimestre des fichiers est celui trait�
	if [ "${trim}" = "${INVCONSO_D}" ]
	then
		
        	export EST_FTECLEDSII=${EPO_FTECLEDSII}
		load=y
		
	fi
else
		export EST_FTECLEDSII=${EPO_FTECLEDSII}
		load=y
fi

if [ -s  ${ESF_FTECLEDSII} ]
then
    	load=y
fi

if [ "${load}" = "n" ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Pas de fichier � charger car pas de donn�es pour ${INVCONSO_D} - Arret"
	ECHO_LOG "#========================================================================="
	JOBEND
fi


NSTEP=${NJOB}_15

LIBEL="Merge TECLESSII_T from EBS and IFRS17 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDSII_I17S} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TTECLEDSII_T.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_TTECLEDSII_T_OTHERS.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN
/KEYS 	CTR_NF,
	END_NT,  
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O2}
/OMIT INVENTAIRE

exit
EOF
SORT    

##[024]

NSTEP=${NJOB}_20

LIBEL="Merge TECLESSII from EBS and IFRS17 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDSII_I17G} 2000 1"
SORT_I2="${ESF_FTECLEDSII_I17L} 2000 1"
SORT_I3="${ESF_FTECLEDSII_I17P} 2000 1"
SORT_I4="${EST_FTECLEDSII} 2000 1"
SORT_I5="${EPO_GTSII_RISKMARGIN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}_OTHERS.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN
/KEYS 	CTR_NF,
	END_NT,  
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O2}
/OMIT INVENTAIRE

exit
EOF
SORT    
    

NSTEP=${NJOB}_21
#-----------------------------------------------------------------------------
LIBEL="TRUNCATE SEG_NF"
AWK_I=${DFILT}/${NJOB}_20_${IB}_${TTECLEDSII}.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       {  if ( length(\$25) > 10 ) \$25 = substr(\$25,1,10);
          print \$0
       }
exit
EOF
AWK

NSTEP=${NJOB}_23
#-----------------------------------------------------------------------------
LIBEL="TRUNCATE SEG_NF for I17S"
AWK_I=${DFILT}/${NJOB}_15_${IB}_TTECLEDSII_T.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_TTECLEDSII_T.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       {  if ( length(\$25) > 10 ) \$25 = substr(\$25,1,10);
          print \$0
       }
exit
EOF
AWK


NSTEP=${NJOB}_25
# Switch to infocentre server ${SRV_2}
# ${SRV_2} is already defined in the environnement file
#--------------------------------------------------------------------------
LIBEL="Switch to infocentre server ${SRV_2}"
SWITCH_SRV ${SRV_2}


NSTEP=${NJOB}_30
#--------------------------------
LIBEL="BCP in ${TTECLEDSII} table"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_RMINFILE=NO
BCP_I=${DFILT}/${NJOB}_21_${IB}_${TTECLEDSII}.dat
BCP_TABLE="BSAR..${TTECLEDSII}"
BCP


NSTEP=${NJOB}_35
#--------------------------------
LIBEL="BCP in TTECLEDSII_T table for I17S data"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_RMINFILE=NO
BCP_I=${DFILT}/${NJOB}_23_${IB}_TTECLEDSII_T.dat
BCP_TABLE="BSAR..TTECLEDSII_T"
BCP


NSTEP=${NJOB}_50

##------------------------------------------------------------------------------
#LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDSII','${CLODAT_D}',${BALSHTYEA_NF},${BALSHTMTH_NF},'${CRE_D}','CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL


if [ "${load}" = "y" ]
then
	gzip -c ${DFILT}/${NJOB}_20_${IB}_${TTECLEDSII}.dat > ${DARCH}/${ENV_PREFIX}_ESFD8600_FTECLEDSII_${INVCONSO_D}_${CRE_D}.dat.gz
fi



########################################################################################################################
#Addition steps to fill TTECLEDA and TTECLEDR tables
########################################################################################################################


#if [[ "${SRV_2}" =~ (DEV|CN2|ITK|CNV|UAT|IN2|MAI|INT)_DWO2 ]]; then
#        echo "Next step : filling  TTECLEDA and TTECLEDR tables"  2>&1 | ${TEE}
#else
#	NSTEP=${NJOB}_200
#	LIBEL="Erase temporary files"
#	RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
#
#        JOBEND
#fi


NSTEP=${NJOB}_60
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 2000 1"
SORT_I2="${EST_FTECLEDASII} 2000 1"
SORT_I3="${ESF_FTECLEDA_I17G} 2000 1"
SORT_I4="${ESF_FTECLEDA_I17L} 2000 1"
SORT_I5="${ESF_FTECLEDA_I17P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_O.dat 2000 1"
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
	AMT_M            19:1 -  19:EN 18/3,
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
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
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

NSTEP=${NJOB}_65
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA_T by BALSHTDAY for I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_I17S} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_T.dat 2000 1"
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
	AMT_M            19:1 -  19:EN 18/3,
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
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
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


NSTEP=${NJOB}_70
# Sort of the FTECLEDA File on TTECLEDA_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDA File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_TECLEDA_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_75
# Sort of the FTECLEDA_T File, I17S 
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDA_T File on index key, I17S "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65_${IB}_SORT_TECLEDA_T.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_T.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_80
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_TECLEDA_O.dat


NSTEP=${NJOB}_85
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file, I17S"
RMFIL ${DFILT}/${NJOB}_65_${IB}_SORT_TECLEDA_T.dat


NSTEP=${NJOB}_90
#-------------------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 2000 1"
SORT_I2="${EST_FTECLEDRSII} 2000 1"
SORT_I3="${ESF_FTECLEDR_I17G} 2000 1"
SORT_I4="${ESF_FTECLEDR_I17L} 2000 1"
SORT_I5="${ESF_FTECLEDR_I17P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	DBLTRNCOD_CF      7:1 -  7:,
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
	CED_NF           20:1 -  20:,
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
	RETAMT_M         35:1 - 35:EN 18/3,
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
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION RETAMT_M NE 0 and BALSHEY_NF > 0
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_95
#-------------------------------------------
LIBEL="Summarize TTECLEDR_T by BALSHTDAY, I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_I17S} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_T.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	DBLTRNCOD_CF      7:1 -  7:,
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
	CED_NF           20:1 -  20:,
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
	RETAMT_M         35:1 - 35:EN 18/3,
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
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION RETAMT_M NE 0 and BALSHEY_NF > 0
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


NSTEP=${NJOB}_100
# Sort of the FTECLEDR File on TTECLEDR_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_TECLEDR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_110
# Sort of the FTECLEDR_T File
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key, I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_TECLEDR_T.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_T.dat 2000 1"
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

NSTEP=${NJOB}_120
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_TECLEDR_O.dat

NSTEP=${NJOB}_125
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file, I17S"
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_TECLEDR_T.dat


NSTEP=${NJOB}_130
#--------------------------------
LIBEL="filling ${TTECLEDA} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDA_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDA}"
BCP

NSTEP=${NJOB}_135
#--------------------------------
LIBEL="filling TTECLEDA_T table, I17S"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_75_${IB}_SORT_FTECLEDA_T.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..TTECLEDA_T"
BCP


NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDA', '${INVCONSO_D}',
		${PARM_CONSOYEA}, ${PARM_CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_150
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDA_O.dat

NSTEP=${NJOB}_150
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file, I17S"
RMFIL ${DFILT}/${NJOB}_77_${IB}_SORT_FTECLEDA_T.dat


NSTEP=${NJOB}_160
# filling TTECLEDR table
#--------------------------------
LIBEL="filling ${TTECLEDR} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDR}"
BCP

NSTEP=${NJOB}_160
# filling TTECLEDR_T table
#--------------------------------
LIBEL="filling TTECLEDR_T table, I17S"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_110_${IB}_SORT_FTECLEDR_T.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..TTECLEDR_T"
BCP

NSTEP=${NJOB}_180
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDR', '${INVCONSO_D}',
		${PARM_CONSOYEA}, ${PARM_CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL



NSTEP=${NJOB}_200
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"



JOBEND
 

#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESFD8101.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : Roger Cassis
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative job ESFD8101
#
#-----------------------------------------------------------------------------
# historiques des modifications:
#[001] 08/03/2016 R. Cassis :spot:30246 - Ajout gestion des Ultimates et du speentnat_ct forc�
#[002] 08/03/2016 R. Cassis :spot:30402 - Ajout cl� dans les tris FTECLEDX - correction date trimestre de FULTIMATE
#[003] 02/06/2016 R. Cassis :spot:30695 - Ajout du site dans la requete de TULTIMATES
#[004] 30/06/2016 R. Cassis :spot:30839 - Extraction de la FULTIMATES par procedure pour gerer les formats de dates.
#[005] 24/10/2016 R. Cassis :spot:31393 - Ajout de la gestion du fichier RISK_MARGIN pour envoi vers RA
#[006] 06/04/2017 R. Cassis :spot:60188 - Ajout de la gestion du fichier FULTIMATES mode EBS pour envoi vers RA
#[007] 10/04/2017 R. Cassis :spira:59429  Gestion des annulations CONSO IFRS et EBS
#[008] 18/09/2017 R. Cassis :spira:63991  Pour YTD, on prend tous les mois de l'ann�e
#[009] 03/10/2017 R. Cassis :spira:61508  Adaptation pour fichier Ecritures de service LOCAL
#[010] 07/12/2017 R. Cassis :spira:66334  Les fichiers perimetre ES Local sont nomm�s ESL_ sont maintenant g�n�r�s dans le ESID7000
#[011] 03/05/2018 L. DOAN   :spira:77081  REQ08.1 F3 : Generating data for RA  : clonnage de ESID8101.cmd
#[012] 02/05/2020 L. DOAN   :spira:82684  Slit of upload TTECLEDA/R
#[013] 28/05/2020 L. DOAN   :spira:85741: add CSM LC
#[014] 19/09/2020 L. DOAN   :spira:83014: remove CSM LC
#[015] 09/10/2020 L. DOAN   :spira:88638: remove EBS common
#[016] 29/10/2020 L. DOAN   :spira:84655: fix double run bug
#[017] 21/12/2020 L. DOAN   :spira:91994: Local - IFRS17L/IFRS1P Omega/RA  interface : remove EBS
#[018] 29/12/2020 L. DOAN   :spira:91531: fix param
#[019] 16/03/2021 L. DOAN   :spira:83101: fix G/L/P
#[020] 26/03/2021 L. DOAN   :spira:91531: remove ESF_FTECLEDA[R]CO_ANNULMVT
#[021] 04/05/2021 L. DOAN   :spira:96031: BDA gaap code - Interface RA
#[021] 22/06/2021 L. DOAN   :spira:97241: parallel closing
#[022] 07/07/2021 L. DOAN   :spira:97560: ParallelRun- Envoie a RA INV EBS
#[023] 27/09/2021 L. DOAN   :spira:97560: ParallelRun- Envoie a RA INV EBS : INV to POS for cashflow
#[024] 04/10/2021 L. DOAN   :spira:95603: IFRS17 - AOC metadata 
#[025] 23/11/2021 JYP/Mariem:spira:95603: IFRS17 - AOC metadata PARM_CRE_D
#[026] 23/03/2022 M.NAJI    :spira:103272 vider col 110 de FTECLEDA et col 63 de FTECLEDR
#[027] 03/30/2022 JBD       :spira:103227 Use clotyp='TRA' in O2/RA interface when in transition
#[028] 22/04/2022 TD/MZM    :spira:103227 Modification TD
#[029] 01/06/2022 DAD       :spira:104727 Transforme ALLNO & empty to NORME_CF in ESF_FTECLEDSIIRA
#[030] 19/06/2023 JYP       :spira 109764 : summarize with NEWCOLS1_NF in keys
#[031] 06/08/2025 Mr JYP    :US 5559 : SERQS split files by site , SII part
#============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters


CRE_D=${PARM_CRE_D}
BALSHTYEA_NF=${PARM_BLCSHTYEA_NF}
BALSHTMTH_NF=${PARM_BLCSHTMTH_NF}
#PER_CF=${TYPEINV}

CLODAT_D=${PARM_ICLODAT_D}
INVCONSO_D=${PARM_INVCONSO_D}
CLODATMAX_D=${PARM_INVCONSO_D}
SUFFTABLE=${PARM_SUFFTABLE}

################################################################
#Les diff�rentes valeurs possibles pour SPEENTNAT_CT sont : 
#1             Ecriture Service
#2             Social Ec. Serv
#3             Conso Ec. Serv.
#4             �criture service EBS -> rien dans TACCSUP
#5             �criture Serv. Social EBS
#6             �criture Serv. Conso EBS

#9	       I17G INV
#10	       I17G POS
#11	       I17G POC
################################################################
# Format du Fichier CLS_Type
#Norme donn�es~type inv~ann�e/mois du trimestre
#IFRS~INV~YYYYMM    -> contains IFRS std
#IFRS~POS~YYYYMM    -> contains IFRS std + POS
#IFRS~POC~YYYYMM    -> contains IFRS POC
#EBS~POS~YYYYMM     -> contains EBS POS
#EBS~POC~YYYYMM     -> contains EBS POC
#I17G~INV~YYYYMM    -> contains IFRS17 std
#I17G~POS~YYYYMM    -> contains IFRS17 std + pos 
#I17G~POC~YYYYMM    -> contains IFRS17 poc
################################################################

if [ "${DNZFILP}" = "" ]
then
	DNZFILP=${DFILP}
fi



TRIM=${CLODATMAX_QTR}
BALSHTYEA_NFTRIM=${CLODATMAX_YEA}


BALSHTMTH_NFDEB=`echo ${CLODATMAX_D} | awk '{mth = substr($0,5,2) - 2; print mth}'`
BALSHTMTH_NFFIN=`echo ${CLODATMAX_D} | cut -c5-6` 


#prendre deux variables dans mapping 
#ESF_FILE_LIST=${NCHAIN}_FILE_LIST_${HOST_PRDSIT}.dat

# ne pas d�clarer cett variable dans SQL ARCHI 

#ESF_CLS=${NCHAIN}_CLSTYPE_${HOST_PRDSIT}.dat

# Job Initialisation
JOBINIT

#----------------------
SPEENTNAT_CTDEFAUT=10
#----------------------

#[005]
#TODO : condition "I17L" and "I17P"

#MOD [027] first part start
CHK_TRA=`grep TI17PERMFIL ${DPRM}/ESFJ0000.prm |cut -d" " -f2`

if [ "${CHK_TRA}" = "TI17TRAPERMFIL" ]
then
    ECHO_LOG "TRA_MODE = YES"
    TRA_MODE="YES"
else
    ECHO_LOG "TRA_MODE = NO"
    TRA_MODE="NO"
fi
#MOD [027] first part end

if [ "${NORME_CF}" = "I17*" ]
then       
    if [ "${TYPEINV}" = "POS" ]
    then
	SPEENTNAT_CTDEFAUT=10
	
    else 
	if [ "${TYPEINV}" = "POC" ]
	then
	    SPEENTNAT_CTDEFAUT=11
	    
	else
	    SPEENTNAT_CTDEFAUT=9
	    
	fi
	
    fi
fi




if [ ! -f ${ESF_FTECLEDA} ]
   then
        ECHO_LOG "ESF_FTECLEDA =${ESF_FTECLEDA}  does not exist, take an empty file"            >> $FLOG
        ESF_FTECLEDA="${DFILP}/empty.dat"
fi



if [ ! -f ${ESF_FTECLEDR} ]
   then
        ECHO_LOG "ESF_FTECLEDR =${ESF_FTECLEDR}  does not exist, take an empty file"            >> $FLOG
        ESF_FTECLEDR="${DFILP}/empty.dat"
fi


if [ ! -f ${ESF_FTECLEDSII_LOCAL} ]
   then
        ECHO_LOG "ESF_FTECLEDSII_LOCAL =${ESF_FTECLEDSII_LOCAL}  does not exist, take an empty file"            >> $FLOG
        ESF_FTECLEDSII_LOCAL="${DFILP}/empty.dat"
fi



if [ ! -f ${ESF_SII_RISKMARGIN_LOCAL} ]
   then
        ECHO_LOG "ESF_SII_RISKMARGIN_LOCAL =${ESF_SII_RISKMARGIN_LOCAL}  does not exist, take an empty file"            >> $FLOG
        ESF_SII_RISKMARGIN_LOCAL="${DFILP}/empty.dat"
fi




ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESF_FTECLEDA............: ${ESF_FTECLEDA}"
ECHO_LOG "#===> ESF_FTECLEDR............: ${ESF_FTECLEDR}"
ECHO_LOG "#===> ESF_FTECLEDSII..........: ${ESF_FTECLEDSII}"
ECHO_LOG "#===> ESF_GTSII_RISKMARGIN....: ${ESF_GTSII_RISKMARGIN}"
ECHO_LOG "#===> ESF_FTECLEDSII_LOCAL ...: $ESF_FTECLEDSII_LOCAL "
ECHO_LOG "#===> ESF_SII_RISKMARGIN_LOCAL: $ESF_SII_RISKMARGIN_LOCAL "
ECHO_LOG "#===> ESF_FTECLEDARA..........: ${DNZFILP}/${ESF_FTECLEDARA}"
ECHO_LOG "#===> ESF_FTECLEDRRA..........: ${DNZFILP}/${ESF_FTECLEDRRA}"
ECHO_LOG "#===> ESF_FTECLEDAYTD.........: ${DNZFILP}/${ESF_FTECLEDAYTD}"
ECHO_LOG "#===> ESF_FTECLEDRYTD.........: ${DNZFILP}/${ESF_FTECLEDRYTD}"
ECHO_LOG "#===> ESF_FTECLEDSIIRA........: ${DNZFILP}/${ESF_FTECLEDSIIRA}"
#ECHO_LOG "#===> ESF_FULTIMATES..........: ${ESF_FULTIMATES}"
ECHO_LOG "#===> ESF_FULTIMATESRA........: ${DNZFILP}/${ESF_FULTIMATESRA}"
ECHO_LOG "#===> ESF_FILE_LIST...........: ${DNZFILP}/${ESF_FILE_LIST}"
ECHO_LOG "#===> ESF_CLS.................: ${DNZFILP}/${ESF_CLS}"
ECHO_LOG "#===> CRE_D...................: ${CRE_D}"
ECHO_LOG "#===> BALSHTYEA_NF............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NFTRIM........: ${BALSHTYEA_NFTRIM}"
ECHO_LOG "#===> BALSHTMTH_NFDEB.........: ${BALSHTMTH_NFDEB}"
ECHO_LOG "#===> BALSHTMTH_NFFIN.........: ${BALSHTMTH_NFFIN}"
ECHO_LOG "#===> CLODAT_D................: ${CLODAT_D}"
ECHO_LOG "#===> CLODATMAX_D.............: ${CLODATMAX_D}"
ECHO_LOG "#===> TRIM....................: ${TRIM}"
ECHO_LOG "#===> NORME...................: ${NORME}"
ECHO_LOG "#===> TYPEINV.................: ${TYPEINV}"
ECHO_LOG "#===> COMPTAPOC...............: ${COMPTAPOC}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*${IDF_CT}*.dat"



echo "#===> TTECLEDR ....................: ${TTECLEDR}" 			2>&1 | ${TEE}
echo "#===> TTECLEDA ....................: ${TTECLEDA}" 			2>&1 | ${TEE}




NSTEP=${NJOB}_05
# summarize TTECLEDA
#--------------------------------
LIBEL="Summarize TTECLEDA : ${ESF_FTECLEDA} sur ${DNZFILP}/${ESF_FTECLEDARA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DNZFILP}/${ESF_FTECLEDARA} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	TRNCOD2_CF        6:2 -   6:2,
	TRNCOD8_CF        6:8 -   6:8,
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
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	COLS1             1:1 -   3:,
	COLS2             5:1 -  18:,
	COLS3            20:1 -  34:,
	COLS4            36:1 -  87:,
	COLS5            89:1 - 105:,
        COLS107-109     107:1 - 109:,
		NEWCOLS1_NF     110:1 - 110:,
        GAAPCOD_NT      111:1 - 111:,
        I17PRDCOD_CT    112:1 - 112:,
        NEWCOLS4_NF     113:1 - 113:,
        NEWCOLS5_NF     114:1 - 114:,
        NEWCOLS6_NF     115:1 - 115:,
        NEWCOLS7_NF     116:1 - 116:,
        NEWCOLS8_NF     117:1 - 117:,
        NEWCOLS9_NF     118:1 - 118:
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
	RETARDRETINT_B,
	NEWCOLS1_NF

/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) and BALSHEY_NF > 0
                         and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN} 
			 and BALSHEY_NF <= ${CLODATMAX_YEA}
/CONDITION SPEENTNAT ("ABDEGHIJKL" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF) AND "${SPEENTNAT_CTDEFAUT}" != "11"
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/DERIVEDFIELD SPEENTNAT_CT2 if SPEENTNAT then "10~" else "${SPEENTNAT_CTDEFAUT}~"
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD EMPTY_FIELD "~" 
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT COLS1, BALSHRMTH_NFC, COLS2, AMT_MC, COLS3, RETAMT_MC, COLS4, RETINTAMT_MC, COLS5, SPEENTNAT_CT2
	,COLS107-109
	,NEWCOLS1_NF
	,GAAPCOD_NT
	,I17PRDCOD_CT
	,EMPTY_FIELD
	,NEWCOLS5_NF
	,NEWCOLS6_NF
	,NEWCOLS7_NF
	,NEWCOLS8_NF
	,NEWCOLS9_NF
exit
EOF
SORT


NSTEP=${NJOB}_15
# summarize TTECLEDR
#-------------------------------------------
LIBEL="Summarize TTECLEDR : ${ESF_FTECLEDR} sur ${DNZFILP}/${ESF_FTECLEDRRA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
SORT_O="${DNZFILP}/${ESF_FTECLEDRRA} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	TRNCOD2_CF        6:2 -  6:2,
	TRNCOD8_CF        6:8 -  6:8,
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
	AMT_M            19:1 -  19:EN 18/3,
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
	RETARDRETINT_B   62:1 - 62:,
	COLS1             1:1 -  3:,
	COLS2             5:1 - 34:,
	COLS3            36:1 - 58:,
  	COLS60-62        60:1 - 62:,
        GAAPCOD_NT       64:1 - 64:,
        I17PRDCOD_CT     65:1 - 65:,
        NEWCOLS4_NF      66:1 - 66:,
        NEWCOLS5_NF      67:1 - 67:,
        NEWCOLS6_NF      68:1 - 68:,
        NEWCOLS7_NF      69:1 - 69:,
        NEWCOLS8_NF      70:1 - 70:,
        NEWCOLS9_NF      71:1 - 71:

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
/CONDITION RESTRICTION RETAMT_M NE 0 and  BALSHEY_NF > 0  and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN} and BALSHEY_NF <= ${CLODATMAX_YEA}
/CONDITION SPEENTNAT ("ABDEGHIJKL" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF) AND "${SPEENTNAT_CTDEFAUT}" != "11"
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/DERIVEDFIELD SPEENTNAT_CT2 if SPEENTNAT then "10~" else "${SPEENTNAT_CTDEFAUT}~"
/DERIVEDFIELD EMPTY_FIELD "~" 
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT COLS1, BALSHRMTH_NFC, COLS2, RETAMT_MC, COLS3, SPEENTNAT_CT2
 	,COLS60-62
        ,EMPTY_FIELD
        ,GAAPCOD_NT
        ,I17PRDCOD_CT
        ,EMPTY_FIELD
        ,NEWCOLS5_NF
        ,NEWCOLS6_NF
        ,NEWCOLS7_NF
        ,NEWCOLS8_NF
        ,NEWCOLS9_NF
exit
EOF
SORT


#[008]
NSTEP=${NJOB}_30
# summarize TTECLEDA
#--------------------------------
LIBEL="Create Control file for ${ESF_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DNZFILP}/${ESF_FTECLEDAYTD} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	RETINTAMT_M      88:1 -  88:EN 18/3
/KEYS
	BALSHEY_NF,
	BALSHRMTH_NF,
        SSD_CF,
	ESB_CF,
	TRNCOD_CF,
	CUR_CF,
	RETCUR_CF
/CONDITION RESTRICTION  BALSHEY_NF > 0 and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN} and BALSHEY_NF <= ${CLODATMAX_YEA}
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MT       AMT_M       COMPRESS
/DERIVEDFIELD RETAMT_MT    RETAMT_M    COMPRESS
/DERIVEDFIELD RETINTAMT_MT RETINTAMT_M COMPRESS 
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT BALSHEY_NF, BALSHRMTH_NFC, SSD_CF, ESB_CF, TRNCOD_CF, CUR_CF, RETCUR_CF, AMT_MT, RETAMT_MT, RETINTAMT_MT
exit
EOF
SORT

#[008]
NSTEP=${NJOB}_40
# summarize TTECLEDR
#--------------------------------
LIBEL="Create Control file for ${ESF_FTECLEDR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
SORT_O="${DNZFILP}/${ESF_FTECLEDRYTD} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	CUR_CF           18:1 -  18:,
	RETCUR_CF        34:1 -  34:,
	AMT_M            19:1 -  19:EN 18/3,
	RETAMT_M         35:1 -  35:EN 18/3
/KEYS
	BALSHEY_NF,
	BALSHRMTH_NF,
        SSD_CF,
	ESB_CF,
	TRNCOD_CF,
	CUR_CF,
	RETCUR_CF
/CONDITION RESTRICTION  BALSHEY_NF > 0 and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and  BALSHRMTH_NF <= ${BALSHTMTH_NFFIN} and BALSHEY_NF <= ${CLODATMAX_YEA}
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MT    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MT RETAMT_M COMPRESS
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT BALSHEY_NF, BALSHRMTH_NFC, SSD_CF, ESB_CF, TRNCOD_CF, CUR_CF, RETCUR_CF, AMT_MT, RETAMT_MT
exit
EOF
SORT

## MOD [027] beg
if [ "${TRA_MODE}" = "YES" ]
then
    NSTEP=${NJOB}_45
    #-----------------------------------------------------------------------------
    LIBEL="Force INV or POS to TRA in ${ESF_FTECLEDSII_LOCAL}"
    AWK_I=${ESF_FTECLEDSII_LOCAL}
    AWK_O=${DFILT}/${NSTEP}_${IB}_FTECLEDSII.dat
    AWK_CMD=`CFTMP`
    INPUT_TEXT ${AWK_CMD} <<EOF
    BEGIN{ FS="\~"; OFS="\~" }
      {
         if (substr(\$4,1,3) != "INI") 
			{ \$4 = "TRA";}
         print \$0;
      }
exit
EOF
    AWK

    NSTEP=${NJOB}_45b
    #-----------------------------------------------------------------------------
    LIBEL="Force INV or POS to TRA in ${ESF_SII_RISKMARGIN_LOCAL}"
    AWK_I=${ESF_SII_RISKMARGIN_LOCAL}
    AWK_O=${DFILT}/${NSTEP}_${IB}_GTSII_RISKMARGIN.dat
    AWK_CMD=`CFTMP`
    INPUT_TEXT ${AWK_CMD} <<EOF
    BEGIN{ FS="\~"; OFS="\~" }
       {
         if (substr(\$4,1,3) != "INI") 
			{ \$4 = "TRA";}
         print \$0;
       }
exit
EOF
    AWK

else
    NSTEP=${NJOB}_45
    #-----------------------------------------------------------------------------
    LIBEL="Transforme INV en POS in ${ESF_FTECLEDSII_LOCAL} "
    AWK_I=${ESF_FTECLEDSII_LOCAL}
    AWK_O=${DFILT}/${NSTEP}_${IB}_FTECLEDSII.dat
    AWK_CMD=`CFTMP`
    INPUT_TEXT ${AWK_CMD} <<EOF
    BEGIN{ FS="\~"; OFS="\~" }
       {
         if (substr(\$4,1,3) == "INV") 
			{ \$4 = "POS";}
         print \$0;
        }
exit
EOF
    AWK

    NSTEP=${NJOB}_45b
    #-----------------------------------------------------------------------------
    LIBEL="Transforme INV en POS in ${ESF_SII_RISKMARGIN_LOCAL} "
    AWK_I=${ESF_SII_RISKMARGIN_LOCAL}
    AWK_O=${DFILT}/${NSTEP}_${IB}_GTSII_RISKMARGIN.dat
    AWK_CMD=`CFTMP`
    INPUT_TEXT ${AWK_CMD} <<EOF
    BEGIN{ FS="\~"; OFS="\~" }
      {
        if (substr(\$4,1,3) == "INV") 
			{ \$4 = "POS";}
		print \$0;
      }
exit
EOF
    AWK
fi
#MOD [027] End

#[005]
NSTEP=${NJOB}_50
# Copie fichiers SII
#------------------------------------------------------------------------------
LIBEL="Copy file (SO / CO) ${ESF_FTECLEDSII_LOCAL} and ${ESF_SII_RISKMARGIN_LOCAL} on ${DFILT}/${NSTEP}_${IB}_FTECLEDSIIRA.dat"
EXECKSH_MODE=P
EXECKSH "cat ${DFILT}/${NJOB}_45_${IB}_FTECLEDSII.dat ${ESF_SII_RISKMARGIN_LOCAL} > ${DFILT}/${NSTEP}_${IB}_FTECLEDSIIRA.dat"
EXECKSH "cp ${ESF_GAAPCOD_MAPPING} ${DNZFILP}/${ESF_GAAPCOD_RA}"

#[029]
NSTEP=${NJOB}_60
LIBEL="Transforme ALLNO to ${NORME_CF} in ${DNZFILP}/${ESF_FTECLEDSIIRA}"
AWK_I=${DFILT}/${NJOB}_50_${IB}_FTECLEDSIIRA.dat
AWK_O=${DNZFILP}/${ESF_FTECLEDSIIRA}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	if ( (\$30 == "ALLNO" || \$30 == "") && (substr(\$4,1,3) == "TRA" || substr(\$4,1,3) == "POS") ) { 
		\$30 = "${NORME_CF}";
	}
	print \$0;
}
exit
EOF
AWK

NEW_TYPEINV="${TYPEINV}"

#MOD [027]
if [ "${TRA_MODE}" = "NO" ]
then
    NEW_TYPEINV="POS"
    ECHO_LOG "#===> Inventaire IFRS17 : Force TYPEINV to  ${NEW_TYPEINV}"
else
    NEW_TYPEINV="TRA"
    ECHO_LOG "#===> Force TYPEINV to  ${NEW_TYPEINV}"
fi 

#MOD [028]
##if [ "${TRA_MODE}" = "NO" ]
##then
##NEW_TYPEINV="POS"
##ECHO_LOG "#===> Inventaire IFRS17 : Force TYPEINV to ${NEW_TYPEINV}"
##else
##NEW_TYPEINV="POS"
##ECHO_LOG "#===> Force TYPEINV to ${NEW_TYPEINV}"
##fi
 

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Creation fichier descriptif dans ${ESF_CLS}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
echo "${NORME_CF}~${NEW_TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}" > ${DNZFILP}/${ESF_CLS}
cat ${DNZFILP}/${ESF_CLS}

echo "${NORME_CF}~${NEW_TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}~${PARM_CRE_D}~${PARM_CRE_D}~${PARM_ID_NF}~${PARM_VRS_NF}" > ${DNZFILP}/${ESF_FMETADATA}
cat ${DNZFILP}/${ESF_FMETADATA}

ECHO_LOG "#"
ECHO_LOG "#===> Creation liste des fichiers dans ${ESF_FILE_LIST}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
wc -l ${DNZFILP}/${NCHAIN}_*${IDF_CT}*${HOST_PRDSIT}.dat |  grep -v "total" | grep -v "FILE_LIST" | awk '{split($0,tab1," "); i=split(tab1[2],tab2,"/"); print tab2[i] "~" tab1[1]}' > ${DNZFILP}/${ESF_FILE_LIST}
cat ${DNZFILP}/${ESF_FILE_LIST}

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Sauvegarde des fichiers"
ECHO_LOG "#"
#------------------------------------------------------------------------------
gzip -c ${DNZFILP}/${ESF_FTECLEDARA}  > ${DSAVE}/${SVG}_${ESF_FTECLEDARA}.gz
gzip -c ${DNZFILP}/${ESF_FTECLEDRRA}  > ${DSAVE}/${SVG}_${ESF_FTECLEDRRA}.gz

gzip -c ${DNZFILP}/${ESF_FTECLEDAYTD} > ${DSAVE}/${SVG}_${ESF_FTECLEDAYTD}.gz
gzip -c ${DNZFILP}/${ESF_FTECLEDRYTD} > ${DSAVE}/${SVG}_${ESF_FTECLEDRYTD}.gz
gzip -c ${DNZFILP}/${ESF_FTECLEDSIIRA} > ${DSAVE}/${SVG}_${ESF_FTECLEDSIIRA}.gz
gzip -c ${ESF_SII_RISKMARGIN_LOCAL} > ${DSAVE}/${SVG}_${ESF_GTSII_RISKMARGINRA}.gz
gzip -c ${DNZFILP}/${ESF_FULTIMATESRA} > ${DSAVE}/${SVG}_${ESF_FULTIMATESRA}.gz

gzip -c ${DNZFILP}/${ESF_CLS}         > ${DSAVE}/${SVG}_${ESF_CLS}.gz
gzip -c ${DNZFILP}/${ESF_FILE_LIST}   > ${DSAVE}/${SVG}_${ESF_FILE_LIST}.gz



JOBEND
 



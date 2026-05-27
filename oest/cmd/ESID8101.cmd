#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Formatage des fichiers GLT, ULTIMATES pour chargement dans Netezza
# nom du script SHELL           : ESID8101.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : Roger Cassis
# references des specifications : :spot:29903
#-----------------------------------------------------------------------------
# description
#  Formatage des fichiers Estimation : GLT, Ultimates pour chargement dans Netezza
#
# Launch applicative job ESID8101
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
#[010] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nomm�s ESL_ sont maintenant g�n�r�s dans le ESID7000
#[011] 05/05/2020 R. Cassis :spira:87013 - Ajout de la copie du fichier DB2 duplication de celui existant pour norme Local
#[012] 12/05/2020 l. Doan   :spira:83103 - truncate gaapcod 
#[013] 10/12/2020 R. Cassis :spira:92530 - POCI- Problem of variable year
#[013] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[014] 06/04/2021 : JYP   : SPIRA 91531 : bugfix RiskMargin
#[015] 08/04/2021 R. Cassis :spira:95476 - Decommissionnement du serveur Netezza
#[016] 21/04/2021 M. NAJI :spira: 91531 - r�-integration des correction de Linh r�vision 497769 et d�commenter une partie du mapping dans la condition "LOC"
#[016] 222/04/2021 L.DOAN SPIRA 91531 Fix Local variables
#[017] 222/04/2021 L.DOAN SPIRA 96031 BDA gaap code - Interface RA
#[015] 08/04/2021 R. Cassis :spira:95476 - Decommissionnement du serveur Netezza
#[018] 19/07/2021 R. Cassis :spira:90957 - Suppression du for�age du speentnat_ct dans le tri
#[019] 18/08/2021 L. DOAN   :spira:97560: ParallelRun- Envoie a RA INV EBS
#[020] 27/09/2021 L. DOAN   :spira:97560: ParallelRun- Envoie a RA INV EBS : INV to POS for cashflow
#[021] 01/12/2021 HR        :spira:91532: step 50 else clause added
#[022] 08/03/2022 TD        :spira:102866: Force TRA in CLOTYPE when transition is activated
#[023] 23/03/2022 M.NAJI    :spira:103272 vider col 110 de FTECLEDA et col 63 de FTECLEDR
#[024] 23/05/2022 DAD       :spira:102866 add condition CLODATMAX_D for TRA_MODE
#[025] 19/06/2023 JYP       :spira 109764 : summarize with NEWCOLS1_NF in keys
#[026] 06/08/2025 Mr JYP    :US 5559 : SERQS split files by site , SII part
#===============================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
CLODATMAX_D=$5
INVCONSO_D=$6
NORME=$7
TYPEINV=$8
BLCSHTYEALOC_NF=$9
BLCSHTMTHLOC_NF=${10}



################################################################
#Les diff�rentes valeurs possibles pour SPEENTNAT_CT sont : 
#1             Ecriture Service
#2             Social Ec. Serv
#3             Conso Ec. Serv.
#4             �criture service EBS -> rien dans TACCSUP
#5             �criture Serv. Social EBS
#6             �criture Serv. Conso EBS
################################################################
# Format du Fichier CLS_Type
#Norme donn�es~type inv~ann�e/mois du trimestre
#IFRS~INV~YYYYMM    -> contains IFRS std
#IFRS~POS~YYYYMM    -> contains IFRS std + POS
#IFRS~POC~YYYYMM    -> contains IFRS POC
#EBS~POS~YYYYMM     -> contains EBS POS
#EBS~POC~YYYYMM     -> contains EBS POC
################################################################

if [ "${DNZFILP}" = "" ]
then
	DNZFILP=${DFILP}
fi

#Test si compta POC
COMPTAPOC=N
if [ `grep "IsEpoComptaRequestF=Y" ${DFILP}/${ENV_PREFIX}_ESCJ0000_PLAN2.dat | wc -l` -gt 0 -a "${TYPEINV}" = "POC" ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> COMPTABILISATION POC DEMANDEE"
	ECHO_LOG "#========================================================================="
	COMPTAPOC=Y
	year=`echo ${CLODATMAX_D} | awk '{an = substr($0,1,4); if (substr($0,5,2) == 12) an = an + 1; print an}'`
	month=`echo ${CLODATMAX_D} | awk '{mois = substr($0,5,2) + 3; if (mois == 15) mois = 3; if (mois < 12) mois = "0" mois; print mois}'`
	day=`echo ${month} | awk '{jour = 30; if ($0 == 3 || $0 == 12) jour = 31; print jour}'`
	CLODATMAX_D=${year}${month}${day}
fi

TRIM=`echo ${CLODATMAX_D} | awk '{trim = substr($0,5,2)/3; print trim;}'`
BALSHTYEA_NFTRIM=`echo ${CLODATMAX_D} | cut -c1-4` 
BALSHTMTH_NFDEB=`echo ${CLODATMAX_D} | awk '{mth = substr($0,5,2) - 2; print mth}'`
BALSHTMTH_NFFIN=`echo ${CLODATMAX_D} | cut -c5-6` 

TRIMP=`echo ${INVCONSO_D} | awk '{trim = substr($0,5,2)/3; print trim;}'`
BALSHTYEA_NFTRIMP=`echo ${INVCONSO_D} | cut -c1-4` 

if [ "${COMPTAPOC}" = "Y" ]
then
	TRIMP=${TRIM}
	BALSHTYEA_NFTRIMP=${year}  #[013]
fi

#EST_FULTIMATESRA=${NCHAIN}_BSAR_FTULTIMATESFULL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDR_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDA_YTD_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDR_YTD_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#EST_CLS=${NCHAIN}_CLSTYPE_${HOST_PRDSIT}.dat
#EST_FILE_LIST=${NCHAIN}_FILE_LIST_${HOST_PRDSIT}.dat

# Job Initialisation
JOBINIT

#----------------------
#[018] SPEENTNAT_CTDEFAUT=1
#----------------------

#[005] [018]
#if [ "${NORME}" = "EBS" ]
#then
#	if [ "${TYPEINV}" = "POS" ]
#	then
#[018]		SPEENTNAT_CTDEFAUT=5
#		EST_FTECLEDA=${EPO_FTECLEDASIISO}
#		EST_FTECLEDR=${EPO_FTECLEDRSIISO}
#		EST_FTECLEDSII=${EPO_FTECLEDSIISO}
#		EPO_FULTIMATESSII=${EPO_FULTIMATESSIISO}
#		EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGINSO}
#		EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDASIISO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDRSIISO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDASIISO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDRSIISO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDSIIRA=${NCHAIN}_BSAR_FTECLEDSIISO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_GTSII_RISKMARGINRA=${NCHAIN}_BSAR_GTSII_RISKMARGINSO_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#	else
#[018]		SPEENTNAT_CTDEFAUT=6
#		EST_FTECLEDA=${EPO_FTECLEDASIICO}
#		EST_FTECLEDR=${EPO_FTECLEDRSIICO}
#		EST_FTECLEDSII=${EPO_FTECLEDSIICO}
#		EPO_FULTIMATESSII=${EPO_FULTIMATESSIICO}
#		EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGINCO}
#		EPO_FTECLEDACO_ANNULMVT=${EPO_FTECLEDASIICO_ANNULMVT}
#		EPO_FTECLEDRCO_ANNULMVT=${EPO_FTECLEDRSIICO_ANNULMVT}
#		EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDASIICO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDRSIICO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDASIICO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDRSIICO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDSIIRA=${NCHAIN}_BSAR_FTECLEDSIICO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_GTSII_RISKMARGINRA=${NCHAIN}_BSAR_GTSII_RISKMARGINCO_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
#	fi
#else
#	if [ "${TYPEINV}" != "INV" -a "${NORME}" != "LOC" ]
#	then
#		if [ "${TYPEINV}" = "POS" ]
#		then
#[018]			SPEENTNAT_CTDEFAUT=2
#			EST_FTECLEDA=${EPO_FTECLEDASO}
#			EST_FTECLEDR=${EPO_FTECLEDRSO}
#			EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDASO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#			EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDRSO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#			EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDASO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#			EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDRSO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		else
#[018]			SPEENTNAT_CTDEFAUT=3
#			EST_FTECLEDA=${EPO_FTECLEDACO}
#			EST_FTECLEDR=${EPO_FTECLEDRCO}
#			#EPO_FTECLEDACO_ANNULMVT=${EPO_FTECLEDACO_ANNULMVT} #inutile
#			#EPO_FTECLEDRCO_ANNULMVT=${EPO_FTECLEDRCO_ANNULMVT} #inutile
#			EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDACO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDRCO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDACO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDRCO_YTD_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#		fi
#	fi
#fi

CHK_TRA=`grep TI17PERMFIL ${DPRM}/ESFJ0000.prm |cut -d" " -f2`

#[024]
if [ "${CHK_TRA}" = "TI17TRAPERMFIL" ] && [ "${NORME}" = "EBS" ] && [ "${CLODATMAX_D}" = "20211231" ]
then
	TRA_MODE="YES"
else
	TRA_MODE="NO"
fi

if [ "${NORME}" = "LOC" ]
then
	ANPOST=`echo ${CLODATMAX_D} | cut -c1-4`
	MOISPOST=`echo ${CLODATMAX_D} | cut -c5-6`
	ECHO_LOG "==> ANPOST = ${ANPOST} - MOISPOST = ${MOISPOST}"
#[016]
	TRIML=${TRIMP}  
	BALSHTYEA_NFTRIML=${BALSHTYEA_NFTRIMP} 
	if [ ${BLCSHTMTHLOC_NF} -gt ${MOISPOST} -a ${BLCSHTYEALOC_NF} -eq ${ANPOST} ] ||
		[ ${BLCSHTYEALOC_NF} -gt ${ANPOST} ]
	then
		# Le trimestre est le trimestre en cours, mais pas celui de Post-omega
		TRIML=`expr ${TRIMP} + 1`
		if [ ${TRIML} -gt 4 ]
		then
			TRIML=1
			BALSHTYEA_NFTRIML=`expr ${BALSHTYEA_NFTRIMP} + 1`
		fi
	fi
#	#[010]
#	EST_FTECLEDA=${ESL_FTECLEDALO}
#	EST_FTECLEDR=${ESL_FTECLEDRLO}
#[018]	SPEENTNAT_CTDEFAUT=`cut -d~ -f106 ${EST_FTECLEDA} | head -1`
##	EST_FTECLEDARA=${NCHAIN}_BSAR_FTECLEDASO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
##	EST_FTECLEDRRA=${NCHAIN}_BSAR_FTECLEDRSO_${BALSHTYEA_NFTRIMP}_${TRIMP}Q_${HOST_PRDSIT}.dat
#[016]
	EST_FTECLEDAYTD=${NCHAIN}_BSAR_FTECLEDASO_YTD_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat
	EST_FTECLEDRYTD=${NCHAIN}_BSAR_FTECLEDRSO_YTD_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat
	EST_FTECLEDARA=${ENV_PREFIX}_ESID8110_RAAJUSTDB_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat
	EST_FTECLEDRRA=${ENV_PREFIX}_ESID8110_RRAJUSTDB_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat
	EST_FTECLEDARANZ=${ENV_PREFIX}_ESID8110_RAAJUST_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat  #[011]
	EST_FTECLEDRRANZ=${ENV_PREFIX}_ESID8110_RRAJUST_${BALSHTYEA_NFTRIML}_${TRIML}Q_${HOST_PRDSIT}.dat  #[011]
fi	

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> EST_FTECLEDA............: ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_FTECLEDR............: ${EST_FTECLEDR}"
ECHO_LOG "#===> EST_FTECLEDSII..........: ${EST_FTECLEDSII}"
ECHO_LOG "#===> EST_GTSII_RISKMARGIN....: ${EST_GTSII_RISKMARGIN}"
ECHO_LOG "#===> ESF_FTECLEDSII_LOCAL....: ${ESF_FTECLEDSII_LOCAL}"
ECHO_LOG "#===> ESF_SII_RISKMARGIN_LOCAL: ${ESF_SII_RISKMARGIN_LOCAL}"
ECHO_LOG "#===> EST_FTECLEDARA..........: ${DNZFILP}/${EST_FTECLEDARA}"
ECHO_LOG "#===> EST_FTECLEDRRA..........: ${DNZFILP}/${EST_FTECLEDRRA}"
ECHO_LOG "#===> EST_FTECLEDAYTD.........: ${DNZFILP}/${EST_FTECLEDAYTD}"
ECHO_LOG "#===> EST_FTECLEDRYTD.........: ${DNZFILP}/${EST_FTECLEDRYTD}"
ECHO_LOG "#===> EST_FTECLEDSIIRA........: ${DNZFILP}/${EST_FTECLEDSIIRA}"
ECHO_LOG "#===> EPO_FTECLEDACO_ANNULMVT.: ${EPO_FTECLEDACO_ANNULMVT}"
ECHO_LOG "#===> EPO_FTECLEDRCO_ANNULMVT.: ${EPO_FTECLEDRCO_ANNULMVT}"
ECHO_LOG "#===> EST_FULTIMATES..........: ${EST_FULTIMATES}"
ECHO_LOG "#===> EPO_FULTIMATESSII.......: ${EPO_FULTIMATESSII}"
ECHO_LOG "#===> EST_FULTIMATESRA........: ${DNZFILP}/${EST_FULTIMATESRA}"
ECHO_LOG "#===> EST_FILE_LIST...........: ${DNZFILP}/${EST_FILE_LIST}"
ECHO_LOG "#===> EST_CLS.................: ${DNZFILP}/${EST_CLS}"
ECHO_LOG "#===> CRE_D...................: ${CRE_D}"
ECHO_LOG "#===> BALSHTYEA_NF............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NFTRIM........: ${BALSHTYEA_NFTRIM}"
ECHO_LOG "#===> BALSHTMTH_NFDEB.........: ${BALSHTMTH_NFDEB}"
ECHO_LOG "#===> BALSHTMTH_NFFIN.........: ${BALSHTMTH_NFFIN}"
ECHO_LOG "#===> BALSHTYEA_NFTRIMP.......: ${BALSHTYEA_NFTRIMP}"
ECHO_LOG "#===> BALSHTYEA_NFTRIML.......: ${BALSHTYEA_NFTRIML}"
ECHO_LOG "#===> BLCSHTYEALOC_NF.........: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF.........: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> CLODAT_D................: ${CLODAT_D}"
ECHO_LOG "#===> CLODATMAX_D.............: ${CLODATMAX_D}"
ECHO_LOG "#===> TRIM....................: ${TRIM}"
ECHO_LOG "#===> TRIMP...................: ${TRIMP}"
ECHO_LOG "#===> TRIML...................: ${TRIML}"
ECHO_LOG "#===> NORME...................: ${NORME}"
ECHO_LOG "#===> TYPEINV.................: ${TYPEINV}"
ECHO_LOG "#===> COMPTAPOC...............: ${COMPTAPOC}"
ECHO_LOG "#===> TRANSITION MODE ACTIVATED : ${TRA_MODE}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*.dat"

NSTEP=${NJOB}_10
# summarize TTECLEDA
#--------------------------------
LIBEL="Summarize TTECLEDA : ${EST_FTECLEDA} sur ${DNZFILP}/${EST_FTECLEDARA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DNZFILP}/${EST_FTECLEDARA} 1000 1"
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
	RETARDRETINT_B  109:1 - 109:,
	COLS1             1:1 -   3:,
	COLS2             5:1 -  18:,
	COLS3            20:1 -  34:,
	COLS4            36:1 -  87:,
	COLS89-109     	 89:1 - 109:,
	NEWCOLS1_NF      110:1 - 110:,	
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
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD EMPTY_FIELD "~" 
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT COLS1, BALSHRMTH_NFC, COLS2, AMT_MC, COLS3, RETAMT_MC, COLS4, RETINTAMT_MC
	,COLS89-109
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
if [ "${COMPTAPOC}" != "Y" -a "${NORME}" != "LOC" ] && [ "${TRA_MODE}" = "NO" ]   #[022]
then
	SORT
fi

NSTEP=${NJOB}_20
# summarize TTECLEDR
#-------------------------------------------
LIBEL="Summarize TTECLEDR : ${EST_FTECLEDR} sur ${DNZFILP}/${EST_FTECLEDRRA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 1000 1"
SORT_O="${DNZFILP}/${EST_FTECLEDRRA} 1000 1"
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
	RETARDRETINT_B   62:1 - 62:,
	COLS1             1:1 -  3:,
	COLS2             5:1 - 34:,
	COLS36-62        36:1 - 62:,
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
/CONDITION RESTRICTION RETAMT_M NE 0 and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN}
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/DERIVEDFIELD EMPTY_FIELD "~" 
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT COLS1, BALSHRMTH_NFC, COLS2, RETAMT_MC 
	,COLS36-62
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
if [ "${COMPTAPOC}" != "Y" -a "${NORME}" != "LOC" ] && [ "${TRA_MODE}" = "NO" ]   #[022]
then
	SORT
fi

#[008]
NSTEP=${NJOB}_30
# summarize TTECLEDA
#--------------------------------
LIBEL="Create Control file for ${EST_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DNZFILP}/${EST_FTECLEDAYTD} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 15/3,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	RETINTAMT_M      88:1 -  88:EN 15/3
/KEYS
	BALSHEY_NF,
	BALSHRMTH_NF,
   SSD_CF,
	ESB_CF,
	TRNCOD_CF,
	CUR_CF,
	RETCUR_CF
/CONDITION RESTRICTION BALSHEY_NF = ${BALSHTYEA_NF} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN}
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
if [ "${COMPTAPOC}" != "Y" -a "${NORME}" != "LOC" ] && [ "${TRA_MODE}" = "NO" ] #[009] #[022]
then
	SORT
fi

#[008]
NSTEP=${NJOB}_40
# summarize TTECLEDR
#--------------------------------
LIBEL="Create Control file for ${EST_FTECLEDR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 1000 1"
SORT_O="${DNZFILP}/${EST_FTECLEDRYTD} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	CUR_CF           18:1 -  18:,
	RETCUR_CF        34:1 -  34:,
	AMT_M            19:1 -  19:EN 15/3,
	RETAMT_M         35:1 -  35:EN 15/3
/KEYS
	BALSHEY_NF,
	BALSHRMTH_NF,
   SSD_CF,
	ESB_CF,
	TRNCOD_CF,
	CUR_CF,
	RETCUR_CF
/CONDITION RESTRICTION BALSHEY_NF = ${BALSHTYEA_NF} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN}
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MT    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MT RETAMT_M COMPRESS
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT BALSHEY_NF, BALSHRMTH_NFC, SSD_CF, ESB_CF, TRNCOD_CF, CUR_CF, RETCUR_CF, AMT_MT, RETAMT_MT
exit
EOF
if [ "${COMPTAPOC}" != "Y" -a "${NORME}" != "LOC" ] && [ "${TRA_MODE}" = "NO" ] #[009]#[022]
then
	SORT
fi

#[009]
if [ "${NORME}" = "LOC" ]
then
	NSTEP=${NJOB}_41
	# Copie fichiers CO
	#------------------------------------------------------------------------------
	EXECKSH_MODE=P
	if [ -s ${DNZFILP}/${EST_FTECLEDARA} ]
	then
		diff ${DNZFILP}/${EST_FTECLEDARA} ${EST_FTECLEDA} > ${DFILT}/${NCHAIN}_diffLOC_R.dat
		if [ -s ${DFILT}/${NCHAIN}_diffLOC_R.dat ]
		then
			LIBEL="Append file ${EST_FTECLEDA} to ${DNZFILP}/${EST_FTECLEDARA}"
			EXECKSH "cat ${EST_FTECLEDA} >> ${DNZFILP}/${EST_FTECLEDARA}"
		else
			ECHO_LOG "===> LOCAL file ${EST_FTECLEDARA} already processed, no file generation"
		fi
	else
		LIBEL="Copy file ${EST_FTECLEDA} on ${DNZFILP}/${EST_FTECLEDARA}"
		EXECKSH "cp ${EST_FTECLEDA} ${DNZFILP}/${EST_FTECLEDARA}"
	fi
	if [ -s ${DNZFILP}/${EST_FTECLEDARA} ] #[011]
	then
		LIBEL="Copy file ${DNZFILP}/${EST_FTECLEDARA} on ${DNZFILP}/${EST_FTECLEDARANZ}"
		EXECKSH "cp ${DNZFILP}/${EST_FTECLEDARA} ${DNZFILP}/${EST_FTECLEDARANZ}"
	fi
	NSTEP=${NJOB}_42
	# Copie fichiers CO
	#------------------------------------------------------------------------------
	EXECKSH_MODE=P
	if [ -s ${DNZFILP}/${EST_FTECLEDRRA} ]
	then
		diff ${DNZFILP}/${EST_FTECLEDRRA} ${EST_FTECLEDR} > ${DFILT}/${NCHAIN}_diffLOC_R.dat
		if [ -s ${DFILT}/${NCHAIN}_diffLOC_R.dat ]
		then
			LIBEL="Append file ${EST_FTECLEDR} to ${DNZFILP}/${EST_FTECLEDRRA}"
			EXECKSH "cat ${EST_FTECLEDR} >> ${DNZFILP}/${EST_FTECLEDRRA}"
		else
			ECHO_LOG "===> LOCAL file ${EST_FTECLEDRRA} already processed, no file generation"
		fi
	else
		LIBEL="Copy file ${EST_FTECLEDR} on ${DNZFILP}/${EST_FTECLEDRRA}"
		EXECKSH "cp ${EST_FTECLEDR} ${DNZFILP}/${EST_FTECLEDRRA}"
	fi
	if [ -s ${DNZFILP}/${EST_FTECLEDRRA} ] #[011]
	then
		LIBEL="Copy file ${DNZFILP}/${EST_FTECLEDRRA} on ${DNZFILP}/${EST_FTECLEDRRANZ}"
		EXECKSH "cp ${DNZFILP}/${EST_FTECLEDRRA} ${DNZFILP}/${EST_FTECLEDRRANZ}"
	fi
fi	

#[019] Beg
# if [ "${TYPEINV}" != "INV" -a "${NORME}" = "EBS" -a "${COMPTAPOC}" != "Y" ]
if [ "${NORME}" = "EBS" -a "${COMPTAPOC}" != "Y" ]
#[019] End
then

	if [ "${TRA_MODE}" = "YES" ]
	then

		NSTEP=${NJOB}_45
		# #[043] Creation d'un fichier AT INI avec TRNCOD INI
		#-----------------------------------------------------------------------------
		LIBEL="Force INV or POS to TRA in ${ESF_FTECLEDSII_LOCAL}"
		AWK_I=${ESF_FTECLEDSII_LOCAL}
		AWK_O=${DFILT}/${NSTEP}_${IB}_FTECLEDSII.dat
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		  {
				\$4 = "TRA";
				print \$0;
		  }
exit
EOF
		AWK
		
		NSTEP=${NJOB}_45b
		# #[043] Creation d'un fichier AT INI avec TRNCOD INI
		#-----------------------------------------------------------------------------
		LIBEL="Force INV or POS to TRA in ${ESF_SII_RISKMARGIN_LOCAL}"
		AWK_I=${ESF_SII_RISKMARGIN_LOCAL}
		AWK_O=${DFILT}/${NSTEP}_${IB}_GTSII_RISKMARGIN.dat
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		  {
				\$4 = "TRA";
				print \$0;
		  }
exit
EOF
		AWK
	else
		NSTEP=${NJOB}_45
		# #[043] Creation d'un fichier AT INI avec TRNCOD INI
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
		# #[043] Creation d'un fichier AT INI avec TRNCOD INI
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


	#[005]
	NSTEP=${NJOB}_50
	# Copie fichiers SII
	#------------------------------------------------------------------------------
	LIBEL="Copy file (SO / CO) ${ESF_FTECLEDSII_LOCAL} and ${ESF_SII_RISKMARGIN_LOCAL} on ${DNZFILP}/${EST_FTECLEDSIIRA}"
	EXECKSH_MODE=P
	EXECKSH "cat ${DFILT}/${NJOB}_45_${IB}_FTECLEDSII.dat ${DFILT}/${NJOB}_45b_${IB}_GTSII_RISKMARGIN.dat > ${DNZFILP}/${EST_FTECLEDSIIRA}"

	if [ "${EPO_FULTIMATESSII}" != "" ]
	then
		#[022]
		if [ "${TYPEINV}" = "INV" ] && [ "${NORME_CF}" = "EBS" ] && [ "${TRA_MODE}" = "NO" ]
		then

        		NEW_TYPEINV="POS"
        		ECHO_LOG "#===> Inventaire EBS : Force TYPEINV to  ${NEW_TYPEINV} for cashflow"
		
		#[022]
        elif [ "${NORME_CF}" = "EBS" ] && [ "${TRA_MODE}" = "YES" ]
		then	
				NEW_TYPEINV="TRA"
				ECHO_LOG "#===> Inventaire EBS : Force TYPEINV to  ${NEW_TYPEINV} for cashflow"
		
		else
				
				NEW_TYPEINV=${TYPEINV}
				ECHO_LOG "#===> Inventaire EBS : Force TYPEINV to  ${NEW_TYPEINV} for cashflow"

		fi

		#[006]
		NSTEP=${NJOB}_51 
		# Copie fichiers SII
		#------------------------------------------------------------------------------
		LIBEL="Copy file (SO / CO) ${EPO_FULTIMATESSII} ${DNZFILP}/${EST_FULTIMATESRA}"
		AWK_I=${EPO_FULTIMATESSII}
		AWK_O=${DNZFILP}/${EST_FULTIMATESRA}
		AWK_PARAM=" -v norme=${NORME} -v typeinv=${NEW_TYPEINV} -v an=${BALSHTYEA_NFTRIM} -v mois=${BALSHTMTH_NFFIN} "
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			print norme "~" typeinv "~" an "~" mois "~" \$0;
		}
exit
EOF
		AWK


	fi
fi

#[001] [003] [004]
# ATTENTION aux doubles runs, il tournera en IFRS et en Post
if [ "${TYPEINV}" = "INV" -a "${EST_VARIANTE}" = "3" ]  ##-o ${NORME} = "EBS" ]
then
	NSTEP=${NJOB}_60
	# Begin isql-bcpmulti TULTIMATES
	#---------------------------------------------------------------------
	LIBEL="Extract data from BSAR..TULTIMATES"
	BCP_WAY="OUT"; BCP_VER="+"
	BCP_O=${DNZFILP}/${EST_FULTIMATESRA}
	BCP_QRY="execute BSAR..PsRATULTIMATES_01 '${NORME}', '${TYPEINV}', '${BALSHTYEA_NFTRIM}', '${BALSHTMTH_NFFIN}' with recompile"
	BCP

	
	ECHO_LOG "#===> Sauvegarde du fichier : ${EST_FULTIMATESRA}"
	gzip -c ${DNZFILP}/${EST_FULTIMATESRA} > ${DSAVE}/${SVG}_${EST_FULTIMATESRA}.gz
fi

#[007]
if [ "${TYPEINV}" = "POC" ]
then
	#Cas de Comptabilisation POC - On envoit que le fichier d'annulation
	if [ "${COMPTAPOC}" = "Y" ]
	then
		# Cas de Comptabilisation du POC	
		if [ "${EPO_FTECLEDACO_ANNULMVT}" != "" ]
		then
			NSTEP=${NJOB}_70
			# Copie fichiers CO
			#------------------------------------------------------------------------------
			LIBEL="Copy file ${EPO_FTECLEDACO_ANNULMVT} on ${DNZFILP}/${EST_FTECLEDARA}"
			EXECKSH_MODE=P
			EXECKSH "cp ${EPO_FTECLEDACO_ANNULMVT} ${DNZFILP}/${EST_FTECLEDARA}"
		fi
		if [ "${EPO_FTECLEDRCO_ANNULMVT}" != "" ]
		then
			NSTEP=${NJOB}_80
			# Copie fichiers CO
			#------------------------------------------------------------------------------
			LIBEL="Copy file ${EPO_FTECLEDRCO_ANNULMVT} on ${DNZFILP}/${EST_FTECLEDRRA}"
			EXECKSH_MODE=P
			EXECKSH "cp ${EPO_FTECLEDRCO_ANNULMVT} ${DNZFILP}/${EST_FTECLEDRRA}"
		fi
	else
	#Cas de POC - on envoit le fichier d'annulation du trimestre precedent + le fichier POC actuel
		if [ "${EPO_FTECLEDACO_ANNULMVT}" != "" ]
		then
			NSTEP=${NJOB}_90
			# Copie fichiers CO
			#------------------------------------------------------------------------------
			LIBEL="Add file ${EPO_FTECLEDACO_ANNULMVT} to ${DNZFILP}/${EST_FTECLEDARA}"
			EXECKSH_MODE=P
			EXECKSH "cat ${EPO_FTECLEDACO_ANNULMVT} >> ${DNZFILP}/${EST_FTECLEDARA}"
		fi
		if [ "${EPO_FTECLEDRCO_ANNULMVT}" != "" ]
		then
			NSTEP=${NJOB}_100
			# Copie fichiers CO
			#------------------------------------------------------------------------------
			LIBEL="Add file ${EPO_FTECLEDRCO_ANNULMVT} to ${DNZFILP}/${EST_FTECLEDRRA}"
			EXECKSH_MODE=P
			EXECKSH "cat ${EPO_FTECLEDRCO_ANNULMVT} >> ${DNZFILP}/${EST_FTECLEDRRA}"
		fi
	fi
fi


NEW_TYPEINV="${TYPEINV}"

if [ "${TYPEINV}" = "INV" ] && [ "${NORME_CF}" = "EBS" ] && [ "${TRA_MODE}" = "NO" ]
then

        NEW_TYPEINV="POS"
        ECHO_LOG "#===> Inventaire EBS : Force TYPEINV to  ${NEW_TYPEINV}"
#[022]
elif [ "${NORME_CF}" = "EBS" ] && [ "${TRA_MODE}" = "YES" ]
then
        
		NEW_TYPEINV="TRA"
        ECHO_LOG "#===> Inventaire EBS : Force TYPEINV to  ${NEW_TYPEINV}"
#[022]
fi


ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Creation fichier descriptif dans ${EST_CLS}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
echo "${NORME}~${NEW_TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}" > ${DNZFILP}/${EST_CLS}
cat ${DNZFILP}/${EST_CLS}

ECHO_LOG "#"
ECHO_LOG "#===> Creation liste des fichiers dans ${EST_FILE_LIST}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
wc -l ${DNZFILP}/${NCHAIN}_*${HOST_PRDSIT}.dat |  grep -v "total" | grep -v "FILE_LIST" | awk '{split($0,tab1," "); i=split(tab1[2],tab2,"/"); print tab2[i] "~" tab1[1]}' > ${DNZFILP}/${EST_FILE_LIST}
cat ${DNZFILP}/${EST_FILE_LIST}

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Sauvegarde des fichiers"
ECHO_LOG "#"
#------------------------------------------------------------------------------
#[016]
if [ -s ${DNZFILP}/${EST_FTECLEDARANZ} -a "${NORME}" = "LOC" ] #[011]
then
	ECHO_LOG "gzip ${DNZFILP}/${EST_FTECLEDARANZ}"
	gzip -c ${DNZFILP}/${EST_FTECLEDARANZ}  > ${DSAVE}/${SVG}_${EST_FTECLEDARANZ}.gz
fi
if [ -s ${DNZFILP}/${EST_FTECLEDRRANZ} -a "${NORME}" = "LOC" ] #[011]
then
	ECHO_LOG "gzip ${DNZFILP}/${EST_FTECLEDRRANZ}"

	gzip -c ${DNZFILP}/${EST_FTECLEDRRANZ}  > ${DSAVE}/${SVG}_${EST_FTECLEDRRANZ}.gz
fi
if [ "${COMPTAPOC}" != "Y" -a "${NORME}" != "LOC" ]  #[009]
then
	echo "gzip ${DNZFILP}/${EST_FTECLEDARA}"
	gzip -c ${DNZFILP}/${EST_FTECLEDAYTD} > ${DSAVE}/${SVG}_${EST_FTECLEDAYTD}.gz
	gzip -c ${DNZFILP}/${EST_FTECLEDRYTD} > ${DSAVE}/${SVG}_${EST_FTECLEDRYTD}.gz
	gzip -c ${DNZFILP}/${EST_FTECLEDARA}  > ${DSAVE}/${SVG}_${EST_FTECLEDARA}.gz
	gzip -c ${DNZFILP}/${EST_FTECLEDRRA}  > ${DSAVE}/${SVG}_${EST_FTECLEDRRA}.gz
fi
if [ "${NORME}" = "EBS" -a "${COMPTAPOC}" != "Y" ]
then
	echo "gzip ${DNZFILP}/${EST_FTECLEDSIIRA}"
	gzip -c ${DNZFILP}/${EST_FTECLEDSIIRA} > ${DSAVE}/${SVG}_${EST_FTECLEDSIIRA}.gz
	

	if [ -s ${EST_GTSII_RISKMARGIN} ]
        then
		gzip -c ${EST_GTSII_RISKMARGIN} > ${DSAVE}/${SVG}_${EST_GTSII_RISKMARGINRA}.gz
	fi
	if [ -s ${DNZFILP}/${EST_FULTIMATESRA} ] 
	then
		gzip -c ${DNZFILP}/${EST_FULTIMATESRA} > ${DSAVE}/${SVG}_${EST_FULTIMATESRA}.gz
	fi
fi
ECHO_LOG "gzip ${DNZFILP}/${EST_CLS}"
gzip -c ${DNZFILP}/${EST_CLS}         > ${DSAVE}/${SVG}_${EST_CLS}.gz
gzip -c ${DNZFILP}/${EST_FILE_LIST}   > ${DSAVE}/${SVG}_${EST_FILE_LIST}.gz

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Delete temporary file"
ECHO_LOG "#"
NSTEP=${NJOB}_200
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


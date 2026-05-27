#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Extraction de la table TACCSUP
#                                  pour les ecritures Post Omega
# nom du script SHELL            : ESPD0061.cmd
# revision                       : $Revision:   1.7  $
# date de creation               : 16/06/2005
# auteur                         : J. Ribot
# references des specifications  : SPOT 5085
#-----------------------------------------------------------------------------
# Description
#   Extracting tables
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION
#Auteur:         JF VDV
#Date:           23/05/2012
#Description:    [23390] - SOLVENCY am�nagements
#[004] 19/07/2012 Roger Cassis :spot:23802 Solvency - Ajout steps creation segest
#[005] 23/10/2012 Roger Cassis :spot:24041 - Ajustements SOLVENCY - test cond3 au lieu de cond1
#[006] 20/01/2013 :spot:24698 - -=PhP=-  corrections pour la conso assignation du EPO_FSEGEST_SOLVENCYSO
#[007] 20/01/2013 :spot:24849 - -=PhP=-  corrections pour la conso assignation du nom du fichier EPO_EPOSIISO
#[011] 21/10/2013 :spot:26391 - Cyrille Despret  Ajout de la segmentation sur code ICR 
#[012] 21/07/2015 :spot:28941 - Roger Cassis  Ajout de la segmentation sur code INF et extraction ULAE
#[013] 04/04/2017 R. Cassis   :spira:60188 Generation de la FULTIMATES EBS a partir de celle d'IFRS
#[014] 14/03/2018 MZM         :spira:60188 Modification du tri du fichier EPO_FSEGEST_SOLVENCY : Prise en compte du mode actuariale 'S'
#[015] 23/04/2018 MZM         :spira:65651
#[016] 14/03/2018 MZM         :spira:60188 Modification du tri du fichier EPO_FSEGEST_SOLVENCY : Prise en compte des modes actuariale 'S' et 'R'
#[017] 29/06/2018 R. Cassis   :spira:65656 On extrait FCTREST0 pour prendre en compte les modifications TP EBS (notamment Forcage IBNR).
#[019] 28/08.2018 JYP         : IFRS17 req 10.6 : Upgrade Loss Ratio : now 2 segtyps can be extracted, new parameter is added calling PsSECTION_13 (W or X)
#[020] 08/04/2019 R. Cassis   :spira:65656 gestion parametre PRS_CF a 710 ou 730 pour filtrer les postes IFRS ou EBS de FCTREST et restructuration steps
#[021] 16/04/2019 MZM         :spira:70671 Future RETRO for NP : g�n�ration des fichiers ITDPREMIUM RETRO et UPR, 
#                                                                et du fichier Des placements avec prise en compte de la colonne TOTRETSIGSHA_R via la PS PsPLACEMT_22
#                                          Correction PRS Step 015
#[022] 13/05/2019 R. Cassis   :spira:65656 Correction sur FCTRFWH est EPO_ et non EST_
#[023] 14/06/2019 MZM         :spira:70671 Procedure stocke  PRD BEST_PsRETITDPRM_01.prc execute sur
#[024] 07/11/2019 R. Cassis   :spira:65656 Ajout Date INVCONSO_D dans execution PsSection_16 et FCTRESTF en distinct
#[025] 27/04/2020 R. Cassis   :spira:86536 Revue de la gestion de FCTREST
#[026] 12/06/2020 R. Cassis   :spira:86536 Revue de la gestion de FCTREST
#[027] 01/12/2020 MZM         : Spira:92035 : REQ11. Generate RETRO LOSS OCCURING FILE AT Closing and LOFACTOR AT INI
#[028] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[029] 18/01/2021 R. Cassis   :spira:93390: Suppression de filtres sur dates user
#[030] 17/02/2021 MZM :       :spira:92532: AE Extraction P&C : Deplacement des fichiers ESF_FLORETFACTOR_STD ESF_FLORETFACTOR_STD vers ESPJ0061
#[031] 30/03/2021 R. Cassis   :spira:91531: Deplacement step FCTREST0 et rajout creation EPO_CADVPERIESB0 et FCTRGROLESII
#[032] 01/04/2021 CAS		  :SPIRA#94906: Deplacement de la g�n�ration des fichiers NCB Assum et Retro dans ce batch
#[033] 29/06/2021 R. Cassis   :spira:97398: Ajout gestion INV EBS dans les param�tres
#[034] 06/07/2021 R. Cassis   :spira:95897: Ajout extraction des postes comptables I17 omis dans les annulations et les ouvertures ESF_GROUPING_TC_TOOMIT
#[035] 26/08/2021 MZM         :spira:95950: Ajout extraction  PARM_BOOKINGNEXT_D
#[035] 26/08/2021 MZM         :spira:95950: Ajout extraction  PARM_BOOKINGNEXT_D
#[036] 05/10/2021 MZM         :spira:95950: Ajout INIT PARAM POSI
#[037] 05/10/2021 MZM         :spira:87852: Retrocession automatized Tax Estimates management : Extraction Fichier Taxes Retro Management
#[038] 11/10/2021 JYP         :spira:95950: bugfix dates variables for AE extractions
#[039] 20/10/2021 MZM         :spira:87852: Retrocession automatized Tax Estimates management : Extraction Fichier Taxes Retro Management le 20/10/2021 ACTIVATION
#[040] 25/11/2021 HR          :spira:99667: EBS/IFRS17 AE extraction during INV and POS
#[041] 20/04/2022 RC          : SPIRA 103840: Add balance sheet params at PiESTACCSUP_05 process
#[042] 13/07/2022 DAD         : Spira 104648 : no JOBEND after step 230 juste not execute step 240/250/260 
#[043] 27/01/2023 MZM         : Spira 108632 : EBS/IFRS17 AE extraction on INV : Utilisation des PARMETRES PARM_CONSOMTH et PARM_CONSOYEA
#[044] 07/03/2025 MZM  	      :SPIRA: 111945 BBNI AE GENERATION
#[045] 13/10/2025 MZM  	      :US 5637: DEPLACEMENT  BBNI AE GENERATION (Dans ce JOB) 
#[046] 20/01/2025 MZM  	      :US 7847: GENERATION DES AE EBS INI
#[047] 20/01/2026 MZM  	      :US8221 : Prod Q4 2025 - AE BBNI extracted wrongly by normal EBS process : REMOVE AE EBS INI FROM AE EBS GLOBAL (US 7847 )
#=============================================================================== 

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialization
JOBINIT


# Parameters
BOOKING_D=$1
PSTOMGEN_D=$2
ENCONSO_D=$3
EBSPSTOMGEN_D=$4
CRE_D=$5
INVCONSO_D=$6
CONSOYEA=$7
ICLODAT_D=$8
BOOKINGNEXT_D=$9

# SSD_CF=00, used for all subsidiaries
SSD_CF=00



###################################################################################################
###   DEB EXTRACTION DES DATES POUR LES PROC DES AE EN FONCTION DU TYPEINV et NORME_CF         ####
###################################################################################################

ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- INV IFRS17 : SPEENNAT_CF = 9   "
ECHO_LOG "#BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D  ....:${PARM_BOOKINGNEXT_D}       -- INV IFRS17 : SPEENNAT_CF = 9    " 

ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS IFRS17 : SPEENNAT_CF = 10  "
ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POS IFRS17 : SPEENNAT_CF = 10   " 

ECHO_LOG "#BORNE DATE_DEB===>  PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC IFRS17 : SPEENNAT_CF = 11  " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGCONEND17_D..:${PARM_PSTOMGCONEND17_D}     -- POC IFRS17 : SPEENNAT_CF = 11   "
                                                                                                                   
ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS I4I    : SPEENNAT_CF = 2   " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGEN_D     ....:${PARM_PSTOMGEN_D}          -- POS I4I    : SPEENNAT_CF = 2   "

ECHO_LOG "#BORNE DATE_DEB ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC I4I    : SPEENNAT_CF = 3   "
ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGCONEND_D ....:${PARM_PSTOMGCONEND_D}      -- POC I4I    : SPEENNAT_CF = 3   "
                                                                                                                   
ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- INV EBS    : SPEENNAT_CF = 4   " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D .....:${PARM_BOOKINGNEXT_D}       -- INV EBS    : SPEENNAT_CF = 4   "

#ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS EBS    : SPEENNAT_CF = 5   "
#ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POS EBS    : SPEENNAT_CF = 5    "

ECHO_LOG "#BORNE DATE_DEB ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC EBS    : SPEENNAT_CF = 6   " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_EBSPSTOMGCONEND_D..:${PARM_EBSPSTOMGCONEND_D}   -- POC EBS    : SPEENNAT_CF = 6    " 

#[040]
ECHO_LOG "#BORNE DATE_DEB ===> PARM_EBSPSTOMGEN_PREV_D ....:${PARM_EBSPSTOMGEN_PREV_D}       -- POS EBS    : SPEENNAT_CF = 4 and 5   " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_EBSPSTOMGEN_D  ....:${PARM_EBSPSTOMGEN_D}}       -- POS EBS    : SPEENNAT_CF = 4 and 5   "

# Borne Inferieure DATE_DEB en fonction type de closing

if  [ "${TYPEINV}" = "INV" ] 
then  
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"     		
     fi         
fi


#[040]
if  [ "${TYPEINV}" = "POS" ] 
then  
     #if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] 
     if [ [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] 
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"     		
     fi 

#[040]
     if [ "${NORME_CF}" = "EBS" ] 
     then 
     		PARM_DATE_DEB_D="${PARM_EBSPSTOMGEN_PREV_D}"
     		PARM_DATE_FIN_D="${PARM_EBSPSTOMGEN_D}"     		
     fi 
#[036]
     
 		if  [ "${NORME_CF}" = "I4I" ] 
 		then 
			PARM_DATE_DEB_D="${PARM_BOOKING_D}" 
			PARM_DATE_FIN_D="${PARM_PSTOMGEN_D}"   			
		fi     
                  
fi

if [ "${TYPEINV}" = "POC" ] 
then 
 		if  [ "${NORME_CF}" = "I4I" ] 
 		then 
 			PARM_DATE_DEB_D="${PARM_PSTOMGEN_D}" 
			PARM_DATE_FIN_D="${PARM_PSTOMGCONEND_D}"   			
 		fi
 		
 		if  [ "${NORME_CF}" = "EBS" ]
 		then
			PARM_DATE_DEB_D="${PARM_EBSPSTOMGEND_D}" 
			PARM_DATE_FIN_D="${PARM_EBSPSTOMGCONEND_D}" 			
		fi	
			
 		if  [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ]
 		then
			PARM_DATE_DEB_D="${PARM_PSTOMGEND17_D}" 	
			PARM_DATE_FIN_D="${PARM_PSTOMGCONEND17_D}" 													
 		fi
fi




###################################################################################################
###   FIN EXTRACTION DES DATES POUR LES PROC DES AE EN FONCTION DU TYPEINV et NORME_CF         ####
###################################################################################################




#[013][020] [021] [033] [040]
if [ ${TYPEINV} = "POS" ]
then
	TYPESEG=T
	TYPESEG2=W
	if [ ${NORME_CF} = "I4I" ]
	then
		SPEENTNAT_CT="2"
	else
		SPEENTNAT_CT="4,5"
		PSTOMGEN_D=${EBSPSTOMGEN_D}
	fi		
fi
if [ ${TYPEINV} = "POC" ]
then
	PSTOMGEN_D=${ENCONSO_D}
	TYPESEG=U
	TYPESEG2=X
	if [ ${NORME_CF} = "I4I" ]
	then
		SPEENTNAT_CT="3"
	else
		SPEENTNAT_CT="6"
	fi		
fi
if [ ${TYPEINV} = "INV" ]  # INV EBS TYPESEG pas Utilis� car calcul IBNR d�sactiv�
then
## [035]	PSTOMGEN_D=${EBSPSTOMGEN_D} 
	PSTOMGEN_D=${BOOKINGNEXT_D}
	TYPESEG=A
	TYPESEG2=V
	SPEENTNAT_CT="4"
fi

if [ ${NORME_CF} = "I4I" ]
then
	PRS_CF=710
else
	PRS_CF=730
fi

if [ ! -f ${ESF_EPOSOCI_BBNI} ]
then
        ECHO_LOG "ESF_EPOSOCI_BBNI=${ESF_EPOSOCI_BBNI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_EPOSOCI_BBNI}" ESF_EPOSOCI_INI

fi

if [ ! -f ${ESF_EPOSOCI_INI} ]
then
        ECHO_LOG "ESF_EPOSOCI_INI=${ESF_EPOSOCI_INI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_EPOSOCI_INI}" 

fi

if [ ! -f ${ESF_FTRSLNK_TXT} ]
then
        ECHO_LOG "ESF_FTRSLNK_TXT=${ESF_FTRSLNK_TXT}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTRSLNK_TXT}"

fi



ECHO_LOG ""
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> PARM_CONSOYEA........: ${PARM_CONSOYEA}"
ECHO_LOG "#===> PARM_CONSOMTH........: ${PARM_CONSOMTH}"
ECHO_LOG "#===> PARM_BALSHEYEA_NF....: ${PARM_BALSHEYEA_NF}"
ECHO_LOG "#===> PARM_BALSHTMTH_NF....: ${PARM_BALSHTMTH_NF}"
ECHO_LOG "#===> BOOKING_D............: ${BOOKING_D}"
ECHO_LOG "#===> PARM_BOOKINGNEXT_D...: ${BOOKINGNEXT_D}"
ECHO_LOG "#===> PSTOMGEN_D...........: ${PSTOMGEN_D}"
ECHO_LOG "#===> ENCONSO_D............: ${ENCONSO_D}"
ECHO_LOG "#===> EBSPSTOMGEN_D........: ${EBSPSTOMGEN_D}"
ECHO_LOG "#===> CRE_D................: ${CRE_D}"
ECHO_LOG "#===> INVCONSO_D...........: ${INVCONSO_D}"
ECHO_LOG "#===> PARM_ICLODAT_D.......: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CONSOYEA.............: ${CONSOYEA}"
ECHO_LOG "#===> POST SOCIAL IFRS.....: ${EST_ESPD0060_COND1}"
ECHO_LOG "#===> POST SOCIAL EBS......: ${EST_ESPD0060_COND3}"
ECHO_LOG "#===> POST CONSO...........: ${EST_ESPD0060_COND2}"
ECHO_LOG "#===> TYPEINV..............: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.............: ${NORME_CF}"
ECHO_LOG "#===> TYPESEG..............: ${TYPESEG}"
ECHO_LOG "#===> TYPESEG2.............: ${TYPESEG2}"
ECHO_LOG "#===> SPEENTNAT_CT.........: ${SPEENTNAT_CT}"
ECHO_LOG "#===> PRS_CF...............: ${PRS_CF}"
ECHO_LOG "#===> PSTOMGEN_D...........: ${PSTOMGEN_D}"
ECHO_LOG "#---------------------------------------------------------------------------"
ECHO_LOG "#===> EPO_FSEGEST_SOLVENCYSO...........: ${EPO_FSEGEST_SOLVENCYSO}"
ECHO_LOG "#===> EPO_FSEGEST_SOLVENCYCO...........: ${EPO_FSEGEST_SOLVENCYCO}"
ECHO_LOG "#===> EPO_FSEGEST_SOLVENCY.............: ${EPO_FSEGEST_SOLVENCY}"
ECHO_LOG "#===> EPO_FCTREST0.....................: ${EPO_FCTREST0}"
ECHO_LOG "#===> EPO_FCTRESTA.....................: ${EPO_FCTRESTA}"
ECHO_LOG "#===> EPO_FCTRESTF.....................: ${EPO_FCTRESTF}"
ECHO_LOG "#===> EPO_FCTRESTF0....................: ${EPO_FCTRESTF0}"
ECHO_LOG "#===> EPO_FULTIMATES...................: ${EPO_FULTIMATES}"
ECHO_LOG "#===> EPO_FULAERAT.....................: ${EPO_FULAERAT}"
ECHO_LOG "#===> EPO_FULAERATSO...................: ${EPO_FULAERATSO}"
ECHO_LOG "#===> EPO_FRISKMSII....................: ${EPO_FRISKMSII}"
ECHO_LOG "#===> EPO_FRISKMSIISO..................: ${EPO_FRISKMSIISO}"
ECHO_LOG "#===> EPO_FULTIMATESSII................: ${EPO_FULTIMATESSII}"
ECHO_LOG "#===> EPO_FULTIMATESSIISO..............: ${EPO_FULTIMATESSIISO}"
ECHO_LOG "#===> EPO_FULAERATCO...................: ${EPO_FULAERATCO}"
ECHO_LOG "#===> EPO_FRISKMSIICO..................: ${EPO_FRISKMSIICO}"
ECHO_LOG "#===> EPO_FULTIMATESSIICO..............: ${EPO_FULTIMATESSIICO}"
ECHO_LOG "#===> EPO_EPOSOCI......................: ${EPO_EPOSOCI}" 
ECHO_LOG "#===> EPO_EPOSOCI_BBNI.................: ${ESF_EPOSOCI_BBNI}" 
ECHO_LOG "#===> EPO_EPOSIISO.....................: ${EPO_EPOSIISO}"
ECHO_LOG "#===> EPO_EPOCONS......................: ${EPO_EPOCONS}"
ECHO_LOG "#===> EPO_EPOSIICO.....................: ${EPO_EPOSIICO}          "
ECHO_LOG "#===> EPO_FTRSLNK8.....................: ${EPO_FTRSLNK8}          "
ECHO_LOG "#===> EPO_FSEGPATTERN_BDT..............: ${EPO_FSEGPATTERN_BDT}   "
ECHO_LOG "#===> EPO_FSEGPATTERN_CSF..............: ${EPO_FSEGPATTERN_CSF}   "
ECHO_LOG "#===> EPO_FSEGPATTERN_ICR..............: ${EPO_FSEGPATTERN_ICR}   "
ECHO_LOG "#===> EPO_FSEGPATTERN_DSC..............: ${EPO_FSEGPATTERN_DSC}   "
ECHO_LOG "#===> EPO_FSEGPATTERN_INF..............: ${EPO_FSEGPATTERN_INF}   "
ECHO_LOG "#===> EPO_FCTRFWH......................: ${EPO_FCTRFWH}   "
ECHO_LOG "#===> EPO_FSEGPATTERNFWH...............: ${EPO_FSEGPATTERNFWH}   "
ECHO_LOG "#===> EPO_FPLACEMT22...................: ${EPO_FPLACEMT22}   "
ECHO_LOG "#===> EPO_RETITDPRM_UPR_ACT............: ${EPO_RETITDPRM_UPR_ACT}   "
ECHO_LOG "#===> ESF_FLORETFACTOR_STD.............: ${ESF_FLORETFACTOR_STD}   "
ECHO_LOG "#===> ESF_FLORETFACTOR_INI.............: ${ESF_FLORETFACTOR_INI}   "
ECHO_LOG "#===> ESF_NDIC_NCB.....................: ${ESF_NDIC_NCB}   "
ECHO_LOG "#===> ESF_NDIC_NCB_RET.................: ${ESF_NDIC_NCB_RET}   "
ECHO_LOG "#===> ESF_TAXRETMGNT...................: ${ESF_TAXRETMGNT}   "
ECHO_LOG "#===> ESF_IADPERICASE_BBNI.............: ${ESF_IADPERICASE_BBNI}   "
ECHO_LOG "#===> ESF_IRDPERICASE_BBNI.............: ${ESF_IRDPERICASE_BBNI}   "
ECHO_LOG "#===> ESF_IADPERICASE_INI.............: ${ESF_IADPERICASE_INI}   "
ECHO_LOG "#===> ESF_IRDPERICASE_INI.............: ${ESF_IRDPERICASE_INI}   " 
ECHO_LOG "#===> ESF_FTRSLNK_TXT.................: ${ESF_FTRSLNK_TXT}   " 
ECHO_LOG "#===> ESF_EPOSOCI_INI.................: ${ESF_EPOSOCI_INI}   " 
ECHO_LOG "#========================================================================="


##[043] BCP_QRY="exec BEST..PiESTACCSUP_05 '${SPEENTNAT_CT}', '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', ${PARM_BALSHEYEA_NF}, ${PARM_BALSHTMTH_NF}"
#[041]
NSTEP=${NJOB}_10_${TYPEINV}_${NORME_CF}
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table for ${TYPEINV}_${NORME_CF}_${SPEENTNAT_CT}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_EPOSOCI}
BCP_QRY="exec BEST..PiESTACCSUP_05 '${SPEENTNAT_CT}', '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', ${PARM_CONSOYEA}, ${PARM_CONSOMTH}"
BCP



###  [047]  MOVE TO JOB ESFD5062
#####[044] Filter EPO_EPOSOCI ON BBNI CONTRATS ==> ESF_EPOSOCI_BBNI  
###
###
###if [ "${NORME_CF}" = "EBS" ]
###then
###
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG.....00......: ${ESF_IADPERICASE_BBNI}   "
###
###NSTEP=${NJOB}_12
####-----------------------------------------------------------------------------
###LIBEL="Split contrat assmued and retro "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${EPO_EPOSOCI}  2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
###SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RET.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS TRNCOD1_CF       6:1 -  6:1,
###        CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:  
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT,
###        ACCRET_CF,
###        SEGNAT_CT,
###        PLC_NT,
###        CUR_CF
###/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3" )
###/OUTFILE ${SORT_O} OVERWRITE
###/INCLUDE COND_GTAA
###/OUTFILE ${SORT_O2} OVERWRITE
###/OMIT COND_GTAA
###exit
###EOF
###SORT
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....001.......: ${ESF_IADPERICASE_BBNI}   "
###
###
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....003.......: ${ESF_IADPERICASE_BBNI}   "
###
###
###ECHO_LOG "#===> ESF_IADPERIFACACCEPT_BBNI..DEBUG....003.......: ${ESF_IADPERIFACACCEPT_BBNI}   "
###
###NSTEP=${NJOB}_13
####-----------------------------------------------------------------------------
###LIBEL="Filter ESF_FTRSLNK_TXT on TRNCOD_ES ONLY "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${ESF_FTRSLNK_TXT}  500 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_EBS_STD.dat 500 1"
###SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_EBS_INI.dat 500 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS
###     PRS_CF                 1:1 -  1:,
###     ACMTRS_NT                  2:1 -  2:,
###     DETTRS_CF                  3:1 -  3:,
###     DETTRS8_CF                 3:8 -  3:8
###/CONDITION IS_TRNCOD_EBS_STD  (PRS_CF != "740" OR ACMTRS_NT != "101")
###/CONDITION IS_TRNCOD_EBS_INI  (PRS_CF= "740" AND ACMTRS_NT = "101")
###/OUTFILE $SORT_O
###/INCLUDE IS_TRNCOD_EBS_STD
###/OUTFILE $SORT_O2
###/INCLUDE IS_TRNCOD_EBS_INI
###/COPY
###exit
###EOF
###SORT
###
###
###
###
###
##### RETRO P  / RETRO NP BBNI
###
###NSTEP=${NJOB}_15
####------------------------------------------------------------------------------------
###LIBEL=" RETRO NP AND RETRO PROP from ESF_IRDPERICASE_BBNI"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${ESF_IRDPERICASE_BBNI} 2000 1"  
###SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1"
###SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} << EOF
###/FIELDS
###        RETCTR_NF        3:1 -   3:,
###        RETEND_NF        4:1 -   4:,
###        RETSEC_NF        5:1 -   5:,
###        RTY_NF           6:1 -   6:,
###        RETUW_NT         7:1 -   7:,    
###        NATRET_CF        49:1 - 49:               
###
###/KEYS   RETCTR_NF,
###				RETEND_NF,    
###				RETSEC_NF,
###				RTY_NF,   
###				RETUW_NT 				
###/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
###/OUTFILE ${SORT_O} OVERWRITE
###/INCLUDE RETRO_NP
###/OUTFILE ${SORT_O2} OVERWRITE
###/OMIT RETRO_NP
###exit
###EOF
###SORT
###
##### RETRO P  / RETRO NP INI
###
###NSTEP=${NJOB}_17
####------------------------------------------------------------------------------------
###LIBEL=" RETRO NP AND RETRO PROP from ESF_IRDPERICASE_INI"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${ESF_IRDPERICASE_INI} 2000 1"  
###SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_INI_RETRO_NP.dat 2000 1"
###SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_INI_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} << EOF
###/FIELDS
###        RETCTR_NF        3:1 -   3:,
###        RETEND_NF        4:1 -   4:,
###        RETSEC_NF        5:1 -   5:,
###        RTY_NF           6:1 -   6:,
###        RETUW_NT         7:1 -   7:,    
###        NATRET_CF        49:1 - 49:               
###
###/KEYS   RETCTR_NF,
###				RETEND_NF,    
###				RETSEC_NF,
###				RTY_NF,   
###				RETUW_NT 				
###/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
###/OUTFILE ${SORT_O} OVERWRITE
###/INCLUDE RETRO_NP
###/OUTFILE ${SORT_O2} OVERWRITE
###/OMIT RETRO_NP
###exit
###EOF
###SORT
###
###
###NSTEP=${NJOB}_20
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts RETRO NP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_15_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
###NSTEP=${NJOB}_25
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts RETRO PROP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_15_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
##### ALL ASS AND RETRTO PROP BBNI
###
###NSTEP=${NJOB}_30
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE BBNI ASS and RETRO PROP Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_ASS.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_25_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT
###
###
###NSTEP=${NJOB}_40
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts ASS "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_30_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_CTR_NF    8:1 -  8:,
###        GT_END_NT    9:1 -  9:,
###        GT_SEC_NF    10:1 - 10:,
###        GT_UWY_NF    11:1 - 11:,
###        GT_UW_NT     12:1 - 12:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_CTR_NF ,
###        GT_END_NT ,
###        GT_SEC_NF ,
###        GT_UWY_NF ,
###        GT_UW_NT
###/INFILE ${ESF_IADPERICASE_BBNI} 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###NSTEP=${NJOB}_45
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE BBNI ASS and RETRO Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_40_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_20_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###SORT_O="${ESF_EPOSOCI_BBNI}  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT
###
#####
###
###NSTEP=${NJOB}_45
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for INI Contracts RETRO NP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE_INI_RETRO_NP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
###NSTEP=${NJOB}_50
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for INI Contracts RETRO PROP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE_INI_RETPROP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
##### ALL ASS AND RETRTO PROP INI
###
###NSTEP=${NJOB}_53
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE INI ASS and RETRO PROP Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_12_${IB}_EPOSOCI_ASS.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_50_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT
###
###
###NSTEP=${NJOB}_55
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for INI Contracts ASS "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_53_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_CTR_NF    8:1 -  8:,
###        GT_END_NT    9:1 -  9:,
###        GT_SEC_NF    10:1 - 10:,
###        GT_UWY_NF    11:1 - 11:,
###        GT_UW_NT     12:1 - 12:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_CTR_NF ,
###        GT_END_NT ,
###        GT_SEC_NF ,
###        GT_UWY_NF ,
###        GT_UW_NT
###/INFILE ${ESF_IADPERICASE_INI} 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###NSTEP=${NJOB}_56
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE INI ASS and RETRO Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_55_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_45_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
#####SORT_O="${ESF_EPOSOCI_INI}  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT
###
###
##### 
###
###NSTEP=${NJOB}_57
#### Begin sort
####-----------------------------------------------------------------------------
###LIBEL="Generate  ESF_EPOSOCI_INI : FILTER ON PRS 751 AND ACMTRS_NT"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_56_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
#####SORT_O="${ESF_EPOSOCI_INI} 2000 1"
###INPUT_TEXT $SORT_CMD <<EOF
###/FIELDS SSD_CF 1:1 - 1:,
###        ESB_CF 2:1 - 2:,
###        BALSHEY_NF 3:1 - 3:,
###        BALSHRMTH_NF 4:1 - 4:,
###        BALSHRDAY_NF 5:1 - 5:,
###        TRNCOD_CF 6:1 - 6:,
###        DBLTRNCOD_CF 7:1 - 7: ,
###        CTR_NF 8:1 - 8:,
###        END_NT 9:1 - 9:,
###        SEC_NF 10:1 - 10:,
###        UWY_NF 11:1 - 11: ,
###        UW_NT 12:1 - 12:,
###        OCCYEA_NF 13:1 - 13:,
###        ACY_NF 14:1 - 14:,
###        SCOSTRMTH_NF 15:1 - 15:,
###        SCOENDMTH_NF 16:1 - 16:,
###        CLM_NF 17:1 - 17:,
###        CUR_CF 18:1 - 18:,
###        AMT_M 19:1 - 19: EN 15/3,
###        CED_NF 20:1 - 20:,
###        BRK_NF 21:1 - 21:,
###        PAY_NF 22:1 - 22:,
###        KEY_NF 23:1 - 23:,
###        RETCTR_NF 24:1 - 24:,
###        RETEND_NT 25:1 - 25:,
###        RETSEC_NF 26:1 - 26:,
###        RTY_NF 27:1 - 27:,
###        RETUW_NT 28:1 - 28:,
###        RETOCCYEA_NF 29:1 - 29:,
###        RETACY_NF 30:1 - 30:,
###        RETSCOSTRMTH_NF 31:1 - 31:,
###        RETSCOENDMTH_NF 32:1 - 32:,
###        RCL_NF 33:1 - 33:,
###        RETCUR_CF 34:1 - 34:,
###        RETAMT_M 35:1 - 35: EN 15/3,
###        PLC_NT 36:1 - 36 :,
###        ACMTRS_NT_F2                          2:1  - 2:,
###        DETTRS_CF_F2                          3:1  - 3:,
###        all_cols_F1                           1:1  - 49:
###/joinkeys
###       TRNCOD_CF
###/INFILE ${DFILT}/${NJOB}_13_${IB}_FTRSLNK_TRNCOD_EBS_INI.dat 500 1 "~"
###/joinkeys
###       DETTRS_CF_F2
###/JOIN UNPAIRED LEFTSIDE
###/OUTFILE ${SORT_O}
###/REFORMAT
###        leftside:all_cols_F1
###        ,rightside:PRS_CF_F2
###        ,rightside:ACMTRS_NT_F2
###exit
###EOF
###SORT
###
###
###
###NSTEP=${NJOB}_58
#### Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_O.dat
####-----------------------------------------------------------------------------
###LIBEL="Current GTR File Sort, Filter INI..."
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_57_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1" 
###SORT_O="${ESF_EPOSOCI_INI} 2000 1" 
###INPUT_TEXT $SORT_CMD <<EOF
###/FIELDS 	SSD_CF 							  1:1 - 1:,
###					ESB_CF 				      2:1 - 2:,
###					BALSHEY_NF 		          3:1 - 3:,
###					BALSHRMTH_NF 	          4:1 - 4:,
###					BALSHRDAY_NF 	          5:1 - 5:,
###					TRNCOD_CF 			      6:1 - 6:,
###					DBLTRNCOD_CF 	          7:1 - 7:,
###					CTR_NF 				      8:1 - 8:,
###					END_NT 				      9:1 - 9:,
###					SEC_NF 				      10:1 - 10:,
###					UWY_NF 				      11:1 - 11:,
###					UW_NT 					  12:1 - 12:,
###					OCCYEA_NF 			      13:1 - 13:,
###					ACY_NF 				      14:1 - 14:,
###					SCOSTRMTH_NF 	          15:1 - 15:,
###					SCOENDMTH_NF 	          16:1 - 16:,
###					CLM_NF 				      17:1 - 17:,
###					CUR_CF 				      18:1 - 18:,
###					AMT_M 					  19:1 - 19: EN 15/3,
###					CED_NF 				      20:1 - 20:,
###					BRK_NF 				      21:1 - 21:,
###					PAY_NF 				      22:1 - 22:,
###					KEY_NF 				      23:1 - 23:,
###					RETCTR_NF 			      24:1 - 24:,
###					RETEND_NT 			      25:1 - 25:,
###					RETSEC_NF 			      26:1 - 26:,
###					RETRTY_NF 				  27:1 - 27:,
###					RETUW_NT 			      28:1 - 28:,
###					RETOCCYEA_NF 	          29:1 - 29:,
###					RETACY_NF 			      30:1 - 30:,
###					RETSCOSTRMTH_NF           31:1 - 31:,
###					RETSCOENDMTH_NF           32:1 - 32:,
###					RCL_NF 				      33:1 - 33:,
###					RETCUR_CF 			      34:1 - 34:,
###					RETAMT_M 			      35:1 - 35: EN 15/3,
###                    all_cols_F1               1:1  - 49:         
###					PLC_NT                    36:1 - 36 :,
###                    PRS_CF_F2                 50:1 - 50:,
###        	        ACMTRS_NT_F2              51:1 - 51:      	
###/CONDITION  IS_PRS_EBS_INI ( PRS_CF_F2 = "740"  and ACMTRS_NT_F2 = "101")   
###/OUTFILE ${SORT_O}
###/INCLUDE IS_PRS_EBS_INI 
###/REFORMAT  all_cols_F1  
###exit
###EOF
###SORT
###
#####
###
###fi
###
##### REMOVE AE EBS INI FROM AE EBS GLOBAL :



NSTEP=${NJOB}_60
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Working table truncate"
ISQL_BASE="BEST"
ISQL_QRY="truncate table BTRAV..EST_ESPJ0090_TACCSUP"
ISQL

#[022]
NSTEP=${NJOB}_61
#Generate the list of contract/section/UWY/UWY order/Endorsement  with signed fund held
#-----------------------------------------------------------------------------
LIBEL="Generation of the list of contracts with signed fund held"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FCTRFWH}
BCP_QRY="execute BEST..PsACCRETTRN_FWH_01 '${TYPEINV}', '${INVCONSO_D}'"
BCP

#[022]
NSTEP=${NJOB}_63
#Generate data having PATCAT_CT= FWH  and PATTYP_CT = RAT and the patterns necessary for the calculation of fund held investment income 
#-----------------------------------------------------------------------------
LIBEL="Generation of data for calculation of fund held investment income"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERNFWH}
BCP_QRY="execute BEST..PsFPATTERNFWH_01 '${CRE_D}', 'CSF', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

# Generation d'un fichier temporaire de PLACEMENT via la PROC nouvelle PsPLACEMT_22 	[021]
NSTEP=${NJOB}_65
#------------------------------------------------------------------------------
LIBEL="Generate Placement FILE to Compute Future for Retro NP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BEST..PsPLACEMT_22 "
BCP_O=${EPO_FPLACEMT22}
BCP

#[023] BCP_QRY="exec BSAR..PsRETITDPRM_01 '${ICLODAT_D}', ${SSD_CF}"

# Generation du fichier des ITDPREMIUM ACTUAL et DES UPR ACTUAL via la Procedure Stockee BEST..PsRETITDPRM_01 [021]
NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="Generate Retro ITD PREMIUM Actual And UPR Actual FILE"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BEST..PsRETITDPRM_01 '${ICLODAT_D}', ${SSD_CF}"
BCP_O=${EPO_RETITDPRM_UPR_ACT}
BCP

#[031]
if [ ${NORME_CF} = "I4I" ]  
then 

	NSTEP=${NJOB}_71
	#Generation of CADVPERIESB0 File
	#-----------------------------------------------------------------------------
	LIBEL="Current Generation of CADVPERIESB0 Perimeter File..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O="$DFILT/${NSTEP}_${IB}_CADVPERIESB0_O.dat"
	BCP_QRY="select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from bfac..tcontr a, BREF..TBATCHSSD b
	         where ctrsts_ct in ( 14, 16, 17, 19)
	         and   a.SSD_CF=b.SSD_CF
	         and   b.BATCHUSER_CF = suser_name()
	         select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from btrt..tcontr a, BREF..TBATCHSSD b
	         where ctrsts_ct in ( 14, 16, 17, 19)
	         and   a.SSD_CF=b.SSD_CF
	         and   b.BATCHUSER_CF = suser_name()"
	BCP
	
	NSTEP=${NJOB}_72
	# Begin sort
	#------------------------------------------------------------------------------
	LIBEL="Sort of CADVPERIESB0 -> EST_CADVPERIESB0 perimeter file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_71_${IB}_CADVPERIESB0_O.dat"
	SORT_O="${EPO_CADVPERIESB0}"
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF 1:1 - 1:,
 END_NT 2:1 - 2:,
 UWY_NF 3:1 - 3:,
 UW_NT  4:1 - 4:
/KEYS CTR_NF,
 END_NT,
 UWY_NF,
 UW_NT
exit
EOF
	SORT
fi

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#[025] Si pas inventaire EBS, on quitte
if [ ${NORME_CF} != "EBS" ]  
then 
	JOBEND
fi
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

#[017][20][031]
NSTEP=${NJOB}_75
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Transfer of the table TCTREST in file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FCTREST0}
BCP_QRY="execute BEST..PsSECTION_16 ${PRS_CF}, '${INVCONSO_D}'"  # [020] [024]
BCP

#[004] Si inventaire EBS
NSTEP=${NJOB}_80
#Download of TSEGEST table with screen on the subsidary and the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of TSEGEST for Solvency Social in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGEST_SOLVENCY}
BCP_QRY="execute BEST..PsSECTION_13 'I', '${TYPESEG}' , '${TYPESEG2}' "
BCP

#[015]
NSTEP=${NJOB}_90
# Extraction des Postes Comtpables EBS TRSLNK Regroupement 720
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables EBS TRSLNK  Regroupement 720"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FTRSLNK8}
BCP_QRY="exec BEST..PsTRSLNK_05"
BCP

NSTEP=${NJOB}_100
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FSEGPATTERN File for BDT..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERN_BDT}
BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'BDT', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

#[010]
NSTEP=${NJOB}_110
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FSEGPATTERN File for CSF..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERN_CSF}
BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'CSF', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

#[011]
NSTEP=${NJOB}_120
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FSEGPATTERN File for ICR..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERN_ICR}
BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'ICR', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

#[010]
NSTEP=${NJOB}_130
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FSEGPATTERN File for DSC..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERN_DSC}
BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'DSC', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

NSTEP=${NJOB}_140
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="SOLVENCY Generation of FSEGPATTERN File for INF..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FSEGPATTERN_INF}
BCP_QRY="exec BEST..PsFPATTERNSII_02 '${CRE_D}', 'INF', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

NSTEP=${NJOB}_150
#Download of ULAERAT table with screen on the subsidary and the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of ULAERAT for Solvency Social in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FULAERAT}
BCP_QRY="execute BEST..PsULAERAT_01 '${TYPEINV}', '${INVCONSO_D}'"
BCP

NSTEP=${NJOB}_160
#Download of FRISKMSII table with screen on the subsidary and the segment type
#-----------------------------------------------------------------------------
LIBEL="Download of FRISKMSII for Solvency Social in progress ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EPO_FRISKMSII}
BCP_QRY="execute BEST..PsFRISKMSII_01 '${TYPEINV}', '${INVCONSO_D}'"
BCP

#DEB [014] [016]
#	#[013]
#	NSTEP=${NJOB}_100
#	#-----------------------------------------------------------------------------
#	LIBEL="FSEGEST file sort by Segment/UW Year/Currency"
#	SORT_WDIR=${SORTWORK}
#	SORT_CMD=`CFTMP`
#	SORT_I=${EPO_FSEGEST_SOLVENCY}
#	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FSEGEST_SOLVENCY_O.dat
#	INPUT_TEXT ${SORT_CMD} <<EOF
#	/FIELDS SSD_CF    1:1 - 1:EN
#	       ,SEG_NF    2:1 - 2:
#	       ,UWY_NF    3:1 - 3:
#	       ,AMORAT_CT 8:1 - 8:
#	/KEYS SSD_CF
#	     ,SEG_NF
#	     ,UWY_NF
#	/CONDITION BOOK AMORAT_CT = "R"
#	/INCLUDE BOOK
#	exit
#EOF
#	SORT

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
LIBEL="FSEGEST file sort by Segment/UW Year/Currency"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FSEGEST_SOLVENCY}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FSEGEST_SOLVENCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1:EN
       ,SEG_NF    2:1 - 2:
       ,UWY_NF    3:1 - 3:
       ,AMORAT_CT 8:1 - 8:
       ,SEGTYP_CT 9:1 - 9:
/KEYS SSD_CF
     ,SEG_NF
     ,UWY_NF
/CONDITION BOOK (AMORAT_CT = "R" OR AMORAT_CT = "S") AND ( SEGTYP_CT != "V" AND SEGTYP_CT != "W" AND SEGTYP_CT != "X" ) 
/INCLUDE BOOK
exit
EOF
SORT
# FIN [014] [016]

NSTEP=${NJOB}_180
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of the ultimates file for ${TYPEINV} EBS"
PRG=ESTC2055
export ${PRG}_I1=${EPO_FULTIMATES}
export ${PRG}_I2=${DFILT}/${NJOB}_170_${IB}_SORT_FSEGEST_SOLVENCY_O.dat
export ${PRG}_O1=${EPO_FULTIMATESSII}
EXECPRG


## [027]

#BCP_QRY="execute BEST..PsLORETFACTOR_02  '${ICLODAT_D}'"

## [030]

### [027]
##NSTEP=${NJOB}_185
### Begin Bcp
###------------------------------------------------------------------------------
##LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR STANDARD"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${ESF_FLORETFACTOR_STD} 
##BCP_QRY="execute BEST..PsLORETFACTOR_02  '${PARM_ICLODAT_D}'"
##BCP
##
### [027]
##NSTEP=${NJOB}_190
### Begin Bcp
###------------------------------------------------------------------------------
##LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR AT INI"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${ESF_FLORETFACTOR_INI}
##BCP_QRY="execute BEST..PsLORETFACTOR_01  '${PARM_ICLODAT_D}'"
##BCP
##


###########################################################################
# [025] Now process FCTREST 
###########################################################################

########################################################################
#[025] [026] Start  manage FCTREST [029]

NSTEP=${NJOB}_200
# FCTREST0 filter on type 'F' records
#-----------------------------------------------------------------------------
LIBEL="FCTREST0 filter on type 'F' and 'A' records DESCENDING on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTREST0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST0F_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST0A_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:8,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:,
        ORICOD_LS 17:1 - 17:,
        CREUSR_CF 19:1 - 19:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D DESC,
      ADMMOD_CT
/CONDITION TYPEF ADMMOD_CT = "F" AND CLODAT_D = "${INVCONSO_D}"
/CONDITION TYPEA PRS_CF = "${PRS_CF}" and ADMMOD_CT = "A" and ORICOD_LS != "CloP" 
/OUTFILE ${SORT_O}
/INCLUDE TYPEF
/OUTFILE ${SORT_O2}
/INCLUDE TYPEA
exit
EOF
SORT

NSTEP=${NJOB}_210
# We keep only the last versus of each key for a quarter for type 'F' based on CRE_D
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter for type 'F' based on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_FCTREST0F_O.dat 1000 1"
SORT_O="${EPO_FCTRESTF} 1000 1 OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:8,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_220
# We keep only the last versus of each key for a quarter for type 'A' based on CRE_D
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter for type 'A' based on CRE_D"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_FCTREST0A_O.dat 1000 1"
SORT_O="${EPO_FCTRESTA} 1000 1 OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:8,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_230
# execksh
#------------------------------------------------------------------------------
LIBEL="cp ${EPO_FCTRESTF} keep original file on ${EPO_FCTRESTF0}"
EXECKSH_MODE=P
EXECKSH "cp ${EPO_FCTRESTF} ${EPO_FCTRESTF0}"

#[042]
ERROR_EPO_FCTRESTA=0
if [ ! -s ${EPO_FCTRESTA} ]
then
	# JOBEND
     ERROR_EPO_FCTRESTA=1
fi

#############################################################################
# The following process is done to omit records F that are processed 
# because for same key we can have a record type A that replace previous record type F
#############################################################################
#[042]
if [[ $ERROR_EPO_FCTRESTA != 1 ]]
then

NSTEP=${NJOB}_240
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort by key section and CLODAT/ACMTRS/CRE_D DESC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FCTRESTF}
SORT_I2=${EPO_FCTRESTA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       9:1 -  9:EN,
        CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        CLODAT_D    16:1 - 16:,
        PRS_CF       7:1 -  7:,
        ACMTRS_NT    8:1 -  8:,
        CRE_D        6:1 -  6:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT, CRE_D DESC
exit
EOF
SORT

NSTEP=${NJOB}_250
# We keep only the last versus of each key for a quarter
#-----------------------------------------------------------------------------
LIBEL="We keep only the last versus of each key for a quarter F or A"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_240_${IB}_SORT_FCTREST_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1AF_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       9:1 -  9:EN,
        CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        CLODAT_D    16:1 - 16:,
        PRS_CF       7:1 -  7:,
        ACMTRS_NT    8:1 -  8:,
        CRE_D        6:1 -  6:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_260
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Keep only records mode F"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_SORT_FCTREST1AF_O.dat 500 1"
SORT_O="${EPO_FCTRESTF} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       9:1 -  9:EN,
        CTR_NF       1:1 -  1:,
        END_NT       2:1 -  2:,
        SEC_NF       3:1 -  3:,
        UWY_NF       4:1 -  4:,
        UW_NT        5:1 -  5:,
        CRE_D        6:1 -  6:,
        PRS_CF       7:1 -  7:,
        ACMTRS_NT    8:1 -  8:,
        ADMMOD_CT   15:1 -  15:,
        CLODAT_D    16:1 - 16:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CLODAT_D, ACMTRS_NT, CRE_D
/CONDITION ADMMODF ADMMOD_CT = "F"
/OUTFILE ${SORT_O}
/INCLUDE ADMMODF
exit
EOF
SORT

fi

#[025] [026] End manage FCTREST
###########################################################################

STEP=${NJOB}_270
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_NDIC_NCB"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_NDIC_NCB}
BCP_QRY="execute BEST..PsNCBExtractA"
BCP

NSTEP=${NJOB}_280
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_NDIC_NCB_RET"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_NDIC_NCB_RET}
BCP_QRY="execute BEST..PsNCBExtractR"
BCP

#[034]
NSTEP=${NJOB}_290
# Extraction des Postes Comtpables EBS TRSLNK Regroupement 720
#------------------------------------------------------------------------------
LIBEL="Extraction des Postes Comtpables EBS TRSLNK Regroupement 740 a omettre dans annulations et ouvertures"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_GROUPING_TC_TOOMIT}
BCP_QRY="exec BREF..PsTRSLNK_10"
BCP


#### [037] [039] Desact ==>
##
NSTEP=${NJOB}_295
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction des donn�es pour l'application de la Taxe Retro Management"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_TAXRETMGNT}
BCP_QRY="execute BEST..PsTAXRETMGT  '${PARM_ICLODAT_D}' "
BCP

NSTEP=${NJOB}_297
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_GAAPMAP using Norme"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_GAAPMAP}
BCP_QRY="execute BREF..PsGAAPMAP_01 '${NORME_CF}', '${PARM_CRE_D}'"
BCP



NSTEP=${NJOB}_300
# Switch to datawharehouse server
#----------------------------------------------------------------------------
LIBEL="Switch to datawharehouse server ${SRV_2}"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_320
#Generation of FCTRGROLESII File
#-----------------------------------------------------------------------------
LIBEL="FCTRGROLESII Segment File Generation from TUWSEC..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${EPO_FCTRGROLESII}"
BCP_QRY="execute BSAR..PsRISKMARGIN_SEG '${PARM_ICLODAT_D}', 'POS'  with recompile"
BCP


JOBEND

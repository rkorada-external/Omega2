#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Gestion des ecritures de services Post Omega
# nom du script SHELL		: ESPJ0091.cmd
# revision			: $Revision:   1.10  $
# date de creation		: 15/06/2005
# auteur			: J. Ribot
# references des specifications	: SPOT 5085
#-----------------------------------------------------------------------------
# description
#   special entries treatment ( set 78 )
#
# launched by ESPJ0090.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#[01] 17/07/2012 Florent :spot:23390 Solvency II, ajout gestion d'un record plus grand à cause de commentaires, sur les sort venant de TACCSUP
#[02] 12/09/2013 Florent :spot:25427 Closing batches adaptation for centralization, maj step 135 
#[03] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
#[04] 03/12/2015 Florent   :spot:29162 utilisation des ${EPO_FCES} et ${EPO_FPLC} et plus les table BTRAV
#[05] 25/10/2017 R. cassis :spira:61508 Ajout option A dans prog ESTC2333 (A=autre/L=Local)
#[06] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[07] 26/01/2021 : Spira:92735 : EBS automatique retrocession : LO factor not applied to future AE transactions 
#[08] 17/02/2021 : Spira:92592 : I17 AE : LO factor not applied to future AE transactions ; deplacement extraction LOFACTOR de ESPD0061 à ICI
#[09] 03/03/2021 : Spira:92592 : I17 AE : LO factor not applied to future AE transactions : Gestion mode paralle L, P 
#[010] 09/04/2021 : Spira:92736 : I17 AE : LO factor not applied to future AE transactions : Remplacer FTRSLNK par FBOPRSLNK lors appel ESTC2308 
#[011] 26/04/2021 : Spira:95920 : Mise en  Commentaire SWITCH DW des step _120, _125 et _135 
#[012] 16/07/2021 : Spira:95950 : Refonte AE I17 
#[013] 26/07/2021 : Spira:95950  remplacment de ESF_FLORETFACTOR par ESF_FLORETFACTOR_STD pour débloquer le plantage à confirmer 
#[014] 23/08/2021 : Spira:95950  Commentaires rajoutés pour bornes dates d'extraction AE : Prise en compte des paramètres Dates bornes
#[015] 21/09/2021 : Spira:95950  ESPJ0092 Dedie aux AE  IFRS17 : Ajout Filtre AE I17 STD
#[016] 25/10/2021 : Spira:99008  Format LOFACTOR 5 car
#[016] 07/01/2022 : Spira:99999  Fix BUG ITK Augmentation Taille 1000 ==> 2000
#[017] 04/04/2022 : Spira:101057 Manual overwrite of IFRS 17 parameters - Impact on revenue and LO factor
#[018] 22/04/2022 MZM : Spira:101057 Fix Bug
#[019] 05/07/2022 JBD	:	SPIRA 104778 : Build new closing for I17S norm 
#[020] 17/10/2022 MZM : SPIRA 102482: IFRS17 Onerous Q+1 - additional scope
#[021] 20/10/2022 MZM : spira 105660 LO FACTOR Table update process I17 (INV / POS)
#[022] 09/10/2023 MZM : spira 109430 Generation du fichier MERGE LO FACTOR  I17 INI et LOFACTOR STD 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BOOKING_D=$1
ENCONSO_D=$2
CONSOYEA=$3
INVCONSO_D=$4
SUFFTABLE=$5

## TU DEB
##CONSOYEA="2020"
##INVCONSO_D="20210630"

##ESF_FTRSLNK_TXT=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FTRSLNK_TXT_INV_20210930.dat
##ESF_FBOPRSLNK_TXT=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FBOPRSLNK_TXT_INV_20210930.dat
##EPO_FDETTRS=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FDETTRS_INV_20210930.dat
##EPO_FTRSLNK=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FTRSLNK_INV_20210930.dat
##EPO_FBOPRSLNK=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FBOPRSLNK_INV_20210930.dat
##EPO_FCES=/scordata_aenitko2batch/ubeu/perm/T_ESID2500_FCES_INV_20210930.dat
##EPO_FPLC=/scordata_aenitko2batch/ubeu/perm/T_ESID2500_FPLC_INV_20210930.dat
##EPO_FTRANSCODE=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FTRANSCODE_INV_20210930.dat
##EPO_FCURCVSN=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FCURCVSN_INV_20210930.dat
##EPO_FCURCVSNI=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FCURCVSNI_INV_20210930.dat
##EPO_FCURQUOT=/scordata_aenitko2batch/ubeu/perm/T_ESCJ0060_FCURQUOT_INV_20210930.dat
##
##ESF_FLORETFACTOR_INI=/scor/home/u006596/martin/temporaire/T_ESPJ0090_I17G_AEE_RPO_INI_FLORETFACTOR_INI_INV_20210930.dat
##ESF_FLORETFACTOR_STD=/scordata_aenitko2batch/ubeu/perm/T_ESPJ0090_FLORETFACTOR_STD_EBS_INV_20210930.dat
##ESF_IADVPERICASE_STD=/scordata_aenitko2batch/ubeu/perm/T_ESID0560_IADVPERICASE_INV_20211231.dat
##EPO_IADVPERICASE=/scordata_aenitko2batch/ubeu/perm/T_ESFD5020_IADPERICASE_I17G_INI_INV_20210930.dat

## TU FIN

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> NORME_CF...............: ${NORME_CF}"
ECHO_LOG "#===> CONSOYEA...............: ${CONSOYEA}"
ECHO_LOG "#===> INVCONSO_D.............: ${INVCONSO_D}"
ECHO_LOG "#===> PARM_ICLODAT_D.........: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> IDF_CT.................: ${IDF_CT}"
ECHO_LOG "#===> EPO_FCES...............: ${EPO_FCES}"
ECHO_LOG "#===> EPO_FDETTRS............: ${EPO_FDETTRS}"
ECHO_LOG "#===> EPO_FTRANSCODE.........: ${EPO_FTRANSCODE}"
ECHO_LOG "#===> EPO_FTRSLNK............: ${EPO_FTRSLNK}"
ECHO_LOG "#===> ESF_FTRSLNK_TXT........: ${ESF_FTRSLNK_TXT}"
ECHO_LOG "#===> EPO_FBOPRSLNK..........: ${EPO_FBOPRSLNK}"
ECHO_LOG "#===> ESF_FBOPRSLNK_TXT......: ${ESF_FBOPRSLNK_TXT}"
ECHO_LOG "#===> EPO_IADVPERICASE.......: ${EPO_IADVPERICASE}"
ECHO_LOG "#===> ESF_IADVPERICASE_STD...: ${ESF_IADVPERICASE_STD}"

ECHO_LOG "#===> ESF_FLORETFACTOR_STD...: ${ESF_FLORETFACTOR_STD}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI...: ${ESF_FLORETFACTOR_INI}"

ECHO_LOG "#===> ESF_FLORETFACTOR_MRG...: ${ESF_FLORETFACTOR_MRG}"

ECHO_LOG "#===> ESF_FLORETFACTOR.......: ${ESF_FLORETFACTOR}"
ECHO_LOG "#===> DIP_CSM_BU.............: ${DIP_CSM_BU}"
ECHO_LOG "#========================================================================="



##•	and CONTR.CTRINC_D >= @p_clo_date+1
##•	and CONTR.CTRINC_D <= @p_next_clo_date      -- dernier jour du trimestre de closing suivant PARM_BOOKINGNEXT_D

# Job Initialisation
JOBINIT

if [ ${SUFFTABLE} = '0' ]
then
   LOGWRITE 1 "The Table TTECLEDA is ${SUFFTABLE} "

   STEPEND 1
fi

#

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

ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D      ....:${PARM_BOOKING_D}           -- POS EBS    : SPEENNAT_CF = 5   "
ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POS EBS    : SPEENNAT_CF = 5    "

ECHO_LOG "#BORNE DATE_DEB ===> PARM_PSTOMGEND17_D  ....:${PARM_PSTOMGEND17_D}       -- POC EBS    : SPEENNAT_CF = 6   " 
ECHO_LOG "#BORNE DATE_FIN ===> PARM_EBSPSTOMGCONEND_D..:${PARM_EBSPSTOMGCONEND_D}   -- POC EBS    : SPEENNAT_CF = 6    " 



# Borne Inferieure DATE_DEB en fonction type de closing

if  [ "${TYPEINV}" = "INV" ] 
then  
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"     		
     fi         
fi


if  [ "${TYPEINV}" = "POS" ] 
then  
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"     		
     fi              
fi

if [ "${TYPEINV}" = "POC" ] 
then 
 		if  [ "${NORME_CF}" = "I4I" ] 
 		then 
 			PARM_DATE_DEB_D=   "${PARM_PSTOMGEN_D}" 
     	PARM_DATE_FIN_D=   "${PARM_PSTOMGCONEND_D}"   			
 		fi
 		
 		if  [ "${NORME_CF}" = "EBS" ]
 		then
			PARM_DATE_DEB_D=  "${PARM_EBSPSTOMGEND_D}" 
			PARM_DATE_FIN_D=  "${PARM_EBSPSTOMGCONEND_D}" 			
		fi	
			
 		if  [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
 		then
			PARM_DATE_DEB_D=  "${PARM_PSTOMGEND17_D}" 	
			PARM_DATE_FIN_D=  "${PARM_PSTOMGCONEND17_D}" 													
 		fi
fi




###################################################################################################
###   FIN EXTRACTION DES DATES POUR LES PROC DES AE EN FONCTION DU TYPEINV et NORME_CF         ####
###################################################################################################

# [08] Deb Generated LOFACTOR STD on EBS Closing AND LOFACTOR INI ON IFRS17 Closing



########################################################################################
##                    DEB TRT   IFRS17 INCEPTION et STANDARD                         ###
########################################################################################


## [012] DEB TRT I17 ## [020]

## Ajout des conditions d'extractions Pour ONEROUS FORCES :
## PARM_DATE_FIN_D
## PARM_DATE_DEB_D

#BCP_O=${ESF_FLORETFACTOR_INI} 


# [021] Execution de la proc INI deplace dans ESFD5000 BEST..PsLORETFACTOR_0 ==> BEST..PsLORETFACTOR_I17_01

##NSTEP=${NJOB}_03
### Begin Bcp
###------------------------------------------------------------------------------
##LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR AT INI"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_INI_O.dat
##BCP_QRY="execute BEST..PsLORETFACTOR_01  '${PARM_ICLODAT_D}', '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}' "
##BCP


#[017]

### [016]   STEP POUR FORMAT COLONNE LOFACTOR VIA awk
#BCP_O=${ESF_FLORETFACTOR_STD} 

NSTEP=${NJOB}_03A
#------------------------------------------------------------------------------
#LIBEL="FORMAT LOFACTOR" --> ""
#-----------------------------------------------------------------------------
LIBEL="FORMAT LOFACTOR "
AWK_I=${ESF_FLORETFACTOR_5010_INI}
AWK_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_INI_O.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		\$30 = sprintf("%-.5f",\$30);
		print \$0;
	}
exit
EOF
AWK

if [ "${DIP_CSM_BU}" != "" ] && [ -s "${DIP_CSM_BU}" ]
then

NSTEP=${NJOB}_03B
#------------------------------------------------------------------------------
LIBEL=" Move file from FTP location to temporary location(DFILT)"
EXECKSH "cp ${DIP_CSM_BU} ${DFILT}/${NSTEP}_${IB}_BU.dat"

NSTEP=${NJOB}_03C
#------------------------------------------------------------------------------
LIBEL="Convert carriage-returns to Unix"
EXECKSH "dos2unix ${DFILT}/${NJOB}_03B_${IB}_BU.dat"

NSTEP=${NJOB}_03D
#------------------------------------------------------------------------------
LIBEL="Change sep and remove headers"
awk -F "\t" 'OFS="~"  {if (NR != 1 ) print $1,$5,$2,$3,$4,$6,$10,$7,$8,$9,$11,$12,$13,$14,$15,$16,$17,$18}' ${DFILT}/${NJOB}_03B_${IB}_BU.dat > ${DFILT}/${NSTEP}_${IB}_BU_AWK.dat


NSTEP=${NJOB}_03E
LIBEL="JOIN FLORETFACTOR WITH BU FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03A_${IB}_BCP_FLORETFACTOR_INI_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_INI_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:,
        FILLER1          1:1     - 30:,
        FILLER2         31:1     - 31:,
        RCTR_NF         1:1      - 1:,
        REND_NT         2:1      - 2:,
        RSEC_NF         3:1      - 3:,
        RUWY_NF         4:1      - 4:,
        RUW_NT          5:1      - 5:,
        RRETCTR_NF      6:1      - 6:,
        RRETEND_NT      7:1      - 7:,
        RRETSEC_NF      8:1      - 8:,
        RRETRTY_NF      9:1      - 9:,
        RRETUW_NT      10:1      - 10:,
        LOFACTORINI_R  12:1      - 12:
/JOINKEYS
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/INFILE ${DFILT}/${NJOB}_03D_${IB}_BU_AWK.dat 2000 1 "~"
/JOINKEYS
        RCTR_NF,
        RSEC_NF,
        RUWY_NF,
        RUW_NT,
        RRETCTR_NF,
        RRETSEC_NF,
        RRETRTY_NF,
        RRETUW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1, RIGHTSIDE:LOFACTORINI_R, LEFTSIDE:FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_03F
LIBEL="Reformat FLORETFACTOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03E_${IB}_BCP_FLORETFACTOR_INI_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_INI_NOMATCH_O.dat OVERWRITE 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_BCP_FLORETFACTOR_INI_O.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:,
        FILLER1          1:1     - 29:,
        LOFACTORINI_R   30:1     - 30:,
        BULOFACTORINI_R 31:1     - 31:,
        FILLER2         32:1     - 32:
/DERIVEDFIELD
        COMMENT "LOFACTORINI_R"
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/CONDITION BUPROVIDED ( BULOFACTORINI_R = "" )
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, LOFACTORINI_R, FILLER2
/INCLUDE BUPROVIDED
/OUTFILE ${SORT_O2}
/REFORMAT FILLER1, BULOFACTORINI_R, FILLER2
/OMIT BUPROVIDED

exit
EOF
SORT


NSTEP=${NJOB}_03G
LIBEL="merge FLORETFACTOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03F_${IB}_BCP_FLORETFACTOR_INI_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_03F_${IB}_BCP_FLORETFACTOR_INI_NOMATCH_O.dat 2000 1"
SORT_O="${ESF_FLORETFACTOR_INI} OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT

exit
EOF
SORT

else

NSTEP=${NJOB}_03B
# cp ESF_FLORETFACTOR_INI 
#------------------------------------------------------------------------------
LIBEL="copy ${DFILT}/${NJOB}_03A_${IB}_BCP_FLORETFACTOR_INI_O.dat"
EXECKSH "cp ${DFILT}/${NJOB}_03A_${IB}_BCP_FLORETFACTOR_INI_O.dat ${ESF_FLORETFACTOR_INI}"

fi

## Ne traiter que si Groupe en attendant une reflexion ....
## ## Deb Reflexion Mode Parallel Groupe // Parent // Local 


echo "AFFICHE PARM_DATE_DEB_D = ${PARM_DATE_DEB_D} "
echo "AFFICHE PARM_DATE_FIN_D = ${PARM_DATE_FIN_D} "
echo "AFFICHE PARM_BOOKINGNEXT_D = ${PARM_BOOKINGNEXT_D} ; TYPEINV = ${TYPEINV} ; NORME_CF = ${NORME_CF} "

## BCP_QRY="exec BEST..PiESTACCSUP_04 '${BOOKING_D}', '${ENCONSO_D}', '${NORME_CF}'"

####[022]  DEB GENERATION du FICHIER MERGE (CLE CSUE ASS et RET) LOFACTOR_STD et LOFACTOR_INI ==> LOFACTOR_MRG

NSTEP=${NJOB}_04
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-STD not in LORETFACTOR INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LORETFACTOR_STD_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:,
        FILLER1          1:1     - 30:,
        FILLER2         31:1     - 31:,
        RCTR_NF         1:1      - 1:,
        REND_NT         2:1      - 2:,
        RSEC_NF         3:1      - 3:,
        RUWY_NF         4:1      - 4:,
        RUW_NT          5:1      - 5:,
        RRETCTR_NF      6:1      - 6:,
        RRETEND_NT      7:1      - 7:,
        RRETSEC_NF      8:1      - 8:,
        RRETRTY_NF      9:1      - 9:,
        RRETUW_NT      10:1      - 10:,
        LOFACTORINI_R  12:1      - 12:
/JOINKEYS
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/INFILE ${ESF_FLORETFACTOR_INI} 2000 1 "~"
/JOINKEYS
        RCTR_NF,
        RSEC_NF,
        RUWY_NF,
        RUW_NT,
        RRETCTR_NF,
        RRETSEC_NF,
        RRETRTY_NF,
        RRETUW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:FILLER1
exit
EOF
SORT


NSTEP=${NJOB}_04A
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_04_${IB}_SORT_LORETFACTOR_STD_O.dat 2000 1"
SORT_I2="${ESF_FLORETFACTOR_INI} 2000 1"
SORT_O="${ESF_FLORETFACTOR_MRG} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LORETFACTOR_MERGE_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT




### FIN GENERATIOn du FICHIER MERGE LOFACTOR_STD et LOFACTOR_INI ==> LOFACTOR_MRG

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FACCSUP_O.dat
BCP_QRY="exec BEST..PiESTACCSUP_04 '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', '${NORME_CF}'"
BCP

NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Working table truncate BTRAV..EST_ESPJ0090_TACCSUP"
ISQL_BASE="BTRAV"
ISQL_QRY="truncate table BTRAV..EST_ESPJ0090_TACCSUP"
ISQL

#[03]
NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Transformation of service writing file into extended LT format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FACCSUP_O.dat 2000 1" #[01]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat 2000 1" #[01]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRN_NT 1:1 - 1:
       ,ACCTYP_NF 2:1 - 2:
       ,SSD_CF 3:1 - 3:
       ,ESB_CF 4:1 - 4:
       ,ENTPERY_NF 5:1 - 5:
       ,ENTPERMTH_NF 6:1 - 6:
       ,BALSHEY_NF 7:1 - 7:
       ,BALSHRMTH_NF 8:1 - 8:
       ,BALSHRDAY_NF 9:1 - 9:
       ,VALPERY_NF 10:1 - 10:
       ,VALPERMTH_NF 11:1 - 11:
       ,TRNCOD_CF 12:1 - 12:
       ,DBLTRNCOD_CF 13:1 - 13:
       ,CTR_NF 15:1 - 15:
       ,END_NT 16:1 - 16:
       ,SEC_NF 17:1 - 17:
       ,UWY_NF 18:1 - 18:
       ,UW_NT 19:1 - 19:
       ,OCCYEA_NF 20:1 - 20:
       ,ACY_NF 21:1 - 21:
       ,SCOSTRMTH_NF 22:1 - 22:
       ,SCOENDMTH_NF 23:1 - 23:
       ,CLM_NF 24:1 - 24:
       ,CUR_CF 25:1 - 25:
       ,AMT_M 26:1 - 26:
       ,CED_NF 27:1 - 27:
       ,BRK_NF 28:1 - 28:
       ,PAY_NF 29:1 - 29:
       ,KEY_NF 30:1 - 30:
       ,RETCTR_NF 31:1 - 31:
       ,RETEND_NT 32:1 - 32:
       ,RETSEC_NF 33:1 - 33:
       ,RTY_NF 34:1 - 34:
       ,RETUW_NT 35:1 - 35:
       ,PLC_NT 36:1 - 36:
       ,RETOCCYEA_NF 37:1 - 37:
       ,RETACY_NF 38:1 - 38:
       ,RETSCOSTRMTH_NF 39:1 - 39:
       ,RETSCOENDMTH_NF 40:1 - 40:
       ,RCL_NF 41:1 - 41:
       ,RETCUR_CF 42:1 - 42:
       ,RETAMT_M 43:1 - 43:
       ,RTO_NF 44:1 - 44:
       ,INT_NF 45:1 - 45:
       ,RETPAY_NF 46:1 - 46:
       ,RETKEY_CF 47:1 - 47:
       ,COMMAC_LL 49:1 - 49:
       ,SPEENTTYP_CF 54:1 - 54:
       ,SPEENTNAT_CT 55:1 - 55:
       ,EVT_NF 56:1 - 56:
       ,REVT_NF 57:1 - 57:
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD SEPA "~"
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, TRNCOD_CF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CUR_CF
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ZERO, SEPA, ENTPERY_NF, ENTPERMTH_NF, VALPERY_NF, VALPERMTH_NF, TRN_NT, ACCTYP_NF, COMMAC_LL, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT


### AJOUT FICHIER POUR JOINTURE sur FICHIER PARAM pour dissocier INI de STD 



NSTEP=${NJOB}_41
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on TRNCOD_I17 INI ONLY "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_I17.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
     PRS_CF    		    1:1 -  1:,
     ACMTRS_NT    		2:1 -  2:,
     DETTRS_CF    		3:1 -  3:,
     DETTRS8_CF    		3:8 -  3:8    
/CONDITION IS_TRNCOD_I17 ( DETTRS8_CF = "I" OR DETTRS8_CF = "J" OR DETTRS8_CF = "K" OR DETTRS8_CF = "L"  OR DETTRS8_CF = "M" OR DETTRS8_CF = "N") AND (PRS_CF= "740" AND ACMTRS_NT = "101")
/OUTFILE $SORT_O
/INCLUDE IS_TRNCOD_I17
/COPY
exit
EOF
SORT




NSTEP=${NJOB}_42
# Merge PERICASES STD and INI file
#------------------------------------------------------------------------------
LIBEL="Merge PERICASES STD and INI file on CSUE unique"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADVPERICASE} 2000 1"
SORT_I2="${ESF_IADVPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_43
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of PERICASE_MERGE file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_42_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 210:
/KEYS   ALL_F1
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_50
# Begin programme C TYPETRAIT=L/A (local/Autres)
#------------------------------------------------------------------------------
LIBEL="Application of cessions operator"
PRG=ESTC2333
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
GTE_B 1
TYPETRAIT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${EPO_FCES}
export ${PRG}_I3=${EPO_FDETTRS}
export ${PRG}_I4=${EPO_FTRANSCODE}
#export ${PRG}_I5=${EPO_IADVPERICASE}
export ${PRG}_I5=${DFILT}/${NJOB}_43_${IB}_SORT_IADVPERICASE_MERGE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat
EXECPRG



#[07] Applying LOFACTOR

# TRIE du fichier LOFACTOR sur RETCTR,RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_51 
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR_STD BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR_STD.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      LOFACTOR
exit
EOF
SORT

NSTEP=${NJOB}_51B
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR_INI BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR_INI.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      LOFACTOR
exit
EOF
SORT


## GENERATE GTAR100_0 AT INI AND GTAR100 AT STD en fonction du TRNCOD

#/INFILE ${DFILT}/${NJOB}_41_${IB}_FTRSLNK_TRNCOD_I17.dat 500 1 "~"

NSTEP=${NJOB}_52
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort  GTAR100 to GTAR100_I17_INI and GTAR100_I17"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O_I17.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:,
			  all_cols_F1		 		  1:1  - 72:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_41_${IB}_FTRSLNK_TRNCOD_I17.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1
	,rightside:PRS_CF_F2   
	,rightside:ACMTRS_NT_F2   
exit
EOF
SORT



# Applying LOFACTOR I17 

#if  [ ${IDF_CT} = "I17G_AEE_RPO_I17" ]  ||  [ ${IDF_CT} = "I17P_AEE_RPO_I17" ] ||  [ ${IDF_CT} = "I17L_AEE_RPO_I17" ]


## OR (ACMTRS_NT_F2 IS NULL) )  )


##/CONDITION  IS_PRS_I17_STD ( PRS_CF_F2 = "740"  and (ACMTRS_NT_F2 != "101") ) 

NSTEP=${NJOB}_53
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort  GTAR100 to GTAR100_I17_INI and GTAR100_I17_STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_52_${IB}_SORT_GTAR100_O_I17.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O_I17_INI.dat OVERWRITE"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O_I17_STD.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD8_CF 6:8 - 8:,        
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
			  PRS_CF_F2      73:1  - 73:,
			  ACMTRS_NT_F2				74:1  - 74:,
			  DETTRS_CF_F2				75:1  - 75:,
			  all_cols_F1		 		  1:1  - 73:
/KEYS 		RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
					RTY_NF,
					RETUW_NT
/CONDITION  IS_PRS_I17_INI ( PRS_CF_F2 = "740"  and ACMTRS_NT_F2 = "101") 
/CONDITION  IS_PRS_I17_STD ( PRS_CF_F2 != "740"  or ACMTRS_NT_F2 != "101") AND ( TRNCOD8_CF= "I" OR TRNCOD8_CF= "J" OR TRNCOD8_CF= "K" OR TRNCOD8_CF= "L"  OR TRNCOD8_CF= "M" OR TRNCOD8_CF= "N") 
/OUTFILE ${SORT_O}
/INCLUDE IS_PRS_I17_INI  
/OUTFILE ${SORT_O2}
/OMIT IS_PRS_I17_INI   
exit
EOF
SORT


##[012] TRT I17 INI


########################################################################################
##                    DEB TRT IFRS17 INCEPTION                                       ###
########################################################################################



NSTEP=${NJOB}_54
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_53_${IB}_SORT_GTAR100_O_I17_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT
#


NSTEP=${NJOB}_56
# Join and sort of  GTAR100 File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current GTAR100_O File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_53_${IB}_SORT_GTAR100_O_I17_INI.dat 2000 1"
#SORT_I="${DFILT}/${NJOB}_52_${IB}_SORT_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_51B_${IB}_SORT_FLORETFACTOR_INI.dat 2000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   


NSTEP=${NJOB}_57
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_56_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_58
# SORT UNIQUE of GTAR100_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_57_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_59
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofactor to GTAR100..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_57_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat
#export ${PRG}_I2=${EPO_FTRSLNK}
export ${PRG}_I2=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_FACTOR_O_I17_INI.dat
EXECPRG


# END Modif [07]

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_59_${IB}_ESTC2308_GTAR100_FACTOR_O_I17_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, TRNCOD_CF, CUR_CF, RETOCCYEA_NF, RCL_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT , OCCYEA_NF, CLM_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF
exit
EOF
SORT


########################################################################################
##                    FIN TRT IFRS17 INCEPTION                                       ###
########################################################################################

#fi  # Fin traitement INI


########################################################################################
##                    DEB TRT IFRS17 STANDARD                                        ###
########################################################################################


NSTEP=${NJOB}_70
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2334
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 0
BALSHTYEA_NF ${CONSOYEA}
GTE_B 1
PRS 50 
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_GTAR100_FACTOR_O_I17_INI.dat
export ${PRG}_I2=${EPO_FPLC}
export ${PRG}_I3=${EPO_FCURCVSNI}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCURCVSN}
export ${PRG}_I6=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1_I17_INI.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2_I17_INI.dat
EXECPRG


#[03]
NSTEP=${NJOB}_80
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTAR_O1_I17_INI.dat  2000 1 "
SORT_I2="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTARMAJ_O2_I17_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O_I17_INI.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        ENTPERY_NF 42:1 - 42:,
        ENTPERMTH_NF 43:1 - 43:,
        VALPERY_NF 44:1 - 44:,
        VALPERMTH_NF 45:1 - 45:,
        TRN_NT 46:1 - 46:,
        ACCTYP_NF 47:1 - 47:,
        BALSHEY_NF 48:1 - 48:,
        BALSHRMTH_NF 49:1 - 49:,
        BALSHRDAY_NF 50:1 - 50:,
        COMMAC_LL 51:1 - 51:,
        SPEENTTYP_CF 52:1 - 52:,
        SPEENTNAT_CT 53:1 - 53:,
        EVT_NF 54:1 - 54:,
        REVT_NF 55:1 - 55:
/KEYS   SSD_CF,
        ESB_CF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ENTPERY_NF,
        ENTPERMTH_NF,
        VALPERY_NF,
        VALPERMTH_NF,
        TRN_NT,
        ACCTYP_NF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        COMMAC_LL,
        SPEENTTYP_CF,
        SPEENTNAT_CT,
        EVT_NF,
        REVT_NF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


# [012] FIN TRT I17 INI 

# DEB TRT I17 STD 


NSTEP=${NJOB}_85
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_53_${IB}_SORT_GTAR100_O_I17_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O_I17_STD.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT
#


NSTEP=${NJOB}_90
# Join and sort of  GTAR100 File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current GTAR100_O File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_53_${IB}_SORT_GTAR100_O_I17_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_51_${IB}_SORT_FLORETFACTOR_STD.dat 2000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   


NSTEP=${NJOB}_95
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_100
# SORT UNIQUE of GTAR100_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_110
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofactor to GTAR100..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_95_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat
export ${PRG}_I2=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_FACTOR_O_I17_STD.dat
EXECPRG


NSTEP=${NJOB}_120
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2308_GTAR100_FACTOR_O_I17_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, TRNCOD_CF, CUR_CF, RETOCCYEA_NF, RCL_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT , OCCYEA_NF, CLM_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF
exit
EOF
SORT

########################################################################################
##                    FIN TRT IFRS17 STANDARD                                        ###
########################################################################################


#fi  # Fin traitement STD




NSTEP=${NJOB}_130
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2334
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 0
BALSHTYEA_NF ${CONSOYEA}
GTE_B 1
PRS 50 
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_GTAR100_FACTOR_O_I17_STD.dat
export ${PRG}_I2=${EPO_FPLC}
export ${PRG}_I3=${EPO_FCURCVSNI}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCURCVSN}
export ${PRG}_I6=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1_I17_STD.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2_I17_STD.dat
EXECPRG


#[03]
NSTEP=${NJOB}_140
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTC2334_GTAR_O1_I17_STD.dat  2000 1 "
SORT_I2="${DFILT}/${NJOB}_130_${IB}_ESTC2334_GTARMAJ_O2_I17_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O_I17_STD.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        ENTPERY_NF 42:1 - 42:,
        ENTPERMTH_NF 43:1 - 43:,
        VALPERY_NF 44:1 - 44:,
        VALPERMTH_NF 45:1 - 45:,
        TRN_NT 46:1 - 46:,
        ACCTYP_NF 47:1 - 47:,
        BALSHEY_NF 48:1 - 48:,
        BALSHRMTH_NF 49:1 - 49:,
        BALSHRDAY_NF 50:1 - 50:,
        COMMAC_LL 51:1 - 51:,
        SPEENTTYP_CF 52:1 - 52:,
        SPEENTNAT_CT 53:1 - 53:,
        EVT_NF 54:1 - 54:,
        REVT_NF 55:1 - 55:
/KEYS   SSD_CF,
        ESB_CF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ENTPERY_NF,
        ENTPERMTH_NF,
        VALPERY_NF,
        VALPERMTH_NF,
        TRN_NT,
        ACCTYP_NF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        COMMAC_LL,
        SPEENTTYP_CF,
        SPEENTNAT_CT,
        EVT_NF,
        REVT_NF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


# FIN TRT I17 STD


#[03]
NSTEP=${NJOB}_150
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_FACCSUP_O_I17_INI.dat 2000 1 "   
SORT_I2="${DFILT}/${NJOB}_140_${IB}_SORT_FACCSUP_O_I17_STD.dat 2000 1 "   
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 2000 1" #[01]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, AMT_M 19:1 - 19:, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:, ENTPERY_NF 42:1 - 42:, ENTPERMTH_NF 43:1 - 43:, VALPERY_NF 44:1 - 44:, VALPERMTH_NF 45:1 - 45:, TRN_NT 46:1 - 46:, ACCTYP_NF 47:1 - 47:, BALSHEY_NF 48:1 - 48:, BALSHRMTH_NF 49:1 - 49:, BALSHRDAY_NF 50:1 - 50:, COMMAC_LL 51:1 - 51:, SPEENTTYP_CF 52:1 - 52:, SPEENTNAT_CT 53:1 - 53:, EVT_NF 54:1 - 54:, REVT_NF 55:1 - 55:
/COPY
/CONDITION TYP1 ACCTYP_NF EQ "1"
/DERIVEDFIELD SEPA "~"
/DERIVEDFIELD TYP_NF IF TYP1 THEN "00" ELSE "98" CHAR 2
/DERIVEDFIELD ZERO "0" CHAR 1
/DERIVEDFIELD VIDE ""
/DERIVEDFIELD CRE_D "${CRE_D}"
/DERIVEDFIELD LSTUPDUSR_CF "AG"
/OUTFILE ${SORT_O}
/REFORMAT TYP_NF, SEPA, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, ZERO, SEPA, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, TRN_NT, COMMAC_LL, CRE_D, SEPA, VIDE, SEPA, CRE_D, SEPA, LSTUPDUSR_CF, SEPA, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT



NSTEP=${NJOB}_160
# Selection of the largest TRN_NT from TACCSUP
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from TACCSUP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select isnull(max(TRN_NT),0) from BEST..TACCSUP"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O.dat
BCP

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${BCP_O}`

NSTEP=${NJOB}_170
# Adding an identity column to the Acceptance TL
#-----------------------------------------------------------------------------
LIBEL="Adding an identity column to the Accetance TL"
PRG=ESTC8800
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
TRN_NT ${TRNMAX_NT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_SORT_FACCSUP_O.dat
#export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_FACCSUP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCSUP_O.dat
EXECPRG


NSTEP=${NJOB}_180
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Transfer of service writing file into BEST..TACCSUP table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_170_${IB}_ESTC8800_FACCSUP_O.dat
#BCP_I=${DFILT}/${NJOB}_95_${IB}_ESTC8800_FACCSUP_O.dat
BCP_TABLE="BEST..TACCSUP"
BCP

NSTEP=${NJOB}_190
# Update of double entry transaction code
#------------------------------------------------------------------------------
LIBEL="Update of double entry transaction code"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuACCSUP_02 ${TRNMAX_NT}"
ISQL


## [ 012] FIN TRT I17
########################################################################################
##                    FIN TRT   IFRS17 INCEPTION et STANDARD                         ###
########################################################################################


JOBEND
  

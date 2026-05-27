#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow 
# nom du script SHELL           : ESID3703A.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#               Calculate cashflow in a separate chain/job (this part is extracted from ESID3703.cmd) 
#
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[02] 27/07/2012 :spot:23937 -=Dch=-   Ajout de touch pour cr¦ation des fichiers vides en d¦but de job, puis v¦rification en sortie de ESTC1056: si fichier vide : fin du job
#[03] 02/08/2012 :spot:24041 -=Dch=-   Remplacement de MPPINC par MNAUTO dans la jointure ( segment)
#[04] 28/08/2012 :spot:24041 -=JFVDV=- Am¦nagements (comment out / undo comment out)
#[05] 03/09/2012 :spot:24041 R. Cassis Reformat tri pour format FTECLEDSII
#[06] 07/09/2012 :spot:24041 Florent   modif email Philippe de ce jour
#[07] 14/09/2012 :spot:24041 -=Dch=-   Modif des awk pour le fichier GTCUMUL ( step 5) avant traitement ESTC1056 et suivant et ajout des pivots dans EST1057 et 58
#[07] 19/09/2012 :spot:24041 -=Dch=-   Ajout des premium reserve et modification des fichiers GTAASII et GTARSII dans les tri-fusion
#[08] 20/01/2013 :spot:24698 -=PhP=-   corrections pour la conso
#[09] 20/01/2013 :spot:24864 -=PhP=-   corrections pour la conso
#[10] 14/11/2013 :spot:25427 R. Cassis modifs centralization des bases
# Restauration ancienne version
#[11] 28/04/2014 :spot:26653 PPEZOUT   Echanges internes Solvency
#[12] 28/05/2014 :spot:26838 Benjeddou Echanges internes Solvency
#[13] 21/10/2013 :spot:26391 Cyrille   Application du pattern ICR (Incurred Incremental) pour les IBNR. Doit etre identique ¦ l'application du pattern CSF (cash flow) pour les Paid and Premium Cumulatives
#[14] 17/02/2015 :spot:26391 Cyrille   Ajout du retrocessionaire a la cle dur fichier RMNTP
#[15] 01/06/2015 :spot:26391 Roger     On ne prend pas les postes 2A4261.. dont le montant r¦tro est positif
#[16] 02/06/2015 :spot:26391 Roger     Correction sur fichier en entr¦e.
#[17] 25/06/2015 :spot:28941 PP/Roger  Diverses corrections pour EST49A2 EBS ULAE et Risk Management - refonte du shell
#[18] 03/09/2015 :spot:28941 Philippe  ajout code ¦tablissement dans les echanges internes SII
#[19] 02/11/2015 :spot:29615 P PEZOUT
#[20] 03/06/2016 :spot:30543 Florent   on passe ¦ 65 ann¦es et ce fichier devient la r¦f¦rences pour les PAATERNSII !
#[21] 18/11/2016 :spira:57799 Florent  Mise au format ¦ 71 colonnes pour les fichiers EST_DLDSIIGT*
#[22] 13/11/2017 :spira:64660 Roger    gestion du RTO et PLC dans le fichier R¦tro EST_DLDSIIGTR et EST_DLDSIIGTAR
#[23] 28/06/2018 :spira:69426 JYP      part of cashflow calculation extracted from ESID3703.cmd
#[24] 03/09/2018 Charles Socie 	: EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
#[25] 05/02/2019 Quentin Desmettre : EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
#[26] 22/07/2019 Charles Socie 	: EXT-IFRS17-903121  REQ 11.4 : craetion of new ouput EST_GTSII_GLOBAL_CASHFLOW
#[27] 17/09/2019 JYP : new version compatible I17G archi , called by ESFD3610 too
#[28] 27/09/2019 JYP : SPIRA 70537: closing at inception: use norme_cf = I17G/P/L
#[29] 15/10/2019 LEL : SPIRA 70537: regarding to Kouassi's mail we cancel puting norme to I17G for new lignes calculated at Inception
#[30] 15/11/2019 KBagwe:SPIRA 82639: EBS - Funds Held impact on Discount - Revert. STEP 67.
#[31] 29/11/2019 Charles Socie : SPIRA 77191 : IFRS17 Bad debt management : discount at lock in rate (REQ11.4)
#[32] 29/04/2020 Charles Socie : SPIRA 86189 : 11.2 - INI - ULAE - RMNTP missing add ouput EST_GTSII_CLACC_CASHFLOW
#[33] 30/04/2020 Charles Socie : SPIRA 79381 : Bad Dept
#[34] 07/05/2020 Charles Socie : SPIRA 83206  IFRS17 REQ11.7 For contract incepting before closing date please adapt the pattern used for discounting add pericase to ESTC1056B
#[35] 28/07/2020 JYP SPIRA 87660 : mapping for ICR at Inception
#[36] 31/08/2020 Charles Socie : SPIRA 88975  IFRS17 add Retropericase to ESTC1056B
#[035] 02/11/2020 M.NAJI SPIRA 91421  : optimisation, refonte de des job ESID3703A 
#[037] 29/10/2021 JYP SPIRA 98044 : bugfix optimisation 
#[37 from 3703A] 27/01/2021 Charles Socie : SPIRA 92917  IFRS 17 Transition Init: Adapt RMNTP
#[40] 02/16/2022 JBD :  SPIRA 100572 - keep only gr 309 - 320 with ICR patcat into file ${ESF_GTSII_ICR} 
#[041] 18/02/2022 MZM FIX UAT : SPIRA 101403 MAJ Taille segment de tri 1000 1 ==> 2000 1 et  500 1 ==> 2000 1
#[042] 30/06/2022 JYP/TD: SPIRA 104751 issue with CONTEXT INI
#[043] 01/07/2022 JYP/TD: SPIRA 104751 issue with CONTEXT INI
#[044] 08/09/2023 MZM : SPIRA 109430 IO DUM : MERGE CASHFLOWS PREVIOUS DUMMY AND NEW DUMMY GENERATE FROM ESFD3610 IDF_CT =  I17G/L/P/S_CSF_MRG_INI
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3
IDF_CT=$4

#[010]
TRIM_NF=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`

touch ${DFILT}/${NCHAIN}_vide.dat

# Job Initialisation
JOBINIT


if [ "${CONTEXT_CT}" == "" ]
then
	CONTEXT_CT="EMPTY"
fi 


if [ "${PARM_IS_TRN}" == 'YES' ]
then
	CONTEXT_CT=TRN
fi 

IS_EST_FSEGPATTERN_CSF_EMPTY=1
if [ -s ${EST_FSEGPATTERN_CSF} ]
then
	IS_EST_FSEGPATTERN_CSF_EMPTY=0
fi

IS_EST_FSEGPATTERN_ICR_EMPTY=1
if [ -s ${EST_FSEGPATTERN_ICR} ]
then
	IS_EST_FSEGPATTERN_ICR_EMPTY=0
fi



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV........................: ${TYPEINV}"
ECHO_LOG "#===> NORME..........................: ${NORME}"
ECHO_LOG "#===> IDF_CT.........................: $IDF_CT "
ECHO_LOG "#===> CONTEXT_CT.....................: ${CONTEXT_CT} "
ECHO_LOG "#===> CRE_D..........................: ${CRE_D}"
ECHO_LOG "#===> TRIM_NF........................: ${TRIM_NF}"
ECHO_LOG "#===> ICLODAT_D......................: ${ICLODAT_D}"
ECHO_LOG "#===> IS_EST_FSEGPATTERN_CSF_EMPTY...: ${IS_EST_FSEGPATTERN_CSF_EMPTY}"
ECHO_LOG "#===> IS_EST_FSEGPATTERN_ICR_EMPTY...: ${IS_EST_FSEGPATTERN_ICR_EMPTY}"
ECHO_LOG "#....................... INPUT ..........................................."
ECHO_LOG "#===> EST_DLCUMGTAAR.................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> EST_FCURSII....................: ${EST_FCURSII}"
ECHO_LOG "#===> EST_FSEGPATTERN_INF............: ${EST_FSEGPATTERN_INF}"
ECHO_LOG "#===> EST_FSEGPATTERN_CSF............: ${EST_FSEGPATTERN_CSF}"
ECHO_LOG "#===> EST_FCTRFWH....................: ${EST_FCTRFWH}"
ECHO_LOG "#===> EST_FSEGPATTERNFWH.............: ${EST_FSEGPATTERNFWH}"
ECHO_LOG "#===> EST_FSEGPATTERN_BDT............: ${EST_FSEGPATTERN_BDT}"
ECHO_LOG "#===> EST_FRATINGRTO.................: ${EST_FRATINGRTO}"
ECHO_LOG "#===> EST_IADPERICASE_STD............: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IRDPERICASE0................: ${EST_IRDPERICASE0}"
ECHO_LOG "#....................... OUTPUT ..........................................."
ECHO_LOG "#===> EST_GTSII_CASHFLOW.............: ${EST_GTSII_CASHFLOW}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAE.....: ${EST_GTSII_REMAINTOPAY_ULAE}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAEINF..: ${EST_GTSII_REMAINTOPAY_ULAEINF}"
ECHO_LOG "#===> EST_GTSII_GLOBAL_CASHFLOW......: ${EST_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#===> EST_GTSII_CLACC_CASHFLOW.......: ${EST_GTSII_CLACC_CASHFLOW}"
ECHO_LOG "#==>  ESF_GTSII_ICR IFRS17 ..........: ${ESF_GTSII_ICR}     "
ECHO_LOG "#==>  ESF_GTSII_DUMMY_ALL_MRG ........: $ESF_GTSII_DUMMY_ALL_MRG     "
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
# files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLEIFTECLEDSII}`/${PCH}ES*D3710_DLEIFTECLEDSIIEI.dat"
RMFIL "${EST_GTSII_REMAINTOPAY_ULAE}"
RMFIL "${EST_GTSII_CASHFLOW}"

# creation des fichiers vide
touch ${EST_FTECLEDSII}
touch ${EST_DLDSIIGTAA}
touch ${EST_DLDSIIGTAR}
touch ${EST_DLDSIIGTR}

NSTEP=${NJOB}_01
LIBEL="Erase temporary files"
EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_ULAE.dat"
EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_FHNI.dat"
EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056B_CASHFLOW.dat "
EXECKSH "touch ${DFILT}/${NJOB}_65_${IB}_ESTC1056B_GTSII_REMAINTOPAY_ULAEICR.dat"
EXECKSH "touch ${DFILT}/${NJOB}_65_${IB}_ESTC1056B_REMAINTOPAY_FHNI.dat"
EXECKSH "touch ${ESF_GTSII_ICR}"
EXECKSH "touch ${EST_GTSII_REMAINTOPAY_ULAEINF} "
EXECKSH "touch ${DFILT}/${NJOB}_75_${IB}_ESTC1058A_GTSII_BADDEBT.dat"
EXECKSH "touch ${DFILT}/${NJOB}_65_${IB}_ESTC1056B_ESF_GTSII_ICR.dat"

#[038]
#########################################################------------------------------- EXTEND ${EST_DLCUMGTAAR}  with CTRINC & RETCTRCAT 
if [ -s "${EST_FSEGPATTERN_CSF}" ] || [ -s "${EST_FSEGPATTERN_ICR}" ] 
then
	
NSTEP=${NJOB}_10
# add CTRINC & RETCTRCAT accept to EST_DLCUMGTAAR
#-----------------------------------------------------------------------------
LIBEL="add CTRINC & RETCTRCAT accept to EST_DLCUMGTAAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLCUMGTAAR}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	 PER_CTR_NF        3:1 -  3:
	,PER_END_NT        4:1 -  4:
	,PER_SEC_NF        5:1 -  5:
	,PER_UWY_NF        6:1 -  6:
	,PER_UW_NT         7:1 -  7:
	,PER_CTRINC_D      	 19:1 -  19: 
	,PER_RETCTRCAT_CF    106:1 -  106: 
	,CML_CTR_NF           8:1 -  8:
	,CML_END_NT           9:1 -  9:
	,CML_SEC_NF          10:1 - 10:
	,CML_UWY_NF          11:1 - 11:
	,CML_UW_NT           12:1 - 12:
	,CML_TYP_CT         49:1 -  49:
	,CML_ALL_COLS		  1:1 - 52:
/DERIVEDFIELD TYPE_CTR "A"
/joinkeys
  	 CML_CTR_NF 			
	,CML_END_NT 			
	,CML_SEC_NF 			
	,CML_UWY_NF 			
	,CML_UW_NT  			
  	,CML_TYP_CT
/INFILE ${EST_IADPERICASE_STD} 2000 1 "~"
/joinkeys
	 PER_CTR_NF 			
	,PER_END_NT 			
	,PER_SEC_NF 			
	,PER_UWY_NF 			
	,PER_UW_NT  			
	,TYPE_CTR
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
	 leftside:CML_ALL_COLS      
	,rightside:PER_CTRINC_D 		
	,rightside:PER_RETCTRCAT_CF 	
exit
EOF
SORT


NSTEP=${NJOB}_20
# add CTRINC & RETCTRCAT retro to GTAAR
#-----------------------------------------------------------------------------
LIBEL="add CTRINC & RETCTRCAT retro to GTAAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat   2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	 PER_CTR_NF          3:1 -   3:
	,PER_END_NT          4:1 -   4:
	,PER_SEC_NF          5:1 -   5:
	,PER_UWY_NF          6:1 -   6:
	,PER_UW_NT           7:1 -   7:
	,PER_CTRINC_D      	19:1 -  19: 
	,PER_RETCTRCAT_CF  107:1 - 107: 
	,CML_RETCTR_NF      24:1 -  24:
	,CML_RETEND_NT      25:1 -  25:
	,CML_RETSEC_NF      26:1 -  26:
	,CML_RTY_NF         27:1 -  27:
	,CML_RETUW_NT       28:1 -  28:
	,CML_TYP_CT         49:1 -  49:
	,CML_ALL_COLS       1:1 -  54:
/DERIVEDFIELD TYPE_CTR "R"
/joinkeys
  	 CML_RETCTR_NF 		
	,CML_RETEND_NT 		
	,CML_RETSEC_NF 		
	,CML_RTY_NF    		
	,CML_RETUW_NT  
  	,CML_TYP_CT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/joinkeys
	 PER_CTR_NF 			
	,PER_END_NT 			
	,PER_SEC_NF 			
	,PER_UWY_NF 			
	,PER_UW_NT 
	,TYPE_CTR
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
	 leftside:CML_ALL_COLS      
	,rightside:PER_CTRINC_D 		
	,rightside:PER_RETCTRCAT_CF 	
exit
EOF
SORT



NSTEP=${NJOB}_30
# add CTRINC & RETCTRCAT to GTAAR
#-----------------------------------------------------------------------------
LIBEL="$TMP_PERICASE x FCURQUOT_TXT_${BALSHTYEA_NF} ==> PERICASE_PCPRATE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat    2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat    2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
        ACMTRS3_NT       52:1 - 52:
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
exit
EOF
SORT
fi
############################################------------------------------------- END EXTEND ${EST_DLCUMGTAAR}  with CTRINC & RETCTRCAT 


PARALLEL_INIT 2


PATTERN_CATEGORY="CSF  "


#[34] add Context_ct, Closing_date and I3
NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="CSF CALCULATION Calcul du CashFlow (Receivables Undiscount EBS & Claim Undiscounted reserves EBS)"
PRG=ESTC1056B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
CONTEXT_CT ${CONTEXT_CT}
CLOSINGDATE ${ICLODAT_D}
IS_EST_FSEGPATTERN_CSF_EMPTY ${IS_EST_FSEGPATTERN_CSF_EMPTY}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
#[013]
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat
export ${PRG}_I2=${EST_FSEGPATTERN_CSF}
#export ${PRG}_I3=${EST_IADPERICASE_STD}
#export ${PRG}_I4=${EST_IRDPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1056B_CASHFLOW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTC1056B_REMAINTOPAY_ULAE.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
PARALLEL EXECPRG


#[024] Step moved from ESID3703B step 180

PATTERN_CATEGORY="ICR  "

NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="ICR CALCULATION : ICR pattern applied to IBRN and future claims"

# Type of pattern to apply to GT data (5 digits)
#[34] add Context_ct, Closing_date and I3

PRG=ESTC1056B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
CONTEXT_CT ${CONTEXT_CT}
CLOSINGDATE ${ICLODAT_D}
IS_EST_FSEGPATTERN_ICR_EMPTY ${IS_EST_FSEGPATTERN_ICR_EMPTY}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
#[013]
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_DLCUMGTAAR_CTRINC_RETCTRCAT_O.dat
export ${PRG}_I2=${EST_FSEGPATTERN_ICR}
#export ${PRG}_I3=${EST_IADPERICASE_STD}
#export ${PRG}_I4=${EST_IRDPERICASE0}
#export ${PRG}_O1=${ESF_GTSII_ICR}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ESF_GTSII_ICR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_ICR_NOTUSED.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY_ULAEICR.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI.dat
PARALLEL EXECPRG
  
PARALLEL_END


#[40] Keep only grouping 320 and 309 for patcat ICR
NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="Keep gr 320 and 309"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65_${IB}_ESTC1056B_ESF_GTSII_ICR.dat 4000 1"
SORT_O="${ESF_GTSII_ICR} 4000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF          1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        ACMTRS3_NT       42:1 - 42:,
        ACMCUR_CF        44:1 - 44:,
        TYP_CT           49:1 - 49:,
        PATCAT_CT        52:1 - 52:3,
        ACMTRS_NT        124:1 - 124:
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION COND_REMOVE((ACMTRS3_NT = "320" OR ACMTRS3_NT = "309") AND PATCAT_CT = "ICR")
/OUTFILE ${SORT_O}
/INCLUDE COND_REMOVE
exit
EOF
SORT


NSTEP=${NJOB}_56
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_REMAINTOPAY_FHNI
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_REMAINTOPAY_FHNI BOOKED - ASSUME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_FHNI.dat 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_REMAINTOPAY_FHNI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
	  ESB_CF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION ACCRET (TYP_CT = 'A' OR TYP_CT = 'AI')
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT

NSTEP=${NJOB}_57
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_REMAINTOPAY_FHNI - RETRO
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_REMAINTOPAY_FHNI BOOKED - RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_FHNI.dat 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_REMAINTOPAY_FHNI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION ACCRET (TYP_CT = 'R' OR TYP_CT = 'RI')
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT




if [ -s ${EST_FSEGPATTERN_INF} ]
then
  NSTEP=${NJOB}_60
  #-----------------------------------------------------------------------------
  LIBEL="INFLATED RMNTP ULAE CALCULATION"

  PATTERN_CATEGORY="INF  "

  PRG=ESTC1071A
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
PATTERN_CATEGORY ${PATTERN_CATEGORY}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_ULAE.dat
  export ${PRG}_I2=${EST_FCURSII}
  export ${PRG}_I3=${EST_FSEGPATTERN_INF}
  export ${PRG}_O1=${EST_GTSII_REMAINTOPAY_ULAEINF}
  
  EXECPRG
  #cd $DEXE
  #debugV2 $PRG
fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ULAE "
ECHO_LOG "#===> Nombre de lignes ULAE UNDISC generees "
wc -l ${EST_GTSII_REMAINTOPAY_ULAE}
ECHO_LOG "#===> Nombre de lignes ULAE INFLATED generees "
wc -l ${EST_GTSII_REMAINTOPAY_ULAEINF}
ECHO_LOG "#========================================================================="



if [ "${CONTEXT_CT}" = "INI" ]
then

NSTEP=${NJOB}_62
#-----------------------------------------------------------------------------
# CLOSING at Inception update NORME_CF into EST_GTSII_REMAINTOPAY_ULAEINF
#[29] 
#-----------------------------------------------------------------------------
LIBEL="Closing at Inception : update NORME_CF into EST_GTSII_REMAINTOPAY_ULAEINF "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_REMAINTOPAY_ULAEINF} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_REMAINTOPAY_ULAEINF_INI.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
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
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        AM01_M           55:1 - 55:EN 15/3,
        AM02_M           56:1 - 56:EN 15/3,
        AM03_M           57:1 - 57:EN 15/3,
        AM04_M           58:1 - 58:EN 15/3,
        AM05_M           59:1 - 59:EN 15/3,
        AM06_M           60:1 - 60:EN 15/3,
        AM07_M           61:1 - 61:EN 15/3,
        AM08_M           62:1 - 62:EN 15/3,
        AM09_M           63:1 - 63:EN 15/3,
        AM10_M           64:1 - 64:EN 15/3,
        AM11_M           65:1 - 65:EN 15/3,
        AM12_M           66:1 - 66:EN 15/3,
        AM13_M           67:1 - 67:EN 15/3,
        AM14_M           68:1 - 68:EN 15/3,
        AM15_M           69:1 - 69:EN 15/3,
        AM16_M           70:1 - 70:EN 15/3,
        AM17_M           71:1 - 71:EN 15/3,
        AM18_M           72:1 - 72:EN 15/3,
        AM19_M           73:1 - 73:EN 15/3,
        AM20_M           74:1 - 74:EN 15/3,
        AM21_M           75:1 - 75:EN 15/3,
        AM22_M           76:1 - 76:EN 15/3,
        AM23_M           77:1 - 77:EN 15/3,
        AM24_M           78:1 - 78:EN 15/3,
        AM25_M           79:1 - 79:EN 15/3,
        AM26_M           80:1 - 80:EN 15/3,
        AM27_M           81:1 - 81:EN 15/3,
        AM28_M           82:1 - 82:EN 15/3,
        AM29_M           83:1 - 83:EN 15/3,
        AM30_M           84:1 - 84:EN 15/3,
        AM31_M           85:1 - 85:EN 15/3,
        AM32_M           86:1 - 86:EN 15/3,
        AM33_M           87:1 - 87:EN 15/3,
        AM34_M           88:1 - 88:EN 15/3,
        AM35_M           89:1 - 89:EN 15/3,
        AM36_M           90:1 - 90:EN 15/3,
        AM37_M           91:1 - 91:EN 15/3,
        AM38_M           92:1 - 92:EN 15/3,
        AM39_M           93:1 - 93:EN 15/3,
        AM40_M           94:1 - 94:EN 15/3,
        AM41_M           95:1 - 95:EN 15/3,
        AM42_M           96:1 - 96:EN 15/3,
        AM43_M           97:1 - 97:EN 15/3,
        AM44_M           98:1 - 98:EN 15/3,
        AM45_M           99:1 - 99:EN 15/3,
        AM46_M          100:1 - 100:EN 15/3,
        AM47_M          101:1 - 101:EN 15/3,
        AM48_M          102:1 - 102:EN 15/3,
        AM49_M          103:1 - 103:EN 15/3,
        AM50_M          104:1 - 104:EN 15/3,
        AM51_M          105:1 - 105:EN 15/3,
        AM52_M          106:1 - 106:EN 15/3,
        AM53_M          107:1 - 107:EN 15/3,
        AM54_M          108:1 - 108:EN 15/3,
        AM55_M          109:1 - 109:EN 15/3,
        AM56_M          110:1 - 110:EN 15/3,
        AM57_M          111:1 - 111:EN 15/3,
        AM58_M          112:1 - 112:EN 15/3,
        AM59_M          113:1 - 113:EN 15/3,
        AM60_M          114:1 - 114:EN 15/3,
        AM61_M          115:1 - 115:EN 15/3,
        AM62_M          116:1 - 116:EN 15/3,
        AM63_M          117:1 - 117:EN 15/3,
        AM64_M          118:1 - 118:EN 15/3,
        AM65_M          119:1 - 119:EN 15/3,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:		
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/KEYS 	SSD_CF,
	ESB_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CUR_CF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT,
	RTO_NF,
	ACMCUR_CF,
	ACMTRS_NT,
	TYP_CT,
	ACMTRS3_NT	  
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF
	,ESB_CF
	,BALSHEY_NF
	,BALSHRMTH_NF
	,BALSHRDAY_NF
	,TRNCOD_CF
	,DBLTRNCOD_CF
	,CTR_NF
	,END_NT
	,SEC_NF
	,UWY_NF
	,UW_NT
	,OCCYEA_NF
	,ACY_NF
	,SCOSTRMTH_NF
	,SCOENDMTH_NF
	,CLM_NF
	,CUR_CF
	,AMT_MC
	,CED_NF
	,BRK_NF
	,PAY_NF
	,KEY_NF
	,RETCTR_NF
	,RETEND_NT
	,RETSEC_NF
	,RTY_NF
	,RETUW_NT
	,RETOCCYEA_NF
	,RETACY_NF
	,RETSCOSTRMTH_NF
	,RETSCOENDMTH_NF
	,RCL_NF
	,RETCUR_CF
	,RETAMT_MC
	,PLC_NT
	,RTO_NF
	,INT_NF
	,RETPAY_NF
	,RETKEY_CF
	,RETINTAMT_MC
	,ACMTRS_NT
	,ACMAMT_MC
	,ACMCUR_CF
	,PRS_CF
	,SEG_NF
	,LOB_CF
	,NAT_CF
	,TYP_CT
	,NORME_CF
	,RATING_CF
	,PATCAT_CT
	,PATTYP_CT
	,PATTERN_ID
	,AM01_MC
	,AM02_MC
	,AM03_MC
	,AM04_MC
	,AM05_MC
	,AM06_MC
	,AM07_MC
	,AM08_MC
	,AM09_MC
	,AM10_MC
	,AM11_MC
	,AM12_MC
	,AM13_MC
	,AM14_MC
	,AM15_MC
	,AM16_MC
	,AM17_MC
	,AM18_MC
	,AM19_MC
	,AM20_MC
	,AM21_MC
	,AM22_MC
	,AM23_MC
	,AM24_MC
	,AM25_MC
	,AM26_MC
	,AM27_MC
	,AM28_MC
	,AM29_MC
	,AM30_MC
	,AM31_MC
	,AM32_MC
	,AM33_MC
	,AM34_MC
	,AM35_MC
	,AM36_MC
	,AM37_MC
	,AM38_MC
	,AM39_MC
	,AM40_MC
	,AM41_MC
	,AM42_MC
	,AM43_MC
	,AM44_MC
	,AM45_MC
	,AM46_MC
	,AM47_MC
	,AM48_MC
	,AM49_MC
	,AM50_MC
	,AM51_MC
	,AM52_MC
	,AM53_MC
	,AM54_MC
	,AM55_MC
	,AM56_MC
	,AM57_MC
	,AM58_MC
	,AM59_MC
	,AM60_MC
	,AM61_MC
	,AM62_MC
	,AM63_MC
	,AM64_MC
	,AM65_MC
	,COEF_LOB
	,DSCCUR_CF
	,COMMENT
	,TOTAUX_MC
	,ACMTRS3_NT
exit
EOF
SORT

#wc -l ${DFILT}/${NSTEP}_${IB}_REMAINTOPAY_ULAEINF_INI.dat

# overwrite EST_GTSII_REMAINTOPAY_ULAEINF
LIBEL="Closing at Inception : overwrite EST_GTSII_REMAINTOPAY_ULAEINF "
EXECKSH "cp ${DFILT}/${NSTEP}_${IB}_REMAINTOPAY_ULAEINF_INI.dat ${EST_GTSII_REMAINTOPAY_ULAEINF} " 

fi


NSTEP=${NJOB}_63
#-----------------------------------------------------------------------------
# SORT of FWHGTA
#-----------------------------------------------------------------------------
LIBEL="SORT of FWHGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTA} 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTA.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD35_CF       6:3 -  6:5,
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 41:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
	  UW_NT
/CONDITION COND_TRNCOD TRNCOD1_CF = "1"
                   AND (TRNCOD35_CF = '814' OR TRNCOD35_CF = '815')
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
exit
EOF
SORT

NSTEP=${NJOB}_63A
#-----------------------------------------------------------------------------
# SORT of FWHGTR
#-----------------------------------------------------------------------------
LIBEL="SORT of FWHGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD35_CF       6:3 -  6:5,
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:
/KEYS SSD_CF,
      ESB_CF,
      RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
	  RTO_NF
/CONDITION COND_TRNCOD TRNCOD1_CF = "2"
                   AND (TRNCOD35_CF = '814' OR TRNCOD35_CF = '815')
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
exit
EOF
SORT




#[025]
NSTEP=${NJOB}_65B
#-----------------------------------------------------------------------------
LIBEL="Addition of curve rate data"
PRG=ESTC2059
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
exit
EOF
export ${PRG}_PRM=${FPRM}

export ${PRG}_I1=${EST_FCTRFWH}
export ${PRG}_I2="${DFILT}/${NJOB}_63_${IB}_SORT_FWHGTA.dat"
export ${PRG}_I3="${DFILT}/${NJOB}_63A_${IB}_SORT_FWHGTR.dat"
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_NOTBOOKED_FWH.dat
EXECPRG

NSTEP=${NJOB}_65BB
LIBEL="SORT of NOTBOOKED_FWH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65B_${IB}_ESTC2059_GTSII_NOTBOOKED_FWH.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_NOTBOOKED_FWH.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 -  1:,
        SSD_CF            2:1 -  2:EN,
        SEC_NF            3:1 -  3:EN,
        UWY_NF            4:1 -  4:,
        UW_NT             5:1 -  5:EN,
        END_NT            6:1 -  6:EN
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
	  UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_65C
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_CASHFLOW
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_CASHFLOW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_CASHFLOW.dat 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_CASHFLOW.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION ACCRET ((TYP_CT = 'A' OR TYP_CT = 'AI') AND (ACMTRS_NT ="303" OR ACMTRS_NT ="309" OR ACMTRS_NT ="320" ))
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT

NSTEP=${NJOB}_65D
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_GTSII_ICR
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_GTSII_ICR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_ICR} 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_GTSII_ICR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION ACCRET ((TYP_CT = 'A' OR TYP_CT = 'AI') AND (ACMTRS_NT ="309" OR ACMTRS_NT ="320" ))
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT


NSTEP=${NJOB}_65E
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_CASHFLOW
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_CASHFLOW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_CASHFLOW.dat 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_CASHFLOW_RETRO.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 
/CONDITION ACCRET ( TYP_CT = 'R' OR TYP_CT = 'RI')
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT

NSTEP=${NJOB}_65F
#-----------------------------------------------------------------------------
# SORT of ESTC1056B_GTSII_ICR
#-----------------------------------------------------------------------------
LIBEL="SORT of ESTC1056B_GTSII_ICR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_ICR} 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESTC1056B_GTSII_ICR_RETRO.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
	  ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT 

/CONDITION ACCRET ( TYP_CT = 'R' OR TYP_CT = 'RI')
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
exit
EOF
SORT



  
# Calculate simulated fund-with held and remaining to pay 
NSTEP=${NJOB}_66
#-----------------------------------------------------------------------------
LIBEL="Calculate simulated fund-with held and remaining to pay :  Assume"
PRG=ESTC2060
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_65BB_${IB}_SORT_GTSII_NOTBOOKED_FWH.dat"
export ${PRG}_I2=${DFILT}/${NJOB}_65C_${IB}_SORT_ESTC1056B_CASHFLOW.dat
export ${PRG}_I3="${DFILT}/${NJOB}_65D_${IB}_SORT_ESTC1056B_GTSII_ICR.dat"
export ${PRG}_I4=${DFILT}/${NJOB}_56_${IB}_SORT_ESTC1056B_REMAINTOPAY_FHNI.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_EST_SIMU_CASHFLOW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_EST_SIMU_REMAINTOPAY_FWH.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_EST_BOOKED_FWH.dat
EXECPRG

# Calculate simulated fund-with held and remaining to pay
NSTEP=${NJOB}_66B
#-----------------------------------------------------------------------------
LIBEL="Calculate simulated fund-with held and remaining to pay :  Retro"
PRG=ESTC2060
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET R
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_65BB_${IB}_SORT_GTSII_NOTBOOKED_FWH.dat"
export ${PRG}_I2=${DFILT}/${NJOB}_65E_${IB}_SORT_ESTC1056B_CASHFLOW_RETRO.dat
export ${PRG}_I3="${DFILT}/${NJOB}_65F_${IB}_SORT_ESTC1056B_GTSII_ICR_RETRO.dat"
export ${PRG}_I4=${DFILT}/${NJOB}_57_${IB}_SORT_ESTC1056B_REMAINTOPAY_FHNI.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_EST_SIMU_CASHFLOW_RETRO.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_EST_SIMU_REMAINTOPAY_FWH_RETRO.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_EST_BOOKED_FWH_RETRO.dat
EXECPRG



# SORT and MERGE CASHFLOW/FHW/SIMU_FHW
NSTEP=${NJOB}_67
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_66_${IB}_EST_SIMU_REMAINTOPAY_FWH.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_66_${IB}_EST_BOOKED_FWH.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_66B_${IB}_EST_SIMU_REMAINTOPAY_FWH_RETRO.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_66B_${IB}_EST_BOOKED_FWH_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_SORT_REMAINTOPAY.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_MERGE_SORT_REMAINTOPAY_RETRO.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
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
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        AM01_M           55:1 - 55:EN 15/3,
        AM02_M           56:1 - 56:EN 15/3,
        AM03_M           57:1 - 57:EN 15/3,
        AM04_M           58:1 - 58:EN 15/3,
        AM05_M           59:1 - 59:EN 15/3,
        AM06_M           60:1 - 60:EN 15/3,
        AM07_M           61:1 - 61:EN 15/3,
        AM08_M           62:1 - 62:EN 15/3,
        AM09_M           63:1 - 63:EN 15/3,
        AM10_M           64:1 - 64:EN 15/3,
        AM11_M           65:1 - 65:EN 15/3,
        AM12_M           66:1 - 66:EN 15/3,
        AM13_M           67:1 - 67:EN 15/3,
        AM14_M           68:1 - 68:EN 15/3,
        AM15_M           69:1 - 69:EN 15/3,
        AM16_M           70:1 - 70:EN 15/3,
        AM17_M           71:1 - 71:EN 15/3,
        AM18_M           72:1 - 72:EN 15/3,
        AM19_M           73:1 - 73:EN 15/3,
        AM20_M           74:1 - 74:EN 15/3,
        AM21_M           75:1 - 75:EN 15/3,
        AM22_M           76:1 - 76:EN 15/3,
        AM23_M           77:1 - 77:EN 15/3,
        AM24_M           78:1 - 78:EN 15/3,
        AM25_M           79:1 - 79:EN 15/3,
        AM26_M           80:1 - 80:EN 15/3,
        AM27_M           81:1 - 81:EN 15/3,
        AM28_M           82:1 - 82:EN 15/3,
        AM29_M           83:1 - 83:EN 15/3,
        AM30_M           84:1 - 84:EN 15/3,
        AM31_M           85:1 - 85:EN 15/3,
        AM32_M           86:1 - 86:EN 15/3,
        AM33_M           87:1 - 87:EN 15/3,
        AM34_M           88:1 - 88:EN 15/3,
        AM35_M           89:1 - 89:EN 15/3,
        AM36_M           90:1 - 90:EN 15/3,
        AM37_M           91:1 - 91:EN 15/3,
        AM38_M           92:1 - 92:EN 15/3,
        AM39_M           93:1 - 93:EN 15/3,
        AM40_M           94:1 - 94:EN 15/3,
        AM41_M           95:1 - 95:EN 15/3,
        AM42_M           96:1 - 96:EN 15/3,
        AM43_M           97:1 - 97:EN 15/3,
        AM44_M           98:1 - 98:EN 15/3,
        AM45_M           99:1 - 99:EN 15/3,
        AM46_M          100:1 - 100:EN 15/3,
        AM47_M          101:1 - 101:EN 15/3,
        AM48_M          102:1 - 102:EN 15/3,
        AM49_M          103:1 - 103:EN 15/3,
        AM50_M          104:1 - 104:EN 15/3,
        AM51_M          105:1 - 105:EN 15/3,
        AM52_M          106:1 - 106:EN 15/3,
        AM53_M          107:1 - 107:EN 15/3,
        AM54_M          108:1 - 108:EN 15/3,
        AM55_M          109:1 - 109:EN 15/3,
        AM56_M          110:1 - 110:EN 15/3,
        AM57_M          111:1 - 111:EN 15/3,
        AM58_M          112:1 - 112:EN 15/3,
        AM59_M          113:1 - 113:EN 15/3,
        AM60_M          114:1 - 114:EN 15/3,
        AM61_M          115:1 - 115:EN 15/3,
        AM62_M          116:1 - 116:EN 15/3,
        AM63_M          117:1 - 117:EN 15/3,
        AM64_M          118:1 - 118:EN 15/3,
        AM65_M          119:1 - 119:EN 15/3,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/KEYS SSD_CF,
	  ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
	  CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT	  
/CONDITION ACCRET ( (TYP_CT = 'A' OR TYP_CT = 'AI') AND (ACMTRS_NT = "702" OR ACMTRS_NT = "902") )
/OUTFILE ${SORT_O}
/INCLUDE ACCRET
/REFORMAT SSD_CF
     ,ESB_CF
     ,BALSHEY_NF
     ,BALSHRMTH_NF
     ,BALSHRDAY_NF
     ,TRNCOD_CF
     ,DBLTRNCOD_CF
     ,CTR_NF
     ,END_NT
     ,SEC_NF
     ,UWY_NF
     ,UW_NT
     ,OCCYEA_NF
     ,ACY_NF
     ,SCOSTRMTH_NF
     ,SCOENDMTH_NF
     ,CLM_NF
     ,CUR_CF
     ,AMT_MC
     ,CED_NF
     ,BRK_NF
     ,PAY_NF
     ,KEY_NF
     ,RETCTR_NF
     ,RETEND_NT
     ,RETSEC_NF
     ,RTY_NF
     ,RETUW_NT
     ,RETOCCYEA_NF
     ,RETACY_NF
     ,RETSCOSTRMTH_NF
     ,RETSCOENDMTH_NF
     ,RCL_NF
     ,RETCUR_CF
     ,RETAMT_MC
     ,PLC_NT
     ,RTO_NF
     ,INT_NF
     ,RETPAY_NF
     ,RETKEY_CF
     ,RETINTAMT_MC
     ,ACMTRS_NT
     ,ACMAMT_MC
     ,ACMCUR_CF
     ,PRS_CF
     ,SEG_NF
     ,LOB_CF
     ,NAT_CF
     ,TYP_CT
     ,NORME_CF
     ,RATING_CF
     ,PATCAT_CT
     ,PATTYP_CT
     ,PATTERN_ID
     ,AM01_MC
     ,AM02_MC
     ,AM03_MC
     ,AM04_MC
     ,AM05_MC
     ,AM06_MC
     ,AM07_MC
     ,AM08_MC
     ,AM09_MC
     ,AM10_MC
     ,AM11_MC
     ,AM12_MC
     ,AM13_MC
     ,AM14_MC
     ,AM15_MC
     ,AM16_MC
     ,AM17_MC
     ,AM18_MC
     ,AM19_MC
     ,AM20_MC
     ,AM21_MC
     ,AM22_MC
     ,AM23_MC
     ,AM24_MC
     ,AM25_MC
     ,AM26_MC
     ,AM27_MC
     ,AM28_MC
     ,AM29_MC
     ,AM30_MC
     ,AM31_MC
     ,AM32_MC
     ,AM33_MC
     ,AM34_MC
     ,AM35_MC
     ,AM36_MC
     ,AM37_MC
     ,AM38_MC
     ,AM39_MC
     ,AM40_MC
     ,AM41_MC
     ,AM42_MC
     ,AM43_MC
     ,AM44_MC
     ,AM45_MC
     ,AM46_MC
     ,AM47_MC
     ,AM48_MC
     ,AM49_MC
     ,AM50_MC
     ,AM51_MC
     ,AM52_MC
     ,AM53_MC
     ,AM54_MC
     ,AM55_MC
     ,AM56_MC
     ,AM57_MC
     ,AM58_MC
     ,AM59_MC
     ,AM60_MC
     ,AM61_MC
     ,AM62_MC
     ,AM63_MC
     ,AM64_MC
     ,AM65_MC
     ,COEF_LOB
     ,DSCCUR_CF
     ,COMMENT
     ,TOTAUX_MC
	 ,ACMTRS3_NT
/CONDITION ACCRETRO ( (TYP_CT = 'R' OR TYP_CT = 'RI') AND (ACMTRS_NT = "702" OR ACMTRS_NT = "902" ) )
/OUTFILE ${SORT_O2}
/INCLUDE ACCRETRO
/REFORMAT SSD_CF
     ,ESB_CF
     ,BALSHEY_NF
     ,BALSHRMTH_NF
     ,BALSHRDAY_NF
     ,TRNCOD_CF
     ,DBLTRNCOD_CF
     ,CTR_NF
     ,END_NT
     ,SEC_NF
     ,UWY_NF
     ,UW_NT
     ,OCCYEA_NF
     ,ACY_NF
     ,SCOSTRMTH_NF
     ,SCOENDMTH_NF
     ,CLM_NF
     ,CUR_CF
     ,AMT_MC
     ,CED_NF
     ,BRK_NF
     ,PAY_NF
     ,KEY_NF
     ,RETCTR_NF
     ,RETEND_NT
     ,RETSEC_NF
     ,RTY_NF
     ,RETUW_NT
     ,RETOCCYEA_NF
     ,RETACY_NF
     ,RETSCOSTRMTH_NF
     ,RETSCOENDMTH_NF
     ,RCL_NF
     ,RETCUR_CF
     ,RETAMT_MC
     ,PLC_NT
     ,RTO_NF
     ,INT_NF
     ,RETPAY_NF
     ,RETKEY_CF
     ,RETINTAMT_MC
     ,ACMTRS_NT
     ,TOTAUX_MC
     ,ACMCUR_CF
     ,PRS_CF
     ,SEG_NF
     ,LOB_CF
     ,NAT_CF
     ,TYP_CT
     ,NORME_CF
     ,RATING_CF
     ,PATCAT_CT
     ,PATTYP_CT
     ,PATTERN_ID
     ,AM01_MC
     ,AM02_MC
     ,AM03_MC
     ,AM04_MC
     ,AM05_MC
     ,AM06_MC
     ,AM07_MC
     ,AM08_MC
     ,AM09_MC
     ,AM10_MC
     ,AM11_MC
     ,AM12_MC
     ,AM13_MC
     ,AM14_MC
     ,AM15_MC
     ,AM16_MC
     ,AM17_MC
     ,AM18_MC
     ,AM19_MC
     ,AM20_MC
     ,AM21_MC
     ,AM22_MC
     ,AM23_MC
     ,AM24_MC
     ,AM25_MC
     ,AM26_MC
     ,AM27_MC
     ,AM28_MC
     ,AM29_MC
     ,AM30_MC
     ,AM31_MC
     ,AM32_MC
     ,AM33_MC
     ,AM34_MC
     ,AM35_MC
     ,AM36_MC
     ,AM37_MC
     ,AM38_MC
     ,AM39_MC
     ,AM40_MC
     ,AM41_MC
     ,AM42_MC
     ,AM43_MC
     ,AM44_MC
     ,AM45_MC
     ,AM46_MC
     ,AM47_MC
     ,AM48_MC
     ,AM49_MC
     ,AM50_MC
     ,AM51_MC
     ,AM52_MC
     ,AM53_MC
     ,AM54_MC
     ,AM55_MC
     ,AM56_MC
     ,AM57_MC
     ,AM58_MC
     ,AM59_MC
     ,AM60_MC
     ,AM61_MC
     ,AM62_MC
     ,AM63_MC
     ,AM64_MC
     ,AM65_MC
     ,COEF_LOB
     ,DSCCUR_CF
     ,COMMENT
     ,TOTAUX_MC
	 ,ACMTRS3_NT	 
exit
EOF
SORT


#-----------------------------------------------------------------------------



# INVESTMENT INCOME CASHFLOW CALCULATION - ASSUME
NSTEP=${NJOB}_68
#-----------------------------------------------------------------------------
LIBEL="INVESTMENT INCOME CASHFLOW CALCULATION - ASSUME"
PRG=ESTC2061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${EST_FCTRFWH}"
export ${PRG}_I2="${DFILT}/${NJOB}_67_${IB}_MERGE_SORT_REMAINTOPAY.dat"
export ${PRG}_I3="${EST_FSEGPATTERNFWH}"
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_EST_CASHFLOW_FHNI.dat
EXECPRG

# INVESTMENT INCOME CASHFLOW CALCULATION - RETRO
NSTEP=${NJOB}_69
#-----------------------------------------------------------------------------
LIBEL="INVESTMENT INCOME CASHFLOW CALCULATION - RETRO"
PRG=ESTC2061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ACCRET R
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${EST_FCTRFWH}"
export ${PRG}_I2="${DFILT}/${NJOB}_67_${IB}_MERGE_SORT_REMAINTOPAY_RETRO.dat"
export ${PRG}_I3="${EST_FSEGPATTERNFWH}"
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_EST_CASHFLOW_FHNI_RETRO.dat
EXECPRG

#[31]
NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="MERGE CASHFLOW/FHW/SIMU_FHW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_CASHFLOW.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_66B_${IB}_EST_SIMU_CASHFLOW_RETRO.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_69_${IB}_EST_CASHFLOW_FHNI_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CASHFLOW_PREP_BDT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
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
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        ACMTRS3_NT       124:1 - 124:,
	    PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:5
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
/CONDITION Bad_Dept TYP_CT="R" AND PATCAT1_CT="CSF" AND ((( ACMTRS_NT = "101" OR ACMTRS_NT = "105" OR ACMTRS_NT = "201" OR ACMTRS_NT = "205" OR 
						ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "307" OR ACMTRS_NT = "309" OR ACMTRS_NT = "320"  OR ACMTRS_NT = "702" OR ACMTRS_NT = "902" ) 
					OR ( ACMTRS_NT = "401" AND PATTYP_CT="FHNI" ) ) OR ( "$IDF_CT" = "I17G_CSF_MRG_INI"  OR   "$IDF_CT" = "I17S_CSF_MRG_INI"  OR   "$IDF_CT" = "I17P_CSF_MRG_INI" OR  "$IDF_CT" = "I17L_CSF_MRG_INI"   ) )

/OUTFILE ${SORT_O}
/INCLUDE Bad_Dept
exit
EOF
SORT

#[31]
if [ -s ${EST_FSEGPATTERN_BDT} ]
then
NSTEP=${NJOB}_75
  # Begin C program
  #-----------------------------------------------------------------------------
  LIBEL="Calcul des badDebt"
  PRG=ESTC1058A
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  export ${PRG}_I1="${DFILT}/${NJOB}_70_${IB}_SORT_CASHFLOW_PREP_BDT.dat"
  export ${PRG}_I2=${EST_FSEGPATTERN_BDT}
  export ${PRG}_I3=${EST_FRATINGRTO}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_BADDEBT.dat
  EXECPRG
fi 

 
#[31]
# SORT and MERGE CASHFLOW/FHW/SIMU_FHW
NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="MERGE CASHFLOW/FHW/SIMU_FHW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_CASHFLOW.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_66_${IB}_EST_SIMU_CASHFLOW.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_68_${IB}_EST_CASHFLOW_FHNI.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_67_${IB}_MERGE_SORT_REMAINTOPAY.dat 2000 1"
SORT_I5="${DFILT}/${NJOB}_66B_${IB}_EST_SIMU_CASHFLOW_RETRO.dat 2000 1"
SORT_I6="${DFILT}/${NJOB}_69_${IB}_EST_CASHFLOW_FHNI_RETRO.dat 2000 1"
SORT_I7="${DFILT}/${NJOB}_67_${IB}_MERGE_SORT_REMAINTOPAY_RETRO.dat 2000 1"
SORT_I8="${DFILT}/${NJOB}_50_${IB}_ESTC1056B_REMAINTOPAY_ULAE.dat 2000 1"
SORT_I9="${DFILT}/${NJOB}_75_${IB}_ESTC1058A_GTSII_BADDEBT.dat 2000 1"
SORT_O="${EST_GTSII_CASHFLOW}"
SORT_O2="${EST_GTSII_REMAINTOPAY_ULAE}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
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
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTERN_ID       54:1 - 54:,
        AM01_M           55:1 - 55:EN 15/3,
        AM02_M           56:1 - 56:EN 15/3,
        AM03_M           57:1 - 57:EN 15/3,
        AM04_M           58:1 - 58:EN 15/3,
        AM05_M           59:1 - 59:EN 15/3,
        AM06_M           60:1 - 60:EN 15/3,
        AM07_M           61:1 - 61:EN 15/3,
        AM08_M           62:1 - 62:EN 15/3,
        AM09_M           63:1 - 63:EN 15/3,
        AM10_M           64:1 - 64:EN 15/3,
        AM11_M           65:1 - 65:EN 15/3,
        AM12_M           66:1 - 66:EN 15/3,
        AM13_M           67:1 - 67:EN 15/3,
        AM14_M           68:1 - 68:EN 15/3,
        AM15_M           69:1 - 69:EN 15/3,
        AM16_M           70:1 - 70:EN 15/3,
        AM17_M           71:1 - 71:EN 15/3,
        AM18_M           72:1 - 72:EN 15/3,
        AM19_M           73:1 - 73:EN 15/3,
        AM20_M           74:1 - 74:EN 15/3,
        AM21_M           75:1 - 75:EN 15/3,
        AM22_M           76:1 - 76:EN 15/3,
        AM23_M           77:1 - 77:EN 15/3,
        AM24_M           78:1 - 78:EN 15/3,
        AM25_M           79:1 - 79:EN 15/3,
        AM26_M           80:1 - 80:EN 15/3,
        AM27_M           81:1 - 81:EN 15/3,
        AM28_M           82:1 - 82:EN 15/3,
        AM29_M           83:1 - 83:EN 15/3,
        AM30_M           84:1 - 84:EN 15/3,
        AM31_M           85:1 - 85:EN 15/3,
        AM32_M           86:1 - 86:EN 15/3,
        AM33_M           87:1 - 87:EN 15/3,
        AM34_M           88:1 - 88:EN 15/3,
        AM35_M           89:1 - 89:EN 15/3,
        AM36_M           90:1 - 90:EN 15/3,
        AM37_M           91:1 - 91:EN 15/3,
        AM38_M           92:1 - 92:EN 15/3,
        AM39_M           93:1 - 93:EN 15/3,
        AM40_M           94:1 - 94:EN 15/3,
        AM41_M           95:1 - 95:EN 15/3,
        AM42_M           96:1 - 96:EN 15/3,
        AM43_M           97:1 - 97:EN 15/3,
        AM44_M           98:1 - 98:EN 15/3,
        AM45_M           99:1 - 99:EN 15/3,
        AM46_M          100:1 - 100:EN 15/3,
        AM47_M          101:1 - 101:EN 15/3,
        AM48_M          102:1 - 102:EN 15/3,
        AM49_M          103:1 - 103:EN 15/3,
        AM50_M          104:1 - 104:EN 15/3,
        AM51_M          105:1 - 105:EN 15/3,
        AM52_M          106:1 - 106:EN 15/3,
        AM53_M          107:1 - 107:EN 15/3,
        AM54_M          108:1 - 108:EN 15/3,
        AM55_M          109:1 - 109:EN 15/3,
        AM56_M          110:1 - 110:EN 15/3,
        AM57_M          111:1 - 111:EN 15/3,
        AM58_M          112:1 - 112:EN 15/3,
        AM59_M          113:1 - 113:EN 15/3,
        AM60_M          114:1 - 114:EN 15/3,
        AM61_M          115:1 - 115:EN 15/3,
        AM62_M          116:1 - 116:EN 15/3,
        AM63_M          117:1 - 117:EN 15/3,
        AM64_M          118:1 - 118:EN 15/3,
        AM65_M          119:1 - 119:EN 15/3,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
	ACMTRS3_NT      124:1 - 124:
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
	TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
	TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
	TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
	TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
	TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
	TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
	TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/CONDITION ACMTRSCHK1 PATTYP_CT != "RMNTP" OR (PATCAT1_CT = "BDT" AND PATTYP_CT = "RMNTP" )
/CONDITION ACMTRSCHK2 PATTYP_CT = "RMNTP"  AND (PATCAT1_CT != "BDT" )
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AM01_MC AM01_M COMPRESS
/DERIVEDFIELD AM02_MC AM02_M COMPRESS
/DERIVEDFIELD AM03_MC AM03_M COMPRESS
/DERIVEDFIELD AM04_MC AM04_M COMPRESS
/DERIVEDFIELD AM05_MC AM05_M COMPRESS
/DERIVEDFIELD AM06_MC AM06_M COMPRESS
/DERIVEDFIELD AM07_MC AM07_M COMPRESS
/DERIVEDFIELD AM08_MC AM08_M COMPRESS
/DERIVEDFIELD AM09_MC AM09_M COMPRESS
/DERIVEDFIELD AM10_MC AM10_M COMPRESS
/DERIVEDFIELD AM11_MC AM11_M COMPRESS
/DERIVEDFIELD AM12_MC AM12_M COMPRESS
/DERIVEDFIELD AM13_MC AM13_M COMPRESS
/DERIVEDFIELD AM14_MC AM14_M COMPRESS
/DERIVEDFIELD AM15_MC AM15_M COMPRESS
/DERIVEDFIELD AM16_MC AM16_M COMPRESS
/DERIVEDFIELD AM17_MC AM17_M COMPRESS
/DERIVEDFIELD AM18_MC AM18_M COMPRESS
/DERIVEDFIELD AM19_MC AM19_M COMPRESS
/DERIVEDFIELD AM20_MC AM20_M COMPRESS
/DERIVEDFIELD AM21_MC AM21_M COMPRESS
/DERIVEDFIELD AM22_MC AM22_M COMPRESS
/DERIVEDFIELD AM23_MC AM23_M COMPRESS
/DERIVEDFIELD AM24_MC AM24_M COMPRESS
/DERIVEDFIELD AM25_MC AM25_M COMPRESS
/DERIVEDFIELD AM26_MC AM26_M COMPRESS
/DERIVEDFIELD AM27_MC AM27_M COMPRESS
/DERIVEDFIELD AM28_MC AM28_M COMPRESS
/DERIVEDFIELD AM29_MC AM29_M COMPRESS
/DERIVEDFIELD AM30_MC AM30_M COMPRESS
/DERIVEDFIELD AM31_MC AM31_M COMPRESS
/DERIVEDFIELD AM32_MC AM32_M COMPRESS
/DERIVEDFIELD AM33_MC AM33_M COMPRESS
/DERIVEDFIELD AM34_MC AM34_M COMPRESS
/DERIVEDFIELD AM35_MC AM35_M COMPRESS
/DERIVEDFIELD AM36_MC AM36_M COMPRESS
/DERIVEDFIELD AM37_MC AM37_M COMPRESS
/DERIVEDFIELD AM38_MC AM38_M COMPRESS
/DERIVEDFIELD AM39_MC AM39_M COMPRESS
/DERIVEDFIELD AM40_MC AM40_M COMPRESS
/DERIVEDFIELD AM41_MC AM41_M COMPRESS
/DERIVEDFIELD AM42_MC AM42_M COMPRESS
/DERIVEDFIELD AM43_MC AM43_M COMPRESS
/DERIVEDFIELD AM44_MC AM44_M COMPRESS
/DERIVEDFIELD AM45_MC AM45_M COMPRESS
/DERIVEDFIELD AM46_MC AM46_M COMPRESS
/DERIVEDFIELD AM47_MC AM47_M COMPRESS
/DERIVEDFIELD AM48_MC AM48_M COMPRESS
/DERIVEDFIELD AM49_MC AM49_M COMPRESS
/DERIVEDFIELD AM50_MC AM50_M COMPRESS
/DERIVEDFIELD AM51_MC AM51_M COMPRESS
/DERIVEDFIELD AM52_MC AM52_M COMPRESS
/DERIVEDFIELD AM53_MC AM53_M COMPRESS
/DERIVEDFIELD AM54_MC AM54_M COMPRESS
/DERIVEDFIELD AM55_MC AM55_M COMPRESS
/DERIVEDFIELD AM56_MC AM56_M COMPRESS
/DERIVEDFIELD AM57_MC AM57_M COMPRESS
/DERIVEDFIELD AM58_MC AM58_M COMPRESS
/DERIVEDFIELD AM59_MC AM59_M COMPRESS
/DERIVEDFIELD AM60_MC AM60_M COMPRESS
/DERIVEDFIELD AM61_MC AM61_M COMPRESS
/DERIVEDFIELD AM62_MC AM62_M COMPRESS
/DERIVEDFIELD AM63_MC AM63_M COMPRESS
/DERIVEDFIELD AM64_MC AM64_M COMPRESS
/DERIVEDFIELD AM65_MC AM65_M COMPRESS
/DERIVEDFIELD TOTAUX_MC TOTAUX_M COMPRESS
/KEYS 	SSD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	PLC_NT,
	RTO_NF,
	ACMCUR_CF,
	ACMTRS_NT,
	TYP_CT,
	PATCAT_CT,
	PATTYP_CT,
	ACMTRS3_NT
/OUTFILE ${SORT_O}
/INCLUDE ACMTRSCHK1
/REFORMAT SSD_CF
	,ESB_CF
	,BALSHEY_NF
	,BALSHRMTH_NF
	,BALSHRDAY_NF
	,TRNCOD_CF
	,DBLTRNCOD_CF
	,CTR_NF
	,END_NT
	,SEC_NF
	,UWY_NF
	,UW_NT
	,OCCYEA_NF
	,ACY_NF
	,SCOSTRMTH_NF
	,SCOENDMTH_NF
	,CLM_NF
	,CUR_CF
	,AMT_MC
	,CED_NF
	,BRK_NF
	,PAY_NF
	,KEY_NF
	,RETCTR_NF
	,RETEND_NT
	,RETSEC_NF
	,RTY_NF
	,RETUW_NT
	,RETOCCYEA_NF
	,RETACY_NF
	,RETSCOSTRMTH_NF
	,RETSCOENDMTH_NF
	,RCL_NF
	,RETCUR_CF
	,RETAMT_MC
	,PLC_NT
	,RTO_NF
	,INT_NF
	,RETPAY_NF
	,RETKEY_CF
	,RETINTAMT_MC
	,ACMTRS_NT
	,ACMAMT_M
	,ACMCUR_CF
	,PRS_CF
	,SEG_NF
	,LOB_CF
	,NAT_CF
	,TYP_CT
	,NORME_CF
	,RATING_CF
	,PATCAT_CT
	,PATTYP_CT
	,PATTERN_ID
	,AM01_MC
	,AM02_MC
	,AM03_MC
	,AM04_MC
	,AM05_MC
	,AM06_MC
	,AM07_MC
	,AM08_MC
	,AM09_MC
	,AM10_MC
	,AM11_MC
	,AM12_MC
	,AM13_MC
	,AM14_MC
	,AM15_MC
	,AM16_MC
	,AM17_MC
	,AM18_MC
	,AM19_MC
	,AM20_MC
	,AM21_MC
	,AM22_MC
	,AM23_MC
	,AM24_MC
	,AM25_MC
	,AM26_MC
	,AM27_MC
	,AM28_MC
	,AM29_MC
	,AM30_MC
	,AM31_MC
	,AM32_MC
	,AM33_MC
	,AM34_MC
	,AM35_MC
	,AM36_MC
	,AM37_MC
	,AM38_MC
	,AM39_MC
	,AM40_MC
	,AM41_MC
	,AM42_MC
	,AM43_MC
	,AM44_MC
	,AM45_MC
	,AM46_MC
	,AM47_MC
	,AM48_MC
	,AM49_MC
	,AM50_MC
	,AM51_MC
	,AM52_MC
	,AM53_MC
	,AM54_MC
	,AM55_MC
	,AM56_MC
	,AM57_MC
	,AM58_MC
	,AM59_MC
	,AM60_MC
	,AM61_MC
	,AM62_MC
	,AM63_MC
	,AM64_MC
	,AM65_MC
	,COEF_LOB
	,DSCCUR_CF
	,COMMENT
	,TOTAUX_MC
	,ACMTRS3_NT
/OUTFILE ${SORT_O2}
/INCLUDE ACMTRSCHK2
/REFORMAT SSD_CF
	,ESB_CF
	,BALSHEY_NF
	,BALSHRMTH_NF
	,BALSHRDAY_NF
	,TRNCOD_CF
	,DBLTRNCOD_CF
	,CTR_NF
	,END_NT
	,SEC_NF
	,UWY_NF
	,UW_NT
	,OCCYEA_NF
	,ACY_NF
	,SCOSTRMTH_NF
	,SCOENDMTH_NF
	,CLM_NF
	,CUR_CF
	,AMT_MC
	,CED_NF
	,BRK_NF
	,PAY_NF
	,KEY_NF
	,RETCTR_NF
	,RETEND_NT
	,RETSEC_NF
	,RTY_NF
	,RETUW_NT
	,RETOCCYEA_NF
	,RETACY_NF
	,RETSCOSTRMTH_NF
	,RETSCOENDMTH_NF
	,RCL_NF
	,RETCUR_CF
	,RETAMT_MC
	,PLC_NT
	,RTO_NF
	,INT_NF
	,RETPAY_NF
	,RETKEY_CF
	,RETINTAMT_MC
	,ACMTRS_NT
	,ACMAMT_MC
	,ACMCUR_CF
	,PRS_CF
	,SEG_NF
	,LOB_CF
	,NAT_CF
	,TYP_CT
	,NORME_CF
	,RATING_CF
	,PATCAT_CT
	,PATTYP_CT
	,PATTERN_ID
	,AM01_MC
	,AM02_MC
	,AM03_MC
	,AM04_MC
	,AM05_MC
	,AM06_MC
	,AM07_MC
	,AM08_MC
	,AM09_MC
	,AM10_MC
	,AM11_MC
	,AM12_MC
	,AM13_MC
	,AM14_MC
	,AM15_MC
	,AM16_MC
	,AM17_MC
	,AM18_MC
	,AM19_MC
	,AM20_MC
	,AM21_MC
	,AM22_MC
	,AM23_MC
	,AM24_MC
	,AM25_MC
	,AM26_MC
	,AM27_MC
	,AM28_MC
	,AM29_MC
	,AM30_MC
	,AM31_MC
	,AM32_MC
	,AM33_MC
	,AM34_MC
	,AM35_MC
	,AM36_MC
	,AM37_MC
	,AM38_MC
	,AM39_MC
	,AM40_MC
	,AM41_MC
	,AM42_MC
	,AM43_MC
	,AM44_MC
	,AM45_MC
	,AM46_MC
	,AM47_MC
	,AM48_MC
	,AM49_MC
	,AM50_MC
	,AM51_MC
	,AM52_MC
	,AM53_MC
	,AM54_MC
	,AM55_MC
	,AM56_MC
	,AM57_MC
	,AM58_MC
	,AM59_MC
	,AM60_MC
	,AM61_MC
	,AM62_MC
	,AM63_MC
	,AM64_MC
	,AM65_MC
	,COEF_LOB
	,DSCCUR_CF
	,COMMENT
	,TOTAUX_MC
	,ACMTRS3_NT
exit
EOF
SORT

NSTEP=${NJOB}_85
#Concat ULAEINF and CSF
#-----------------------------------------------------------------------------
LIBEL="Concat ULAEINF and CSF - PREPARATION D'UN FICHIER CONTENAT TOUS LES CASHFLOW POUR LA CHAINE ESFD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_CASHFLOW} 4000 1"
SORT_I2="${EST_GTSII_REMAINTOPAY_ULAEINF} 4000 1"
SORT_O="${EST_GTSII_GLOBAL_CASHFLOW} 4000 1"
SORT_O2="${EST_GTSII_CLACC_CASHFLOW} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
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
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        ACMTRS3_NT       124:1 - 124:,
		PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:5
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
/CONDITION CSF_ULAE (ACMTRS3_NT = "3114" OR ACMTRS3_NT = "3115") AND PATCAT1_CT="CSF" AND PATTYP_CT="CLACC"
/OUTFILE ${SORT_O}
/OMIT CSF_ULAE
/OUTFILE ${SORT_O2}
/INCLUDE CSF_ULAE
exit
EOF
SORT



###[044]  MERGE CASHFLOWS PREVIOUS DUMMY AND NEW CASHFLOW

	
if [ "${IDF_CT}" = "I17G_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17S_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17L_CSF_MRG_INI" ] || [ "${IDF_CT}" = "I17P_CSF_MRG_INI" ]  
then	



if [ "${NORME_CF}" = "I17G" ] ||  [ "${NORME_CF}" = "I17S" ]
then
   NORME_SUFFIX=I
fi   
if [ "${NORME_CF}" = "I17L" ]
then
   NORME_SUFFIX=M
fi   
if [ "${NORME_CF}" = "I17P" ]
then
   NORME_SUFFIX=K      
fi

if [ ! -f ${ESF_GTSII_DUMMY_ALL_MRG} ]
then
	touch ${ESF_GTSII_DUMMY_ALL_MRG}
fi

ECHO_LOG ""
ECHO_LOG "#=============================Input====================================="

ECHO_LOG "#===> ESF_GTSII_DUMMY_STD.............: ${ESF_GTSII_DUMMY_STD}"
##ECHO_LOG "#===> EST_GTSII_CASHFLOW..............: ${EST_GTSII_CASHFLOW}"

ECHO_LOG "#===> EST_GTSII_GLOBAL_CASHFLOW......: ${EST_GTSII_GLOBAL_CASHFLOW}"
##ECHO_LOG "#===> EST_GTSII_CLACC_CASHFLOW.......: ${EST_GTSII_CLACC_CASHFLOW}"

ECHO_LOG "#=============================Output====================================="
ECHO_LOG "#==>  ESF_GTSII_DUMMY_ALL_MRG ........: $ESF_GTSII_DUMMY_ALL_MRG     "


## TRANSCODIFICATION DES TRNCOD INI ==> STD 

ECHO_LOG "#==> ESF_DLDGTR_P       ........:  ${ESF_DLDGTR_P}              " 

NSTEP=${NJOB}_200
# Creation d'un fichier AT STD avec TRNCOD INI
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD de Norme STD  vers INI :  '2Axxxxx2' en  '2xxxxxI"
AWK_I=${EST_GTSII_GLOBAL_CASHFLOW}
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_GTSII_GLOBAL_CASHFLOW.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

if (\$6 == "2A100012") { \$6 = "2110061${NORME_SUFFIX}" ; }
if (\$6 == "2A100022") { \$6 = "2110062${NORME_SUFFIX}" ; }
if (\$6 == "2A494302") { \$6 = "2149461${NORME_SUFFIX}" ; }
if (\$6 == "2A120012") { \$6 = "2112061${NORME_SUFFIX}" ; }
if (\$6 == "2A120052") { \$6 = "2112062${NORME_SUFFIX}" ; }
if (\$6 == "2A120072") { \$6 = "2112063${NORME_SUFFIX}" ; }
if (\$6 == "2A120062") { \$6 = "2114061${NORME_SUFFIX}" ; }
if (\$6 == "2A200712") { \$6 = "2149462${NORME_SUFFIX}" ; }
if (\$6 == "2A121212") { \$6 = "2112161${NORME_SUFFIX}" ; }

                                                            
 print \$0; 
  }
exit
EOF
AWK

EXECKSH "cp ${DFILT}/${NJOB}_200_${IB}_AWK_GTSII_GLOBAL_CASHFLOW.dat ${EST_GTSII_GLOBAL_CASHFLOW}"     

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL=" MERGE PREVIOUS ESFD3830 DUMMY WITH NEW CASHFLOW FILE  AND NEW NDIC CASHFLOW " 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_DUMMY_STD}  2000 1" 
SORT_I2="${EST_GTSII_GLOBAL_CASHFLOW} 2000 1"
##SORT_I3="${EST_NDIC_CASHFLOW} 2000 1"
SORT_O="${ESF_GTSII_DUMMY_ALL_MRG} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:,
	ACMTRS3_NT       52:1 - 52: 
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT,
      ACMTRS3_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT
 
fi



JOBEND

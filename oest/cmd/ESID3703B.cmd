#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des discounts 
# nom du script SHELL           : ESID3703B.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#		DISCOUNT CALCULATION (extracted from old ESID3703.cmd) 
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[02] 27/07/2012 :spot:23937 -=Dch=-   Ajout de touch pour cr�..ation des fichiers vides en d�..but de job, puis v�..rification en sortie de ESTC1056 : si fichier vide : fin du job
#[03] 02/08/2012 :spot:24041 -=Dch=-   Remplacement de MPPINC par MNAUTO dans la jointure ( segment)
#[04] 28/08/2012 :spot:24041 -=JFVDV=- Am�..nagements (comment out / undo comment out)
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
#[13] 21/10/2013 :spot:26391 Cyrille   Application du pattern ICR (Incurred Incremental) pour les IBNR. Doit etre identique �.. l'application du pattern CSF (cash flow) pour les Paid and Premium Cumulatives
#[14] 17/02/2015 :spot:26391 Cyrille   Ajout du retrocessionaire a la cle dur fichier RMNTP
#[15] 01/06/2015 :spot:26391 Roger     On ne prend pas les postes 2A4261.. dont le montant r�..tro est positif
#[16] 02/06/2015 :spot:26391 Roger     Correction sur fichier en entr�..e.
#[17] 25/06/2015 :spot:28941 PP/Roger  Diverses corrections pour EST49A2 EBS ULAE et Risk Management - refonte du shell
#[18] 03/09/2015 :spot:28941 Philippe  ajout code �..tablissement dans les echanges internes SII
#[19] 02/11/2015 :spot:29615 P PEZOUT
#[20] 03/06/2016 :spot:30543 Florent   on passe �.. 65 ann�..es et ce fichier devient la r�..f�..rences pour les PAATERNSII !
#[21] 18/11/2016 :spira:57799 Florent  Mise au format �.. 71 colonnes pour les fichiers EST_DLDSIIGT*
#[22] 13/11/2017 :spira:64660 Roger    gestion du RTO et PLC dans le fichier R�..tro EST_DLDSIIGTR et EST_DLDSIIGTAR
#[23] 28/06/2018 :spira:69426 JYP      part of discount calculation extracted from ESID3703.cmd
#[024] 14/09/2018 :spira:62219 Roger    Omission des mouvements BDT avec retrocessionnaire interne
#[025] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
#[026] 13/11/2018 :JYP: revert spira:62219 Roger Omission des mouvements BDT avec retrocessionnaire interne
#[027] 07/12/2018 :spira:62219 Roger    Omission des mouvements BDT avec retrocessionnaire interne 
#[028] 05/02/2018 Quentin Desmettre EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
#[029] 02/09/2019 :spira:79910: JYP:  many bugfix currencies
#[030] 11/12/2019 RC  :spira:81496 Mise a jour de l'etablissement dans fichier DLDSIIGTAR a partir de PERICASE
#[031] 18/12/2019 RC  :spira:81791 Correction du tri Step269 pour fichier GTSII_ESCOMPTE_CLM - probleme de devise
#[032] 26/12/2019 JYP :spira:82679 Bugfix cumul par currency step 269
#[033] 18/11/2019 Charles Socie SPIRA : 77191 IFRS17 Bad debt management : discount at lock in rate (REQ11.4) and unwind calculation (REQ11.5) delete step 150 and 160
#[034] 04/03/2020 Charles Socie SPIRA : 83091 Use IFRS 17 discount batch chain for EBS discount
#[035] 18/03/2020 R. Cassis :spira:85448 Correction du tri Step269 Devise CUR_CF affectee pour ACCRET = RI egalement -> non retour arriere
#[036] 07/05/2020 Charles Socie : SPIRA 83206  IFRS17 REQ11.7 For contract incepting before closing date please adapt the pattern used for discounting add pericase to ESTC1056A
#[037] 13/07/2020 R. Cassis :spira: 84474  Manque la colonne SEG_NF dans la cle de tri step269
#[038] 31/08/2020 Charles Socie : SPIRA 88975  IFRS17 add Retropericase to ESTC1056A
#[039] 04/08/2020 R. Cassis :spira: 79427  Remplacement du ESTC1081 par des tris et utilisation du fichier FPLATXCUM a la place du fichier FCLIENT pour l'info RI.
#[040] 22/12/2020 : M.NAJI : 	. SPIRA 91531 
#							 	. variabilisation du TYPEINV et NORME
# 								. Ajout de l'IDF_CT  pr�fix� par la norme
#[041] 02/03/2021 JYP : SPIRA 92514 : add ACMTRSL3_NT into DSC_CLM file
#[042] 24/04/2025 MZM : SPIRA 112870 BBNI- Undiscounted future transactions mapping : DSC BBNI
#[043] 23/05/2025 MZM : SPIRA 113071  NRT : Missing TL EBS Discount (INT) 
#[044] 30/07/2025 MZM : US 6065 BBNI - Missing 1A46060G transaction	Spira 113133 No Transco pour 	"%A416032"
#[045] 04/09/2025 MZM : US 6087 BBNI - missing discount TL in RR view
#[046] 03/03/2026 MZM : US 7847:  FIX ITK EBS INI 
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
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`
CLOPRD=`echo ${ICLODAT_D} | awk '{print substr($0,1,6)}'`

touch ${DFILT}/${NCHAIN}_vide.dat

# Job Initialisation
JOBINIT

TYPEPO=""
TYPETRT_CT=GT_SII
if [ "${TYPEINV}" != "INV" ]
then
  # en sortie du ESP4000
  if [ "${TYPEINV}" = "POS" ]
  then
    TYPEPO=SO
  else
    TYPEPO=CO
  fi
fi



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> TYPEPO.........................: ${TYPEPO}"
ECHO_LOG "#===> TRIM_NF........................: ${TRIM_NF}"
ECHO_LOG "#===> TYPETRT_CT.....................: ${TYPETRT_CT}"
ECHO_LOG "#===> ICLODAT_D......................: ${ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_A......................: ${ICLODAT_A}"
ECHO_LOG "#===> ICLODAT_M......................: ${ICLODAT_M}"
ECHO_LOG "#===> ICLODAT_J......................: ${ICLODAT_J}"
ECHO_LOG "#===> CRE_D..........................: ${CRE_D}"
ECHO_LOG "#===> CLOPRD.........................: ${CLOPRD}"
ECHO_LOG "#....................... INPUT ..........................................."
ECHO_LOG "#===> EST_FSEGPATTERN_ICR............: ${EST_FSEGPATTERN_ICR}"
ECHO_LOG "#===> EST_FSEGPATTERN_BDT............: ${EST_FSEGPATTERN_BDT}"
ECHO_LOG "#===> EST_FSEGPATTERN_DSC............: ${EST_FSEGPATTERN_DSC}"
ECHO_LOG "#===> EST_DLEIFTECLEDSIIEP...........: ${EST_DLEIFTECLEDSIIEP}"
ECHO_LOG "#===> EST_FCURSII....................: ${EST_FCURSII}"
ECHO_LOG "#===> EST_FDETTRS....................: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FPLC.......................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FRATINGRTO.................: ${EST_FRATINGRTO}"
ECHO_LOG "#===> EST_FSSDACTR...................: ${EST_FSSDACTR}"
ECHO_LOG "#===> EST_FTRSLNK....................: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_IADPERICASE................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS..: ${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}"
ECHO_LOG "#===> EST_GTSII_CASHFLOW.............: ${EST_GTSII_CASHFLOW}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAE.....: ${EST_GTSII_REMAINTOPAY_ULAE}"
ECHO_LOG "#===> EST_GTSII_REMAINTOPAY_ULAEINF..: ${EST_GTSII_REMAINTOPAY_ULAEINF}"
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE.............: ${ESF_GTSII_ESCOMPTE}"
ECHO_LOG "#===> EST_IADPERICASE_STD............: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_IRDPERICASE0...............: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_IADPERICASE_BBNI...........: ${EST_IADPERICASE_BBNI}"
ECHO_LOG "#===> ESF_IRDPERICASE0_BBNI..........: ${EST_IRDPERICASE0_BBNI}"
ECHO_LOG "#............................. OUTPUT ....................................."
ECHO_LOG "#===> EST_GTSII_ESCOMPTE_CLM.........: ${EST_GTSII_ESCOMPTE_CLM}"
ECHO_LOG "#===> EST_DLEIFTECLEDSIIEI...........: ${EST_DLEIFTECLEDSIIEI}"
ECHO_LOG "#===> EST_DLDSIIGTAA.................: ${EST_DLDSIIGTAA}"
ECHO_LOG "#===> EST_FTECLEDSII.................: ${EST_FTECLEDSII}"
ECHO_LOG "#===> EST_DLDSIIGTAR.................: ${EST_DLDSIIGTAR}"
ECHO_LOG "#===> EST_DLDSIIGTR..................: ${EST_DLDSIIGTR}"
ECHO_LOG "#===> EST_DLEIFTECLEDSII.............: ${EST_DLEIFTECLEDSII}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
#Last version of ESID3720 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLEIFTECLEDSII}`/${PCH}ES*D3720_DLEIFTECLEDSIIEI.dat"

# creation des fichiers vide
touch ${EST_FTECLEDSII}
touch ${EST_DLDSIIGTAA}
touch ${EST_DLDSIIGTAR}
touch ${EST_DLDSIIGTR}

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo  "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`

NSTEP=${NJOB}_01
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${datedel}*.dat"
RMFIL "${DFILT}/${NJOB}*${datedel1}*.dat"
RMFIL "${DFILT}/${NJOB}*${datedel2}*.dat"



#[013] Apply ICR (incurred incremental) pattern to IBNR and future claims
if [ -s ${EST_FSEGPATTERN_ICR} ]
then
  NSTEP=${NJOB}_180
  #-----------------------------------------------------------------------------
  LIBEL="ICR CALCULATION : ICR pattern applied to IBRN and future claims"

  # Type of pattern to apply to GT data (5 digits)
  #[036] add Context_ct, Closing_date and I3
  PATTERN_CATEGORY="ICR  "

  PRG=ESTC1056A
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  export ${PRG}_I1=${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}
  export ${PRG}_I2=${EST_FSEGPATTERN_ICR}
  export ${PRG}_I3=${EST_IADPERICASE_STD}
  export ${PRG}_I4=${EST_IRDPERICASE0}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ICR.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_ICR_NOTUSED.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY_ULAEICR.dat
  export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_REMAINTOPAY_FHNI_NOTUSED.dat
  EXECPRG
else
  NSTEP=${NJOB}_181
  # Create an empty file for later use
  #------------------------------------------------------------------------------
  LIBEL="ICR CALCULATION touch ${DFILT}/${NJOB}_180_${IB}_ESTC1056A_GTSII_ICR.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_180_${IB}_ESTC1056A_GTSII_ICR.dat"
fi
# fin [011]


NSTEP=${NJOB}_200
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_CASHFLOW} 2000 1"
SORT_I2="${ESF_GTSII_ESCOMPTE} 2000 1"
SORT_I3="${DFILT}/${NJOB}_180_${IB}_ESTC1056A_GTSII_ICR.dat 2000 1"  #[014] ajout du fichier ICR : Incurred Incremental pattern
SORT_I4="${EST_GTSII_REMAINTOPAY_ULAE} 2000 1"
SORT_I5="${EST_GTSII_REMAINTOPAY_ULAEINF} 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CUMUL1.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF          8:1 -  8:,
        END_NT          9:1 -  9:,
        SEC_NF         10:1 - 10:,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:,
        RETCTR_NF      24:1 - 24:,
        RETEND_NT      25:1 - 25:,
        RETSEC_NF      26:1 - 26:,
        RTY_NF         27:1 - 27:,
        RETUW_NT       28:1 - 28:,
        PLC_NT         36:1 - 36:,
        ACMTRS_NT      42:1 - 42:,
        ACMCUR_CF      44:1 - 44:,
        PRS_CF         45:1 - 45:,
        TYP_CT         49:1 - 49:,
        NORME_CF       50:1 - 50:,
        RATING_CF      51:1 - 51:,
        PATCAT_CT      52:1 - 52:,
        PATCAT1_CT     52:1 - 52:3,
        PATTYP_CT      53:1 - 53:,
        PATTYP1_CT     53:1 - 53:3,
        PATTERN_ID     54:1 - 54:,
        AMT_M          19:1 - 19:EN 15/3,
        RETAMT_M       35:1 - 35:EN 15/3,
        RETINTAMT_M    41:1 - 41:EN 15/3,
        ACMAMT_M       43:1 - 43:EN 15/3,
        AM01_M         55:1 - 55:EN 15/3,
        AM02_M         56:1 - 56:EN 15/3,
        AM03_M         57:1 - 57:EN 15/3,
        AM04_M         58:1 - 58:EN 15/3,
        AM05_M         59:1 - 59:EN 15/3,
        AM06_M         60:1 - 60:EN 15/3,
        AM07_M         61:1 - 61:EN 15/3,
        AM08_M         62:1 - 62:EN 15/3,
        AM09_M         63:1 - 63:EN 15/3,
        AM10_M         64:1 - 64:EN 15/3,
        AM11_M         65:1 - 65:EN 15/3,
        AM12_M         66:1 - 66:EN 15/3,
        AM13_M         67:1 - 67:EN 15/3,
        AM14_M         68:1 - 68:EN 15/3,
        AM15_M         69:1 - 69:EN 15/3,
        AM16_M         70:1 - 70:EN 15/3,
        AM17_M         71:1 - 71:EN 15/3,
        AM18_M         72:1 - 72:EN 15/3,
        AM19_M         73:1 - 73:EN 15/3,
        AM20_M         74:1 - 74:EN 15/3,
        AM21_M         75:1 - 75:EN 15/3,
        AM22_M         76:1 - 76:EN 15/3,
        AM23_M         77:1 - 77:EN 15/3,
        AM24_M         78:1 - 78:EN 15/3,
        AM25_M         79:1 - 79:EN 15/3,
        AM26_M         80:1 - 80:EN 15/3,
        AM27_M         81:1 - 81:EN 15/3,
        AM28_M         82:1 - 82:EN 15/3,
        AM29_M         83:1 - 83:EN 15/3,
        AM30_M         84:1 - 84:EN 15/3,
        AM31_M         85:1 - 85:EN 15/3,
        AM32_M         86:1 - 86:EN 15/3,
        AM33_M         87:1 - 87:EN 15/3,
        AM34_M         88:1 - 88:EN 15/3,
        AM35_M         89:1 - 89:EN 15/3,
        AM36_M         90:1 - 90:EN 15/3,
        AM37_M         91:1 - 91:EN 15/3,
        AM38_M         92:1 - 92:EN 15/3,
        AM39_M         93:1 - 93:EN 15/3,
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
        ACMTRS3_NT      124:1 - 124:,
        FILLER1        1:1 - 2:,
        FILLER2        8:1 - 51:,
        FILLER4       53:1 - 124:
/DERIVEDFIELD CHAIN1_VIDE 1"~"
/DERIVEDFIELD CLODAT_A "${ICLODAT_A}~"
/DERIVEDFIELD CLODAT_M "${ICLODAT_M}~"
/DERIVEDFIELD CLODAT_J "${ICLODAT_J}~"
/KEYS   CTR_NF,
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
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        TYP_CT,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        ACMTRS3_NT
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,CLODAT_A
         ,CLODAT_M
         ,CLODAT_J
         ,CHAIN1_VIDE
         ,CHAIN1_VIDE
         ,FILLER2
         ,PATCAT1_CT
         ,CHAIN1_VIDE
         ,FILLER4
exit
EOF
SORT

NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_GTSII_CUMUL1.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIICSFAA.dat "
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAA.dat "
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAR.dat "
SORT_O4="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIICSFAR.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
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
        PATTYP1_CT       53:1 - 53:3,
        PATTERN_ID       54:1 - 54:,
        FIN              55:1 - 119:,
        COEF_LOB        120:1 - 120:,
        DSCCUR_CF       121:1 - 121:,
        COMMENT         122:1 - 122:,
        TOTAUX_M        123:1 - 123:EN 15/3,
        TIFI_M          124:1 - 124:EN 15/3,
	ACMTRS3_NT       125:1 - 125:
/CONDITION ACCEP_GT  TYP_CT  = "A"  AND ((PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR") OR PATTYP1_CT="INF")
/CONDITION RETRO_GT  TYP_CT != "A"  AND ((PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR") AND PATTYP_CT != "RMNTP")
/CONDITION ACCEP_SII TYP_CT  = "A"  AND ((PATCAT1_CT  = "CSF" OR PATCAT1_CT  = "ICR") AND PATTYP1_CT!="INF" )
/CONDITION RETRO_SII TYP_CT != "A"  AND (PATCAT1_CT != "BDT" OR (NORME_CF = "ALLNO" AND PATCAT1_CT = "BDT") OR PATTYP1_CT = "BDT")
/KEYS CTR_NF,
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
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF,
      ACMTRS3_NT
/OUTFILE ${SORT_O}
/INCLUDE ACCEP_SII
/OUTFILE ${SORT_O2}
/INCLUDE ACCEP_GT
/OUTFILE ${SORT_O3}
/INCLUDE RETRO_GT
/OUTFILE ${SORT_O4}
/INCLUDE RETRO_SII
exit
EOF
SORT


NSTEP=${NJOB}_262
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSFAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAR.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        FILLER1           1:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        FILLER2          20:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        FILLER3          36:1 - 40:,
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
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        PLC_NT,
        RETCUR_CF,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        TYP_CT,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        SSD_CF,
        ESB_CF,
	ACMTRS3_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_265
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL for retrocessionaire subsidiaries..."
PRG=ESTC2315A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOPRD_D ${CLOPRD}
DBCLO_D ${ICLODAT_D}
CRE_D ${CRE_D}
TYPETRT_CT ${TYPETRT_CT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_262_${IB}_SORT_DLDSIIGTAR.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FSSDACTR}
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIFTECLEDSII.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR.dat
EXECPRG


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC2315A "
ECHO_LOG "#===> Nombre de lignes AI generees "
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLEIFTECLEDSII.dat
ECHO_LOG "#===> Nombre de lignes RI+R origine "
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR.dat
ECHO_LOG "#===> Nombre de lignes RI origine "
grep ~RI ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR.dat > ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR_RI.dat
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR_RI.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_266
#[018] correction sur le code �tablissement
#-----------------------------------------------------------------------------
LIBEL="SORT OF ESTC2315A_DLEIFTECLEDSII.dat echanges internes generes 'AI' "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLEIFTECLEDSII.dat 2000 1"
if [ "${NORME_CF}" = "I4I" ] && [ "${VSERQS_I4I}" != "YES" ]
then
        SORT_I2="${SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
}"
fi
if [ "${NORME_CF}" = "EBS" ] && [ "${VSERQS_EBS}" != "YES" ]
then
        SORT_I2="${SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
}"
fi

if [ "${NORME_CF}" = "I17G" ] && [ "${VSERQS_I17G}" != "YES" ]
then
        SORT_I2="${SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
}"
fi

if [ "${NORME_CF}" = "I17P" ] && [ "${VSERQS_I17P}" != "YES" ]
then
        SORT_I2="${SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
}"
fi


if [ "${NORME_CF}" = "I17L" ] && [ "${VSERQS_I17L}" != "YES" ]
then
        SORT_I2="${SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
}"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLEIFTECLEDSII.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        FILLER1           1:1 - 18:,
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
        FILLER2          20:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        FILLER3          36:1 - 40:,
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
        FILLER4          44:1 - 51:,
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
        CLISSD_NF       124:1 - 124:,
        CLOPRD          125:1 - 125:,
        DBCLO_D         126:1 - 126:,
        CRE2_D          127:1 - 127:,
        ORGSSD_CF       128:1 - 128:,
        FILLER5         124:1 - 128:,
	ACMTRS3_NT       133:1 - 133:
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
/DERIVEDFIELD CHAIN1_VIDE 1"~"
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        RETCUR_CF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        SSD_CF,
        ESB_CF,
        PLC_NT,
        ACMTRS_NT,
        ACMCUR_CF,
        PRS_CF,
        TYP_CT,
        NORME_CF,
        RATING_CF,
        PATCAT_CT,
        PATTYP_CT,
        PATTERN_ID,
        SEG_NF,
	ACMTRS3_NT
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
         ,RETAMT_MC
         ,FILLER3
         ,RETINTAMT_MC
         ,ACMTRS_NT
         ,ACMAMT_MC
         ,FILLER4
         ,PATCAT1_CT
         ,CHAIN1_VIDE
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
         ,FILLER5
	 ,ACMTRS3_NT
exit
EOF
SORT


NSTEP=${NJOB}_267
#------------------------------------------------------------------------------
LIBEL="Sort of life A perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_268
#-----------------------------------------------------------------------------
LIBEL="Current adding establishment code in TL ..."
PRG=ESTM7604A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_266_${IB}_SORT_DLEIFTECLEDSII.dat
export ${PRG}_I2=${DFILT}/${NJOB}_267_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIFTECLEDSII_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANOS_O.log
export ${PRG}_O3=${EST_DLEIFTECLEDSIIEI}
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTM7604 "
ECHO_LOG "#===> Nombre de lignes AI lues "
wc -l ${DFILT}/${NJOB}_266_${IB}_SORT_DLEIFTECLEDSII.dat
ECHO_LOG "#===> Nombre de lignes AI sans Etablissements interserveurs"
wc -l ${EST_DLEIFTECLEDSIIEI}
ECHO_LOG "#===> Nombre de lignes AI avec Etablissements intraserveurs"
wc -l ${DFILT}/${NJOB}_268_${IB}_ESTM7604A_DLEIFTECLEDSII_O1.dat

NSTEP=${NJOB}_268A
#------------------------------------------------------------------------------
LIBEL="Reformat for ACMTRSL3"
EXECKSH_MODE="W"
EXECKSH_I=${DFILT}/${NJOB}_268_${IB}_ESTM7604A_DLEIFTECLEDSII_O1.dat
EXECKSH_O=${DFILT}/${NSTEP}_${IB}_ESTM7604A_DLEIFTECLEDSII_O1_MOD.dat
EXECKSH "cut  -f1-123,129 -d~"

#[035] [037]
NSTEP=${NJOB}_269
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSF                 : les lignes CSF et RMNTP
# ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat            : les lignes accept hors CSF et hors RMNTP
# ${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR.dat        : les lignes retro hors CSF et hors RMNTP, top�es R ou RI pour celles ayant particip� aux echanges internes
# ${DFILT}/${NJOB}_268_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat : les lignes accept issues de la retro interne
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSFAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_265_${IB}_ESTC2315A_DLDSIIGTAR.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_268A_${IB}_ESTM7604A_DLEIFTECLEDSII_O1_MOD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAA.dat"
SORT_O3="${EST_GTSII_ESCOMPTE_CLM} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        CTR1_NF           8:1 -  8:1,
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
        TYP1_CT          49:1 - 49:1,
        NORME_CF         50:1 - 50:,
        RATING_CF        51:1 - 51:,
        PATCAT_CT        52:1 - 52:,
        PATCAT1_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        PATTYP1_CT       53:1 - 53:3,
        PATTERN_ID       54:1 - 54:,
        AM1_40           55:1 - 94:,
        AM41_65          95:1 - 119:,
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
        TIFI_M          124:1 - 124:EN 15/3,
        ACMTRS3_NT      124:1 - 124:
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      CUR_CF,
      ACMCUR_CF,
      RETCUR_CF,	  
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      ACMTRS_NT,
      PRS_CF,
      PATCAT_CT,
      PATTYP_CT,
      TYP_CT,
      NORME_CF,
      RATING_CF,
      PATTERN_ID,
      SEG_NF,
      SSD_CF,
      ESB_CF,
      ACMTRS3_NT
/CONDITION pattern PATTERN_ID = ""
/CONDITION pattyp  PATTYP_CT = ""
/CONDITION patcat  PATCAT_CT = ""
/CONDITION lobNONVIE  (LOB_CF != "" AND LOB_CF != "30" AND LOB_CF != "31")
/CONDITION lobacc  TYP1_CT = "A"
/CONDITION ACCEP_GT  TYP1_CT  = "A"  AND ((PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR") OR PATTYP1_CT="INF")
/CONDITION COND_FUTURECLAIMS PATCAT1_CT ="DSC" AND CTR1_NF != "" AND CTR1_NF != " " AND
                             (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "307" OR ACMTRS_NT = "309" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" )
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER     "CloP~"
/DERIVEDFIELD PATTERN2_ID if pattern then "EMPTY" else PATTERN_ID
/DERIVEDFIELD PATTYP2 if  pattyp then "ER" else PATTYP_CT
/DERIVEDFIELD PATCAT2 if  patcat then "ER" else PATCAT_CT
/DERIVEDFIELD LOBACC_NEW if  lobacc then LOB_CF else ""
/DERIVEDFIELD LOBRET_NEW if  lobacc then "" else LOB_CF
/DERIVEDFIELD CUR_CF_NEW if lobacc then CUR_CF else RETCUR_CF
/DERIVEDFIELD CUR_CF_NEW2 if lobacc then CUR_CF else RETCUR_CF
/DERIVEDFIELD CLODAT_D "${ICLODAT_D}~"
/DERIVEDFIELD CLOTYP_CT "${TYPEINV}~"
/DERIVEDFIELD CLODAT_A "${ICLODAT_A}~"
/DERIVEDFIELD CLODAT_M "${ICLODAT_M}~"
/DERIVEDFIELD CLODAT_J "${ICLODAT_J}~"
/DERIVEDFIELD TYPA_CT "A~"
/DERIVEDFIELD RETRO_VIDE 18"~"
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
/DERIVEDFIELD CHAIN1_VIDE 1"~"
/DERIVEDFIELD PRS_CFL2 "750~"
/OUTFILE ${SORT_O}
/INCLUDE lobNONVIE
/REFORMAT
  SSD_CF
 ,ESB_CF
 ,CLODAT_D
 ,CLOTYP_CT
 ,BALSHEY_NF
 ,BALSHRMTH_NF
 ,BALSHRDAY_NF
 ,CTR_NF
 ,END_NT
 ,SEC_NF
 ,UWY_NF
 ,UW_NT
 ,RETCTR_NF
 ,RETEND_NT
 ,RETSEC_NF
 ,RTY_NF
 ,RETUW_NT
 ,PLC_NT
 ,RTO_NF
 ,ACMTRS_NT
 ,ACMAMT_MC
 ,CUR_CF_NEW
 ,DSCCUR_CF
 ,PRS_CF
 ,SEG_NF
 ,LOBACC_NEW
 ,LOBRET_NEW
 ,NAT_CF
 ,TYP_CT
 ,NORME_CF
 ,RATING_CF
 ,COEF_LOB
 ,PATCAT2
 ,PATTYP2
 ,PATTERN2_ID
 ,DATTRAIT
 ,USER
 ,TOTAUX_MC
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
 ,COMMENT
 ,TIFI_M
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
 ,ACMTRS3_NT
/OUTFILE ${SORT_O2}
/INCLUDE ACCEP_GT
/OUTFILE ${SORT_O3}
/INCLUDE COND_FUTURECLAIMS
/REFORMAT
  SSD_CF
  ,ESB_CF
  ,CLODAT_A
  ,CLODAT_M
  ,CLODAT_J
  ,CHAIN1_VIDE
  ,CHAIN1_VIDE
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
  ,AMT_M
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,RETRO_VIDE
  ,ACMTRS_NT
  ,ACMAMT_M
  ,CUR_CF_NEW2
  ,PRS_CFL2
  ,TYP_CT
  ,LOB_CF
  ,NAT_CF
  ,TYPA_CT
  ,NORME_CF
  ,RATING_CF
  ,PATCAT1_CT
  ,CHAIN1_VIDE
  ,PATTYP_CT
  ,PATTERN_ID
  ,AM1_40 
  ,AM41_65
  ,COEF_LOB
  ,DSCCUR_CF
  ,COMMENT
  ,TOTAUX_M
  ,ACMTRS3_NT
exit
EOF
SORT


NSTEP=${NJOB}_269z
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1075
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_269_${IB}_SORT_FTECLEDSII.dat
#export ${PRG}_O1=${EST_FTECLEDSII}  # [006]
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDSII.dat  # [006] [027]
EXECPRG



NSTEP=${NJOB}_269z01
# Filter T.code on ACMTRSL3_NT values
#---------------------------------------------------------------------------
LIBEL="Filter T.code on ACMTRSL3_NT values"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:
       ,RETSEC_NF 2:1 - 2:EN
       ,RETRTY_NF 3:1 - 3:
       ,RTO_NF    8:1 - 8:
/CONDITION rto RTO_NF != ""        
/KEYS RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
/SUM
/INCLUDE rto
/REFORMAT RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_269z02
# Get internal Retro info by Join with FPLATXCUM
#------------------------------------------------------------------------------
LIBEL="Get internal Retro info by Join with FPLATXCUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_269z_${IB}_ESTC1075_FTECLEDSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII_O.dat OVERWRITE 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF    13:1 -  13:,
        RETSEC_NF    15:1 -  15:,
        RTY_NF       16:1 -  16:,
        RTO_NF       19:1 -  19:,
        COLS1         1:1 - 106:,
        F_RETCTR_NF   1:1 -   1:,
        F_RETSEC_NF   2:1 -   2:,
        F_RTY_NF      3:1 -   3:,
        F_RTO_NF      4:1 -   4:
/joinkeys
         RETCTR_NF   
        ,RETSEC_NF   
        ,RTY_NF   
        ,RTO_NF    
/INFILE ${DFILT}/${NJOB}_269z01_${IB}_FPLATXCUM.dat 100 1 "~"
/joinkeys
         F_RETCTR_NF   
        ,F_RETSEC_NF   
        ,F_RTY_NF   
        ,F_RTO_NF    
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_269z03
# Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT
#---------------------------------------------------------------------------
LIBEL="Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_269z02_${IB}_SORT_FTECLEDSII_O.dat 2000 1"
SORT_O=${EST_FTECLEDSII}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS PATCAT_CT   33:1 -  33:
       ,RTO_NF     107:1 - 107:
       ,COLS1        1:1 - 106:
/COPY
/REFORMAT COLS1
exit
EOF
SORT

#[039] fin
#####################################

NSTEP=${NJOB}_269z1
#-----------------------------------------------------------------------------
LIBEL="Replace Grouping code and Update ULAE acmtrsl2 with 3114/3115"
AWK_I=${DFILT}/${NJOB}_269_${IB}_SORT_DLDSIIGTAA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDSIIGTAA.dat
AWK_CMD=`CFTMP`

INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        {\$45="750"; if (\$124 == 3115 || \$124 == 3114) {\$42=\$124;}};
                        { print \$0;}
exit
EOF
AWK

NSTEP=${NJOB}_269z2
#------------------------------------------------------------------------------
LIBEL="Remove ACMTRSL3 DLDSIIGTAA.dat before sending file to TL"
EXECKSH_MODE="W"
EXECKSH_I=${DFILT}/${NJOB}_269z1_${IB}_AWK_DLDSIIGTAA.dat
EXECKSH_O=${DFILT}/${NJOB}_269_${IB}_SORT_DLDSIIGTAA.dat
EXECKSH "cut  -f1-122,123 -d~"


NSTEP=${NJOB}_270
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1060A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_269_${IB}_SORT_DLDSIIGTAA.dat
export ${PRG}_I2=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAA.dat  # [006]
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAA_ANO.log  # [006]
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1060A "
ECHO_LOG "#===> Nombre de lignes a generer "
wc -l ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat
ECHO_LOG "#===> Nombre de lignes GT generees "
wc -l ${DFILT}/${NJOB}_270_${IB}_ESTC1060A_DLDSIIGTAA.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_280
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAA tri du fichier genere par contrat accept et contrat retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC1060A_DLDSIIGTAA.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAA.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAA_NULL.dat
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
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
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
      RETCUR_CF,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION MONTANTNONNUL ( AMT_M !=0 OR RETAMT_M !=0)
/OUTFILE ${SORT_O}
/INCLUDE MONTANTNONNUL
/OUTFILE ${SORT_O2}
/OMIT MONTANTNONNUL
exit
EOF
SORT


NSTEP=${NJOB}_290
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAA Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_280_${IB}_SORT_DLDSIIGTAA.dat # [006]
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLDSIIGTAA}
EXECPRG

NSTEP=${NJOB}_291
#-----------------------------------------------------------------------------
LIBEL="Replace Grouping code and Update ULAE acmtrsl2 with 3114/3115"
AWK_I=${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDSIIGTAR.dat
AWK_CMD=`CFTMP`

INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        {\$45="750"; if (\$124 == 3115 || \$124 == 3114) {\$42=\$124;}};
                        { print \$0;}
exit
EOF
AWK


NSTEP=${NJOB}_292
#------------------------------------------------------------------------------
LIBEL="Remove ACMTRSL3 DLDSIIGTAR before sending file to TL"
EXECKSH_MODE="W"
EXECKSH_I=${DFILT}/${NJOB}_291_${IB}_AWK_DLDSIIGTAR.dat
EXECKSH_O=${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAR.dat
EXECKSH "cut  -f1-122,123 -d~"


NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAR Generation des lignes GT supplementaires pour Retro ventile par accept GTAR"
PRG=ESTC1060A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAR.dat
export ${PRG}_I2=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR_ANO.dat
EXECPRG


#[22]
NSTEP=${NJOB}_310
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAR tri du fichier "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC1060A_DLDSIIGTAR.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAR.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAR_NULL.dat
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
        RETINTAMT_M      41:1 - 41: EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION MONTANTNONNUL ( AMT_M !=0 OR RETAMT_M !=0)
/OUTFILE ${SORT_O}
/INCLUDE MONTANTNONNUL
/REFORMAT FILLER1,PLC_NT,RTO_NF,FILLER2
/OUTFILE ${SORT_O2}
/OMIT MONTANTNONNUL
exit
EOF
SORT


#[015] [22]
NSTEP=${NJOB}_315
#-----------------------------------------------------------------------------
LIBEL="Omit des lignes des postes 2A4261.. dont le montant r�tro est positif "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_310_${IB}_SORT_DLDGTAR.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAR.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAR_POSITIF.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:1 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        RETINTAMT_M      41:1 - 41: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF,
      CUR_CF,
      TRNCOD_CF
/CONDITION BADdebtPOSITIF ( TRNCOD34_CF = "2A4261" AND RETAMT_M >= 0 )
/OUTFILE ${SORT_O}
/OMIT BADdebtPOSITIF
/OUTFILE ${SORT_O2}
/INCLUDE BADdebtPOSITIF
exit
EOF
SORT


NSTEP=${NJOB}_320
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTAR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_315_${IB}_SORT_DLDGTAR.dat  #[013]
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAR.dat   #[22]
EXECPRG

#[22]
NSTEP=${NJOB}_325
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Creation DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_320_${IB}_ESTM7603_DLDGTAR.dat 1000 1"
SORT_O="${EST_DLDSIIGTAR} OVERWRITE 1000 1"
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
        RETINTAMT_M      41:1 - 41: EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION MONTANTNONNUL ( AMT_M !=0 OR RETAMT_M !=0)
/OUTFILE ${SORT_O}
/INCLUDE MONTANTNONNUL
exit
EOF
SORT

#[22]
NSTEP=${NJOB}_330
#-----------------------------------------------------------------------------
LIBEL="Creation fichier DLDSIIGTR a partir du DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_320_${IB}_ESTM7603_DLDGTAR.dat 1000 1"
SORT_O="${EST_DLDSIIGTR} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT1            1:1 -  7:,
        TRNCOD_CF         6:1 -  6:,
        AMT_M            19:1 - 19:EN 18/3,
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
        RETAMT_M         35:1 - 35:EN 18/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 18/3,
        FIN1             42:1 - 56:,
        FIN2             58:1 - 71:
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD AMT_MC "0.000~"
/DERIVEDFIELD RETINTAMT_MC "0.000~"
/DERIVEDFIELD VIDES11 11"~"
/DERIVEDFIELD VIDES04  4"~"
/DERIVEDFIELD ORICOD_LS2  "EBSGTA~"
/KEYS RETCTR_NF,
      RETEND_NT,
      RETCUR_CF,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      TRNCOD_CF
/OUTFILE ${SORT_O}
/REFORMAT DEBUT1,
          VIDES11,
          AMT_MC,
          VIDES04,
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
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FIN1,
          ORICOD_LS2,
          FIN2
exit
EOF
SORT

#[042] TRANSCODIFICATION des CONTRATS BBNI 

if  [ "$IDF_CT" =  "EBS_ESPD2620_BBNI" ]
then

NSTEP=${NJOB}_340
#------------------------------------------------------------------------------------
LIBEL="ONLY RETRO NP from EST_IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE0_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE0_RETRO_PROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF        3:1 -   3:,
        RETEND_NF        4:1 -   4:,
        RETSEC_NF        5:1 -   5:,
        RTY_NF           6:1 -   6:,
        RETUW_NT         7:1 -   7:,    
        NATRET_CF        49:1 - 49:               

/KEYS   RETCTR_NF,
				RETEND_NF,    
				RETSEC_NF,
				RTY_NF,   
				RETUW_NT 				
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT RETRO_NP
exit
EOF
SORT


NSTEP=${NJOB}_345
#------------------------------------------------------------------------------------
LIBEL="ONLY RETRO NP from EST_IRDPERICASE0_BBNI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0_BBNI} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE0_BBNI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE0_BBNI_RETRO_PROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF        3:1 -   3:,
        RETEND_NF        4:1 -   4:,
        RETSEC_NF        5:1 -   5:,
        RTY_NF           6:1 -   6:,
        RETUW_NT         7:1 -   7:,    
        NATRET_CF        49:1 - 49:               

/KEYS   RETCTR_NF,
				RETEND_NF,    
				RETSEC_NF,
				RTY_NF,   
				RETUW_NT 				
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT RETRO_NP
exit
EOF
SORT


ECHO_LOG "#===> TRANSCODIFICATION des CONTRATS BBNI .............: ${EST_DLDSIIGTAA}"

NSTEP=${NJOB}_350
#-----------------------------------------------------------------------------
LIBEL="SORT EST_DLDSIIGTAA contrat assmued  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDSIIGTAA}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	      CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:  
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
exit
EOF
SORT

ECHO_LOG "#===> EST_IADPERICASE_BBNI..DEBUG....001.......: ${EST_IADPERICASE_BBNI}   "


NSTEP=${NJOB}_360
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAA  BBNI Contracts from PERICASE BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_DLDSIIGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAA_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${EST_IADPERICASE_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_365
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAA  BBNI Contracts from PERICASE BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_DLDSIIGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAA_BBNI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${EST_IADPERICASE_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT

####[044]

NSTEP=${NJOB}_370
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '2Axxxxx2' en EBS BBNI' "
AWK_I="${DFILT}/${NJOB}_365_${IB}_DLDSIIGTAA_BBNI.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLDSIIGTAA_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
   

		if (\$6 == "1A100012")  { \$6 = "1A10001G" ;print \$0;} 
		if (\$6 == "1A100022")  { \$6 = "1A10062G" ;print \$0;} 
		if (\$6 == "1A120062")  { \$6 = "1A14061G" ;print \$0;} 
		if (\$6 == "1A120012")  { \$6 = "1A12001G" ;print \$0;} 
		if (\$6 == "1A120052")  { \$6 = "1A12007G" ;print \$0;} 
		if (\$6 == "1A120072")  { \$6 = "1A12007G" ;print \$0;} 
		if (\$6 == "1A461112")  { \$6 = "1A46060G" ;print \$0;} 
		if (\$6 == "1A494302")  { \$6 = "1A49461G" ;print \$0;} 
		if (\$6 == "1A200712")  { \$6 = "1A49462G" ;print \$0;} 
		if (\$6 == "1A416012")  { \$6 = "1A41101G" ;print \$0;} 
		if (\$6 == "1A121212")  { \$6 = "1A12161G" ;print \$0;} 

 
##[044]if (\$6 == "1A416032") { \$6 = "1A41103G";print \$0;}  



fi
  }
exit
EOF
AWK

NSTEP=${NJOB}_375
#-----------------------------------------------------------------------------
LIBEL="MERGE   BBNI ASS and OTHERS Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_370_${IB}_AWK_DLDSIIGTAA_BBNI.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_360_${IB}_DLDSIIGTAA_OTHERS.dat 2000 1"
SORT_O="${EST_DLDSIIGTAA}  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	      CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

ECHO_LOG "#===> TRANSCODIFICATION des CONTRATS BBNI .............: ${EST_DLDSIIGTAR} "

NSTEP=${NJOB}_380
#-----------------------------------------------------------------------------
LIBEL="SORT EST_DLDSIIGTAR contrat assmued  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDSIIGTAR}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF       6:1 -  6:1,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:  
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
exit
EOF
SORT


NSTEP=${NJOB}_385
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAR  BBNI Contracts from PERICASE BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_DLDSIIGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       		 24:1 - 24:,
        RETEND_NT       		 25:1 - 25:,
        RETSEC_NF       		 26:1 - 26:,
        RTY_NF          		 27:1 - 27:,
        RETUW_NT        		 28:1 - 28:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF   ,
        RETUW_NT  
/INFILE ${EST_IRDPERICASE0_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_390
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAR  BBNI Contracts from PERICASE BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_DLDSIIGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_BBNI_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       		 24:1 - 24:,
        RETEND_NT       		 25:1 - 25:,
        RETSEC_NF       		 26:1 - 26:,
        RTY_NF          		 27:1 - 27:,
        RETUW_NT        		 28:1 - 28:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF   ,
        RETUW_NT  
/INFILE ${DFILT}/${NJOB}_345_${IB}_SORT_EST_IRDPERICASE0_BBNI_RETRO_NP.dat 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_395
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAR  BBNI Contracts from PERICASE BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_DLDSIIGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       		 24:1 - 24:,
        RETEND_NT       		 25:1 - 25:,
        RETSEC_NF       		 26:1 - 26:,
        RTY_NF          		 27:1 - 27:,
        RETUW_NT        		 28:1 - 28:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF   ,
        RETUW_NT  
/INFILE ${DFILT}/${NJOB}_345_${IB}_SORT_EST_IRDPERICASE0_BBNI_RETRO_PROP.dat 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_400
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAR  BBNI Contracts RETRO PROP from PERICASE ASSUMES BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_395_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP_BY_ASS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT  
/INFILE ${EST_IADPERICASE_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_402
#-----------------------------------------------------------------------------
LIBEL="Extract DLDSIIGTAR  BBNI Contracts RETRO PROP from PERICASE ASSUMES BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_395_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT  
/INFILE ${EST_IADPERICASE_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:GT_ALL_COLS
exit
EOF
SORT

##
NSTEP=${NJOB}_405
#-----------------------------------------------------------------------------
LIBEL="MERGE   BBNI RET PROP  and RET NP Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP_BY_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_390_${IB}_DLDSIIGTAR_BBNI_RETRO_NP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLDSIIGTAR_BBNI_RETRO_MERGE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	      CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

##[044]

NSTEP=${NJOB}_410
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '2Axxxxx2' en EBS BBNI' "
AWK_I="${DFILT}/${NJOB}_405_${IB}_DLDSIIGTAR_BBNI_RETRO_MERGE.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLDSIIGTAR_BBNI.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
   
	if (\$6 == "1A100012")  { \$6 = "1A10001G" ;print \$0;}   
	if (\$6 == "1A100022")  { \$6 = "1A10062G" ;print \$0;}   
	if (\$6 == "1A120062")  { \$6 = "1A14061G" ;print \$0;}   
	if (\$6 == "1A120012")  { \$6 = "1A12001G" ;print \$0;}   
	if (\$6 == "1A120052")  { \$6 = "1A12007G" ;print \$0;}   
	if (\$6 == "1A120072")  { \$6 = "1A12007G" ;print \$0;}   
	if (\$6 == "1A461112")  { \$6 = "1A46060G" ;print \$0;}   
	if (\$6 == "1A494302")  { \$6 = "1A49461G" ;print \$0;}   
	if (\$6 == "1A200712")  { \$6 = "1A49462G" ;print \$0;}   
	if (\$6 == "1A416012")  { \$6 = "1A41101G" ;print \$0;}   
	if (\$6 == "1A121212")  { \$6 = "1A12161G" ;print \$0;} 
	
	
  if (\$6 == "2A100012")  { \$6 = "2A10001G" ;print \$0;}  
  if (\$6 == "2A100022")  { \$6 = "2A10062G" ;print \$0;}  
  if (\$6 == "2A120062")  { \$6 = "2A14061G" ;print \$0;}  
  if (\$6 == "2A120012")  { \$6 = "2A12001G" ;print \$0;}  
  if (\$6 == "2A120052")  { \$6 = "2A12007G" ;print \$0;}  
  if (\$6 == "2A120072")  { \$6 = "2A12007G" ;print \$0;}  
  if (\$6 == "2A494302")  { \$6 = "2A49461G" ;print \$0;}  
  if (\$6 == "2A200712")  { \$6 = "2A49462G" ;print \$0;}  
  if (\$6 == "2A416012")  { \$6 = "2A41101G" ;print \$0;}  
  if (\$6 == "2A121212")  { \$6 = "2A12161G" ;print \$0;}  
	
	  


##if (\$6 == "2A416012") { \$6 = "2A41101G";print \$0;}  
##if (\$6 == "2A416032") { \$6 = "2A41103G";print \$0;} 



fi
  }
exit
EOF
AWK

##[043] Fix INT

NSTEP=${NJOB}_415
#-----------------------------------------------------------------------------
LIBEL="MERGE   BBNI RET and OTHERS Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_410_${IB}_AWK_DLDSIIGTAR_BBNI.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_385_${IB}_DLDSIIGTAR_OTHERS.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_402_${IB}_DLDSIIGTAR_BBNI_RETRO_PROP_OTHERS.dat 2000 1"
SORT_O="${EST_DLDSIIGTAR}  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	      CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

ECHO_LOG "#===> TRANSCODIFICATION des CONTRATS BBNI .............: ${EST_DLDSIIGTR} "





###

#[45]
NSTEP=${NJOB}_420
#-----------------------------------------------------------------------------
LIBEL="Creation fichier DLDSIIGTR TRANSCODIFIE a partir du DLDSIIGTAR TRANSCODIFIE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDSIIGTAR}  2000 1"
SORT_O="${EST_DLDSIIGTR} OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT1            1:1 -  7:,
        TRNCOD_CF         6:1 -  6:,
        AMT_M            19:1 - 19:EN 18/3,
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
        RETAMT_M         35:1 - 35:EN 18/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 18/3,
        FIN1             42:1 - 56:,
        FIN2             58:1 - 71:
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD AMT_MC "0.000~"
/DERIVEDFIELD RETINTAMT_MC "0.000~"
/DERIVEDFIELD VIDES11 11"~"
/DERIVEDFIELD VIDES04  4"~"
/DERIVEDFIELD ORICOD_LS2  "EBSGTA~"
/KEYS RETCTR_NF,
      RETEND_NT,
      RETCUR_CF,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      TRNCOD_CF
/OUTFILE ${SORT_O}
/REFORMAT DEBUT1,
          VIDES11,
          AMT_MC,
          VIDES04,
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
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FIN1,
          ORICOD_LS2,
          FIN2
exit
EOF
SORT


fi




NSTEP=${NJOB}_600
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND


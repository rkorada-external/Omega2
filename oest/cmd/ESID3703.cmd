#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESID3703.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:23802 Calcul des Cashflow et valeur escompte
#
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[02] 27/07/2012 :spot:23937 -=Dch=-   Ajout de touch pour cr�ation des fichiers vides en d�but de job, puis v�rification en sortie de ESTC1056 : si fichier vide : fin du job
#[03] 02/08/2012 :spot:24041 -=Dch=-   Remplacement de MPPINC par MNAUTO dans la jointure ( segment)
#[04] 28/08/2012 :spot:24041 -=JFVDV=- Am�nagements (comment out / undo comment out)
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
#[13] 21/10/2013 :spot:26391 Cyrille   Application du pattern ICR (Incurred Incremental) pour les IBNR. Doit etre identique � l'application du pattern CSF (cash flow) pour les Paid and Premium Cumulatives
#[14] 17/02/2015 :spot:26391 Cyrille   Ajout du retrocessionaire a la cle dur fichier RMNTP
#[15] 01/06/2015 :spot:26391 Roger     On ne prend pas les postes 2A4261.. dont le montant r�tro est positif
#[16] 02/06/2015 :spot:26391 Roger     Correction sur fichier en entr�e.
#[17] 25/06/2015 :spot:28941 PP/Roger  Diverses corrections pour EST49A2 EBS ULAE et Risk Management - refonte du shell
#[18] 03/09/2015 :spot:28941 Philippe  ajout code �tablissement dans les echanges internes SII
#[19] 02/11/2015 :spot:29615 P PEZOUT
#[20] 03/06/2016 :spot:30543 Florent   on passe � 65 ann�es et ce fichier devient la r�f�rences pour les PAATERNSII !
#[21] 18/11/2016 :spira:57799 Florent  Mise au format � 71 colonnes pour les fichiers EST_DLDSIIGT*
#[22] 13/11/2017 :spira:64660 Roger    gestion du RTO et PLC dans le fichier R�tro EST_DLDSIIGTR et EST_DLDSIIGTAR
#[23] 31/10/2018 :spira:71038 Rafael   Changement du ACMTRS 312 par 307
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3

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
    # en sortie du ESID3703
    EST_FTECLEDSII=${EPO_FTECLEDSIISO}
    EST_DLDSIIGTAA=${EPO_DLDSIIGTAASO}
    EST_DLDSIIGTAR=${EPO_DLDSIIGTARSO}
    EST_DLDSIIGTR=${EPO_DLDSIIGTRSO}
    TYPEPO=SO
  else
    # en sortie du ESID3703
    EST_FTECLEDSII=${EPO_FTECLEDSIICO}
    EST_DLDSIIGTAA=${EPO_DLDSIIGTAACO}
    EST_DLDSIIGTAR=${EPO_DLDSIIGTARCO}
    EST_DLDSIIGTR=${EPO_DLDSIIGTRCO}
    TYPEPO=CO
  fi
  EST_DLEIFTECLEDSIIEI=${EPO_DLEIFTECLEDSIIEI}
  EST_DLEIFTECLEDSIIEP=${EPO_DLEIFTECLEDSIIEP}
  EST_FSEGPATTERN_CSF=${EPO_FSEGPATTERN_CSF}
  EST_FSEGPATTERN_ICR=${EPO_FSEGPATTERN_ICR}
  EST_FSEGPATTERN_DSC=${EPO_FSEGPATTERN_DSC}
  EST_FSEGPATTERN_BDT=${EPO_FSEGPATTERN_BDT}
  EST_FSEGPATTERN_INF=${EPO_FSEGPATTERN_INF}
  EST_FCURSII=${EPO_FCURSII}
  EST_FRATINGRTO=${EPO_FRATINGRTO}
  EST_IADPERICASE=${EPO_IADPERICASE}
  EST_FTRSLNK=${EPO_FTRSLNK}
  EST_FPLATXCUMALL=${EPO_FPLATXCUMALL}
  EST_DLCUMGTAAR=${EPO_DLCUMGTAAR}
  EST_DLCUMGTAAR_IBNR_FUTCLAIMS=${EPO_DLCUMGTAAR_IBNR_FUTCLAIMS}  #[017]
  EST_FPLC=${EPO_FPLC}
  EST_FSSDACTR=${EPO_FSSDACTR}
  EST_FDETTRS=${EPO_FDETTRS}
  EST_FCURQUOT=${EPO_FCURQUOT}
  EST_DLEIFTECLEDSII=${EPO_DLEIFTECLEDSII}
  EST_GTSII_ESCOMPTE_CLM=${EPO_GTSII_ESCOMPTE_CLM}
fi

if [ "${EST_ESPD2000_COND3}" = "Y" ]
then
  export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CRE_D..........................: ${CRE_D}"
ECHO_LOG "#===> TYPEINV........................: ${TYPEINV}"
ECHO_LOG "#===> TYPEPO.........................: ${TYPEPO}"
ECHO_LOG "#===> TRIM_NF........................: ${TRIM_NF}"
ECHO_LOG "#===> TYPETRT_CT.....................: ${TYPETRT_CT}"
ECHO_LOG "#===> ICLODAT_D......................: ${ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_A......................: ${ICLODAT_A}"
ECHO_LOG "#===> ICLODAT_M......................: ${ICLODAT_M}"
ECHO_LOG "#===> ICLODAT_J......................: ${ICLODAT_J}"
ECHO_LOG "#===> CLOPRD.........................: ${CLOPRD}"
ECHO_LOG "#===> EST_FSEGPATTERN_CSF............: ${EST_FSEGPATTERN_CSF}"
ECHO_LOG "#===> EST_FSEGPATTERN_ICR............: ${EST_FSEGPATTERN_ICR}"
ECHO_LOG "#===> EST_FSEGPATTERN_BDT............: ${EST_FSEGPATTERN_BDT}"
ECHO_LOG "#===> EST_FSEGPATTERN_DSC............: ${EST_FSEGPATTERN_DSC}"
ECHO_LOG "#===> EST_FSEGPATTERN_INF............: ${EST_FSEGPATTERN_INF}"
ECHO_LOG "#===> EST_CURGTA.....................: ${EST_CURGTA}"
ECHO_LOG "#===> EST_DLCUMGTAAR.................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> EST_DLDSIIGTAA.................: ${EST_DLDSIIGTAA}"
ECHO_LOG "#===> EST_DLDSIIGTAR.................: ${EST_DLDSIIGTAR}"
ECHO_LOG "#===> EST_DLDSIIGTR..................: ${EST_DLDSIIGTR}"
ECHO_LOG "#===> EST_DLEIFTECLEDSII.............: ${EST_DLEIFTECLEDSII}"
ECHO_LOG "#===> EST_DLEIFTECLEDSIIEI...........: ${EST_DLEIFTECLEDSIIEI}"
ECHO_LOG "#===> EST_DLEIFTECLEDSIIEP...........: ${EST_DLEIFTECLEDSIIEP}"
ECHO_LOG "#===> EST_FCURSII....................: ${EST_FCURSII}"
ECHO_LOG "#===> EST_FDETTRS....................: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FPLATXCUMALL...............: ${EST_FPLATXCUMALL}"
ECHO_LOG "#===> EST_FPLC.......................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FRATINGRTO.................: ${EST_FRATINGRTO}"
ECHO_LOG "#===> EST_FSSDACTR...................: ${EST_FSSDACTR}"
ECHO_LOG "#===> EST_FTECLEDSII.................: ${EST_FTECLEDSII}"
ECHO_LOG "#===> EST_FTRSLNK....................: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_IADPERICASE................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_GTSII_ESCOMPTE_CLM.........: ${EST_GTSII_ESCOMPTE_CLM}"
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS..: ${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
#Last version of ESID3700 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLEIFTECLEDSII}`/${PCH}ES*D3700_DLEIFTECLEDSIIEI.dat"

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

if [ -s ${EST_FSEGPATTERN_CSF} ]
then

  PATTERN_CATEGORY="CSF  "

  NSTEP=${NJOB}_50
  #-----------------------------------------------------------------------------
  LIBEL="CSF CALCULATION Calcul du CashFlow (Receivables Undiscount EBS & Claim Undiscounted reserves EBS)"
  PRG=ESTC1056
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
TRIM_NF ${TRIM_NF}
PATTERN_CATEGORY ${PATTERN_CATEGORY}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  #[013]
  export ${PRG}_I1=${EST_DLCUMGTAAR}
  export ${PRG}_I2=${EST_FSEGPATTERN_CSF}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_CASHFLOW.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY_ULAE.dat
  EXECPRG
else

  NSTEP=${NJOB}_55
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="CSF CALCULATION touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_CASHFLOW.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_CASHFLOW.dat"
  EXECKSH "touch ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat"
fi

gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_CASHFLOW.dat         > ${DFILT}/${NJOB}_050_ESTC1056_GTSII_CASHFLOW.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat > ${DFILT}/${NJOB}_050_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat.gz

if [ -s ${EST_FSEGPATTERN_INF} ]
then
  NSTEP=${NJOB}_60
  #-----------------------------------------------------------------------------
  LIBEL="INFLATED RMNTP ULAE CALCULATION"

  PATTERN_CATEGORY="INF  "

  PRG=ESTC1071
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
PATTERN_CATEGORY ${PATTERN_CATEGORY}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat
  export ${PRG}_I2=${EST_FCURSII}
  export ${PRG}_I3=${EST_FSEGPATTERN_INF}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY_ULAEINF.dat
  EXECPRG
  #cd $DEXE
  #debugV2 $PRG
else
  NSTEP=${NJOB}_61
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="CSF CALCULATION touch ${DFILT}/${NJOB}_60_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat "
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_60_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat"
fi

gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat > ${DFILT}/${NJOB}_060_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat.gz

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ULAE "
ECHO_LOG "#===> Nombre de lignes ULAE UNDISC generees "
wc -l ${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat
ECHO_LOG "#===> Nombre de lignes ULAE INFLATED generees "
wc -l ${DFILT}/${NJOB}_60_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat
ECHO_LOG "#========================================================================="

#[011]
NSTEP=${NJOB}_70
#Concat ULAEINF and CSF
#-----------------------------------------------------------------------------
LIBEL="Concat ULAEINF and CSF - PREPARATION DISCOUNT CALCULATION"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_CASHFLOW.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_60_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSF.dat"
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
      TYP_CT
/CONDITION CSF_ULAE (ACMTRS_NT = "3114" OR ACMTRS_NT = "3115") AND PATCAT1_CT="CSF" AND PATTYP_CT="CLACC"
/OUTFILE ${SORT_O}
/OMIT CSF_ULAE
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_70_${IB}_SORT_GTSII_CSF.dat > ${DFILT}/${NJOB}_070_SORT_GTSII_CSF.dat.gz


if [ -s ${EST_FSEGPATTERN_DSC} ]
then
  NSTEP=${NJOB}_80
  #-----------------------------------------------------------------------------
  LIBEL="CSF CALCULATION Calcul du montant escompt� (Receivables Discount EBS + Claim Discount Reserves EBS)"
  PRG=ESTC1057
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_SORT_GTSII_CSF.dat
  export ${PRG}_I2=${EST_FSEGPATTERN_DSC}
  export ${PRG}_I3=${EST_FCURSII}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ESCOMPTE.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_PIVOT.dat
  export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_NOTUSED.dat
  EXECPRG
else
  NSTEP=${NJOB}_90
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="CSF CALCULATION touch ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_ESCOMPTE.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_ESCOMPTE.dat"
  EXECKSH "touch ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_REMAINTOPAY.dat"
  EXECKSH "touch ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_PIVOT.dat"
fi

gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_ESCOMPTE.dat    > ${DFILT}/${NJOB}_080_ESTC1057_GTSII_ESCOMPTE.dat.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_REMAINTOPAY.dat > ${DFILT}/${NJOB}_080_ESTC1057_GTSII_REMAINTOPAY.dat.gz


NSTEP=${NJOB}_100
#[23]
#-----------------------------------------------------------------------------
LIBEL="CSF CALCULATION Somme des montants du fichier GTSII_ESCOMPTE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_ESCOMPTE.dat 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ESCOMPTE.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_GTSII_ESCOMPTE_CLM.dat
#SORT_O2="${EST_GTSII_ESCOMPTE_CLM} OVERWRITE"
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
        TOTAUX_M        123:1 - 123:EN 15/3
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/CONDITION COND_FUTURECLAIMS TYP_CT = "A" AND (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "309" OR ACMTRS_NT = "307" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" )
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
      PLC_NT ,
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF
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
/OUTFILE  ${SORT_O2}
/INCLUDE COND_FUTURECLAIMS
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
exit
EOF
SORT

NSTEP=${NJOB}_120
#[014] Ajout du retrocessionaire a la cle dur fichier RMNTP
#[23] Changement du ACMTRS 312 par 307
#-----------------------------------------------------------------------------
LIBEL="CSF CALCULATION Somme des montants du fichier GTSII_REMAINTOPAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1057_GTSII_REMAINTOPAY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_REMAINTOPAY.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
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
        TOTAUX_M        123:1 - 123:EN 15/3
/SUMMARIZE TOTAL AM01_M, TOTAL AM02_M, TOTAL AM03_M, TOTAL AM04_M, TOTAL AM05_M, TOTAL AM06_M, TOTAL AM07_M, TOTAL AM08_M, TOTAL AM09_M, TOTAL AM10_M,
           TOTAL AM11_M, TOTAL AM12_M, TOTAL AM13_M, TOTAL AM14_M, TOTAL AM15_M, TOTAL AM16_M, TOTAL AM17_M, TOTAL AM18_M, TOTAL AM19_M, TOTAL AM20_M,
           TOTAL AM21_M, TOTAL AM22_M, TOTAL AM23_M, TOTAL AM24_M, TOTAL AM25_M, TOTAL AM26_M, TOTAL AM27_M, TOTAL AM28_M, TOTAL AM29_M, TOTAL AM30_M,
           TOTAL AM31_M, TOTAL AM32_M, TOTAL AM33_M, TOTAL AM34_M, TOTAL AM35_M, TOTAL AM36_M, TOTAL AM37_M, TOTAL AM38_M, TOTAL AM39_M, TOTAL AM40_M,
           TOTAL AM41_M, TOTAL AM42_M, TOTAL AM43_M, TOTAL AM44_M, TOTAL AM45_M, TOTAL AM46_M, TOTAL AM47_M, TOTAL AM48_M, TOTAL AM49_M, TOTAL AM50_M,
           TOTAL AM51_M, TOTAL AM52_M, TOTAL AM53_M, TOTAL AM54_M, TOTAL AM55_M, TOTAL AM56_M, TOTAL AM57_M, TOTAL AM58_M, TOTAL AM59_M, TOTAL AM60_M,
           TOTAL AM61_M, TOTAL AM62_M, TOTAL AM63_M, TOTAL AM64_M, TOTAL AM65_M,
           TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M, TOTAL TOTAUX_M
/CONDITION COND_FUTURECLAIMS CTR1_NF != "" AND CTR1_NF != " " AND (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "309" OR ACMTRS_NT = "307" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" )
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
/DERIVEDFIELD TYPA_CT "A~"
/DERIVEDFIELD RETRO_VIDE 14"~"
/DERIVEDFIELD CHAIN1_VIDE 1"~"
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
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF,
      ACMCUR_CF,
      PLC_NT
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
exit
EOF
SORT

#NSTEP=${NJOB}_125
## Explanations on SUM and STABLE options choice :
## SUM will take only one record according the key
## STABLE will allow to take the first input record from the records having the same key.
##---------------------------------------------------------------------------
#LIBEL="Summarizing file"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I=${EST_FPLATXCUMALL}
#SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL.dat
#INPUT_TEXT $SORT_CMD <<EOF
#/FIELDS RETCTR_NF 1:1 - 1:,
#        RETSEC_NF 2:1 - 2:EN,
#        RETRTY_NF 3:1 - 3:,
#        PLC_NT    4:1 - 4:EN
#/KEYS RETCTR_NF, RETSEC_NF, RETRTY_NF, PLC_NT
#/SUM
#/STABLE
#exit
#EOF
#SORT
#
#NSTEP=${NJOB}_130
## Affectation par placement
##-----------------------------------------------------------------------------
#LIBEL="CSF CALCULATION Affectation par placement"
#PRG=ESTC1052
#export ${PRG}_I1=${DFILT}/${NJOB}_125_${IB}_FPLATXCUMALL.dat
#export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_SORT_GTSII_REMAINTOPAY.dat
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY.dat
#EXECPRG
#
if [ -s ${EST_FSEGPATTERN_BDT} ]
then
  NSTEP=${NJOB}_150
  # Begin C program
  #-----------------------------------------------------------------------------
  LIBEL="Calcul des badDebt"
  PRG=ESTC1058
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_HOST_PRDSIT=${HOST_PRDSIT}
  #export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_ESTC1052_GTSII_REMAINTOPAY.dat
  export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_GTSII_REMAINTOPAY.dat
  export ${PRG}_I2=${EST_FSEGPATTERN_BDT}
  export ${PRG}_I3=${EST_FRATINGRTO}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_BADDEBT.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_PIVOT.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_NO_SYNC.dat
  EXECPRG
else
  NSTEP=${NJOB}_160
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="touch ${DFILT}/${NJOB}_150_${IB}_ESTC1058_GTSII_BADDEBT.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_150_${IB}_ESTC1058_GTSII_BADDEBT.dat"
  EXECKSH "touch ${DFILT}/${NJOB}_150_${IB}_ESTC1058_GTSII_PIVOT.dat"
fi

gzip -c ${DFILT}/${NJOB}_120_${IB}_SORT_GTSII_REMAINTOPAY.dat     > ${DFILT}/${NJOB}_120_SORT_GTSII_REMAINTOPAY.dat.gz
#gzip -c ${DFILT}/${NJOB}_130_${IB}_ESTC1052_GTSII_REMAINTOPAY.dat > ${DFILT}/${NJOB}_130_ESTC1052_GTSII_REMAINTOPAY.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_ESTC1058_GTSII_BADDEBT.dat     > ${DFILT}/${NJOB}_150_ESTC1058_GTSII_BADDEBT.dat.gz

#[013] Apply ICR (incurred incremental) pattern to IBNR and future claims
if [ -s ${EST_FSEGPATTERN_ICR} ]
then
  NSTEP=${NJOB}_180
  #-----------------------------------------------------------------------------
  LIBEL="ICR CALCULATION : ICR pattern applied to IBRN and future claims"

  # Type of pattern to apply to GT data (5 digits)
  PATTERN_CATEGORY="ICR  "

  PRG=ESTC1056
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
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_ICR.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGPATTERN_ICR_NOTUSED.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTSII_REMAINTOPAY_ULAEICR.dat
  EXECPRG
else
  NSTEP=${NJOB}_181
  # Create an empty file for later use
  #------------------------------------------------------------------------------
  LIBEL="ICR CALCULATION touch ${DFILT}/${NJOB}_180_${IB}_ESTC1056_GTSII_ICR.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_180_${IB}_ESTC1056_GTSII_ICR.dat"
fi

gzip -c ${DFILT}/${NJOB}_180_${IB}_ESTC1056_GTSII_ICR.dat > ${DFILT}/${NJOB}_180_ESTC1056_GTSII_ICR.dat.gz
# fin [011]

NSTEP=${NJOB}_200
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_CASHFLOW.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_SORT_GTSII_ESCOMPTE.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_120_${IB}_SORT_GTSII_REMAINTOPAY.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_150_${IB}_ESTC1058_GTSII_BADDEBT.dat 2000 1"
SORT_I5="${DFILT}/${NJOB}_180_${IB}_ESTC1056_GTSII_ICR.dat 2000 1"  #[014] ajout du fichier ICR : Incurred Incremental pattern
SORT_I6="${DFILT}/${NJOB}_50_${IB}_ESTC1056_GTSII_REMAINTOPAY_ULAE.dat 2000 1"
SORT_I7="${DFILT}/${NJOB}_60_${IB}_ESTC1071_GTSII_REMAINTOPAY_ULAEINF.dat 2000 1"
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
        PATTERN_ID
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
        TIFI_M          124:1 - 124:EN 15/3
/CONDITION ACCEP_GT  TYP_CT  = "A"  AND ((PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR") OR PATTYP1_CT="INF")
/CONDITION RETRO_GT  TYP_CT != "A"  AND PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR" AND PATTYP_CT != "RMNTP"
/CONDITION ACCEP_SII TYP_CT  = "A"  AND ((PATCAT1_CT  = "CSF" OR PATCAT1_CT  = "ICR") AND PATTYP1_CT!="INF" )
/CONDITION RETRO_SII TYP_CT != "A"
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
      ACMTRS_NT,
      PATCAT_CT,
      PATTYP_CT,
      NORME_CF,
      RATING_CF
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

gzip -c ${DFILT}/${NJOB}_200_${IB}_SORT_GTSII_CUMUL1.dat > ${DFILT}/${NJOB}_200_SORT_GTSII_CUMUL1.dat.gz
gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSFAR.dat > ${DFILT}/${NJOB}_260_SORT_DLDSIICSFAR.dat.gz

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
        TOTAUX_M        123:1 - 123:EN 15/3
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
        ESB_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_262_${IB}_SORT_DLDSIIGTAR.dat > ${DFILT}/${NJOB}_262_SORT_DLEIFTECLEDSII.dat.gz

NSTEP=${NJOB}_265
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL for retrocessionaire subsidiaries..."
PRG=ESTC2315
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

gzip -c ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLEIFTECLEDSII.dat    > ${DFILT}/${NJOB}_265_ESTC2315_DLEIFTECLEDSII.dat.gz
gzip -c ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR.dat        > ${DFILT}/${NJOB}_265_ESTC2315_DLDSIIGTAR.dat.gz

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC2315 "
ECHO_LOG "#===> Nombre de lignes AI generees "
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLEIFTECLEDSII.dat
ECHO_LOG "#===> Nombre de lignes RI+R origine "
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR.dat
ECHO_LOG "#===> Nombre de lignes RI origine "
grep ~RI ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR.dat > ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR_RI.dat
wc -l ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR_RI.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_266
#[018] correction sur le code �tablissement
#-----------------------------------------------------------------------------
LIBEL="SORT OF ESTC2315_DLEIFTECLEDSII.dat echanges internes generes 'AI' "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLEIFTECLEDSII.dat 2000 1"
SORT_I2="${EST_DLEIFTECLEDSIIEP} 2000 1"
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
        FILLER5         124:1 - 128:
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
        SEG_NF
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
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_266_${IB}_SORT_DLEIFTECLEDSII.dat    > ${DFILT}/${NJOB}_266_SORT_DLEIFTECLEDSII.dat.gz

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
PRG=ESTM7604
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
wc -l ${DFILT}/${NJOB}_268_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat

gzip -c ${DFILT}/${NJOB}_268_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat    > ${DFILT}/${NJOB}_268_ESTM7604_DLEIFTECLEDSII.dat.gz

NSTEP=${NJOB}_269
#[23] Changement du ACMTRS 312 par 307
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSF                 : les lignes CSF et RMNTP
# ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat            : les lignes accept hors CSF et hors RMNTP
# ${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR.dat        : les lignes retro hors CSF et hors RMNTP, top�es R ou RI pour celles ayant particip� aux echanges internes
# ${DFILT}/${NJOB}_268_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat : les lignes accept issues de la retro interne
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSFAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_265_${IB}_ESTC2315_DLDSIIGTAR.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_268_${IB}_ESTM7604_DLEIFTECLEDSII_O1.dat 2000 1"
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
        TIFI_M          124:1 - 124:EN 15/3
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
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      ACMTRS_NT,
      ACMCUR_CF,
      PRS_CF,
      PATCAT_CT,
      PATTYP_CT,
      TYP_CT,
      NORME_CF,
      RATING_CF,
      PATTERN_ID,
      SSD_CF,
      ESB_CF
/CONDITION pattern PATTERN_ID = ""
/CONDITION pattyp  PATTYP_CT = ""
/CONDITION patcat  PATCAT_CT = ""
/CONDITION lobNONVIE  (LOB_CF != "" AND LOB_CF != "30" AND LOB_CF != "31")
/CONDITION lobacc  TYP1_CT = "A"
/CONDITION ACCEP_GT  TYP1_CT  = "A"  AND ((PATCAT1_CT != "CSF" AND PATCAT1_CT != "ICR") OR PATTYP1_CT="INF")
/CONDITION COND_FUTURECLAIMS PATCAT1_CT ="DSC" AND CTR1_NF != "" AND CTR1_NF != " " AND
                             (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "309" OR ACMTRS_NT = "307" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" )
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER     "CloP~"
/DERIVEDFIELD PATTERN2_ID if pattern then "EMPTY" else PATTERN_ID
/DERIVEDFIELD PATTYP2 if  pattyp then "ER" else PATTYP_CT
/DERIVEDFIELD PATCAT2 if  patcat then "ER" else PATCAT_CT
/DERIVEDFIELD LOBACC_NEW if  lobacc then LOB_CF else ""
/DERIVEDFIELD LOBRET_NEW if  lobacc then "" else LOB_CF
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
 ,ACMCUR_CF
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
  ,ACMCUR_CF
  ,PRS_CF
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
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_269_${IB}_SORT_DLDSIIGTAA.dat       > ${DFILT}/${NJOB}_269_SORT_DLDSIIGTAA.dat.gz


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
export ${PRG}_O1=${EST_FTECLEDSII}  # [006]
EXECPRG
gzip -c ${DFILT}/${NJOB}_269_${IB}_SORT_FTECLEDSII.dat  > ${DFILT}/${NJOB}_269_ESTC1075_FTECLEDSII.dat.gz

NSTEP=${NJOB}_270
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1060
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

gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIICSFAA.dat      > ${DFILT}/${NJOB}_260_SORT_DLDSIICSFAA.dat.gz
gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat       > ${DFILT}/${NJOB}_260_SORT_DLDSIIGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_270_${IB}_ESTC1060_DLDSIIGTAA.dat   > ${DFILT}/${NJOB}_270_ESTC1060_DLDSIIGTAA.dat.gz

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1060 "
ECHO_LOG "#===> Nombre de lignes a generer "
wc -l ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAA.dat
ECHO_LOG "#===> Nombre de lignes GT generees "
wc -l ${DFILT}/${NJOB}_270_${IB}_ESTC1060_DLDSIIGTAA.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_280
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAA tri du fichier genere par contrat accept et contrat retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC1060_DLDSIIGTAA.dat 2000 1"
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

gzip -c ${DFILT}/${NJOB}_280_${IB}_SORT_DLDSIIGTAA_NULL.dat       > ${DFILT}/${NJOB}_280_SORT_DLDSIIGTAA_NULL.dat.gz

NSTEP=${NJOB}_290
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAA Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_280_${IB}_SORT_DLDSIIGTAA.dat # [006]
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLDSIIGTAA}
EXECPRG

NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAR Generation des lignes GT supplementaires pour Retro ventile par accept GTAR"
PRG=ESTC1060
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

gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLDSIIGTAR.dat       > ${DFILT}/${NJOB}_260_SORT_DLDSIIGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_300_${IB}_ESTC1060_DLDSIIGTAR.dat   > ${DFILT}/${NJOB}_300_ESTC1060_DLDSIIGTAR.dat.gz

#[22]
NSTEP=${NJOB}_310
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="DLDSIIGTAR tri du fichier "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC1060_DLDSIIGTAR.dat 2000 1"
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

gzip -c ${DFILT}/${NJOB}_310_${IB}_SORT_DLDGTAR.dat       > ${DFILT}/${NJOB}_310_SORT_DLDGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_310_${IB}_SORT_DLDGTAR_NULL.dat  > ${DFILT}/${NJOB}_310_SORT_DLDGTAR_NULL.dat.gz

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

gzip -c ${DFILT}/${NJOB}_315_${IB}_SORT_DLDGTAR.dat         > ${DFILT}/${NJOB}_315_SORT_DLDGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_315_${IB}_SORT_DLDGTAR_POSITIF.dat > ${DFILT}/${NJOB}_315_SORT_DLDGTAR_POSITIF.dat.gz

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

NSTEP=${NJOB}_350
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

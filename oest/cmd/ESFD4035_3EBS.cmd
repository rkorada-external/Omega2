#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4035.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04/01/2021
# auteur                        : Nhat Linh DOAN
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 83101  :  - conversion transcode from others GAAP
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 04/01/2021 NLD : SPIRA 83101 :  conversion transcode from others GAAP
#[002] 17/03/2021 NLD : SPIRA 83101 :  activate conversion I17 to I17
#[003] 26/03/2021 NLD : SPIRA 83101 :  fix new ICLODAT
#[004] 10/05/2021 NLD : SPIRA 83101 :  integrate EBS
#[005] 17/05/2021 NLD : SPIRA 96351 :  REQ20.1 - Exclude Life contracts
#[006] 29/06/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times.
#[007] 06/09/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times, update CRE_D and LSTUPD_D 
#[008] 26/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  : (for grouping 751=1010 ; 2010) AND ((Prof = 3 and CSM =1) OR  (Prof = 1 and LC =1))
#[009] 31/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout des colonnes  SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF dans la cle de jointure
#[010] 11/02/2022  HR : SPIRA 100977 : I17 - Criteria to compute Revenue / EXP / CSM
#[011] 21/02/2022 MZM : SPIRA 102371:  I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases) : Annulation  ; Modif effectuee dans ESFD4037
#[012] 12/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115 (Ajout Cartouche)
#[013] 13/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout SCORTH  dans la cle de jointure au step _19A
#[014] 31/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Inversion des colonnes LC et CSM
#[015] 09/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Condition sur RETRO NP (Exclure sur les enreg Accept et Retro Prop) ; Exclure Regle Profitabilite
#[016] 21/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP :Fix sur Anomalie Dans LOG au step _19D
#[017] 28/06/2022 MZM : SPIRA 105131:  REQ20.1 - no calculation  Fix sur les doublons apres Step _19A : Ajout Step _19O
#[018] 10/11/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1 GENERER FTECLEDR A PARTIR DU FTECLEDA
#[019] 10/11/2022 MZM : SPIRA 107687:  REQ20.1 - TECHNICAL CHANGE : 2010,2013,2019,1016,1017
#[020] 06/12/2022 MZM : SPIRA 107133:  REQ20.1 -Spira 107133 TRN_NT  EMPTY AND TRANSFORMATION Stored In column 57 ==> RECLASSP
#[021] 30/01/2023 MZM : SPIRA 108631:  REQ 20.1 - Change Input file to avoid double offset - Copy : Prise en compte des Annulations PRS_740
#[022] 03/04/2023 MZM : SPIRA 109394   Criteria to compute I4 to I17 transformation not properly applied
#[023] 07/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17
#[024] 11/04/2023 MZM : SPIRA 108942   20.1 - Delta Posting - strange delta
#[025] 14/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17 : Grouping "1016" et "1017" Pour Tout
#[026] 22/05/2023 MZM : SPIRA 109559   20.1 - I17 - IFRS4 cancel calculated on retro NP with Q-1 CSM pattern at 1 : Modif du Step _19O pour filtre que Ass et Retro Prop
#[027] 04/07/2023 MZM : SPIRA 110070   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping POUR EBS : "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" et des conditions  [abs(CSM ending) + abs(LC ending)] 
#[028] 18/07/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] 
#[029] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  Fix sur Doublons CSM / LC AMORT
#[030] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  Fix sur Doublons CSM / LC AMORT (Fix ITK _19A)
#[031] 11/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
#[032] 09/07/2023 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220" 
#[033] 16/01/2023 MZM : SPIRA 110217   20.1 - I17 -REQ 20.1 - 17 - Add the LC reclass to the IO auto generation : Prise en compte des Grouping  que pour les AI
#[034] 29/01/2024 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220"
#[035] 29/01/2023 MZM : SPIRA 111191   20.1 - I17 - Add the LC reclass to the IO auto generation - Revert 
#===============================================================================


# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename ${ESF_FTECLEDR_OUT%.*}`
ICLODAT_M0=$(($ICLODAT_MTH - 2))



NSTEP=${NJOB}_45
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${EPO_FTECLEDR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_M0}) or ( BALSHRMTH_NF > ${ICLODAT_MTH} ) or (BALSHEY_NF != ${ICLODAT_YEA} )

/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT	  



# [020] TRN_NT_NEW AND TRANSFORMATION Stored In column  /DERIVEDFIELD ORICOD_NEW   "RECLASSP~"

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EPO_FTECLEDR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        S_DETTRS_CF        6:1 - 6:,
        S_HEAD             1:1 - 2:,
	S_MID1             8:1 - 40:,
	S_MID2              45:1 - 55:,
	S_TRN_NT            56:1 - 56:,	
 				ORIDETTRS_CF       3:1 - 3:,
        TARGDETTRS_CF      6:1 - 6:,
        MAPTYP_CT          7:1 - 7: EN,
 	S_TAIL1            58:1 - 63:,
        S_TAIL2            66:1 - 71:
/DERIVEDFIELD GAAPCOD_NEW 2"~"
/DERIVEDFIELD SEPARATEUR   "~"
/DERIVEDFIELD ORICOD_NEW   "RECLASSP~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_YEA}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_MTH}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_DAY}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"
/DERIVEDFIELD TRN_NT_NEW "~"
/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_10_${IB}_GAAPMAP_EBS.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
	leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, TRN_NT_NEW, ORICOD_NEW, leftside : S_TAIL1,GAAPCOD_NEW,leftside : S_TAIL2,  rightside : MAPTYP_CT

exit
EOF
SORT




NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_50_${IB}_${EST_BASE}_EBS.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if (\$72 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if (\$72 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${ESF_FTECLEDR_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_${EST_BASE}_EBS_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         6:1 - 6:,
        ALL               1:1 - 71:
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF

/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT ALL
exit
EOF
SORT

ECHO_LOG "#===> ESF_FTECLEDA_40_IFRS4 ................: ${ESF_FTECLEDA_40_IFRS4}"
ECHO_LOG "#===> TEST_DATA ....: ${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_IFRS4.dat"


NSTEP=${NJOB}_70A
#------------------------------------------------------------------------------------
LIBEL="Generate FTECLEDR FROM STEP _70 OF FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_70_EBS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        SSD_CF            1:1 -   1:,
        ESB_CF            2:1 -   2:,
        BALSHEY_NF        3:1 -   3:,
        BALSHRMTH_NF      4:1 -   4:,
        CHAMPS_1A7        1:1 -   7:,
        TRNCOD_CF         6:1 -   6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -   7:,
        CTR_NF            8:1 -   8:,
        END_NT            9:1 -   9:,
        SEC_NF           10:1 -  10:,
        UWY_NF           11:1 -  11:,
        UW_NT            12:1 -  12:,
        OCCYEA_NF        13:1 -  13:,
        ACY_NF           14:1 -  14:,
        SCOSTRMTH_NF     15:1 -  15:,
        SCOENDMTH_NF     16:1 -  16:,
        CUR_CF           18:1 -  18:,
        AMT_M            19:1 -  19:EN 18/3,
        CED_NF           20:1 -  20:,
        RETCTR_NF        24:1 -  24:,
        RETEND_NT        25:1 -  25:,
        RETSEC_NF        26:1 -  26:,
        RTY_NF           27:1 -  27:,
        RETUW_NT         28:1 -  28:,
        RETOCCYEA_NF     29:1 -  29:,
        RETACY_NF        30:1 -  30:,
        RETSCOSTRMTH_NF  31:1 -  31:,
        RETSCOENDMTH_NF  32:1 -  32:,
        RETCUR_CF        34:1 -  34:,
        RETAMT_M         35:1 -  35:EN 18/3,
        PLC_NT           36:1 -  36:,
        RTO_NF           37:1 -  37:,
  CHAMPS_1A40       1:1 -  40:,
  CHAMPS_41A41     41:1 -  41:,
  CHAMPS_42A44     42:1 -  44:,
  LOBRET_CF        46:1 -  46:,
  SOBRET_CF        48:1 -  48:,
  TOPRET_CF        50:1 -  50:,
  NATRET_CF        52:1 -  52:,
  GARRET_CF        54:1 -  54:,
  PCPRSKTRYRET_CF  56:1 -  56:,
  USRCRTCODRET_CT  58:1 -  58:,
  USRCRTVALRET_LM  60:1 -  60:,
  RETCTRCAT_CF     62:1 -  62:,
  RETACCTYP_CT     67:1 -  67:,
  CHAMPS_42A55     42:1 -  55:,
  CHAMPS_56A56     56:1 -  56:,
  CHAMPS_57A57     57:1 -  57:,
  CHAMPS_58A58     58:1 -  58:,
  CHAMPS_59A59     59:1 -  59:,
  CHAMPS_60A64     60:1 -  64:,
  CHAMPS_65A65     65:1 -  65:,
  CHAMPS_66A71     66:1 -  71:,
        RETINTAMT_M      88:1 -  88:EN 18/3,
        CHAMPS_89A113    89:1 -  113:,
        ZZRECONKEY_CF   102:1 - 102:,
        TRN_NT          103:1 - 103:,
        ORICOD_LS       104:1 - 104:,
        RETROAUTO_B     105:1 - 105:,
        SPEENTNAT_CT    106:1 - 106:,
        EVT_NF          107:1 - 107:,
        REVT_NF         108:1 - 108:,
        RETARDRETINT_B  109:1 - 109:,
        NEWCOLS1_NF     110:1 - 110:,
        GAAPCOD_NT      111:1 - 111:,
        I17PRDCOD_CT    112:1 - 112:,
        GT_ANNUL_OPNG   114:1 - 114:,
        CHAMPS_115A118  115:1 - 118:
/KEYS   SSD_CF,
        ESB_CF,
        TRNCOD_CF
/CONDITION RETRO_ONLY (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4")
/DERIVEDFIELD CHAMPS_VIDE "~"
/INCLUDE RETRO_ONLY
/OUTFILE ${SORT_O}
/REFORMAT
      CHAMPS_1A40,
      CHAMPS_41A41,
      CHAMPS_42A44,
      LOBRET_CF,
      SOBRET_CF,
      TOPRET_CF,
      NATRET_CF,
      GARRET_CF,
      PCPRSKTRYRET_CF,
      USRCRTCODRET_CT,
      USRCRTVALRET_LM,
      RETCTRCAT_CF,
      RETACCTYP_CT,
      CHAMPS_VIDE,
      CHAMPS_VIDE,
                        ORICOD_LS,
                        RETROAUTO_B,
                        CHAMPS_VIDE,
                        EVT_NF,
                        REVT_NF,
                        RETARDRETINT_B,
                        NEWCOLS1_NF,
                        GAAPCOD_NT,
                        I17PRDCOD_CT,
                        CHAMPS_VIDE,
                        GT_ANNUL_OPNG,
                        CHAMPS_VIDE,
                        CHAMPS_VIDE,
                        CHAMPS_VIDE,
                        CHAMPS_VIDE
exit
EOF
SORT

## [032]

JOBEND

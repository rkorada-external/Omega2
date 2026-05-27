#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des discounts 
# nom du script SHELL           : ESPD3622.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2020
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#		DISCOUNT CALCULATION (extracted from old ESID3703.cmd) 
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[02] 27/07/2012 :spot:23937 -=Dch=-   Ajout de touch pour crâ..ation des fichiers vides en dâ..but de job, puis vâ..rification en sortie de ESTC1056 : si fichier vide : fin du job
#[03] 02/08/2012 :spot:24041 -=Dch=-   Remplacement de MPPINC par MNAUTO dans la jointure ( segment)
#[04] 28/08/2012 :spot:24041 -=JFVDV=- Amâ..nagements (comment out / undo comment out)
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
#[13] 21/10/2013 :spot:26391 Cyrille   Application du pattern ICR (Incurred Incremental) pour les IBNR. Doit etre identique â.. l'application du pattern CSF (cash flow) pour les Paid and Premium Cumulatives
#[14] 17/02/2015 :spot:26391 Cyrille   Ajout du retrocessionaire a la cle dur fichier RMNTP
#[15] 01/06/2015 :spot:26391 Roger     On ne prend pas les postes 2A4261.. dont le montant râ..tro est positif
#[16] 02/06/2015 :spot:26391 Roger     Correction sur fichier en entrâ..e.
#[17] 25/06/2015 :spot:28941 PP/Roger  Diverses corrections pour EST49A2 EBS ULAE et Risk Management - refonte du shell
#[18] 03/09/2015 :spot:28941 Philippe  ajout code â..tablissement dans les echanges internes SII
#[19] 02/11/2015 :spot:29615 P PEZOUT
#[20] 03/06/2016 :spot:30543 Florent   on passe â.. 65 annâ..es et ce fichier devient la râ..fâ..rences pour les PAATERNSII !
#[21] 18/11/2016 :spira:57799 Florent  Mise au format â.. 71 colonnes pour les fichiers EST_DLDSIIGT*
#[22] 13/11/2017 :spira:64660 Roger    gestion du RTO et PLC dans le fichier Râ..tro EST_DLDSIIGTR et EST_DLDSIIGTAR
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
#[036] 20/04/2020 M.NAJI :SPIRA 86220 optimisation ESPD3620, découpage ESID3703B en plusieurs jobs
#[037] 13/07/2020 R. Cassis :spira: 84474  Manque la colonne SEG_NF dans la cle de tri step269
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3

#[010]
CLOPRD=`echo ${ICLODAT_D} | awk '{print substr($0,1,6)}'`
TYPETRT_CT=GT_SII


# Job Initialisation
JOBINIT






NSTEP=${NJOB}_262
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3621A${TYPEINV}_260_${IB}_SORT_DLDSIICSFAR.dat 2000 1"
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


NSTEP=${NJOB}_263
#[036] enrichissemenet de DLDSIIGTAR avec PLA_SSDRTO_B  et PLA_RETOVRCOM_B
#-----------------------------------------------------------------------------
LIBEL=" enrichissemenet de DLDSIIGTAR avec PLA_SSDRTO_B  et PLA_RETOVRCOM_B"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_262_${IB}_SORT_DLDSIIGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAR_SSDRTO_RETOVRCOM.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		GT_RETCTR_NF        24:1 - 24:,
        GT_RETSEC_NF        26:1 - 26:,
        GT_RTY_NF           27:1 - 27:,
        GT_PLC_NT           36:1 - 36:,
		PLA_RETCTR_NF 	3:1  -	3:, 
		PLA_RETSEC_NF 	5:1  -	5:,
		PLA_RTY_NF 		6:1  -	6:,
		PLA_PLC_NT 		8:1  -	8:,
		PLA_SSDRTO_B 	15:1 -	15: ,
		PLA_RETOVRCOM_B 19:1 -	19:,
		GT_ALL_COLS 				1:1 - 124:

/joinkeys
		GT_RETCTR_NF        ,
		GT_RETSEC_NF        ,
		GT_RTY_NF           ,
		GT_PLC_NT           
/INFILE ${EST_FPLC}   2000 1 "~"
/joinkeys 
		PLA_RETCTR_NF 	, 
		PLA_RETSEC_NF 	,
		PLA_RTY_NF 		,
		PLA_PLC_NT 		
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside: GT_ALL_COLS   
	,rightside:PLA_SSDRTO_B  
	,rightside:PLA_RETOVRCOM_B 
exit
EOF
SORT

NSTEP=${NJOB}_264
#[018] enrichissemenet de DLDSIIGTAR avec, rightside:SSD_ACTR_SSD_CF,rightside:SSD_ACTR_CTR_NF,rightside ...
#-----------------------------------------------------------------------------
LIBEL="enrichissemenet de DLDSIIGTAR avec, rightside:SSD_ACTR_SSD_CF,rightside:SSD_ACTR_CTR_NF,rightside ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_263_${IB}_SORT_DLDSIIGTAR_SSDRTO_RETOVRCOM.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAR_SSDRTO_RETOVRCOM_SSDACTR.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		GT_RETCTR_NF        24:1 - 24:,
        GT_RETSEC_NF        26:1 - 26:,
        GT_RTY_NF           27:1 - 27:,
        GT_PLC_NT           36:1 - 36:,
		SSD_ACTR_RETCTR_NF	 1:1 -	1:,
		SSD_ACTR_RTY_NF      2:1 -	2:,
		SSD_ACTR_PLC_NT      3:1 -	3:,
		SSD_ACTR_RETSEC_NF   4:1 -	4:,
		SSD_ACTR_SSD_CF      5:1 -	5:,
		SSD_ACTR_CTR_NF      6:1 -	6:,
		SSD_ACTR_UWY_NF      7:1 -	7:,
		SSD_ACTR_UW_NT       8:1 -	8:,
		SSD_ACTR_SEC_NF      9:1 -	9:,
		SSD_ACTR_END_NT     10:1 - 10:,
		SSD_ACTR_CLISSD_NF  11:1 - 11:,
		SSD_ACTR_RTOSSD_CF	12:1 - 12:,
		GT_ALL_COLS 	     1:1 - 126:
/joinkeys
		GT_RETCTR_NF        ,
		GT_RETSEC_NF        ,
		GT_RTY_NF           ,
		GT_PLC_NT           
/INFILE ${EST_FSSDACTR_TXT}   2000 1 "~"
/joinkeys 
		SSD_ACTR_RETCTR_NF 	, 
		SSD_ACTR_RETSEC_NF 	,
		SSD_ACTR_RTY_NF 		,
		SSD_ACTR_PLC_NT 		
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} 
/REFORMAT 
	 leftside: GT_ALL_COLS   
	,rightside:SSD_ACTR_SSD_CF     
	,rightside:SSD_ACTR_CTR_NF     
	,rightside:SSD_ACTR_UWY_NF     
	,rightside:SSD_ACTR_UW_NT      
	,rightside:SSD_ACTR_SEC_NF     
	,rightside:SSD_ACTR_END_NT     
	,rightside:SSD_ACTR_CLISSD_NF  
	,rightside:SSD_ACTR_RTOSSD_CF	
exit
EOF
SORT

NSTEP=${NJOB}_265
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL for retrocessionaire subsidiaries..."
PRG=ESTC2315B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOPRD_D ${CLOPRD}
DBCLO_D ${ICLODAT_D}
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_264_${IB}_SORT_DLDSIIGTAR_SSDRTO_RETOVRCOM_SSDACTR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIFTECLEDSII.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR_RI.dat
EXECPRG



NSTEP=${NJOB}_266
#[018] correction sur le code établissement
#-----------------------------------------------------------------------------
LIBEL="SORT OF ESTC2315A_DLEIFTECLEDSII.dat echanges internes generes 'AI' "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTC2315B_DLEIFTECLEDSII.dat 2000 1"
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
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTC2315B_DLDSIIGTAR.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_268A_${IB}_ESTM7604A_DLEIFTECLEDSII_O1_MOD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDSIIGTAA.dat"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ESCOMPTE_CLM.dat"
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
exit
EOF
SORT
JOBEND


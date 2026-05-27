/* struct.h
==============================================================================
[001] 28/07/2010 D.GATIBELZA   ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Köln
                               automatic DAC calculation taking into account the fanancing commission,
                               the technical result,the interest on deposit
[002] 21/03/2011 D.GATIBELZA   ESTDOM21408 OneLedger
[003] 18/04/2012 Roger Cassis  :spot:23802 - Ajout colonne PRS_CF pour Solvency
[004] 29/08/2012 Roger Cassis  :spot:24041 - Ajout 14 colonnes OneGL fichiers GTA
[005] 19/09/2012 Florent       :spot:24041 - Ajout colonnes fichier Perimètre pour le ESTC1062.c et du PIVOT SII
[006] 14/11/2013 -=Dch=-       :spot:25773  - Omega 2B modification de colonnes pour LIFEST
[007] 26/08/2014 ABJ  spot     :25773 ajout du flag GT_SPIMOD
[008] 20/09/2014 Florent       :spot:27747 Multi Currency - ajout colonnes sur le périmètre
                               :spot:27748 Loss Corridor  - ajout colonnes sur le périmètre
[009] 26/01/2015 S.Behague     :spot:28122 EST48
[010] 19/02/2015 F Maragnes    :spot:28305 Ajout colonne sur CASEACT
                               :spot:28140 renommage colonne 176 PER_ESTV2C_COL_02 => ER_SEGSA_B
[011] 02/03/2015 P. Menant     :spot:28306 EST37
[012] 12/05/2015 F Maragnes    :spot:28305 Ajout colonne  CASEACT_Scirpcci_M 21
[013] 27/03/2015 J.FONTANA     :spot:28559 EST24BT - Ajout de PER_PARENT_FLAG et PER_LOCAL_FLAG
[014] 03/06/2015 D. Fillinger  :spot:28742 Automatic Calculation - ajout colonnes sur pericase
[015] 31/08/2015 DFI           :spot:29273 EST26 Intra Day
[016] 11/09/2015 R.BEN EZZINE  :spot:29380 EST29 ajout du statut terminés comptables Retro
[017] 22/10/2015 E.CHATAIN     :spot:29066 Ajout de 14 champs supplementaires GLT
[018] 25/01/2016 M.MECHRI      :spot:30176 NEWBIZ
[019] 12/02/2016 -=Dch=-       :spot:30167 Modification du champ PER_ESTV2C_COL_17 par PER_COMBAS_CF
[020] 25/05/2016 S.Behague     :spot:30583 spira 41148
[021] 02/06/2016 S.Behague     :spot:30300 EST39
[022] 06/06/2016 Florent       :spot:30543 on passe à 65 années GTSII3
[023] 08/07/2016 MMA           :spot:30899 Ajout de la Ledger (ESB) dans CTRFIC
[024] 16/08/2016 S.Behague     :spot:31066 Spira 52504 Postes PMD
[025] 18/11/2016 Florent       :spira:57799 maj de GT_NBCOL2
[026] 28/12/2016 MMA           :Spira 57351 Suppression de la modification [023]
[027] 09/02/2018 S.Behague     :spira 60627 Prise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[028] 11/04/2018 S.Behague     :spira 65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE
[029] 18/04/2018 HH.Huynh      :spira 62073: Creation et ajout BLCSHTSTR_D et BLCSHTEND_D version definitive
[030] 11/05/2018 M.NAJI        : Ajout taxe de base spira 61503
[031] 29/05/2018 HH.Huynh	   :spira 68968: Ajout du taux d'annuité des réserves.(PER_ESTV2C_COL_10 =>PER_ANNFUNINT_R ) dans le fichier pericase 
[032] 29/05/2018 HH.Huynh	   :spira 64222: Modification MAX_LIDRI 150000 -> 200000  suite message erreur limite maximale atteinte 
[033] 20/09/2019 S.Behague     :spira:60627 - Prise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro
[034] 30/08/2018 JYP           : IFRS17 req 10.6 : ajout du IFRS17 priced flg/amount dans le PERICASE 
[035] 08/10/2018 MZM           :spira:70671 : Ajout des Colonnes Montant Retro Net Premium pour le Calcul des FUTURES RETRO PREMIUM 
																							et  "retro pricing LR" dans le champ "IPLR_R" pour le calcul des futures CLAIMS, 
																							et du "flag retro pricing LR" dans le champ PRC_FLG_CT qui dit si oui non le contrat est "price"
[036] 24/10/2018 L.ELFAHIM	   :spira 61507: EST08c3 - Implementation d'une méthode spécifique de calcul sur les portefeuilles prime EPP/RPP
[037] 24/10/2018 JYP		   :revert IFRS17 req 10.6 : suppression champ supplémentaire sur la structure SEGEST
[038] 12/02/2019 S.Behague     :REQ.L.02.05: Evolution quarterly 
[039] 15/03/2019 NL.DOAN       :spira 69939 et spira 66615 -  Ajout deux nouveaux champs (payment frequency, first due date)  dans le PERICASE pour les traités
[040] 15/03/2019 B.LAGHA       : Spira - 64222 - Ajout d'une nouvelle Structure d'un nouveau perimetre additionnel qui contient des nouvelles colonnes
[041] 16/04/2019 MZM           :Spira:70671 - Ajout de la colonne PLA_TOTRETSIGSHA_R
[042] 17/06/2019 TY            :IFRS17 req 10.11 : ajout champ CANEGP_M de TSECIFRS
[043] 10/09/2019 S.Behague :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
[044] 09/04/2020 MZM       :Spira:42212 Traites Decales ; Ajout de la date de derniere Compta
[045] 23/07/2020 HR            :Spira 82685 Fusion struct.h et structA.h
[046] 29/09/2020 MZGM :spira 89714  Mise à jour du champ REIPRMPTP_R comme indicateur de Gratuite du Reinstatement Premium Dans Pericase Annexe
[047] 20/04/2021 R. Cassis :Spira:92617 Ajout champ AMORAT_CT dans le fichier des estimations par segment/exercice/
[048] 28/01/2022 R. Cassis :Spira:98240 Ajout champ GT_GAAPCOD_NT et GT_I17PRDCOD_CT et definition champs FTTECLEDx (nom choisi pour eviter conflits avec autres %TECLED%.h)
[049] 24/09/2025 MZM  US 7084:FIX PROD : NB_MAX_PILOT 200000 => 300000 in struct.h
==============================================================================*/



#ifndef __STRUCT
#define __STRUCT

#define max(a,b)  (((a) > (b)) ? (a) : (b))
#define min(a,b)  (((a) < (b)) ? (a) : (b))

#define NB_MAX_PILOT    300000

#define MAX_LIFDRI 300000
#define LIF_ACY_MAX 4
//Référence step 80 du ESID3703, EST_FTSII
enum C_EST_FTSII
{
  PIV_SSD_CF = 0
  , PIV_ESB_CF
  , PIV_CTR_NF
  , PIV_END_NT
  , PIV_SEC_NF
  , PIV_UWY_NF
  , PIV_UW_NT
  , PIV_ACMCUR_CF
  , PIV_CED_NF
  , PIV_BRK_NF
  , PIV_PAY_NF
  , PIV_KEY_NF
  , PIV_RETCTR_NF
  , PIV_RETEND_NT
  , PIV_RETSEC_NF
  , PIV_RTY_NF
  , PIV_RETUW_NT
  , PIV_RETCUR_CF
  , PIV_PLC_NT
  , PIV_RTO_NF
  , PIV_SEGLOB_CF
  , PIV_ULR_R
  , PIV_ULRY_NF
  , PIV_WPREMIUM_M
  , PIV_WCHARGES_M
  , PIV_WCLAIM_M
  , PIV_UPR_R
  , PIV_SCOEGP_M
  , PIV_FPREMIUM_M
  , PIV_UCR_R
  , PIV_PRCO_M
  , PIV_PRCI_M
  , PIV_NORME_CF
  , PIV_PRMDSC_R
  , PIV_CLMDSC_R
  , PIV_BDTRAT_R
  , PIV_PRMRESD_M
  , PIV_PRMRESB_M
};

/* Champs des placements utilises pour la generation retrocession */
#define PLA1_SSD_CF 0
#define PLA1_ESB_CF 1
#define PLA1_RETCTR_NF 2
#define PLA1_RETEND_NT 3
#define PLA1_RETSEC_NF 4
#define PLA1_RTY_NF 5
#define PLA1_RETUW_NT 6
#define PLA1_PLC_NT 7
#define PLA1_PLCSTS_CT 8
#define PLA1_OVRCOM_R 9
#define PLA1_RTO_NF 10
#define PLA1_INT_NF 11
#define PLA1_PAY_NF 12
#define PLA1_KEY_CF 13
#define PLA1_ORICUR_B 14
#define PLA1_SSDRTO_B 15
#define PLA1_RETSIGSHA_R 16
#define PLA1_LOB_CF 17
#define PLA1_RAICOM_B 18
#define PLA1_RETOVRCOM_B 19
#define PLA1_CTR_NF 20
#define PLA1_END_NT 21
#define PLA1_SEC_NF 22
#define PLA1_UWY_NF 23
#define PLA1_UW_NT 24
#define PLA1_CUR_CF 25
#define PLA1_CESSH_R 26
#define PLA1_CLMFUN_R 27
#define PLA1_URRFUN_R 28
#define PLA1_CLMFUNINT_R 29
#define PLA1_URRFUNINT_R 30
#define PLA1_CONRETCTR_B 31
#define PLA1_OVRBASIS_NT  32
#define PLA1_ACCFAM_CT 33
#define PLA1_ACCTYP_CT 34
#define PLA1_CTRNAT_CT 35
#define PLA1_DEPORI_B  36
/*#define PLA1_RTOCTY_CF 33 */
#define PLA1_BLCSHTSTR_D 37		// [029] 
#define PLA1_BLCSHTEND_D 38		// [029] 
#define PLA1_CLOFAM_CT 39
#define PLA1_NBCOL 40			// [029] 

/* Position des champs dans le perimetre */
#define SEPARATEUR '~'
#define PER_SSD_CF 0
#define PER_SEGTYP_CT 1
#define PER_CTR_NF 2
#define PER_END_NT 3
#define PER_SEC_NF 4
#define PER_UWY_NF 5
#define PER_UW_NT 6
#define PER_ACCESB_CF 7
#define PER_ADMMODPRM_CT 8
#define PER_ANLCTY_CF 9
#define PER_CAN_DT 10
#define PER_CED_NF 11
#define PER_CLICTY_CF 12
#define PER_CLINAT_CF 13
#define PER_CLMACT_M 14
#define PER_COMTYP_CT 15
#define PER_CTBGENFEE_R 16
#define PER_CTBTYP_CT 17
#define PER_CTRINC_D 18
#define PER_CTRRET_B 19
#define PER_CUTSHA_R 20
#define PER_DIV_NT 21
#define PER_EGPCUR_CF 22
#define PER_ESTCRB_CT 23
#define PER_ESTCTR_NF 24
#define PER_ESTEND_B 25
#define PER_ESTSEC_NF 26
#define PER_EXP_D 27
#define PER_FIXCOM_R 28
#define PER_FRSUWY_NF 29
#define PER_GANPAYORD_NT 30
#define PER_GAR_CF 31
#define PER_GENPRMPAY_NF 32
#define PER_GENPRMSEN_NF 33
#define PER_INSPOL_R 34
#define PER_LAYCAP_M 35
#define PER_LIFTRTTYP_CF 36
#define PER_LOB_CF 37
#define PER_LOSCOREXI_B 38
#define PER_LOSCORHIG_R 39
#define PER_LOSCORLOW_R 40
#define PER_LOSCORRAT_R 41
#define PER_LOSCTB_R 42
#define PER_LOSCTBEXI_B 43
#define PER_MAXCOM_R 44
#define PER_MAXRATCLP_R 45
#define PER_MINCOM_R 46
#define PER_MINRATCLP_R 47
#define PER_NAT_CF 48
#define PER_ORDNBR_NT 49
#define PER_PCPCUR_CF 50
#define PER_PCPRSKTRY_CF 51
#define PER_POLDURMTH_NF 52
#define PER_PRD_NF 53
#define PER_PRFCOM_R 54
#define PER_PRFCOMEXI_B 55
#define PER_PRMEFFLOA_M 56
#define PER_PRMEFFLOA_R 57
#define PER_PRMFIXEFF_R 58
#define PER_PRMFLCRAT_B 59
#define PER_PRMMAXEFF_R 60
#define PER_PRMMINEFF_R 61
#define PER_PRMNETCOM_B 62
#define PER_PRMPRTSCL_B 63
#define PER_REIEXI_B 64
#define PER_REIFRE_B 65
#define PER_REINBR_N 66
#define PER_REIUNL_B 67
#define PER_RESTRFDUR_N 68
#define PER_RESTRFTYP_CF 69
#define PER_SBJCPTDEF_B 70
#define PER_SBJPRM_M 71
#define PER_SCLCOMEXI_B 72
#define PER_SCLCTBEXI_B 73
#define PER_SCOEGP_M 74
#define PER_SCOINC_D 75
#define PER_SECACCSTS_CT 76
#define PER_SECINC_D 77
#define PER_SECSTS_CT 78
#define PER_SEG_NF 79
#define PER_SOB_CF 80
#define PER_SUBNAT_CF 81
#define PER_SUPLOATYP_CT 82
#define PER_TOP_CF 83
#define PER_CTRNAT_CT 84
#define PER_UWGRP_CF 85
#define PER_ACCFRQ_CT 86
#define PER_WRKCAT_CT 87
#define PER_ORGINC_D 88
#define PER_LIARIDSHA_B 89
#define PER_FLAPRM_B 90
#define PER_RIDSHA_R 91
#define PER_CTBCALLVL_CF 92
#define PER_CTBCOM_B 93
#define PER_PRMPRT_M 94
#define PER_PRMPRTCUR_CF 95
#define PER_ACCADMTYP_CT 96
#define PER_SBJPRMCUR_CF 97
#define PER_CTRSTS_CT 98
#define PER_OVRCOM_R 99
#define PER_OVRCOMTYP_CT 100
#define PER_TAXCNDEXI_B 101
#define PER_PRDBRK_R 102
#define PER_ACCBRK_R 103
#define PER_LIACUR_CF 104
#define PER_ERNPRMADM_B 105
#define PER_RETCTRCAT_CF 106
#define PER_CLECUTPER_B 107
#define PER_CLECUTPER_NB 108
#define PER_ORICUR_B 109
#define PER_RETACCADM_B 110
#define PER_SSDRTO_B 111
#define PER_RAICOM_B 112
#define PER_DIFMTH_NF 113
#define PER_USRCRTCOD_CT 114
#define PER_USRCRTVAL_LM 115
#define PER_PRDBRKTYP_CT 116
#define PER_ACCBRKTYP_CT 117
#define PER_UWORG_CF 118
#define PER_SECQUA_CF 119
#define PER_SECQUA2_CF 120
#define PER_SECQUA3_CF 121
#define PER_SECQUA4_CF 122
#define PER_SECQUA5_CF 123
#define PER_ADMGRP_CF 124
#define PER_ORGCED_NF 125
#define PER_REITYP_CF 126
#define PER_PRMMINACT_R 127
#define PER_PRMFIXACT_R 128
#define PER_PRMMAXACT_R 129
#define PER_CLMPRMACT_R 130
#define PER_FLAPRM1_M 131
#define PER_FLAPRMCU1_CF 132
#define PER_FLAPRM2_M 133
#define PER_FLAPRMCU2_CF 134
#define PER_FLAPRM3_M 135
#define PER_FLAPRMCU3_CF 136
#define PER_MINPRVPR1_M 137
#define PER_PRVPRMCU1_CF 138
#define PER_MINPRVPR2_M 139
#define PER_PRVPRMCU2_CF 140
#define PER_MINPRVPR3_M 141
#define PER_PRVPRMCU3_CF 142
#define PER_PRTCUR_CF 143
#define PER_PRVPRM_B 144
#define PER_DEFSBJPRM_M 145
#define PER_ESTSBJPRM_M 146
#define PER_SBJPRMCPT_M 147
#define PER_CTRACCSTS_CT 148
#define PER_CTRACCYEA_NF 149
#define PER_PMLRAT_R 150
#define PER_CEDHORDNBR_NT 151
#define PER_CEDSORDNBR_NT 152
#define PER_ORGCEDHORDNBR_NT 153
#define PER_ORGCEDSORDNBR_NT 154
#define PER_BRKHORDNBR_NT 155
#define PER_BRKSORDNBR_NT 156
#define PER_FACADMTYP_B 157
#define PER_CRTVRSINC_D 158
#define PER_RECBRK_B 159 /* indic d'existance de courtage sur REC */
#define PER_RECBRK_R 160 /* taux de courtage sur reconstitution */
#define PER_CNATYP_CT 161 /* TYPE CNA JR 12/06/03 */
#define PER_CLMCUTOFF_B 162  /*  JR 01/04/05 */
#define PER_PRMCUTOFF_B 163  /*  JR 01/04/05 */
#define PER_CLMRUNOFF_B 164  /*  JR 01/04/05 */
#define PER_PRMRUNOFF_B 165  /*  JR 01/04/05 */
#define PER_ASSFINANCE_CT 166  /*  JR 09/12/08  IFRS SPOT16593 */
#define PER_FLAPRM4_M       167
#define PER_FLAPRMCU4_CF    168
#define PER_FLAPRM5_M       169
#define PER_FLAPRMCU5_CF    170
#define PER_MINPRVPR4_M     171
#define PER_PRVPRMCU4_CF    172
#define PER_MINPRVPR5_M     173
#define PER_PRVPRMCU5_CF    174
#define PER_ESTLOSCORTYP_CT 175
#define PER_SEGSA_B         176
#define PER_USGAAP_CT       177     // [014]
#define PER_URRCAL_R        178     // [014]
#define PER_CLMFUN_R        179     // [014]
#define PER_CLMFUNCAS_R     180     // [014]
#define PER_CLMFUNINT_R     181     // [014]
#define PER_URRFUN_R        182     // [014]
#define PER_URRFUNCAS_R     183     // [014]
#define PER_URRFUNINT_R     184     // [014]
#define PER_ANNFUNINT_R   185		// [031]
#define PER_PAYTIME_NF      186   // [011]
#define PER_CTRTYP_CT       187   // [011]
#define PER_CTRINCUWY_D     188   // [011]
#define PER_PARENT_FLAG     189   // [013]   
#define PER_LOCAL_FLAG      190   // [013]
#define PER_TERCTR_B        191     // [016]
#define PER_COMBAS_CF       192   //[019]
#define PER_PAYFRQ_CT       193   // [024]
#define PER_FIRPAYDUE_D     194   // [024]
#define PER_CLOFAM_CT       195   // [027]
#define PER_ACCFAM_CT       196
#define PER_POLED_D         197  //[043]
#define PER_PRMINCEST_CT    198  //[036]
#define PER_PRMWITEST_CT    199  //[036]

#define PER_PRC_FLG_CT		200	  // [034]			 // [035] FLAG PRICING  LR Utilise a partir de IRDPERICASE (PRICEDCTR_B)
#define PER_IPLR_R   		201   // [034]    		 // [035] retro pricing LR Utilise a partir de IRDPERICASE (PRICEDLR_R)
#define PER_FLAPROPRM_M     202   						 // [035]
#define PER_TRT_PAYFRQ_CT   203   // [039]
#define PER_TRT_FIRPAYDUE_D 204   // [039]
#define PER_CANEGP_M	    205	  // [042]
#define PER_NBCOL           206

// Définition Fichier PERIMETRE ETENDUE - MDJ 23/05/2005 - MOD02
#define PERExtend_COMTYP_CT       206
#define PERExtend_SCLCOMEXI_B     207
#define PERExtend_CHGCALLVL_CF    208
#define PERExtend_ESTCOMTYP_CT    209
#define PERExtend_CTBTYP_CT       210
#define PERExtend_SCLCTBEXI_B     211
#define PERExtend_CTBCALLVL_CF    212
#define PERExtend_ESTCBTTYP_CT    213
#define PERExtend_RESCOMTRFTYP_CF 214
#define PERExtend_RESCOMTRFDUR_N  215
#define PERExtend_ESTREITYP_CT    216
#define PERExtend_REIVAR_B        217
#define PERExtend_ESTPRMTYP_CT    218


#define PER_DATDERCPA_D				   218  // [044]  DATEDERCPA 

/* position des champs dans le perimetre annexe PERIFR */

#define PERFR_CTR_NF 0
#define PERFR_END_NT 1
#define PERFR_SEC_NF 2
#define PERFR_UWY_NF 3
#define PERFR_UW_NT 4
#define PERFR_REILIN_NT 5
#define PERFR_REIPRM_M 6
#define PERFR_REIPRM_R 7
#define PERFR_REIPRMBAS_R 8
#define PERFR_REIRNK_N 9
#define PERFR_SEGTYP_CT 10
#define PERFR_SSD_CF 11
#define PERFR_REIPROTMP_B 12
#define PERFR_REIPRMPTP_R 13


/* position des champs dans le perimetre des echeances de primes
provisionnelles*/

#define PERPRMD_CTR_NF 0
#define PERPRMD_END_NT 1
#define PERPRMD_SEC_NF 2
#define PERPRMD_UWY_NF 3
#define PERPRMD_UW_NT 4
#define PERPRMD_PRMDUE_D 5
#define PERPRMD_PRMDUE_M 6
#define PERPRMD_PRMDUECUR_CF 7
#define PERPRMD_PRMLIN_NT 8
#define PERPRMD_SEGTYP_CT 9
#define PERPRMD_SSD_CF 10


/* position des champs dans le perimetre annexe famille des charges taxes */

#define PERFCT_CTR_NF 0
#define PERFCT_END_NT 1
#define PERFCT_SEC_NF 2
#define PERFCT_UWY_NF 3
#define PERFCT_UW_NT 4
#define PERFCT_SEGTYP_CT 5
#define PERFCT_SSD_CF 6
#define PERFCT_TAX_R 7
#define PERFCT_TAXLIN_NT 8
#define PERFCT_TAXTYP_CT 9
#define PERFCT_CNATYP_CT 10
#define PERFCT_TAXBAS_CF 11  // [030] spot 61503

/* position des champs dans le perimetre annexe famille des charges iterees */

#define PERFCI_CTR_NF 0
#define PERFCI_END_NT 1
#define PERFCI_SEC_NF 2
#define PERFCI_UWY_NF 3
#define PERFCI_UW_NT 4
#define PERFCI_CHGLIN_NT 5
#define PERFCI_CHGTYP_B 6
#define PERFCI_MAX_R 7
#define PERFCI_MAXRAT_R 8
#define PERFCI_MIN_R 9
#define PERFCI_MINRAT_R 10
#define PERFCI_RATTYP_B 11
#define PERFCI_SEGTYP_CT 12
#define PERFCI_SSD_CF 13


/* Position des champs dans les postes regroupes */

#define TRS_ACMTRS_NT 0
#define TRS_DETTRS_CF 1
#define TRS_NBCOL 2


/* Position des champs dans le GT */
/*  ajout GT_RETINTAMT_M  jr 01/2003  */
#define GT_SSD_CF 0
#define GT_ESB_CF 1
#define GT_BALSHEY_NF 2
#define GT_BALSHRMTH_NF 3
#define GT_BALSHRDAY_NF 4
#define GT_TRNCOD_CF 5
#define GT_DBLTRNCOD_CF 6
#define GT_CTR_NF 7
#define GT_END_NT 8
#define GT_SEC_NF 9
#define GT_UWY_NF 10
#define GT_UW_NT 11
#define GT_OCCYEA_NF 12
#define GT_ACY_NF 13
#define GT_SCOSTRMTH_NF 14
#define GT_SCOENDMTH_NF 15
#define GT_CLM_NF 16
#define GT_CUR_CF 17
#define GT_AMT_M 18
#define GT_CED_NF 19
#define GT_BRK_NF 20
#define GT_PAY_NF 21
#define GT_KEY_NF 22
#define GT_RETCTR_NF 23
#define GT_RETEND_NT 24
#define GT_RETSEC_NF 25
#define GT_RTY_NF 26
#define GT_RETUW_NT 27
#define GT_RETOCCYEA_NF 28
#define GT_RETACY_NF 29
#define GT_RETSCOSTRMTH_NF 30
#define GT_RETSCOENDMTH_NF 31
#define GT_RCL_NF 32
#define GT_RETCUR_CF 33
#define GT_RETAMT_M 34
#define GT_PLC_NT 35
#define GT_RTO_NF 36
#define GT_INT_NF 37
#define GT_RETPAY_NF 38
#define GT_RETKEY_CF 39
#define GT_RETINTAMT_M 40

#define GT_ESTCUR_CF 41
#define GT_ESTAMT_M 42
#define GT_NAT_CF 43
#define GT_ACMTRS_NT 44
#define GT_ESTCTR_NF 45
#define GT_ESTSEC_NF 46
#define GT_LOB_CF 47
#define GT_SCOEGP_M 48
#define GT_ESTCRB_CT 49
#define GT_LIFTRTTYP_CF 50
#define GT_ACCADMTYP_CT 51
#define GT_SECSTS_CT 52
#define GT_PRD_NF 53
#define GT_SEG_NF 54
#define GT_COMACC_B 55
#define GT_ADJCOD_CT 56
#define GT_ORICOD_CF 57
#define GT_DETTRS_CF 58
#define GT_ACCRET_B 59
#define GT_ESTUWY_NF 60
#define GT_LSTENDMTH_NF 61
#define GT_PROPER_N 62
#define GT_RTOCTY_CF 63
//#define GT_SPIMOD_CT 64
#define GT_GAAP_NF 64
#define GT_BRKSCOEGP_M 65
#define GT_UWGRP_CF 66
#define GT_PROPAGRES_B 67
// Ajout de champ GT_PostBpc_B pour EST48
#define GT_PostBpc_B 68
//[007]
#define GT_SPIMOD_CT 69     //[009]
#define GT_RETAUTGEN_B 70   //[009]
#define GT_ACCTYP_NF 71     //[009]
#define GT_ActivePlan_b 72  //[009]

#define GT_NBCOL 73

// [004]
#define GT_BUKRS_CF 41
#define GT_RCOMP_CF 42
#define GT_LDGRP_CF 43
#define GT_HKONT_CF 44
#define GT_DBLHKONT_CF 45
#define GT_GJAHR_NF 46
#define GT_MONAT_NF 47
#define GT_VBUND_CF 48
#define GT_ZZCED_NF 49
#define GT_SEGMENT_CF 50
#define GT_BEWAR_CF 51
#define GT_ZZGAAPDIF_CF 52
#define GT_BLART_CF 53
#define GT_ZZRECONKEY_CF 54
// [002] GT OneGL ST1 b
#define GT_TRN_NT 55
#define GT_ORICOD_LS 56

//[017]
#define GT_RETROAUTO_B  57
#define GT_SPEENTNAT_CT 58
#define GT_EVT_NF 59
#define GT_REVT_NF  60
#define GT_RETARDRETINT_B 61

#define GT_NEWCOLS1_NF 62
#define GT_GAAPCOD_NT 63      // [048]
#define GT_I17PRDCOD_CT 64    // [048]
#define GT_NEWCOLS4_NF 65
#define GT_NEWCOLS5_NF 66
#define GT_NEWCOLS6_NF 67
#define GT_NEWCOLS7_NF 68
#define GT_NEWCOLS8_NF 69
#define GT_NEWCOLS9_NF 70

#define GT_NBCOL2 71
#define GT_NBCOL3 71
//[017]

/*[045] BEGIN 23/07/2020 Copy from structA*/
#define GT_ACMTRS3_NT 71
/*#define GT_NBCOL2 72 conflict to be solved*/
/*#define GT_NBCOL3 72* conflict to be solved*/
#define GT_PRS_CF 44
#define GT_ACMTRS3_NT2 128
/*END 23/07/2020 Copy of structA*/

//[004]
/* Position des champs dans le GT */
#define GTSII_SSD_CF 0
#define GTSII_ESB_CF 1
#define GTSII_BALSHEY_NF 2
#define GTSII_BALSHRMTH_NF 3
#define GTSII_BALSHRDAY_NF 4
#define GTSII_TRNCOD_CF 5
#define GTSII_DBLTRNCOD_CF 6
#define GTSII_CTR_NF 7
#define GTSII_END_NT 8
#define GTSII_SEC_NF 9
#define GTSII_UWY_NF 10
#define GTSII_UW_NT 11
#define GTSII_OCCYEA_NF 12
#define GTSII_ACY_NF 13
#define GTSII_SCOSTRMTH_NF 14
#define GTSII_SCOENDMTH_NF 15
#define GTSII_CLM_NF 16
#define GTSII_CUR_CF 17
#define GTSII_AMT_M 18
#define GTSII_CED_NF 19
#define GTSII_BRK_NF 20
#define GTSII_PAY_NF 21
#define GTSII_KEY_NF 22
#define GTSII_RETCTR_NF 23
#define GTSII_RETEND_NT 24
#define GTSII_RETSEC_NF 25
#define GTSII_RTY_NF 26
#define GTSII_RETUW_NT 27
#define GTSII_RETOCCYEA_NF 28
#define GTSII_RETACY_NF 29
#define GTSII_RETSCOSTRMTH_NF 30
#define GTSII_RETSCOENDMTH_NF 31
#define GTSII_RCL_NF 32
#define GTSII_RETCUR_CF 33
#define GTSII_RETAMT_M 34
#define GTSII_PLC_NT 35
#define GTSII_RTO_NF 36
#define GTSII_INT_NF 37
#define GTSII_RETPAY_NF 38
#define GTSII_RETKEY_CF 39
#define GTSII_RETINTAMT_M 40
#define GTSII_ACMTRS_NT 41
#define GTSII_ACMAMT_MC 42
#define GTSII_ACMCUR_CF 43
#define GTSII_PRS_CF 44
#define GTSII_SEG_NF 45
#define GTSII_LOB_CF 46
#define GTSII_NAT_CF 47
#define GTSII_TYP_CT 48
#define GTSII_PATTYP_CT 49
#define GTSII_SEGLOB_CF 50
#define GTSII_NBCOL 51

/*[045] BEGIN 23/07/2020 COPY from structA*/
#define GTSII_ACMTRS3_NT 51
#define GTSII_CURQUOT_RATE      41
#define GTSII_CURQUOT_RET_RATE  42
#define GTSII_TRSLNK_ACMTRS_NT  43
#define GTSII_FBOPRSLNK_ACMTRSL2_NT     44
#define GTSII_FBOPRSLNK_ACMTRSL3_NT     45
#define GTSII_FBOPRSLNK_TRNTYP_CT       46
#define GTSII_ACMTRS2_NT 58
#define GTSII_ACMTRS3_NT2 61
/*END 23/07/2020 COPY from structA*/

/* pour prog ESTC2315 échanges internes */
#define GTSII3_PLC_NT 35
#define GTSII3_RTO_NF 36
#define GTSII3_INT_NF 37
#define GTSII3_RETPAY_NF 38
#define GTSII3_RETKEY_CF 39
#define GTSII3_RETINTAMT_M 40
#define GTSII3_ACMTRS_NT 41
#define GTSII3_ACMAMT_MC 42
#define GTSII3_ACMCUR_CF 43
#define GTSII3_PRS_CF 44
#define GTSII3_SEG_NF 45
#define GTSII3_LOB_CF 46
#define GTSII3_NAT_CF 47
#define GTSII3_TYP_CT 48
#define GTSII3_NORME_CF 49
#define GTSII3_RATING_CF 50
#define GTSII3_PATCAT_CT 51
#define GTSII3_PATTYP_CT 52
#define GTSII3_PATTERN_ID 53
#define GTSII3_AN1_M 54
#define GTSII3_AN_FIN_M 118 //65 année de taux
#define GTSII3_COEF_LOB 119
#define GTSII3_DSCCUR_CF 120
#define GTSII3_COMMENT 121
#define GTSII3_TOTAUX_M 122
#define GTSII3_TIFI_M 123
#define GTSII3_CLISSD_NF 124
#define GTSII3_CLOPRD_D 125
#define GTSII3_DBCLO_D 126
#define GTSII3_CRE_D 127
#define GTSII3_SSD_CF 128

enum FORMAT_TTECLEDSII
{
  TTECLEDSII_SSD_CF = 0
  , TTECLEDSII_ESB_CF
  , TTECLEDSII_CLODAT_D
  , TTECLEDSII_CLOTYP_CT
  , TTECLEDSII_BALSHEY_NF
  , TTECLEDSII_BALSHRMTH_NF
  , TTECLEDSII_BALSHRDAY_NF
  , TTECLEDSII_CTR_NF
  , TTECLEDSII_END_NT
  , TTECLEDSII_SEC_NF
  , TTECLEDSII_UWY_NF
  , TTECLEDSII_UW_NT
  , TTECLEDSII_RETCTR_NF
  , TTECLEDSII_RETEND_NT
  , TTECLEDSII_RETSEC_NF
  , TTECLEDSII_RETRTY_NF
  , TTECLEDSII_RETUW_NT
  , TTECLEDSII_PLC_NT
  , TTECLEDSII_RTO_NF
  , TTECLEDSII_ACMTRS_NT
  , TTECLEDSII_ACMAMT_M
  , TTECLEDSII_CUR_CF
  , TTECLEDSII_DSCCUR_CF
  , TTECLEDSII_PRS_CF
  , TTECLEDSII_SEG_NF
  , TTECLEDSII_LOBACC_CF
  , TTECLEDSII_LOBRET_CF
  , TTECLEDSII_SEGNAT_CT
  , TTECLEDSII_ACCRET_CF
  , TTECLEDSII_NORME_CF
  , TTECLEDSII_RATING_CF
  , TTECLEDSII_COEF_LOB
  , TTECLEDSII_PATCAT_CT
  , TTECLEDSII_PATTYP_CT
  , TTECLEDSII_PATTERN_ID
  , TTECLEDSII_CRE_D
  , TTECLEDSII_CREUSR_CF
  , TTECLEDSII_TOTAUX
  , TTECLEDSII_AN1
  , TTECLEDSII_AN2
  , TTECLEDSII_AN3
  , TTECLEDSII_AN4
  , TTECLEDSII_AN5
  , TTECLEDSII_AN6
  , TTECLEDSII_AN7
  , TTECLEDSII_AN8
  , TTECLEDSII_AN9
  , TTECLEDSII_AN10
  , TTECLEDSII_AN11
  , TTECLEDSII_AN12
  , TTECLEDSII_AN13
  , TTECLEDSII_AN14
  , TTECLEDSII_AN15
  , TTECLEDSII_AN16
  , TTECLEDSII_AN17
  , TTECLEDSII_AN18
  , TTECLEDSII_AN19
  , TTECLEDSII_AN20
  , TTECLEDSII_AN21
  , TTECLEDSII_AN22
  , TTECLEDSII_AN23
  , TTECLEDSII_AN24
  , TTECLEDSII_AN25
  , TTECLEDSII_AN26
  , TTECLEDSII_AN27
  , TTECLEDSII_AN28
  , TTECLEDSII_AN29
  , TTECLEDSII_AN30
  , TTECLEDSII_AN31
  , TTECLEDSII_AN32
  , TTECLEDSII_AN33
  , TTECLEDSII_AN34
  , TTECLEDSII_AN35
  , TTECLEDSII_AN36
  , TTECLEDSII_AN37
  , TTECLEDSII_AN38
  , TTECLEDSII_AN39
  , TTECLEDSII_AN40
  , TTECLEDSII_COMMENT_CF
  , TTECLEDSII_TIFI_M
  , TTECLEDSII_AN41
  , TTECLEDSII_AN42
  , TTECLEDSII_AN43
  , TTECLEDSII_AN44
  , TTECLEDSII_AN45
  , TTECLEDSII_AN46
  , TTECLEDSII_AN47
  , TTECLEDSII_AN48
  , TTECLEDSII_AN49
  , TTECLEDSII_AN50
  , TTECLEDSII_AN51
  , TTECLEDSII_AN52
  , TTECLEDSII_AN53
  , TTECLEDSII_AN54
  , TTECLEDSII_AN55
  , TTECLEDSII_AN56
  , TTECLEDSII_AN57
  , TTECLEDSII_AN58
  , TTECLEDSII_AN59
  , TTECLEDSII_AN60
  , TTECLEDSII_AN61
  , TTECLEDSII_AN62
  , TTECLEDSII_AN63
  , TTECLEDSII_AN64
  , TTECLEDSII_AN65
};

/* Position des champs dans le GT enrichi */
/*  ajout GTE_RETINTAMT_M  jr 01/2003  */
#define GTE_SSD_CF 0
#define GTE_ESB_CF 1
#define GTE_BALSHEY_NF 2
#define GTE_BALSHRMTH_NF 3
#define GTE_BALSHRDAY_NF 4
#define GTE_TRNCOD_CF 5
#define GTE_DBLTRNCOD_CF 6
#define GTE_CTR_NF 7
#define GTE_END_NT 8
#define GTE_SEC_NF 9
#define GTE_UWY_NF 10
#define GTE_UW_NT 11
#define GTE_OCCYEA_NF 12
#define GTE_ACY_NF 13
#define GTE_SCOSTRMTH_NF 14
#define GTE_SCOENDMTH_NF 15
#define GTE_CLM_NF 16
#define GTE_CUR_CF 17
#define GTE_AMT_M 18
#define GTE_CED_NF 19
#define GTE_BRK_NF 20
#define GTE_PAY_NF 21
#define GTE_KEY_NF 22
#define GTE_RETCTR_NF 23
#define GTE_RETEND_NT 24
#define GTE_RETSEC_NF 25
#define GTE_RTY_NF 26
#define GTE_RETUW_NT 27
#define GTE_RETOCCYEA_NF 28
#define GTE_RETACY_NF 29
#define GTE_RETSCOSTRMTH_NF 30
#define GTE_RETSCOENDMTH_NF 31
#define GTE_RCL_NF 32
#define GTE_RETCUR_CF 33
#define GTE_RETAMT_M 34
#define GTE_PLC_NT 35
#define GTE_RTO_NF 36
#define GTE_INT_NF 37
#define GTE_RETPAY_NF 38
#define GTE_RETKEY_CF 39
#define GTE_RETINTAMT_M 40
#define GTE_ACMTRS_NT 41
#define GTE_ACMAMT_M 42
#define GTE_ACMCUR_CF 43

/* Position des champs dans le GT cumule pour les estimations avec les */
/* exercices de survenance */

#define GTESTCUMUL1_CTR_NF 0
#define GTESTCUMUL1_END_NT 1
#define GTESTCUMUL1_SEC_NF 2
#define GTESTCUMUL1_UWY_NF 3
#define GTESTCUMUL1_UW_NT 4
#define GTESTCUMUL1_OCCYEA_NF 5
#define GTESTCUMUL1_ACMTRS_NT 6
#define GTESTCUMUL1_ACMAMT_M 7
#define GTESTCUMUL1_ACMCUR_CF 8
#define GTESTCUMUL1_SEG_NF 9

/* Position des champs dans le GT cumule pour les estimations sans les */
/* exercices de survenance */

#define GTESTCUMUL2_CTR_NF 0
#define GTESTCUMUL2_END_NT 1
#define GTESTCUMUL2_SEC_NF 2
#define GTESTCUMUL2_UWY_NF 3
#define GTESTCUMUL2_UW_NT 4
#define GTESTCUMUL2_ACMTRS_NT 5
#define GTESTCUMUL2_ACMAMT_M 6

/* Position des champs dans le Fichier de Travail */

#define FT_CLODAT_D 0
#define FT_CTR_NF 1
#define FT_END_NT 2
#define FT_SEC_NF 3
#define FT_UWY_NF 4
#define FT_UW_NT 5
#define FT_ACY_NF 6
#define FT_SCOSTRMTH_NF 7
#define FT_SCOENDMTH_NF 8
#define FT_UWYDIS_NF 9
#define FT_SSD_CF 10
#define FT_WFCOD_NT 11
#define FT_WFTYP_CF 12
#define FT_EGPCUR_CF 13
#define FT_PRM_M 14
#define FT_PPNAC_M 15
#define FT_PPNAEA_M 16
#define FT_RPPC_M 17
#define FT_RPPEA_M 18
#define FT_LPPNAC_M 19
#define FT_EPPC_M 20
#define FT_EPPEA_M 21
#define FT_RECC_M 22
#define FT_RECE_M 23
#define FT_BCC_M 24
#define FT_BCE_M 25
#define FT_SHR_R 26
#define FT_ACCADMTYP_CT 27
#define FT_PRS_CF 28         // [003]

/* Position des champs dans les previsions */
enum C_PREVI_COLS {
  PRE_SSD_CF  = 0   //0
  , PRE_CTR_NF      //1
  , PRE_END_NT      //2
  , PRE_SEC_NF      //3
  , PRE_UWY_NF      //4
  , PRE_UW_NT     //5
  , PRE_ACY_NF      //6
  , PRE_CRE_D     //7
  , PRE_PRS_CF      //8
  , PRE_ACMTRS_NT   //9

  , PRE_BALSHEY_NF    //10
  , PRE_BALSHTMTH_NF  //11
  , PRE_CUR_CF      //12
  , PRE_ESTMNT_M    //13
  , PRE_INDSUP_B    //14
  , PRE_ORICOD_LS   //15
  , PRE_CREUSR_CF   //16
  , PRE_LSTUPD_D    //17
  , PRE_LSTUPDUSR_CF  //18
  , PRE_DETTRNCOD_CF    //19
  , PRE_DETTRS_CF     //20
  , PRE_GAAP_NF   //21
  , PRE_GAAPDIFF_M    //22
  , PRE_PROPAGATION_B //23
  , PRE_ESTMTH_NF   //24
  , PRE_ORICTR_NF   //25
  , PRE_ORISEC_NF   //26
  , PRE_ORIUWY_NF   //27
  , PRE_UPD_NF      //28
  , PRE_LOB_CF      //29
  , PRE_ACCSTS_CT   //30
  , PRE_ACCADMTYP_CT  //31
  , PRE_ESTCRB_CT   //32
  , PRE_CED_NF      //33
  , PRE_BRK_NF      //34
  , PRE_SPIMOD_CT   //35
  , PRE_PAY_NF      //36
  , PRE_NAT_CF    //37
  , PRE_GANPAYORD_NT  //38
  , PRE_ADJCOD_CT   //39
  , PRE_RETCOD_CT   //40
  , PRE_ACCRET_B    //41
  , PRE_ESB_CF      //42
  , PRE_LIFTRTTYP_CF  //43
  , PRE_UWGRP_CF    //44
  , PRE_CNATYP_CT   //45
  , PRE_RENOUV_B    //46
  , PRE_CLOPRD      //47
  , PRE_DBCLO_D   //48
  , PRE_ORICRE_D    //49
  , PRE_ORISSD_CF   //50
  , PRE_BATCH_B   //51
  , PRE_NBCOLNEW    //52
  , PRE_NBCOL     //53
};

// colonnes de fichier CPLIFEST
enum C_TLIFEST_COLS {
  TLIFEST_CTR_NF = 0    // 0
  , TLIFEST_END_NT      // 1
  , TLIFEST_SEC_NF      // 2
  , TLIFEST_UWY_NF      // 3
  , TLIFEST_UW_NT     // 4
  , TLIFEST_CRE_D     // 5
  , TLIFEST_BALSHEY_NF    // 6
  , TLIFEST_BALSHTMTH_NF  // 7
  , TLIFEST_ACY_NF      // 8
  , TLIFEST_GAAP_NF     // 9
  , TLIFEST_DETTRNCOD_CF      // 10
  , TLIFEST_ESTMTH_NF     // 11
  , TLIFEST_PRS_CF      // 12
  , TLIFEST_ACMTRS_NT   // 13
  , TLIFEST_SSD_CF      // 14
  , TLIFEST_CUR_CF      // 15
  , TLIFEST_ESTMNT_M    // 16
  , TLIFEST_INDSUP_B    // 17
  , TLIFEST_ORICOD_LS   // 18
  , TLIFEST_CREUSR_CF   // 19
  , TLIFEST_LSTUPD_D    // 20
  , TLIFEST_LSTUPDUSR_CF  //21
  , TLIFEST_ORICTR_NF       // 22
  , TLIFEST_ORISEC_NF       // 23
  , TLIFEST_ORIUWY_NF       // 24
  , TLIFEST_GAAPDIFF_M      // 25
  , TLIFEST_PROPAGATION_B     // 26
  , TLIFEST_CALCULATED_B      // 27
  , TLIFEST_BATCH_B       // 28
  , TLIFEST_ESB_CF      // 29
};


/* Position des champs dans le fichier(1) modif prevision vie */

#define MOD_CTR_NF 0
#define MOD_SEC_NF 1
#define MOD_CRE_D 2
#define MOD_BALSHEY_NF 3
#define MOD_BALSHTMTH_NF 4
#define MOD_SSD_CF 5
#define MOD_TYPMOD1_CT 6
#define MOD_TYPMOD2_CT 7
#define MOD_CUR_CF 8
#define MOD_CMT_NT 9
#define MOD_SENMAI_D 10
#define MOD_ORICOD_LS 11
#define MOD_CREUSR_CF 12
#define MOD_LSTUPD_D 13
#define MOD_LSTUPDUSR_CF 14
#define MOD_TIMESTAMP_CF 15
#define MOD_DISPLAY_B 16
#define MOD_NBCOL 17

/* Position des champs dans le fichier(2) modif prevision vie */

#define MOD2_CTR_NF 0
#define MOD2_SEC_NF 1
#define MOD2_CRE_D 2
#define MOD2_BALSHEY_NF 3
#define MOD2_BALSHTMTH_NF 4
#define MOD2_ACY_NF 5
#define MOD2_COMACC_B 6
#define MOD2_PRIPRMAMT_M 7
#define MOD2_AFTPRMAMT_M 8
#define MOD2_PRIRESTECAMT_M 9
#define MOD2_AFTRESTECAMT_M 10
#define MOD2_PRIRESDACAMT_M 11
#define MOD2_AFTRESDACAMT_M 12
#define MOD2_PRIRESFINAMT_M 13
#define MOD2_AFTRESFINAMT_M 14
#define MOD2_CREUSR_CF 15
#define MOD2_LSTUPD_D 16
#define MOD2_LSTUPDUSR_CF 17
#define MOD2_TIMESTAMP_CF 18
#define MOD2_GAAP_NT 19
#define MOD2_NBCOL 20

/* Position des champs dans le fichier TLIFPEN */

#define PEN_USR_CF 0
#define PEN_CTR_NF 1
#define PEN_SEC_NF 2
#define PEN_CRE_D 3
#define PEN_BALSHEY_NF 4
#define PEN_BALSHTMTH_NF 5
#define PEN_PENSTS_CT 6
#define PEN_UWGRP_CF 7
#define PEN_CREUSR_CF 8
#define PEN_LSTUPD_D 9
#define PEN_LSTUPDUSR_CF 10
#define PEN_TIMESTAMP_CF 11
#define PEN_NBCOL 12


/* positions des champs dans le fichier de placement issu de la table retro
   TPLACEMT*/

#define PLC_RETCTR_NF         0
#define PLC_RTY_NF            1
#define PLC_PLC_NT            2
#define PLC_PLCVER_NT         3
#define PLC_SSD_CF            4
#define PLC_INT_NF            5
#define PLC_UDWAGE_NF         6
#define PLC_PLCCENT_NT        7
#define PLC_RTO_NF            8
#define PLC_PLCSTS_CT         9
#define PLC_PLCSTS_D         10
#define PLC_CTC_NT           11
#define PLC_SSDRTO_B         12
#define PLC_VALLCK_B         13
#define PLC_CTRMAI_D         14
#define PLC_TRTPROMAI_D      15
#define PLC_COVNOTREC_D      16
#define PLC_SIGREC_D         17
#define PLC_SIGRMD_D         18
#define PLC_PLCCMT_NT        19
#define PLC_RETACTSHA_R      20
#define PLC_RETACTUNT_N      21
#define PLC_RETACTLIA_M      22
#define PLC_RETPOTUNT_N      23
#define PLC_RETPOTLIA_M      24
#define PLC_RETPOTSHA_R      25
#define PLC_RETSIGSHA_R      26
#define PLC_LEARNK_N         27
#define PLC_MINPRMLCK_B      28
#define PLC_LATSETPRM_NT     29
#define PLC_ACCDIS_B         30
#define PLC_PAY_NF           31
#define PLC_KEY_CF           32
#define PLC_RTOREF_LS        33
#define PLC_PLCINC_D         34
#define PLC_CAN_DT           35
#define PLC_PARCMU_B         36
#define PLC_PNO_D            37
#define PLC_PNORMD_D         38
#define PLC_PLCCON_D         39
#define PLC_DEFPLCSEN_D      40
#define PLC_GENRMD_D         41
#define PLC_GENRMDCMT_NT     42
#define PLC_FUNWIT_B         43
#define PLC_CTRFUNCON_B      44
#define PLC_ACCPLC_B         45
#define PLC_RTOCTY_CF        46
#define PLC_RENPLC_B         47
#define PLC_CTRPROCON_B      48
#define PLC_CTRCOMCON_B      49
#define PLC_FIXCOM_R         50
#define PLC_SUBACCLOC_B      51
#define PLC_RETOVRCOM_B      52
#define PLC_OVRCOM_R         53
#define PLC_PROPLA_B         54
#define PLC_CONPLC_B         55
#define PLC_HIS_B            56
#define PLC_RAICOM_B         57
#define PLC_ACKSEN_D         58
#define PLC_PNOSCO_B         59
#define PLC_ACCCTC_NT        60
#define PLC_CRE_D            61
#define PLC_CREUSR_CF        62
#define PLC_LSTUPD_D         63
#define PLC_LSTUPDUSR_CF     64
#define PLC_NBCOL            65

/* Champs des placements utilises pour la generation retrocession */
#define PLA_SSD_CF 0
#define PLA_ESB_CF 1
#define PLA_RETCTR_NF 2
#define PLA_RETEND_NT 3
#define PLA_RETSEC_NF 4
#define PLA_RTY_NF 5
#define PLA_RETUW_NT 6
#define PLA_PLC_NT 7
#define PLA_OVRCOM_R 8
#define PLA_RTO_NF 9
#define PLA_INT_NF 10
#define PLA_PAY_NF 11
#define PLA_KEY_CF 12
#define PLA_ORICUR_B 13
#define PLA_SSDRTO_B 14
#define PLA_RETSIGSHA_R 15
#define PLA_LOB_CF 16
#define PLA_RAICOM_B 17
#define PLA_RETOVRCOM_B 18
#define PLA_CTR_NF 19
#define PLA_END_NT 20
#define PLA_SEC_NF 21
#define PLA_UWY_NF 22
#define PLA_UW_NT 23
#define PLA_CUR_CF 24
#define PLA_CESSH_R 25
#define PLA_CLMFUN_R 26
#define PLA_URRFUN_R 27
#define PLA_CLMFUNINT_R 28
#define PLA_URRFUNINT_R 29
#define PLA_CONRETCTR_B 30
#define PLA_DEPORI_B 31
#define PLA_RTOCTY_CF 32
#define PLA_BASIS_NT  33
#define PLA_OVRBASIS_NT   34
#define PLA_FIXCOM_R      35
#define PLA_TOTRETSIGSHA_R 36  // [40] Ajout de la colonne 
#define PLA_NBCOL 37

//Modif pour STAM1225
#define PLA_STAT_RTOCTY_CF 30
/* modif JR 18/02/2003 */
/* ATTENTION le champs PLA_RTOCTY_CF n'est utilisé que par stat reporting */
/* les champs PLA_CONRETCTR_B et PLA_DEPORI_B ont ete inséré avant en colonne 30 pour utilisation dans estimation  */

/* Position des champs dans les comptes complets */

#define CMP_SSD_CF 0
#define CMP_CTR_NF 1
#define CMP_ACY_NF 2
#define CMP_SCOSTRMTH_NF 3
#define CMP_SCOENDMTH_NF 4
#define CMP_LSTUPD_D 5
#define CMP_PROPAGRES_B 6
#define CMP_NBCOL 7

/* Position des champs dans le fichier TPINTWIT */
#define TPINTWIT_RETCTR_NF 0
#define TPINTWIT_RTY_NF 1
#define TPINTWIT_PLC_NT 2
#define TPINTWIT_PLCVER_NT 3
#define TPINTWIT_RETTRTCUR_CF 4
#define TPINTWIT_CLMFUNINT_R 5
#define TPINTWIT_URRFUNINT_R 6
#define TPINTWIT_IBNFUNINT_R 7
#define TPINTWIT_SSD_CF 8
#define TPINTWIT_CRE_D 9
#define TPINTWIT_CREUSR_CF 10
#define TPINTWIT_LSTUPD_D 11
#define TPINTWIT_LSTUPDUSR_CF 12

/* Position des champs dans le fichier TINTWIT */
#define TINTWIT_RETCTR_NF 0
#define TINTWIT_RTY_NF 1
#define TINTWIT_RETTRTCUR_CF 2
#define TINTWIT_CLMFUNINT_R 3
#define TINTWIT_URRFUNINT_R 4
#define TINTWIT_IBNFUNINT_R 5
#define TINTWIT_CRE_D 6
#define TINTWIT_CREUSR_CF 7
#define TINTWIT_LSTUPD_D 8
#define TINTWIT_LSTUPDUSR_CF 9

/* Position des champs dans le fichier TDEPOSIT */

#define TDEPOSIT_RETCTR_NF 0
#define TDEPOSIT_RTY_NF 1
#define TDEPOSIT_SSD_CF 2
#define TDEPOSIT_CLMFUNMOD_CT 3
#define TDEPOSIT_CLMFUN_R 4
#define TDEPOSIT_URRFUNMOD_CT 5
#define TDEPOSIT_URRFUN_R 6
#define TDEPOSIT_IBNFUNMOD_CT 7
#define TDEPOSIT_IBNFUN_R 8
#define TDEPOSIT_DEPADM_CT 9
#define TDEPOSIT_DEPORI_B 10
#define TDEPOSIT_CANDEP_B 11
#define TDEPOSIT_CRE_D 12
#define TDEPOSIT_CREUSR_CF 13
#define TDEPOSIT_LSTUPD_D 14
#define TDEPOSIT_LSTUPDUSR_CF 15
#define TDEPOSIT_NBCOL 16

/* Position des champs dans le fichier TPFUNWIT */

#define TPFUNWIT_RETCTR_NF 0
#define TPFUNWIT_RTY_NF 1
#define TPFUNWIT_PLC_NT 2
#define TPFUNWIT_PLCVER_NT 3
#define TPFUNWIT_SSD_CF 4
#define TPFUNWIT_CLMFUNMOD_CT 5
#define TPFUNWIT_CLMFUN_R 6
#define TPFUNWIT_URRFUNMOD_CT 7
#define TPFUNWIT_URRFUN_R 8
#define TPFUNWIT_IBNFUNMOD_CT 9
#define TPFUNWIT_IBNFUN_R 10
#define TPFUNWIT_DEPADM_CT 11
#define TPFUNWIT_DEPORI_B 12
#define TPFUNWIT_CANDEP_B 13
#define TPFUNWIT_CRE_D 14
#define TPFUNWIT_CREUSR_CF 15
#define TPFUNWIT_LSTUPD_D 16
#define TPFUNWIT_LSTUPDUSR_CF 17
#define TPFUNWIT_NBCOL 18

/* Position des champs dans le fichier FCTRGRO */
#define CTRGRO_CTR_NF 0
#define CTRGRO_END_NT 1
#define CTRGRO_SEC_NF 2
#define CTRGRO_VRS_NF 3
#define CTRGRO_SSD_CF 4
#define CTRGRO_SEGTYP_CT 5
#define CTRGRO_SEG_NF 6
#define CTRGRO_NAT_CF 13
#define CTRGRO_CTRRET_B 18

/* Position des champs dans le fichier PERICASEEST */

#define CASEEST_CTR_NF 0
#define CASEEST_END_NT 1
#define CASEEST_SEC_NF 2
#define CASEEST_UWY_NF 3
#define CASEEST_UW_NT  4
#define CASEEST_EGPCUR_CF 5
#define CASEEST_CTRNAT_CT 6
#define CASEEST_Pai_M 7
#define CASEEST_SEG_NF 8
#define CASEEST_Scii_M 9
#define CASEEST_Scci_M 10
#define CASEEST_PAi_M  11
#define CASEEST_Psi_M  12
#define CASEEST_Ssi_M  13
#define CASEEST_Ssi_CT 14
#define CASEEST_CALAMTPRM_M 15
#define CASEEST_ENTAMTPRM_M 16
#define CASEEST_ADMMODPRM_CT 17
#define CASEEST_CALAMTCLM_M 18
#define CASEEST_ENTAMTCLM_M 19


/* Position des champs dans le fichier PERICASEACT  */

#define CASEACT_CTR_NF 0
#define CASEACT_END_NT 1
#define CASEACT_SEC_NF 2
#define CASEACT_UWY_NF 3
#define CASEACT_UW_NT  4
#define CASEACT_EGPCUR_CF 5
#define CASEACT_CTRNAT_CT 6
#define CASEACT_Pai_M 7
#define CASEACT_SEG_NF 8
#define CASEACT_Scii_M 9
#define CASEACT_Scci_M 10
#define CASEACT_PAi_M  11
#define CASEACT_Psi_M  12
#define CASEACT_Ssi_M  13
#define CASEACT_Sai_M  14
#define CASEACT_Sai_CT 15
#define CASEACT_PAai_M 16
#define CASEACT_ENTAMT_M 17
#define CASEACT_Sccai_M 18
#define CASEACT_Sccarpcci_M 19
#define CASEACT_Sccrpcci_M 20
#define CASEACT_Scirpcci_M 21

/* Position des champs dans le fichier des estimations par segment/exercice */

#define SEGEST1_SSD_CF 0
#define SEGEST1_SEG_NF 1
#define SEGEST1_UWY_NF 2
#define SEGEST1_CUR_CF 3
#define SEGEST1_SEGNAT_CT 4
#define SEGEST1_Ss_M 5
#define SEGEST1_SP_R 6
#define SEGEST1_SP_CT 7


/* Position des champs dans le fichier des estimations par segment/exercice/ */
/* devise de l'aliment */

#define SEGEST2_SEG_NF 0
#define SEGEST2_UWY_NF 1
#define SEGEST2_EGPCUR_CF 2
#define SEGEST2_CUR_CF 3
#define SEGEST2_SEGNAT_CT 4
#define SEGEST2_Ss_M 5
#define SEGEST2_Ps_M 6
#define SEGEST2_PAa_M 7
#define SEGEST2_Sc_M 8
#define SEGEST2_PA_M 9
#define SEGEST2_Pa_M 10
#define SEGEST2_Sa_M 11
#define SEGEST2_AMORAT_CT 12  /* Modif [047] */


/* Position des champs dans le fichier des ventilations par segment/exercice/ */
/* exercice de survenance */

#define LABOCY_VRS_NF 0
#define LABOCY_SSD_CF 1
#define LABOCY_SEGTYP_CT 2
#define LABOCY_SEG_NF 3
#define LABOCY_UWY_NF 4
#define LABOCY_CRE_D 5
#define LABOCY_OCCYEA_NF 6
#define LABOCY_SPIRAT_R 7


/* Position des champs dans le fichier des ventilations par segment/exercice/ */
/* exercice de survenance utile pour les estimations */

#define LABOCYEST_SEG_NF 0
#define LABOCYEST_UWY_NF 1
#define LABOCYEST_OCCYEA_NF 2
#define LABOCYEST_SPIRAT_R 3
#define LABOCYEST_Sc_M 4


/* Position des champs dans le fichier des ultimes */

#define ULT_CTR_NF 0
#define ULT_END_NT 1
#define ULT_SEC_NF 2
#define ULT_UWY_NF 3
#define ULT_UW_NT 4
#define ULT_CRE_D 5
#define ULT_SSD_CF 6
#define ULT_DIV_NT 7
#define ULT_CUR_CF 8
#define ULT_CALAMTPRM_M 9
#define ULT_ENTAMTPRM_M 10
#define ULT_RETAMTPRM_M 11
#define ULT_ADMMODPRM_CT 12
#define ULT_RESPRM_M 13
#define ULT_CALAMTCLM_M 14
#define ULT_ENTAMTCLM_M 15
#define ULT_RETAMTCLM_M 16
#define ULT_ADMMODCLM_CT 17
#define ULT_ORICOD_LS 18
#define ULT_UPDUSR_CF 19
#define ULT_CREUSR_CF 20
#define ULT_LSTUPD_D 21
#define ULT_LSTUPDUSR_CF 22


/* Position des champs dans le fichier des dommages */

#define EST_CTR_NF 0
#define EST_END_NT 1
#define EST_SEC_NF 2
#define EST_UWY_NF 3
#define EST_UW_NT 4
#define EST_CRE_D 5
#define EST_PRS_CF 6
#define EST_ACMTRS_NT 7
#define EST_SSD_CF 8
#define EST_DIV_NT 9
#define EST_CUR_CF 10
#define EST_CALAMT_M 11
#define EST_ENTAMT_M 12
#define EST_RETAMT_M 13
#define EST_ADMMOD_CT 14
#define EST_CLODAT_D 15
#define EST_ORICOD_LS 16
#define EST_UPDUSR_CF 17
#define EST_CREUSR_CF 18
#define EST_LSTUPD_D 19
#define EST_LSTUPDUSR_CF 20
#define EST_CMT_NT 21


/* Position de champs dans le fichier des charges iterees */

#define CHG2_CTR_NF 0
#define CHG2_END_NT 1
#define CHG2_SEC_NF 2
#define CHG2_UWY_NF 3
#define CHG2_UW_NT  4
#define CHG2_CHGLIN_NT 5
#define CHG2_RATTYP_B 6
#define CHG2_MAX_R 7
#define CHG2_MINRAT_R 8
#define CHG2_MIN_R 9
#define CHG2_MAXRAT_R 10


/* Positions des champs des postes cumules */

#define ACC_ACMTRS_NT   0
#define ACC_PRS_CF      1
#define ACC_ADJCOD_CT   2
#define ACC_RETCOD_CT   3
#define ACC_DETTRS_CF   4
#define ACC_ADJSIG_B    5
#define ACC_SPIMOD_CT   6
#define ACC_RESTEC_B    7       //[001]
#define ACC_RESDAC_B    8       //[001]
#define ACC_RESFIN_B    9       //[001]
#define ACC_SUMRISK_B  10       //[001]
#define ACC_NBCOL      11       //[001] passe de 7 à 11


/* position des champs dans le fichier des versements en entree */
/* de l'operateur de versement */
#define CES_CTR_NF 0
#define CES_END_NT 1
#define CES_SEC_NF 2
#define CES_UWY_NF 3
#define CES_UW_NT 4
#define CES_RETCTR_NF 5
#define CES_RETEND_NT 6
#define CES_RETSEC_NF 7
#define CES_RTY_NF 8
#define CES_RETUW_NT 9
#define CES_CESACCSTA_N 10
#define CES_CESACCEND_N 11
#define CES_CESSH_R 12
#define CES_SSD_CF 13
#define CES_ESB_CF 14
#define CES_RETCTRCAT_CF 15
#define CES_ACCADMTYP_CT 16
#define CES_RETACCADM_B 17
#define CES_CLECUTPER_B 18
#define CES_CLECUTPER_NB 19
#define CES_LOB_CF 20
#define CES_CUR_CF 21
#define CES_RETPCPCUR_CF 22
#define CES_CONRETCTR_B 23
#define CES_ACCFAM_CT 24
#define CES_NBCOL 25

// [029]  
/* spira 62073 : position des champs dans le fichier des versements en entree */
/* de l'operateur de versement  */
#define CES1_CTR_NF 0
#define CES1_END_NT 1
#define CES1_SEC_NF 2
#define CES1_UWY_NF 3
#define CES1_UW_NT 4
#define CES1_RETCTR_NF 5
#define CES1_RETEND_NT 6
#define CES1_RETSEC_NF 7
#define CES1_RTY_NF 8
#define CES1_RETUW_NT 9
#define CES1_CES1ACCSTA_N 10
#define CES1_CES1ACCEND_N 11
#define CES1_CESSH_R 12
#define CES1_SSD_CF 13
#define CES1_ESB_CF 14
#define CES1_RETCTRCAT_CF 15
#define CES1_ACCADMTYP_CT 16
#define CES1_RETACCADM_B 17
#define CES1_CLECUTPER_B 18
#define CES1_CLECUTPER_NB 19
#define CES1_LOB_CF 20
#define CES1_CUR_CF 21
#define CES1_RETPCPCUR_CF 22
#define CES1_CONRETCTR_B 23
#define CES1_ACCFAM_CT 24
#define CES1_BLCSHTSTR_D 25	// [029] 
#define CES1_BLCSHTEND_D 26	// [029] 
#define CES1_NBCOL 27		// [029] 

/* ______________________________________________________________________________________________  */
/*   J. Ribot 14/02/03                                                                             */
/* le champs suivant CES_RETPCPCUR_CF a ete integre dans la desdription de base du fichier cession */
/*    pour permettre d'ajouter l'indicateur CONRETCTR_B                                            */
/* Champ supplementaire pour generation retrocession (lot 21)                                      */
/*#define CES_RETPCPCUR_CF 22                                                                      */
/*#define CES_NBCOL_PLUS1 23                                                                       */
/* ______________________________________________________________________________________________  */

/* Structure de la liste des mois de fin de periode par contrat */
#define MTH_RETCTR_NF 0
#define MTH_LSTENDMTH_NF 1
#define MTH_RETACCYER_NF 2
#define MTH_NBCOL 3

/* Structure du fichier d'anomalies */

#define ANO_ANOCOD_CF 0
#define ANO_UWGRP_CF 1
#define ANO_CTR_NF 2
#define ANO_SEC_NF 3
#define ANO_UWY_NF 4
#define ANO_ACY_NF 5
#define ANO_ACMTRS_NT 6
#define ANO_PCPCUR_CF 7
#define ANO_SSD_CF 8
#define ANO_NBCOL 9

/* Position des champs du fichier FDETTRS (correspondant a la table TDETTRS */
/* de la base BREF */

#define DETTRS_DETTRS_CF 0
#define DETTRS_CTRSCOD_CF 4


/* Liste des anomalies */

#define A_TraiteParDefaut 1             /* 2032, utilisation du traite/defaut */
#define A_SegmentParDefaut 2            /* 2032, utilisation du seg./defaut */
#define A_TraiteModifie 3               /* 2032, evolution du traite */
#define A_SegmentModifie 4              /* 2032, evolution du segment */
#define A_PasDeTraiteParDefaut 5        /* 2032, ano: traite/defaut absent */
#define A_PasDeSegmentParDefaut 6       /* 2032, ano: segment/defaut absent */
#define A_CribleN 7                     /* 2035, ano: trouve crible N */
#define A_Type1 8                       /* 2035, ano: type comptable = 1 */
#define A_ChmtDev 9                     /* 2035, conversion du montant */
#define A_Lib 10                        /* 2035, liberation (effacee) */
#define A_Type45 11                     /* 2035, ano: trouve type 4 ou 5 */
#define A_SigneComplementAnormal 12     /* 2113, signe et montant incompatible */
#define A_Type2 13                      /* 2137, ano: type comptable = 2 */
#define A_Type3 14                      /* 2035, ano: type comptable = 3 */
#define A_NbAno 15                      /* Nombre de messages d'anomalie */

/* Format du fichier utilise pour l'edition de l'etat synthetique de
controle inventaire acceptation*/
#define     SYNA_SSD_CF     0
#define     SYNA_ESB_CF     1
#define     SYNA_LOB_CF     2
#define     SYNA_CTRNAT_CT  3
#define     SYNA_WRKCAT_CT  4
#define     SYNA_AMT10000_M 5
#define     SYNA_AMT10030_M 6
#define     SYNA_AMT10031_M 7
#define     SYNA_AMT10100_M 8
#define     SYNA_AMT10130_M 9
#define     SYNA_AMT10400_M 10
#define     SYNA_AMT10430_M 11
#define     SYNA_AMT20000_M 12
#define     SYNA_AMT20030_M 13
#define     SYNA_AMT20031_M 14
#define     SYNA_AMT22000_M 15
#define     SYNA_AMT23000_M 16
#define     SYNA_AMT24030_M 17
#define     SYNA_AMT24031_M 18

/* Format du fichier utilise pour l'edition de l'etat synthetique de
controle inventaire retrocession*/
#define     SYNR_SSD_CF     0
#define     SYNR_ESB_CF     1
#define     SYNR_LOB_CF     2
#define     SYNR_CTRNAT_CT  3
#define     SYNR_AMT10000_M 4
#define     SYNR_AMT10030_M 5
#define     SYNR_AMT10031_M 6
#define     SYNR_AMT10100_M 7
#define     SYNR_AMT10130_M 8
#define     SYNR_AMT10200_M 9
#define     SYNR_AMT10430_M 10
#define     SYNR_AMT20000_M 11
#define     SYNR_AMT20030_M 12
#define     SYNR_AMT20031_M 13
#define     SYNR_AMT22000_M 14
#define     SYNR_AMT24030_M 15
#define     SYNR_AMT24031_M 16

/* Position des champs dans le fichier des identifiants */

#define IDENT_CTR_NF 0
#define IDENT_END_NT 1
#define IDENT_SEC_NF 2
#define IDENT_UWY_NF 3
#define IDENT_UW_NT 4

/*Postion des champs dans le fichier de rapprochement */

#define FRAPP_SSD_CF    0
#define FRAPP_ESB_CF    1
#define FRAPP_CTR_NF    2
#define FRAPP_END_NT    3
#define FRAPP_SEC_NF    4
#define FRAPP_UWY_NF    5
#define FRAPP_UW_NT     6
#define FRAPP_RETCTR_NF 7
#define FRAPP_RETEND_NT 8
#define FRAPP_RETSEC_NF 9
#define FRAPP_RTY_NF    10
#define FRAPP_RETUW_NT  11
#define FRAPP_RETCUR_CF 12
#define FRAPP_RETNAT_CF 13     /* Top retrocession Prop / Non Prop */
#define FRAPP_ACRES_M   14     /* Resultat comptable */
#define FRAPP_THRES_M   15     /* Resultat theorique */
#define FRAPP_AMT1_M    16     /* ecart brut */
#define FRAPP_AMT2_M    17     /* ecart de placement sur rejet de retard */
#define FRAPP_AMT3_M    18     /* ecart de change sur rejet de retard */
#define FRAPP_AMT4_M    19     /* ecart de placement sur les comptes */
#define FRAPP_AMT5_M    20     /* ecart de change sur les comptes */
#define FRAPP_AMT6_M    21     /* ecart d'effets retroactifs sur bilans
                                  anterieurs */
#define FRAPP_AMT7_M    22     /* ecart d'ecriture de rachat */
#define FRAPP_AMT8_M    23     /* ecart de versement sur ouvertures
                                  estimations / actualisees / service */
#define FRAPP_AMT9_M    24     /* ecart de placement sur ouvertures
                                  estimations / actualisees / service */
#define FRAPP_AMT10_M   25     /*  ecart de change sur ouvertures
                                  estimations / actualisees / service */
#define FRAPP_AMT11_M   26     /* ecart de commission majoree */
#define FRAPP_AMT12_M   27     /* ecart epure */
#define FRAPP_FIN       28     /* fin */

#define TOUTTRAA_RETCTR_NF 0
#define TOUTTRAA_RTY_NF 1
#define TOUTTRAA_RETSEC_NF 2
#define TOUTTRAA_SSD_CF 3
#define TOUTTRAA_CTR_NF 4
#define TOUTTRAA_END_NT 5
#define TOUTTRAA_SEC_NF 6
#define TOUTTRAA_UW_NT 7
#define TOUTTRAA_UWY_NF 8
#define TOUTTRAA_SCOSTRMTH_NF 9
#define TOUTTRAA_SCOENDMTH_NF 10
#define TOUTTRAA_ACCYER_NF 11
#define TOUTTRAA_BLCSHT_D 12
#define TOUTTRAA_CLM_NF 13
#define TOUTTRAA_TRNCOD_CF 14
#define TOUTTRAA_ACPCUR_CF 15
#define TOUTTRAA_CED_M 16
#define TOUTTRAA_RETACT_CT 17
#define TOUTTRAA_OCCYEA_NF 18

#define TOUTTRAI_SSD_CF 0
#define TOUTTRAI_RETCTR_NF 1
#define TOUTTRAI_RTY_NF 2
#define TOUTTRAI_PLC_NT 3
#define TOUTTRAI_RETSEC_NF 4
#define TOUTTRAI_CTR_NF 5
#define TOUTTRAI_UW_NT 6
#define TOUTTRAI_UWY_NF 7
#define TOUTTRAI_END_NT 8
#define TOUTTRAI_SEC_NF 9
#define TOUTTRAI_RCL_NF 10
#define TOUTTRAI_TRNCOD_CF 11
#define TOUTTRAI_CUR_CF 12
#define TOUTTRAI_TRN_M 13
#define TOUTTRAI_OCCYEA_NF 14
#define TOUTTRAI_COMTRA_B 15
#define TOUTTRAI_ACCYER_NF 16

#define TACCTRAA_RETCTR_NF 0
#define TACCTRAA_RTY_NF 1
#define TACCTRAA_RETSEC_NF 2
#define TACCTRAA_SSD_CF 3
#define TACCTRAA_CTR_NF 4
#define TACCTRAA_END_NT 5
#define TACCTRAA_SEC_NF 6
#define TACCTRAA_UW_NT 7
#define TACCTRAA_UWY_NF 8
#define TACCTRAA_SCOSTRMTH_NF 9
#define TACCTRAA_SCOENDMTH_NF 10
#define TACCTRAA_ACCYER_NF 11
#define TACCTRAA_BLCSHT_D 12
#define TACCTRAA_CLM_NF 13
#define TACCTRAA_TRNCOD_CF 14
#define TACCTRAA_ACPCUR_CF 15
#define TACCTRAA_CED_M 16
#define TACCTRAA_RETACT_CT 17
#define TACCTRAA_OCCYEA_NF 18
#define TACCTRAA_CNVCUR_CF 19
#define TACCTRAA_CNVAMT_M 20
#define TACCTRAA_RETACCYER_NF 21
#define TACCTRAA_ACCTRTCUR_R 22
#define TACCTRAA_ACC_D 23

#define TACCTRAI_SSD_CF 0
#define TACCTRAI_RETCTR_NF 1
#define TACCTRAI_RTY_NF 2
#define TACCTRAI_PLC_NT 3
#define TACCTRAI_RETSEC_NF 4
#define TACCTRAI_CTR_NF 5
#define TACCTRAI_UW_NT 6
#define TACCTRAI_UWY_NF 7
#define TACCTRAI_SEC_NF 8
#define TACCTRAI_END_NT 9
#define TACCTRAI_TRNCOD_CF 10
#define TACCTRAI_CNVCUR_CF 11
#define TACCTRAI_CNVAMT_M 12
#define TACCTRAI_ACC_D 13
#define TACCTRAI_COMTRA_B 14

#define TCMUSPLI_SSD_CF 0
#define TCMUSPLI_RETCTR_NF 1
#define TCMUSPLI_RTY_NF 2
#define TCMUSPLI_RETSEC_NF 3
#define TCMUSPLI_CTR_NF 4
#define TCMUSPLI_UW_NT 5
#define TCMUSPLI_UWY_NF 6
#define TCMUSPLI_SEC_NF 7
#define TCMUSPLI_END_NT 8
#define TCMUSPLI_TRNCOD_CF 9
#define TCMUSPLI_CNVCUR_CF 10
#define TCMUSPLI_CNVAMT_M 11
#define TCMUSPLI_ACC_D 12
#define TCMUSPLI_TOTCMU_R 13

#define TCMUSPLIT_SSD_CF 0
#define TCMUSPLIT_RETCTR_NF 1
#define TCMUSPLIT_RTY_NF 2
#define TCMUSPLIT_RETSEC_NF 3
#define TCMUSPLIT_CTR_NF 4
#define TCMUSPLIT_UW_NT 5
#define TCMUSPLIT_UWY_NF 6
#define TCMUSPLIT_SEC_NF 7
#define TCMUSPLIT_END_NT 8
#define TCMUSPLIT_TRNCOD_CF 9
#define TCMUSPLIT_CNVCUR_CF 10
#define TCMUSPLIT_CNVAMT_M 11
#define TCMUSPLIT_ACC_D 12


/* Position des champs dans le fichier de travail des SNEMs */
#define SEPARATEUR '~'
#define WFS_SSD_CF 0
#define WFS_ESB_CF 1
#define WFS_CLODAT_D 2
#define WFS_CTR_NF 3
#define WFS_END_NT 4
#define WFS_SEC_NF 5
#define WFS_UWY_NF 6
#define WFS_UW_NT 7
#define WFS_SCOGLOEGP_M 8
#define WFS_EGPCUR_CF 9
#define WFS_SPSAPC_M 10
#define WFS_DIFFMTH_NF 11
#define WFS_SNEMEYBP_M 12
#define WFS_SNEMBPCUR_CF 13
#define WFS_SNEMEY_M 14
#define WFS_SNEMCLODAT_M 15
#define WFS_CTRRET_B 16
#define WFS_TOTRAT_R 17


/* Position des champs dans le fichier des montants stats FUNDSTA */
#define UND_CTR_NF    0
#define UND_END_NT    1
#define UND_SEC_NF    2
#define UND_UWY_NF    3
#define UND_UW_NT   4
#define UND_CUR_CF    5
#define UND_CACCPRM_M   6
#define UND_CACCUPR_M   7
#define UND_CACCCLM_M   8
#define UND_CACCACR_M   9
#define UND_CACCLOA_M   10
#define UND_CACCRESPRM_M  11
#define UND_ACCPRM_M    12
#define UND_ACCUPR_M    13
#define UND_ACCCLM_M    14
#define UND_ACCACR_M    15
#define UND_ACCLOA_M    16
#define UND_ACY_NF    17
#define UND_SCOENDMTH_NF  18
#define UND_LSTUPD_D    19

/* SEGPOR */

#define SEGPOR_CTR_NF 0
#define SEGPOR_END_NT 1
#define SEGPOR_SEC_NF 2
#define SEGPOR_SEGTYP_CT 3
#define SEGPOR_SSD_CF 4
#define SEGPOR_CTRNAT_CT 5
#define SEGPOR_CTRRET_B 6
#define SEGPOR_UWY_NF 7


/* PLG 19/10/2009 - Fiche Spot n° 16778 */
/* Constante de paramétrage du fichier de synchro avec les taux de saisonnalité par traité */
#define SINNP_SSD_CF    0
#define SINNP_CTR_NF    1
#define SINNP_END_NT    2
#define SINNP_SEC_NF    3
#define SINNP_UWY_NF    4
#define SINNP_UW_NT     5
#define SINNP_CTREXP_D  6
#define SINNP_TAUX_1    7
#define SINNP_TAUX_2    8
#define SINNP_TAUX_3    9
#define SINNP_TAUX_4    10
/* Fin PLG 19/10/2009 */

/* JBG 24/04/14 - Newbiz pour LIFSTAREP */
#define LIF_CLODAT_D    0
#define LIF_SSD_CF      1
#define LIF_CTR_NF      2
#define LIF_END_NT      3
#define LIF_SEC_NF      4
#define LIF_UWY_NF      5
#define LIF_UW_NT     6
#define LIF_PLC_NT      7
#define LIF_ACCRET_CF   8
#define LIF_ACY_NF      9
#define LIF_ACMTRS_NT   10
#define LIF_CUR_CF      11
#define LIF_CBNMNT_M    12
#define LIF_CBPMNT_M    13
#define LIF_PCMNT_M     14
#define LIF_PAMNT_M     15
#define LIF_PRMNT_M     16
#define LIF_CED_NF      17
#define LIF_SECSTS_CT   18
#define LIF_SECACCSTS_CT  19
#define LIF_ACCADMTYP_CT  20
#define LIF_ESTCRB_CT   21
#define LIF_ESTCTR_NF   22
#define LIF_ESTSEC_NF   23
#define LIF_COMACC_B    24
#define LIF_AUTUPD_B    25
#define LIF_YNEWCTR_B   26
#define LIF_TNEWCTR_B   27
#define LIF_CLMCUTOFF_B   28
#define LIF_PRMCUTOFF_B   29
#define LIF_CLMRUNOFF_B   30
#define LIF_PRMRUNOFF_B   31
#define LIF_LSTUPD_D    32
#define LIF_PAMNTNB_M   33
#define LIF_PRMNTNB_M   34

#define NEW_CTR_NF      0
#define NEW_END_NT      1
#define NEW_SEC_NF      2
#define NEW_ACY_NF      3
#define NEW_ACMTRS_NT   4
#define NEW_CRE_D     5
#define NEW_NEWBIZ_R    6
#define NEW_CREUSR_CF   7

/* [015] */
enum {
  SEG_SSD_CF = 0    //0
  , SEG_SEG_NF    //1
  , SEG_UWY_NF      //2
  , SEG_CUR_CF    //3
  , SEG_SEGNAT_CT   //4
  , SEG_CLMAMT_M    //5
  , SEG_LOSRAT_R    //6
  , SEG_AMORAT_CT   //7
  , SEG_ACY_NF    //8
};

/* Fin JBG 24/04/14 */

/* Structure de stockage du fichier des segments d'analyse */

typedef struct {
  unsigned char      SSD_CF;
  short     UWGRP_CF;
  char         ANLCTY_CF[4];
  char         CLINAT_CF[4];
  unsigned char      ORDNBR_NT;
  char         SEG_NF[11];
} T_SEGPAR;


/* Structure de stockage du fichier des traites de rattachement */

typedef struct {
  unsigned char      SSD_CF;
  char         LIFTRTTYP_CF[3];
  short     UWGRP_CF;
  char         ANLCTY_CF[4];
  char         ESTCTR_NF[10];
  int           CED_NF;             // 20100609 TRIPERT : SPOT 19101 : Ajout la cedante */
  unsigned char      ESB_CF;        //[023]
} T_CTRFIC;


/* Structure de stockage du fichier de pilotage */
typedef struct {
  char         CTR_NF[10];
  unsigned char      END_NT;
  unsigned char      SEC_NF;
  short     UWY_NF;
  unsigned char      UW_NT;
  short     ACY_NF;
  unsigned char      SSD_CF;
  short     BALSHEY_NF;
  unsigned char      BALSHTMTH_NF;
  unsigned char          AUTUPD_B;
  unsigned char          COMACC_B;
  char         CRE_D[18];
  char         UPD_NF;
  int          CMT_NT;
  char         CREUSR_CF[5];
  char         LSTUPD_D[50];
  char         LSTUPDUSR_CF[5];
} T_LIFDRI;

/* Structure de stockage du fichier de pilotage */
typedef struct {
  char          CTR_NF[10];
  unsigned char   END_NT;
  unsigned char   SEC_NF;
  short         UWY_NF;
  unsigned char   UW_NT;
  short         ACY_NF;
  unsigned char   SSD_CF;
  short         BALSHEY_NF;
  unsigned char BALSHTMTH_NF;
  unsigned char AUTUPD_B;
  unsigned char COMACC_B;
  unsigned char   PROPAG_RES_B;
  unsigned char   SEGUPD_B;
  char         CRE_D[18];
  char         UPD_NF;
  int          CMT_NT;
  char         CREUSR_CF[5];
  char         LSTUPD_D[50];
  char         LSTUPDUSR_CF[5];
} T_LIFDRI_ALL;

/* Structure de stockage du fichier de pilotage detail*/
typedef struct {
  char          CTR_NF[10];
  unsigned char   END_NT;
  unsigned char   SEC_NF;
  short         UWY_NF;
  unsigned char   UW_NT;
  short         ACY_NF;
  unsigned char ACM_NF;
  unsigned char   SSD_CF;
  short         BALSHEY_NF;
  unsigned char BALSHTMTH_NF;
  unsigned char AUTUPD_B;
  unsigned char COMACC_B;
  unsigned char   PROPAG_RES_B;
  unsigned char   SEGUPD_B;
  char         CRE_D[18];
  char         UPD_NF;
  int          CMT_NT;
  char         CREUSR_CF[5];
  char         LSTUPD_D[50];
  char         LSTUPDUSR_CF[5];
} T_LIFDRI_ALL_QUARTER;

typedef struct {
  char            CLODAT_D[9];
  char            CTR_NF[10];
  int             END_NT;
  int             SEC_NF;
  int             UWY_NF;
  int             UW_NT;
  int             ACY_NF;
  int             SCOSTRMTH_NF;
  int             SCOENDMTH_NF;
  int             UWYDIS_NF;
  int             SSD_CF;
  char            WFCOD_NT[6];
  char            WFTYP_CF;
  char            EGPCUR_CF[4];
  double          PRM_M;
  double          PPNAC_M;
  double          PPNAEA_M;
  double          RPPC_M;
  double          RPPEA_M;
  double          LPPNAC_M;
  double          EPPC_M;
  double          EPPEA_M;
  double          RECC_M;
  double          RECE_M;
  double          BCC_M;
  double          BCE_M;
  double          SHR_R;
  int             ACCADMTYP_CT;
} T_FT ;


typedef struct {
  char    TRSPFX_CF;
  short   ACMTRSL0_NT;
  short   ACMTRSL1_NT;
  short   ACMTRSL2_NT;
  short   ACMTRSL3_NT;
  short   ACMTRSLL1_NT;
  short   ACMTRSLL2_NT;
  short   TRSTYP_NT;
  char        DETTRS_CF[9];
  char        PCPTRS_CF[3];
  char        TRS_CF;
  char        SUBTRS_CF[3];
  short       ESTIM_NT;
  short       TRNTYP_CT;
} T_FBOTRSLNK;


typedef struct {
  unsigned char   SSD_CF ;
  char            CLODAT_D[9] ;
  unsigned char   FSTWAY_B ;
} T_LISTESSD ;

typedef struct {
  short     PRS_CF ;
  char    TRNCOD_CF[9] ;
  char    DETTRS_CF[9] ;
} T_RETPAR ;

typedef struct {
  char    RETCTR_NF[10] ;
  short         RTY_NF ;
  int   PLC_NT ;
  unsigned char RETSEC_NF ;
  unsigned char SSD_CF ;
  char            CTR_NF[10] ;
  short           UWY_NF ;
  unsigned char UW_NT ;
  unsigned char   SEC_NF ;
  unsigned char   END_NT ;
  int   CLISSD_NF ;
  unsigned char RTOSSD_CF ;
} T_SSDACTR ;

typedef struct {
  int   CLI_NF ;
  int   CLISSD_NF ;
} T_TCLIENT;


typedef struct {
  char    LOB_CF[3] ;
  char    SOB_CF[3] ;
  char    PRDCOD_CT[4] ;
} T_SOBBLOB ;

typedef struct {
  int   VRS_NF ;
  unsigned char SSD_CF ;
  char    SEGTYP_CT ;
  char    SEG_NF[11] ;
  char    CUR_CF[4] ;
  char    SEGNAT_CT ;
} T_SEGMENT ;

/*typedef struct  {
CS_TINYINT SSD_CF;
short ESB_CF;
typedef struct  {
CS_TINYINT SSD_CF;
CS_TINYINT ESB_CF; */

typedef struct  {
  unsigned char SSD_CF;
  unsigned char  ESB_CF;
  char    CUR_CF[4];
  double  AMT_M;
} T_LIFTHR;

typedef struct  {
  char    c_SSD_CF;
  short   s_ACMTRS_NT;
  char    sz_ACMTRS_LS[20];
} T_ACMTRS;

typedef struct  {
  char    c_SSD_CF;
  char    sz_LIB[17];
  char    sz_LAG_CF[2];
} T_SUBSID;

typedef struct  {
  char    sz_LAG_CF[2];
  int     n_COLVAL_CT;
  char    sz_COLVAL_LM[33];
} T_BANTECL;

typedef struct  {
  short   s_GRP_CF;
  char    c_SSD_CF;
  char    sz_GRP_LS[17];
} T_GRP;


#define MAXROW_SUBSID   100
#define MAXROW_ACMTRS   4000           /*  27/03/2008   J. Ribot    SPOT 15219 ASE15 : recompilation des programmes C  passe a 1500 pour ESTR203A */
/*  17/10/2008   JFVDV       SPOT 16230 Augmentation de la taille du tableau T_ACMTRS pour ESTR203A, passage de 1 500 à 4 000 lignes et recompilation des programmes C */
#define MAXROW_BANTECL  10000
#define MAXROW_GRP   1000



/* Structure de stockage du fichier de rapprochement */

typedef struct {
  unsigned char      SSD_CF;
  unsigned char      ESB_CF;
  char         CTR_NF[10];
  unsigned char      END_NT;
  unsigned char      SEC_NF;
  short     UWY_NF;
  unsigned char      UW_NT;
  char         RETCTR_NF[10];
  unsigned char      RETEND_NT;
  unsigned char      RETSEC_NF;
  short     RTY_NF;
  unsigned char      RETUW_NT;
  char         RETCUR_CF[4];
  char         RETNAT_CF;
  double        ACRES_M;
  double        THRES_M;
  double        AMT1_M;
  double        AMT2_M;
  double        AMT3_M;
  double        AMT4_M;
  double        AMT5_M;
  double        AMT6_M;
  double        AMT7_M;
  double        AMT8_M;
  double        AMT9_M;
  double        AMT10_M;
  double        AMT11_M;
  double        AMT12_M;
} T_FRAPP;

typedef struct {
  char    c_SSD_CF;
  short   s_Deb ;
  short   s_Fin ;
} T_RETSEC_SSD ;

typedef struct {
  char    c_SSD_CF;
  short   s_RTY_NF;
  short   s_Deb ;
  short   s_Fin ;
} T_RETSEC_SSD_RTY ;

typedef struct {
  char    c_SSD_CF;
  short   s_RTY_NF;
  char    sz_RETCTR_NF[10] ;
  char    c_RETSEC_NF ;
  char    c_RETEND_NT ;
  char    c_RETUW_NT ;
} T_RETSEC ;

typedef struct {
  int             VRS_NF ;
  unsigned char   SSD_CF ;
  char            SEGTYP_CT ;
  char            SEG_NF[11] ;
  short           UWY_NF ;
  char            CRE_D[9] ;
  char            CUR_CF[4] ;
  double          PRMAMT_M ;
  double          CLMAMT_M ;
  double          LOSRAT_R ;
  char            AMORAT_CT ;
} T_SEGEST ;

typedef struct {
  int       SSD_CF ;
  char      SEG_NF[11] ;
  short     UWY_NF ;
  char      CUR_CF[4] ;
  char      SEGNAT_CT ;
  double    CLMAMT_M ;
  double    LOSRAT_R ;
  char      AMORAT_CT ;
  char      SEGTYP_CT ; // [034] JYP IFRS17 req 10.6
} T_SEGEST_SOLVENCY ;

/* Ajout JBG pour ESTC1055 */
typedef struct {
  char            RETCTR_NF[10];
  int             RETSEC_NF;
  int             RETRTY_NF;
  char            RETPLC_NT[10];
  double          RETAMT_M;
  double      RETTOT_M;
} T_FPLATRET;

/* Ajout JBG pour NEWBIZ */
typedef struct {
  char      CLODAT_D[18];
  short     SSD_CF;
  char      CTR_NF[10];
  short     END_NT;
  short     SEC_NF;
  int       UWY_NF;
  short     UW_NT;
  short     PLC_NT;
  unsigned char ACCRET_CF;
  int       ACY_NF;
  int       ACMTRS_NT;
  char      CUR_CF[4];
  double      CBNMNT_M;
  double      CBPMNT_M;
  double      PCMNT_M;
  double      PAMNT_M;
  double      PRMNT_M;
  int       CED_NF;
  short     SECSTS_CT;
  short     SECACCSTS_CT;
  short     ACCADMTYP_CT;
  unsigned char ESTCRB_CT;
  char      ESTCTR_NF[10];
  short     ESTSEC_NF;
  unsigned char COMACC_B;
  unsigned char AUTUPD_B;
  unsigned char YNEWCTR_B;
  unsigned char TNEWCTR_B;
  unsigned char CLMCUTOFF_B;
  unsigned char PRMCUTOFF_B;
  unsigned char CLMRUNOFF_B;
  unsigned char PRMRUNOFF_B;
  char      LSTUPD_D[18];
  double      PAMNTNB_M;
  double      PRMNTNB_M;
} T_FSTAREP;

/* Structure de stockage du fichier de NEWBIZ */
#define NB_CTR_NF           0
#define NB_END_NT           1
#define NB_SEC_NF           2
#define NB_ACY_NF           3
#define NB_ACMTRS_NT        4
#define NB_CRE_D            5
#define NB_NEWBIZ_R         6
#define NB_CREUSR_CF        7
#define NB_NBCOL            8

/* [040] Declaration des Positions des champs dans le perimetre additionnel */
#define PER_ADDI_SEPARATOR     '~'
#define PER_ADDI_SSD_CF         0
#define PER_ADDI_CTR_NF         1
#define PER_ADDI_END_NT         2
#define PER_ADDI_SEC_NF         3
#define PER_ADDI_UWY_NF         4
#define PER_ADDI_UW_NT          5
#define PER_ADDI_CLMFUNVARINT_B 6
#define PER_ADDI_CLMFUNESTINT_R 7
#define PER_ADDI_URRFUNVARINT_B 8
#define PER_ADDI_URRFUNESTINT_R 9
#define PER_ADDI_ANNFUNVARINT_B 10
#define PER_ADDI_ANNFUNCAS_R    11
#define PER_ADDI_ANNFUNESTINT_R 12
#define PER_ADDI_LIFRESVARINT_B 13
#define PER_ADDI_LIFRESCAS_R    14
#define PER_ADDI_LIFRESINT_R    15
#define PER_ADDI_LIFRESESTINT_R 16
#define PER_ADDI_ANNFUN_R       17
#define PER_ADDI_LIFRES_R       18
#define PER_ADDI_CHAMP_LIBRE_03 19 -- un champ suplÃ©mentaire libre
#define PER_ADDI_CHAMP_LIBRE_04 20 -- un champ suplÃ©mentaire libre
#define PER_ADDI_CHAMP_LIBRE_05 21
#define PER_ADDI_CHAMP_LIBRE_06 22
#define PER_ADDI_CHAMP_LIBRE_07 23
#define PER_ADDI_CHAMP_LIBRE_08 24
#define PER_ADDI_CHAMP_LIBRE_09 25
#define PER_ADDI_CHAMP_LIBRE_10 26
#define PER_ADDI_CHAMP_LIBRE_11 27
#define PER_ADDI_CHAMP_LIBRE_12 28
#define PER_ADDI_CHAMP_LIBRE_13 29
#define PER_ADDI_CHAMP_LIBRE_14 30
#define PER_ADDI_CHAMP_LIBRE_15 31
#define PER_ADDI_CHAMP_LIBRE_16 32
#define PER_ADDI_CHAMP_LIBRE_17 33
#define PER_ADDI_CHAMP_LIBRE_18 34
#define PER_ADDI_CHAMP_LIBRE_19 35
#define PER_ADDI_CHAMP_LIBRE_20 36
#define PER_ADDI_CHAMP_LIBRE_21 37
#define PER_ADDI_CHAMP_LIBRE_22 38
#define PER_ADDI_CHAMP_LIBRE_23 39
#define PER_ADDI_CHAMP_LIBRE_24 40
#define PER_ADDI_CHAMP_LIBRE_25 41
#define PER_ADDI_CHAMP_LIBRE_26 42
#define PER_ADDI_CHAMP_LIBRE_27 43
#define PER_ADDI_CHAMP_LIBRE_28 44
#define PER_ADDI_CHAMP_LIBRE_29 45
#define PER_ADDI_CHAMP_LIBRE_30 46
#define PER_ADDI_CHAMP_LIBRE_31 47
#define PER_ADDI_CHAMP_LIBRE_32 48
#define PER_ADDI_CHAMP_LIBRE_33 49
#define PER_ADDI_CHAMP_LIBRE_34 50
#define PER_ADDI_CHAMP_LIBRE_35 51
#define PER_ADDI_CHAMP_LIBRE_36 52
#define PER_ADDI_CHAMP_LIBRE_37 53
#define PER_ADDI_CHAMP_LIBRE_38 54
#define PER_ADDI_CHAMP_LIBRE_39 55
#define PER_ADDI_CHAMP_LIBRE_40 56
#define PER_ADDI_CHAMP_LIBRE_41 57
#define PER_ADDI_CHAMP_LIBRE_42 58
#define PER_ADDI_CHAMP_LIBRE_43 59
#define PER_ADDI_CHAMP_LIBRE_44 60
#define PER_ADDI_CHAMP_LIBRE_45 61
#define PER_ADDI_CHAMP_LIBRE_46 62
#define PER_ADDI_CHAMP_LIBRE_47 63
#define PER_ADDI_CHAMP_LIBRE_48 64
#define PER_ADDI_CHAMP_LIBRE_49 65
#define PER_ADDI_CHAMP_LIBRE_50 66
#define PER_ADDI_CHAMP_LIBRE_51 67
#define PER_ADDI_CHAMP_LIBRE_52 68
#define PER_ADDI_CHAMP_LIBRE_53 69

#define PER_ADDI_NBCOL		70
/* [040] Fin de la declaration des positions des champs de perimetre additionnel */


#endif /* __STRUCT */


/*[045] BEGIN 23/07/2020 copy of structA*/
typedef struct {
  short     PRS_CF;
  short		ACMTRS_NT;
  char		PARM1[32];
  char		PARM2[32];
  char		PARM3[32];
  char		PARM4[32];
  char		PARM5[32];
  char		PARM6[32];
  char		PARM7[32];
  char		PARM8[32];
  char		PARM9[32];
  char		PARM10[32];
} T_TMAPPING;

typedef struct {
  char    TRSPFX_CF;
  short   ACMTRSL0_NT;
  short   ACMTRSL1_NT;
  short   ACMTRSL2_NT;
  short   ACMTRSL3_NT;
  short   ACMTRSLL1_NT;
  short   ACMTRSLL2_NT;
  short   TRSTYP_NT;
  char        DETTRS_CF[9];
  char        PCPTRS_CF[3];
  char        TRS_CF;
  char        SUBTRS_CF[3];
  short       ESTIM_NT;
  short       TRNTYP_CT;
} T_FBOPRSLNK;


typedef struct {
short SSD_CF;
char CTR_NF[10];
short END_NT;
short SEC_NF;
int UWY_NF;
short UW_NT;
char CUR_CF[4];	
char RETCTR_NF[10];
short RETEND_NT;
short RETSEC_NF;
int RTY_NF;
short RETUW_NT;	
char RETCUR_CF[4];
double RETAMT_M;
short PLC_NT;
int RTO_NF;
int ACMTRS_NT;
double ACMAMT_M;
char ACCRET[1];
char NORME[6];   
char PATCAT_CT[4]; 
char PATTYP_CT[4];
//double Amt[64];
double TOTAUX;
} T_DldSIIGT;	


typedef struct {
	long key;
	int count;
	int index[150];	
} T_DATAMAP;
/*END 23/07/2020 copy of structA*/

// [048]
#define FTTECLEDA_SSD_CF 0
#define FTTECLEDA_ESB_CF 1
#define FTTECLEDA_BALSHEY_NF 2
#define FTTECLEDA_BALSHRMTH_NF 3
#define FTTECLEDA_BALSHRDAY_NF 4
#define FTTECLEDA_TRNCOD_CF 5
#define FTTECLEDA_DBLTRNCOD_CF 6
#define FTTECLEDA_CTR_NF 7
#define FTTECLEDA_END_NT 8
#define FTTECLEDA_SEC_NF 9
#define FTTECLEDA_UWY_NF 10
#define FTTECLEDA_UW_NT 11
#define FTTECLEDA_OCCYEA_NF 12
#define FTTECLEDA_ACY_NF 13
#define FTTECLEDA_SCOSTRMTH_NF 14
#define FTTECLEDA_SCOENDMTH_NF 15
#define FTTECLEDA_CLM_NF 16
#define FTTECLEDA_CUR_CF 17
#define FTTECLEDA_AMT_M 18
#define FTTECLEDA_CED_NF 19
#define FTTECLEDA_BRK_NF 20
#define FTTECLEDA_PAY_NF 21
#define FTTECLEDA_KEY_NF 22
#define FTTECLEDA_RETCTR_NF 23
#define FTTECLEDA_RETEND_NT 24
#define FTTECLEDA_RETSEC_NF 25
#define FTTECLEDA_RTY_NF 26
#define FTTECLEDA_RETUW_NT 27
#define FTTECLEDA_RETOCCYEA_NF 28
#define FTTECLEDA_RETACY_NF 29
#define FTTECLEDA_RETSCOSTRMTH_NF 30
#define FTTECLEDA_RETSCOENDMTH_NF 31
#define FTTECLEDA_RCL_NF 32
#define FTTECLEDA_RETCUR_CF 33
#define FTTECLEDA_RETAMT_M 34
#define FTTECLEDA_PLC_NT 35
#define FTTECLEDA_RTO_NF 36
#define FTTECLEDA_INT_NF 37
#define FTTECLEDA_RETPAY_NF 38
#define FTTECLEDA_RETKEY_CF 39
#define FTTECLEDA_CRE_D 40
#define FTTECLEDA_CREUSR_CF 41
#define FTTECLEDA_LSTUPD_D 42
#define FTTECLEDA_LSTUPDUSR_CF 43
#define FTTECLEDA_LOBACC_CF 44
#define FTTECLEDA_LOBRET_CF 45
#define FTTECLEDA_SOBACC_CF 46
#define FTTECLEDA_SOBRET_CF 47
#define FTTECLEDA_TOPACC_CF 48
#define FTTECLEDA_TOPRET_CF 49
#define FTTECLEDA_NATACC_CF 50
#define FTTECLEDA_NATRET_CF 51
#define FTTECLEDA_GARACC_CF 52
#define FTTECLEDA_GARRET_CF 53
#define FTTECLEDA_PCPRSKTRYACC_CF 54
#define FTTECLEDA_PCPRSKTRYRET_CF 55
#define FTTECLEDA_USRCRTCODACC_CT 56
#define FTTECLEDA_USRCRTCODRET_CT 57
#define FTTECLEDA_USRCRTVALACC_LM 58
#define FTTECLEDA_USRCRTVALRET_LM 59
#define FTTECLEDA_CTRNAT_CT 60
#define FTTECLEDA_RETCTRCAT_CF 61
#define FTTECLEDA_WRKCAT_CT 62
#define FTTECLEDA_PRDCOD_CT 63
#define FTTECLEDA_ANLCTY_CF 64
#define FTTECLEDA_ACCADMTYP_CT 65
#define FTTECLEDA_RETACCTYP_CT 66
#define FTTECLEDA_COMACC_B 67
#define FTTECLEDA_CPLACCUPD_D 68
#define FTTECLEDA_CTRRET_B 69
#define FTTECLEDA_UWGRP_CF 70
#define FTTECLEDA_VRS_NF 71
#define FTTECLEDA_SEG_NF 72
#define FTTECLEDA_UWORG_CF 73
#define FTTECLEDA_ESTCRB_CT 74
#define FTTECLEDA_ESTCTR_NF 75
#define FTTECLEDA_ESBACC_NF 76
#define FTTECLEDA_ORGCED_NF 77
#define FTTECLEDA_CEDHORDNBR_NT 78
#define FTTECLEDA_CEDSORDNBR_NT 79
#define FTTECLEDA_ORGCEDHORDNBR_NT 80
#define FTTECLEDA_ORGCEDSORDNBR_NT 81
#define FTTECLEDA_BRKHORDNBR_NT 82
#define FTTECLEDA_BRKSORDNBR_NT 83
#define FTTECLEDA_FACADMTYP_CT 84
#define FTTECLEDA_CLIIND_NF 85
#define FTTECLEDA_HORDNBR_NT 86
#define FTTECLEDA_RETINTAMT_M 87
#define FTTECLEDA_BUKRS_CF 88        //les 14 colonnes du ONEGL de SAP
#define FTTECLEDA_RCOMP_CF 89
#define FTTECLEDA_LDGRP_CF 90
#define FTTECLEDA_HKONT_CF 91
#define FTTECLEDA_DBLHKONT_CF 92
#define FTTECLEDA_GJAHR_NF 93
#define FTTECLEDA_MONAT_NF 94
#define FTTECLEDA_VBUND_CF 95
#define FTTECLEDA_ZZCED_NF 96
#define FTTECLEDA_SEGMENT_CF 97
#define FTTECLEDA_BEWAR_CF 98
#define FTTECLEDA_ZZGAAPDIF_CF 99
#define FTTECLEDA_BLART_CF 100
#define FTTECLEDA_ZZRECONKEY_CF 101
#define FTTECLEDA_TRN_NT 102          //ajout des nouvelles colonnes du GT: 16 colonnes
#define FTTECLEDA_ORICOD_LS 103
#define FTTECLEDA_RETROAUTO_B 104
#define FTTECLEDA_SPEENTNAT_CF 105
#define FTTECLEDA_EVT_CF 106
#define FTTECLEDA_REVT_CF 107
#define FTTECLEDA_RETARDRETINT_B 108
#define FTTECLEDA_NEWCOLS1_NF 109
#define FTTECLEDA_GAAPCOD_NT 110
#define FTTECLEDA_I17PRDCOD_CT 111
#define FTTECLEDA_NEWCOLS4_NF 112
#define FTTECLEDA_NEWCOLS5_NF 113
#define FTTECLEDA_NEWCOLS6_NF 114
#define FTTECLEDA_NEWCOLS7_NF 115
#define FTTECLEDA_NEWCOLS8_NF 116
#define FTTECLEDA_NEWCOLS9_NF 117
#define FTTECLEDA_NB_COL 118

#define FTTECLEDR_SSD_CF 0
#define FTTECLEDR_ESB_CF 1
#define FTTECLEDR_BALSHEY_NF 2
#define FTTECLEDR_BALSHRMTH_NF 3
#define FTTECLEDR_BALSHRDAY_NF 4
#define FTTECLEDR_TRNCOD_CF 5
#define FTTECLEDR_DBLTRNCOD_CF 6
#define FTTECLEDR_CTR_NF 7
#define FTTECLEDR_END_NT 8
#define FTTECLEDR_SEC_NF 9
#define FTTECLEDR_UWY_NF 10
#define FTTECLEDR_UW_NT 11
#define FTTECLEDR_OCCYEA_NF 12
#define FTTECLEDR_ACY_NF 13
#define FTTECLEDR_SCOSTRMTH_NF 14
#define FTTECLEDR_SCOENDMTH_NF 15
#define FTTECLEDR_CLM_NF 16
#define FTTECLEDR_CUR_CF 17
#define FTTECLEDR_AMT_M 18
#define FTTECLEDR_CED_NF 19
#define FTTECLEDR_BRK_NF 20
#define FTTECLEDR_PAY_NF 21
#define FTTECLEDR_KEY_NF 22
#define FTTECLEDR_RETCTR_NF 23
#define FTTECLEDR_RETEND_NT 24
#define FTTECLEDR_RETSEC_NF 25
#define FTTECLEDR_RTY_NF 26
#define FTTECLEDR_RETUW_NT 27
#define FTTECLEDR_RETOCCYEA_NF 28
#define FTTECLEDR_RETACY_NF 29
#define FTTECLEDR_RETSCOSTRMTH_NF 30
#define FTTECLEDR_RETSCOENDMTH_NF 31
#define FTTECLEDR_RCL_NF 32
#define FTTECLEDR_RETCUR_CF 33
#define FTTECLEDR_RETAMT_M 34
#define FTTECLEDR_PLC_NT 35
#define FTTECLEDR_RTO_NF 36
#define FTTECLEDR_INT_NF 37
#define FTTECLEDR_RETPAY_NF 38
#define FTTECLEDR_RETKEY_CF 39
#define FTTECLEDR_CRE_D 40
#define FTTECLEDR_CREUSR_CF 41
#define FTTECLEDR_LSTUPD_D 42
#define FTTECLEDR_LSTUPDUSR_CF 43
#define FTTECLEDR_LOBRET_CF 44
#define FTTECLEDR_SOBRET_CF 45
#define FTTECLEDR_TOPRET_CF 46
#define FTTECLEDR_NATRET_CF 47
#define FTTECLEDR_GARRET_CF 48
#define FTTECLEDR_PCPRSKTRYRET_CF 49
#define FTTECLEDR_USRCRTCODRET_CT 50
#define FTTECLEDR_USRCRTVALRET_LM 51
#define FTTECLEDR_RETCTRCAT_CF 52
#define FTTECLEDR_RETACCTYP_CT 53
#define FTTECLEDR_SSDRTO_B 54
#define FTTECLEDR_TRN_NT 55           //ajout des nouvelles colonnes du GT: 16 colonnes
#define FTTECLEDR_ORICOD_LS 56
#define FTTECLEDR_RETROAUTO_B 57
#define FTTECLEDR_SPEENTNAT_CF 58
#define FTTECLEDR_EVT_CF 59
#define FTTECLEDR_REVT_CF 60
#define FTTECLEDR_RETARDRETINT_B 61
#define FTTECLEDR_NEWCOLS1_NF 62
#define FTTECLEDR_GAAPCOD_NT 63
#define FTTECLEDR_I17PRDCOD_CT 64
#define FTTECLEDR_NEWCOLS4_NF 65
#define FTTECLEDR_NEWCOLS5_NF 66
#define FTTECLEDR_NEWCOLS6_NF 67
#define FTTECLEDR_NEWCOLS7_NF 68
#define FTTECLEDR_NEWCOLS8_NF 69
#define FTTECLEDR_NEWCOLS9_NF 70
#define FTTECLEDR_NB_COL 71

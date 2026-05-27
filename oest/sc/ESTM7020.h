
//  11/01/2010  Roger Cassis      :spot:18415 -> Ajout transfert fichier Plan_Vie.
// [002] 19/08/2015 Roger Cassis :spot:29223 Evol du modele de la table TLIFSTAREP

/*------------------------------------------------------*/
/* description du fichier de données TRFCROSSREF        */
/*------------------------------------------------------*/

#define TRF_SSD_CF         0
#define TRF_CTR_NF         1
#define TRF_DESTSSD_CF     2
#define TRF_DESTCTR_NF     3

/*------------------------------------------------------*/
/* description du fichier de données LIFSTAREP_PLAN     */
/*------------------------------------------------------*/
// [002]
#define LSR_CLODAT_D       0
#define LSR_SSD_CF         1
#define LSR_CTR_NF         2
#define LSR_END_NT         3
#define LSR_SEC_NF         4
#define LSR_UWY_NF         5
#define LSR_UW_NT          6
#define LSR_PLC_NT         7
#define LSR_ACCRET_CF      8
#define LSR_ACY_NF         9
#define LSR_ACMTRS_NT     10
#define LSR_DETTRNCOD_CF  11 /*Ajout Poste Détail : poste à 5 carac */
#define LSR_ESTMTH_NF     12 // =13
#define LSR_PCPCUR_CF     13
#define LSR_CBNMNT_M      14
#define LSR_CBPMNT_M      15

#define LSR_PC1MNT_M      16
#define LSR_PCMNT_M       17 // GAAP 2
#define LSR_PC3MNT_M      18 // GAAP 3
#define LSR_PC4MNT_M      19 // GAAP 4
#define LSR_PC5MNT_M      20 // GAAP 5

#define LSR_PA1MNT_M      21
#define LSR_PAMNT_M       22 // GAAP 2
#define LSR_PA3MNT_M      23 // GAAP 3
#define LSR_PA4MNT_M      24 // GAAP 4
#define LSR_PA5MNT_M      25 // GAAP 5

#define LSR_PR1MNT_M      26
#define LSR_PRMNT_M       27 // GAAP 2
#define LSR_PR3MNT_M      28 // GAAP 3
#define LSR_PR4MNT_M      29 // GAAP 4
#define LSR_PR5MNT_M      30 // GAAP 5

#define LSR_CED_NF        31
#define LSR_SECSTS_CT     32
#define LSR_SECACCSTS_CT  33
#define LSR_ACCADMTYP_CT  34
#define LSR_ESTCRB_CT     35
#define LSR_ESTCTR_NF     36
#define LSR_ESTSEC_NF     37
#define LSR_COMACC_B      38
#define LSR_AUTUPD_B      39
#define LSR_YNEWCTR_B     40
#define LSR_TNEWCTR_B     41
#define LSR_CLMCUTOFF_B   42
#define LSR_PRMCUTOFF_B   43
#define LSR_CLMRUNOFF_B   44
#define LSR_PRMRUNOFF_B   45
#define LSR_LSTUPD_D      46
#define LSR_CTRINC_D      47
#define LSR_TRNCOD        48 /* SPOT ..... */
#define LSR_ORICTR_NF     49 /* Ajout des champs de la structure LIFEST (3 champs qui suivent) */
#define LSR_ORISEC_NF     50
#define LSR_ORIUWY_NF     51
#define LSR_PAMNTNB_M     52 /* Prevision annuelle pr  new business */
#define LSR_PRMNTNB_M     53 /* Montant Plan pr new business */
#define LSR_SSDRTO_B      54 /*boolean (Mn retro != 0 set à 1 else 0 */
#define LSR_PROPAG_B      55
#define LSR_EXEPLAN_CF    56
#define LSR_VSRPLAN_CF    57
#define LSR_ECRPLANPO1_MC 58
#define LSR_ECRPLANPO2_MC 59
#define LSR_ECRPLANPO3_MC 60
#define LSR_ECRPLANPO4_MC 61
#define LSR_ECRPLANPO5_MC 62

#define LSR_NBCOL         63 


/*==============================================================================
historique des modifications :
[001] 16/01/2012 Roger Cassis  :spot:23189  - Augmentation de la taille du tableau des familles de charges NB_FAM_MAX de 90 a 500
[002] 11/05/2018 M.NAJI  M.NAJI :SPIRA:61503  Calculation of Taxes (using a new "Based On" field added on TRT) 
[003] 15/10/2025 MZM : US 5637 Fix ITK : Augmentation de NB_FAM_MAX de 500 A 1000
[003 22/01/2026 MZM : US 7847 Fix ITK : Augmentation de NB_FAM_MAX de 500 A 1000 dans (ESTC1016.h)
==============================================================================*/

 /* nombre de postes maxi du tableau des familles de charges iterees Ktbd_FamCha */

#define NB_FAM_MAX	1000

 /* definition de la position des champs du fichier des Taux statistiques */

#define URR_CTR_NF 	0
#define URR_UWY_NF	1
#define URR_UW_NT	2
#define URR_END_NT	3
#define URR_SEC_NF	4
#define URR_DAC1_R	5
#define URR_DAC2_R	6
#define URR_ACY_NF	7
#define URR_LSTUPD_D	8
#define URR_LSTUPDUSR_CF 9

 /* nombre de colonnes de la tables des taux de charges */

#define NB_COL_LOARAT	10

 /* definition de la position des champs du fichier des taux de charges */

#define LOA_CTR_NF 	0
#define LOA_END_NT	1
#define LOA_SEC_NF	2
#define LOA_UWY_NF	3
#define LOA_UW_NT	4
#define LOA_SSD_CF	5
#define LOA_COMMIS_R	6
#define LOA_OVECOM_R	7
#define LOA_TAX_R	8
#define LOA_BROKER_R	9
#define LOA_TAXWO_R	10  //[002] spot 61503

/* nombre de colonnes de la tables des Estimations dommages */


#define NB_COL_CTREST	21

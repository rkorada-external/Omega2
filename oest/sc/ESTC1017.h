/*==============================================================================
historique des modifications :
[001] 11/05/2018 M.NAJI  M.NAJI :SPIRA:61503  Calculation of Taxes (using a new "Based On" field added on TRT) 
==============================================================================*/

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
#define LOA_TAXWO_R	10  //[001] spot 61503


 /* nombre de colonne du fichier des montants de primes et charges */

#define NB_COL_PRMLOA	12

 /* definition de la position des champs du fichier des montants de primes et charges */

#define PRMLOA_CTR_NF 		0
#define PRMLOA_END_NT		1
#define PRMLOA_SEC_NF		2
#define PRMLOA_UWY_NF		3
#define PRMLOA_UW_NT		4
#define PRMLOA_PRS_CF		5
#define PRMLOA_ACMTRS_NT	6
#define PRMLOA_SSD_CF		7
#define PRMLOA_CUR_CF		8
#define PRMLOA_RECACC_M		9
#define PRMLOA_ESTACC_M		10
#define PRMLOA_RESERV_M		11


 /* nombre de poste du tableau des montants GT */

#define AMT_NBPOSTE		13 

 /* nombre de poste du tableau des complements */

#define COMP_NBPOSTE		13

/* definition des noms de colonnes des tableaux Ktd_Amt et Ktd_Comp */

#define Charge_EPP		0
#define Taxe_EPP		1
#define Courtage_EPP		2
#define ChargeCom_PRM		3
#define ChargeSurCom_PRM	4
#define Taxe_PRM		5
#define Courtage_PRM		6
#define ChargeTaxe_PPNA 	7
#define Courtage_PPNA		8
#define Charge_RPP		9
#define Taxe_RPP		10
#define Courtage_RPP		11
#define Courtage_REC		12


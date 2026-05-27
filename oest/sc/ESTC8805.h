
 /* 
 ------------------------------------------------------------------------
         definition de la position des champs du fichier TVENTNP 
 ------------------------------------------------------------------------
 date de creation              : 11/05/2004
 auteur                        : M. DJELLOULI
 references des specifications : SPOT 10103 

[001] 27/01/2019   KBAGWE	: spira 79904 : EBS - TNR - Funds Held discrepancies
 ------------------------------------------------------------------------
 */

#define VENT_RETCTR_NF    0
#define VENT_RTY_NF       1
#define VENT_RETSEC_NF    2
#define VENT_SSD_CF       3
#define VENT_CTR_NF       4
#define VENT_UWY_NF       5
#define VENT_UW_NT        6
#define VENT_END_NT       7
#define VENT_SEC_NF       8
#define VENT_PRM_R        9
#define VENT_CLM_R        10
#define VENT_ADDPRM_R  11
#define VENT_OTHER_R      12
#define VENT_CRE_D        13
#define VENT_CREUSR_CF    14
#define VENT_LSTUPD_D     15
#define VENT_LSTUPDUSR_CF 16
#define VENT_CUR_CF 17				/*MOD001*/

// Fichier des Regroupements Comptables
#define TRS7_PRS_CF    0
#define TRS7_ACMTRS_NT       1
#define TRS7_DETTRS_CF    2


// Ventilation Retro NP¨- Table des Ventilations FVENTNP
typedef struct
   {
    char RETCTR_NF[10];
	int RTY_NF;
    int RETSEC_NF;
    int SSD_CF;
    char CTR_NF[10];
	int UWY_NF;
	unsigned char UW_NT;
    unsigned char END_NT;
    unsigned char SEC_NF;
    double PRM_R;
    double CLM_R;
    double ADDPRM_R;
    double OTHER_R;
    char CUR_CF[4];			/*MOD001*/
   } T_VENTNP;

// Table des Contrats Non Prop PERICASE
typedef struct
   {
    char RETCTR_NF[10];
    int RTY_NF;
    unsigned char RETSEC_NF;
   } T_PERICASENP;


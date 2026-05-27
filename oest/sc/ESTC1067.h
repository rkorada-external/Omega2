/*==============================================================================
nom de l'application          : ESTIMATION 
nom du source                 : ESTC1064.h
révision                      : $Revision: 1.0 $
date de création              : 21/09/2018
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :Spira:67650 REQ10.4 et REQ10.5 - Calcul des Futures primes, Fixes et Variables, Future fixed et Variables charges futures et des primes sinistre

------------------------------------------------------------------------------
historique des modifications :
[01]
================================================================================*/

#define NB_PAR_MAX    500 /* nombre de postes maxi du tableau des participations Ktbd_Par */
#define NB_FAM_MAX    100 /* nombre de postes maxi du tableau des familles de charges iterees par exercice */
#define NB_UWY_MAX     50 /* nombre d'exercice maxi par famille de charges iterees */
#define NB_COL_CTREST  21 /* nombre de colonnes de la tables des Estimations dommages */
#define NB_COL_GT      41 /* nombre de colonne du fichier GT */

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
#define LOA_TAXWO_R	10


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


/* definition de la structure T_ESTGT */
typedef struct
{
  short         UWY_NF;
  unsigned char UW_NT;
  unsigned char SSD_CF;
  char          DIV_NT[4];
  char          EGPCUR_CF[4];
  unsigned char ACCESB_CF;
  int           CED_NF;
  int           PRD_NF;
  int           GENPRMPAY_NF;
  char          GANPAYORD_NT[3];
  double        PB_M;
  double        PAP_M;
  char          LOSADMMOD_CT;
  double        LOSENTAMT_M;
  double        LOSRETAMT_M;
  char          PBADMMOD_CT;
  double        PBENTAMT_M;
  double        PBRETAMT_M;
  char          PAPADMMOD_CT;
  double        PAPENTAMT_M;
  double        PAPRETAMT_M;
  char          DIFMTH_NF;
  char          SEGSA_B;
} T_ESTGT;



 /* nombre de colonne du fichier GT */

#define NB_COL_GT	41


 /* nombre de poste du tableau des complements */

#define COMP_NBPOSTE		12

/* definition des noms de colonnes des tableaux Ktd_Comp */

#define Charge_EPP		0
#define Taxe_EPP		1
#define Courtage_EPP		2
#define Charge_PRM		3
#define Taxe_PRM		4
#define Courtage_PRM		5
#define ChargeTaxe_PPNA 	6
#define Courtage_PPNA		7
#define Charge_RPP		8
#define Taxe_RPP		9
#define Courtage_RPP		10
#define Courtage_REC		11


 /* definition de la structure T_PCACM */

typedef struct
{
short		ACY_NF ;
unsigned char	SCOSTRMTH_NF ;
unsigned char	SCOENDMTH_NF ;
double		AMT_M ;
} T_PCACM ;


/* definition de la structure T_PCACM2 */

typedef struct
{
short		ACY_NF ;
unsigned char	SCOSTRMTH_NF ;
unsigned char	SCOENDMTH_NF ;
double		AMT_M ;
unsigned char	TRNCOD_SUFIX ;
} T_PCACM2 ;

typedef struct {	
		char Contrat [10];
		char Devise[4];
		short Section;
		int  Exercice;
		short Endorsement; // END_NT
		short Order; // UW_NT
		short Condition_EPP;
		short Condition_RPP;
		short Condition_Tax_EPP;
		short Condition_Tax_RPP;
		double Montant_EPP;
		double Montant_RPP;
		double Comm_EPP;
		double Comm_RPP; 
		double Tax_EPP;
		double Tax_RPP;
} T_PERICOND;
	

 /* nombre de poste des tableaux du GT */

/*#define NB_GT_MAX	1000 modif o.arik 7/6/2001*/
#define NB_GT_MAX	2000

enum PERI_COLS {
				CTR_NF=0 ,
				END_NT,
				SEC_NF   ,
				UWY_NF   ,
				UW_NT,
				COND_EPP,
				COND_RPP,
				COND_TAX_EPP,
				COND_TAX_RPP,
				AMT_EPP ,
				AMT_RPP,
				COM_EPP,
				COM_RPP,
				TAX_EPP,
				TAX_RPP,
				DEVISE };

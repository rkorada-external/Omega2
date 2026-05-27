/**=======================================================================================
APPLICATION NAME          	: MAINTENANCE EXPENSES CALCULATION
SOURCE NAME                 : ESFC3630.h
REVISION                   	: V1
CREATION DATE              	: 03/2019
AUTOR                       : L.ELFAHIM
TYPE             			: Batch 
-----------------------------------------------------------------------------------------
DESCRIPTION :
	THIS INTERFACE HANDLES GLOBAL VARIABLES FOR ESFC3630 C PROGRAM
-----------------------------------------------------------------------------------------
MODIFICATIONS HISTORY :
	20/02/2019 		LEL		71570		Developpement de la version initiale
	24/07/2019		LEL		79992		Filtres et Jointures des fichiers
	10/09/2019		LEL		79992		Gerer la date du bilan
	25/09/2019		LEL		79992		Ajouter fichier gestion des anomalies
	26/08/2021      LEL   	97351       ACF/PCA: EXPENSES CALCULATION	
	21/07/2022		DAD		104984		Update new formula : IAE Paid
	22/02/2023		MiS		108484		New variables for PERICASE sync 
	14/03/2023		HR		108487		IAE and IME Paid - Add conversion
	22/05/2023		HR		109577		I17 - Calculate IME Paid on run off contracts
=========================================================================================*/

#ifndef __ESTC1090
#define __ESTC1090

#define SEPARATOR			"~"	
#define AMN_LEN 			19
#define CUR_NF				27
#define CED_NF				28
#define BRK_NF				29
#define PAY_NF				30
#define KEY_NF				31
#define NB_COL_GT 			43		
#define TRN_CODE			51
#define CML_ACMTRS3_NT2     123			
#define MAINT_RATIO     	125			
#define INI_STATUS			126			
#define FIRST_CLO_D			127			
#define EARP_R1				128	
#define IME_LOBN2_NF	    127			
#define IME_UWY_NF			128	
#define CSM_Q				129			
#define CSM_PREVQ			130	
#define DSC_FWD_AMT_TOTAL	131		//104984
#define PER_INI_STATUS		253
#define PER_FIRST_CLO_D		254
#define PER_FLAG			255
#define PER_DSC_FWD_AMT_TOTAL 256
#define PER_DSCSSD_CF       257
#define PER_DSCBALSHEY_NF   258
#define PER_DSCCUR_CF       259

#define NB_COL_GTR 			73
#define PER_PLC_NT			207
#define PER_RTO				208
#define PER_INT				209
#define PER_PAY				210
#define PER_KEY				211
#define RET_INI_STATUS		212
#define RET_FIRST_CLO_D		213
#define PER_RET_FLAG		215

FILE *Kp_OutputANO;	
FILE *Kp_OutputBatch;										
FILE *Kp_InputFilExc; 
FILE *Kp_OutputFil_EXPENSES;

T_RUPTURE_SYNC_VAR 	pbd_Sync;
T_RUPTURE_VAR       pbd_Rupture; 	
T_RUPTURE_SYNC_VAR 	Kbd_Rupt_CASHFLOW; 
T_RUPTURE_SYNC_VAR 	Kbd_RuptDLGTAAPNAE; 				
T_RUPTURE_SYNC_VAR      Kbd_Rupt_PER;

/**----------------------------------------------------------*
 	Fonctions du fichier d'aggregat
*-----------------------------------------------------------*/
int n_InitRupture( T_RUPTURE_VAR *pbd_Rupture );
int n_ActionLigneMaitre(char *ptsz_LigneCour[]);
int n_ActionFilsSansPere( char *ptsz_LigneEsclave[] );
int n_ActionPereSansFils( char *ptsz_LigneMaitre[] );

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ConditionSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_ActionLigneSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_PereSansFils_Sync( char **pbd_InRecOwner );

int n_Init_CASHFLOW( T_RUPTURE_SYNC_VAR  *pbd_Sync );
int n_CondSync_CSF( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_CSF( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_PereSansFils_CSF( char **pbd_InRecOwner );

int n_Init_PER( T_RUPTURE_SYNC_VAR  *pbd_Sync );
int n_CondSync_PER( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ActionLigne_PER( char **pbd_InRecOwner , char **pbd_InRecChild );

char n_GetNorme( const char *Norme_CF );	
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code );

int 	flag;

char 	Norme;
char 	Norme_CF[5];				
char	TrnCod[9];				
char	context_ct[4];	

char 	Ksz_Annee_bilan[5]; 
char 	Ksz_Mois_bilan[3] ; 
char 	Ksz_Jour_bilan[3] ;
char 	Ksz_CloDat[9] ;  		
char    Ksz_IncCloDat[9] ;
char    Ksz_PrevCloDat[9] ;

double 	d_UPR;
double 	n_MAINT_PAID;
double 	d_FUTURE_PREM;

enum TRERETFACCTR {
	CTR_NF= 0,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	RATEINDEX_CTG,
	RATEINDEX_CTP,
	RATEINDEX_CTL,
	TYPE,
	SSD_CF,
	ESB_CF,
	GRPINISTS_CT,
	PARINISTS_CT,
	LOCINISTS_CT,
	GRPFIRCLO_D,
	PARFIRCLO_D,
	LOCFIRCLO_D,
	GRPIFRSTRA_CT,
	PARIFRSTRA_CT,
	LOCIFRSTRA_CT,
	FIELD1,
	FIELD2,
	FIELD3,
	FIELD4,
	FIELD5,
	FIELD6,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT
};
 
#endif /* __ESTC1090 */

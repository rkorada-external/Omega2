/*====================================================================================================================
NOM DE L'APPLICATION          : AQUISITION EXPENSES CALCULATIONS
NOM DU SOURCE                 : ESFC3670.h
REVISION                      : V1
DATE DE CREATION              : 12/2018
AUTEUR                        : L.ELFAHIM
SQUELETTE DE BASE             : BATCH
REFERENCES DES SPECIFICATIONS : 
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
NOTE :	  
	 /  \   * CE FICHIER ENTETE GERE LES DEUX PROGRAMME ESFC3670 ET ESFC3672 TOUTE MODIFICATION *
	/  ! \  * DES VARIABLES OU FONCTIONS DECLAREES ICI IMPACTERA LES DEUX PROGRAMMES   **********
	/______\ ************************************************************************************
----------------------------------------------------------------------------------------------------------------------
HISTORIQUE DES MODIFICATIONS :
   <jj/mm/aaaa>   	<AUTEUR>   	<SPIRA> 	<DESCRIPTION DE LA MODIFICATION>
    01/08/2019		LEL   		75803		MERGE REQ11.1 et REQ11.2
    02/08/2019		T.YVERT		REQ.P.11.1	NEW RULE FOR TRS_COD
    14/11/2019		LEL			82609		CHANGE REQUEST ( Change in FD )
    08/01/2020		LEL  		82884		CHANGE INPUT FILE IN ORDER TO RETRIEVE UPR ENDING
    06/02/2020		LEL  		79102		RETRO NP MANAGEMENT
	06/01/2021		LEL  		92596		INTEGRATE FUTURE AE IN EXPENSE CALCULATION
	10/05/2021 		LEL	    	96217		Mapping change : Use IFRS17 PERICASE instead of EBS PERICASE
======================================================================================================================*/

#ifndef __ESFC3670
#define __ESFC3670

/**----------------------------------------------------
	Define variables            
-------------------------------------------------------*/
#define CLISSD 			253					
#define ACQ_RAT_Q		255 
#define SEPARATOR 	 	"~"	
#define ACMAMT_MC		42
#define ACMCUR_CF		43						
#define ACQ_RAT_PREVQ	255 						

#define	TRS_ITD 		40 				 			
#define	TRS_COD 		41
#define NB_COL_GT 		43	
#define NB_COL_GTR 		73								
#define	TRSCOD_UPR 		110 								
#define	TRS_COD_PREM 	42 																										  					
			
#define Ret_RTO			208
#define Ret_INT			209
#define Ret_PAY			210
#define Ret_KEY			211
#define Ret_RAT_Q		212
#define Ret_CLISSD		214
#define Ret_PLACEMT		207
#define RETPCPCUR_CF	50
#define Ret_RAT_PREVQ	213

/**-------------------------------------------------------
	Declaration des structures et fichiers du travail            
----------------------------------------------------------*/
FILE *Kp_OutputANO;									// pointeur sur le fichier de sorties des anomalies	
FILE *Kp_InputFilExc;        						// pointeur sur le fichier en entree des cours de change FCURQUOT 			
FILE *Kp_OutputFil_EXPENSES;						// pointeur sur le fichier de sorties des expenses calculations		

T_RUPTURE_VAR Kbd_RuptPER;          				// rupture sur le perimetre 		
T_RUPTURE_SYNC_VAR Kbd_RuptDldGTA;    				// synchro fichier de travail-perimetre 
T_RUPTURE_SYNC_VAR Kbd_RuptDLDGTAASIISO;    		// synchro fichier de travail-perimetre 
T_RUPTURE_SYNC_VAR Kbd_RuptDLGTAAPNAE;    			// synchro fichier de travail-perimetre 
	
/**---------------------------------------------------/
	Declaration des prototypes des fonctions 
-----------------------------------------------------*/
char n_GetNorme( const char *Norme_CF );					 
int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code );	

int n_InitPER( T_RUPTURE_VAR *pbd_Rupt );
int n_ActionLignePER( char **pbd_InRec_Cur );

int n_InitDldGTAA(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLigneGTAA( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ConditionSyncGTAA( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_InitDLDGTAASIISO(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLigneDLDGTAASIISO( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ConditionSyncDLDGTAASIISO( char **pbd_InRecOwner , char **pbd_InRecChild );

int n_InitDLGTAAPNAE(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLigneDLGTAAPNAE( char **pbd_InRecOwner , char **pbd_InRecChild );
int n_ConditionSyncDLGTAAPNAE( char **pbd_InRecOwner , char **pbd_InRecChild );

/**---------------------------------------------------/
	Declaration des variables globales 
------------------------------------------------------*/
double 	AcqExpenses; 		// Montant Acquisition Expenses 		
double 	AcqExpPaid; 		// Montant Acquisition Expenses Paid 		
double	d_FUTURE_PREM;		// Variable d aggregation FUTURE PREMIUMS 	
double  d_UPR_Ending;		// Variable d aggregation UPR ENDING ACOUNTS
double  d_UPR_Opening;		// Variable d aggregation UPR OPENING ACOUNTS 
double  d_WRITTEN_Prem;		// Variable d aggregation WRITTEN PREMIUM 

char 	Ksz_Annee_bilan[4+1]; 
char 	Ksz_Mois_bilan[2+1] ; 
char 	Ksz_Jour_bilan[2+1] ;
char 	Ksz_CloDat[8+1] ;  	
char 	Norme_CF[4+1] ;		
char	Context_CT[4];
char	TrnCod[8+1];		
char 	Norme;				 

int 	flag_Future;  
int 	flag_UPR_END; 
int		flag_UPR_OPN;  

#endif /* __ESFC3670 */

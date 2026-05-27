/*==============================================================================
Nom de l'application          : Maintenance Expenses Paid Calculation
Nom du source                 : ESTC1091.h
Revision                      : V1
Date de creation              : 03/2019
Auteur                        : L.EL-FAHIM
Squelette de base             : Batch
References des specifications : 
-------------------------------------------------------------------------------
Description :
	Ce programme manipule plusieurs fichiers en entree pour gerer :
	Maintenance Expenses Calculations

-------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
=============================================================================*/

#ifndef __ESTC1091
#define __ESTC1091

#define SEPARATOR 			"~"
#define CML_ACMTRS3_NT2		123	
#define NB_COL_GT 			43


/**--------------------------------------------------------/
	Declaration des fichiers et structures 
----------------------------------------------------------*/
FILE *kp_Output_EXPENSES;					/* Pointeur sur la fichier out   */
T_RUPTURE_VAR *pbd_Rupture; 				/* Pointeur sur la structure de la rupture   */

/**----------------------------------------------------------*
 	Fonctions du fichier d'aggregat
*-----------------------------------------------------------*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture( char **ptb_InRec, char **ptb_InRec_Cur );
int n_ActionFirstRupture( char *ptsz_LigneMaitre[] );
int n_ActionLigneMaitre(char *ptsz_LigneCour[]);
int n_ActionLastRupture( char *ptsz_LigneMaitre[] );

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ActionLigneSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_ConditionSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);

int n_EcrireGT( char **pbd_InRec_Cur, double d_Montant, char *trn_Code );
char n_GetNorme( const char *Norme_CF ); 	/* Extraire indice de la norme passe en parametre pour le renseigner dans TRNCOD */


/**--------------------------------------------------------/
	Declaration des variables globales 
----------------------------------------------------------*/
double 	n_MAINT_PAID;
char 	Norme_CF[5];						/* Variable GLOBAL contenant la norme dans lequel le closing est lance */
char	TrnCod[8+1];						/* Used in ESTC1091 program */
char 	Norme;								/* Used in ESTC1091 program */
char 	sz_Clodat_d[9] = "19990101";		/* Closing date */
char 	gsz_Annee[5], gsz_Mois[3], gsz_Jour[3]; // de la Date de cloture Ex: 20111201
 
#endif /* __ESTC1091 */

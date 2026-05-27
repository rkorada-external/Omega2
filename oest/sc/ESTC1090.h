/*============================================================================================
Nom de l'application          : Maintenance Expenses Calculation
Nom du source                 : ESTC1090.h
Revision                      : V1
Date de creation              : 03/2019
Auteur                        : L.EL-FAHIM
Squelette de base             : Batch
References des specifications : 
---------------------------------------------------------------------------------------------
Description :
	Ce programme manipule plusieurs fichiers en entree pour gerer :
	Maintenance Expenses Calculations
---------------------------------------------------------------------------------------------
Historique des modifications :
	<jj/mm/aaaa>   	<auteur>   	<SPIRA>		<description de la modification>
	20/02/2019	L.ELFAHIM		71570		Developpement de la version initiale
	24/07/2019	L.ELFAHIM		79992		Filtres et Jointures des fichiers
	10/09/2019	L.ELFAHIM		79992		Gerer la date du bilan
	25/09/2019	L.ELFAHIM		79992		Ajouter fichier gestion des anomalies
=============================================================================================*/

#ifndef __ESTC1090
#define __ESTC1090

#define SEPARATOR			"~"			/* Separateur des donnes dans le fichier */
#define AMN_LEN 			19			/* Taille maximale que peut atteindre un chiffre 18 + 1 */
#define CML_ACMTRS3_NT2     123			/* GTSII_REMAINTOPAY_ULAEINF encrichi par ACMTRS3_NT2 */
#define MAINT_RATIO     	125			/* GTSII_REMAINTOPAY_ULAEINF encrichi par MAINT_RATIO */

FILE *Kp_OutputBatch;					/* Pointeur sur le fichier ouput */
FILE *Kp_OutputANO;						/* Pointeur sur le fichier des anomalies */

T_RUPTURE_VAR       *pbd_Rupture; 		/* Pointeur sur la structure de la rupture   */
T_RUPTURE_SYNC_VAR  *pbd_Sync; 			/* Pointeur sur la structure de synchronisation */

/**----------------------------------------------------------*
 	Fonctions du fichier d'aggregat
*-----------------------------------------------------------*/
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionFilsSansPere( char *ptsz_LigneEsclave[] );
int n_ActionPereSansFils( char *ptsz_LigneMaitre[] );

int n_ActionLigneMaitre(char *ptsz_LigneCour[]);
int n_ConditionSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_ActionLigneSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);

char 	Norme_CF[4+1];				/* Variable GLOBAL contenant la norme dans lequel le closing est lance */
char	TrnCod[8+1];				/* Transaction code ID */

char 	Ksz_Annee_bilan[4+1]; 
char 	Ksz_Mois_bilan[2+1] ; 
char 	Ksz_Jour_bilan[2+1] ;
char 	Ksz_CloDat[8+1] ;  			/* Tableau contenant CloDat recu en parametre */
 
#endif /* __ESTC1090 */

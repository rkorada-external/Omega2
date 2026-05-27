/*==============================================================================
Nom de l'application          : Affectation du champ EXP_D aux autres contrats/
                                avenants
Nom du source                 : ESTC0106.c
Revision                      : $Revision:   1.0  $
Date de creation              : 18/09/1997
Auteur                        : CGI
References des specifications : 
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre facs XADPERICASE, a chaque rupture sur contrat/
   avenant, le champ EXP_D de la ligne en rupture premiere est reporte aux
   autres lignes.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie       */
T_RUPTURE_VAR  	   *pbd_Rupture; /* Pointeur sur la structure de la rupture   */

char Ksz_EXP_D[9]; /* Champ EXP_D de la rupture premiere */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]); 
int n_ActionLigneRupture (char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : rupture sur le fichier perimetre XADPERICASE		***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/	
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0106_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0106_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0106_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);

   exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre ESTPERICASE */
   if (n_OpenFileAppl("ESTC0106_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/	
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_ret;

   DEBUT_FCT("n_TestRupture");

   if (s_ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture");

   strcpy(Ksz_EXP_D, ptsz_LigneCour[PER_EXP_D]);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

/* Ecriture de la ligne avec affectation du champ EXP_D */
   ptsz_LigneCour[PER_EXP_D] = Ksz_EXP_D;
   n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

   RETURN_VAL(OK);
}

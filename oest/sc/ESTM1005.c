/*==============================================================================
Nom de l'application          : Ajout du champ DIFMTH_NF au fichier XADPERICASE
Nom du source                 : ESTM1005.c
Revision                      : $Revision: 1.2 $
Date de creation              : 01/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Ajout du champ DIFMTH_NF a la fin de chaque ligne du perimetre
------------------------------------------------------------------------------
Historique des modifications :
   	M.HA-THUC - 22/06/98
	L'ecart est maintenant calcule sur tous les exercices
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C

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

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
char Ksz_NbreMois[25];             /* Difference en nombre de mois */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
/* int n_TestRupture	   (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]); */
/* int n_ActionPremiereRupture(char *ptsz_LigneCour[]); */
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);


int n_DureeEnMois( int, int, int, int);


/**************************************************************************/
/*** Objet : Ajout du champ DIFMTH_NF au fichier XADPERICASE		***/
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
   if (n_OpenFileAppl("ESTM1005_O1", "wt", &Kp_OutputFile) == ERR) {
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

   if (n_CloseFileAppl("ESTM1005_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1005_O1", &Kp_OutputFile) == ERR) {
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

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTM1005_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }

   /*************************************/
   /* Modifs du 22/06/98 - M.HA-THUC	*/
   /* On supprime la gestion de rupture */
   /*************************************/
   /* pbd_Rupture->n_NbRupture=1; */
   /* pbd_Rupture->n_ConditionRupture[0]=n_TestRupture; */
   /* pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture; */
   pbd_Rupture->n_NbRupture=0;
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
   static short s_Ret;

   DEBUT_FCT("n_TestRupture");

   if (s_Ret=strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])) {
      return s_Ret;
   }

   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF]));
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
   char sz_Annee[5];
   char sz_Mois[3];

   DEBUT_FCT("n_ActionPremiereRupture");

   if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F') {
      sz_Annee[0] = ptsz_LigneCour[PER_EXP_D][0];
      sz_Annee[1] = ptsz_LigneCour[PER_EXP_D][1];
      sz_Annee[2] = ptsz_LigneCour[PER_EXP_D][2];
      sz_Annee[3] = ptsz_LigneCour[PER_EXP_D][3];
      sz_Annee[4] = '\0';
      sz_Mois[0] = ptsz_LigneCour[PER_EXP_D][4];
      sz_Mois[1] = ptsz_LigneCour[PER_EXP_D][5];
      sz_Mois[2] = '\0';
      sprintf(Ksz_NbreMois, "%d", - n_DureeEnMois(atoi(ptsz_LigneCour[PER_UWY_NF]), 12, atoi(sz_Annee), atoi(sz_Mois)));

/* Pour debugage */
/*    printf("CTR : %s, EXPAnnee : %s, EXPMois : %s, UWY : %s, Mois : %d, Nbre : %s\n", ptsz_LigneCour[PER_CTR_NF], sz_Annee, sz_Mois, ptsz_LigneCour[PER_UWY_NF], 12, Ksz_NbreMois); */


   }
   else {
      *Ksz_NbreMois = '\0';
   }

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
   char sz_Annee[5];
   char sz_Mois[3];

   DEBUT_FCT("n_ActionLigneRupture");

   /*************************************/
   /* Modfis du 22/06/98 - M.HA-THUC	*/
   /* On calcule l'ecart pour chaque 	*/
   /* exercice				*/
   /*************************************/

   if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F') {
      sz_Annee[0] = ptsz_LigneCour[PER_EXP_D][0];
      sz_Annee[1] = ptsz_LigneCour[PER_EXP_D][1];
      sz_Annee[2] = ptsz_LigneCour[PER_EXP_D][2];
      sz_Annee[3] = ptsz_LigneCour[PER_EXP_D][3];
      sz_Annee[4] = '\0';
      sz_Mois[0] = ptsz_LigneCour[PER_EXP_D][4];
      sz_Mois[1] = ptsz_LigneCour[PER_EXP_D][5];
      sz_Mois[2] = '\0';
      sprintf(Ksz_NbreMois, "%d", - n_DureeEnMois(atoi(ptsz_LigneCour[PER_UWY_NF]), 12, atoi(sz_Annee), atoi(sz_Mois)));
   }
   else {
      *Ksz_NbreMois = '\0';
   }

   ptsz_LigneCour[PER_DIFMTH_NF] = Ksz_NbreMois;
   n_WriteCols(Kp_OutputFile, ptsz_LigneCour,'~', 0);

   RETURN_VAL(OK);
}

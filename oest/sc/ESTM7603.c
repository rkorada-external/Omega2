/*==============================================================================
Nom de l'application          : Injection du poste contrepartie dans le GT
Nom du source                 : ESTM7603.c
Revision                      : $Revision: 1.2 $
Date de creation              : 18/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Injection du poste contrepartie dans le GT. Par le poste comptable du GT, on
   accede a la ligne du fichier binaire correspondant a la table TDETTRS (BREF),
   on lit alors le poste contrepartie (champ CTRSCOD_CF) que l'on complete dans
   le GT.
   Le GT et le fichier FDETTRS sont tries par poste comptable.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	  25/09/2006   J.Ribot    Spot13206  mise en place d'un message d'alerte et du plantage du traitement lorsque la limite
                                      de la table en memoire servant a stocker les lignes DETTRS est atteinte.  (estserv.c)
                                   nbre de lignes de stockage passé a 10000 (estverv.h)
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE   *Kp_OutputFile;   /* Pointeur sur le fichier FGT en sortie */
FILE   *Kp_GetDbltrncod; /* Pointeur sur le fichier des poste de contrepartie */
T_RUPTURE_VAR *pbd_Rupture; /* Pointeur sur la structure du GT */
char Ksz_DBLTRNCOD_CF[9]; /* Poste contrepartie */


/*--------------------------*/
/* Fonctions du fichier FGT */
/*--------------------------*/

int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture(char *ptsz_LigneCour[]);


int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs);


/**************************************************************************/
/*** Objet : recuperation du poste de contrepartie			***/
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

/* Ouverture du fichier de sortie GT */
   if (n_OpenFileAppl("ESTM7603_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Ouverture du fichier contenant le poste de contrepartie */
   if (n_OpenFileAppl("ESTM7603_I2", "rt", &Kp_GetDbltrncod) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetDbltrncod");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM7603_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7603_I2", &(Kp_GetDbltrncod)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7603_O1", &Kp_OutputFile) == ERR) {
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
   if (n_OpenFileAppl("ESTM7603_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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
   return (strcmp(ptsz_LigneSuiv[GT_TRNCOD_CF], ptsz_LigneCour[GT_TRNCOD_CF]));
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

   n_PosteContre(ptsz_LigneCour[GT_TRNCOD_CF], Kp_GetDbltrncod);

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

/* Ecriture de la ligne courante modifiee */
   ptsz_LigneCour[GT_DBLTRNCOD_CF] = Ksz_DBLTRNCOD_CF;
   n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction qui renvoie le type du poste contrepartie 	***/
/***         correspondant au poste comptable passe en parametre        ***/
/***         (recherche dans FDETTRS, fichier image de la table TDETTRS	***/
/***	     de BRET)							***/
/***									***/
/*** Nom : n_PosteContre						***/
/***									***/
/*** Parametres:							***/
/***   i sz_trncod : chaine contenant le poste comptable,		***/
/***   i Kp_Dettrs : pointeur sur le fichier d'entree.			***/
/***									***/
/*** Retour:								***/
/***   OK 								***/
/**************************************************************************/

int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs)
{
    static int b_PremierAppel=0;
    static int n_NbreLignes;
    static T_DETTRS bd_TDETTRS[MAX_TDETTRS];
    int n_position;

   DEBUT_FCT("n_PosteContre");
//  printf("TRNCOD =  %s\n", sz_trncod);
/* S'il s'agit du premier appel a la fonction, on charge la table en memoire */
    if ( b_PremierAppel==0 ) {
       n_NbreLignes = n_LoadTDETTRS(Kp_Dettrs, bd_TDETTRS);
       b_PremierAppel=1;
    }

/* Calcul de la position du poste comptable dans la table TDETTRS */
    n_position = n_GetPosDettrs(sz_trncod, bd_TDETTRS, n_NbreLignes);

/* Si le poste n'est pas trouve dans la table on sort et on renvoie 0 */
   if (n_position == -1) {
         *Ksz_DBLTRNCOD_CF = '\0';
   }

/* On renvoie le type de poste trouve */
   else {
      strcpy(Ksz_DBLTRNCOD_CF, bd_TDETTRS[n_position].CTRSCOD_CF);
   }
//    printf("Contre partie =  %s \n", Ksz_DBLTRNCOD_CF);
   RETURN_VAL(OK);
}


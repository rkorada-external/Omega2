/*==============================================================================
Nom de l'application          : Filtre des affaires des facs et affectation du
                                champ SECINC_D aux autres contrats/avenants
Nom du source                 : ESTC0105.c
Revision                      : $Revision: 1.2 $
Date de creation              : 17/09/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre facs XADPERICASE, a chaque rupture sur contrat/
   avenant, on conserve les affaires si le champ CTRINC_D de la ligne en rupture
   premiere est inferieur ou egal a la date recuperee par la proc. PsSECTION_32.
   Si le contrat/avenant est conserve le champ CTRINC_D de la ligne en rupture
   premiere est reporte aux autres lignes dans le champ SECINC_D.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
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

T_UTCTLIB Kbd_UTCTLIB;        /* Structure d'appel des procs */
FILE          *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
T_RUPTURE_VAR *pbd_Rupture;   /* Pointeur sur la structure de la rupture */

char Ksz_SEG_D[9];       /* Date de demande du perimetre */
char Kc_OPTION;          /* Option : I pour inventaire, S pour segmentation */
char Ksz_SECINC_D[9];    /* Date d'effet de la section du contrat/avenant */
char Ksz_DateMaxTRT[9];  /* Date de filtre du perimetre traites - non utilise */
char Ksz_DateMaxFAC[9];  /* Date de filtre du perimetre facs */
short Ks_Ecrire; /* Vaut 1 pour si le contrat/avenant est reporte en sortie, */
                 /* 0 autrement */


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

/* Recuperation du parametre correspondant a la date de demande du perimetre */
   strcpy(Ksz_SEG_D, psz_GetCharArgv(1));

/* Par defaut pour l'inventaire, recopie de la date */
   strcpy(Ksz_DateMaxFAC, Ksz_SEG_D);

/* Recuperation su parametre corespondant a l'option demandee */
   Kc_OPTION = *(psz_GetCharArgv(2));

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0105_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }


/* Cas segmentation */

if (Kc_OPTION == 'S') {

/* Connexion a la base */
      if (n_LocalConnect (&Kbd_UTCTLIB) != CS_SUCCEED) {
        ExitPgm (ERR_XX, "Erreur appel fonction n_LocalConnect");
      }

/* Recuperation de la date de filtre pour les facs */
      n_ProcessingProc (&Kbd_UTCTLIB, 3,"BEST..PsSECTION_32",
      	                "@p_date_maxTRT", CS_RETURN, CS_CHAR_TYPE, Ksz_DateMaxTRT, 8, 0,
      	                "@p_date_maxFAC", CS_RETURN, CS_CHAR_TYPE, Ksz_DateMaxFAC, 8, 0,
   	                "@p_seg_d", CS_INPUTVALUE, CS_CHAR_TYPE, Ksz_SEG_D, 8, 0);

   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }


/* Cas segmentation */

   if (Kc_OPTION == 'S') {

/* Deconnexion de la base */
      if (n_LocalDisconnect (&Kbd_UTCTLIB) != CS_SUCCEED) {
         ExitPgm (ERR_XX, "Erreur appel fonction LocalDisconnect");
      }
   }

   if (n_CloseFileAppl("ESTC0105_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0105_O1", &Kp_OutputFile) == ERR) {
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

/* Ouverture du fichier maitre ESTPERICASE */
   if (n_OpenFileAppl("ESTC0105_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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

   if ((s_ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF]))) {
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

   if (strcmp(Ksz_DateMaxFAC, ptsz_LigneCour[PER_CTRINC_D]) >= 0) {
      Ks_Ecrire = 1;
      strcpy(Ksz_SECINC_D, ptsz_LigneCour[PER_CTRINC_D]);
   }
   else {
      Ks_Ecrire = 0;
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
   DEBUT_FCT("n_ActionLigneRupture");

/* Ecriture de la ligne */
   if (Ks_Ecrire) {
      ptsz_LigneCour[PER_SECINC_D] = Ksz_SECINC_D;
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
   }

   RETURN_VAL(OK);
}

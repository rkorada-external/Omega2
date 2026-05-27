/*==============================================================================
Nom de l'application          : Cumul des exercices de survenance du GT
Nom du source                 : ESTC0602.c
Revision                      : $Revision: 1.2 $
Date de creation              : 23/06/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Cumul des exercices de survenance du GT
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[001]24/02/2015 F Maragnes :spot:28305  Ajout de deux nouvelles variables (Kd_sccrpcc et Kd_sccarpcc) dans le fichier résultat 
[002]12/05/2015 F Maragnes :spot:28305  Ajout de la variable Kd_scirpcc  dans le fichier résultat 

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

double Kd_Sci;      /* Cumul du champ ACMAMT_M pour le poste 20000 */
double Kd_Scc;      /* Cumul du champ ACMAMT_M pour le poste -20000 */
double Kd_Scca;      /* Cumul du champ ACMAMT_M pour le poste -20030 */
double Kd_PA;       /* Cumul du champ ACMAMT_M pour le poste 01002 */
double Kd_sccrpcc ;   /* Cumul du champ CASEACT_Sccrpcci_M pour le poste 20500 */
double Kd_sccarpcc;  /* Cumul du champ  CASEACT_Sccarpcci_M pour le poste 20530 */
double  Kd_scirpcc;  /* Cumul du champ ACMAMT_M pour le poste 20500 */
char Ksz_MessageErr[256]; /* Message d'erreur */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	   (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : Cumul des exercices de survenance du GT			***/
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
   if (n_OpenFileAppl("ESTC0602_O1", "wt", &Kp_OutputFile) == ERR) {
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

   if (n_CloseFileAppl("ESTC0602_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0602_O1", &Kp_OutputFile) == ERR) {
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
   if (n_OpenFileAppl("ESTC0602_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[0]=n_ActionDerniereRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture1     						***/
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

   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTESTCUMUL1_CTR_NF], ptsz_LigneCour[GTESTCUMUL1_CTR_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTESTCUMUL1_END_NT], ptsz_LigneCour[GTESTCUMUL1_END_NT]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTESTCUMUL1_SEC_NF], ptsz_LigneCour[GTESTCUMUL1_SEC_NF]))) {
      return s_Ret;
   }
   if ((s_Ret=strcmp(ptsz_LigneSuiv[GTESTCUMUL1_UWY_NF], ptsz_LigneCour[GTESTCUMUL1_UWY_NF]))) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[GTESTCUMUL1_UW_NT], ptsz_LigneCour[GTESTCUMUL1_UW_NT]));
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

   Kd_Sci = 0;
   Kd_Scc = 0;
   Kd_Scca = 0;
   Kd_PA = 0;
   Kd_sccrpcc=0 ;
   Kd_sccarpcc=0;
   Kd_scirpcc=0;
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

   if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == 20000) {
      Kd_Sci = Kd_Sci + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20000) {
      Kd_Scc = Kd_Scc + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20030) {
      Kd_Scca = Kd_Scca + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }
   else if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == 1002) {
      Kd_PA = Kd_PA + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   } 
   else if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20500) {
      Kd_sccrpcc  = Kd_sccrpcc  + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }else  if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == -20530) {
      Kd_sccarpcc = Kd_sccarpcc + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }else  if (atoi(ptsz_LigneCour[GTESTCUMUL1_ACMTRS_NT]) == 20500) {
      Kd_scirpcc  = Kd_scirpcc  + atof(ptsz_LigneCour[GTESTCUMUL1_ACMAMT_M]);
   }   

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionDerniereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionDerniereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionDerniereRupture");

   if (Kd_Sci != 0) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
              20000,
              Kd_Sci
      );
   }
   if (Kd_Scc != 0) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
              -20000,
              Kd_Scc
      );
   }
   if (Kd_Scca != 0) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
              -20030,
              Kd_Scca
      );
   }
   if (Kd_PA != 0) {
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
              1002,
              Kd_PA
      );
   }
    
   
    if (Kd_sccrpcc  != 0) {


      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
             -20500,
              Kd_sccrpcc 
      );
   }
   
   if (Kd_sccarpcc  != 0) {



      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
             -20530,
              Kd_sccarpcc 
      );
   }  
   
    if (Kd_scirpcc  != 0) {

    
      fprintf(Kp_OutputFile, "%s~%s~%s~%s~%s~%d~%-.3lf\n",
              ptsz_LigneCour[GTESTCUMUL1_CTR_NF],
              ptsz_LigneCour[GTESTCUMUL1_END_NT],
              ptsz_LigneCour[GTESTCUMUL1_SEC_NF],
              ptsz_LigneCour[GTESTCUMUL1_UWY_NF],
              ptsz_LigneCour[GTESTCUMUL1_UW_NT],
              20500,
              Kd_scirpcc
				);
   }  
 
   RETURN_VAL(OK);
}


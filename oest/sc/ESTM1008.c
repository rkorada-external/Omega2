/*==============================================================================
Nom de l'application          : Prise en compte de l'EPP du premier exercice
                                pour les proportionnelles
Nom du source                 : ESTM1008.c
Revision                      : $Revision: 1.2 $
Date de creation              : 08/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Calcul de l'aliment de l'exercice virtuel precedent le premier exercice
  avec encapsulation du lot 11.
  En entree, on a besoin du perimetre (fichier maitre) FILTRE POUR NE CONSERVER
  QUE LES TRAITES PROPORTIONNELS, du fichier de travail issu du programme
  ESTM1007.c
  On recupere un fichier de travail en sortie reconduit comportant des lignes
  supplementaires.
  Le perimetre est trie par contrat/avenant/section/exercice/numero d'ordre.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
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

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier de travail en */
                                   /* sortie */
T_RUPTURE_VAR *pbd_Rupture; /* Pointeur sur la structure du perimetre */
T_RUPTURE_SYNC_VAR *pbd_SyncTT; /* Pointeur sur la structure de */
                                /* synchronisation avec le fichier de travail */
short Ks_UWY_NF; /* Premier exercice pour le contrat/avenant/section */
char Ksz_EGPCUR_CF[4]; /* Devise du premier exercice */
double Kd_CUTSHA_R;    /* Part SCOR du premier exercice */
double Kd_Part;        /* Part du premier exercice */
short Ks_PRMPRTSCL_B;  /* Indicateur de l'echelonnement de l'entree de */
                       /* portefeuille primes */
short Ks_Pex; /* Vaut 1 si premier exercice en synchro, 0 */
short Ks_Analyse; /* Vaut 1 si le contrat/avenant/section est analyse, 0 */
                  /* autrement */

double Kd_EPP; /* Montant de l'EPP */
double Kd_Coeff; /* Coefficient issu du Lot 11 */
char Ksz_CLODAT_D[9];     /* Date de libelle d'inventaire */
T_EchPrmRecu Ktbd_EchPrm[12]; /* Tableau des annees de compte/periode de */
                              /* compte pour l'ecriture en sortie */
char Ksz_SECINC_D[9]; /* Date d'effet du premier exercice - 1 an */


/*----------------------------------*/
/* Fonctions du fichier IADPERICASE */
/*----------------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);


/*----------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre IADPERICASE et le fichier de travail */
/*----------------------------------------------------------------------------*/

int n_InitSyncTT	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncTT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncTT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et esclave     	***/
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
   pbd_SyncTT=malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Recuperation du parametre correspondant a la date libelle d'inventaire */
   strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));

/* Ouverture du fichier de travail */
   if (n_OpenFileAppl("ESTM1008_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation avec le fichier de travail */
   if (n_InitSyncTT(pbd_SyncTT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM1008_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1008_I2", &(pbd_SyncTT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1008_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncTT);

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
   if (n_OpenFileAppl("ESTM1008_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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
/*** Objet : initialisation de la synchronisation de IADPERICASE avec le***/
/***         fichier de travail                                   	***/
/***									***/
/*** Nom : n_InitSyncTT     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncTT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncGT
)
{
   DEBUT_FCT("n_InitSyncTT");
   memset(pbd_SyncTT, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM1008_I2", "rt", &(pbd_SyncTT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncTT->ConditionEndSync=n_ConditionSyncTT;
   pbd_SyncTT->n_ActionLigne=n_ActionLigneSyncTT;
   pbd_SyncTT->c_Separ='~';

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
   static int n_Ret;
   if (n_Ret = strcmp(ptsz_LigneCour[PER_CTR_NF], ptsz_LigneSuiv[PER_CTR_NF])) {
      return n_Ret;
   }
   if (n_Ret = strcmp(ptsz_LigneCour[PER_END_NT], ptsz_LigneSuiv[PER_END_NT])) {
      return n_Ret;
   }
   return (strcmp(ptsz_LigneCour[PER_SEC_NF], ptsz_LigneSuiv[PER_SEC_NF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***fichier maitre***/
/******/
/*** Nom : n_ActionPremiereRupture***/
/******/
/*** Parametres:***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante***/
/******/
/*** Retour:***/
/***    OK si pas d'erreur,***/
/***    ERR si erreur.***/
/**************************************************************************/
int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
      Ks_Analyse = 0;
      Ks_Pex = 0;
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
   static char sz_EXP_D[9];   /* Date d'echeance */

   DEBUT_FCT("n_ActionPremiereRupture");


     if ( Ks_Analyse == 0 && (*ptsz_LigneCour[PER_CTRNAT_CT] == 'P') && ( (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 1) || (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 3) || (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 4) || (atoi(ptsz_LigneCour[PER_ACCADMTYP_CT]) == 5) ) ) {
      Ks_Analyse = 1;

/* EXP_D = EXP_D du peri - 1 jour */
      n_AddDays(sz_EXP_D, 1, '-', ptsz_LigneCour[PER_SECINC_D]);

/* SECINC_D = SECINC_D du peri - 1 an */
      n_AddYears(Ksz_SECINC_D, 1, '-', ptsz_LigneCour[PER_SECINC_D]);

/* Appel du Lot 11 */
      Kd_Coeff = d_CalculCoeffPna(Ksz_SECINC_D,
                                  sz_EXP_D,
                                  Ksz_SECINC_D,
                                  sz_EXP_D,
                                  12,
                                  (unsigned char)atoi(ptsz_LigneCour[PER_ERNPRMADM_B])
                 );

/* Sauvegarde du premier exercice, de l'indicateur d'echelonnement */
/* et de la part SCOR courante */
      Ks_UWY_NF = atoi(ptsz_LigneCour[PER_UWY_NF]);
      Ks_PRMPRTSCL_B = atoi(ptsz_LigneCour[PER_PRMPRTSCL_B]);
      Kd_CUTSHA_R = atof(ptsz_LigneCour[PER_CUTSHA_R]);
      strcpy(Ksz_EGPCUR_CF, ptsz_LigneCour[PER_EGPCUR_CF]);

/* Calcul de la part */
      if (*ptsz_LigneCour[PER_LIARIDSHA_B] == '0') {
         Kd_Part = atof(ptsz_LigneCour[PER_RIDSHA_R])*atof(ptsz_LigneCour[PER_CUTSHA_R]);
      }
      else {
         Kd_Part = atof(ptsz_LigneCour[PER_CUTSHA_R]);
      }

/* Par defaut, l'EPP est pris dans le perimetre */
      Kd_EPP = atof(ptsz_LigneCour[PER_PRMPRT_M]);


/* On fait la synchro avec le fichier de travail pour le premier contrat/ */
/* avenant/section/exercice pour rechercher l'EPP s'il existe et pour */
/* recopier en sortie toutes les lignes du fichier de travail */
      n_ProcessingRuptureSyncVar(pbd_SyncTT, ptsz_LigneCour);
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
   static char sz_Date_D[9];  /* Date */
   static char sz_AnneeDeb[5];/* Chaine contenant l'annee de debut de periode */
   static char sz_AnneeFin[5];/* Chaine contenant l'annee de fin de periode */
   static char sz_MoisDeb[3]; /* Chaine contenant le mois de debut de periode */
   static char sz_MoisFin[3]; /* Chaine contenant le mois de fin de periode */
   static int n_NbreEchPrmInit; /* Variable contenant le nombre de periodes */
                                /* initiales */
   static int n_NbreEchPrm; /* Nombre de lignes du tableau */
   static int n_CompteurEchPrm; /* Compteur sur les lignes du tableau */

   DEBUT_FCT("n_ActionDerniereRupture");

   if (Ks_Analyse) {

/* Calcul des annees de compte/periodes de comptes */

      switch (atoi(ptsz_LigneCour[PER_ACCFRQ_CT])) {
         case 1:
            n_NbreEchPrmInit = 12;
            break;
         case 2:
            n_NbreEchPrmInit = 4;
            break;
         case 3:
            n_NbreEchPrmInit = 3;
            break;
         case 4:
            n_NbreEchPrmInit = 2;
            break;
         case 5:
            n_NbreEchPrmInit = 1;
            break;
      }

/* Cacul du debut de la periode comptable, ajout du decalage */
      n_AddMonths(sz_Date_D, fabs(atoi(ptsz_LigneCour[PER_DIFMTH_NF])), '-', Ksz_SECINC_D);
      n_NbreEchPrm = n_NbreEchPrmInit;

      for (n_CompteurEchPrm = 0; n_CompteurEchPrm < n_NbreEchPrm; n_CompteurEchPrm ++) {

/* Date de debut de periode de compte */
         sz_AnneeDeb[0] = sz_Date_D[0];
         sz_AnneeDeb[1] = sz_Date_D[1];
         sz_AnneeDeb[2] = sz_Date_D[2];
         sz_AnneeDeb[3] = sz_Date_D[3];
         sz_AnneeDeb[4] = '\0';
         sz_MoisDeb[0] = sz_Date_D[4];
         sz_MoisDeb[1] = sz_Date_D[5];
         sz_MoisDeb[2] = '\0';

/* Date de fin de periode de compte */
         n_AddMonths(sz_Date_D, 12/n_NbreEchPrmInit - 1, '+', sz_Date_D);
         sz_AnneeFin[0] = sz_Date_D[0];
         sz_AnneeFin[1] = sz_Date_D[1];
         sz_AnneeFin[2] = sz_Date_D[2];
         sz_AnneeFin[3] = sz_Date_D[3];
         sz_AnneeFin[4] = '\0';
         sz_MoisFin[0] = sz_Date_D[4];
         sz_MoisFin[1] = sz_Date_D[5];
         sz_MoisFin[2] = '\0';

/* Periode de compte sur 2 annees */
         if (strcmp(sz_AnneeDeb, sz_AnneeFin)) {

/* Premiere ecriture */
            Ktbd_EchPrm[n_CompteurEchPrm].ACY_NF = atoi(sz_AnneeDeb);
            Ktbd_EchPrm[n_CompteurEchPrm].SCOSTRMTH_NF = atoi(sz_MoisDeb);
            Ktbd_EchPrm[n_CompteurEchPrm].SCOENDMTH_NF = 12;
            if (Kd_Coeff != 0) {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = (float)n_NbreEchPrmInit * ((12 - (float)atoi(sz_MoisDeb) + 1) / 12) * Kd_EPP/(Kd_Coeff * (float)n_NbreEchPrmInit);
            }
            else {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = 0;
            }
            n_CompteurEchPrm++;

/* Seconde ecriture */
            Ktbd_EchPrm[n_CompteurEchPrm].ACY_NF = atoi(sz_AnneeFin);
            Ktbd_EchPrm[n_CompteurEchPrm].SCOSTRMTH_NF = 1;
            Ktbd_EchPrm[n_CompteurEchPrm].SCOENDMTH_NF = atoi(sz_MoisFin);
            if (Kd_Coeff != 0) {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = (float)n_NbreEchPrmInit * (((float)atoi(sz_MoisFin)) / 12) * Kd_EPP/(Kd_Coeff * (float)n_NbreEchPrmInit);
            }
            else {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = 0;
            }
            n_NbreEchPrm++;

         }

/* Periode de compte sur 1 annee */
         else {
            Ktbd_EchPrm[n_CompteurEchPrm].ACY_NF = atoi(sz_AnneeDeb);
            Ktbd_EchPrm[n_CompteurEchPrm].SCOSTRMTH_NF = atoi(sz_MoisDeb);
            Ktbd_EchPrm[n_CompteurEchPrm].SCOENDMTH_NF = atoi(sz_MoisFin);
            if (Kd_Coeff != 0) {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = Kd_EPP/(Kd_Coeff * (float)n_NbreEchPrmInit);
            }
            else {
               Ktbd_EchPrm[n_CompteurEchPrm].AMT_M = 0;
            }
         }

         n_AddMonths(sz_Date_D, 1, '+', sz_Date_D);
      }

/* Affichages pour debuggage */
/*    printf("CTR %s, END %s, SEC %s, EPP %lf, Coeff %lf\n",
             ptsz_LigneCour[PER_CTR_NF],
             ptsz_LigneCour[PER_END_NT],
             ptsz_LigneCour[PER_SEC_NF],
             Kd_EPP,
             Kd_Coeff
      ); */

/* Ecriture dans le fichier de travail */
      for (n_CompteurEchPrm = 0; n_CompteurEchPrm < n_NbreEchPrm; n_CompteurEchPrm ++) {
         fprintf(Kp_OutputFile, "%s~%s~%s~%s~%d~%d~%d~%d~%d~%d~%s~%d~%c~%s~%-.3lf~~~~~~~~~~~~~%-.3lf~%s\n",
                 Ksz_CLODAT_D,
                 ptsz_LigneCour[PER_CTR_NF],
                 ptsz_LigneCour[PER_END_NT],
                 ptsz_LigneCour[PER_SEC_NF],
                 Ks_UWY_NF - 1,
                 1,
                 Ktbd_EchPrm[n_CompteurEchPrm].ACY_NF,
                 Ktbd_EchPrm[n_CompteurEchPrm].SCOSTRMTH_NF,
                 Ktbd_EchPrm[n_CompteurEchPrm].SCOENDMTH_NF,
                 Ks_UWY_NF - 1,
                 ptsz_LigneCour[PER_SSD_CF], /* Ajout de la filiale */
                 9000,
                 'E',
                 Ksz_EGPCUR_CF,
                 Ktbd_EchPrm[n_CompteurEchPrm].AMT_M,
                 Kd_Part,
                 ptsz_LigneCour[PER_ACCADMTYP_CT]
         );
      }
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation de IADPERICASE avec le fichier de travail	***/
/***									***/
/*** Nom : n_ConditionSyncTT						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSyncTT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSyncTT");

   if (s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[FT_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[FT_END_NT])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[FT_SEC_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier de travail 	***/
/***									***/
/*** Nom : n_ActionLigneSyncTT						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncTT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncTT");

/* Recherche s'il existe un montant d'EPP cedante pour le premier exercice */
   if (atoi(ptsz_LigneEsclave[FT_UWY_NF]) == Ks_UWY_NF && Ks_Pex == 0) {
      if (atof(ptsz_LigneEsclave[FT_EPPC_M])) {
         if (Ks_PRMPRTSCL_B == 0) {
            Kd_EPP = atof(ptsz_LigneEsclave[FT_EPPC_M]);
	    Ks_Pex = 1;
         }
      }
   }

   RETURN_VAL(OK);
}

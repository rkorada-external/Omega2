/*==============================================================================
Nom de l'application          : Encapsulation du lot 5
Nom du source                 : ESTC0606.c
Revision                      : $Revision: 1.2 $
Date de creation              : 07/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Calcul de la sinistralite et des IBNR pour chaque segment/exercice.
   Le fichier maitre est le fichier PERICASEEST3 ou PERICASEACT3 (issu du
   perimetre)
   Contient les fonctions du source ESTC0501.c (qui est inutile)
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>       <description de la modification>
    07/11/1998    B.Montagnac    Modification du traitement de calcul des IBNR et
                                 de la sinistralite pour chaque segment/exercice.
                                 (Initialement segment/exercice/devise)

    30/11/1998    B.Montagnac    Correction du calcul des montants et des IBNR
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"
#include "ESTC0501.h"

T_LIGNEREC Kbd_Rec[NB_REC_MAX]; /* variable intermediaire tableau de reconstitution */

int Kn_RecRnk; /* variable correspondant au rang de reconstitution par affaire*/

extern int n_SinisCtrEst (char CTRNAT_CT, int NbreCASEX, T_SEG *pbd_SEG, T_CASEX tbd_CASEX[]);

extern int n_SinisActu (char CTRNAT_CT, int NbreEXER, int NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[]);


int n_IBNRActu (int n_NbreEXER, int n_NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[]) ;

/************************************/
/* Define                           */
/* Attention : a modifier si besoin */
/************************************/

#define SEGEXERDEV_MAX 90000 /* Nombre maximum de C/A/S/N° s'ordre par */
                             /* segment/exercice/devise */

#define EXER_MAX 10 /* Nombre maximum d'exercices de survenance */


/*-------------------------------*/
/* Variables de travail externes */
/*-------------------------------*/

extern char b_EOF_MAITRE; /* Permet de faire des synchronisations sur la */
                          /* sur la derniere ligne du fichier maitre */

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputFileUltimes; /* Pointeur sur le fichier de */
                                          /* sortie des ultimes (estimations) */
FILE 		   *Kp_OutputFileFAMLIA; /* Pointeur sur le fichier de */
                                /* sortie pour la table TFAMLIA (estimations) */
FILE 		   *Kp_OutputFileSECTION; /* Pointeur sur le fichier de */
                                /* sortie pour la table TSECTION (estimations)*/
FILE 		   *Kp_OutputFileDommages; /* Pointeur sur le fichier de */
                                           /* sortie des dommages (actuariat) */
FILE 		   *Kp_OutputFileGT;       /* Pointeur sur le fichier de */
                                           /* sortie du GT (actuariat) */

FILE 		   *Kp_GetTaux;    /* Pointeur sur le fichier des taux */

T_RUPTURE_VAR  	   *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncSEGEST;/* Pointeur sur la structure de */
                                   /* synchronisation avec TLABOCY */
T_RUPTURE_SYNC_VAR *pbd_SyncLABOCY;/* Pointeur sur la structure de */
                                   /* synchronisation avec LABOCY */
T_RUPTURE_SYNC_VAR *pbd_SyncPERICASE;/* Pointeur sur la structure de */
                                   /* synchronisation avec PERICASE */
T_RUPTURE_SYNC_VAR *pbd_SyncGT;    /* Pointeur sur la structure de */
                                   /* synchronisation avec le GT */
T_RUPTURE_SYNC_VAR *pbd_SyncPer;   /* Pointeur sur la structure de */
				   /* synchronisation avec le PERIFR */

char **Kptsz_PERIMASTER;
char **Kptsz_PERICASE;    /* Pointeur sur la ligne de l'esclave permettant de */
                          /* recuperer des donnees dans le maitre */

double Kd_Sccij;          /* Valeur de Sccij pour ecriture dans le GT :  SP sur comptes complets en proportionnels */
double Kd_Sccaij;         /* Valeur de Sccaij pour ecriture dans le GT : SAP sur comptes complets en proportionnel */
double Kd_Sci;            /* Valeur de Sci pour ecriture dans le GT : ??? sur comptes complets en proportionnel */

char Kc_SEGTYP_CT;        /* Type segment */
char Ksz_CRE_D[20];        /* Date systeme */

int Kn_BALSHTYEA;          /* Annee utilisee pour le cours en actuariat */
int Kn_CREYEA;             /* Annee utilisee pour le cours en estimation */

/* Variables pour recuperer les versions */
char Kc_Delimiteur='_';   /* Delimiteur utilise */
char Ksz_SSD_LL[65];      /* Liste des filiales separees par '_', contient 21 */
                          /* filiales au maximum de 2 caracteres */
int Kn_Compteur;          /* Compteur sur une chaine ou un tableau */
int Kn_CompteurSousChaine;/* Compteur sur la sous-chaine contenant la filiale */
                          /* ou la version en cours */
char Ksz_SousChaine[11];  /* Sous chaine contenant la filiale ou la version */
                          /* en cours */
int Kn_NbreFiliales=0;    /* Nbre de filiales */
int Ktn_ListeFiliales[22];/* Tableau contenant la liste des filales */
int Kn_VRS_NF;            /* Version de la filiale en cours */
char Ksz_VRS_LL[233];     /* Liste des versions correspondant aux filiales */
                          /* precedentes separees par '_', contient 21 */
                          /* versions de 10 caracteres */
int Kn_NbreVersions=0;    /* Nbre de versions */
int Ktn_ListeVersions[22];/* Tableau contenant la liste des versions */

char Kc_INVTYP;           /* Type d'inventaire */
char Ksz_CLODAT_D[9];     /* Date de libelle d'inventaire */
short Ks_SegmentNul;      /* Vaut 1 si le segment n'existe pas, 0 autrement */

double Kd_BurningCost;    /* Variable contenant le BurningCost */
double Kd_Reconstitution; /* Variable contenant la reconstitution */
double Kd_Reconstit;      /* Variable contenant la Reconstitution */
char Ksz_MessageErr[256]; /* Message d'erreur */

int Kn_CompteurCASEX; /* Compteur numero d'affaire */
int Kn_NbreCASEX;     /* Nombre d'affaires pour le SEG/EXER/DEV */
int Kn_CompteurEXER;/* Compteur numero d'exercice de survenance */
int Kn_NbreEXER;    /* Nombre d'exercices de survenance pour le */
                      /* SEG/EXER */
T_SEG Kbd_SEG; /* Vecteur contenant les donnees du segment/exercice/devise */
T_EXER Ktbd_EXER[EXER_MAX]; /* Tableau contenant les exercices de survenance */
T_CASEX Ktbd_CASEX[SEGEXERDEV_MAX]; /* Tableau de structures contenant les */
                                   /* affaires en entree du lot 5. */
T_IBNR Ktbd_IBNR[SEGEXERDEV_MAX*EXER_MAX]; /* Tableau de structures contenant */
                                          /* les IBNR en retour du lot 5. */

BOOL Kb_ReturnStatus=0; /* code de retour du programme (=0 si OK, 1 sinon) */

/*--------------------------------------------------------------------*/
/* Fonctions du fichier maitre (fichier PERICASEEST3 ou PERICASEACT3) */
/*--------------------------------------------------------------------*/

int n_InitRupture	 	(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture1	 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_TestRupture2	 	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture1	(char *ptsz_LigneCour[]);
int n_ActionPremiereRupture2	(char *ptsz_LigneCour[]);
int n_ActionLigneRupture 	(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture	(char *ptsz_LigneCour[]);


/*-----------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le le fichier maitre et TSEGEST */
/*-----------------------------------------------------------------------*/

int n_InitSyncSEGEST 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncSEGEST	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncSEGEST	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsSEGEST(char **ptsz_LigneMaitre);


/*--------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et TLABOCY */
/*--------------------------------------------------------------------*/

int n_InitSyncLABOCY 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncLABOCY	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncLABOCY	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*---------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et PERICASE */
/*---------------------------------------------------------------------*/

int n_InitSyncPERICASE 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncPERICASE	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPERICASE1	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPERICASE2	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*--------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et le GT */
/*--------------------------------------------------------------------*/

int n_InitSyncGT 		(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncGT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncGT	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*----------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et le PERIFR */
/*----------------------------------------------------------------------*/

int n_CopyRec( char **ptb_InRecChild, T_LIGNEREC *pbd_Rec ) ;
int n_InitRec		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Rec		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptRec( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptRec	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


/**************************************************************************/
/*** Objet : Encapsulation du lot 5					***/
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
   char	sz_SysTime[9] ;

   pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
   pbd_SyncSEGEST = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncLABOCY = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncPERICASE = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncGT = malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncPer = malloc(sizeof(T_RUPTURE_SYNC_VAR));


   /* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

   /* Recuperation du parametre correspondant au type de segment */
   Kc_SEGTYP_CT = *(psz_GetCharArgv(1));

   /* Recuperation du parametre correspondant a la date de demande du batch */
   /* strcpy(Ksz_CRE_D, psz_GetCharArgv(2)); modifie le 03/02/98 */

   /* En controle des estimations, recuperation de CRE_D */
   if (Kc_SEGTYP_CT == 'E') {
      strcpy(Ksz_CRE_D, psz_GetCharArgv(2));
      Ksz_CRE_D[5] = '\0';
      Kn_CREYEA = atoi(Ksz_CRE_D);
   }

   /* En actuariat, recuperation de BALSHTYEA_NF */
   if (Kc_SEGTYP_CT == 'A') {
      Kn_BALSHTYEA = n_GetIntArgv(2);
   }

   /* modification et formatage de la date de creation */
   RecSysDate( Ksz_CRE_D, sz_SysTime ) ;
   FormatTime( sz_SysTime, sz_SysTime ) ;
   strcat( Ksz_CRE_D, " " ) ;
   strcat( Ksz_CRE_D, sz_SysTime ) ;

   /* Recuperation du parametre correspondant a la liste des filiales */
   strcpy(Ksz_SSD_LL, psz_GetCharArgv(3));

   /* Recuperation du parametre correspondant a la liste des numeros de version */
   strcpy(Ksz_VRS_LL, psz_GetCharArgv(4));

   if (Kc_SEGTYP_CT == 'A') {
     /* Recuperation du parametre correspondant au type d'inventaire */
      Kc_INVTYP = *(psz_GetCharArgv(5));

      /* Recuperation du parametre correspondant a la date libelle d'inventaire */
      strcpy(Ksz_CLODAT_D, psz_GetCharArgv(6));
   }


   /* Place les filiales dans le tableau des filiales */
   for (Kn_Compteur = 0; Ksz_SSD_LL[Kn_Compteur] != '\0'; Kn_Compteur++) {
      if (Ksz_SSD_LL[Kn_Compteur] == Kc_Delimiteur) {
         if (Kn_CompteurSousChaine != 0) {
            Ksz_SousChaine[Kn_CompteurSousChaine + 1] = '\0';
            Ktn_ListeFiliales[Kn_NbreFiliales] = atoi(Ksz_SousChaine);
            Kn_NbreFiliales++;
            Kn_CompteurSousChaine = 0;
         }
      }
      else {
         Ksz_SousChaine[Kn_CompteurSousChaine] = Ksz_SSD_LL[Kn_Compteur];
         Kn_CompteurSousChaine++;
     }
   }

   /* Place les versions dans le tableau des versions */
   /*   for (Kn_Compteur = 0; Ksz_VRS_LL[Kn_Compteur] != '\0'; Kn_Compteur++) {
      if (Ksz_VRS_LL[Kn_Compteur] == Kc_Delimiteur) {
         if (Kn_CompteurSousChaine != 0) {
            Ksz_SousChaine[Kn_CompteurSousChaine + 1] = '\0';
            Ktn_ListeVersions[Kn_NbreVersions] = atoi(Ksz_SousChaine);
            Kn_NbreVersions++;
            Kn_CompteurSousChaine = 0;
         }
      }
      else {
         Ksz_SousChaine[Kn_CompteurSousChaine] = Ksz_VRS_LL[Kn_Compteur];
         Kn_CompteurSousChaine++;
     }
   }
   */

   { /* Correction de la boucle par Mehdi le 29/01/1998 */
	char *p1, *p2;

	Kn_NbreVersions = 0 ;
	p1= Ksz_VRS_LL+1;

	while( (p2 = strchr(p1,'_')))
	{
		*p2=0;
		Ktn_ListeVersions[Kn_NbreVersions] = atoi(p1) ;
		p1=p2+1;
         	Kn_NbreVersions++;
	}
   }

   /* Pour debugage */
   /* for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++) {
      printf ("Filiale %d, version %d\n", Ktn_ListeFiliales[Kn_Compteur], Ktn_ListeVersions[Kn_Compteur]);
   } */


   /* Generation d'une anomalie quand le nombre de filiales est different du */
   /* nombre de versions */
   if (Kn_NbreFiliales != Kn_NbreVersions) {
      sprintf (Ksz_MessageErr, "Number of subsidaries different of number of versions");
      n_WriteAno(Ksz_MessageErr);
   }

   /* Ouverture du fichier des taux */
   if (n_OpenFileAppl("ESTC0606_I6", "rb", &Kp_GetTaux) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetTaux");
   }

   if (Kc_SEGTYP_CT == 'E') {
      /* Ouverture du fichier de sortie des ultimes */
      if (n_OpenFileAppl("ESTC0606_O1", "wt", &Kp_OutputFileUltimes) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
      }

      /* Ouverture du fichier de sortie des familles d'engagement */
      if (n_OpenFileAppl("ESTC0606_O2", "wt", &Kp_OutputFileFAMLIA) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
      }

      /* Ouverture du fichier de sortie des sections */
      if (n_OpenFileAppl("ESTC0606_O3", "wt", &Kp_OutputFileSECTION) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
      }
   }
   else {

      /* Ouverture du fichier de sortie des dommages */
      if (n_OpenFileAppl("ESTC0606_O1", "wt", &Kp_OutputFileDommages) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
      }

      /* Ouverture du fichier de sortie du GT */
      if (n_OpenFileAppl("ESTC0606_O2", "wt", &Kp_OutputFileGT) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
      }
   }

   /* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
     ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

   /* Initialisation de la structure de synchronisation avec TSEGEST */
   if (n_InitSyncSEGEST(pbd_SyncSEGEST) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncSEGEST");
   }

   /* Initialisation de la structure de synchronisation avec PERICASE */
   if (n_InitSyncPERICASE(pbd_SyncPERICASE) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncPERICASE");
   }

   if (Kc_SEGTYP_CT == 'E') {

     /* Initialisation de la structure de synchronisation avec PERIFR */
      if (n_InitRec(pbd_SyncPer) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_InitRec");
      }
   }

   else { /* Actuariat */

      /* Initialisation de la structure de synchronisation avec TLABOCY */
      if (n_InitSyncLABOCY(pbd_SyncLABOCY) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncLABOCY");
      }

      /* Initialisation de la structure de synchronisation avec le GT */
      if (n_InitSyncGT(pbd_SyncGT) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGT");
      }
   }

   /* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0606_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0606_I2", &(pbd_SyncSEGEST->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplSEGEST");
   }

   if (n_CloseFileAppl("ESTC0606_I3", &(pbd_SyncPERICASE->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplPERICASE");
   }

   if (n_CloseFileAppl("ESTC0606_I6", &Kp_GetTaux) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (Kc_SEGTYP_CT == 'E') {
      if (n_CloseFileAppl("ESTC0606_I4", &(pbd_SyncPer->pf_InputFil)) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplPERIFR");
      }

      if (n_CloseFileAppl("ESTC0606_O1", &Kp_OutputFileUltimes) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }

      if (n_CloseFileAppl("ESTC0606_O2", &Kp_OutputFileSECTION) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }

      if (n_CloseFileAppl("ESTC0606_O3", &Kp_OutputFileFAMLIA) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }
   }
   else { /* Actuariat */
      if (n_CloseFileAppl("ESTC0606_I4", &(pbd_SyncLABOCY->pf_InputFil)) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplLABOCY");
      }

      if (n_CloseFileAppl("ESTC0606_I5", &(pbd_SyncGT->pf_InputFil)) == ERR) {
         ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplGT");
      }

      if (n_CloseFileAppl("ESTC0606_O1", &Kp_OutputFileDommages) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }

      if (n_CloseFileAppl("ESTC0606_O2", &Kp_OutputFileGT) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncSEGEST);
   free(pbd_SyncLABOCY);
   free(pbd_SyncPERICASE);
   free(pbd_SyncPer);
   free(pbd_SyncGT);
   exit(Kb_ReturnStatus);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture                  ***/
/***									***/
/*** Nom : n_InitRupture    						***/
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
   if (n_OpenFileAppl("ESTC0606_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=2;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture1;
   pbd_Rupture->n_ConditionRupture[1]=n_TestRupture2;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture1;
   pbd_Rupture->n_ActionFirst[1]=n_ActionPremiereRupture2;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[1]=n_ActionDerniereRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation avec TSEGEST	        ***/
/***									***/
/*** Nom : n_InitSyncSEGEST  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncSEGEST(
   T_RUPTURE_SYNC_VAR  *pbd_SyncSEGEST
)
{
   DEBUT_FCT("n_InitSyncSEGEST");
   memset(pbd_SyncSEGEST, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier TSEGEST */
   if (n_OpenFileAppl("ESTC0606_I2", "rt", &(pbd_SyncSEGEST->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncSEGEST->ConditionEndSync=n_ConditionSyncSEGEST;
   pbd_SyncSEGEST->n_ActionLigne=n_ActionLigneSyncSEGEST;
   pbd_SyncSEGEST->n_PereSansFils=n_ActionPereSansFilsSEGEST;
   pbd_SyncSEGEST->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation avec PERICASE	        ***/
/***									***/
/*** Nom : n_InitSyncPERICASE  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncPERICASE(
   T_RUPTURE_SYNC_VAR  *pbd_SyncPERICASE
)
{
   DEBUT_FCT("n_InitSyncPERICASE");
   memset(pbd_SyncPERICASE, 0, sizeof(T_RUPTURE_SYNC_VAR));

   /* Ouverture du fichier PERICASE */
   if (n_OpenFileAppl("ESTC0606_I3", "rt", &(pbd_SyncPERICASE->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncPERICASE->ConditionEndSync=n_ConditionSyncPERICASE2;
   pbd_SyncPERICASE->n_ActionLigne=n_ActionLigneSyncPERICASE;
   pbd_SyncPERICASE->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation avec TLABOCY	        ***/
/***									***/
/*** Nom : n_InitSyncLABOCY  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncLABOCY(
   T_RUPTURE_SYNC_VAR  *pbd_SyncLABOCY
) {
   DEBUT_FCT("n_InitSyncLABOCY");
   memset(pbd_SyncLABOCY, 0, sizeof(T_RUPTURE_SYNC_VAR));

   /* Ouverture du fichier LABOCY */
   if (n_OpenFileAppl("ESTC0606_I4", "rt", &(pbd_SyncLABOCY->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncLABOCY->ConditionEndSync=n_ConditionSyncLABOCY;
   pbd_SyncLABOCY->n_ActionLigne=n_ActionLigneSyncLABOCY;
   pbd_SyncLABOCY->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation avec le GT	        ***/
/***									***/
/*** Nom : n_InitSyncGT  						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncGT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncGT
)
{
   DEBUT_FCT("n_InitSyncGT");
   memset(pbd_SyncGT, 0, sizeof(T_RUPTURE_SYNC_VAR));

   /* Ouverture du fichier GT */
   if (n_OpenFileAppl("ESTC0606_I5", "rt", &(pbd_SyncGT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncGT->ConditionEndSync=n_ConditionSyncGT;
   pbd_SyncGT->n_ActionLigne=n_ActionLigneSyncGT;
   pbd_SyncGT->c_Separ='~';

   RETURN_VAL(OK);
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Liste des affaires » avec
	l'esclave « Parametres de reconstitution »

retour :
	OK
==============================================================================*/
int n_InitRec(T_RUPTURE_SYNC_VAR  *pbd_Rupt) {
	DEBUT_FCT( "n_InitRec" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Parametres de reconstitution */
	if ( n_OpenFileAppl( "ESTC0606_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier Parametres de reconstitution */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Rec ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncRec ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptRec ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptRec ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneRec ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncRec(
	char **ptsz_LigneMaitre ,  /* adresse de la ligne du maitre */
	char **ptsz_LigneEsclave  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncRec" ) ;

   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEG_NF], ptsz_LigneEsclave[PERFR_SEGTYP_CT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_UWY_NF], ptsz_LigneEsclave[PERFR_UWY_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_EGPCUR_CF], ptsz_LigneEsclave[PERFR_SSD_CF]))) {
      return ret;
   }
   if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneEsclave[PERFR_CTR_NF]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].END_NT - (short)atoi(ptsz_LigneEsclave[PERFR_END_NT]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF - (short)atoi(ptsz_LigneEsclave[PERFR_SEC_NF]))) {
      return ret;
   }
   return (Ktbd_CASEX[Kn_CompteurCASEX].UW_NT - (short)atoi(ptsz_LigneEsclave[PERFR_UW_NT]));
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Rec(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Rec" ) ;

	if ( ( ret = strcmp( pbd_InRec[PERFR_CTR_NF], pbd_InRec_Cur[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_END_NT], pbd_InRec_Cur[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_SEC_NF], pbd_InRec_Cur[PERFR_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UWY_NF], pbd_InRec_Cur[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UW_NT], pbd_InRec_Cur[PERFR_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFirstRuptRec" ) ;

	/* initialisation de la variable du rang de reconstitution */
	Kn_RecRnk = 0 ;

	RETURN_VAL ( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneRec(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneRec" ) ;

	/* Copie des rubriques du fichier Parametres de reconstitution vers une variable de type LigneRec */
	n_CopyRec( ptb_InRecChild, &Kbd_Rec[ Kn_RecRnk++ ] ) ;

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptRec(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLastRuptRec" ) ;

	/* Positionnememt de la variable de participation */
/*	Kn_Pa += 4 ;	*/

	RETURN_VAL ( OK ) ;
}


/**************************************************************************/
/*** Objet : fonction de test de rupture 1 (uniquement en actuariat)	***/
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

int n_TestRupture1(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static int n_Ret;

   if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
      return n_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]));
}


/**************************************************************************/
/*** Objet : fonction de test de rupture 2				***/
/***									***/
/*** Nom : n_TestRupture2     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture2(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static int n_Ret;

   if (Kc_SEGTYP_CT == 'E') {
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEEST_SEG_NF], ptsz_LigneCour[CASEEST_SEG_NF]))) {
         return n_Ret;
      }
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEEST_UWY_NF], ptsz_LigneCour[CASEEST_UWY_NF]))) {
         return n_Ret;
      }
      return (strcmp(ptsz_LigneSuiv[CASEEST_EGPCUR_CF], ptsz_LigneCour[CASEEST_EGPCUR_CF]));
   }
   else {
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF]))) {
         return n_Ret;
      }
      if ((n_Ret=strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]))) {
         return n_Ret;
      }
      return (strcmp(ptsz_LigneSuiv[CASEACT_EGPCUR_CF], ptsz_LigneCour[CASEACT_EGPCUR_CF]));
   }
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere 1 du ***/
/***         fichier maitre (uniquement en actuariat)			***/
/***									***/
/*** Nom : n_ActionPremiereRupture1					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture1(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture1");

   if (Kc_SEGTYP_CT == 'A') {
      Kn_NbreEXER = 0;

      /* Remplissage de la structure des exercices de survenance du segment */
      /* Pas de ventilation par exercice de survenance en Proportionnel     */
      n_ProcessingRuptureSyncVar(pbd_SyncLABOCY, ptsz_LigneCour);
   }

   if (Kc_SEGTYP_CT == 'E') {
      if (*ptsz_LigneCour[CASEEST_SEG_NF] == '\0') {
         Ks_SegmentNul = 1;
         RETURN_VAL(OK);
      }
   }
   else if (Kc_SEGTYP_CT == 'A') {
      if (*ptsz_LigneCour[CASEACT_SEG_NF] == '\0') {
         Ks_SegmentNul = 1;
         RETURN_VAL(OK);
      }
   }

   Ks_SegmentNul = 0;

   /* Remplissage de la structure du segment */
   n_ProcessingRuptureSyncVar(pbd_SyncSEGEST, ptsz_LigneCour);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere 2 du ***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture2					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture2(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture2");

   /* printf("Nouveau SEG/UWY/EGPCUR\n"); */

   Kn_NbreCASEX = 0;

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
   double d_Sai;     /* Contient la valeur de Sai */
   double d_Montant; /* Contient l'IBNR */

   DEBUT_FCT("n_ActionLigneRupture");

   Kptsz_PERIMASTER = ptsz_LigneCour;

   /* Si segment non nul */
   if (Ks_SegmentNul == 0) {
      if (Kn_NbreCASEX == SEGEXERDEV_MAX) {
         sprintf (Ksz_MessageErr, "SEG %s, UWY %d : maximum number of CTR/END/SEC is reached ; increase SEGEXERDEV_MAX value", Kbd_SEG.SEG_NF, Kbd_SEG.UWY_NF);

         /* Modif 28/01/98 : ecriture dans le .ano au lieu du .log */
         /*n_WriteLog('E', Ksz_MessageErr);*/
         n_WriteAno(Ksz_MessageErr);

        /* et 'plantage' du programme */
         Kb_ReturnStatus=1;
      }
      else {
         if (Kc_SEGTYP_CT == 'E') {
            strcpy(Ktbd_CASEX[Kn_NbreCASEX].CTR_NF, ptsz_LigneCour[CASEEST_CTR_NF]);
            Ktbd_CASEX[Kn_NbreCASEX].END_NT = (short)(atoi(ptsz_LigneCour[CASEEST_END_NT]));
            Ktbd_CASEX[Kn_NbreCASEX].SEC_NF = (short)(atoi(ptsz_LigneCour[CASEEST_SEC_NF]));
            Ktbd_CASEX[Kn_NbreCASEX].UW_NT = (short)(atoi(ptsz_LigneCour[CASEEST_UW_NT]));
            strcpy(Ktbd_CASEX[Kn_NbreCASEX].EGPCUR_CF, ptsz_LigneCour[CASEEST_EGPCUR_CF]);
            Ktbd_CASEX[Kn_NbreCASEX].ModeGestion = *(ptsz_LigneCour[CASEEST_Ssi_CT]);
            Ktbd_CASEX[Kn_NbreCASEX].Pa = atof(ptsz_LigneCour[CASEEST_Pai_M]);
            Ktbd_CASEX[Kn_NbreCASEX].PA = atof(ptsz_LigneCour[CASEEST_PAi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Ps = atof(ptsz_LigneCour[CASEEST_Psi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Ss = atof(ptsz_LigneCour[CASEEST_Ssi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Sci = atof(ptsz_LigneCour[CASEEST_Scii_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Scc = atof(ptsz_LigneCour[CASEEST_Scci_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Scca = 0 ;
            Ktbd_CASEX[Kn_NbreCASEX].CALAMTPRM_M = atof(ptsz_LigneCour[CASEEST_CALAMTPRM_M]);
            Ktbd_CASEX[Kn_NbreCASEX].ENTAMTPRM_M = atof(ptsz_LigneCour[CASEEST_ENTAMTPRM_M]);
            Ktbd_CASEX[Kn_NbreCASEX].ADMMODPRM_CT = *(ptsz_LigneCour[CASEEST_ADMMODPRM_CT]);
            Ktbd_CASEX[Kn_NbreCASEX].CALAMTCLM_M = atof(ptsz_LigneCour[CASEEST_CALAMTCLM_M]);
            Ktbd_CASEX[Kn_NbreCASEX].ENTAMTCLM_M = atof(ptsz_LigneCour[CASEEST_ENTAMTCLM_M]);
         }
         else {
            strcpy(Ktbd_CASEX[Kn_NbreCASEX].CTR_NF, ptsz_LigneCour[CASEACT_CTR_NF]);
            Ktbd_CASEX[Kn_NbreCASEX].END_NT = (short)(atoi(ptsz_LigneCour[CASEACT_END_NT]));
            Ktbd_CASEX[Kn_NbreCASEX].SEC_NF = (short)(atoi(ptsz_LigneCour[CASEACT_SEC_NF]));
            Ktbd_CASEX[Kn_NbreCASEX].UW_NT = (short)(atoi(ptsz_LigneCour[CASEACT_UW_NT]));
            strcpy(Ktbd_CASEX[Kn_NbreCASEX].EGPCUR_CF, ptsz_LigneCour[CASEACT_EGPCUR_CF]);
            Ktbd_CASEX[Kn_NbreCASEX].ModeGestion = *(ptsz_LigneCour[CASEACT_Sai_CT]);
            Ktbd_CASEX[Kn_NbreCASEX].PA = atof(ptsz_LigneCour[CASEACT_PAi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].PAa = atof(ptsz_LigneCour[CASEACT_PAai_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Ps = atof(ptsz_LigneCour[CASEACT_Psi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Ss = atof(ptsz_LigneCour[CASEACT_Ssi_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Sci = atof(ptsz_LigneCour[CASEACT_Scii_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Scc = atof(ptsz_LigneCour[CASEACT_Scci_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Scca = atof(ptsz_LigneCour[CASEACT_Sccai_M]);
            Ktbd_CASEX[Kn_NbreCASEX].Sa = atof(ptsz_LigneCour[CASEACT_Sai_M]);
            Ktbd_CASEX[Kn_NbreCASEX].CALAMTPRM_M = atof(ptsz_LigneCour[CASEACT_ENTAMT_M]);
         }
         Kn_NbreCASEX++;
      }
   }


   /* Si aucun segment rattache a l'affaire : ecriture dans le GT d'une ligne */
   else if (Kc_SEGTYP_CT == 'A') {
      if (*ptsz_LigneCour[CASEACT_Sai_CT] == 'F') {
         d_Sai = atof(ptsz_LigneCour[CASEACT_Sai_M]);
           }
      else {
           if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                d_Sai = atof(ptsz_LigneCour[CASEACT_Scci_M]) + atof(ptsz_LigneCour[CASEACT_Sccai_M]);
                }
           else {    /* Facultatives et Non Proportionnels */
                d_Sai = atof(ptsz_LigneCour[CASEACT_Scii_M]);
           }
      }


      pbd_SyncPERICASE->ConditionEndSync=n_ConditionSyncPERICASE1;
      n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptsz_LigneCour);
      pbd_SyncPERICASE->ConditionEndSync=n_ConditionSyncPERICASE2;


      /* Recherche du numero de version */
      Kn_VRS_NF = 0; /* valeur par defaut */
      for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++) {
	 if (Ktn_ListeFiliales[Kn_Compteur] == atoi(Kptsz_PERIMASTER[PER_SSD_CF])) {
	    Kn_VRS_NF = Ktn_ListeVersions[Kn_Compteur];
	 }
      }

      /* Ecriture des resultats dans le fichier des dommages si inventaire principal et non force */
      if ( ( *ptsz_LigneCour[CASEACT_Sai_CT] != 'F' ) && ( Kc_INVTYP == 'P' ) ) {
	 fprintf( Kp_OutputFileDommages, "%s~%s~%s~%s~%s~%s~%d~%d~%s~%s~%s~%-.3lf~%-.3lf~%-.3lf~%c~%s~%d~~%s~%s~\n",
		  ptsz_LigneCour[CASEACT_CTR_NF],
		  ptsz_LigneCour[CASEACT_END_NT],
		  ptsz_LigneCour[CASEACT_SEC_NF],
		  ptsz_LigneCour[CASEACT_UWY_NF],
		  ptsz_LigneCour[CASEACT_UW_NT],
		  Ksz_CRE_D,
		  710,
		  20000,
		  Kptsz_PERICASE[PER_SSD_CF],
		  Kptsz_PERICASE[PER_DIV_NT],
		  ptsz_LigneCour[CASEACT_EGPCUR_CF],
		  d_Sai,
		  atof( ptsz_LigneCour[CASEACT_ENTAMT_M] ),
		  d_Sai,
		  'A',
		  Ksz_CLODAT_D,
		  Kn_VRS_NF,
		  "CloP",
		  Ksz_CRE_D ) ;
      }

      if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
         if (fabs(d_Montant = atof(ptsz_LigneCour[CASEACT_Sccai_M]))> 0.001) {
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                    Kptsz_PERICASE[PER_SSD_CF],
                    Kptsz_PERICASE[PER_ACCESB_CF],
                    Ksz_CLODAT_D[0],
                    Ksz_CLODAT_D[1],
                    Ksz_CLODAT_D[2],
                    Ksz_CLODAT_D[3],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Ksz_CLODAT_D[6],
                    Ksz_CLODAT_D[7],
                    11494002,
                    Kptsz_PERICASE[PER_CTR_NF],
                    Kptsz_PERICASE[PER_END_NT],
                    Kptsz_PERICASE[PER_SEC_NF],
                    Kptsz_PERICASE[PER_UWY_NF],
                    Kptsz_PERICASE[PER_UW_NT],
                    Kptsz_PERICASE[PER_UWY_NF],
                    Ksz_CLODAT_D[0],
                    Ksz_CLODAT_D[1],
                    Ksz_CLODAT_D[2],
                    Ksz_CLODAT_D[3],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Kptsz_PERICASE[PER_EGPCUR_CF],
                    d_Montant,
                    Kptsz_PERICASE[PER_CED_NF],
                    Kptsz_PERICASE[PER_PRD_NF],
                    Kptsz_PERICASE[PER_GENPRMPAY_NF],
                    Kptsz_PERICASE[PER_GANPAYORD_NT]
            );
         }

	 if (fabs(d_Montant = (-atof(ptsz_LigneCour[CASEACT_Scii_M]) - atof(ptsz_LigneCour[CASEACT_Sccai_M])))>0.001 ) {
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                    Kptsz_PERICASE[PER_SSD_CF],
                    Kptsz_PERICASE[PER_ACCESB_CF],
                    Ksz_CLODAT_D[0],
                    Ksz_CLODAT_D[1],
                    Ksz_CLODAT_D[2],
                    Ksz_CLODAT_D[3],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Ksz_CLODAT_D[6],
                    Ksz_CLODAT_D[7],
                    11494052,
                    Kptsz_PERICASE[PER_CTR_NF],
                    Kptsz_PERICASE[PER_END_NT],
                    Kptsz_PERICASE[PER_SEC_NF],
                    Kptsz_PERICASE[PER_UWY_NF],
                    Kptsz_PERICASE[PER_UW_NT],
                    Kptsz_PERICASE[PER_UWY_NF],
                    Ksz_CLODAT_D[0],
                    Ksz_CLODAT_D[1],
  		    Ksz_CLODAT_D[2],
                    Ksz_CLODAT_D[3],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Ksz_CLODAT_D[4],
                    Ksz_CLODAT_D[5],
                    Kptsz_PERICASE[PER_EGPCUR_CF],
                    d_Montant,
                    Kptsz_PERICASE[PER_CED_NF],
                    Kptsz_PERICASE[PER_PRD_NF],
                    Kptsz_PERICASE[PER_GENPRMPAY_NF],
                    Kptsz_PERICASE[PER_GANPAYORD_NT]
            );
         }
      }

      if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
         d_Montant = d_Sai - atof(ptsz_LigneCour[CASEACT_Sccai_M]) -  atof(ptsz_LigneCour[CASEACT_Scci_M]) ;
      }
      else {
         d_Montant = d_Sai - (atof(ptsz_LigneCour[CASEACT_Scii_M]) + atof(ptsz_LigneCour[CASEACT_Scci_M]));
      }
      if (fabs(d_Montant) > 0.001) {
         fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                 Kptsz_PERICASE[PER_SSD_CF],
                 Kptsz_PERICASE[PER_ACCESB_CF],
                 Ksz_CLODAT_D[0],
                 Ksz_CLODAT_D[1],
                 Ksz_CLODAT_D[2],
                 Ksz_CLODAT_D[3],
                 Ksz_CLODAT_D[4],
                 Ksz_CLODAT_D[5],
                 Ksz_CLODAT_D[6],
                 Ksz_CLODAT_D[7],
                 11494102,
                 Kptsz_PERICASE[PER_CTR_NF],
                 Kptsz_PERICASE[PER_END_NT],
                 Kptsz_PERICASE[PER_SEC_NF],
                 Kptsz_PERICASE[PER_UWY_NF],
                 Kptsz_PERICASE[PER_UW_NT],
                 Kptsz_PERICASE[PER_UWY_NF],
                 Ksz_CLODAT_D[0],
                 Ksz_CLODAT_D[1],
                 Ksz_CLODAT_D[2],
                 Ksz_CLODAT_D[3],
                 Ksz_CLODAT_D[4],
                 Ksz_CLODAT_D[5],
                 Ksz_CLODAT_D[4],
                 Ksz_CLODAT_D[5],
                 Kptsz_PERICASE[PER_EGPCUR_CF],
                 d_Montant,
                 Kptsz_PERICASE[PER_CED_NF],
                 Kptsz_PERICASE[PER_PRD_NF],
                 Kptsz_PERICASE[PER_GENPRMPAY_NF],
                 Kptsz_PERICASE[PER_GANPAYORD_NT]
         );
      }
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
   static double d_Montant; /* Montant acceptation cedante */
   static double d_SP;      /* Rapport S/P */
   static int n_DIV;        /* Champ DIV_NT */

   DEBUT_FCT("n_ActionDerniereRupture");

   /* Si segment non nul */
   if (Ks_SegmentNul == 0) {

      /* Cas controle des estimations */
      if (Kc_SEGTYP_CT == 'E') {

	 /* Pour debugage */
	 /*printf("Nature de segment : %c ; nbre d'affaires : %d\n", *ptsz_LigneCour[CASEEST_CTRNAT_CT], Kn_NbreCASEX);
         printf("Donnees du segment : Pa %lf ; Sc : %lf ; Ss : %lf\n", Kbd_SEG.Pa, Kbd_SEG.Sc, Kbd_SEG.Ss);
         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            printf("Donnees de l'affaire %d : Pa %lf ; Sc : %lf ; Ss : %lf\n", Kn_CompteurCASEX, Ktbd_CASEX[Kn_CompteurCASEX].Pa, Ktbd_CASEX[Kn_CompteurCASEX].Sci, Ktbd_CASEX[Kn_CompteurCASEX].Ss);
         }*/

	 /* Appel lot 5 */
	 n_SinisCtrEst(*ptsz_LigneCour[CASEEST_CTRNAT_CT], Kn_NbreCASEX, &Kbd_SEG, Ktbd_CASEX);

         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            if (Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion != 'F') {

	       /* Pour debugage */
	       /*printf("Contrat %s, avenant %d, section %d, exercice %d, numero d'ordre %d dans action derniere...\n",
                      Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF,
                      Ktbd_CASEX[Kn_CompteurCASEX].END_NT,
                      Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF,
                      Kbd_SEG.UWY_NF,
                      Ktbd_CASEX[Kn_CompteurCASEX].UW_NT
               );*/

               if (b_EOF_MAITRE == TRUE) {/* Permet d'empecher un pere sans fils */
                  b_EOF_MAITRE = FALSE;   /* lors du traitement du dernier bloc */
               }

	       /* Ecriture des resultats dans le fichier des ultimes si non force */
	       n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptsz_LigneCour);
	       if ( *Kptsz_PERICASE[PER_CTRNAT_CT] == 'N' ) {

		  if ( *Kptsz_PERICASE[PER_PRMFLCRAT_B] == '1' ) {

		     if ( *Kptsz_PERICASE[PER_FLAPRM_B] == '0' ) {

		        Kd_Reconstitution=0;
               		Kd_BurningCost =
			d_CalculBurningCost((unsigned char)atoi(Kptsz_PERICASE[PER_SUPLOATYP_CT]),
				atof(Kptsz_PERICASE[PER_SBJPRM_M]),
                        	Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
				atof(Kptsz_PERICASE[PER_PRMMINEFF_R]),
				atof(Kptsz_PERICASE[PER_PRMMAXEFF_R]),
                        	atof(Kptsz_PERICASE[PER_PRMEFFLOA_M]),
                        	atof(Kptsz_PERICASE[PER_PRMEFFLOA_R]),
                        	atof(Kptsz_PERICASE[PER_CUTSHA_R]),
                        	atof(Kptsz_PERICASE[PER_RIDSHA_R]),
                        	(unsigned char)atoi(Kptsz_PERICASE[PER_LIARIDSHA_B]));

			/* pour debugage
		printf("SUPLOATYP %d \n SBJPRMM %lf \n Ssi %lf \n PRMMINEFF %lf \n PRMMAXEFF %lf \n PRMEFFLOAM %lf \n PRMEFFLOAR %lf CUTSHAR %lf \n RIDSHAR %lf \n LIARIDSHA %d \n",
              	atoi(Kptsz_PERICASE[PER_SUPLOATYP_CT]),
               	atof(Kptsz_PERICASE[PER_SBJPRM_M]),
               	Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
               	atof(Kptsz_PERICASE[PER_PRMMINEFF_R]),
               	atof(Kptsz_PERICASE[PER_PRMMAXEFF_R]),
               	atof(Kptsz_PERICASE[PER_PRMEFFLOA_M]),
               	atof(Kptsz_PERICASE[PER_PRMEFFLOA_R]),
               	atof(Kptsz_PERICASE[PER_CUTSHA_R]),
               	atof(Kptsz_PERICASE[PER_RIDSHA_R]),
               	atoi(Kptsz_PERICASE[PER_LIARIDSHA_B]));
		printf ("LIARIDSHA %d BC %lf \n",PER_LIARIDSHA_B, Kd_BurningCost);
		*/
		}
		/************************************************/
		/* Modifs du 02/04/98 - M.HA-THUC		*/
		/* Rajout d'un cas pour le calcul de reconstit	*/
		/************************************************/
		else
		{
			n_ProcessingRuptureSyncVar(pbd_SyncPer,ptsz_LigneCour);
			Kd_BurningCost=0;
			Kd_Reconstitution = d_CalculPrimeReconstitution(
				(unsigned char)atoi(Kptsz_PERICASE[PER_REIEXI_B]),
				(unsigned char)atoi(Kptsz_PERICASE[PER_REIUNL_B]),
				(unsigned char)atoi(Kptsz_PERICASE[PER_REIFRE_B]),
				(unsigned char)atoi(Kptsz_PERICASE[PER_REINBR_N]),
				atof(Kptsz_PERICASE[PER_SBJPRM_M]),
				Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
				Ktbd_CASEX[Kn_CompteurCASEX].Ps,
				atof(Kptsz_PERICASE[PER_LAYCAP_M]),
				atof(Kptsz_PERICASE[PER_CUTSHA_R]),
				atof(Kptsz_PERICASE[PER_RIDSHA_R]),
				(unsigned char)atoi(Kptsz_PERICASE[PER_LIARIDSHA_B]),
				Kbd_Rec);
		}
	}
        else
	{
                n_ProcessingRuptureSyncVar(pbd_SyncPer,ptsz_LigneCour);
		Kd_BurningCost=0;
		Kd_Reconstitution = d_CalculPrimeReconstitution(
	(unsigned char)atoi(Kptsz_PERICASE[PER_REIEXI_B]),
	(unsigned char)atoi(Kptsz_PERICASE[PER_REIUNL_B]),
	(unsigned char)atoi(Kptsz_PERICASE[PER_REIFRE_B]),
	(unsigned char)atoi(Kptsz_PERICASE[PER_REINBR_N]),
			atof(Kptsz_PERICASE[PER_SBJPRM_M]),
			Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
			Ktbd_CASEX[Kn_CompteurCASEX].Ps,
			atof(Kptsz_PERICASE[PER_LAYCAP_M]),
			atof(Kptsz_PERICASE[PER_CUTSHA_R]),
			atof(Kptsz_PERICASE[PER_RIDSHA_R]),
	(unsigned char)atoi(Kptsz_PERICASE[PER_LIARIDSHA_B]),
			Kbd_Rec);

/* Pour debugage */
/*		printf("REIEXI %c \n REIUNL %c \n REIFRE %c \n REINBR %c \n SBJPRM %lf \n Ss %lf \n Ps %lf \n LAYCAP %lf \n CUTSHA %lf \n RIDSHA %lf \n LIARIDSHA %c \n REIRNK0 %d REIPRMBAS0 %lf REIPRMM0 %lf REIPRMR0 %lf \n REIRNK1 %d REIPRMBAS1 %lf REIPRMM1 %lf REIPRMR1 %lf \n",
			Kptsz_PERICASE[PER_REIEXI_B][0],
                        Kptsz_PERICASE[PER_REIUNL_B][0],
                        Kptsz_PERICASE[PER_REIFRE_B][0],
                        Kptsz_PERICASE[PER_REINBR_N][0],
                        atof(Kptsz_PERICASE[PER_SBJPRM_M]),
                        Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
                        Ktbd_CASEX[Kn_CompteurCASEX].Ps,
                        atof(Kptsz_PERICASE[PER_LAYCAP_M]),
                        atof(Kptsz_PERICASE[PER_CUTSHA_R]),
                        atof(Kptsz_PERICASE[PER_RIDSHA_R]),
                        Kptsz_PERICASE[PER_LIARIDSHA_B][0],
			Kbd_Rec[0].REIRNK_N,
			Kbd_Rec[0].REIPRMBAS_R,
			Kbd_Rec[0].REIPRM_M,
			Kbd_Rec[0].REIPRM_R,
			Kbd_Rec[1].REIRNK_N,
			Kbd_Rec[1].REIPRMBAS_R,
			Kbd_Rec[1].REIPRM_M,
			Kbd_Rec[1].REIPRM_R); */
	}
    }

/* Recherche du numero de version */
               Kn_VRS_NF = 0; /* valeur par defaut */
               for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++) {
                  if (Ktn_ListeFiliales[Kn_Compteur] == atoi(Kptsz_PERIMASTER[PER_SSD_CF])) {
                     Kn_VRS_NF = Ktn_ListeVersions[Kn_Compteur];
                  }
               }

/* Affectation de DIV_NT */
               if (*Kptsz_PERICASE[PER_CTRNAT_CT] == 'F') {
                  n_DIV = atoi(Kptsz_PERICASE[PER_DIV_NT]);
               }
               else {
                  n_DIV = 0;
               }

               fprintf(Kp_OutputFileUltimes, "%s~%s~%s~%s~%s~%s~%s~%d~%s~%-.3lf~%-.3lf~%-.3lf~%c~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%c~%d~%s~~%s~\n",
                       Kptsz_PERICASE[PER_CTR_NF],
                       Kptsz_PERICASE[PER_END_NT],
                       Kptsz_PERICASE[PER_SEC_NF],
                       Kptsz_PERICASE[PER_UWY_NF],
                       Kptsz_PERICASE[PER_UW_NT],
                       Ksz_CRE_D,
                       Kptsz_PERICASE[PER_SSD_CF],
                       n_DIV,
                       Kptsz_PERICASE[PER_EGPCUR_CF],
                       Ktbd_CASEX[Kn_CompteurCASEX].CALAMTPRM_M,
                       Ktbd_CASEX[Kn_CompteurCASEX].ENTAMTPRM_M,
                       Ktbd_CASEX[Kn_CompteurCASEX].Ps,
                       Ktbd_CASEX[Kn_CompteurCASEX].ADMMODPRM_CT,
                       Kd_BurningCost+Kd_Reconstitution,
                       Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
                       Ktbd_CASEX[Kn_CompteurCASEX].ENTAMTCLM_M,
                       Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M,
                       'A',
                       Kn_VRS_NF,
                       ptsz_LigneCour[CASEEST_SEG_NF],
                       Ksz_CRE_D
               );
            }

/* Ecriture des resultats dans le fichier TFAMLIA dans tous les cas */
               if (Ktbd_CASEX[Kn_CompteurCASEX].Ps == 0) {
                  d_SP = 0;
               }

/* S/P toujours positif : la prime de souscription retenue est utilisee */
               else {
                  d_SP = - Ktbd_CASEX[Kn_CompteurCASEX].CALAMTCLM_M / (Ktbd_CASEX[Kn_CompteurCASEX].Ps * 100);
               }
               fprintf(Kp_OutputFileFAMLIA, "%s~%d~%d~%d~%d~%-.3lf\n",
                       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF,
                       Ktbd_CASEX[Kn_CompteurCASEX].END_NT,
                       Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF,
                       Kbd_SEG.UWY_NF,
                       Ktbd_CASEX[Kn_CompteurCASEX].UW_NT,
                       d_SP /* Champ PMLRAT_R */
               );

/* Ecriture des resultats dans le fichier TSECTION dans tous les cas */
            fprintf(Kp_OutputFileSECTION, "%s~%d~%d~%d~%d~%c~%c\n",
                    Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF,
                    Ktbd_CASEX[Kn_CompteurCASEX].END_NT,
                    Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF,
                    Kbd_SEG.UWY_NF,
                    Ktbd_CASEX[Kn_CompteurCASEX].UW_NT,
                    'I', /* Champ ESTUPDTYP */
                    'N'  /* Champ ESTCRB */
            );
         }
      }


/* Cas actuariat */

      else {

/* Remplissage de la structure IBNR */
         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            for (Kn_CompteurEXER = 0; Kn_CompteurEXER < Kn_NbreEXER; Kn_CompteurEXER++) {
               strcpy(Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].CTR_NF, Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF);
               Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].END_NT = Ktbd_CASEX[Kn_CompteurCASEX].END_NT;
               Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].SEC_NF = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF;
               Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].UW_NT = Ktbd_CASEX[Kn_CompteurCASEX].UW_NT;
               Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].EXER_NF = Ktbd_EXER[Kn_CompteurEXER].EXER_NF;
            }
          }


/* Pour debugage */
	 /*printf("Segment : %s ; UWY : %d ; nature : %c ; nbre d'affaires : %d ; Nbre exercices : %d\n", Kbd_SEG.SEG_NF, Kbd_SEG.UWY_NF, *ptsz_LigneCour[CASEEST_CTRNAT_CT], Kn_NbreCASEX, Kn_NbreEXER);
         printf("Donnees du segment : Ss %lf ; Sa : %lf\n", Kbd_SEG.Ss, Kbd_SEG.Sa);
         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            printf("Donnees de l'affaire %d Ss : %lf ; Sa : %lf ; Sci : %lf ; Scc : %lf\n", Kn_CompteurCASEX, Ktbd_CASEX[Kn_CompteurCASEX].Ss, Ktbd_CASEX[Kn_CompteurCASEX].Sa, Ktbd_CASEX[Kn_CompteurCASEX].Sci, Ktbd_CASEX[Kn_CompteurCASEX].Scc);
         }*/

	 /* Appel du lot 5 */
         n_SinisActu(*ptsz_LigneCour[CASEACT_CTRNAT_CT], Kn_NbreEXER, Kn_NbreCASEX, &Kbd_SEG, Ktbd_EXER, Ktbd_CASEX, Ktbd_IBNR);

/* Pour debugage */
/*         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            printf("Donnees de l'affaire %d Ss : %lf ; Sa : %lf ; Sci : %lf ; Scc : %lf\n", Kn_CompteurCASEX, Ktbd_CASEX[Kn_CompteurCASEX].Ss, Ktbd_CASEX[Kn_CompteurCASEX].Sa, Ktbd_CASEX[Kn_CompteurCASEX].Sci, Ktbd_CASEX[Kn_CompteurCASEX].Scc);
         }  */

         for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++) {
            if (b_EOF_MAITRE == TRUE) { /* Permet d'empecher un pere sans fils */
               b_EOF_MAITRE = FALSE;    /* lors du traitement du dernier bloc */
            }

/* Recherche du numero de version */
               Kn_VRS_NF = 0; /* valeur par defaut */
               for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++) {
                  if (Ktn_ListeFiliales[Kn_Compteur] == atoi(Kptsz_PERICASE[PER_SSD_CF])) {
                     Kn_VRS_NF = Ktn_ListeVersions[Kn_Compteur];
                  }
               }

/* Synchronisation avec le perimetre */
               n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptsz_LigneCour);

/* Ecriture des resultats dans le fichier des dommages si inventaire principal et non force */
            if ( (Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion != 'F') && (Kc_INVTYP == 'P') ) {
               fprintf(Kp_OutputFileDommages, "%s~%s~%s~%s~%s~%s~%d~%d~%s~%s~%s~%-.3lf~%-.3lf~%-.3lf~%c~%s~%d~%s~%s~%s~\n",
                       Kptsz_PERICASE[PER_CTR_NF],
                       Kptsz_PERICASE[PER_END_NT],
                       Kptsz_PERICASE[PER_SEC_NF],
                       Kptsz_PERICASE[PER_UWY_NF],
                       Kptsz_PERICASE[PER_UW_NT],
                       Ksz_CRE_D,
                       710,
                       20000,
                       Kptsz_PERICASE[PER_SSD_CF],
                       Kptsz_PERICASE[PER_DIV_NT],
                       Kptsz_PERICASE[PER_EGPCUR_CF],
                       Ktbd_CASEX[Kn_CompteurCASEX].Sa,
/* Champ ENTMAMT_M initial dans le champ CALAMTPRM_M de la structure */
                       Ktbd_CASEX[Kn_CompteurCASEX].CALAMTPRM_M,
                       Ktbd_CASEX[Kn_CompteurCASEX].Sa,
                       'A',
                       Ksz_CLODAT_D,
                       Kn_VRS_NF,
                       Kbd_SEG.SEG_NF,
                       "CloP",
                       Ksz_CRE_D
               );
            }

/* Ecriture des resultats dans le fichier GT */

/* Existence d'exercice de survenances */
            if (Kn_NbreEXER) {
               for (Kn_CompteurEXER = 0; Kn_CompteurEXER < Kn_NbreEXER; Kn_CompteurEXER++) {


/* Pour debugage */
/*          printf("SEG : %s ; EXER : %d ; SPIRAT : %lf ; Sc : %lf ; IBNR : %lf; PIBNR : %lf\n",
                      Kbd_SEG.SEG_NF,
                      Ktbd_EXER[Kn_CompteurEXER].EXER_NF,
                      Ktbd_EXER[Kn_CompteurEXER].SPIRAT_R,
                      Ktbd_EXER[Kn_CompteurEXER].Sc,
                      Ktbd_EXER[Kn_CompteurEXER].IBNR,
                      Ktbd_EXER[Kn_CompteurEXER].PIBNR
               ); */

/*             printf("CTR : %s ; END : %d ; SEC : %d ; UWY : %d ; UW : %d; IBNR : %lf\n",
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].CTR_NF,
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].END_NT,
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].SEC_NF,
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].EXER_NF,
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].UW_NT,
                      Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].IBNR
               ); */


                  Kd_Sccij = 0;
                  Kd_Sccaij = 0;
                  n_ProcessingRuptureSyncVar(pbd_SyncGT, ptsz_LigneCour);

                  if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                     if (fabs(d_Montant = Kd_Sccaij)>0.001) {
                        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                                Kptsz_PERICASE[PER_SSD_CF],
                                Kptsz_PERICASE[PER_ACCESB_CF],
                                Ksz_CLODAT_D[0],
                                Ksz_CLODAT_D[1],
                                Ksz_CLODAT_D[2],
                                Ksz_CLODAT_D[3],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Ksz_CLODAT_D[6],
                                Ksz_CLODAT_D[7],
                                11494002,
                                Kptsz_PERICASE[PER_CTR_NF],
                                Kptsz_PERICASE[PER_END_NT],
                                Kptsz_PERICASE[PER_SEC_NF],
                                Kptsz_PERICASE[PER_UWY_NF],
                                Kptsz_PERICASE[PER_UW_NT],
                                Ktbd_EXER[Kn_CompteurEXER].EXER_NF,
                                Ksz_CLODAT_D[0],
                                Ksz_CLODAT_D[1],
                                Ksz_CLODAT_D[2],
                                Ksz_CLODAT_D[3],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Kptsz_PERICASE[PER_EGPCUR_CF],
                                d_Montant,
                                Kptsz_PERICASE[PER_CED_NF],
                                Kptsz_PERICASE[PER_PRD_NF],
                                Kptsz_PERICASE[PER_GENPRMPAY_NF],
                                Kptsz_PERICASE[PER_GANPAYORD_NT]
                           );
                     }

                  }


                  if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                     if (fabs(d_Montant = -Kd_Sccaij /*-Kd_Sci <- initialise ds ActionLigneSyncGT... /// (-Sci-Scca) */)>0.001) {
                        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                                Kptsz_PERICASE[PER_SSD_CF],
                                Kptsz_PERICASE[PER_ACCESB_CF],
                                Ksz_CLODAT_D[0],
                                Ksz_CLODAT_D[1],
                                Ksz_CLODAT_D[2],
                                Ksz_CLODAT_D[3],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Ksz_CLODAT_D[6],
                                Ksz_CLODAT_D[7],
                                11494052,
                                Kptsz_PERICASE[PER_CTR_NF],
                                Kptsz_PERICASE[PER_END_NT],
                                Kptsz_PERICASE[PER_SEC_NF],
                                Kptsz_PERICASE[PER_UWY_NF],
                                Kptsz_PERICASE[PER_UW_NT],
                                Ktbd_EXER[Kn_CompteurEXER].EXER_NF,
                                Ksz_CLODAT_D[0],
                                Ksz_CLODAT_D[1],
                                Ksz_CLODAT_D[2],
                                Ksz_CLODAT_D[3],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Ksz_CLODAT_D[4],
                                Ksz_CLODAT_D[5],
                                Kptsz_PERICASE[PER_EGPCUR_CF],
                                d_Montant,
                                Kptsz_PERICASE[PER_CED_NF],
                                Kptsz_PERICASE[PER_PRD_NF],
                                Kptsz_PERICASE[PER_GENPRMPAY_NF],
                                Kptsz_PERICASE[PER_GANPAYORD_NT]
                           );
                     }

                  }

                  if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                     d_Montant = Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].IBNR - Kd_Sccaij;
                  }
                  else {
                     d_Montant = Ktbd_IBNR[Kn_CompteurCASEX*Kn_NbreEXER + Kn_CompteurEXER].IBNR;
                  }
                  if (fabs(d_Montant) > 0.001) {
                     fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                             Kptsz_PERICASE[PER_SSD_CF],
                             Kptsz_PERICASE[PER_ACCESB_CF],
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[6],
                             Ksz_CLODAT_D[7],
                             11494102,
                             Kptsz_PERICASE[PER_CTR_NF],
                             Kptsz_PERICASE[PER_END_NT],
                             Kptsz_PERICASE[PER_SEC_NF],
                             Kptsz_PERICASE[PER_UWY_NF],
                             Kptsz_PERICASE[PER_UW_NT],
                             Ktbd_EXER[Kn_CompteurEXER].EXER_NF,
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Kptsz_PERICASE[PER_EGPCUR_CF],
                             d_Montant,
                             Kptsz_PERICASE[PER_CED_NF],
                             Kptsz_PERICASE[PER_PRD_NF],
                             Kptsz_PERICASE[PER_GENPRMPAY_NF],
                             Kptsz_PERICASE[PER_GANPAYORD_NT]
                     );
                  }
               }
            }

/* Absence d'exercice de survenance */
            else {
               if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                  if (fabs(d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Scca)>0.001) {
                     fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                             Kptsz_PERICASE[PER_SSD_CF],
                             Kptsz_PERICASE[PER_ACCESB_CF],
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[6],
                             Ksz_CLODAT_D[7],
                             11494002,
                             Kptsz_PERICASE[PER_CTR_NF],
                             Kptsz_PERICASE[PER_END_NT],
                             Kptsz_PERICASE[PER_SEC_NF],
                             Kptsz_PERICASE[PER_UWY_NF],
                             Kptsz_PERICASE[PER_UW_NT],
                             Kptsz_PERICASE[PER_UWY_NF],
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Kptsz_PERICASE[PER_EGPCUR_CF],
                             d_Montant,
                             Kptsz_PERICASE[PER_CED_NF],
                             Kptsz_PERICASE[PER_PRD_NF],
                             Kptsz_PERICASE[PER_GENPRMPAY_NF],
                             Kptsz_PERICASE[PER_GANPAYORD_NT]
                     );
                  }
               }

               if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                  if (fabs(d_Montant = (-Ktbd_CASEX[Kn_CompteurCASEX].Sci -Ktbd_CASEX[Kn_CompteurCASEX].Scca))>0.001) {
                     fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                             Kptsz_PERICASE[PER_SSD_CF],
                             Kptsz_PERICASE[PER_ACCESB_CF],
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[6],
                             Ksz_CLODAT_D[7],
                             11494052,
                             Kptsz_PERICASE[PER_CTR_NF],
                             Kptsz_PERICASE[PER_END_NT],
                             Kptsz_PERICASE[PER_SEC_NF],
                             Kptsz_PERICASE[PER_UWY_NF],
                             Kptsz_PERICASE[PER_UW_NT],
                             Kptsz_PERICASE[PER_UWY_NF],
                             Ksz_CLODAT_D[0],
                             Ksz_CLODAT_D[1],
                             Ksz_CLODAT_D[2],
                             Ksz_CLODAT_D[3],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Ksz_CLODAT_D[4],
                             Ksz_CLODAT_D[5],
                             Kptsz_PERICASE[PER_EGPCUR_CF],
                             d_Montant,
                             Kptsz_PERICASE[PER_CED_NF],
                             Kptsz_PERICASE[PER_PRD_NF],
                             Kptsz_PERICASE[PER_GENPRMPAY_NF],
                             Kptsz_PERICASE[PER_GANPAYORD_NT]
                     );
                  }
               }

               if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P') {
                  d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Sa - Ktbd_CASEX[Kn_CompteurCASEX].Scca - Ktbd_CASEX[Kn_CompteurCASEX].Scc;
               }
               else {
                  d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Sa - Ktbd_CASEX[Kn_CompteurCASEX].Sci - Ktbd_CASEX[Kn_CompteurCASEX].Scc;
               }

               if (fabs(d_Montant) > 0.001) {
                  fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~\n",
                          Kptsz_PERICASE[PER_SSD_CF],
                          Kptsz_PERICASE[PER_ACCESB_CF],
                          Ksz_CLODAT_D[0],
                          Ksz_CLODAT_D[1],
                          Ksz_CLODAT_D[2],
                          Ksz_CLODAT_D[3],
                          Ksz_CLODAT_D[4],
                          Ksz_CLODAT_D[5],
                          Ksz_CLODAT_D[6],
                          Ksz_CLODAT_D[7],
                          11494102,
                          Kptsz_PERICASE[PER_CTR_NF],
                          Kptsz_PERICASE[PER_END_NT],
                          Kptsz_PERICASE[PER_SEC_NF],
                          Kptsz_PERICASE[PER_UWY_NF],
                          Kptsz_PERICASE[PER_UW_NT],
                          Kptsz_PERICASE[PER_UWY_NF],
                          Ksz_CLODAT_D[0],
                          Ksz_CLODAT_D[1],
                          Ksz_CLODAT_D[2],
                          Ksz_CLODAT_D[3],
                          Ksz_CLODAT_D[4],
                          Ksz_CLODAT_D[5],
                          Ksz_CLODAT_D[4],
                          Ksz_CLODAT_D[5],
                          Kptsz_PERICASE[PER_EGPCUR_CF],
                          d_Montant,
                          Kptsz_PERICASE[PER_CED_NF],
                          Kptsz_PERICASE[PER_PRD_NF],
                          Kptsz_PERICASE[PER_GENPRMPAY_NF],
                          Kptsz_PERICASE[PER_GANPAYORD_NT]
                  );
               }
            }
         }
      }
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier 	***/
/***	     TSEGEST 							***/
/***									***/
/*** Nom : n_ConditionSyncSEGEST					***/
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

int n_ConditionSyncSEGEST(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if (Kc_SEGTYP_CT == 'E') {
      if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEG_NF], ptsz_LigneEsclave[SEGEST2_SEG_NF]))) {
         return ret;
      }
      return (strcmp(ptsz_LigneMaitre[CASEEST_UWY_NF], ptsz_LigneEsclave[SEGEST2_UWY_NF]));
   }
   else {
      if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[SEGEST2_SEG_NF]))) {
         return ret;
      }
      return strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[SEGEST2_UWY_NF]);
   }
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier SEGEST	***/
/***									***/
/*** Nom : n_ActionLigneSyncSEGEST					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncSEGEST(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncSEGEST");

   strcpy(Kbd_SEG.SEG_NF, ptsz_LigneEsclave[SEGEST2_SEG_NF]);
   Kbd_SEG.UWY_NF = (short)atoi(ptsz_LigneEsclave[SEGEST2_UWY_NF]);
   strcpy(Kbd_SEG.EGPCUR_CF, ptsz_LigneEsclave[SEGEST2_CUR_CF]);

   Kbd_SEG.Pa =  atof(ptsz_LigneEsclave[SEGEST2_Pa_M]);
   Kbd_SEG.PA =  atof(ptsz_LigneEsclave[SEGEST2_PA_M]);
   Kbd_SEG.PAa = atof(ptsz_LigneEsclave[SEGEST2_PAa_M]);
   Kbd_SEG.Ps =  atof(ptsz_LigneEsclave[SEGEST2_Ps_M]);
   Kbd_SEG.Ss =  atof(ptsz_LigneEsclave[SEGEST2_Ss_M]);
   Kbd_SEG.Sc =  atof(ptsz_LigneEsclave[SEGEST2_Sc_M]);
   Kbd_SEG.Sa =  atof(ptsz_LigneEsclave[SEGEST2_Sa_M]);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier FSEGEST 	***/
/***         ne correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFilsSEGEST				***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPereSansFilsSEGEST(char *ptsz_LigneMaitre[])
{
   DEBUT_FCT("n_ActionPereSansFilsSEGEST");

   /* On n'ecrit pas de ligne en sortie */
   Ks_SegmentNul = 1;

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier 	***/
/***         TLABOCY							***/
/***									***/
/*** Nom : n_ConditionSyncLABOCY					***/
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

int n_ConditionSyncLABOCY(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[LABOCYEST_SEG_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[LABOCYEST_UWY_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier TLABOCY	***/
/***									***/
/*** Nom : n_ActionLigneSyncLABOCY					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncLABOCY(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncLABOCY");

   if (Kn_NbreEXER == EXER_MAX) {
         sprintf (Ksz_MessageErr, "SEG %s, UWY %d : maximum number of EXER is reached ; increase EXER_MAX value", Kbd_SEG.SEG_NF, Kbd_SEG.UWY_NF);

         /* Modif 28/01/98 : ecriture dans le .ano au lieu du .log */
         /*n_WriteLog('E', Ksz_MessageErr);*/
         n_WriteAno( Ksz_MessageErr);

         /* et 'plantage' du programme */
         Kb_ReturnStatus=1;
   }
   else {
      Ktbd_EXER[Kn_NbreEXER].EXER_NF = (short)atoi(ptsz_LigneEsclave[LABOCYEST_OCCYEA_NF]);
      Ktbd_EXER[Kn_NbreEXER].SPIRAT_R = atof(ptsz_LigneEsclave[LABOCYEST_SPIRAT_R]);
      Ktbd_EXER[Kn_NbreEXER].Sc = atof(ptsz_LigneEsclave[LABOCYEST_Sc_M]);
      Kn_NbreEXER++;
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier 	***/
/***         PERICASE utilisee dans la fonction d'action ligne du maitre***/
/***									***/
/*** Nom : n_ConditionSyncPERICASE1					***/
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

int n_ConditionSyncPERICASE1(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEG_NF], ptsz_LigneEsclave[PER_SEG_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_EGPCUR_CF], ptsz_LigneEsclave[PER_EGPCUR_CF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_CTR_NF], ptsz_LigneEsclave[PER_CTR_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_END_NT], ptsz_LigneEsclave[PER_END_NT]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEC_NF], ptsz_LigneEsclave[PER_SEC_NF]))) {
      return ret;
   }
   return (strcmp(ptsz_LigneMaitre[CASEEST_UW_NT], ptsz_LigneEsclave[PER_UW_NT]));
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier 	***/
/***         PERICASE utilisee dans la fonction de rupture derniere du	***/
/***         maitre							***/
/***									***/
/*** Nom : n_ConditionSyncPERICASE2					***/
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

int n_ConditionSyncPERICASE2(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_SEG_NF], ptsz_LigneEsclave[PER_SEG_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF]))) {
      return ret;
   }
   if ((ret = strcmp(ptsz_LigneMaitre[CASEEST_EGPCUR_CF], ptsz_LigneEsclave[PER_EGPCUR_CF]))) {
      return ret;
   }
   if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneEsclave[PER_CTR_NF]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].END_NT - (short)atoi(ptsz_LigneEsclave[PER_END_NT]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF - (short)atoi(ptsz_LigneEsclave[PER_SEC_NF]))) {
      return ret;
   }
   return (Ktbd_CASEX[Kn_CompteurCASEX].UW_NT - (short)atoi(ptsz_LigneEsclave[PER_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier PERICASE	***/
/***									***/
/*** Nom : n_ActionLigneSyncPERICASE					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncPERICASE(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncPERICASE");

   Kptsz_PERICASE = ptsz_LigneEsclave;

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et le fichier GT	***/
/***									***/
/*** Nom : n_ConditionSyncGT					        ***/
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

int n_ConditionSyncGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short ret;

   if ((ret = strcmp(Kbd_SEG.SEG_NF, ptsz_LigneEsclave[GTESTCUMUL1_SEG_NF]))) {
      return ret;
   }
   if ((ret = Kbd_SEG.UWY_NF - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_UWY_NF]))) {
      return ret;
   }
   if ((ret = strcmp(Kptsz_PERICASE[PER_EGPCUR_CF], ptsz_LigneEsclave[GTESTCUMUL1_ACMCUR_CF]))) {
      return ret;
   }
   if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneEsclave[GTESTCUMUL1_CTR_NF]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].END_NT - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_END_NT]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_SEC_NF]))) {
      return ret;
   }
   if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].UW_NT - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_UW_NT]))) {
      return ret;
   }
   return (Ktbd_EXER[Kn_CompteurEXER].EXER_NF - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_OCCYEA_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier GT	***/
/***									***/
/*** Nom : n_ActionLigneSyncGT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncGT");


/* Pour debugage */

/* printf("ActionLigneGT SEG : %s ; UWY : %s ; CUR : %s ; CTR : %s ; END : %s ; SEC : %s ; UW : %s ; OCCYEA : %s\n",
       ptsz_LigneEsclave[GTESTCUMUL1_SEG_NF],
       ptsz_LigneEsclave[GTESTCUMUL1_UWY_NF],
       ptsz_LigneEsclave[GTESTCUMUL1_ACMCUR_CF],
       ptsz_LigneEsclave[GTESTCUMUL1_CTR_NF],
       ptsz_LigneEsclave[GTESTCUMUL1_END_NT],
       ptsz_LigneEsclave[GTESTCUMUL1_SEC_NF],
       ptsz_LigneEsclave[GTESTCUMUL1_UW_NT],
       ptsz_LigneEsclave[GTESTCUMUL1_OCCYEA_NF]
      ); */

   if (atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMTRS_NT]) == -20000) {
      Kd_Sccij = atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMAMT_M]);
   }
   if (atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMTRS_NT]) == -20030) {
      Kd_Sccaij = atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMAMT_M]);
   }

   RETURN_VAL(OK);
}


/*==============================================================================
objet :
	fonction de copie des rubriques du fichier Parametres de
 reconstitution vers une variable

retour :	0

==============================================================================*/
int n_CopyRec( char **ptb_InRecChild, /* adresse de la ligne courante du fichier des parametres de reconstitution */
	T_LIGNEREC *pbd_Rec ) /* adresse de la variable intermediaire Tableau de reconstitution */
{
	DEBUT_FCT( "n_CopyRec" ) ;

	pbd_Rec->REIRNK_N = (char)( atoi( ptb_InRecChild[PERFR_REIRNK_N] ) ) ;
	pbd_Rec->REIPRMBAS_R = atof( ptb_InRecChild[PERFR_REIPRMBAS_R] ) ;
	pbd_Rec->REIPRM_M = atof( ptb_InRecChild[PERFR_REIPRM_M] ) ;
	pbd_Rec->REIPRM_R = atof( ptb_InRecChild[PERFR_REIPRM_R] ) ;

	RETURN_VAL( 0 ) ;
}


/**************************************************************************/
/*** Objet : calcul des sinistralites pour le controle des estimations	***/
/***									***/
/*** Nom : n_SinisCtrEst     						***/
/***									***/
/*** Parametres:							***/
/***	i CTRNAT_CF   : nature de contrat,				***/
/***	i n_NbreCASEX : nombre de lignes du tableau des contrats,	***/
/***	i pbd_SEG     : pointeur sur le vecteur du segment,		***/
/***	io tbd_CASEX  : tableau des contrats.		***/
/***									***/
/*** Retour:								***/
/***	0 si pas d'anomalie						***/
/***	1 autrement							***/
/**************************************************************************/

int n_SinisCtrEst (char CTRNAT_CT, int n_NbreCASEX, T_SEG *pbd_SEG, T_CASEX tbd_CASEX[])

{  T_SEG  *pbd_SEGRES;    /* vecteur des donnees du segment restreint (sans les
                             lignes forcees) */
   double d_MtRapportS;   /* Rapport Sc/Ss */
   double d_MtRapportP;   /* Rapport Pai/Pa */
   double d_MtRapportSi;  /* Rapport Sci/Sc */
   int    n_NoCASEX;      /* Compteur du tableau des donnees des contrats */
   short  s_Erreur = 0;   /* Variable d'erreur */
   char   ct_Erreur[256]; /* Message d'erreur */
   double d_Taux;         /* Taux de conversion */

   DEBUT_FCT ("n_SinisCTREst");
   pbd_SEGRES = malloc (sizeof(T_SEG));

   /* Conversion des montants de CASEX[]{} utiles aux calculs */
   for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
      /* Determination du taux de conversion */
      d_Taux = d_GetTaux(Kp_GetTaux, (unsigned char)atoi(Kptsz_PERIMASTER[PER_SSD_CF]),
			 Kn_BALSHTYEA, tbd_CASEX[n_NoCASEX].EGPCUR_CF, pbd_SEG->EGPCUR_CF);

      /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
      if (d_Taux == -1 || d_Taux == 0) {
	sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
		Kptsz_PERICASE[PER_SSD_CF], Kn_BALSHTYEA,
		tbd_CASEX[n_NoCASEX].EGPCUR_CF, pbd_SEG->EGPCUR_CF);
	n_WriteAno(Ksz_MessageErr);
      }

      tbd_CASEX[n_NoCASEX].Pa *= d_Taux;   /* Prime actuarielle pure */
      tbd_CASEX[n_NoCASEX].PA *= d_Taux;   /* Prime acquise comptabilisee */
      tbd_CASEX[n_NoCASEX].PAa *= d_Taux;  /* Prime acquise actuarielle */
      tbd_CASEX[n_NoCASEX].Ps *= d_Taux;   /* Prime ultime de souscription */
      tbd_CASEX[n_NoCASEX].Ss *= d_Taux;   /* Sinistralite de souscription */
      tbd_CASEX[n_NoCASEX].Sci *= d_Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      tbd_CASEX[n_NoCASEX].Scc *= d_Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      tbd_CASEX[n_NoCASEX].Scca *= d_Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      tbd_CASEX[n_NoCASEX].Sa *= d_Taux;   /* Sinistralite actuarielle */
   }


/*************************/
/* Cas non proportionnel */
/*************************/

   if (CTRNAT_CT=='N') {

/* Recopie du vecteur des donnees du segment desquelles seront soustraites les
   donnees des lignes forcees */

      pbd_SEGRES->Pa = pbd_SEG->Pa;
      pbd_SEGRES->Ss = pbd_SEG->Sa;
      pbd_SEGRES->Sc = pbd_SEG->Sc;

/* Les contrats forces sont retires de la somme sur le segment */

      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F') {
            pbd_SEGRES->Pa = pbd_SEGRES->Pa - tbd_CASEX[n_NoCASEX].Pa;
            pbd_SEGRES->Ss = pbd_SEGRES->Ss - tbd_CASEX[n_NoCASEX].Ss;
            pbd_SEGRES->Sc = pbd_SEGRES->Sc - (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca);
         }
      }

/* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

      if ((pbd_SEGRES->Ss == 0) || (pbd_SEGRES->Sc == 0)) {
         d_MtRapportS = 0;
      }
      else {
         d_MtRapportS = pbd_SEGRES->Sc / pbd_SEGRES->Ss;
      }
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F') {
            if (pbd_SEGRES->Pa == 0) {
               d_MtRapportP = 0;
               sprintf (ct_Erreur, "SEG %s, UWY %d : Pa=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF);
               n_WriteAno (ct_Erreur);
               s_Erreur = 1;
            }
            else {
               d_MtRapportP = tbd_CASEX[n_NoCASEX].Pa / pbd_SEGRES->Pa;
            }
            if (pbd_SEGRES->Sc == 0) {
               d_MtRapportSi = 0;
               s_Erreur = 1;
            }
            else {
               d_MtRapportSi = (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca) / pbd_SEGRES->Sc ;
            }
            tbd_CASEX[n_NoCASEX].CALAMTCLM_M = tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca + (pbd_SEGRES->Ss - pbd_SEGRES->Sc) * ((1 - d_MtRapportS) * d_MtRapportP + d_MtRapportS * d_MtRapportSi);
         }
      }
   }


/********************/
/* Cas facultatives */
/********************/

   else if (CTRNAT_CT == 'F') {

/* Recopie du vecteur des donnees du segment desquelles seront soustraites les
   donnees des lignes forcees */

      pbd_SEGRES->Ps = pbd_SEG->Ps;
      pbd_SEGRES->Ss = pbd_SEG->Sa;
      pbd_SEGRES->Sc = pbd_SEG->Sc;

/* Les contrats forces sont retires de la somme sur le segment */

      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F') {
            pbd_SEGRES->Ps = pbd_SEGRES->Ps - tbd_CASEX[n_NoCASEX].Ps;
            pbd_SEGRES->Ss = pbd_SEGRES->Ss - tbd_CASEX[n_NoCASEX].Ss;
            pbd_SEGRES->Sc = pbd_SEGRES->Sc - (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca);
         }
      }

/* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

      if ((pbd_SEGRES->Ss == 0) || (pbd_SEGRES->Sc == 0)) {
         d_MtRapportS = 0;
      }
      else {
         d_MtRapportS = pbd_SEGRES->Sc / pbd_SEGRES->Ss;
      }
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F') {
            if (pbd_SEGRES->Ps == 0) {
               d_MtRapportP = 0;
               sprintf (ct_Erreur, "SEG %s, UWY %d : Ps=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF);
               n_WriteAno (ct_Erreur);
               s_Erreur = 1;
            }
            else {
               d_MtRapportP = tbd_CASEX[n_NoCASEX].Ps / pbd_SEGRES->Ps;
            }
            if (pbd_SEGRES->Sc == 0) {
               d_MtRapportSi = 0;
               s_Erreur = 1;
            }
            else {
               d_MtRapportSi = (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca) / pbd_SEGRES->Sc ;
            }
            tbd_CASEX[n_NoCASEX].CALAMTCLM_M = tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca + (pbd_SEGRES->Ss - pbd_SEGRES->Sc) * ((1 - d_MtRapportS) * d_MtRapportP + d_MtRapportS * d_MtRapportSi);
         }
      }
   }

   /* Reconversion des montants de CASEX[]{} utiles aux calculs */
   for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
      tbd_CASEX[n_NoCASEX].Pa /= d_Taux;   /* Prime actuarielle pure */
      tbd_CASEX[n_NoCASEX].PA /= d_Taux;   /* Prime acquise comptabilisee */
      tbd_CASEX[n_NoCASEX].PAa /= d_Taux;  /* Prime acquise actuarielle */
      tbd_CASEX[n_NoCASEX].Ps /= d_Taux;   /* Prime ultime de souscription */
      tbd_CASEX[n_NoCASEX].Ss /= d_Taux;   /* Sinistralite de souscription */
      tbd_CASEX[n_NoCASEX].Sci /= d_Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      tbd_CASEX[n_NoCASEX].Scc /= d_Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      tbd_CASEX[n_NoCASEX].Scca /= d_Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      tbd_CASEX[n_NoCASEX].Sa /= d_Taux;   /* Sinistralite actuarielle */
   }

   free (pbd_SEGRES);
   RETURN_VAL (s_Erreur);
}



/**************************************************************************/
/*** Objet : calcul des sinistralites pour l'actuariat			***/
/***									***/
/*** Nom : n_SinisActu     						***/
/***									***/
/*** Parametres:							***/
/***	i CTRNAT_CF   : nature de contrat,				***/
/***	i n_NbreEXER  : nombre de lignes du tableau des taux de		***/
/***                    repartition par exercice de survenance,		***/
/***	i n_NbreCASEX : nombre de lignes du tableau des contrats,	***/
/***	i pbd_SEG     : pointeur sur le vecteur du segment,		***/
/***	io tbd_EXER  : tableau des taux de repartition                  ***/
/***                    par exercice de survenance,			***/
/***	io tbd_CASEX : le tableau des contrats,		                ***/
/***    o tbd_IBNR   : tableau des IBNR                                 ***/
/***									***/
/*** Retour:								***/
/***	0 si pas d'erreur						***/
/***	1 autrement							***/
/**************************************************************************/

int n_SinisActu (char CTRNAT_CT, int n_NbreEXER, int n_NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[])

{  T_SEG  *pbd_SEGRES;    /* vecteur des donnees du segment restreint (sans les
                             lignes forcees) */
   double d_MtRapportS;   /* Rapport Sc/Ss */
   double d_MtRapportP;   /* Rapport Pai/Pa */
   double d_MtRapportSi;  /* Rapport Sci/Sc */
   int    n_NoCASEX;      /* Compteur du tableau des donnees des contrats */
   int    n_NbreCASEXNonForce; /* Nombre d'affaires non forcees  */
   short  s_Erreur = 0;   /* Variable d'erreur */
   char   ct_Erreur[256]; /* Message d'erreur */
   double d_Taux;         /* Taux de conversion */

   DEBUT_FCT ("n_SinisActu");
   pbd_SEGRES = malloc (sizeof(T_SEG));

   /* Conversion des montants de CASEX[]{} utiles aux calculs */
   for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
      /* Determination du taux de conversion */
      d_Taux = d_GetTaux(Kp_GetTaux, (unsigned char)atoi(Kptsz_PERIMASTER[PER_SSD_CF]),
			 Kn_BALSHTYEA, tbd_CASEX[n_NoCASEX].EGPCUR_CF, pbd_SEG->EGPCUR_CF);

      /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
      if (d_Taux == -1 || d_Taux == 0) {
	sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
		Kptsz_PERICASE[PER_SSD_CF], Kn_BALSHTYEA,
		tbd_CASEX[n_NoCASEX].EGPCUR_CF, pbd_SEG->EGPCUR_CF);
	n_WriteAno(Ksz_MessageErr);
      }

      tbd_CASEX[n_NoCASEX].Pa *= d_Taux;   /* Prime actuarielle pure */
      tbd_CASEX[n_NoCASEX].PA *= d_Taux;   /* Prime acquise comptabilisee */
      tbd_CASEX[n_NoCASEX].PAa *= d_Taux;  /* Prime acquise actuarielle */
      tbd_CASEX[n_NoCASEX].Ps *= d_Taux;   /* Prime ultime de souscription */
      tbd_CASEX[n_NoCASEX].Ss *= d_Taux;   /* Sinistralite de souscription */
      tbd_CASEX[n_NoCASEX].Sci *= d_Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      tbd_CASEX[n_NoCASEX].Scc *= d_Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      tbd_CASEX[n_NoCASEX].Scca *= d_Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      tbd_CASEX[n_NoCASEX].Sa *= d_Taux;   /* Sinistralite actuarielle */
   }


/*****************/
/* Proportionnel */
/*****************/

   if (CTRNAT_CT=='P') {

/* Recopie du vecteur des donnees du segment desquelles seront soustraites les
   donnees des lignes forcees */

      pbd_SEGRES->Ss = pbd_SEG->Ss;
      pbd_SEGRES->Sa = pbd_SEG->Sa;

/* Les contrats forces sont retires de la somme sur le segment */

      n_NbreCASEXNonForce=0;
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F') {
            pbd_SEGRES->Ss = pbd_SEGRES->Ss - tbd_CASEX[n_NoCASEX].Ss;
            pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
         }
	 else n_NbreCASEXNonForce += 1 ;
      }
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F') {
            if (pbd_SEGRES->Ss == 0) {
               tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].Ss + pbd_SEGRES->Sa / n_NbreCASEXNonForce;
            }
            else {
               d_MtRapportS = tbd_CASEX[n_NoCASEX].Ss / pbd_SEGRES->Ss;
               tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].Ss + (pbd_SEGRES->Sa - pbd_SEGRES->Ss) * d_MtRapportS;
            }
         }
      }
      n_IBNRActu (n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR);
   }


/*************************/
/* Cas non proportionnel */
/*************************/

   else if (CTRNAT_CT == 'N') {

/* Recopie du vecteur des donnees du segment desquelles seront soustraites les
   donnees des lignes forcees */

      pbd_SEGRES->PAa = pbd_SEG->PAa;
      pbd_SEGRES->Sc = pbd_SEG->Sc;
      pbd_SEGRES->Sa = pbd_SEG->Sa;

/* Les contrats forces sont retires de la somme sur le segment */

      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F') {
            pbd_SEGRES->PAa = pbd_SEGRES->PAa - tbd_CASEX[n_NoCASEX].PAa;
            pbd_SEGRES->Sc = pbd_SEGRES->Sc - (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca);
            pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
         }
      }

/* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

      if ((pbd_SEGRES->Sc == 0) || (pbd_SEGRES->Sa == 0)) {
         d_MtRapportS = 0;
      }
      else
	{
           d_MtRapportS = pbd_SEGRES->Sc / pbd_SEGRES->Sa;

	   if ( d_MtRapportS < 0 || d_MtRapportS > 1 )
	   {
               sprintf (ct_Erreur, "Abnormal ldf value (= %f ) for SEG %s, UWY %d, EGPCUR %s .", d_MtRapportS, pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF);
               n_WriteAno (ct_Erreur);
	   }
        }
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F') {
            if (pbd_SEGRES->PAa == 0) {
               d_MtRapportP = 0;
               sprintf (ct_Erreur, "SEG %s, UWY %d, EGPCUR %s : PAa=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF);
               n_WriteAno (ct_Erreur);
               s_Erreur = 1;
            }
            else {
               d_MtRapportP = tbd_CASEX[n_NoCASEX].PAa / pbd_SEGRES->PAa;
            }
            if (pbd_SEGRES->Sc == 0) {
               d_MtRapportSi = 0;
               s_Erreur = 1;
            }
            else {
               d_MtRapportSi =(tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca) / pbd_SEGRES->Sc ;
            }
            tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca + (pbd_SEGRES->Sa - pbd_SEGRES->Sc) * ((1 - d_MtRapportS) * d_MtRapportP + d_MtRapportS * d_MtRapportSi);
         }
      }
      n_IBNRActu (n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR);
   }


/********************/
/* Cas facultatives */
/********************/

   else if (CTRNAT_CT == 'F') {

/* Recopie du vecteur des donnees du segment desquelles seront soustraites les
   donnees des lignes forcees */

      pbd_SEGRES->PA = pbd_SEG->PA;
      pbd_SEGRES->Sa = pbd_SEG->Sa;
      pbd_SEGRES->Sc = pbd_SEG->Sc;

/* Les contrats forces sont retires de la somme sur le segment */

      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F') {
            pbd_SEGRES->PA = pbd_SEGRES->PA - tbd_CASEX[n_NoCASEX].PA;
            pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
            pbd_SEGRES->Sc = pbd_SEGRES->Sc - (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca);
         }
      }

/* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

      if ((pbd_SEGRES->Sa == 0) || (pbd_SEGRES->Sc == 0)) {
         d_MtRapportS = 0;
      }
      else
	{
        d_MtRapportS = pbd_SEGRES->Sc / pbd_SEGRES->Sa;

	   if ( d_MtRapportS < 0 || d_MtRapportS > 1 )
	   {
               sprintf (ct_Erreur, "Abnormal ldf value ( = %f ) for SEG %s, UWY %d, EGPCUR %s .", d_MtRapportS, pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF);
               n_WriteAno (ct_Erreur);
	   }
	}
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F') {
            if (pbd_SEGRES->PA == 0) {
               d_MtRapportP = 0;
               sprintf (ct_Erreur, "SEG %s, UWY %d, EGPCUR_CF %s : PA=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF );
               n_WriteAno (ct_Erreur);
               s_Erreur = 1;
            }
            else {
               d_MtRapportP = tbd_CASEX[n_NoCASEX].PA / pbd_SEGRES->PA;
            }
            if (pbd_SEGRES->Sc == 0) {
               d_MtRapportSi = 0;
               s_Erreur = 1;
            }
            else {
               d_MtRapportSi = (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca) / pbd_SEGRES->Sc ;
            }
            tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca + (pbd_SEGRES->Sa - pbd_SEGRES->Sc) * ((1 - d_MtRapportS) * d_MtRapportP + d_MtRapportS * d_MtRapportSi);
         }
      }
      if (n_NbreEXER) {
         if (n_IBNRActu (n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR)) {
            s_Erreur = 1;
         }
      }
   }
   free (pbd_SEGRES);

   /* Reconversion des montants de CASEX[]{} utiles aux calculs */
   for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
      tbd_CASEX[n_NoCASEX].Pa /= d_Taux;   /* Prime actuarielle pure */
      tbd_CASEX[n_NoCASEX].PA /= d_Taux;   /* Prime acquise comptabilisee */
      tbd_CASEX[n_NoCASEX].PAa /= d_Taux;  /* Prime acquise actuarielle */
      tbd_CASEX[n_NoCASEX].Ps /= d_Taux;   /* Prime ultime de souscription */
      tbd_CASEX[n_NoCASEX].Ss /= d_Taux;   /* Sinistralite de souscription */
      tbd_CASEX[n_NoCASEX].Sci /= d_Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      tbd_CASEX[n_NoCASEX].Scc /= d_Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      tbd_CASEX[n_NoCASEX].Scca /= d_Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      tbd_CASEX[n_NoCASEX].Sa /= d_Taux;   /* Sinistralite actuarielle */
   }

   RETURN_VAL (s_Erreur);
}



/**************************************************************************/
/*** Objet : calcul des IBNR pour l'actuariat				***/
/***									***/
/*** Nom : n_IBNRActu	     						***/
/***									***/
/*** Parametres:							***/
/***	i n_NbreEXER  : nombre de lignes du tableau des taux de		***/
/***                    repartition par exercice de survenance,		***/
/***	i n_NbreCASEX : nombre de lignes du tableau des contrats,	***/
/***	i tbd_EXER   : tableau des taux de repartition ***/
/***                    par exercice de survenance,			***/
/***	i tbd_CASEX  : tableau des contrats,		***/
/***    i tbd_IBNR   : tableau des IBNR		***/
/***									***/
/*** Retour:								***/
/***	0 si pas d'erreur						***/
/***	1 autrement							***/
/**************************************************************************/

int n_IBNRActu (int n_NbreEXER, int n_NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[])

{  int    n_NoEXER;       /* Compteur du tableau des donnees des contrats */
   int    n_NoCASEX;      /* Compteur du tableau des donnees des contrats */
   double d_SIBNR=0;      /* Somme des IBNR par exercice de survenanca pour le
                             segment */
   short  s_Erreur = 0;   /* Variable d'erreur */
   char   ct_Erreur[256]; /* Message d'erreur */

   DEBUT_FCT ("n_IBNRActu");

   for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++) {
      tbd_EXER[n_NoEXER].IBNR = pbd_SEG->Sa * tbd_EXER[n_NoEXER].SPIRAT_R - tbd_EXER[n_NoEXER].Sc;
      d_SIBNR = d_SIBNR + tbd_EXER[n_NoEXER].IBNR;
   }

   if (d_SIBNR == 0) {
      sprintf (ct_Erreur, "SEG %s, UWY %d : IBNR=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF);
      n_WriteAno (ct_Erreur);
      s_Erreur = 1;  /* Variable d'erreur */
   }
   else {
      for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++) {
         tbd_EXER[n_NoEXER].PIBNR = tbd_EXER[n_NoEXER].IBNR / d_SIBNR;
      }
      for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++) {
         for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++) {
            tbd_IBNR[n_NoCASEX*n_NbreEXER + n_NoEXER].IBNR = (tbd_CASEX[n_NoCASEX].Sa - (tbd_CASEX[n_NoCASEX].Sci + tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca)) * tbd_EXER[n_NoEXER].PIBNR;
         }
      }
   }
   RETURN_VAL (s_Erreur);
}

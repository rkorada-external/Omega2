/*==============================================================================
Nom de l'application          : Encapsulation du lot 5
Nom du source                 : ESTC0626.c
Revision                      : $Revision: 1.2 $
Date de creation              : 07/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :

   Initialement : ESTC0606 (regroupant les traitements en estimation ET
                  actuariat)
		  La présente évolution consiste à séparer le code en
		  deux steps ESTC0616 (estimation) et ESTC0626 (actuariat).


	  /\    *********************************************************
	 /  \   * TOUTE MODIFICATION DE CODE PORTANT EGALEMENT SUR LE   *
	/  ! \  * SEGMENT ESTIMATION DOIT ETRE REPORTEE DANS L'ESTC0616 *
   /______\ *********************************************************


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

	  29/01/03      J. Ribot    ajout 1 champs a NULL en sortie pour retintamt_m
    08/11/2004    J. Ribot    modif  test (fabs(pbd_SEGRES->Sc) < 1)
                                          (fabs(pbd_SEGRES->Sa) < 1)
                                          (fabs(pbd_SEGRES->PA) < 1)
                                          (fabs(pbd_SEGRES->PAa) < 1)

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[006] 13/08/2014 R. Cassis :spot:xxxxx Calculate IBNR Prop as IBNR NProp and resolve warnings
[007] 27/10/2014 G. Legay :spot:27485 - Update calculation of IBNR NProp - Add trace file
[008] 19/11/2014 G. Legay :spot:27485 - Update in case of U/W losses is inferior to 1
[009] 07/04/2015 Florent  :spot:28597 - debug (impact on C/S/U with ADMMODPRM_CT=F) and subsidiary for currency conversion
[010] 07/05/2015 F Maragnes :spot:28305 - Ajout  montants de sinistres RPCC dans le calcul du blanchiment pour les IBNR1A :
[011] 24/04/2015 R. cassis :spot:28660 - Add SSD_CF, ESB_CF and PAs to trace log data file
[012] 24/09/2015 Florent :spot:28305 - on supprime pour le momenent la modif de la spot 28305
[013] 28/09/2015 Florent :spot:29481 Ajout  montants de sinistres RPCC dans le calcul du blanchiment pour les IBNR1A
[014] 02/05/2015 -=Dch=- :spot:30465 Ajout  Ajout du fichier de sortie de blanchiment RPCC
[015] 11/04/2018 S.Behague     :spira 65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE
[016] 29/05/2019 M.NAI : spira http://spira/SpiraTeam/15/Incident/61531.aspx IBNR 1A +1B positif : annulation des blanchiments .
[017] 07/11/2018 L.ELfahim :  spira 061531 : Correction beug ecriture des IBNR1B qaund IBNR1A est null.
[018] 05/12/2018 L.ELfahim :  spira 061531 : Correction beug ecriture des IBNR1B et IBNR1A ( un autre cas qui n'est pas gere avant).
[019] 29/03/2019 T.Yvert :  spira 076241 : Annulation IBNR de blanchiement : Exclure les types comptables 1 AC
[020] 06/04/2019 L.DOAN :   spira 076241 : Revert spira  061531 pour les types comptables 1 AC
[021] 16/10/2019 L.DOAN :   spira 079211 : IFRS 4 - IBNR Allocation - positive OSL impact
[022] 05/11/2019 L.DOAN :   spira 79642  : IFRS 4 - IBNR Allocation - Incorrect output
[023] 03/07/2019 R. Cassis :spira:65656 Prs_cf is added as parameter for IFRS4 (710) or EBS (730)
[024] 18/02/2020 R. Cassis :spira:84424 65656 On ajoute la colonne INCURREDCI_M dans le fichier FCTREST et on retire ce montant pour cas 'Force' sur incomplets
[025] 13/03/2020 M. NAJI   :SPIRA 84317 création d'un (#define ZERO 1 ) et teste < ZERO au lieu < 0.001 
[026] 27/04/2020 R. Cassis :spira:86503 On remonte toutes les lignes IFRS cas A et F
[027] 24/06/2020 R. cassis :spira:84903 Le ZERO doit avoir la valeur 0.001 et pas 0.1 comme l'ancienne version
[028] 18/06/2020 R. Cassis :spira:86536 On remonte toutes les lignes TCTREST pour EBS et IFRS periode exceptionnelle
[029] 26/08/2020 R. Cassis :spira:86503 refonte et revue des formules
[030] 26/11/2020 R. Cassis :spira:92042 Alignement de la formule du d_MtRapportSi du type F aux types P et N
[031] 12/01/2021 R. Cassis :spira:92617 Ajustement sur montant d_MtRapportSc a 1 au lieu de 0 si Ss = 0 et type Montant = 'S'
[032] 12/15/2022 JBD			 :spira:101884 NRT - IBNR KO if no UW Loss -> simplification regle
[033] 31/08/2023 JYP/Florian	 :spira:110379 IBNR on unexpected sections 
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"
#include "ESTC0501.h"

/************************************/
/* Define                           */
/* Attention : a modifier si besoin */
/************************************/

static char VERSION_ESTC0626_C[150] = "__version__: ESTC0626.c version [033] 31/08/2023 spira 110379: JYP/Florian IBNR unexpected sections ";

#define SEGEXERDEV_MAX 90000 /* Nombre maximum de C/A/S/N° s'ordre par */
                             /* segment/exercice/devise */

#define EXER_MAX 10 /* Nombre maximum d'exercices de survenance */

//#define CASEACT_Scirpcci_M 	21
#define CASEACT_ACCADMTYP_CT 22
#define CASEACT_NAT_CF 23

#define ZERO  0.001   // [027]
/*-------------------------------*/
/* Variables de travail externes */
/*-------------------------------*/

extern char b_EOF_MAITRE; /* Permet de faire des synchronisations sur la */
                          /* sur la derniere ligne du fichier maitre */

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE *Kp_OutputFileDommages; /* Pointeur sur le fichier de */
                             /* sortie des dommages (actuariat) */
FILE *Kp_OutputFileGT;       /* Pointeur sur le fichier de */
                             /* sortie du GT (actuariat) */

FILE *Kp_OutputFileTrace; /* [007] Pointeur sur le  fichier des Trace */

FILE *Kp_GetTaux; /* Pointeur sur le fichier des taux */

FILE *Kp_OutputBlanchiment;

T_RUPTURE_VAR *pbd_Rupture;           /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_SyncSEGEST;   /* Pointeur sur la structure de */
                                      /* synchronisation avec TLABOCY */
T_RUPTURE_SYNC_VAR *pbd_SyncLABOCY;   /* Pointeur sur la structure de */
                                      /* synchronisation avec LABOCY */
T_RUPTURE_SYNC_VAR *pbd_SyncPERICASE; /* Pointeur sur la structure de */
                                      /* synchronisation avec PERICASE */
T_RUPTURE_SYNC_VAR *pbd_SyncGT;       /* Pointeur sur la structure de */
                                      /* synchronisation avec le GT */

char **Kptsz_PERICASE; /* Pointeur sur la ligne de l'esclave permettant de */
                       /* recuperer des donnees dans le maitre */

char **Kptsz_PERIMASTER; /* Pointeur sur la ligne courante du maitre */
                         /* (accessible dans les fonctions hors synchro) */

int Kn_nat_cf; /* NAT_CF du perimetre (utilise pour la ventilation des non prop.) */

double Kd_Sccij; /* Valeur de Sccij pour ecriture dans le GT :  SP sur comptes complets en proportionnels */
                 /*                 et Non proportionnels 'Stop Loss & Annual Agregate' (NAT_CF=40 ou 41) */

double Kd_Sccaij; /* Valeur de Sccaij pour ecriture dans le GT : SAP sur comptes complets en proportionnel */
                  /*                 et Non proportionnels 'Stop Loss & Annual Agregate' (NAT_CF=40 ou 41) */

double Kd_Sci; /* Valeur de Sci pour ecriture dans le GT : ??? sur comptes incomplets en proportionnel */
               /*                 et Non proportionnels 'Stop Loss & Annual Agregate' (NAT_CF=40 ou 41) */

double d_IncurredPosition = 0.0;  /* Incured position for all contracts [029] */
double d_IncurredPositionF = 0.0;  /* Incured position for all forced contracts [029] */

//int n_NbreCASEXNonForce; /* Nombre d'affaires non forcees  */


char Ksz_CRE_D[20]; /* Date systeme */

int Kn_BALSHTYEA; /* Annee utilisee pour le cours en actuariat */

/* Variables pour recuperer les versions */
char Kc_Delimiteur = '_';  /* Delimiteur utilise */
char Ksz_SSD_LL[65];       /* Liste des filiales separees par '_', contient 21 */
                           /* filiales au maximum de 2 caracteres */
int Kn_Compteur;           /* Compteur sur une chaine ou un tableau */
int Kn_CompteurSousChaine; /* Compteur sur la sous-chaine contenant la filiale */
                           /* ou la version en cours */
char Ksz_SousChaine[11];   /* Sous chaine contenant la filiale ou la version */
                           /* en cours */
int Kn_NbreFiliales = 0;   /* Nbre de filiales */
int Ktn_ListeFiliales[22]; /* Tableau contenant la liste des filales */
int Kn_VRS_NF;             /* Version de la filiale en cours */
char Ksz_VRS_LL[233];      /* Liste des versions correspondant aux filiales */
                           /* precedentes separees par '_', contient 21 */
                           /* versions de 10 caracteres */
int Kn_NbreVersions = 0;   /* Nbre de versions */
int Ktn_ListeVersions[22]; /* Tableau contenant la liste des versions */

char Kc_INVTYP;       /* Type d'inventaire */
char Ksz_CLODAT_D[9]; /* Date de libelle d'inventaire */
short Ks_SegmentNul;  /* Vaut 1 si le segment n'existe pas, 0 autrement */

char Ksz_Prs[4];      /* parametre de la chaine: type de poste '710'(IFRS4) ou '730'(EBS) [022] */
char Ksz_MessageErr[256]; /* Message d'erreur */



int n_IBNRActu(int, int, T_SEG *, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[]);

int Kn_CompteurCASEX;                        /* Compteur numero d'affaire */
int Kn_NbreCASEX;                            /* Nombre d'affaires pour le SEG/EXER/DEV */
int Kn_CompteurEXER;                         /* Compteur numero d'exercice de survenance */
int Kn_NbreEXER;                             /* Nombre d'exercices de survenance pour le */
                                             /* SEG/EXER */
T_SEG Kbd_SEG;                               /* Vecteur contenant les donnees du segment/exercice/devise */
T_EXER Ktbd_EXER[EXER_MAX];                  /* Tableau contenant les exercices de survenance */
T_CASEX Ktbd_CASEX[SEGEXERDEV_MAX];          /* Tableau de structures contenant les affaires en entree du lot 5. */
T_IBNR Ktbd_IBNR[SEGEXERDEV_MAX * EXER_MAX]; /* Tableau de structures contenant */
                                             /* les IBNR en retour du lot 5. */

BOOL Kb_ReturnStatus = 0; /* code de retour du programme (=0 si OK, 1 sinon) */

// ajout de la log blanchiment
void printBlanchiment(char *debutLigne, const char *trncode, char *sccarpcci, char *scirpcci, double ibnr1A, double ibnr1b);

/*--------------------------------------------------------------------*/
/* Fonctions du fichier maitre (fichier PERICASEEST3 ou PERICASEACT3) */
/*--------------------------------------------------------------------*/

int n_InitRupture(T_RUPTURE_VAR *pbd_Rupture);
int n_TestRupture(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);

/*-----------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le le fichier maitre et TSEGEST */
/*-----------------------------------------------------------------------*/

int n_InitSyncSEGEST(T_RUPTURE_SYNC_VAR *pbd_Rupture);
int n_ActionLigneSyncSEGEST(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncSEGEST(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionPereSansFilsSEGEST(char **ptsz_LigneMaitre);

/*--------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et TLABOCY */
/*--------------------------------------------------------------------*/

int n_InitSyncLABOCY(T_RUPTURE_SYNC_VAR *pbd_Rupture);
int n_ActionLigneSyncLABOCY(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncLABOCY(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*---------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et PERICASE */
/*---------------------------------------------------------------------*/

int n_InitSyncPERICASE(T_RUPTURE_SYNC_VAR *pbd_Rupture);
int n_ActionLigneSyncPERICASE(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPERICASE1(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPERICASE2(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier maitre et le GT */
/*--------------------------------------------------------------------*/

int n_InitSyncGT(T_RUPTURE_SYNC_VAR *pbd_Rupture);
int n_ActionLigneSyncGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

int n_SinisActu(char CTRNAT_CT, int NbreEXER, int NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[]);

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
    char *argv[])
{
  char sz_SysTime[9];
  pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
  pbd_SyncSEGEST = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncLABOCY = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncPERICASE = malloc(sizeof(T_RUPTURE_SYNC_VAR));
  pbd_SyncGT = malloc(sizeof(T_RUPTURE_SYNC_VAR));

  printf("Running %s\n", VERSION_ESTC0626_C);

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_BeginPgm");
  }

  /* En actuariat, recuperation de BALSHTYEA_NF */
  Kn_BALSHTYEA = n_GetIntArgv(1);

  /* modification et formatage de la date de creation */
  RecSysDate(Ksz_CRE_D, sz_SysTime);
  FormatTime(sz_SysTime, sz_SysTime);
  strcat(Ksz_CRE_D, " ");
  strcat(Ksz_CRE_D, sz_SysTime);

  /* Recuperation du parametre correspondant a la liste des filiales */
  strcpy(Ksz_SSD_LL, psz_GetCharArgv(2));

  /* Recuperation du parametre correspondant a la liste des numeros de version */
  strcpy(Ksz_VRS_LL, psz_GetCharArgv(3));

  /* Recuperation du parametre correspondant au type d'inventaire */
  Kc_INVTYP = *(psz_GetCharArgv(4));

  /* Recuperation du parametre correspondant a la date libelle d'inventaire */
  strcpy(Ksz_CLODAT_D, psz_GetCharArgv(5));

  /* Recuperation du parametre correspondant au type prs IFRS4(710) ou EBS(730) */
  strcpy(Ksz_Prs, psz_GetCharArgv(6)) ;  // [023]
  
  /* Place les filiales dans le tableau des filiales */
  for (Kn_Compteur = 0; Ksz_SSD_LL[Kn_Compteur] != '\0'; Kn_Compteur++)
  {
    if (Ksz_SSD_LL[Kn_Compteur] == Kc_Delimiteur)
    {
      if (Kn_CompteurSousChaine != 0)
      {
        Ksz_SousChaine[Kn_CompteurSousChaine + 1] = '\0';
        Ktn_ListeFiliales[Kn_NbreFiliales] = atoi(Ksz_SousChaine);
        Kn_NbreFiliales++;
        Kn_CompteurSousChaine = 0;
      }
    }
    else
    {
      Ksz_SousChaine[Kn_CompteurSousChaine] = Ksz_SSD_LL[Kn_Compteur];
      Kn_CompteurSousChaine++;
    }
  }

  { /* Correction de la boucle par Mehdi le 29/01/1998 */
    char *p1, *p2;

    Kn_NbreVersions = 0;
    p1 = Ksz_VRS_LL + 1;

    while ((p2 = strchr(p1, '_')))
    {
      *p2 = 0;
      Ktn_ListeVersions[Kn_NbreVersions] = atoi(p1);
      p1 = p2 + 1;
      Kn_NbreVersions++;
    }
  }

  /* Generation d'une anomalie quand le nombre de filiales est different du */
  /* nombre de versions */
  if (Kn_NbreFiliales != Kn_NbreVersions)
  {
    sprintf(Ksz_MessageErr, "Number of subsidaries different of number of versions");
    n_WriteAno(Ksz_MessageErr);
  }

  /* Ouverture du fichier des taux */
  if (n_OpenFileAppl("ESTC0626_I6", "rb", &Kp_GetTaux) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileApplGetTaux");
  }

  /* Ouverture du fichier de sortie des dommages */
  if (n_OpenFileAppl("ESTC0626_O1", "wt", &Kp_OutputFileDommages) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileAppl");
  }

  /* Ouverture du fichier de sortie du GT */
  if (n_OpenFileAppl("ESTC0626_O2", "wt", &Kp_OutputFileGT) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileAppl");
  }

  /* Ouverture du fichier de sortie BLANCHIMENT */
  if (n_OpenFileAppl("ESTC0626_O4", "wt", &Kp_OutputBlanchiment) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileAppl");
  }

  //[007]
  /* Ouverture du fichier de trace pour calcul des IBNR 2 */
  if (n_OpenFileAppl("ESTC0626_O3", "wt", &Kp_OutputFileTrace) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileAppl");
  }

  /* Initialisation de la structure de rupture */
  if (n_InitRupture(pbd_Rupture) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitRupture");
  }

  /* Initialisation de la structure de synchronisation avec TSEGEST */
  if (n_InitSyncSEGEST(pbd_SyncSEGEST) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncSEGEST");
  }

  /* Initialisation de la structure de synchronisation avec PERICASE */
  if (n_InitSyncPERICASE(pbd_SyncPERICASE) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncPERICASE");
  }

  /* Initialisation de la structure de synchronisation avec TLABOCY */
  if (n_InitSyncLABOCY(pbd_SyncLABOCY) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncLABOCY");
  }

  /* Initialisation de la structure de synchronisation avec le GT */
  if (n_InitSyncGT(pbd_SyncGT) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGT");
  }

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
  }

  if (n_CloseFileAppl("ESTC0626_I1", &(pbd_Rupture->pf_InputFil)) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0626_I2", &(pbd_SyncSEGEST->pf_InputFil)) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplSEGEST");
  }

  if (n_CloseFileAppl("ESTC0626_I3", &(pbd_SyncPERICASE->pf_InputFil)) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplPERICASE");
  }

  if (n_CloseFileAppl("ESTC0626_I6", &Kp_GetTaux) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0626_I4", &(pbd_SyncLABOCY->pf_InputFil)) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplLABOCY");
  }

  if (n_CloseFileAppl("ESTC0626_I5", &(pbd_SyncGT->pf_InputFil)) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileApplGT");
  }

  if (n_CloseFileAppl("ESTC0626_O1", &Kp_OutputFileDommages) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC0626_O2", &Kp_OutputFileGT) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  //[007]
  if (n_CloseFileAppl("ESTC0626_O3", &Kp_OutputFileTrace) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  //[014]
  if (n_CloseFileAppl("ESTC0626_O4", &Kp_OutputBlanchiment) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_EndPgm() == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  }

  free(pbd_Rupture);
  free(pbd_SyncSEGEST);
  free(pbd_SyncLABOCY);
  free(pbd_SyncPERICASE);
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
    T_RUPTURE_VAR *pbd_Rupture)
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTC0626_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }

  pbd_Rupture->n_NbRupture = 1;
  pbd_Rupture->n_ConditionRupture[0] = n_TestRupture;
  pbd_Rupture->n_ActionFirst[0] = n_ActionPremiereRupture;
  pbd_Rupture->n_ActionLigne = n_ActionLigneRupture;
  pbd_Rupture->n_ActionLast[0] = n_ActionDerniereRupture;
  pbd_Rupture->c_Separ = '~';

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
    T_RUPTURE_SYNC_VAR *pbd_SyncSEGEST)
{
  DEBUT_FCT("n_InitSyncSEGEST");
  memset(pbd_SyncSEGEST, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier TSEGEST */
  if (n_OpenFileAppl("ESTC0626_I2", "rt", &(pbd_SyncSEGEST->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncSEGEST->ConditionEndSync = n_ConditionSyncSEGEST;
  pbd_SyncSEGEST->n_ActionLigne = n_ActionLigneSyncSEGEST;
  pbd_SyncSEGEST->n_PereSansFils = n_ActionPereSansFilsSEGEST;
  pbd_SyncSEGEST->c_Separ = '~';

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
    T_RUPTURE_SYNC_VAR *pbd_SyncPERICASE)
{
  DEBUT_FCT("n_InitSyncPERICASE");
  memset(pbd_SyncPERICASE, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier PERICASE */
  if (n_OpenFileAppl("ESTC0626_I3", "rt", &(pbd_SyncPERICASE->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncPERICASE->ConditionEndSync = n_ConditionSyncPERICASE2;
  pbd_SyncPERICASE->n_ActionLigne = n_ActionLigneSyncPERICASE;
  pbd_SyncPERICASE->c_Separ = '~';

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
    T_RUPTURE_SYNC_VAR *pbd_SyncLABOCY)
{
  DEBUT_FCT("n_InitSyncLABOCY");
  memset(pbd_SyncLABOCY, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier LABOCY */
  if (n_OpenFileAppl("ESTC0626_I4", "rt", &(pbd_SyncLABOCY->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncLABOCY->ConditionEndSync = n_ConditionSyncLABOCY;
  pbd_SyncLABOCY->n_ActionLigne = n_ActionLigneSyncLABOCY;
  pbd_SyncLABOCY->c_Separ = '~';

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
    T_RUPTURE_SYNC_VAR *pbd_SyncGT)
{
  DEBUT_FCT("n_InitSyncGT");
  memset(pbd_SyncGT, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier GT */
  if (n_OpenFileAppl("ESTC0626_I5", "rt", &(pbd_SyncGT->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pbd_SyncGT->ConditionEndSync = n_ConditionSyncGT;
  pbd_SyncGT->n_ActionLigne = n_ActionLigneSyncGT;
  pbd_SyncGT->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction de test de rupture                                ***/
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
    char *ptsz_LigneCour[])
{
  static int n_Ret;

  if ((n_Ret = strcmp(ptsz_LigneSuiv[CASEACT_SEG_NF], ptsz_LigneCour[CASEACT_SEG_NF])))
  {
    return n_Ret;
  }
  return (strcmp(ptsz_LigneSuiv[CASEACT_UWY_NF], ptsz_LigneCour[CASEACT_UWY_NF]));
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du   ***/
/***         fichier maitre (uniquement en actuariat)			***/
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

  memset(Ktbd_IBNR, 0, sizeof(T_IBNR) * SEGEXERDEV_MAX * EXER_MAX);

  memset(Ktbd_EXER, 0, sizeof(T_EXER) * EXER_MAX);
  Kn_NbreEXER = 0;

  memset(Ktbd_CASEX, 0, sizeof(T_CASEX) * SEGEXERDEV_MAX);
  Kn_NbreCASEX = 0;

  /* Remplissage de la structure des exercices de survenance du segment */
  /* Pas de ventilation par exercice de survenance en Proportionnel     */
  n_ProcessingRuptureSyncVar(pbd_SyncLABOCY, ptsz_LigneCour);

  if (*ptsz_LigneCour[CASEACT_SEG_NF] == '\0')
  {
    Ks_SegmentNul = 1;
    RETURN_VAL(OK);
  }

  Ks_SegmentNul = 0;

  /* Remplissage de la structure du segment */
  n_ProcessingRuptureSyncVar(pbd_SyncSEGEST, ptsz_LigneCour);

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

  double d_IBNR1, d_IBNR2;
  char sortieBlanchiment[500];

  DEBUT_FCT("n_ActionLigneRupture");

  /* sauvegarde du pointeur courant */
  Kptsz_PERIMASTER = ptsz_LigneCour;

  /* Si segment non nul */
  if (Ks_SegmentNul == 0)
  {
    if (Kn_NbreCASEX == SEGEXERDEV_MAX)
    {
      sprintf(Ksz_MessageErr, "SEG %s, UWY %d : maximum number of CTR/END/SEC is reached ; increase SEGEXERDEV_MAX value", Kbd_SEG.SEG_NF, Kbd_SEG.UWY_NF);
      n_WriteAno(Ksz_MessageErr);

      /* et 'plantage' du programme */
      Kb_ReturnStatus = 1;
    }
    else
    {
      strcpy(Ktbd_CASEX[Kn_NbreCASEX].CTR_NF, ptsz_LigneCour[CASEACT_CTR_NF]);
      Ktbd_CASEX[Kn_NbreCASEX].END_NT = (short)(atoi(ptsz_LigneCour[CASEACT_END_NT]));
      Ktbd_CASEX[Kn_NbreCASEX].SEC_NF = (short)(atoi(ptsz_LigneCour[CASEACT_SEC_NF]));
      Ktbd_CASEX[Kn_NbreCASEX].UWY_NF = (short)(atoi(ptsz_LigneCour[CASEACT_UWY_NF]));
      Ktbd_CASEX[Kn_NbreCASEX].UW_NT = (short)(atoi(ptsz_LigneCour[CASEACT_UW_NT]));
      strcpy(Ktbd_CASEX[Kn_NbreCASEX].EGPCUR_CF, ptsz_LigneCour[CASEACT_EGPCUR_CF]);
      Ktbd_CASEX[Kn_NbreCASEX].ModeGestion = *(ptsz_LigneCour[CASEACT_Sai_CT]);
      Ktbd_CASEX[Kn_NbreCASEX].TypeComptable = (short)atoi(ptsz_LigneCour[CASEACT_ACCADMTYP_CT]);
      Ktbd_CASEX[Kn_NbreCASEX].Nature = (short)atoi(ptsz_LigneCour[CASEACT_NAT_CF]);
      Ktbd_CASEX[Kn_NbreCASEX].PA = atof(ptsz_LigneCour[CASEACT_PAi_M]);
      Ktbd_CASEX[Kn_NbreCASEX].PAa = atof(ptsz_LigneCour[CASEACT_PAai_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Ps = atof(ptsz_LigneCour[CASEACT_Psi_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Ss = atof(ptsz_LigneCour[CASEACT_Ssi_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Sci = atof(ptsz_LigneCour[CASEACT_Scii_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Scc = atof(ptsz_LigneCour[CASEACT_Scci_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Scca = atof(ptsz_LigneCour[CASEACT_Sccai_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Sa = atof(ptsz_LigneCour[CASEACT_Sai_M]);
      Ktbd_CASEX[Kn_NbreCASEX].CALAMTPRM_M = atof(ptsz_LigneCour[CASEACT_ENTAMT_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Scirpcci_M = atof(ptsz_LigneCour[CASEACT_Scirpcci_M]);
      Ktbd_CASEX[Kn_NbreCASEX].Sccarpcci_M = atof(ptsz_LigneCour[CASEACT_Sccarpcci_M]);
      strcpy(Ktbd_CASEX[Kn_NbreCASEX].SEG_NF, ptsz_LigneCour[CASEACT_SEG_NF]);
      Ktbd_CASEX[Kn_NbreCASEX].Taux = 1.0; // par defaut

/*
if (strcmp(ptsz_LigneCour[CASEACT_SEG_NF], "MFSCREU 01") == 0 && strcmp(ptsz_LigneCour[CASEACT_UWY_NF], "2018") == 0)
{ 	
	printf("ici 100Chargement CASEACT_CTR_NF = %s - SEG_NF = %s - UWY_NF = %d - Sci = %-.3lf - CASEACT_UWY_NF = %s - Kn_BALSHTYEA = %d  - CASEACT_EGPCUR_CF = %s - Kbd_SEG.EGPCUR_CF = %s - Kn_NbreCASEX = %d\n",
          ptsz_LigneCour[CASEACT_CTR_NF],Ktbd_CASEX[Kn_NbreCASEX].SEG_NF,Ktbd_CASEX[Kn_NbreCASEX].UWY_NF,Ktbd_CASEX[Kn_NbreCASEX].Sci,ptsz_LigneCour[CASEACT_UWY_NF], Kn_BALSHTYEA, ptsz_LigneCour[CASEACT_EGPCUR_CF], Kbd_SEG.EGPCUR_CF,Kn_NbreCASEX);
}*/
      Kn_NbreCASEX++;
    }
  }
  /* Si aucun segment rattache a l'affaire : ecriture dans le GT d'une ligne */
  else
  {
    pbd_SyncPERICASE->ConditionEndSync = n_ConditionSyncPERICASE1;
    n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptsz_LigneCour);
    pbd_SyncPERICASE->ConditionEndSync = n_ConditionSyncPERICASE2;

    if (*ptsz_LigneCour[CASEACT_Sai_CT] == 'F')
    {
      d_Sai = atof(ptsz_LigneCour[CASEACT_Sai_M]);
    }
    else
    {
      /* Prop. et Non prop. 'Stop Loss & Annual Agregate' (NAT_CF=40 ou 41) */
      if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf == 40 || Kn_nat_cf == 41)
      {
        // ITD paid = [Scci = paid claims on complete account + (Scii + Sccai) = paid claims on incomplete account]

        double sai = atof(ptsz_LigneCour[CASEACT_Scci_M]) + atof(ptsz_LigneCour[CASEACT_Sccai_M]);

        // [20] by default for type=1
        d_Sai = sai;
      }
      else
      {
        /* Facultatives et Non Proportionnels */
        /* sauf Non proportionnels 'Stop Loss & Annual Agregate' */
        d_Sai = atof(ptsz_LigneCour[CASEACT_Scii_M]);
      }
    }

    /* Recherche du numero de version */
    Kn_VRS_NF = 0; /* valeur par defaut */
    for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++)
    {
      if (Ktn_ListeFiliales[Kn_Compteur] == atoi(Kptsz_PERICASE[PER_SSD_CF]))
      {
        Kn_VRS_NF = Ktn_ListeVersions[Kn_Compteur];
      }
    }

    memset(sortieBlanchiment, 0, sizeof(sortieBlanchiment));
    sprintf(sortieBlanchiment, "%s~%s~%s~%s~%s~%s~%s",
            Kptsz_PERICASE[PER_SSD_CF],
            Kptsz_PERICASE[PER_ACCESB_CF],
            Kptsz_PERICASE[PER_CTR_NF],
            Kptsz_PERICASE[PER_END_NT],
            Kptsz_PERICASE[PER_SEC_NF],
            Kptsz_PERICASE[PER_UWY_NF],
            Kptsz_PERICASE[PER_EGPCUR_CF]);

    d_IBNR1 = atof(ptsz_LigneCour[CASEACT_Sccarpcci_M]);
    d_IBNR2 = atof(ptsz_LigneCour[CASEACT_Scirpcci_M]) - d_IBNR1;

    //	[015]
    if (atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]) != 1)
    { //[019]
      if (fabs(d_IBNR1) < ZERO)
        d_IBNR2 = 0;
      else if (fabs(d_IBNR1) < fabs(d_IBNR2))
        d_IBNR2 = -d_IBNR1;
    } // end of [019]

    /* Ecriture des resultats dans le fichier des dommages si inventaire principal et non force */
    if ((*ptsz_LigneCour[CASEACT_Sai_CT] != 'F') && (Kc_INVTYP == 'P'))
    {
      fprintf(Kp_OutputFileDommages, "%s~%s~%s~%s~%s~%s~%d~%d~%s~%s~%s~%-.3lf~%-.3lf~%-.3lf~%c~%s~%d~~%s~%s~~~%-.3lf\n",
              ptsz_LigneCour[CASEACT_CTR_NF],
              ptsz_LigneCour[CASEACT_END_NT],
              ptsz_LigneCour[CASEACT_SEC_NF],
              ptsz_LigneCour[CASEACT_UWY_NF],
              ptsz_LigneCour[CASEACT_UW_NT],
              Ksz_CRE_D,
              atoi(Ksz_Prs),  // [023] 710,	
              20000,
              Kptsz_PERICASE[PER_SSD_CF],
              Kptsz_PERICASE[PER_DIV_NT],
              ptsz_LigneCour[CASEACT_EGPCUR_CF],
              d_Sai,
              atof(ptsz_LigneCour[CASEACT_ENTAMT_M]),
              d_Sai,
              'A',
              Ksz_CLODAT_D,
              Kn_VRS_NF,
              "CloP",
              Ksz_CRE_D,
              atof(ptsz_LigneCour[CASEACT_Scci_M]));   // [024] colonne INCURREDCI_M ajoutée dans TCTREST
    }

    if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf == 40 || Kn_nat_cf == 41)
    {
      if (fabs(d_Montant = atof(ptsz_LigneCour[CASEACT_Sccai_M])) > ZERO) /*  [017] (|| d_Montant == 0)  */
      {
        /*ajout une colonne pour retintamt_m */
        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                11494002, //IBNR1A
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
                Kptsz_PERICASE[PER_GANPAYORD_NT]);
        // Ajout de la sortie log Blanchiment
        printBlanchiment(sortieBlanchiment, "11494002", ptsz_LigneCour[CASEACT_Sccarpcci_M], ptsz_LigneCour[CASEACT_Scirpcci_M], d_IBNR1, d_IBNR2);
      }

      //[010]

      d_Montant = atof(ptsz_LigneCour[CASEACT_Sccarpcci_M]); // d_IBNR1A
      if (fabs(d_Montant) > ZERO)
      {
        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                11494012,
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
                Kptsz_PERICASE[PER_GANPAYORD_NT]);

        //Ajout de la log Blanchiment
        printBlanchiment(sortieBlanchiment, "11494012", ptsz_LigneCour[CASEACT_Sccarpcci_M], ptsz_LigneCour[CASEACT_Scirpcci_M], d_IBNR1, d_IBNR2);
      }

      //	[015]
      d_Montant = -atof(ptsz_LigneCour[CASEACT_Scii_M]) - atof(ptsz_LigneCour[CASEACT_Sccai_M]);

      if (atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]) != 1)
      { // [019]

        if (fabs(atof(ptsz_LigneCour[CASEACT_Sccai_M])) < ZERO)
        {
          d_Montant = 0;
          /*ajout une colonne pour retintamt_m */
          // [020] Debut
          fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                  11494052, //IBNR1B
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
                  0.0,
                  Kptsz_PERICASE[PER_CED_NF],
                  Kptsz_PERICASE[PER_PRD_NF],
                  Kptsz_PERICASE[PER_GENPRMPAY_NF],
                  Kptsz_PERICASE[PER_GANPAYORD_NT]);

          printBlanchiment(sortieBlanchiment, "11494052", ptsz_LigneCour[CASEACT_Sccarpcci_M], ptsz_LigneCour[CASEACT_Scirpcci_M], d_IBNR1, d_IBNR2);

          // [020] Fin
        }
        else if (fabs(atof(ptsz_LigneCour[CASEACT_Sccai_M])) < fabs(d_Montant))

          d_Montant = -atof(ptsz_LigneCour[CASEACT_Sccai_M]);
      }

      // end of  [019]

      if (fabs(d_Montant) > ZERO)
      {
        /*ajout une colonne pour retintamt_m */
        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                11494052, //IBNR1B
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
                Kptsz_PERICASE[PER_GANPAYORD_NT]);

        printBlanchiment(sortieBlanchiment, "11494052", ptsz_LigneCour[CASEACT_Sccarpcci_M], ptsz_LigneCour[CASEACT_Scirpcci_M], d_IBNR1, d_IBNR2);
      }

      //[010]
      d_Montant = (-atof(ptsz_LigneCour[CASEACT_Scirpcci_M]) - atof(ptsz_LigneCour[CASEACT_Sccarpcci_M]));

      if (fabs(d_Montant) > ZERO)
      {
        fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                11494062,
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
                Kptsz_PERICASE[PER_GANPAYORD_NT]);

        printBlanchiment(sortieBlanchiment, "11494062", ptsz_LigneCour[CASEACT_Sccarpcci_M], ptsz_LigneCour[CASEACT_Scirpcci_M], d_IBNR1, d_IBNR2);
      }
    }
  }
  RETURN_VAL(OK);
}

void printBlanchiment(char *debutLigne, const char *trncode, char *sccarpcci, char *scirpcci, double ibnr1A, double ibnr1b)
{
  // Ajout de la sortie de log BLANCHIMENT RPCC
  //
  fprintf(Kp_OutputBlanchiment, "%s~%s~%s~%s~%s~%.3lf~%.3lf\n",
          debutLigne,
          trncode,
          Ksz_CLODAT_D,
          sccarpcci,
          scirpcci,
          ibnr1A,
          ibnr1b);
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
  int n_NoCASEX;           /* Compteur du tableau des donnees des contrats */
  double d_Taux;           /* Taux de conversion */
  double d_IBNR_1A = 0.0;
  double d_IBNR_1B = 0.0;
  double d_Delta = 0.0;
  

  DEBUT_FCT("n_ActionDerniereRupture");

  /* Si segment non nul */
  if (Ks_SegmentNul == 0)
  {
    /* Remplissage de la structure IBNR */
    for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++)
    {
      for (Kn_CompteurEXER = 0; Kn_CompteurEXER < Kn_NbreEXER; Kn_CompteurEXER++)
      {
        strcpy(Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].CTR_NF, Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF);
        Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].END_NT = Ktbd_CASEX[Kn_CompteurCASEX].END_NT;
        Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].SEC_NF = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF;
        Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].UW_NT = Ktbd_CASEX[Kn_CompteurCASEX].UW_NT;
        Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].EXER_NF = Ktbd_EXER[Kn_CompteurEXER].EXER_NF;
      }
    }
  	// **************************************************************************************************
	  // [029] Debut bloc de Calcul du d_IncurredPosition valable pour tous types de contrats forces ou non
  	// **************************************************************************************************
//     n_NbreCASEXNonForce = 0;
    /* Conversion des montants de CASEX[]{} utiles aux calculs */
  	// **********************************************************
    for (n_NoCASEX = 0; n_NoCASEX < Kn_NbreCASEX; n_NoCASEX++)
    {
      /* Determination du taux de conversion */
      d_Taux = d_GetTaux(Kp_GetTaux, (unsigned char)atoi(Kptsz_PERICASE[PER_SSD_CF]), Kn_BALSHTYEA, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF);

      /* Generation d'une anomalie quand la fonction de taux renvoie 0 */
      if (d_Taux == -1 || d_Taux == 0)
      {
        sprintf(Ksz_MessageErr, "SSD : %s ; UWY : %d ; INITIAL CUR : %s ; FINAL CUR %s",
                Kptsz_PERICASE[PER_SSD_CF], Kn_BALSHTYEA,
                Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF);
        n_WriteAno(Ksz_MessageErr);
      }
    
      Ktbd_CASEX[n_NoCASEX].Pa *= d_Taux;   /* Prime actuarielle pure */
      Ktbd_CASEX[n_NoCASEX].PA *= d_Taux;   /* Prime acquise comptabilisee */
      Ktbd_CASEX[n_NoCASEX].PAa *= d_Taux;  /* Prime acquise actuarielle */
      Ktbd_CASEX[n_NoCASEX].Ps *= d_Taux;   /* Prime ultime de souscription */
      Ktbd_CASEX[n_NoCASEX].Ss *= d_Taux;   /* Sinistralite de souscription */
      Ktbd_CASEX[n_NoCASEX].Sci *= d_Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      Ktbd_CASEX[n_NoCASEX].Scc *= d_Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      Ktbd_CASEX[n_NoCASEX].Scca *= d_Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      Ktbd_CASEX[n_NoCASEX].Sa *= d_Taux;   /* Sinistralite actuarielle */
      Ktbd_CASEX[n_NoCASEX].Taux = d_Taux;  /* Sauvegarde taux de conversion a la devise segment */

//      if (Ktbd_CASEX[n_NoCASEX].ModeGestion != 'F')
//      {
//      	/* Les contrats forces sont retires de la somme sur le segment */
//        n_NbreCASEXNonForce += 1;
//      }
//      else
//      {
//      	Ktbd_CASEX[n_NoCASEX].IncurredPos = 0.0;
//      }
//    }
/*if (strcmp(Ktbd_CASEX[n_NoCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[n_NoCASEX].UWY_NF == 2016 || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2018 || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2019))
{
	printf("ici 100Apres conversion ~%s~%d~%d~%d~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.6lf\n",
          Ktbd_CASEX[n_NoCASEX].CTR_NF, Ktbd_CASEX[n_NoCASEX].UWY_NF, (unsigned char)atoi(Kptsz_PERICASE[PER_SSD_CF]), Kn_BALSHTYEA, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF, 
          Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Pa, Ktbd_CASEX[n_NoCASEX].PA, Ktbd_CASEX[n_NoCASEX].Taux);
}*/
    }
   	d_IncurredPosition = 0.0;
 	  d_IncurredPositionF = 0.0;
    for (n_NoCASEX = 0; n_NoCASEX < Kn_NbreCASEX; n_NoCASEX++)
    {
  	  // [029] Calcul du d_IncurredPosition valable pour tous types de contrats forces ou non
    	d_Delta = Ktbd_CASEX[n_NoCASEX].Scc + Ktbd_CASEX[n_NoCASEX].Scca; // [021] Last completed

      d_IBNR_1A = Ktbd_CASEX[n_NoCASEX].Scca;
      d_IBNR_1B = -Ktbd_CASEX[n_NoCASEX].Sci - Ktbd_CASEX[n_NoCASEX].Scca;
      if ((*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf == 40 || Kn_nat_cf == 41) && Ktbd_CASEX[n_NoCASEX].TypeComptable != 1)
      {      
        if (fabs(d_IBNR_1A) < ZERO)
          d_IBNR_1B = 0;
        else if (fabs(d_IBNR_1A) < fabs(d_IBNR_1B))
          d_IBNR_1B = -d_IBNR_1A;
      }
      //d_IncurredPosition ne prendre pas le ModeGestion =F
      if (Ktbd_CASEX[n_NoCASEX].TypeComptable != 1)
      {
        if (fabs(d_IBNR_1A) < fabs(d_IBNR_1B) || (fabs(d_IBNR_1A) < 1) || (fabs(d_IBNR_1A + d_IBNR_1B) < 1))
        {                                                                                            // condition (d_IBNR_1A + d_IBNR_1A) == 0
          d_Delta = Ktbd_CASEX[n_NoCASEX].Sci + Ktbd_CASEX[n_NoCASEX].Scc + Ktbd_CASEX[n_NoCASEX].Scca; //[021] ITD_PAID
        }
        
	    //delta = -MAX(-Ktbd_CASEX[n_NoCASEX].Scc - Ktbd_CASEX[n_NoCASEX].Scca, -Ktbd_CASEX[n_NoCASEX].Sci - Ktbd_CASEX[n_NoCASEX].Scc - Ktbd_CASEX[n_NoCASEX].Scca );

      }
      Ktbd_CASEX[n_NoCASEX].IncurredPos = d_Delta;
      d_IncurredPosition += d_Delta; // [021] replace the max rule in spira 75058
      if (Ktbd_CASEX[n_NoCASEX].ModeGestion == 'F') d_IncurredPositionF += d_Delta; // [029]
      
//if (strcmp(Kbd_SEG.SEG_NF, "MFSCREU 01") == 0 && Kbd_SEG.UWY_NF == 2015 && strcmp(Kbd_SEG.EGPCUR_CF, "EUR") == 0)
//{ 
	
/*if (strcmp(Ktbd_CASEX[n_NoCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[n_NoCASEX].UWY_NF == 2015 && strcmp(Ktbd_CASEX[n_NoCASEX].CTR_NF,"02T025193") == 0))  // || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2018 || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2019))
{
	printf("ici 100Apres Calcul d_IncurredPosition ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.6lf\n",
          Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/

    }
  	// **************************************************************************************************
	  // [029] Fin bloc de Calcul du d_IncurredPosition valable pour tous types de contrats forces ou non
  	// **************************************************************************************************
    
    for (Kn_CompteurCASEX = 0; Kn_CompteurCASEX < Kn_NbreCASEX; Kn_CompteurCASEX++)
    {
      if (b_EOF_MAITRE == TRUE)
      {
        /* Permet d'empecher un pere sans fils */
        b_EOF_MAITRE = FALSE; /* lors du traitement du dernier bloc */
      }

      /* Synchronisation avec le perimetre */
      n_ProcessingRuptureSyncVar(pbd_SyncPERICASE, ptsz_LigneCour);


      //il faut synchroniser AVANT avec le périmètre poour être sur la bonne ligne du périmètre car on doit prendre la filiale du périmètre
      // pour le segment en cours dans Ktbd_CASEX
      // comme n_SinisActu calcule pour tout Ktbd_CASEX, on execute une fois pour le segment
      if (Kn_CompteurCASEX == 0)
      {
        /* Appel du lot 5 */
        n_SinisActu(*ptsz_LigneCour[CASEACT_CTRNAT_CT], Kn_NbreEXER, Kn_NbreCASEX, &Kbd_SEG, Ktbd_EXER, Ktbd_CASEX, Ktbd_IBNR);
      }
      
      /* Recherche du numero de version */
      Kn_VRS_NF = 0; /* valeur par defaut */
      for (Kn_Compteur = 0; Kn_Compteur < Kn_NbreFiliales; Kn_Compteur++)
      {
        if (Ktn_ListeFiliales[Kn_Compteur] == atoi(Kptsz_PERICASE[PER_SSD_CF]))
        {
          Kn_VRS_NF = Ktn_ListeVersions[Kn_Compteur];
        }
      }

      /* Ecriture des resultats dans le fichier des dommages si inventaire principal et non force */
//      if ((Kc_INVTYP == 'P') && (Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion != 'F' || (Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion == 'F' && atoi(Ksz_Prs) == 730 )))  // [024] maintenant ecriture si forcé
      // [024] maintenant ecriture dans tous les cas pour IFRS4 et uniquement en mode F si EBS
//      if (Kc_INVTYP == 'P' && (atoi(Ksz_Prs) == 710 || (atoi(Ksz_Prs) == 730 && Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion == 'F'))) 
      // [028] Maintenant, on genere les données en période exceptionnelle pour IFRS4 et dans tous les cas pour EBS
      if (Kc_INVTYP == 'P')
      {
        fprintf(Kp_OutputFileDommages, "%s~%s~%s~%s~%s~%s~%d~%d~%s~%s~%s~%-.3lf~%-.3lf~%-.3lf~%c~%s~%d~%s~%s~%s~~~%-.3lf\n",
                Kptsz_PERICASE[PER_CTR_NF],
                Kptsz_PERICASE[PER_END_NT],
                Kptsz_PERICASE[PER_SEC_NF],
                Kptsz_PERICASE[PER_UWY_NF],
                Kptsz_PERICASE[PER_UW_NT],
                Ksz_CRE_D,
                atoi(Ksz_Prs),  // [023]  710,
                20000,
                Kptsz_PERICASE[PER_SSD_CF],
                Kptsz_PERICASE[PER_DIV_NT],
                Kptsz_PERICASE[PER_EGPCUR_CF],
                Ktbd_CASEX[Kn_CompteurCASEX].Sa/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
                /* Champ ENTMAMT_M initial dans le champ CALAMTPRM_M de la structure */
                Ktbd_CASEX[Kn_CompteurCASEX].CALAMTPRM_M,
                Ktbd_CASEX[Kn_CompteurCASEX].Sa/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
                Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion,  //'A', [024]
                Ksz_CLODAT_D,
                Kn_VRS_NF,
                Kbd_SEG.SEG_NF,
                "CloP",
                Ksz_CRE_D,
                Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux);  // [024] colonne INCURREDCI_M ajoutée dans TCTREST
      }

      /* Ecriture des resultats dans le fichier GT */
      /* Existence d'exercice de survenances */
      if (Kn_NbreEXER)
      {
        for (Kn_CompteurEXER = 0; Kn_CompteurEXER < Kn_NbreEXER; Kn_CompteurEXER++)
        {
          Kd_Sccij = 0;  //IBNR1B
          Kd_Sccaij = 0; //IBNR1A
          n_ProcessingRuptureSyncVar(pbd_SyncGT, ptsz_LigneCour);

          if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf == 40 || Kn_nat_cf == 41)
          {
            /** ----------------------- Debut [018]--------------------------------------------------------*/
            d_Montant = -Kd_Sccaij;
            // The Outstanding Loss Reserve (OLR) on Complete Account for Prop and Non-Prop  'Stop Loss & Annual Agregate' (NAT_CF=40 ou 41) = Premium & Claim Variables.Sccaij is changed as the maximum between itself and the (ITD Paid = Paid complet account + Paid uncomplete account = Premium & Claim Variables.Scci_M + Premium & Claim Variables.Scii_M
            // ITD paid = [Scci = paid claims on complete account + (Scii + Sccai) = paid claims on incomplete account]
            // exclude type !=1 //	[019]

            if (atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]) != 1)
            { //[019]

              // [20]  new rule for type !=1

              if (fabs(Kd_Sccaij) < ZERO)
              {

                fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                        0.0,
                        Kptsz_PERICASE[PER_CED_NF],
                        Kptsz_PERICASE[PER_PRD_NF],
                        Kptsz_PERICASE[PER_GENPRMPAY_NF],
                        Kptsz_PERICASE[PER_GANPAYORD_NT]);
              }

              else
              {
                //if ( abs(IBNR1A) < abs(IBNR1B) )
                if (fabs(Kd_Sccaij) < fabs(Kd_Sccij))
                {
                  d_Montant = -Kd_Sccaij;
                }
              }
            }

            /** ------------------------ Fin [018]-------------------------------------------------------*/
            if (fabs(Kd_Sccaij) > ZERO) /* [018] */
            {
              /*ajout une colonne pour retintamt_m */
              fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                      11494002, // IBNR1A
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
                      Kd_Sccaij, /* [018] */
                      Kptsz_PERICASE[PER_CED_NF],
                      Kptsz_PERICASE[PER_PRD_NF],
                      Kptsz_PERICASE[PER_GENPRMPAY_NF],
                      Kptsz_PERICASE[PER_GANPAYORD_NT]);
            }

            if (fabs(Kd_Sccaij) > ZERO) /* [018] */
            {
              /*ajout une colonne pour retintamt_m */
              fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                      11494052, // IBNR1B
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
                      Kptsz_PERICASE[PER_GANPAYORD_NT]);
            }

            //[010]
            d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Sccarpcci_M;
            if (fabs(d_Montant) > ZERO)
            {
              fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                      11494012,
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
                      Kptsz_PERICASE[PER_GANPAYORD_NT]);
            }
            //[010]
            d_Montant = -Ktbd_CASEX[Kn_CompteurCASEX].Scirpcci_M - Ktbd_CASEX[Kn_CompteurCASEX].Sccarpcci_M;

            if (fabs(d_Montant) > ZERO)
            {
              fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                      11494062,
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
                      Kptsz_PERICASE[PER_GANPAYORD_NT]);
            }
            //[020]

            d_Montant = Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].IBNR - Kd_Sccaij;

          } //end of  if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf ==40 || Kn_nat_cf == 41)
          else
          {
            d_Montant = Ktbd_IBNR[Kn_CompteurCASEX * Kn_NbreEXER + Kn_CompteurEXER].IBNR;
          }

          if (fabs(d_Montant) > ZERO)
          {
            /*ajout une colonne pour retintamt_m */

            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%d~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                    11494102, //IBNR2
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
                    Kptsz_PERICASE[PER_GANPAYORD_NT]);
          }
        }
      }

      /* Absence d'exercice de survenance */
      else
      {
/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2015 ))  //|| Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici avant ecriture 0 ~%s~%s~%-.3lf~%-.3lf~%d\n",
	       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF],Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
	       Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux,atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]));
          //Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          //d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/

        if (*ptsz_LigneCour[CASEACT_CTRNAT_CT] == 'P' || Kn_nat_cf == 40 || Kn_nat_cf == 41)
        {
          /** ----------------------- Debut [018]--------------------------------------------------------*/

          d_Montant = (-Ktbd_CASEX[Kn_CompteurCASEX].Sci - Ktbd_CASEX[Kn_CompteurCASEX].Scca);

/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2015 ))  //|| Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici avant 1ere ecriture 11494052 ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%d\n",
	       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF],Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
	       Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux,d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos,atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]));
          //Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          //d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/
          if (atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]) != 1)
          {

            if (fabs(Ktbd_CASEX[Kn_CompteurCASEX].Scca) < ZERO)
            {
              d_Montant = 0;
              fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                      0.0,
                      Kptsz_PERICASE[PER_CED_NF],
                      Kptsz_PERICASE[PER_PRD_NF],
                      Kptsz_PERICASE[PER_GENPRMPAY_NF],
                      Kptsz_PERICASE[PER_GANPAYORD_NT]);
            }
            else if (fabs(Ktbd_CASEX[Kn_CompteurCASEX].Scca) < fabs(d_Montant))

              d_Montant = -Ktbd_CASEX[Kn_CompteurCASEX].Scca;
          }

/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2015 ))  //|| Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici avant ecriture 11494002 ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%d\n",
	       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF],Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
	       Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux,d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos,atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]));
          //Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          //d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/
          /** ------------------------ Fin [018]-------------------------------------------------------*/

          if (fabs(Ktbd_CASEX[Kn_CompteurCASEX].Scca) > ZERO) /* [018]  */
          {
            /*ajout une colonne pour retintamt_m */
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                    Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux, /* [018]  */
                    Kptsz_PERICASE[PER_CED_NF],
                    Kptsz_PERICASE[PER_PRD_NF],
                    Kptsz_PERICASE[PER_GENPRMPAY_NF],
                    Kptsz_PERICASE[PER_GANPAYORD_NT]);
          }
/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2015 ))  //|| Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici avant 2eme ecriture 11494052 ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%d\n",
	       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF],Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
	       Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux,d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos,atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]));
          //Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          //d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/
          if (fabs(d_Montant) > ZERO) /* [018]  */
          {
            /*ajout une colonne pour retintamt_m */
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                    d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
                    Kptsz_PERICASE[PER_CED_NF],
                    Kptsz_PERICASE[PER_PRD_NF],
                    Kptsz_PERICASE[PER_GENPRMPAY_NF],
                    Kptsz_PERICASE[PER_GANPAYORD_NT]);
          }
          //[010]
          d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Sccarpcci_M;
          if (fabs(d_Montant) > ZERO)
          {
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                    11494012,
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
                    Kptsz_PERICASE[PER_GANPAYORD_NT]);
          }
          //[010]
          d_Montant = -Ktbd_CASEX[Kn_CompteurCASEX].Scirpcci_M - Ktbd_CASEX[Kn_CompteurCASEX].Sccarpcci_M;
          if (fabs(d_Montant) > ZERO)
          {
            fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                    11494062,
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
                    Kptsz_PERICASE[PER_GANPAYORD_NT]);
          }
        }

//        if (Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion != 'F')
//        {
        d_Montant = Ktbd_CASEX[Kn_CompteurCASEX].Sa - Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos; //  d_IncurredPosition;
//        } 
//        else 
//        {
//			    d_Montant = Kbd_SEG.Sa - d_IncurredPosition;
//	      }
//
        if (fabs(d_Montant) > ZERO)
        {

/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MPSCC   02") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2015 ))  //|| Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici avant ecriture 11494102 ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%d\n",
	       Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF],Ktbd_CASEX[Kn_CompteurCASEX].Sci/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
	       Ktbd_CASEX[Kn_CompteurCASEX].Scca/Ktbd_CASEX[Kn_CompteurCASEX].Taux,d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos,atoi(Kptsz_PERICASE[PER_ACCADMTYP_CT]));
          //Ktbd_CASEX[n_NoCASEX].CTR_NF, ptsz_LigneCour[CASEACT_UWY_NF], Ktbd_CASEX[n_NoCASEX].Scca, Ktbd_CASEX[n_NoCASEX].Sci, Ktbd_CASEX[n_NoCASEX].Scc, Ktbd_CASEX[n_NoCASEX].EGPCUR_CF, Kbd_SEG.EGPCUR_CF,
          //d_Delta,d_IncurredPosition,d_IncurredPositionF,d_IBNR_1A,d_IBNR_1B,Ktbd_CASEX[n_NoCASEX].Taux);
}*/
/*if (strcmp(Ktbd_CASEX[Kn_CompteurCASEX].SEG_NF, "MNCLIAB 01") == 0 && (Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2018 || Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF == 2019))
{
	printf("ici Final ~%s~%s~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%C~%d~%-.3lf\n",
	Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF,Ktbd_CASEX[Kn_CompteurCASEX].UWY_NF,d_Montant,Kbd_SEG.Sa,Ktbd_CASEX[Kn_CompteurCASEX].Sa,d_IncurredPosition,Ktbd_CASEX[Kn_CompteurCASEX].ModeGestion,Kn_CompteurCASEX,Ktbd_CASEX[Kn_CompteurCASEX].IncurredPos);
}*/

          /*ajout une colonne pour retintamt_m */
          fprintf(Kp_OutputFileGT, "%s~%s~%c%c%c%c~%c%c~%c%c~%d~~%s~%s~%s~%s~%s~%s~%c%c%c%c~%c%c~%c%c~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
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
                  11494102, //IBNR2
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
                  d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,
                  Kptsz_PERICASE[PER_CED_NF],
                  Kptsz_PERICASE[PER_PRD_NF],
                  Kptsz_PERICASE[PER_GENPRMPAY_NF],
                  Kptsz_PERICASE[PER_GANPAYORD_NT]);

          /* [007] Ecriture dans le fichiers de logs des données nécessaires au calcul des IBNR 2 */
          //Contrat	section Segment	Exercice	nature contrat	mode de gestion contrat	devise	Scc contrat	Sci contrat	Scca contrat	Ss contrat	Ss segment	Sa Segment	Sc segment
          // [011] Ajout Filiale, Etablissement et les Primes acquises
          //											1	 2	3	 4  5  6  7    8	    9	   10   11    12    13    14   15  16
          fprintf(Kp_OutputFileTrace, "%s~%s~%s~%s~%s~%s~%c~%s~%s~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%.3lf~%s~%.3lf~%.6lf\n",
                  Kptsz_PERICASE[PER_SSD_CF],         /* 1 Filiale */
                  Kptsz_PERICASE[PER_ACCESB_CF],      /* 1b Etablissement */
                  Kptsz_PERICASE[PER_CTR_NF],         /* 2 Contrat */
                  Kptsz_PERICASE[PER_SEC_NF],         /* 3 Section */
                  Kbd_SEG.SEG_NF,                     /* 4 Segment */
                  Kptsz_PERICASE[PER_UWY_NF],         /* 5 Section */
                  *ptsz_LigneCour[CASEACT_CTRNAT_CT], /* 6 Nature du contrat : P, N ou F */
                  Kptsz_PERICASE[PER_ADMMODPRM_CT],   /* 7 Mode de gestion du contrat : M, A ou F */
                  Kptsz_PERICASE[PER_EGPCUR_CF],      /* 8 Devise */
                  Ktbd_CASEX[Kn_CompteurCASEX].PA,    /* 9 Prime acquise comptabilisée */
                  Ktbd_CASEX[Kn_CompteurCASEX].PAa,   /* 10 Prime acquise actuarielle */
                  Ktbd_CASEX[Kn_CompteurCASEX].Scc,   /* 11 Scc contrat */
                  Ktbd_CASEX[Kn_CompteurCASEX].Sci,   /* 12 Sci contrat */
                  Ktbd_CASEX[Kn_CompteurCASEX].Scca,  /* 13 Scca contrat */
                  Ktbd_CASEX[Kn_CompteurCASEX].Ss,    /* 14 Ss contrat */
                  Kbd_SEG.PA,                         /* 15 Prime acquise comptabilisée */
                  Kbd_SEG.PAa,                        /* 16 Prime acquise actuarielle */
                  Kbd_SEG.Ss,                         /* 17 Ss segment */
                  Kbd_SEG.Sa,                         /* 18 Sa segment */
                  Kbd_SEG.Sc,                         /* 19 Sc segment */
                  Kbd_SEG.EGPCUR_CF,                  /* 20 Devise de l'aliment */
                  d_Montant/Ktbd_CASEX[Kn_CompteurCASEX].Taux,    /* 21 IBNR calcule par le programme */
                  Ktbd_CASEX[Kn_CompteurCASEX].Taux   /* 22 Ajout Taux */
          );
        }
      }
    }
    /* Reconversion des montants de CASEX[]{} utiles aux calculs */
  	// ************************************************************
    for (n_NoCASEX = 0; n_NoCASEX < Kn_NbreCASEX; n_NoCASEX++)
    {
      Ktbd_CASEX[n_NoCASEX].Pa /= Ktbd_CASEX[n_NoCASEX].Taux;   /* Prime actuarielle pure */
      Ktbd_CASEX[n_NoCASEX].PA /= Ktbd_CASEX[n_NoCASEX].Taux;   /* Prime acquise comptabilisee */
      Ktbd_CASEX[n_NoCASEX].PAa /= Ktbd_CASEX[n_NoCASEX].Taux;  /* Prime acquise actuarielle */
      Ktbd_CASEX[n_NoCASEX].Ps /= Ktbd_CASEX[n_NoCASEX].Taux;   /* Prime ultime de souscription */
      Ktbd_CASEX[n_NoCASEX].Ss /= Ktbd_CASEX[n_NoCASEX].Taux;   /* Sinistralite de souscription */
      Ktbd_CASEX[n_NoCASEX].Sci /= Ktbd_CASEX[n_NoCASEX].Taux;  /* Sinistralite comptabilisee sur comptes incomplets */
      Ktbd_CASEX[n_NoCASEX].Scc /= Ktbd_CASEX[n_NoCASEX].Taux;  /* Sinistralite comptabilisee sur SP comptes complets */
      Ktbd_CASEX[n_NoCASEX].Scca /= Ktbd_CASEX[n_NoCASEX].Taux; /* Sinistralite comptabilisee sur SAP comptes complets */
      Ktbd_CASEX[n_NoCASEX].Sa /= Ktbd_CASEX[n_NoCASEX].Taux;   /* Sinistralite actuarielle */
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
    char *ptsz_LigneEsclave[])
{
  static short ret;

  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[SEGEST2_SEG_NF])))
  {
    return ret;
  }
  return strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[SEGEST2_UWY_NF]);
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
    char *ptsz_LigneEsclave[])
{
  DEBUT_FCT("n_ActionLigneSyncSEGEST");

  strcpy(Kbd_SEG.SEG_NF, ptsz_LigneEsclave[SEGEST2_SEG_NF]);
  Kbd_SEG.UWY_NF = (short)atoi(ptsz_LigneEsclave[SEGEST2_UWY_NF]);
  strcpy(Kbd_SEG.EGPCUR_CF, ptsz_LigneEsclave[SEGEST2_CUR_CF]);

  Kbd_SEG.Pa = atof(ptsz_LigneEsclave[SEGEST2_Pa_M]);
  Kbd_SEG.PA = atof(ptsz_LigneEsclave[SEGEST2_PA_M]);
  Kbd_SEG.PAa = atof(ptsz_LigneEsclave[SEGEST2_PAa_M]);
  Kbd_SEG.Ps = atof(ptsz_LigneEsclave[SEGEST2_Ps_M]);
  Kbd_SEG.Ss = atof(ptsz_LigneEsclave[SEGEST2_Ss_M]);
  Kbd_SEG.Sc = atof(ptsz_LigneEsclave[SEGEST2_Sc_M]);
  Kbd_SEG.Sa = atof(ptsz_LigneEsclave[SEGEST2_Sa_M]);
  Kbd_SEG.AMORAT_CT = *ptsz_LigneEsclave[SEGEST2_AMORAT_CT];  // [031]
  
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
    char *ptsz_LigneEsclave[])
{
  static short ret;

  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[LABOCYEST_SEG_NF])))
  {
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
    char *ptsz_LigneEsclave[])
{
  DEBUT_FCT("n_ActionLigneSyncLABOCY");

  if (Kn_NbreEXER == EXER_MAX)
  {
    sprintf(Ksz_MessageErr, "SEG %s, UWY %d : maximum number of EXER is reached ; increase EXER_MAX value", Kbd_SEG.SEG_NF, Kbd_SEG.UWY_NF);
    n_WriteAno(Ksz_MessageErr);

    /* et 'plantage' du programme */
    Kb_ReturnStatus = 1;
  }
  else
  {
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
    char *ptsz_LigneEsclave[])
{
  static short ret;

  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[PER_SEG_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_EGPCUR_CF], ptsz_LigneEsclave[PER_EGPCUR_CF])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_CTR_NF], ptsz_LigneEsclave[PER_CTR_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_END_NT], ptsz_LigneEsclave[PER_END_NT])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEC_NF], ptsz_LigneEsclave[PER_SEC_NF])))
  {
    return ret;
  }
  return (strcmp(ptsz_LigneMaitre[CASEACT_UW_NT], ptsz_LigneEsclave[PER_UW_NT]));
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
    char *ptsz_LigneEsclave[])
{
  static short ret;

  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_SEG_NF], ptsz_LigneEsclave[PER_SEG_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(ptsz_LigneMaitre[CASEACT_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].EGPCUR_CF, ptsz_LigneEsclave[PER_EGPCUR_CF])))
  {
    return ret;
  }
  if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneEsclave[PER_CTR_NF])))
  {
    return ret;
  }
  if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].END_NT - (short)atoi(ptsz_LigneEsclave[PER_END_NT])))
  {
    return ret;
  }
  if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF - (short)atoi(ptsz_LigneEsclave[PER_SEC_NF])))
  {
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
    char *ptsz_LigneEsclave[])
{
  DEBUT_FCT("n_ActionLigneSyncPERICASE");

  Kptsz_PERICASE = ptsz_LigneEsclave;
  Kn_nat_cf = atoi(Kptsz_PERICASE[PER_NAT_CF]);

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
    char *ptsz_LigneEsclave[])
{
  static short ret;

  if ((ret = strcmp(Kbd_SEG.SEG_NF, ptsz_LigneEsclave[GTESTCUMUL1_SEG_NF])))
  {
    return ret;
  }
  if ((ret = Kbd_SEG.UWY_NF - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_UWY_NF])))
  {
    return ret;
  }
  if ((ret = strcmp(Kptsz_PERICASE[PER_EGPCUR_CF], ptsz_LigneEsclave[GTESTCUMUL1_ACMCUR_CF])))
  {
    return ret;
  }
  if ((ret = strcmp(Ktbd_CASEX[Kn_CompteurCASEX].CTR_NF, ptsz_LigneEsclave[GTESTCUMUL1_CTR_NF])))
  {
    return ret;
  }
  if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].END_NT - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_END_NT])))
  {
    return ret;
  }
  if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].SEC_NF - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_SEC_NF])))
  {
    return ret;
  }
  if ((ret = Ktbd_CASEX[Kn_CompteurCASEX].UW_NT - (short)atoi(ptsz_LigneEsclave[GTESTCUMUL1_UW_NT])))
  {
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
    char *ptsz_LigneEsclave[])
{
  DEBUT_FCT("n_ActionLigneSyncGT");

  if (atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMTRS_NT]) == -20000)
  {
    Kd_Sccij = atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMAMT_M]);
  }
  if (atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMTRS_NT]) == -20030)
  {
    Kd_Sccaij = atof(ptsz_LigneEsclave[GTESTCUMUL1_ACMAMT_M]);
  }

  RETURN_VAL(OK);
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
/***	i Kn_NbreCASEX : nombre de lignes du tableau des contrats,	***/
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

int n_SinisActu(char CTRNAT_CT, int n_NbreEXER, int n_NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[])
{
  T_SEG *pbd_SEGRES;         /* vecteur des donnees du segment restreint (sans les lignes forcees) */
  double d_MtRapportP = 0;   /* Rapport Pai/Pa */
  double d_MtRapportSi = 0;  /* Rapport Sci/Sc */
  double d_MtRapportLDF = 0; /* [006] Rapport Sc/Sa Loss Development Factor PHP */
  double d_MtRapportSc = 0;  /* [006] Rapport Sc contrat/Sc segment PHP */
  int n_NoCASEX;           /* Compteur du tableau des donnees des contrats */
  short s_Erreur = 0;      /* Variable d'erreur */
  char ct_Erreur[256];     /* Message d'erreur */

  //double tbd_sinisCompta=0.0;  /* Calcul de la sinistralité comptabilisée */
  double d_CTRsegmentSA = 0;
  double d_IBNR2Incurred = 0.0;


  // FIN DEBUG

  DEBUT_FCT("n_SinisActu");
  pbd_SEGRES = malloc(sizeof(T_SEG));

  //debug vérif des segments qui étaient en erreur
  //printf("in n_SinisActu,  Kptsz_PERICASE[ACCADMTYP_CT]=%s, CTRNAT_CT=%c,Kn_nat_cf=%d \n",Kptsz_PERICASE[PER_ACCADMTYP_CT], CTRNAT_CT , Kn_nat_cf);
  if (strcmp(Kptsz_PERICASE[PER_SEG_NF], pbd_SEG->SEG_NF))
  {
    printf("Périmètre pas synchro avec le segment en cours: PERI_%s~SEG_MASTER_%s~%d~%s\n", Kptsz_PERICASE[PER_SEG_NF], pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF);
  }

  /*****************/
  /* Proportionnel */
  /*****************/

  if (CTRNAT_CT == 'P')
  {

    /* Recopie du vecteur des donnees du segment desquelles seront soustraites les donnees des lignes forcees */

    pbd_SEGRES->Ss = pbd_SEG->Ss;
    pbd_SEGRES->Sa = pbd_SEG->Sa;
    //pbd_SEGRES->Sc = pbd_SEG->Sc; /* [006] PHP */
    pbd_SEGRES->Sc = d_IncurredPosition;
    	
    // [006]
    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F')
      {
        pbd_SEGRES->Ss = pbd_SEGRES->Ss - tbd_CASEX[n_NoCASEX].Ss;
        pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
//        pbd_SEGRES->Sc = pbd_SEGRES->Sc - d_IncurredPosition; // [029] subtract d_IncurredPosition now
        pbd_SEGRES->Sc = pbd_SEGRES->Sc - tbd_CASEX[n_NoCASEX].IncurredPos; // [029]
      }
    }

//    if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F')   //[024]
//    {
//      pbd_SEGRES->Sc = d_IncurredPosition;
//    }
    d_IBNR2Incurred = pbd_SEGRES->Sa - pbd_SEGRES->Sc; // Sa - Sc

    if ((fabs(pbd_SEGRES->Sc) < 1) || (fabs(pbd_SEGRES->Sa) < 1))
    {
      d_MtRapportLDF = 0;
    }
    else
    {
      d_MtRapportLDF = fabs(pbd_SEGRES->Sc + d_IBNR2Incurred) > 1 ? pbd_SEGRES->Sc / (pbd_SEGRES->Sc + d_IBNR2Incurred) : 0.0; // pbd_SEGRES->Sa - d_IncurredPosition = IBNR2

      if (d_MtRapportLDF < 0 || d_MtRapportLDF > 1)
      {
        sprintf(ct_Erreur, "Abnormal ldf value (= %lf ) for SEG %s, UWY %d, Segment Currency %s, SSD %s.",
                d_MtRapportLDF, pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF, Kptsz_PERICASE[PER_SSD_CF]);
        n_WriteAno(ct_Erreur);
      }
    }

    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F')
      {
        /* calcul du U/W Loss Prorata  d_MtRapportSc */
//        if (fabs(pbd_SEGRES->Ss) < 1)
//        {
//          d_MtRapportSc = 0; // [006]
//          tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].Ss + pbd_SEGRES->Sa / n_NbreCASEXNonForce;
//        }
//        else
//        {

          // [008] Si Ss > 1, c'est tout le Sa qui est calculé. Pas seulement une partie
  
        if (fabs(pbd_SEGRES->Sc) < 1)
        {
          d_MtRapportSi = 0;
          s_Erreur = 1;
        }
        else
        {
          //[007] - update of RapportSi calculation
          //[021] no need to check Type 1 or not
          d_MtRapportSi = (fabs(pbd_SEGRES->Sc) > 1) ? tbd_CASEX[n_NoCASEX].IncurredPos / pbd_SEGRES->Sc : 0.0;
        }


           if (fabs(pbd_SEGRES->Ss) > 1)
		   {
             d_MtRapportSc = tbd_CASEX[n_NoCASEX].Ss / pbd_SEGRES->Ss ; 
		   }
           else if ( pbd_SEGRES->Ss < 1 && pbd_SEG->PA  > 0.0001 )		   
           {
             d_MtRapportSc = tbd_CASEX[n_NoCASEX].PA / pbd_SEG->PA ; // new rule spira 110431
		   }
           else
           {
             d_MtRapportSc = 1.0 ; 
           }

				  
	  
        //tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].IncurredPos  + d_IBNR2Incurred * ((1 - d_MtRapportLDF) * d_MtRapportSc + d_MtRapportLDF * d_MtRapportSi); 
        tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].IncurredPos + d_IBNR2Incurred * ((1 - d_MtRapportLDF) * d_MtRapportSc + d_MtRapportLDF * d_MtRapportSi);  // [029]
//        }
        d_CTRsegmentSA += tbd_CASEX[n_NoCASEX].Sa;
      }
      else d_MtRapportSc = 0.0;  //  [029]
      // pas besoin de calculer ModeGestion = 'F', tout est à 0
/*if (strcmp(tbd_CASEX[n_NoCASEX].CTR_NF, "17ZF38401") == 0 )  //&& strcmp(tbd_CASEX[n_NoCASEX].SEG_NF, "MPCMDIRL17") == 0)  // || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2018 || Ktbd_CASEX[n_NoCASEX].UWY_NF == 2019))
{
	printf("ici 100Apres Calcul nsinis_Actu~%s~%d~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf\n",
          tbd_CASEX[n_NoCASEX].CTR_NF, pbd_SEG->UWY_NF, tbd_CASEX[n_NoCASEX].Sa, tbd_CASEX[n_NoCASEX].IncurredPos, d_IBNR2Incurred, d_MtRapportLDF, d_MtRapportP, d_MtRapportSi,d_MtRapportSc, 
          tbd_CASEX[n_NoCASEX].PAa, tbd_CASEX[n_NoCASEX].Scca, tbd_CASEX[n_NoCASEX].Sci, pbd_SEGRES->Sa, pbd_SEGRES->Sc, d_IncurredPosition, tbd_CASEX[n_NoCASEX].Scc);
}*/

    }
    n_IBNRActu(n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR);
  }

  /*************************/
  /* Cas non proportionnel */
  /*************************/

  else if (CTRNAT_CT == 'N')
  {

    /* Recopie du vecteur des donnees du segment desquelles seront soustraites les donnees des lignes forcees */

    pbd_SEGRES->PAa = pbd_SEG->PAa;
    //pbd_SEGRES->Sc = pbd_SEG->Sc;
    pbd_SEGRES->Sc = d_IncurredPosition;
    pbd_SEGRES->Sa = pbd_SEG->Sa;

    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F')
      {
        pbd_SEGRES->PAa = pbd_SEGRES->PAa - tbd_CASEX[n_NoCASEX].PAa;
        pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
//        pbd_SEGRES->Sc = pbd_SEGRES->Sc - d_IncurredPosition; // [029] 
        pbd_SEGRES->Sc = pbd_SEGRES->Sc - tbd_CASEX[n_NoCASEX].IncurredPos; // [029]
      }
    }

    d_IBNR2Incurred = pbd_SEGRES->Sa - pbd_SEGRES->Sc; // Sa - Sc

    /* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

    if (fabs(pbd_SEGRES->Sc) < 1.0 || fabs(pbd_SEGRES->Sa) < 1.0)
    {
      d_MtRapportLDF = 0;
    }
    else
    {
      d_MtRapportLDF = fabs(pbd_SEGRES->Sc + d_IBNR2Incurred) > 1 ? pbd_SEGRES->Sc / (pbd_SEGRES->Sc + d_IBNR2Incurred) : 0.0;

      //d_MtRapportS = pbd_SEGRES->Sc / pbd_SEGRES->Sa;

      if (d_MtRapportLDF < 0 || d_MtRapportLDF > 1)
      {
        sprintf(ct_Erreur, "Abnormal ldf value (= %lf ) for SEG %s, UWY %d, Segment Currency %s, SSD %s.",
                d_MtRapportLDF, pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF, Kptsz_PERICASE[PER_SSD_CF]);
        n_WriteAno(ct_Erreur);
      }
    }
    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F')
      {
        // JR 08/11/2004 	if (pbd_SEGRES->PAa == 0) {      remplace par
        if (fabs(pbd_SEGRES->PAa) < 1)
        {
          d_MtRapportP = 0;
          sprintf(ct_Erreur, "SEG %s, UWY %d, Segment Currency %s, SSD %c%c : PAa=0",
                  pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF,
                  Kptsz_PERIMASTER[CASEACT_CTR_NF][0], Kptsz_PERIMASTER[CASEACT_CTR_NF][1]);
          n_WriteAno(ct_Erreur);
          s_Erreur = 1;
        }
        else
        {
          d_MtRapportP = tbd_CASEX[n_NoCASEX].PAa / pbd_SEGRES->PAa;
        }
        if (fabs(pbd_SEGRES->Sc) < 1)
        {
          d_MtRapportSi = 0;
          s_Erreur = 1;
        }
        else
        {
          d_MtRapportSi = (fabs(pbd_SEGRES->Sc) > 1) ? tbd_CASEX[n_NoCASEX].IncurredPos / pbd_SEGRES->Sc : 0.0;
        }
        // [029] tbd_CASEX[n_NoCASEX].Sa =  tbd_CASEX[n_NoCASEX].Scc +
        //                          tbd_CASEX[n_NoCASEX].Scca + d_IBNR2Incurred * ((1 - d_MtRapportS) * d_MtRapportP + d_MtRapportS * d_MtRapportSi);  // [022]

        tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].IncurredPos + d_IBNR2Incurred * ((1 - d_MtRapportLDF) * d_MtRapportP + d_MtRapportLDF * d_MtRapportSi);  // [022] [029]

        d_CTRsegmentSA += tbd_CASEX[n_NoCASEX].Sa;

      }
/*if (strcmp(tbd_CASEX[n_NoCASEX].SEG_NF, "MPSCC   02") == 0 && (tbd_CASEX[n_NoCASEX].UWY_NF == 2018 || tbd_CASEX[n_NoCASEX].UWY_NF == 2019))
{
	printf("ici 100Apres Calcul nsinis_Actu~%s~%d~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf\n",
          tbd_CASEX[n_NoCASEX].CTR_NF, pbd_SEG->UWY_NF, tbd_CASEX[n_NoCASEX].Sa, tbd_CASEX[n_NoCASEX].IncurredPos, d_IBNR2Incurred, d_MtRapportLDF, d_MtRapportP, d_MtRapportSi, 
          tbd_CASEX[n_NoCASEX].PAa, tbd_CASEX[n_NoCASEX].Scca, tbd_CASEX[n_NoCASEX].Sci, pbd_SEGRES->Sa, pbd_SEGRES->Sc, d_IncurredPosition);
}*/
    }
    n_IBNRActu(n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR);
  }

  /********************/
  /* Cas facultatives */
  /********************/

  else if (CTRNAT_CT == 'F')
  {

    /* Recopie du vecteur des donnees du segment desquelles seront soustraites les
		   donnees des lignes forcees */

    pbd_SEGRES->PA = pbd_SEG->PA;
    pbd_SEGRES->Sa = pbd_SEG->Sa;
    //pbd_SEGRES->Sc = pbd_SEG->Sc;
    pbd_SEGRES->Sc = d_IncurredPosition;    

    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion == 'F')
      {
        pbd_SEGRES->PA = pbd_SEGRES->PA - tbd_CASEX[n_NoCASEX].PA;
        pbd_SEGRES->Sa = pbd_SEGRES->Sa - tbd_CASEX[n_NoCASEX].Sa;
//        pbd_SEGRES->Sc = pbd_SEGRES->Sc - d_IncurredPosition;
        pbd_SEGRES->Sc = pbd_SEGRES->Sc - tbd_CASEX[n_NoCASEX].IncurredPos; // [029]
      }
    }

    d_IBNR2Incurred = pbd_SEGRES->Sa - pbd_SEGRES->Sc; // Sa - Sc

    /* Calcul de Sc/Ss qui ne depend que du vecteur des donnees du segment */

    // JR 08/11/2004    if ((pbd_SEGRES->Sa == 0) || (pbd_SEGRES->Sc == 0)) {      remplace par
    if ((fabs(pbd_SEGRES->Sa) < 1) || (fabs(pbd_SEGRES->Sc) < 1))
    {
      d_MtRapportLDF = 0;
    }
    else
    {
      d_MtRapportLDF = pbd_SEGRES->Sc / pbd_SEGRES->Sa;
      if (d_MtRapportLDF < 0 || d_MtRapportLDF > 1)
      {
        sprintf(ct_Erreur, "Abnormal ldf value ( = %lf ) for SEG %s, UWY %d, Segment Currency %s, SSD %s .",
                d_MtRapportLDF, pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF, Kptsz_PERICASE[PER_SSD_CF]);
        n_WriteAno(ct_Erreur);
      }
    }
    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      if (tbd_CASEX[n_NoCASEX].ModeGestion != 'F')
      {
        if (fabs(pbd_SEGRES->PA) < 1)
        {
          d_MtRapportP = 0;
          sprintf(ct_Erreur, "SEG %s, UWY %d, Segment Currency %s, SSD %c%c : PA=0",
                  pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF,
                  Kptsz_PERIMASTER[CASEACT_CTR_NF][0], Kptsz_PERIMASTER[CASEACT_CTR_NF][1]);
          n_WriteAno(ct_Erreur);
          s_Erreur = 1;
        }
        else
        {
          d_MtRapportP = tbd_CASEX[n_NoCASEX].PA / pbd_SEGRES->PA;
        }
        // JR 08/11/2004 	if (pbd_SEGRES->Sc == 0) {           remplace par
        if (fabs(pbd_SEGRES->Sc) < 1)
        {
          d_MtRapportSi = 0;
          s_Erreur = 1;
        }
        else
        {
//          d_MtRapportSi = (tbd_CASEX[n_NoCASEX].Scc + tbd_CASEX[n_NoCASEX].Scca) / pbd_SEGRES->Sc;  // [029] [030]
          d_MtRapportSi = (fabs(pbd_SEGRES->Sc) > 1) ? tbd_CASEX[n_NoCASEX].IncurredPos / pbd_SEGRES->Sc : 0.0;
        }
        tbd_CASEX[n_NoCASEX].Sa = tbd_CASEX[n_NoCASEX].IncurredPos + (pbd_SEGRES->Sa - pbd_SEGRES->Sc) * ((1 - d_MtRapportLDF) * d_MtRapportP + d_MtRapportLDF * d_MtRapportSi);  // [029]
        d_CTRsegmentSA += tbd_CASEX[n_NoCASEX].Sa;
      }
    }
/*if (strcmp(tbd_CASEX[n_NoCASEX].SEG_NF, "MFSCREU 01") == 0 && (tbd_CASEX[n_NoCASEX].UWY_NF == 2018 || tbd_CASEX[n_NoCASEX].UWY_NF == 2019))
{
	printf("ici 100Apres Calcul nsinis_Actu~%s~%d~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf~%-.3lf\n",
          tbd_CASEX[n_NoCASEX].CTR_NF, pbd_SEG->UWY_NF, tbd_CASEX[n_NoCASEX].Sa, tbd_CASEX[n_NoCASEX].IncurredPos, d_IBNR2Incurred, d_MtRapportLDF, d_MtRapportP, d_MtRapportSi, 
          tbd_CASEX[n_NoCASEX].PA, tbd_CASEX[n_NoCASEX].Scca, tbd_CASEX[n_NoCASEX].Sci, pbd_SEGRES->Sa, pbd_SEGRES->Sc, d_IncurredPosition);
}*/

    if (n_NbreEXER)
    {
      if (n_IBNRActu(n_NbreEXER, n_NbreCASEX, pbd_SEG, tbd_EXER, tbd_CASEX, tbd_IBNR))
      {
        s_Erreur = 1;
      }
    }
  }

  //somme(tbd_CASEX[n_NoCASEX].Sa) pour chaque segment à comparer (segment->Sa - segment->Sc) , si égal OK
  //, quand Ss segment est < 1, le calcul des IBNR est différent. Donc c'est normal
  if (fabs(d_CTRsegmentSA - (pbd_SEGRES->Sa - pbd_SEGRES->Sc) > 1) && pbd_SEG->Ss >= 1)
  {
    sprintf(Ksz_MessageErr, "SEG: %s	UWY: %d	CUR: %s	CTRNAT_CT: %c	SUM CTR: %.3lf	SEG:	%.3lf	Diff: %.3lf",
            pbd_SEG->SEG_NF, pbd_SEG->UWY_NF, pbd_SEG->EGPCUR_CF, CTRNAT_CT, d_CTRsegmentSA, pbd_SEGRES->Sa - pbd_SEGRES->Sc, fabs(d_CTRsegmentSA - (pbd_SEGRES->Sa - pbd_SEGRES->Sc)));
    n_WriteAno(Ksz_MessageErr);
  }

  free(pbd_SEGRES);

  RETURN_VAL(s_Erreur);
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

int n_IBNRActu(int n_NbreEXER, int n_NbreCASEX, T_SEG *pbd_SEG, T_EXER tbd_EXER[], T_CASEX tbd_CASEX[], T_IBNR tbd_IBNR[])
{
  int n_NoEXER;       /* Compteur du tableau des donnees des contrats */
  int n_NoCASEX;      /* Compteur du tableau des donnees des contrats */
  double d_SIBNR = 0; /* Somme des IBNR par exercice de survenanca pour le
	                          segment */
  short s_Erreur = 0; /* Variable d'erreur */

  DEBUT_FCT("n_IBNRActu");

  for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++)
  {
    tbd_EXER[n_NoEXER].IBNR = pbd_SEG->Sa * tbd_EXER[n_NoEXER].SPIRAT_R - d_IncurredPosition;
    d_SIBNR = d_SIBNR + tbd_EXER[n_NoEXER].IBNR;
  }

  if (d_SIBNR == 0)
  {
    /*sprintf (ct_Erreur, "SEG %s, UWY %d : IBNR=0", pbd_SEG->SEG_NF, pbd_SEG->UWY_NF);
		n_WriteAno (ct_Erreur);*/
    s_Erreur = 1; /* Variable d'erreur */
  }
  else
  {
    for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++)
    {
      tbd_EXER[n_NoEXER].PIBNR = tbd_EXER[n_NoEXER].IBNR / d_SIBNR;
    }
    for (n_NoCASEX = 0; n_NoCASEX < n_NbreCASEX; n_NoCASEX++)
    {
      for (n_NoEXER = 0; n_NoEXER < n_NbreEXER; n_NoEXER++)
      {
        tbd_IBNR[n_NoCASEX * n_NbreEXER + n_NoEXER].IBNR = (tbd_CASEX[n_NoCASEX].Sa - d_IncurredPosition) * tbd_EXER[n_NoEXER].PIBNR;
      }
    }
  }
  RETURN_VAL(s_Erreur);
}


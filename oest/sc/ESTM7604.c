/*==============================================================================
Nom de l'application          : Injection du code etablissement dans le GT
Nom du source                 : ESTM7604.c
Revision                      : $Revision: 1.1.1.1 $
Date de creation              : 18/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Injection du poste etablissement dans le GT par le perimetre.
   Le GT et le fichier PERICASE sont tries par contrat/avenant/section/
   exercice/numero d'ordre.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   12/02/03       J. Ribot    gestion colonne retintamt_m
     10/07/03       J. Ribot    modification etat anomalie sortie etat dans un fichier O2
                                 pour envoi sur intranet
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[04] 28/11/2012 R. Cassis :spot:24041 - Solvency - suppression du troncage de la sortie apres RETINTAMT_M
[05]  20/01/2013 P. Pezout :spot:24698 ajout de la fonction is_TRT pour distinguer les natures P et F
[06}  20/11/2014 Florent :spot:27747 corrections des warnings
[07}  05/06/2015 Florent :spot:26391 Maj cas ActionLigne du GT: gestion du cas ou exercice absent du périmètre
[08]  27/07/2015 M.MECHRI :spot  : correction de fichier DLEIGTAA est vide.
[09]  18/09/2015 S.BEHAGUE:spot29105: Inversion Père/Fils
[10]  07/02/2024 JYP:spira 111095 : bugfix when CSUOE is missing into PERICASE
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTM7604_C[151] = "__version__: ESTM7604.c version [010] 07/02/2024 bugfix CSUOE not in PERICASE " ;


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE	        *Kp_OutputFileGT;       /* Pointeur sur le fichier GT en sortie */
FILE            *Kp_OutputFileOUTANOS;
FILE	        *Kp_OutputFileGT3;      /* Pointeur sur le fichier GT en sortie O3 */
T_RUPTURE_VAR   *pbd_RupturePer;        /* Pointeur sur la structure du GT */
T_RUPTURE_SYNC_VAR *pbd_SyncGT;         /* Pointeur sur la structure de */
                                        /* synchronisation avec le fichier perimetre */
char Ksz_ACCESB_CF[3];  /* Code etablissement */
char Ksz_CED_NF[20]; 	/*  Cedante */
short Ks_Anomalie;      /* Vaut 1 si l'affaire est absente du perimetre, */
                        /* 0 autrement */
char Ksz_CTR_NF[10]="00T000CTR"; 	/*  Contrat */
char Ksz_ACCESB_CF_PREV[3]="";  /* Code etablissement */
char Ksz_CED_NF_PREV[20]=""; 	/*  Cedante */
char Ksz_CTR_NF_PREV[10]="00T000CTR"; 	/*  Contrat */
char sz_message[150];

/*  etat jr   090703   */

int  Kn_lignes, Kn_Page, Kn_Page1;
char Ksz_titre[41] ="Internal exchange receipt errors report.";
char Ksz_shell[11] ="ESID2050  ";

char Ksz_date[9],Ksz_DJ[11];


#define Kn_MaxLignes 30

/*-------------------------------------*/
/* Fonctions du fichier PERIMETRE PERE */
/*-------------------------------------*/
int n_InitRupturePer	 (T_RUPTURE_VAR  *pbd_RupturePer);
int n_TestRupturePer	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupturePer(char *ptsz_LigneCour[]);

void EnTete();

/*--------------------------------------------------------*/
/* Fonctions de la synchronisation entre FGT et FPERICASE */
/*--------------------------------------------------------*/
int n_InitSyncGT	 (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ConditionSyncGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionLigneSyncGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPerePer(char **ptsz_LigneEsclave);


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

int main(int argc, char *argv[])
{

  int n_annee,n_mois,n_jour;

   pbd_RupturePer=malloc(sizeof(T_RUPTURE_VAR));
   pbd_SyncGT=malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
  }
 

  sprintf(sz_message,"\nRunning with %s\n", VERSION_ESTM7604_C);
  printf(sz_message);
		
 /*Mise en forme de la date selon la langue*/
  strcpy(Ksz_date,psz_GetCharArgv(1));
  sscanf(Ksz_date,"%4d%2d%2d",&n_annee,&n_mois,&n_jour);
  sprintf(Ksz_DJ,"%02d/%02d/%04d",n_mois,n_jour,n_annee);  /* edition americaine */
/*  sprintf(Ksz_DJ[4],"%02d/%02d/%04d",n_jour,n_mois,n_annee);  si edition francaise */

/*    etat jr   090703   */

  Kn_Page = 1;
  Kn_Page1 = 1;
  Kn_lignes = 1;


/* Ouverture du fichier de sortie GT */
   if (n_OpenFileAppl("ESTM7604_O1", "wt", &Kp_OutputFileGT) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

  /* Ouverture du fichiers ANOS en sortie */
  if (n_OpenFileAppl("ESTM7604_O2", "wt", &Kp_OutputFileOUTANOS) == ERR)  {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

   if (n_OpenFileAppl("ESTM7604_O3", "wt", &Kp_OutputFileGT3) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl O3");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupturePer(pbd_RupturePer) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupturePer");
   }

/* Initialisation de la structure de synchronisation avec le perimetre */
   if (n_InitSyncGT(pbd_SyncGT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_RupturePer) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM7604_I2", &(pbd_RupturePer->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7604_I1", &(pbd_SyncGT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7604_O1", &Kp_OutputFileGT) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7604_O2", &Kp_OutputFileOUTANOS) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM7604_O3", &Kp_OutputFileGT3) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl O3");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_RupturePer);
   free(pbd_SyncGT);

   exit(OK);
}


/******************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***                                                            ***/
/*** Nom : n_InitRupturePer                                     ***/
/***									                        ***/
/*** Parametres:							                    ***/
/***	i pbd_Rupture : pointeur sur la structure de rupture	***/
/***									                        ***/
/*** Retour:								                    ***/
/***	OK si pas d'erreur,						                ***/
/***	ERR si erreur.							                ***/
/******************************************************************/

int n_InitRupturePer(T_RUPTURE_VAR *pbd_Rupture)
{
   DEBUT_FCT("n_InitRupturePer");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTM7604_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) 
   {
      RETURN_VAL(ERR);
   }
   
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupturePer;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupturePer;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation de FGT avec FPERICASE	***/
/***									***/
/*** Nom : n_InitSyncGT     					***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncGT(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
   DEBUT_FCT("n_InitSyncGT");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM7604_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSyncGT;
   pbd_Sync->n_ActionLigne=n_ActionLigneSyncGT;
   pbd_Sync->n_FilsSansPere=n_ActionFilsSansPerePer;
   pbd_Sync->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				                ***/
/***									                                ***/
/*** Nom : n_TestRupturePer     						                ***/
/***									                                ***/
/*** Parametres:							                            ***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		        ***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		        ***/
/***									                                ***/
/*** Retour:								                            ***/
/***	0 si pas de rupture,						                    ***/
/***	1 si rupture.							                        ***/
/**************************************************************************/

int n_TestRupturePer( char *ptsz_LigneSuiv[], char *ptsz_LigneCour[] )
{
   static short s_ret;

   DEBUT_FCT("n_TestRupturePer");

   if ( (s_ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])) ) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						                        ***/
/***									                                ***/
/*** Nom : n_ActionPremiereRupturePer					                ***/
/***									                                ***/
/*** Parametres:							                            ***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		        ***/
/***									                                ***/
/*** Retour:								                            ***/
/***	OK si pas d'erreur,						                        ***/
/***	ERR si erreur.							                        ***/
/**************************************************************************/

int n_ActionPremiereRupturePer(char *ptsz_LigneCour[])
{
    DEBUT_FCT("n_ActionPremiereRupturePer");

    /* On fait la synchro avec le fichier perimetre (Pere) avec toutes les lignes du fichier FGT */
    /* correspondant a une nouvelle affaire */
    /* Sauvegarde des informations etablissement et cédante pour l'exercice */
    strcpy(Ksz_ACCESB_CF, ptsz_LigneCour[PER_ACCESB_CF]);
    strcpy(Ksz_CED_NF, ptsz_LigneCour[PER_CED_NF]);

    n_ProcessingRuptureSyncVar(pbd_SyncGT, ptsz_LigneCour);

    RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation de FGT avec FPERICASE			            ***/
/***									                                ***/
/*** Nom : n_ConditionSyncGT				                        	***/
/***									                                ***/
/*** Parametres:							                            ***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		    ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	    ***/
/***									                                ***/
/*** Retour:								                            ***/
/***	0 si synchronise,						                        ***/
/***	<0 si la ligne esclave est depassee,				            ***/
/***    >0 si la ligne esclave n'est pas depassee.			            ***/
/**************************************************************************/

int n_ConditionSyncGT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSyncGT");

   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[GT_END_NT])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) ) {
      return s_ret;
   }
   if ( (s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) ) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier perimetre	    ***/
/***									                                ***/
/*** Nom : n_ActionLigneSyncGT					                        ***/
/***									                                ***/
/*** Parametres:                            							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		    ***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***							                                		***/
/*** Retour:								                            ***/
/***	OK si pas d'erreur,						                        ***/
/***	ERR si erreur.							                        ***/
/**************************************************************************/

int n_ActionLigneSyncGT( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
   DEBUT_FCT("-->n_ActionLigneSyncGT");
 
   strcpy(Ksz_CTR_NF_PREV, ptsz_LigneEsclave[GT_CTR_NF] ); 
   strcpy(Ksz_ACCESB_CF_PREV, Ksz_ACCESB_CF );
   strcpy(Ksz_CED_NF_PREV, Ksz_CED_NF);	
   strcpy(Ksz_CTR_NF, ptsz_LigneEsclave[GT_CTR_NF]);
   
   ptsz_LigneEsclave[GT_ESB_CF] = Ksz_ACCESB_CF;
   ptsz_LigneEsclave[GT_CED_NF] = Ksz_CED_NF;
   // SI synchro, on écrit dans le fichier de sortie O1
   n_WriteCols(Kp_OutputFileGT, ptsz_LigneEsclave, '~', 0);
               
   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier perimetre ne ***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									                                ***/
/*** Nom : n_ActionFilsSansPerePer					                    ***/
/***									                                ***/
/*** Parametres:							                            ***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		    ***/
/***									                                ***/
/*** Retour:								                            ***/
/***	OK si pas d'erreur,						                        ***/
/***	ERR si erreur.							                        ***/
/**************************************************************************/
int n_ActionFilsSansPerePer(char *ptsz_LigneEsclave[])
{
 
    if ( strcmp(Ksz_CTR_NF_PREV, ptsz_LigneEsclave[GT_CTR_NF]) != 0 ) 
    {	
        // On écrit dans le fichier anomalie O2.
        n_WriteCols(Kp_OutputFileGT3, ptsz_LigneEsclave, '~', 0);
        n_WriteCols(Kp_OutputFileOUTANOS, ptsz_LigneEsclave, '~', 0);
    }
    else 
    {
        // Si le contrat existe dans le périmètre on écrit la ligne avec les infos de l'exercice précédent.
        ptsz_LigneEsclave[GT_ESB_CF] = Ksz_ACCESB_CF_PREV; 
        ptsz_LigneEsclave[GT_CED_NF] = Ksz_CED_NF_PREV;
        n_WriteCols(Kp_OutputFileGT, ptsz_LigneEsclave, '~', 0);
    }

    RETURN_VAL(OK);
}

/*==============================================================================
  objet:
        Edition de l'en-tete
==============================================================================*/
void EnTete()
{
  if (Kn_Page1 == 1)
    Kn_Page1 = 0;
  else
    PageBreak(Kp_OutputFileOUTANOS);


  fprintf(Kp_OutputFileOUTANOS,"   %s  %40.40s %10.10s %d\n",
                                    Ksz_shell, Ksz_titre, Ksz_DJ, Kn_Page);

  Kn_Page++;
  Kn_lignes = 1;
}

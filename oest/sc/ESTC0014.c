/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC0014.c
 Revision                      : $Revision:   1.0  $
 Date de creation              : 11/01/2001
 Auteur                        : S.LLORENTE
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Obtention des diff entre les resultats des inventaires Retro par retrocessionnaires internes et les resultats par contrat acceptation en lien avec
ces retrocessionnaires

------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC0014.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
double Kf_SumAMT_M;
double Kf_SumRETAMT_M;
int Kn_Emetteur;


/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitDIFGTRGTA(&Kbd_ruptDIFGTRGTA)) ExitPgm(ERR_XX, "");
 
  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC0014_O1", "wt", &Kp_OutputFileDiffGTAGTR	) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptDIFGTRGTA) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC0014_I1", &(Kbd_ruptDIFGTRGTA.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC0014_O1", &Kp_OutputFileDiffGTAGTR	)) ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitDIFGTRGTA(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof( T_RUPTURE_VAR ));

  if (n_OpenFileAppl("ESTC0014_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1DIFGTRGTA;
  pbd_Rupt->n_ActionLast[0] = n_ActionL1DIFGTRGTA;
  pbd_Rupt->n_ActionFirst[0] = n_ActionF1DIFGTRGTA;
  pbd_Rupt->n_ActionLigne = n_ActionLigneDIFGTRGTA;
  pbd_Rupt->c_Separ = '~';


  return OK;
}


/*==============================================================================
 Objet :
   Fonction de test de synchronisation avec la Maitre

 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave

 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_IsR1DIFGTRGTA(char **pbd_InRec, char **pbd_InRec_Cur)
{
  int ret;
  
  if ((ret = strcmp(pbd_InRec[DIF_SSD_CF], pbd_InRec_Cur[DIF_SSD_CF])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_CTR_NF], pbd_InRec_Cur[DIF_CTR_NF])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_END_NT], pbd_InRec_Cur[DIF_END_NT])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_SEC_NF], pbd_InRec_Cur[DIF_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_UWY_NF], pbd_InRec_Cur[DIF_UWY_NF])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_UW_NT], pbd_InRec_Cur[DIF_UW_NT])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_ACMTRS_NT], pbd_InRec_Cur[DIF_ACMTRS_NT])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_CUR_CF], pbd_InRec_Cur[DIF_CUR_CF])) != 0) return(ret);
  if ((ret = strcmp(pbd_InRec[DIF_TYPMNT_CT], pbd_InRec_Cur[DIF_TYPMNT_CT])) != 0) return(ret);
 
  return 0;
}


/*==============================================================================
 Objet :
   Fonction lancee en rupture premiere de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionF1DIFGTRGTA(char **pbd_InRec_Cur)
{

/* initialisation des cumuls et de l'emetteur */
  Kf_SumAMT_M =0;
  Kf_SumRETAMT_M =0;
  Kn_Emetteur = 0;
  
  return OK;
}



/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneDIFGTRGTA(char **ptb_InRec_Cur)
{
/* cumul des montants */
   Kf_SumAMT_M = Kf_SumAMT_M + atof(ptb_InRec_Cur[DIF_AMT_M]);
   Kf_SumRETAMT_M = Kf_SumRETAMT_M + atof(ptb_InRec_Cur[DIF_RETAMT_M]);
   
/* sauvegarde de l'emetteur */
if ( atoi(ptb_InRec_Cur[DIF_SSDS_CF]) != 0 )
	Kn_Emetteur = atoi(ptb_InRec_Cur[DIF_SSDS_CF]);

  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee en rupture premiere de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionL1DIFGTRGTA(char **pbd_InRec_Cur)
{
  char sz_Emetteur[6];
  
  if ( Kn_Emetteur != 0)
  	sprintf(sz_Emetteur, "%d", Kn_Emetteur);
  else
  	sz_Emetteur[0]='\0';
  
  if (abs(Kf_SumAMT_M+Kf_SumRETAMT_M) > 10 )
    fprintf(Kp_OutputFileDiffGTAGTR, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~%.3lf~%s~~\n",
               pbd_InRec_Cur[DIF_SSD_CF],
               pbd_InRec_Cur[DIF_CTR_NF],
               pbd_InRec_Cur[DIF_END_NT],
               pbd_InRec_Cur[DIF_SEC_NF],
               pbd_InRec_Cur[DIF_UWY_NF],
               pbd_InRec_Cur[DIF_UW_NT],
               pbd_InRec_Cur[DIF_ACMTRS_NT],
               pbd_InRec_Cur[DIF_TYPMNT_CT],
               pbd_InRec_Cur[DIF_CUR_CF],
               Kf_SumRETAMT_M,
               Kf_SumAMT_M,
               sz_Emetteur
            );
  return OK;
}

/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC0013.c
 Revision                      : $Revision: 1.2 $
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
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
       ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC0013.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/


int n_InitGTAOUTIO(T_RUPTURE_SYNC_VAR  *pbd_Rupt);



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
  if (n_InitGTROUTIO(&Kbd_ruptGTROUTIO)) ExitPgm(ERR_XX, "");
  if (n_InitGTAOUTIO(&Kbd_ruptGTAOUTIO)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC0013_O1", "wt", &Kp_OutputFileDiffGTAGTR	) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptGTROUTIO) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC0013_I1", &(Kbd_ruptGTROUTIO.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC0013_I2", &(Kbd_ruptGTAOUTIO.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC0013_O1", &Kp_OutputFileDiffGTAGTR	)) ExitPgm(ERR_XX, "");

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
int n_InitGTROUTIO(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof( T_RUPTURE_VAR ));

  if (n_OpenFileAppl("ESTC0013_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTROUTIO;
  pbd_Rupt->c_Separ = '~';

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
int n_ActionLigneGTROUTIO(char **ptb_InRec_Cur)
{
  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptGTAOUTIO, ptb_InRec_Cur);

  return OK;
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de synchronisation (Esclave)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_SYNC_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitGTAOUTIO(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC0013_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGTAOUTIO;
  pbd_Rupt->n_FilsSansPere = n_ActionFsPGTAOUTIO;
  pbd_Rupt->n_PereSansFils = n_ActionPsFGTAOUTIO;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncGTAOUTIO;
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
int n_ConditionSyncGTAOUTIO(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  if ((ret = strcmp(ptb_InRecOwner[CLEDR_CTR_NF], ptb_InRecChild[CLEDA_CTR_NF])) != 0) return(ret);
   if ((ret = strcmp(ptb_InRecOwner[CLEDR_SSD_CF], ptb_InRecChild[CLEDA_SSD_CF])) != 0) return(ret);

  if ((ret = strcmp(ptb_InRecOwner[CLEDR_END_NT], ptb_InRecChild[CLEDA_END_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_SEC_NF], ptb_InRecChild[CLEDA_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_UWY_NF], ptb_InRecChild[CLEDA_UWY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_UW_NT], ptb_InRecChild[CLEDA_UW_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_ACMTRS_NT], ptb_InRecChild[CLEDA_ACMTRS_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_CUR_CF], ptb_InRecChild[CLEDA_CUR_CF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CLEDR_TYPMNT_CT], ptb_InRecChild[CLEDA_TYPMNT_CT])) != 0) return(ret);

  return 0;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne synchronisee avec le Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncGTAOUTIO(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  double delta;

  delta = abs(atof(ptb_InRecOwner[CLEDR_AMT_M]) + atof(ptb_InRecChild[CLEDA_AMT_M]));

  if (delta>10)
  {
    fprintf(Kp_OutputFileDiffGTAGTR, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~\n",
               ptb_InRecOwner[CLEDR_SSD_CF_R],
               ptb_InRecOwner[CLEDR_CTR_NF],
               ptb_InRecOwner[CLEDR_END_NT],
               ptb_InRecOwner[CLEDR_SEC_NF],
               ptb_InRecOwner[CLEDR_UWY_NF],
               ptb_InRecOwner[CLEDR_UW_NT],
               ptb_InRecOwner[CLEDR_ACMTRS_NT],
               ptb_InRecOwner[CLEDR_TYPMNT_CT],
               ptb_InRecOwner[CLEDR_CUR_CF],
               ptb_InRecOwner[CLEDR_AMT_M],
               ptb_InRecChild[CLEDA_AMT_M],
               ptb_InRecOwner[CLEDR_SSD_CF]
            );
  }

  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du pere non synchronisee avec le fils

 Parametre(s) :
   Pointeur sur la ligne courante (Maitre)

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionPsFGTAOUTIO(char **ptb_InRecOwner)
{
	if ( atof(ptb_InRecOwner[CLEDR_AMT_M]) != 0)
    fprintf(Kp_OutputFileDiffGTAGTR, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~~\n",
               ptb_InRecOwner[CLEDR_SSD_CF_R],
               ptb_InRecOwner[CLEDR_CTR_NF],
               ptb_InRecOwner[CLEDR_END_NT],
               ptb_InRecOwner[CLEDR_SEC_NF],
               ptb_InRecOwner[CLEDR_UWY_NF],
               ptb_InRecOwner[CLEDR_UW_NT],
               ptb_InRecOwner[CLEDR_ACMTRS_NT],
               ptb_InRecOwner[CLEDR_TYPMNT_CT],
               ptb_InRecOwner[CLEDR_CUR_CF],
               ptb_InRecOwner[CLEDR_AMT_M],
               ptb_InRecOwner[CLEDR_SSD_CF]
            );
  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du fils non synchronisee avec le pere

 Parametre(s) :
   Pointeur sur la ligne courante (Esclave)

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionFsPGTAOUTIO(char **ptb_InRecChild)
{
	if ( atof(ptb_InRecChild[CLEDA_AMT_M]) != 0)
		fprintf(Kp_OutputFileDiffGTAGTR, "%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~%s~~\n",
				   ptb_InRecChild[CLEDA_SSD_CF],
				   ptb_InRecChild[CLEDA_CTR_NF],
				   ptb_InRecChild[CLEDA_END_NT],
				   ptb_InRecChild[CLEDA_SEC_NF],
				   ptb_InRecChild[CLEDA_UWY_NF],
				   ptb_InRecChild[CLEDA_UW_NT],
				   ptb_InRecChild[CLEDA_ACMTRS_NT],
				   ptb_InRecChild[CLEDA_TYPMNT_CT],
				   ptb_InRecChild[CLEDA_CUR_CF],
				   ptb_InRecChild[CLEDA_AMT_M],
				   ptb_InRecChild[CLEDA_SSDS_CF]
				);

  return OK;
}



/*==============================================================================
 Nom de l'application          : OMEGA/ESTIMATION
 Nom du source                 : ESTC2329.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 03/01/2001
 Auteur                        : O.Arik
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Generation de DIFFCES

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
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

#include "ESTC2329.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/


int n_InitEST_FCESANT(T_RUPTURE_SYNC_VAR  *pbd_Rupt);


/*---------------------------------------------*/

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
  if (n_InitEST_FCES(&Kbd_ruptEST_FCES)) ExitPgm(ERR_XX, "");
  if (n_InitEST_FCESANT(&Kbd_ruptEST_FCESANT)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC2329_O1", "wt", &Kp_OutputFileDIFFCES) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptEST_FCES) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2329_I1", &(Kbd_ruptEST_FCES.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2329_I2", &(Kbd_ruptEST_FCESANT.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC2329_O1", &Kp_OutputFileDIFFCES)) ExitPgm(ERR_XX, "");

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
int n_InitEST_FCES(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2329_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneEST_FCES;
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
int n_ActionLigneEST_FCES(char **ptb_InRec_Cur)
{

  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptEST_FCESANT, ptb_InRec_Cur);

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
int n_InitEST_FCESANT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC2329_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncEST_FCESANT;
  pbd_Rupt->n_FilsSansPere = n_ActionFsPEST_FCESANT;
  pbd_Rupt->n_PereSansFils = n_ActionPsFEST_FCESANT;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncEST_FCESANT;
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
int n_ConditionSyncEST_FCESANT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  /*
  ** Modele de test de synchronisation :
  ** =================================
  **
  **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret);
  **
  */

  if ((ret = strcmp(ptb_InRecOwner[CES_CTR_NF], ptb_InRecChild[CES_CTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_END_NT], ptb_InRecChild[CES_END_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_SEC_NF], ptb_InRecChild[CES_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_UWY_NF], ptb_InRecChild[CES_UWY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_UW_NT], ptb_InRecChild[CES_UW_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_RETCTR_NF], ptb_InRecChild[CES_RETCTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_RETEND_NT], ptb_InRecChild[CES_RETEND_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_RETSEC_NF], ptb_InRecChild[CES_RETSEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_RTY_NF], ptb_InRecChild[CES_RTY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[CES_RETUW_NT], ptb_InRecChild[CES_RETUW_NT])) != 0) return(ret);

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
int n_ActionLigneSyncEST_FCESANT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int 	ret;
  double d_CESSH_R;
  char	sz_CESSH_R_Modifie[30];


  if ((ret = strcmp(ptb_InRecOwner[CES_CESSH_R], ptb_InRecChild[CES_CESSH_R])) != 0)
  {
	d_CESSH_R=atof(ptb_InRecOwner[CES_CESSH_R])-atof(ptb_InRecChild[CES_CESSH_R]);
	sprintf(sz_CESSH_R_Modifie,"%.8lf",d_CESSH_R);

	ptb_InRecOwner[CES_CESSH_R]=sz_CESSH_R_Modifie;
	n_WriteCols(Kp_OutputFileDIFFCES,ptb_InRecOwner,'~',0);
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
int n_ActionPsFEST_FCESANT(char **ptb_InRecOwner)
{
  n_WriteCols(Kp_OutputFileDIFFCES,ptb_InRecOwner,'~',0);
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
int n_ActionFsPEST_FCESANT(char **ptb_InRecChild)
{


  double d_CESSH_R;
  char	sz_CESSH_R_Modifie[30];

  d_CESSH_R=-atof(ptb_InRecChild[CES_CESSH_R]);
  sprintf(sz_CESSH_R_Modifie,"%.8lf",d_CESSH_R);

  ptb_InRecChild[CES_CESSH_R]=sz_CESSH_R_Modifie;
  n_WriteCols(Kp_OutputFileDIFFCES,ptb_InRecChild,'~',0);

  return OK;
}



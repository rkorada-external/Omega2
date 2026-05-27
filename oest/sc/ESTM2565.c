/*==============================================================================
 Nom de l'application          : OMEGA/Estimations
 Nom du source                 : ESTM2565.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 09/02/2000
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Generation de MGTAR

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


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

#include "ESTM2565.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

int n_InitMGTAR_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

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
  if (n_InitIADVPERICASE(&Kbd_ruptIADVPERICASE)) ExitPgm(ERR_XX, "");
  if (n_InitMGTAR_SORT(&Kbd_ruptMGTAR_SORT)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTM2565_O1", "wt", &Kp_OutputFileMGTAR) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptIADVPERICASE) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTM2565_I1", &(Kbd_ruptIADVPERICASE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTM2565_I2", &(Kbd_ruptMGTAR_SORT.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTM2565_O1", &Kp_OutputFileMGTAR)) ExitPgm(ERR_XX, "");

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
int n_InitIADVPERICASE(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTM2565_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneIADVPERICASE;
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
int n_ActionLigneIADVPERICASE(char **ptb_InRec_Cur)
{
  /* ... */

  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptMGTAR_SORT, ptb_InRec_Cur);

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
int n_InitMGTAR_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTM2565_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncMGTAR_SORT;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncMGTAR_SORT;

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
int n_ConditionSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  /*
  ** Modele de test de synchronisation :
  ** =================================
  **
  **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret);
  **
  */

  if ((ret = strcmp(ptb_InRecOwner[PER_CTR_NF], ptb_InRecChild[GT_CTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PER_END_NT], ptb_InRecChild[GT_END_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PER_SEC_NF], ptb_InRecChild[GT_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PER_UWY_NF], ptb_InRecChild[GT_UWY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PER_UW_NT], ptb_InRecChild[GT_UW_NT])) != 0) return(ret);

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
int n_ActionLigneSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{

 if ((   (strcmp(ptb_InRecOwner[PER_LOB_CF],"04")==0) && strcmp(ptb_InRecOwner[PER_PCPRSKTRY_CF],"FRA")==0) &&
	 ( atoi(ptb_InRecOwner[PER_SSD_CF])==2 || atoi(ptb_InRecOwner[PER_SSD_CF])==3 || atoi(ptb_InRecOwner[PER_SSD_CF])==12) )
  {
     return OK;
  }

     /* ecriture de la ligne de reconduction */
     n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);


  return OK;
}



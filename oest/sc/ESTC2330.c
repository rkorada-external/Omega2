/*==============================================================================
 Nom de l'application          : OMEGA/ESTIMATION
 Nom du source                 : ESTC2330.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 05/01/2001
 Auteur                        : O.Arik
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Rapprochement GTAR100 et GTAR100_COMPTA

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

#include "ESTC2330.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/


int n_InitGTAR100_COMPTA(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

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
  if (n_InitGTAR100(&Kbd_ruptGTAR100)) ExitPgm(ERR_XX, "");
  if (n_InitGTAR100_COMPTA(&Kbd_ruptGTAR100_COMPTA)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC2330_O1", "wt", &Kp_OutputFileRAPPROCH) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptGTAR100) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2330_I1", &(Kbd_ruptGTAR100.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2330_I2", &(Kbd_ruptGTAR100_COMPTA.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC2330_O1", &Kp_OutputFileRAPPROCH)) ExitPgm(ERR_XX, "");

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
int n_InitGTAR100(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2330_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTAR100;
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
int n_ActionLigneGTAR100(char **ptb_InRec_Cur)
{
  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptGTAR100_COMPTA, ptb_InRec_Cur);

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
int n_InitGTAR100_COMPTA(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC2330_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGTAR100_COMPTA;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncGTAR100_COMPTA;
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
int n_ConditionSyncGTAR100_COMPTA(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  /*
  ** Modele de test de synchronisation :
  ** =================================
  **
  **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret);
  **
  */

  if ((ret = strcmp(ptb_InRecOwner[GT_CTR_NF], ptb_InRecChild[GT_CTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_END_NT], ptb_InRecChild[GT_END_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_SEC_NF], ptb_InRecChild[GT_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_UWY_NF], ptb_InRecChild[GT_UWY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_UW_NT], ptb_InRecChild[GT_UW_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RETCTR_NF], ptb_InRecChild[GT_RETCTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RETEND_NT], ptb_InRecChild[GT_RETEND_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RETSEC_NF], ptb_InRecChild[GT_RETSEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RTY_NF], ptb_InRecChild[GT_RTY_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RETUW_NT], ptb_InRecChild[GT_RETUW_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_TRNCOD_CF], ptb_InRecChild[GT_TRNCOD_CF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[GT_RETCUR_CF], ptb_InRecChild[GT_RETCUR_CF])) != 0) return(ret);

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
int n_ActionLigneSyncGTAR100_COMPTA(char **ptb_InRecOwner, char **ptb_InRecChild)
{

  fprintf( Kp_OutputFileRAPPROCH, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",

  	ptb_InRecOwner[GT_SSD_CF],
  	ptb_InRecOwner[GT_ESB_CF],
  	ptb_InRecOwner[GT_CTR_NF],
  	ptb_InRecOwner[GT_END_NT],
  	ptb_InRecOwner[GT_SEC_NF],
  	ptb_InRecOwner[GT_UWY_NF],
  	ptb_InRecOwner[GT_UW_NT],
  	ptb_InRecOwner[GT_RETCTR_NF],
  	ptb_InRecOwner[GT_RETEND_NT],
  	ptb_InRecOwner[GT_RETSEC_NF],
  	ptb_InRecOwner[GT_RTY_NF],
  	ptb_InRecOwner[GT_RETUW_NT],
  	ptb_InRecOwner[GT_TRNCOD_CF],
  	ptb_InRecOwner[GT_CUR_CF],
  	ptb_InRecOwner[GT_RETAMT_M],
  	ptb_InRecChild[GT_RETAMT_M]);

  return OK;
}

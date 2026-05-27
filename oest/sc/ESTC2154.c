/*==============================================================================
 Nom de l'application          : OMEGA/ESTIMATION
 Nom du source                 : ESTC2154.c
 Revision                      : $Revision: 1.1.1.1 $
 Date de creation              : 14/02/2001
 Auteur                        : O. Arik
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Filtre des SRGTE et SRGTEF avec IARVPERICASE

------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       7/3/2001     ANB		Reconduction des libérations ex = ac = bilan si synchro ou non avec périmètre
       				même si date d'effet > libellé d'inventaire
       14/3/2001    ANB		Retour arrière sur modification précédente

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    
    
TEST !!!
SRVIE18522 V10 SRV Accept Rétro  Estimations de Libération Dépôts sur AC non statistiquée à 0 au lieu de la compta constit ac précédente
réactivation du fils sans père

==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

/*
** Objet  : IADPERICASE (Maitre)
** Entree : ESTC2154_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/

T_RUPTURE_VAR Kbd_ruptIADPERICASE;
int n_InitIADPERICASE(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneIADPERICASE(char **pbd_InRec_Cur);

/*
** Objet  : SRGTE (Esclave --> IADPERICASE)
** Entree : ESTC2154_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/

T_RUPTURE_SYNC_VAR Kbd_ruptSRGTE;
int n_InitSyncSRGTE(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncSRGTE(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncSRGTE(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFsPSRGTE(char **ptb_InRecChild);

int n_InitSRGTE(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_InitSRGTEF(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

/*
** Objet  : SRGTEF (Esclave --> IADPERICASE)
** Entree : ESTC2154_I3
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/

T_RUPTURE_SYNC_VAR Kbd_ruptSRGTEF;
int n_InitSyncSRGTEF(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncSRGTEF(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncSRGTEF(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFsPSRGTEF(char **ptb_InRecChild);

/*
** Objet  : SRGTE
** Sortie : ESTC2154_O1
*/

FILE *Kp_OutputFileSRGTE;

/*
** Objet  : SRGTEF
** Sortie : ESTC2154_O2
*/

FILE *Kp_OutputFileSRGTEF;


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

/*---------------------------------------------*/
int Kn_ICLODAT;
int Kn_BLCSHTYEA_NF;

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
  Kn_ICLODAT =  n_GetIntArgv(1);
  Kn_BLCSHTYEA_NF =  n_GetIntArgv(2);

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitIADPERICASE(&Kbd_ruptIADPERICASE)) ExitPgm(ERR_XX, "");
  if (n_InitSRGTE(&Kbd_ruptSRGTE)) ExitPgm(ERR_XX, "");
  if (n_InitSRGTEF(&Kbd_ruptSRGTEF)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC2154_O1", "wt", &Kp_OutputFileSRGTE) == ERR) ExitPgm(ERR_XX ,"");
  if (n_OpenFileAppl("ESTC2154_O2", "wt", &Kp_OutputFileSRGTEF) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptIADPERICASE) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2154_I1", &(Kbd_ruptIADPERICASE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2154_I2", &(Kbd_ruptSRGTE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2154_I3", &(Kbd_ruptSRGTEF.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC2154_O1", &Kp_OutputFileSRGTE)) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2154_O2", &Kp_OutputFileSRGTEF)) ExitPgm(ERR_XX, "");

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
int n_InitIADPERICASE(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2154_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneIADPERICASE;
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
int n_ActionLigneIADPERICASE(char **ptb_InRec_Cur)
{
  /* ... */

  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptSRGTE, ptb_InRec_Cur);
  n_ProcessingRuptureSyncVar(&Kbd_ruptSRGTEF, ptb_InRec_Cur);

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
int n_InitSRGTE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC2154_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncSRGTE;
  pbd_Rupt->n_FilsSansPere = n_ActionFsPSRGTE;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncSRGTE;
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
int n_ConditionSyncSRGTE(char **ptb_InRecOwner, char **ptb_InRecChild)
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
int n_ActionLigneSyncSRGTE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  /* Reconduction si date d'effet < libelle d'inventaire demandee */
  /* Modif Anb le 7/3/01 : reconduction aussi si libération avec ex = ac = bilan */
  /* Suppresion modif précédente */
  /*if ( ( atoi ( ptb_InRecOwner[PER_SECINC_D]) <=  Kn_ICLODAT ) ||
       ( ( atoi ( ptb_InRecChild[GT_ACMTRS_NT])%10 == 4 ) &&
         ( atoi ( ptb_InRecChild[GT_UWY_NF]) == Kn_BLCSHTYEA_NF ) &&
       	 ( atoi ( ptb_InRecChild[GT_ACY_NF])== Kn_BLCSHTYEA_NF ) )
       )
  {
     n_WriteCols(Kp_OutputFileSRGTE, ptb_InRecChild,'~', 0);
  }*/
  if ( atoi ( ptb_InRecOwner[PER_SECINC_D]) <=  Kn_ICLODAT )
     {
       n_WriteCols(Kp_OutputFileSRGTE, ptb_InRecChild,'~', 0);
     }

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
int n_ActionFsPSRGTE(char **ptb_InRecChild)
{
  /* On n'a pas synchronise avec le maitre
   Si on est sur un poste de liberation, ACMTRN_NT = XXX4 et que ACY = UWY = BLCSHTYEA_NF */

  /* Suppresssion modif précédente */
  /*if (
      ( ( atoi ( ptb_InRecChild[GT_ACMTRS_NT])%10) == 4 )
       &&
       ( atoi ( ptb_InRecChild[GT_UWY_NF]) == Kn_BLCSHTYEA_NF )
       &&
       ( atoi ( ptb_InRecChild[GT_ACY_NF])== Kn_BLCSHTYEA_NF)
     )
  {
    n_WriteCols(Kp_OutputFileSRGTE, ptb_InRecChild,'~', 0);
  }*/

    n_WriteCols(Kp_OutputFileSRGTE, ptb_InRecChild,'~', 0);

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
int n_InitSRGTEF(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC2154_I3","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncSRGTEF;
  pbd_Rupt->n_FilsSansPere = n_ActionFsPSRGTEF;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncSRGTEF;
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
int n_ConditionSyncSRGTEF(char **ptb_InRecOwner, char **ptb_InRecChild)
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
int n_ActionLigneSyncSRGTEF(char **ptb_InRecOwner, char **ptb_InRecChild)
{

  /* Reconduction si date d'effet < libelle d'inventaire demandee */
  if ( atoi ( ptb_InRecOwner[PER_SECINC_D]) <=  Kn_ICLODAT )
  {
     n_WriteCols(Kp_OutputFileSRGTEF, ptb_InRecChild,'~', 0);
  }

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
int n_ActionFsPSRGTEF(char **ptb_InRecChild)
{
  /* On n'a pas synchronise avec le maitre
   Si on est sur un poste de liberation, ACMTRN_NT = XXX4 et que ACY = UWY = BLCSHTYEA_NF */
  /* Suppression modif précédente */

  /*if (
       (( atoi ( ptb_InRecChild[GT_ACMTRS_NT])%10) == 4 )
       &&
       ( atoi ( ptb_InRecChild[GT_UWY_NF]) == Kn_BLCSHTYEA_NF )
       &&
       ( atoi ( ptb_InRecChild[GT_ACY_NF])== Kn_BLCSHTYEA_NF)
     )
  {
    n_WriteCols(Kp_OutputFileSRGTEF, ptb_InRecChild,'~', 0);

  }*/

   n_WriteCols(Kp_OutputFileSRGTEF, ptb_InRecChild,'~', 0);

  return OK;
}


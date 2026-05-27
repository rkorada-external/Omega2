/*==============================================================================
 Nom de l'application          : Estimation
 Nom du source                 : ESTM7003.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 23/05/2005
 Auteur                        : M. DJELLOULI
 References des specifications : SPOT 11175
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
  Chargement des Données de TFAMCFG, TFAMCOTP, TFAMLIA dans PERICASE Etendue
  Les Données de TFAMCFG, TFAMCOTP, TFAMLIA sont contenu dans EST_FTFAMCHG chargé par BTRT..PsTFAMCHG_01

  Le Fichier PERICASE Etendue est temporaire et ne sert qu'a la Chaine ESID2000
------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    06/04/2006      MDJ       Preserver certaines Valeurs du Perimetre Initiale
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[03}  20/11/2014 Florent :spot:27747 enlevé les define du PERExtend_ et mis dans le struc.h
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/


// Fichier TFAMCHG
#define FAM_CTR_NF 0
#define FAM_UWY_NF 1
#define FAM_UW_NT 2
#define FAM_END_NT 3
#define FAM_SEC_NF 4
#define FAM_SSD_CF 5
#define FAM_COMTYP_CT 6
#define FAM_SCLCOMEXI_B 7
#define FAM_CHGCALLVL_CF 8
#define FAM_ESTCOMTYP_CT 9
#define FAM_CTBTYP_CT 10
#define FAM_SCLCTBEXI_B 11
#define FAM_CTBCALLVL_CF 12
#define FAM_ESTCBTTYP_CT 13
#define FAM_RESCOMTRFTYP_CF 14
#define FAM_RESCOMTRFDUR_N 15
#define FAM_ESTREITYP_CT 16
#define FAM_REIVAR_B 17
#define FAM_ESTPRMTYP_CT 18

T_RUPTURE_VAR Kbd_ruptTFAMCFG;

int n_InitTFAMCFG(T_RUPTURE_VAR *pbd_Rupt);

int n_ActionLigneTFAMCFG(char **pbd_InRec_Cur);


T_RUPTURE_SYNC_VAR Kbd_ruptPeriExtend;

int n_InitSyncPeriExtend(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPeriExtend(char **ptb_InRecOwner, char **ptb_InRecChild);

int n_ActionLigneSyncPeriExtend(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFsPPeriExtend(char **ptb_InRecChild);


int n_InitPeriExtend(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

/*
** Objet  : Peri
** Sortie : ESTM7003_O1
*/

FILE *Kp_OutputFilePeri;

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

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
  if (n_InitTFAMCFG(&Kbd_ruptTFAMCFG)) ExitPgm(ERR_XX, "");
  if (n_InitPeriExtend(&Kbd_ruptPeriExtend)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTM7003_O1", "wt", &Kp_OutputFilePeri) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptTFAMCFG) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTM7003_I1", &(Kbd_ruptTFAMCFG.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTM7003_I2", &(Kbd_ruptPeriExtend.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTM7003_O1", &Kp_OutputFilePeri)) ExitPgm(ERR_XX, "");

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
int n_InitTFAMCFG(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTM7003_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneTFAMCFG;
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
int n_ActionLigneTFAMCFG(char **ptb_InRec_Cur)
{
    n_ProcessingRuptureSyncVar(&Kbd_ruptPeriExtend, ptb_InRec_Cur);

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
int n_InitPeriExtend(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTM7003_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPeriExtend;
  pbd_Rupt->n_FilsSansPere = n_ActionFsPPeriExtend;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncPeriExtend;
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
int n_ConditionSyncPeriExtend(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  /*
  ** Modele de test de synchronisation :
  ** =================================
  **
  **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret);
  **
  */
    if ( ( ret = strcmp( ptb_InRecOwner[FAM_CTR_NF], ptb_InRecChild[PER_CTR_NF] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( ptb_InRecOwner[FAM_END_NT], ptb_InRecChild[PER_END_NT] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( ptb_InRecOwner[FAM_SEC_NF], ptb_InRecChild[PER_SEC_NF] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( ptb_InRecOwner[FAM_UW_NT], ptb_InRecChild[PER_UW_NT] ) ) != 0 ) return ret ;
    if ( ( ret = strcmp( ptb_InRecOwner[FAM_UWY_NF], ptb_InRecChild[PER_UWY_NF] ) ) != 0 ) return ret ;


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
int n_ActionLigneSyncPeriExtend(char **ptb_InRecOwner, char **ptb_InRecChild)
    {

// MOD001    ptb_InRecChild[PERExtend_COMTYP_CT] = ptb_InRecOwner[FAM_COMTYP_CT];
// MOD001    ptb_InRecChild[PERExtend_SCLCOMEXI_B] = ptb_InRecOwner[FAM_SCLCOMEXI_B];
    ptb_InRecChild[PERExtend_CHGCALLVL_CF] = ptb_InRecOwner[FAM_CHGCALLVL_CF];
    ptb_InRecChild[PERExtend_ESTCOMTYP_CT] = ptb_InRecOwner[FAM_ESTCOMTYP_CT];
// MOD001        ptb_InRecChild[PERExtend_CTBTYP_CT] = ptb_InRecOwner[FAM_CTBTYP_CT];
    ptb_InRecChild[PERExtend_SCLCTBEXI_B] =  ptb_InRecOwner[FAM_SCLCTBEXI_B];
// MOD001            ptb_InRecChild[PERExtend_CTBCALLVL_CF] = ptb_InRecOwner[FAM_CTBCALLVL_CF];
    ptb_InRecChild[PERExtend_ESTCBTTYP_CT] = ptb_InRecOwner[FAM_ESTCBTTYP_CT];
    ptb_InRecChild[PERExtend_RESCOMTRFTYP_CF]  = ptb_InRecOwner[FAM_RESCOMTRFTYP_CF];
    ptb_InRecChild[PERExtend_RESCOMTRFDUR_N] = ptb_InRecOwner[FAM_RESCOMTRFDUR_N];
    ptb_InRecChild[PERExtend_ESTREITYP_CT] =ptb_InRecOwner[FAM_ESTREITYP_CT];
    ptb_InRecChild[PERExtend_REIVAR_B] = ptb_InRecOwner[FAM_REIVAR_B];
    ptb_InRecChild[PERExtend_ESTPRMTYP_CT] = ptb_InRecOwner[FAM_ESTPRMTYP_CT];

    n_WriteCols(Kp_OutputFilePeri, ptb_InRecChild, '~', 0);

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
int n_ActionFsPPeriExtend(char **ptb_InRecChild)
{
  //ptb_InRecChild[GT_RETINTAMT_M]= "0.000";

// MOD001        ptb_InRecChild[PERExtend_COMTYP_CT] = "";
// MOD001        ptb_InRecChild[PERExtend_SCLCOMEXI_B] = "";
    ptb_InRecChild[PERExtend_CHGCALLVL_CF] = "";
    ptb_InRecChild[PERExtend_ESTCOMTYP_CT] = "";
// MOD001        ptb_InRecChild[PERExtend_CTBTYP_CT] = "";
    ptb_InRecChild[PERExtend_SCLCTBEXI_B] = "";
// MOD001        ptb_InRecChild[PERExtend_CTBCALLVL_CF] = "";
    ptb_InRecChild[PERExtend_ESTCBTTYP_CT] = "";
    ptb_InRecChild[PERExtend_RESCOMTRFTYP_CF]  = "";
    ptb_InRecChild[PERExtend_RESCOMTRFDUR_N] = "";
    ptb_InRecChild[PERExtend_ESTREITYP_CT] = "";
    ptb_InRecChild[PERExtend_REIVAR_B] = "";
    ptb_InRecChild[PERExtend_ESTPRMTYP_CT] = "";

  n_WriteCols(Kp_OutputFilePeri, ptb_InRecChild, '~', 0);
  return OK;
}



/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC1040.c
 Revision                      : $Revision: 1.3 $
 Date de creation              : 13/01/2003
 Auteur                        : J. RIBOT
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :     gestion des ultimes
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
#include "ESTC1040.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
int n_InitIADPERIPRMD(T_RUPTURE_SYNC_VAR  *pbd_Rupt);


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
    if (n_InitIADPERICASE(&Kbd_ruptIADPERICASE)) ExitPgm(ERR_XX, "");
    if (n_InitIADPERIPRMD(&Kbd_ruptIADPERIPRMD)) ExitPgm(ERR_XX, "");

    /* Ouverture des fichiers binaires et des fichiers de sortie */
    if (n_OpenFileAppl("ESTC1040_O1", "wt", &Kp_OutputFileFTCTRACC) == ERR) ExitPgm(ERR_XX ,"");

    /* Lancement du traitement du fichier Maitre */
    if (n_ProcessingRuptureVar(&Kbd_ruptIADPERICASE) == ERR) ExitPgm(ERR_XX, "");

    /* Fermeture des fichiers ouverts */
    if (n_CloseFileAppl("ESTC1040_I1", &(Kbd_ruptIADPERICASE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTC1040_I2", &(Kbd_ruptIADPERIPRMD.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

    if (n_CloseFileAppl("ESTC1040_O1", &Kp_OutputFileFTCTRACC)) ExitPgm(ERR_XX, "");

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

    if (n_OpenFileAppl("ESTC1040_I1","rt", &(pbd_Rupt->pf_InputFil)))
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
    /* Synchronisation du fichier maitre avec ses esclaves */
    n_ProcessingRuptureSyncVar(&Kbd_ruptIADPERIPRMD, ptb_InRec_Cur);

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
int n_InitIADPERIPRMD(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

    if (n_OpenFileAppl("ESTC1040_I2","rt", &(pbd_Rupt->pf_InputFil)))
        return ERR;

    pbd_Rupt->n_NbRupture = 0;
    pbd_Rupt->ConditionEndSync = n_ConditionSyncIADPERIPRMD;
    pbd_Rupt->n_PereSansFils = n_ActionPsFIADPERIPRMD;
    pbd_Rupt->n_ActionLigne = n_ActionLigneSyncIADPERIPRMD;
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
int n_ConditionSyncIADPERIPRMD(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

    /*
    ** Modele de test de synchronisation :
    ** =================================
    **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret); */

    if((ret = strcmp(ptb_InRecOwner[FAM_CTR_NF], ptb_InRecChild[GTA_CTR_NF]))    != 0) return(ret);
    if((ret = (atoi(ptb_InRecOwner[FAM_UWY_NF])-atoi(ptb_InRecChild[GTA_UWY_NF])))!=0) return(ret);
    if((ret = (atoi(ptb_InRecOwner[FAM_SEC_NF])-atoi(ptb_InRecChild[GTA_SEC_NF])))!=0) return(ret);
    if((ret = (atoi(ptb_InRecOwner[FAM_END_NT])-atoi(ptb_InRecChild[GTA_END_NT])))!=0) return(ret);
    if((ret = (atoi(ptb_InRecOwner[FAM_UW_NT]) -atoi(ptb_InRecChild[GTA_UW_NT]))) !=0) return(ret);

/*
if ((ret = strcmp(ptb_InRecOwner[FAM_UWY_NF], ptb_InRecChild[GTA_UWY_NF])) != 0) return(ret);
if ((ret = strcmp(ptb_InRecOwner[FAM_SEC_NF], ptb_InRecChild[GTA_SEC_NF])) != 0) return(ret);
if ((ret = strcmp(ptb_InRecOwner[FAM_END_NT], ptb_InRecChild[GTA_END_NT])) != 0) return(ret);
if ((ret = strcmp(ptb_InRecOwner[FAM_UW_NT],  ptb_InRecChild[GTA_UW_NT]))  != 0) return(ret); */

  return 0;
}


/*==============================================================================
 Objet :        Fonction lancee pour chaque ligne synchronisee avec le Maitre
 Parametre(s) : Pointeur sur la ligne courante
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncIADPERIPRMD(char **ptb_InRecOwner, char **ptb_InRecChild)
{
    if( strcmp(ptb_InRecOwner[FAM_EGPCUR_CF], ptb_InRecChild[GTA_CUR_CF]) != 0 )
    {
        fprintf(Kp_OutputFileFTCTRACC,"%s~%s~%s~%s~%s\n",
            ptb_InRecOwner[FAM_CTR_NF],
            ptb_InRecOwner[FAM_END_NT],
            ptb_InRecOwner[FAM_SEC_NF],
            ptb_InRecOwner[FAM_UW_NT],
            ptb_InRecOwner[FAM_UWY_NF]);
    }
  return OK;
}


/*==============================================================================
 Objet :        Fonction lancee pour chaque ligne du pere non synchronisee avec le fils
 Parametre(s) : Pointeur sur la ligne courante (Maitre)
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_ActionPsFIADPERIPRMD(char **ptb_InRecOwner)
{
  return OK;
}



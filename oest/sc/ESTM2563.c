/*==============================================================================
 Nom de l'application          : OMEGA/Estimations
 Nom du source                 : ESTM2563.c
 Revision                      : $Revision: 1.7 $
 Date de creation              : 09/02/2000
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :     Generation de MGTAR
------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    10/12/2007   J. Ribot    SPOT14784      ajout tests sur filiales 2 20 et 4 et etb 2
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
---------------
MODIFICATION   : [003]
Auteur         : D.GATIBELZA
Date           : 29/03/2010
Version        : 10.1
Description    : ESTDOM19222 Interface Retro Omega PeopleSoft
                 Désactivation du n_ActionFilsSansPereMGTAR
                 -> 20100423: réactivation
---------------
MODIFICATION   : [004]
Auteur         : JF VDV
Date           : 15/10/2010
Version        : 10.1
Description    : [19210] - Filtre sur les postes financiers et de depots
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTM2563.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
int n_InitMGTAR_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

/*==============================================================================
 Objet :    Point d'entree du programme
 Parametre(s) :     int argc    : Nombre d'arguments sur la ligne de commande;
                    char **argv : parametres
 Retour :           En cas de probleme, sortie par ExitPgm(ERRCODE)
                    sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
    /* Initialisation des signaux */
    InitSig () ;

    if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

    /* Initialisation des variables de gestion de ruptures */
    if (n_InitCADVPERIESB(&Kbd_ruptCADVPERIESB))                            ExitPgm(ERR_XX, "");
    if (n_InitMGTAR_SORT(&Kbd_ruptMGTAR_SORT))                              ExitPgm(ERR_XX, "");

    /* Ouverture des fichiers binaires et des fichiers de sortie */
    if (n_OpenFileAppl("ESTM2563_O1", "wt", &Kp_OutputFileMGTAR) == ERR)    ExitPgm(ERR_XX ,"");

    /* Lancement du traitement du fichier Maitre */
    if (n_ProcessingRuptureVar(&Kbd_ruptCADVPERIESB) == ERR)                ExitPgm(ERR_XX, "");

    /* Fermeture des fichiers ouverts */
    if (n_CloseFileAppl("ESTM2563_I1", &(Kbd_ruptCADVPERIESB.pf_InputFil)) == ERR)      ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTM2563_I2", &(Kbd_ruptMGTAR_SORT.pf_InputFil)) == ERR)       ExitPgm(ERR_XX, "");
    if (n_CloseFileAppl("ESTM2563_O1", &Kp_OutputFileMGTAR))                            ExitPgm(ERR_XX, "");

    if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet :        Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) : Pointeur sur une structure T_RUPTURE_VAR
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_InitCADVPERIESB(T_RUPTURE_VAR  *pbd_Rupt)
{
    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if (n_OpenFileAppl("ESTM2563_I1","rt", &(pbd_Rupt->pf_InputFil)))
        return ERR;

    pbd_Rupt->n_NbRupture = 0;
    pbd_Rupt->n_ActionLigne = n_ActionLigneCADVPERIESB;
    pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :        Fonction lancee pour chaque ligne du Maitre
 Parametre(s) : Pointeur sur la ligne courante
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_ActionLigneCADVPERIESB(char **ptb_InRec_Cur)
{
    /* Synchronisation du fichier maitre avec ses esclaves */
    n_ProcessingRuptureSyncVar(&Kbd_ruptMGTAR_SORT, ptb_InRec_Cur);

  return OK;
}


/*==============================================================================
 Objet :        Initialisation de la variable de gestion de synchronisation (Esclave)
 Parametre(s) : Pointeur sur une structure T_RUPTURE_SYNC_VAR
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_InitMGTAR_SORT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

    if (n_OpenFileAppl("ESTM2563_I2","rt", &(pbd_Rupt->pf_InputFil)))
        return ERR;

    pbd_Rupt->n_NbRupture = 0;
    pbd_Rupt->ConditionEndSync = n_ConditionSyncMGTAR_SORT;
    pbd_Rupt->n_ActionLigne    = n_ActionLigneSyncMGTAR_SORT;
    //[003]
    pbd_Rupt->n_FilsSansPere   = n_ActionFilsSansPereMGTAR;

    pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :        Fonction de test de synchronisation avec la Maitre
 Parametre(s) : Pointeur sur la ligne du maitre
                Pointeur sur la ligne de l'esclave
 Retour :       0 --> Pas de synchro
                1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

    /*
    ** Modele de test de synchronisation :
    ** =================================
    **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret); **  */

    if ((ret = strcmp(ptb_InRecOwner[PERESB_CTR_NF], ptb_InRecChild[GT_CTR_NF])) != 0) return(ret);
    if ((ret = strcmp(ptb_InRecOwner[PERESB_END_NT], ptb_InRecChild[GT_END_NT])) != 0) return(ret);
    if ((ret = strcmp(ptb_InRecOwner[PERESB_UWY_NF], ptb_InRecChild[GT_UWY_NF])) != 0) return(ret);
    if ((ret = strcmp(ptb_InRecOwner[PERESB_UW_NT], ptb_InRecChild[GT_UW_NT])) != 0) return(ret);

  return 0;
}


/*==============================================================================
 Objet :        Fonction lancee pour chaque ligne synchronisee avec le Maitre
 Parametre(s) : Pointeur sur la ligne courante
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int n_PerEsb;
  char sz_GtDbltrn[9];
  char sz_AMT_M[20];
  char sz_RETAMT_M[20];

    /* charger les variables locales */
    n_PerEsb = atoi(ptb_InRecOwner[PERESB_ACCESB_CF]);
    strcpy( sz_GtDbltrn, ptb_InRecChild[GT_DBLTRNCOD_CF] );

    /* tester etablist acceptation == (2 ou 3) */
        // [14784] - JR 10/12/2007      && strncmp(ptb_InRecChild[GT_CTR_NF],"02",2)== 0 )
        // [19210] - if ( ( n_PerEsb==2 || n_PerEsb==3)   && strcmp (ptb_InRecChild[GT_SSD_CF] , "2" ) == 0 )

// [19210] - Filtre sur les postes financiers et de depots
//           suppression du test sur etablissement 3

   if (strcmp (ptb_InRecChild[GT_SSD_CF] ,"2")== 0 && n_PerEsb==2
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '3')        //
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '6')        //
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '9')        // [19210]
                && (ptb_InRecChild[GT_TRNCOD_CF][2] != '8') )      //

    {
        /* modification du poste contrepartie */
        if ( !strcmp( sz_GtDbltrn, "22804000") )
            sprintf(ptb_InRecChild[GT_DBLTRNCOD_CF], "%s", "22805000");
        if ( !strcmp( sz_GtDbltrn, "42804000") )
            sprintf(ptb_InRecChild[GT_DBLTRNCOD_CF], "%s", "42805000");

        /* ecriture de la ligne de reconduction */
        sprintf(ptb_InRecChild[GT_ESB_CF], "%c", '9');
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);

        /* ecriture de la ligne d annulation */
        sprintf(sz_AMT_M, "%-.3lf", atof(ptb_InRecChild[GT_AMT_M])*(-1));
        sprintf(sz_RETAMT_M, "%-.3lf", atof(ptb_InRecChild[GT_RETAMT_M])*(-1));

        ptb_InRecChild[GT_AMT_M] = sz_AMT_M;
        ptb_InRecChild[GT_RETAMT_M] = sz_RETAMT_M;
        sprintf(ptb_InRecChild[GT_ESB_CF], "%c", '8');
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);
    }

    /* tester filiale 20 ou filiale 4 et etab ==2 ( ou filiale 22 et etab 2 )*/
    if ( strcmp (ptb_InRecChild[GT_SSD_CF]  ,"20")== 0                      ||      // JR 10/12/2007 SPOT14784
         ( strcmp (ptb_InRecChild[GT_SSD_CF], "4")== 0 && n_PerEsb==2 )     ||      // JR 10/12/2007 SPOT14784
         ( strcmp (ptb_InRecChild[GT_SSD_CF],"22")== 0 && ( n_PerEsb==1 || n_PerEsb==2 ) )   )       // [003]
    {
        /* ecriture de la ligne de reconduction */
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);
    }

  return OK;
}


/*==============================================================================
objet :     fonction lancee quand le pere n'a pas de fils GT
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereMGTAR(  char **ptb_InRecChild  ) /* adresse de la ligne du maitre */
{
  int n_PerEsb;
  char sz_GtDbltrn[9];
  char sz_AMT_M[20];
  char sz_RETAMT_M[20];

    /* charger les variables locales */
    n_PerEsb = atoi(ptb_InRecChild[GT_ESB_CF]);
    strcpy( sz_GtDbltrn, ptb_InRecChild[GT_DBLTRNCOD_CF] );

    /* tester etablist acceptation == (2 ou 3) */
        // [14784] - JR 10/12/2007   //  && strncmp(ptb_InRecChild[GT_CTR_NF],"02",2)== 0 )
        // [19210] - //if ( ( n_PerEsb==2 || n_PerEsb==3 ) && strcmp (ptb_InRecChild[GT_SSD_CF] , "2" ) == 0  )
        // [19210] - Filtre sur les postes financiers et de depots
        //           suppression du test sur etablissement 3

   if (strcmp (ptb_InRecChild[GT_SSD_CF] ,"2")== 0 && n_PerEsb==2
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '3')        //
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '6')        //
                && (ptb_InRecChild[GT_TRNCOD_CF][1] != '9')        // [19210]
                && (ptb_InRecChild[GT_TRNCOD_CF][2] != '8') )      //

    {
        /* modification du poste contrepartie */
        if ( !strcmp( sz_GtDbltrn, "22804000") )
            sprintf(ptb_InRecChild[GT_DBLTRNCOD_CF], "%s", "22805000");
        if ( !strcmp( sz_GtDbltrn, "42804000") )
            sprintf(ptb_InRecChild[GT_DBLTRNCOD_CF], "%s", "42805000");

        /* ecriture de la ligne de reconduction */
        sprintf(ptb_InRecChild[GT_ESB_CF], "%c", '9');
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);

        /* ecriture de la ligne d annulation */
        sprintf(sz_AMT_M, "%-.3lf", atof(ptb_InRecChild[GT_AMT_M])*(-1));
        sprintf(sz_RETAMT_M, "%-.3lf", atof(ptb_InRecChild[GT_RETAMT_M])*(-1));

        ptb_InRecChild[GT_AMT_M] = sz_AMT_M;
        ptb_InRecChild[GT_RETAMT_M] = sz_RETAMT_M;
        sprintf(ptb_InRecChild[GT_ESB_CF], "%c", '8');
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);
    }

    /* tester filiale 20 ou filiale 4 et etab ==2 */
    if ( strcmp (ptb_InRecChild[GT_SSD_CF]  ,"20")== 0                      ||      // JR 10/12/2007 SPOT14784
         ( strcmp (ptb_InRecChild[GT_SSD_CF], "4")== 0 && n_PerEsb==2 )     ||      // JR 10/12/2007 SPOT14784
         ( strcmp (ptb_InRecChild[GT_SSD_CF],"22")== 0 && ( n_PerEsb==1 || n_PerEsb==2 ) )   )       // [003]
    {
        /* ecriture de la ligne de reconduction */
        n_WriteCols(Kp_OutputFileMGTAR, ptb_InRecChild, '~', 0);
    }

  RETURN_VAL(OK);
}


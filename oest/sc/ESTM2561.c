/*==============================================================================
Nom de l'application          : transformation de TOTGTAR GT
Nom du source                 : ESTM2561.c
Revision                      :
Date de creation              : 26/10/1998
Auteur                        :
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :Transformation du GT Retrocession  pour la filiale 6.

------------------------------------------------------------------------------
Historique des modifications :
[01] 08/11/2002 O.GIRAUX  MOD01  On prend en compte en priorite l'A/C accept pour le blanchiment des estimations retrocession
                          + Rejet des postes de Pertes et profits qui ne doivent pas etre blanchis.
[02] 03/12/2003 DJELLOULI Suite à la Demande du 01/12/2003 - MOD02
                          Regle N° 1 : Ne pas Blanchir les Facs
                          Regle N° 2 : Blanchir les Postes 41/42/43/44 des contrats : 06P000094 06P000095 06P000101
                          Regle N° 3 : Ajouter une ligne d'écriture en Année de Compte N-1, pour les
                                       postes suivants, actuellement en Année de Compte N : (PNA) 1C410004 / (FAR) 1C430004 / 1C494002
                          Regle N° 4 : Blanchir tous les contrats pour EXERCICE RETRO = ANNEE de BILAN
[03] 26/12/2003 O.GIRAUX  on applique les règles 2 et 3 à tous les pools et non plus seulement aux P94, P95 et P101
[04] 08/01/2004 DJELLOULI On tient compte des contrats acceptations qui ne sont pas renseignés à blanc ou Null)
[05] 26/05/2004 J.Ribot   :spot:10395 ajout d'une sélection sur GT_SSD_CF = 4 et GT_ESB_CF = 11
[06] 27/03/2008 J. Ribot  :SPOT:15219 ASE15: recompilation des programmes C
[07] 20/07/2012 Florent  :spot:23390 empêcher la gestion des postes EBS
[08] 13/02/2013 Roger    :spot:24846 Insertion du clodat_d dans les années/mois/jour bilan
[09] 25/06/13   Prajakta    Phase1B migration code changes for warning removal
[10] 25/03/2014 Roger    :spot:25427 Gestion des filtres sur type de contrat fac ou traité
[11] 16/10/2014 sbe      : Modification et filtre poste comptable
[12] 16/11/2015 Florent  :spot:26690 correction, la modif 11 ne modifie que le TRNCOD_CF !
[13] 14/09/2016 Florent  :spot:30978 suppression test sur contrat acc et retro
[14] 06/04/2022 JYP  :spira:103649: gaap_code and product_code should be empty
[15] 12/04/2023 MiS  :spira:108544: Removing 49410 for I17
==============================================================================*/
/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE   *Kp_OutputFile;   /* Pointeur sur le fichier FGT en sortie */
FILE   *Kp_GetTrncod;    /* Pointeur sur le fichier GT-TOTGTAR*/

T_RUPTURE_VAR bd_Rupture; /* variable sur la structure du GT */
T_RUPTURE_SYNC_VAR  bd_Rupt; /*variable de gesstion de la synchro
                                    de TOTGTAR avec ordvpericase*/
extern int Ksz_Argc;

char Ksz_CLODAT_D[9];/* Date de libelle inventaire*/
char sz_Norme[5]; /* Norme [15]*/
int                Kn_Annee;                /* Annee de periode de compte
                                             (parametre de la chaine) */
/*--------------------------*/
/* Fonctions du fichier FGT */
/*--------------------------*/
int n_InitRuptperi(T_RUPTURE_VAR *pdb_Rupture);
int n_InitRuptgt(T_RUPTURE_SYNC_VAR *pdb_Rupt);
int n_ActionLignegt(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ActionLigneperi(char **pdb_InRecOwner);
int n_ConditionSyncgt(char **pdb_InRecOwner, char **pdb_InRecChild);
int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *bd_Rupt,
                               char **pdb_InRecOwner);
/***********************************************************************/
/*** Objet :                                                         ***/
/*** Parametres:                                                     ***/
/***  i argv : tableau de pointeurs sur les parametres               ***/
/*** Retour:                                                         ***/
/***  ERR si erreur.                                                 ***/
/***********************************************************************/

int main(int argc, char *argv[])
{

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
  }

  /* Recuperation du parametre correspondant a la date libelle inventaire*/
  strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));

  /* Recuperation de l'annee de compte */
  Kn_Annee = n_GetIntArgv(2);

  /* Recuperation de la Norme [15]*/
  if (Ksz_Argc == 3)
  {
    strcpy(sz_Norme, psz_GetCharArgv(3));
  }

  /* Ouverture du fichier de sortie GT-TOTGTAA */
  if (n_OpenFileAppl("ESTM2561_O1", "wt", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
  }

  /* Initialisation de la variable bd_Rupture*/

  if (n_InitRuptperi(&bd_Rupture) )
    ExitPgm(ERR_XX, "Erreur appel de la fonction n_InitRuptgtperi");

  /* Initialisation de la variable bd_Rupt*/

  if (n_InitRuptgt(&bd_Rupt) )
    ExitPgm(ERR_XX, "Erreur appel de la fonction n_InitRuptperigt");


  /* lancement du traitement du fichier maitre */
  if ( n_ProcessingRuptureVar( &bd_Rupture ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if (n_CloseFileAppl("ESTM2561_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTM2561_I2", &(bd_Rupt.pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTM2561_O1", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_EndPgm() == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  }

  exit(OK);
}


/**************************************************************************/
/***    Objet :                                                         ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitRuptperi(T_RUPTURE_VAR *bd_Rupture)
{

  DEBUT_FCT("n_InitRupgt");
  memset(bd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTM2561_I2", "rt", &(bd_Rupture->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  bd_Rupture->n_NbRupture = 0;
  bd_Rupture->n_ActionLigne = n_ActionLigneperi;
  bd_Rupture->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/***    Objet :                                                         ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_InitRuptgt(T_RUPTURE_SYNC_VAR *pdb_Rupt)
{
  DEBUT_FCT("n_InitRuptgt");
  memset(pdb_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTM2561_I1", "rt", &(pdb_Rupt->pf_InputFil)) == ERR)
  {
    RETURN_VAL(ERR);
  }
  pdb_Rupt->ConditionEndSync = n_ConditionSyncgt;
  pdb_Rupt->n_ActionLigne = n_ActionLignegt;
  pdb_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/***    Objet : test de rupture                                       ***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/
int n_ConditionSyncgt(char **pdb_InRecOwner, char **pdb_InRecChild)
{
  int ret;

  if ((ret = strcmp(pdb_InRecOwner[PER_CTR_NF],
                    pdb_InRecChild[GT_RETCTR_NF])) != 0) return ret;

  if ((ret = strcmp(pdb_InRecOwner[PER_END_NT],
                    pdb_InRecChild[GT_RETEND_NT])) != 0) return ret;

  if ((ret = strcmp(pdb_InRecOwner[PER_SEC_NF],
                    pdb_InRecChild[GT_RETSEC_NF])) != 0) return ret;

  if ((ret = strcmp(pdb_InRecOwner[PER_UWY_NF],
                    pdb_InRecChild[GT_RTY_NF])) != 0) return ret;

  if ((ret = strcmp(pdb_InRecOwner[PER_UW_NT],
                    pdb_InRecChild[GT_RETUW_NT])) != 0) return ret;
  return ( 0);
}

/************************************************************************/
/***    Objet : test de rupture                                       ***/
/***    OK si pas d'erreur,                                           ***/
/***    ERR si erreur.                                                ***/
/************************************************************************/
int n_ActionLigneperi(char **pdb_InRecOwner)
{
  n_ProcessingRuptureSyncVar(&bd_Rupt, pdb_InRecOwner);
  return OK;
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier GT-TOTAGTAA   ***/
/*** Nom : n_ActionLigne                                                ***/
/*** Parametres:                                                        ***/
/***  i pdb_InRecChild : pointeur sur la ligne courante                 ***/
/*** Retour:                                                            ***/
/***  OK si pas d'erreur,                                               ***/
/***  ERR si erreur.                                                    ***/
/**************************************************************************/
int n_ActionLignegt(char **pdb_InRecOwner, char **pdb_InRecChild)
{
  double VAR_AMT;
  double VAR_RETAMT;
  double VAR_RETINTAMT;
  char sz_tmp[30];
  char sz_tmpret[30];
  char sz_tmpretint[30];
  char sz_trncod[9];
  char sz_acy[5];
  char sz_acy_ante[5];
  char sz_scostrmth[3];
  char sz_day[3];          // [08]
  int  n_anneecompte;
  /* MOD2 - Variable pour Sauvegarde Periode (Regle N°2)*/
  char save_acy[5];
  char save_scostrmth[3];
  char save_scoendmth[3];
  /* MOD2 - Sauvegarde Poste Comptable Pour Test du Poste de la ligne d'entree */
  char save_trncod[9];
  char sz_gaap_code[11];
  char sz_prod_code[11];
  
  DEBUT_FCT("n_ActionLigne");

  /* Initialisation des parametres*/
  VAR_AMT = 0;
  VAR_RETAMT = 0;
  VAR_RETINTAMT = 0;
  memset(sz_trncod, 0, sizeof(sz_trncod));
  strcpy(sz_trncod, pdb_InRecChild[GT_TRNCOD_CF]);

  memset(save_trncod, 0, sizeof(save_trncod));
  strcpy(save_trncod, pdb_InRecChild[GT_TRNCOD_CF]);
  
  strcpy(sz_gaap_code,"");
  strcpy(sz_prod_code,"");
  
  
  /* MOD01 O.GIRAUX 08/11/02, annee de compte renseignee a partir de ACY_NF, sinon a partir de RETACY   */
  if (atoi(pdb_InRecChild[GT_ACY_NF]) != 0)
    n_anneecompte = atoi(pdb_InRecChild[GT_ACY_NF]);
  else
    n_anneecompte = atoi(pdb_InRecChild[GT_RETACY_NF]);

  /* MOD2 - Sauvegarde Periode (REgle N° 2)*/
  strcpy(save_acy, pdb_InRecChild[GT_ACY_NF]);
  strcpy(save_scostrmth, pdb_InRecChild[GT_SCOSTRMTH_NF]);
  strcpy(save_scoendmth, pdb_InRecChild[GT_SCOENDMTH_NF]);

  if (((atoi(pdb_InRecChild[GT_SSD_CF]) == 4 && atoi(pdb_InRecChild[GT_ESB_CF]) == 11 )
       || atoi(pdb_InRecChild[GT_SSD_CF]) == 6 )
      && strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "11", 2) != 0
      && strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "81", 2) != 0
      && strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "83", 2) != 0
      && strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "84", 2) != 0
      && strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90", 2) != 0 //MOD01
      && isdigit(pdb_InRecChild[GT_TRNCOD_CF][1])) //[07]
  {
    VAR_AMT = -atof(pdb_InRecChild[GT_AMT_M]);
    sprintf(sz_tmp, "%-.3lf", VAR_AMT);
    pdb_InRecChild[GT_AMT_M] = sz_tmp;

    VAR_RETAMT = -atof(pdb_InRecChild[GT_RETAMT_M]);
    sprintf(sz_tmpret, "%-.3lf", VAR_RETAMT);
    pdb_InRecChild[GT_RETAMT_M] = sz_tmpret;

    VAR_RETINTAMT = -atof(pdb_InRecChild[GT_RETINTAMT_M]);
    sprintf(sz_tmpretint, "%-.3lf", VAR_RETINTAMT);
    pdb_InRecChild[GT_RETINTAMT_M] = sz_tmpretint;

    pdb_InRecChild[GT_CLM_NF] = "";
    pdb_InRecChild[GT_OCCYEA_NF] = "";
    pdb_InRecChild[GT_DBLTRNCOD_CF] = "";

    memset(sz_acy, 0, sizeof(sz_acy));
    memset(sz_day, 0, sizeof(sz_day));                // [08]
    sprintf(sz_acy, "%.4s", Ksz_CLODAT_D);
    sprintf(sz_scostrmth, "%.2s", Ksz_CLODAT_D + 4);
    sprintf(sz_day, "%.2s", Ksz_CLODAT_D + 6);        // [08]

    pdb_InRecChild[GT_ACY_NF] = sz_acy;
    pdb_InRecChild[GT_SCOSTRMTH_NF] = sz_scostrmth;
    pdb_InRecChild[GT_SCOENDMTH_NF] = sz_scostrmth;
    pdb_InRecChild[GT_BALSHEY_NF] = sz_acy;           // [08]
    pdb_InRecChild[GT_BALSHRMTH_NF] = sz_scostrmth;   // [08]
    pdb_InRecChild[GT_BALSHRDAY_NF] = sz_day;         // [08]

    sz_trncod[1] = 'C';
    pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;

    if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "10", 2) == 0)
    {
      strncpy(sz_trncod + 2, "10000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "102", 3) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "103", 3) == 0)
    {
      strncpy(sz_trncod + 2, "10200", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "12", 2) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "15", 2) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "140", 3) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "13", 2) == 0)
    {
      strncpy(sz_trncod + 2, "12000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "141", 3) == 0)
    {
      strncpy(sz_trncod + 2, "14100", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "45", 2) == 0)
    {
      strncpy(sz_trncod + 2, "45000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "20", 2) == 0)
    {
      strncpy(sz_trncod + 2, "20000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "300", 3) == 0 )
    {
      strncpy(sz_trncod + 2, "30000", 5);             /* Modif OG 09/12/02 */
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "301", 3) == 0 )
    {
      strncpy(sz_trncod + 2, "30100", 5);             /* Modif OG 09/12/02 */
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31000", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31020", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31100", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31200", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31300", 5) == 0 ||

             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31010", 5) == 0 ||    /* Modif OG 09/12/02 */
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31030", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31110", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31210", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "31310", 5) == 0)
    {
      strncpy(sz_trncod + 2, "31000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "320", 3) == 0)
    {
      strncpy(sz_trncod + 2, "32000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "321", 3) == 0)
    {
      strncpy(sz_trncod + 2, "32100", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "40", 2) == 0)
    {
      strncpy(sz_trncod + 2, "40000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "41", 2) == 0)
    {
      strncpy(sz_trncod + 2, "41000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "42", 2) == 0)
    {
      strncpy(sz_trncod + 2, "42000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "43", 2) == 0)
    {
      strncpy(sz_trncod + 2, "43000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "44", 2) == 0)
    {
      strncpy(sz_trncod + 2, "44000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "460", 3) == 0)
    {
      strncpy(sz_trncod + 2, "46000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "461", 3) == 0)
    {
      strncpy(sz_trncod + 2, "46100", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "48", 2) == 0)
    {
      strncpy(sz_trncod + 2, "48000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "490", 3) == 0 ||
             strncmp(pdb_InRecChild[GT_DBLTRNCOD_CF] + 2, "491", 3) == 0 )
    {
      strncpy(sz_trncod + 2, "40000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "492", 3) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "493", 3) == 0)
    {
      strncpy(sz_trncod + 2, "41000", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49400", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49500", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49400", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49405", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49505", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49405", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if ((strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49410", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49510", 5) == 0 ) && (strncmp(sz_Norme, "I17", 3) != 0)) //[15]
    {
      strncpy(sz_trncod + 2, "49410", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "49420", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49420", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "82", 2) == 0)
    {
      strncpy(sz_trncod + 2, "82100", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90300", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90310", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90320", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90330", 5) == 0)
    {
      strncpy(sz_trncod + 2, "90300", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90400", 5) == 0 ||
             strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "90410", 5) == 0
            )
    {
      strncpy(sz_trncod + 2, "90400", 5);
      pdb_InRecChild[GT_TRNCOD_CF] = sz_trncod;
    }

    // [11]
    if ( pdb_InRecChild[GT_TRNCOD_CF][7] != 'G' && pdb_InRecChild[GT_TRNCOD_CF][7] != '0' && pdb_InRecChild[GT_TRNCOD_CF][7] != '1' )
    {
      pdb_InRecChild[GT_TRNCOD_CF][7] = '2';
    }

    if ((strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000094") == 0 ||
         strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000095") == 0 ||
         strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000101") == 0 ) &&
        (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "41", 2) == 0 ||
         strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "42", 2) == 0 ||
         strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "43", 2) == 0 ||
         strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 2, "44", 2) == 0 )  &&
        (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 7, "0", 1) == 0))
    {
      /* Pas de Mise a jour de la période de comptes */
      /* Recuperation Sauvegarde Periode (Regle N° 2)*/
      pdb_InRecChild[GT_ACY_NF] = save_acy;
      pdb_InRecChild[GT_SCOSTRMTH_NF] = save_scostrmth;
      pdb_InRecChild[GT_SCOENDMTH_NF] = save_scoendmth;
      pdb_InRecChild[GT_GAAPCOD_NT] = sz_gaap_code;
      pdb_InRecChild[GT_I17PRDCOD_CT] = sz_prod_code;

      /* Ecriture de la ligne courante  */
      n_WriteCols(Kp_OutputFile, pdb_InRecChild, '~', 0);
    }
    else if (Kn_Annee <= n_anneecompte || Kn_Annee == atoi(pdb_InRecChild[GT_RTY_NF])) // Regle N° 4
    {
      pdb_InRecChild[GT_GAAPCOD_NT] = sz_gaap_code;	
      pdb_InRecChild[GT_I17PRDCOD_CT] = sz_prod_code;	  
      /* Ecriture de la ligne courante  */
      n_WriteCols(Kp_OutputFile, pdb_InRecChild, '~', 0);
    }

    /* MOD02 - Regle N° 3 - Postes Spécifiques */
    if ((strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000094") == 0 ||
         strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000095") == 0  ||
         strcmp(pdb_InRecChild[GT_RETCTR_NF], "06P000101") == 0  ) &&
        (strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 1, "C494002", 7) == 0 ||
         strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 1, "C410004", 7) == 0  ||
         strncmp(pdb_InRecChild[GT_TRNCOD_CF] + 1, "C434004", 7) == 0 ) &&
        strncmp(save_trncod + 1, "C", 1) != 0  && // Si poste non deja blanchi
        (Kn_Annee <= n_anneecompte))
    {
      /* Mise a jour de Annee de Compte */
      /* Recuperation Sauvegarde Periode (Regle N° 3)*/
      /* Annee -1 */
      sprintf(sz_acy_ante, "%d", atoi(sz_acy) - 1 );
      pdb_InRecChild[GT_ACY_NF] = sz_acy_ante;

      /* Mise a jour Montant (on inverse) */
      VAR_AMT = -atof(pdb_InRecChild[GT_AMT_M]);
      sprintf(sz_tmp, "%-.3lf", VAR_AMT);
      pdb_InRecChild[GT_AMT_M] = sz_tmp;

      VAR_RETAMT = -atof(pdb_InRecChild[GT_RETAMT_M]);
      sprintf(sz_tmpret, "%-.3lf", VAR_RETAMT);
      pdb_InRecChild[GT_RETAMT_M] = sz_tmpret;

      VAR_RETINTAMT = -atof(pdb_InRecChild[GT_RETINTAMT_M]);
      sprintf(sz_tmpretint, "%-.3lf", VAR_RETINTAMT);
      pdb_InRecChild[GT_RETINTAMT_M] = sz_tmpretint;

      pdb_InRecChild[GT_GAAPCOD_NT] = sz_gaap_code;
      pdb_InRecChild[GT_I17PRDCOD_CT] = sz_prod_code;
	  
      n_WriteCols(Kp_OutputFile, pdb_InRecChild, '~', 0);
    }
  }
  RETURN_VAL(OK);
}

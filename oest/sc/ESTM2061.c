/*============================================================================
Nom de l'application          : Injection du poste contrepartie dans le GT
Nom du source                 : ESTM2061.c
Revision                      :
Date de creation              : 21/10/1998
Auteur                        :
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :Transformation du GT Acceptation pour la filiale 6.

------------------------------------------------------------------------------
Historique des modifications :
[01] 08/11/2002 O.GIRAUX rejet des postes de pertes et profits qui ne doivent pas etre blanchis
[02] 26/05/2004 J.Ribot  :spot:10395 ajout d'une sélection sur GT_SSD_CF = 4 et GT_ESB_CF = 11
[03] 27/03/2008 J. Ribot :SPOT:15219 ASE15: recompilation des programmes C
[04] 20/07/2012 Florent  :spot:23390 empêcher la gestion des postes EBS
[05] 13/02/2013 Roger    :spot:24846 Insertion du clodat_d dans les années/mois/jour bilan
[06] 16/10/2014 sbe      : Modification et filtre poste comptable
[07] 16/11/2015 Florent  :spot:26690 correction, la modif 06 ne modifie que le TRNCOD_CF !
[08] 14/09/2016 Florent  :spot:30978 suppression test sur contrat
[09] 09/02/2021 Linh D.  :spira 93854 : fix GAAPCOD error
[10] 01/02/2022 Roger    :spira:98240 Suppression de defines GT_GAAPCOD_NT et GT_I17PRDCOD_CT car ils sont définis dans struct.h
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
T_RUPTURE_VAR bd_Rupture; /* variable sur la structure du GT */

FILE   *Kp_GetTrncod;    /* Pointeur sur le fichier GT-TOTGTAA*/

char Ksz_CLODAT_D[9];    /* Date de libelle inventaire*/

int Kn_Annee;           /* Annee de periode de compte (parametre de la chaine) */
/*--------------------------*/
/* Fonctions du fichier FGT */
/*--------------------------*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLignegt(char *ptsz_LigneCour[]);

/**************************************************************************/
/*** Objet :                                                            ***/
/*** Parametres:              ***/
/***  i argv : tableau de pointeurs sur les parametres    ***/
/*** Retour:                ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int main(int argc, char *argv[])
{
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
  }

  /* Recuperation du parametre correspondant a la date libelle inventaire*/
  strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));

  /* Recuperation de l'annee de compte */
  Kn_Annee = n_GetIntArgv(2);

  /* Ouverture du fichier de sortie GT-TOTGTAA */
  if (n_OpenFileAppl("ESTM2061_O1", "wt", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
  }

  /* Initialisation de la structure de rupture */
  if (n_InitRupture(&bd_Rupture) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
  }

  /* lancement du traitement du fichier maitre */
  if ( n_ProcessingRuptureVar( &bd_Rupture ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if (n_CloseFileAppl("ESTM2061_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTM2061_O1", &Kp_OutputFile) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_EndPgm() == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  }

  exit(OK);
}

/**************************************************************************/
/*** Objet : initialisation de la structure de rupture      ***/
/***  OK si pas d'erreur,           ***/
/***  ERR si erreur.              ***/
/**************************************************************************/
int n_InitRupture(T_RUPTURE_VAR *pbd_Rupture)
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier GT-TOTGTAA */
  if (n_OpenFileAppl("ESTM2061_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_NbRupture = 0;
  pbd_Rupture->n_ActionLigne = n_ActionLignegt;
  pbd_Rupture->c_Separ = '~';

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier GT-TOTAGTAA ***/
/*** Nom : n_ActionLigne            ***/
/*** Parametres:              ***/
/***  i ptsz_LigneCour : pointeur sur la ligne courante   ***/
/*** Retour:                                                ***/
/***  OK si pas d'erreur,                       ***/
/***  ERR si erreur.                          ***/
/**************************************************************************/
int n_ActionLignegt(char *ptsz_LigneCour[])
{
  /* Declartion des variables*/
  double VAR_AMT;
  char sz_tmp[30];
  char sz_trncod[9];
  char sz_acy[5];
  char sz_scostrmth[3];
  char sz_day[3];          // [05]

  DEBUT_FCT("n_ActionLigne");

  /* Initialisation des parametres*/
  VAR_AMT = 0;
  memset(sz_trncod, 0, sizeof(sz_trncod));
  strcpy(sz_trncod, ptsz_LigneCour[GT_TRNCOD_CF]);

  if (((atoi(ptsz_LigneCour[GT_SSD_CF]) == 4 && atoi(ptsz_LigneCour[GT_ESB_CF]) == 11)
       || atoi(ptsz_LigneCour[GT_SSD_CF]) == 6 )
      && Kn_Annee <= atoi(ptsz_LigneCour[GT_ACY_NF])
      && strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "11", 2) != 0
      && strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "81", 2) != 0
      && strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "84", 2) != 0
      && strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90", 2) != 0 //MOD01
      && isdigit(ptsz_LigneCour[GT_TRNCOD_CF][1])) //[04]
  {
    VAR_AMT = -atof(ptsz_LigneCour[GT_AMT_M]);
    sprintf(sz_tmp, "%-.3lf", VAR_AMT);
    ptsz_LigneCour[GT_AMT_M] = sz_tmp;

    ptsz_LigneCour[GT_CLM_NF] = "";
    ptsz_LigneCour[GT_OCCYEA_NF] = "";
    ptsz_LigneCour[GT_DBLTRNCOD_CF] = "";
    // clean gaapcod and product code
    ptsz_LigneCour[GT_GAAPCOD_NT]="";
    ptsz_LigneCour[GT_I17PRDCOD_CT]="";
    memset(sz_acy, 0, sizeof(sz_acy));
    memset(sz_day, 0, sizeof(sz_day));                // [05]
    sprintf(sz_acy, "%.4s", Ksz_CLODAT_D);
    sprintf(sz_scostrmth, "%.2s", Ksz_CLODAT_D + 4);
    sprintf(sz_day, "%.2s", Ksz_CLODAT_D + 6);        // [05]

    ptsz_LigneCour[GT_ACY_NF] = sz_acy;
    ptsz_LigneCour[GT_SCOSTRMTH_NF] = sz_scostrmth;
    ptsz_LigneCour[GT_SCOENDMTH_NF] = sz_scostrmth;
    ptsz_LigneCour[GT_BALSHEY_NF] = sz_acy;           // [05]
    ptsz_LigneCour[GT_BALSHRMTH_NF] = sz_scostrmth;   // [05]
    ptsz_LigneCour[GT_BALSHRDAY_NF] = sz_day;         // [05]
    	

    sz_trncod[1] = 'C';
    ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;

    if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "10", 2) == 0)
    {
      strncpy(sz_trncod + 2, "10000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "102", 3) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "103", 3) == 0)
    {
      strncpy(sz_trncod + 2, "10200", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "12", 2) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "15", 2) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "140", 3) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "13", 2) == 0)
    {
      strncpy(sz_trncod + 2, "12000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "141", 3) == 0)
    {
      strncpy(sz_trncod + 2, "14100", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "45", 2) == 0)
    {
      strncpy(sz_trncod + 2, "45000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "20", 2) == 0)
    {
      strncpy(sz_trncod + 2, "20000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "300", 3) == 0 )
    {
      strncpy(sz_trncod + 2, "30000", 5);           /*  Modif OG 09/12/02   */
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "301", 3) == 0 )
    {
      strncpy(sz_trncod + 2, "30100", 5);            /* Modif OG 09/12/02 */
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31000", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31020", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31100", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31200", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31300", 5) == 0 ||

             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31010", 5) == 0 ||    /* Modif OG 09/12/02  */
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31030", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31110", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31210", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "31310", 5) == 0)
    {
      strncpy(sz_trncod + 2, "31000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }


    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "320", 3) == 0)
    {
      strncpy(sz_trncod + 2, "32000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "321", 3) == 0)
    {
      strncpy(sz_trncod + 2, "32100", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "40", 2) == 0)
    {
      strncpy(sz_trncod + 2, "40000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "41", 2) == 0)
    {
      strncpy(sz_trncod + 2, "41000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "42", 2) == 0)
    {
      strncpy(sz_trncod + 2, "42000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "43", 2) == 0)
    {
      strncpy(sz_trncod + 2, "43000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "44", 2) == 0)
    {
      strncpy(sz_trncod + 2, "44000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "460", 3) == 0)
    {
      strncpy(sz_trncod + 2, "46000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "461", 3) == 0)
    {
      strncpy(sz_trncod + 2, "46100", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "48", 2) == 0)
    {
      strncpy(sz_trncod + 2, "48000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "490", 3) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "491", 3) == 0)
    {
      strncpy(sz_trncod + 2, "40000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "492", 3) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "493", 3) == 0)
    {
      strncpy(sz_trncod + 2, "41000", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49400", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49500", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49400", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49405", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49505", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49405", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49410", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49510", 5) == 0 )
    {
      strncpy(sz_trncod + 2, "49410", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "49420", 5) == 0)
    {
      strncpy(sz_trncod + 2, "49420", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "82", 2) == 0)
    {
      strncpy(sz_trncod + 2, "82100", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "83", 2) == 0)
    {
      strncpy(sz_trncod + 2, "83100", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90300", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90310", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90320", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90330", 5) == 0 )
    {
      strncpy(sz_trncod + 2, "90300", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }
    else if (strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90400", 5) == 0 ||
             strncmp(ptsz_LigneCour[GT_TRNCOD_CF] + 2, "90410", 5) == 0 )
    {
      strncpy(sz_trncod + 2, "90400", 5);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_trncod;
    }

    //[06]
    if ( ptsz_LigneCour[GT_TRNCOD_CF][7] != 'G' && ptsz_LigneCour[GT_TRNCOD_CF][7] != '0' && ptsz_LigneCour[GT_TRNCOD_CF][7] != '1' )
    {
      ptsz_LigneCour[GT_TRNCOD_CF][7] = '2';
    }
    n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
  }
  RETURN_VAL(OK);
}

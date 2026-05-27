/*=============================================================================
Nom de l'application          :
nom du source                 : ESTC7610.c
revision                      :
date de creation              : 25/08/2004
auteur                        : Jacky Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Il s'agit de detecter les modifications importantes des estimations vie
  En entree : CPLIFEST trie sur
              CTR_NF / SEC_NF / ACY_NF / UWY_NF / ACMTRS_NT / BALSHTMTH_NF / CRE_D

  En sortie : 3 fichiers suivi des modifs importantes
               - TLIFMOD (1 enreg par CTR_NF/SEC_NF)
               - TLIFMOD2 (1 enreg par ACY)
               - TLIFPEN

  4 ruptures :
     Rupt 1 -> Poste comptable
     Rupt 2 -> sec
     Rupt 3 -> acy
     Rupt 4 -> Filiale

------------------------------------------------------------------------------
historique des modifications :
[01]  15/10/2004 J.Ribot on ne prend plus les postes 1303 1304 1323 1324 2303 2304 2323 2324 dans le calcul Résultat Tech. + CNA + Financier
[02]  07/12/2004 J.Ribot prise en compte des postes 2183 2184 2193 2194 dans le calcul Résultat Tech. + CNA RETRO
[03]  03/05/2006 J.Ribot Ne plus generer de fiches pour les CNA   SPOT12721
[04]  30/08/2006 J.Ribot :spot:13087 ajout postes rétro (PTC + ventilation) 2083 2084 + 2603 2604 2623 2624 2633 2634
[05]  18/10/2006 J.Ribot :spot:13087 ajout postes rétro (PTC + ventilation) 2263 + 2264
[06]  16/11/2007 J.Ribot :spot:14286 ajout postes Accept Prime 1011 et rétro Prime 2011
[07]  23/11/2007 J.Ribot :spot:14688 ajout postes Accept VOBA 1163 1164 et rétro VOBA 2163 2164
[08]   7/08/2014  JBG      :spot:25773 - Reelooking code for ++ usage--------------
_________________
MODIFICATION    [008]
Auteur:         D.GATIBELZA
Date:           14/05/2008
Version:        10.1
Description:    ESTVIE15401 Agrandissement d'un tableau en mémoire:
                NB_MAX_PILOT 20000 => 40000
_________________
MODIFICATION    [009]
Auteur:         D.GATIBELZA
Date:           02/06/2009
Version:        9.1

[10] 28/01/2010 Florent :spot:17244 ajout de poste cumul 2110 et 2145 manquant dans la retro, VOBA et CNA cumule suelement dans RESDACAMT_M
_________________
MODIFICATION    [011]
Auteur:         D.GATIBELZA
Date:           28/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
_________________
MODIFICATION    [012]
Auteur:         JF-VDV
Date:           02/09/2010
Version:        10.1
Description:   [18754] Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1543 en dupliquant comme le 1093 et le 2543 comme le 2093
_________________
MODIFICATION    [013]
Auteur:         D.GATIBELZA
Date:           27/09/2010
Version:        10.1
Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC

[14] 05/10/2010 Roger Cassis :spot:18754 ajout de poste cumul 1544 et 2544 manquants pour l'acceptation et la retro
[015] 26/04/2014 Roger Cassis :spot:25427 Omega2 1B Centralization - incremantation nb postes et messages si pb compteurs
[XXX] 6/04/2014 JBG :spot:25773 Warnings suppress in compile
[016] 09/07/2014 ABJ :spot:25773 correction of ACY
[017] 22/07/2014 ABJ  spot:25773  Correction de numero de gap
[018] 23/07/2014 ABJ  spot:25773  Valeur par defaut pour le champ MOD_TYPMOD1_CT
[019] 01/09/2014 ABJ  spot:25773  Correction Last/First rupture pour l ACY/GAAP spira 29926
[020] 9/22/2014 JBG :spot:25773 Add 1533 and 1534 cumulative post
[021] 30/09/2014 M.MECHRI :spot:25773 Add post 1503,1523,1533,1603,1623,1633,1504,1524,1534,1604,1624,1634 and RETRO
[022] 06/10/2014 ABJ  spot:25773  Ajout du DETTRNCOD pour la rupture Acmtrs
[023] 09/11/2015 S.Behague :spot:29658 Ajout Flag DISPLAY_B TLIFMOD
[024] 09/11/2015 S.Behague :spot:30079 Ajout Flag DISPLAY_B TLIFMOD seulement pour ARRETE STAT
[025] 25/01/2016 M.Bonato MBO :spot:30030 spira:43350 le seuil est de 0 pour les ARRETE STAT sinon il possède sa valeur d'origine
[026] 27/05/2016 MMA :spot 30679 Spira 050414: Correction du FIchier de sortie Flifmod2 erroné: Problème d'indexe liè à un Tri, changement de type du pilote
[027] 20/04/2021 S.Behague :spira:89086 APOLO QE : Compte complet yearly sur traité quaterly
[028] 19/07/2022 S.Behague :spira:99820 Fiche mouvement - écart entre le calcul GUI et le calcul batch
[029] 02/12/2022 HR :spira:99820 Fiche mouvement - écart entre le calcul GUI et le calcul batch
==============================================================================*/
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define NB_MAX_SEUIL    100     //[009] 15
#define MAX_COUPLE_ANALYSIS    50

#define MT1AV 0
#define MT1AP 1
#define DIFF1 2
#define MT2AV 3
#define MT2AP 4
#define DIFF2 5
#define MT3AV 6
#define MT3AP 7
#define DIFF3 8
#define MT4AV 9
#define MT4AP 10
#define DIFF4 11

typedef struct {
    int nb_Dettrn;
    unsigned char  Adjsig[200];
    int ACMTRS[200];
    char* DETTRN[200];
}T_DETTRN_ACMTRS_Base;

const int I_PRIPRMAMT_M = 0;
const int I_AFTPRMAMT_M = 1;
const int I_PRIRESTECAMT_M = 3;
const int I_AFTRESTECAMT_M = 4;
const int I_PRIRESDACAMT_M = 6;
const int I_AFTRESDACAMT_M = 7;
const int I_PRIRESFINAMT_M = 9;
const int I_AFTRESFINAMT_M = 10;

int Acy[10];
int Acys = 99;
char gaaps[2];
int indh = 0,
    indv = 0;
int Kn_SUP = 0;

double Tb_Mt[11][14];
double Tb_Diff[11][14];                           // table pour gestion des motifs de depassement du seuil

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE            *Kp_PrevInFile;                 // pointeur sur les previsions en entree
FILE            *Kp_CoursFile;                  // pointeur sur les derniers cours connus
FILE            *Kp_PilotFile;                  // pointeur sur les pilotages
FILE            *Kp_SeuilFile;                  // pointeur sur les seuils
FILE            *Kp_Mod1Out1File;               // pointeur sur sortie 1
FILE            *Kp_Mod2Out2File;               // pointeur sur sortie 2
FILE            *Kp_PenOut3File;                // pointeur sur sortie 3
FILE            *Kp_SubTRSBaseFile;

T_RUPTURE_VAR   Kbd_Rupt;                       // variable de gestion de la rupture
T_LIFDRI_ALL    Kbd_PILOT[NB_MAX_PILOT];        // Fichier pilotage charge en memoire                  //[026] Modification du type de la structure T_LIFDRI => T_LIFDRI_ALL
int             Kn_NbLigPilot;                  // Nombre de lignes dans le fichier pilotage

T_LIFTHR        Kbd_SEUIL[NB_MAX_SEUIL];        // Fichier seuil charge en memoire
int             Kn_NbLigSeuil;                  // Nombre de lignes dans le fichier seuil

int n_ChargerPilot  ();
int n_RechPilot     (char *, char *, char *, int);
int n_ChargerSeuil  ();
int n_RechSeuil     (char **, int);

int n_ChargerTsubTRSBaseDettrncod(FILE *Kp_SubTRSBaseFile);
int n_FindTsubTRSBaseDettrncod(T_DETTRN_ACMTRS_Base *pbd_lu,int Dettrncod);

// declaration des structures pour les cumuls au format du GT simplifie converti
double  Kd_MtAv,                                // Cumul sur 1 meme poste comptable avant S/R
        Kd_MtAp;                                // Cumul sur 1 meme poste comptable apres S/R
char Ksz_Cre[20];                               // date de creation des previsions en sortie
char Ksz_Cre_59[20];                            // date de creation des previsions en sortie
char Ksz_Cre_Mv[20];                            // date de creation des previsions en sortie
char Ksz_Acy[5];
char Ksz_BALSHEY[5];
char Ksz_BALSHTMTH[5];
char Ksz_ORICOD[25];
char sz_Mod_AST[4];
int Kn_NbLigSubTRSBasefile=0;

T_SUBTRSBASE Kbd_SubTRSBase[2000];
T_DETTRN_ACMTRS_Base  Dett_Base[MAX_COUPLE_ANALYSIS];
    
int in = 0;
int n_InitPrev              (T_RUPTURE_VAR  *);
int n_IsR1Sec               (char **, char **);
int n_IsR2Acmtrs            (char **, char **);
int n_IsR3Acy               (char **, char **);
int n_ActionFirstRupt1Sec   (char **);
int n_ActionFirstRupt2Acmtrs(char **);
int n_ActionFirstRupt3Acy   (char **);
int n_ActionLignePrev       (char **);
int n_ActionLastRupt1Sec    (char **);
int n_ActionLastRupt2Acmtrst(char **);
int n_ActionLastRupt3Acy    (char **);
int n_ProcessingRuptureVar  (T_RUPTURE_VAR *);


/*==============================================================================
objet  : Pt d'entree du programme
retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
  char sz_Cre[22];

  // Initialisation des signaux
  InitSig ();

  if (n_BeginPgm (argc, argv) == ERR)                                      ExitPgm(ERR_XX, "");

  // Recuperation de la date de lancement du batch
  strcpy (sz_Cre, psz_GetCharArgv(1));

  // Formatage de la date de creation des previsions en sortie
  sprintf( Ksz_Cre, "%s %s", sz_Cre, "23:59:10" ) ;
  //sprintf( Ksz_Cre, "%s %s", sz_Cre, "23:59:12" ) ;
  sprintf( Ksz_Cre_59, "%s %s", sz_Cre, "23:59:59" ) ;

  // Ouverture des fichiers de sortie
  if (n_OpenFileAppl ("ESTC7610_O1", "wt", &Kp_Mod1Out1File) == ERR)        ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl ("ESTC7610_O2", "wt", &Kp_Mod2Out2File) == ERR)        ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl ("ESTC7610_O3", "wt", &Kp_PenOut3File) == ERR)         ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl ("ESTC7610_I2", "rb", &Kp_CoursFile) == ERR )          ExitPgm(ERR_XX, "");
  if (n_OpenFileAppl ("ESTC7610_I5", "rb", &Kp_SubTRSBaseFile) == ERR)       ExitPgm(ERR_XX, "");

  // Chargement en memoire du fichier pilotage et du fichier seuil
  n_ChargerPilot();
  n_ChargerSeuil();
  
  if (n_ChargerTsubTRSBaseDettrncod(Kp_SubTRSBaseFile) != 0)
    ExitPgm(ERR_XX, "Call of n_ChargerTsubTRSBaseDettrncod() fails");

  // Initialisation var Kbd_Rupt
  if (n_InitPrev(&Kbd_Rupt) == ERR)                                       ExitPgm(ERR_XX, "");
  // Lancement traitement
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)                           ExitPgm(ERR_XX, "");

  // Fermeture des fichiers
  if (n_CloseFileAppl ("ESTC7610_I1", &(Kbd_Rupt.pf_InputFil)) == ERR)     ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_I2", &Kp_CoursFile))                      ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_I3", &Kp_PilotFile) == ERR)               ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_I4", &Kp_SeuilFile) == ERR)               ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_I5", &Kp_SubTRSBaseFile) == ERR)          ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_O1", &Kp_Mod1Out1File) == ERR)            ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_O2", &Kp_Mod2Out2File) == ERR)            ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl ("ESTC7610_O3", &Kp_PenOut3File) == ERR)             ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR)      ExitPgm ( ERR_XX , "" );

  exit(0);
}


/*==============================================================================
objet : Initialisation de la variable de gestion de rupture du fichier GT simplifie converti
retour: 0K
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  // Ouverture du fic CPLIFEST
  if (n_OpenFileAppl("ESTC7610_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)     return ERR;

    pbd_Rupt->n_NbRupture = 3;
  
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Sec;
    pbd_Rupt->n_ConditionRupture[1] = n_IsR2Acmtrs;
    pbd_Rupt->n_ConditionRupture[2] = n_IsR3Acy;

    pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1Sec;
    pbd_Rupt->n_ActionFirst[2]      = n_ActionFirstRupt2Acmtrs;
    pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt3Acy;

    pbd_Rupt->n_ActionLigne         = n_ActionLignePrev;

    pbd_Rupt->n_ActionLast[0]       = n_ActionLastRupt1Sec;
    pbd_Rupt->n_ActionLast[1]       = n_ActionLastRupt2Acmtrst;
    pbd_Rupt->n_ActionLast[2]       = n_ActionLastRupt3Acy;

    pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1 sur Filiale
retour: 0 ---> pas de rupture
       dif de 0 ---> rupture
===========================================================================*/
int n_IsR1Sec(char **ptb_InRec, char **ptb_InRec_Cur)
{
  //int p;

  // Test de correspondance entre ligne courante et ligne suivante sur : Section
  if (strcmp(ptb_InRec[TLIFEST_GAAP_NF], ptb_InRec_Cur[TLIFEST_GAAP_NF]) != 0)       RETURN_VAL(1);
  if (strcmp(ptb_InRec[TLIFEST_CTR_NF], ptb_InRec_Cur[TLIFEST_CTR_NF]) != 0)         RETURN_VAL(1);
  if (strcmp(ptb_InRec[TLIFEST_SEC_NF], ptb_InRec_Cur[TLIFEST_SEC_NF]) != 0)         RETURN_VAL(1);
  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction de test de rupture de niveau 1     sur Etablissement
retour:        0 ---> pas de rupture
        dif de 0 ---> rupture
===========================================================================*/
int n_IsR2Acmtrs(char **ptb_InRec, char **ptb_InRec_Cur)
{
  // Test de correspondance entre ligne courante et ligne suivante sur :
  // Poste Comptable

  if (strcmp(ptb_InRec[TLIFEST_ACY_NF], ptb_InRec_Cur[TLIFEST_ACY_NF]) != 0)         RETURN_VAL(1);
  if (strcmp(ptb_InRec[TLIFEST_UWY_NF], ptb_InRec_Cur[TLIFEST_UWY_NF]) != 0)         RETURN_VAL(1);
  if (strcmp(ptb_InRec[TLIFEST_ACMTRS_NT], ptb_InRec_Cur[TLIFEST_ACMTRS_NT]) != 0)   RETURN_VAL(1);
  if (strcmp(ptb_InRec[TLIFEST_DETTRNCOD_CF], ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF]) != 0)   RETURN_VAL(1); //[022]

  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction de test de rupture de niveau 1             sur Annee bilan
retour:        0 ---> pas de rupture
        dif de 0 ---> rupture
===========================================================================*/
int n_IsR3Acy(char **ptb_InRec, char **ptb_InRec_Cur)
{
  // Test de correspondance entre ligne courante et ligne suivante sur :
  // Annee Compte
  if (strcmp(ptb_InRec[TLIFEST_ACY_NF], ptb_InRec_Cur[TLIFEST_ACY_NF]) != 0)         RETURN_VAL(1);

  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction lancee a la rupture premiere de niveau 1   Initialisation cumul Filiale
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt1Sec(char **ptb_InRec_Cur)
{
  Kd_MtAv = 0;
  Kd_MtAp = 0;
  Acys = 99;
  char gaaps[2];


  for (indv = 0; indv < 10 ; indv ++)
  {
    Acy[indv] = 0;
    for (indh = 0; indh < 13 ; indh ++)
    {
      Tb_Mt[indv][indh] = 0;
      Tb_Diff[indv][indh] = 0;
    }
  }
  indv = 0;
  indh = 0;
  sprintf(Ksz_ORICOD , "%s", " ");
  Acy[indv] = atoi(ptb_InRec_Cur[TLIFEST_ACY_NF]);
  Acys = atoi(ptb_InRec_Cur[TLIFEST_ACY_NF]);
  strcpy(gaaps , ptb_InRec_Cur[TLIFEST_GAAP_NF]);
  return OK;
}



/*==============================================================================
objet : fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul Etablissement
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt2Acmtrs(char **ptb_InRec_Cur)
{
  Kd_MtAv = 0;
  Kd_MtAp = 0;

  return OK;
}



/*==============================================================================
objet : fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul Bilan
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt3Acy(char **ptb_InRec_Cur)
{
  Acys = atoi(ptb_InRec_Cur[TLIFEST_ACY_NF]);

  return OK;
}



/*==============================================================================
objet : fonction lancee pour chaque ligne
        - cumuls
        - ecriture des lignes en sortie
retour :    OK ---> traitement correctement effectue
          ERR --> probleme rencontre
===========================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{

  
  if (strcmp(ptb_InRec_Cur[TLIFEST_CRE_D], Ksz_Cre) > 0)
  {
    Kd_MtAp = atof(ptb_InRec_Cur[TLIFEST_ESTMNT_M]);
    strcpy(Ksz_Cre_Mv, ptb_InRec_Cur[TLIFEST_CRE_D]);
    strcpy(Ksz_BALSHEY, ptb_InRec_Cur[TLIFEST_BALSHEY_NF]);
    strcpy(Ksz_BALSHTMTH, ptb_InRec_Cur[TLIFEST_BALSHTMTH_NF]);
  }
  else
  {
    Kd_MtAv = atof(ptb_InRec_Cur[TLIFEST_ESTMNT_M]);
    Kd_MtAp = atof(ptb_InRec_Cur[TLIFEST_ESTMNT_M]);
  }



  return OK;
}


/*==============================================================================
objet : fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul filiale
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt1Sec(char **ptb_InRec_Cur)
{
  int indice = 0;
  int indix = 0;
  int n_i;
  double d_seuil_bis = 0;


  double d_montant_1 = 0, d_montant_2 = 0;
  double d_taux;
  double d_seuil = 0;
  char sz_TranMt1[30];
  char sz_TranMt2[30];
  char sz_TranMt3[30];
  char sz_TranMt4[30];
  char sz_TranMt5[30];
  char sz_TranMt6[30];
  char sz_TranMt7[30];
  char sz_TranMt8[30];
  char sz_Acy[5];
  char sz_comacc_b[2];
  char *ptb_LigneMod[MOD_NBCOL + 1];
  char *ptb_LigneMod2[MOD2_NBCOL + 1];
  char *ptb_LignePen[PEN_NBCOL + 1];

  Kn_SUP = 0;
  indix = n_RechSeuil (ptb_InRec_Cur, indix);

  if ( indix == -1 )
  {
    d_seuil = 0;
  }
  else
  {
    d_seuil = (Kbd_SEUIL[indix].AMT_M);
  }
  d_seuil_bis = d_seuil;

  // conversion devise de la prev
  d_taux = d_GetTaux ( Kp_CoursFile,
                       (char) atoi(ptb_InRec_Cur[TLIFEST_SSD_CF]),
                       atoi(ptb_InRec_Cur[TLIFEST_BALSHEY_NF]),
                       ptb_InRec_Cur[TLIFEST_CUR_CF],
                       (Kbd_SEUIL[indix].CUR_CF) );

  for (indv = 0; indv < 8 ; indv ++)
  {
    if (Acy[indv] !=  0)
    {
      d_montant_1     = Tb_Mt[indv][I_PRIPRMAMT_M] * d_taux;
      d_montant_2     = Tb_Mt[indv][I_AFTPRMAMT_M] * d_taux;
      Tb_Mt[indv][2]  = d_montant_1 - d_montant_2;

      d_montant_1     = Tb_Mt[indv][I_PRIRESTECAMT_M] * d_taux;
      d_montant_2     = Tb_Mt[indv][I_AFTRESTECAMT_M] * d_taux;
      Tb_Mt[indv][5]  = d_montant_1 - d_montant_2;

      d_montant_1     = Tb_Mt[indv][I_PRIRESDACAMT_M] * d_taux;
      d_montant_2     = Tb_Mt[indv][I_AFTRESDACAMT_M] * d_taux;
      Tb_Mt[indv][8]  = d_montant_1 - d_montant_2;

      d_montant_1     = Tb_Mt[indv][I_PRIRESFINAMT_M] * d_taux;
      d_montant_2     = Tb_Mt[indv][I_AFTRESFINAMT_M] * d_taux;
      Tb_Mt[indv][11] = d_montant_1 - d_montant_2;

      Tb_Diff[9][6] = Tb_Diff[9][4]  * d_taux;                    // conversion max diff

      if (Tb_Diff[9][7]  == 0)    //[025] le seuil est de 0 pour les ARRETE STAT sinon il possède sa valeur d'origine
        d_seuil = 0;
      else
        d_seuil = d_seuil_bis;

      if (fabs(Tb_Diff[9][6]) > d_seuil )
      {
        if (Tb_Diff[9][7]  == 0)
        {
          strcpy(Ksz_ORICOD, "ARRETE STAT");       // code motif du mouvement ayant genere la max diff
        }

        if (Tb_Diff[9][7]  == 1)
        {
          strcpy(Ksz_ORICOD, "CNA AUTO");          // "       "   "     "       "        "    "
        }

        if (Tb_Diff[9][7]  == 2)
        {
          strcpy(Ksz_ORICOD, "RETRO INTERNE");     // "       "   "     "        "        "   "
        }

        if (Tb_Diff[9][7]  == 3)
        {
          strcpy(Ksz_ORICOD, "RETRO AUTO");       // "       "   "     "        "        "   "
        }
      }
// JR 03 05 2006 SPOT12721
// if (fabs(Tb_Mt[indv][2]) > d_seuil ||
//    fabs(Tb_Mt[indv][5]) > d_seuil  ||
//    fabs(Tb_Mt[indv][8]) > d_seuil  ||
//    fabs(Tb_Mt[indv][11]) > d_seuil )

      if ( fabs(Tb_Mt[indv][2]) > d_seuil  ||
           fabs(Tb_Mt[indv][5]) > d_seuil  ||
           ( fabs(Tb_Mt[indv][11]) > d_seuil &&
             fabs(Tb_Mt[indv][8]) == 0 )   )
// FIN JR 03 05 2006 SPOT12721
      {
      	if ( (atoi(ptb_InRec_Cur[TLIFEST_ESTMTH_NF]) == 12 || atoi(ptb_InRec_Cur[TLIFEST_ESTMTH_NF]) == 13) && (strcmp(Ksz_ORICOD, "ARRETE STAT") == 0))
        	Kn_SUP = 1;
        if ( strcmp(Ksz_ORICOD, "ARRETE STAT") != 0 )
        	Kn_SUP = 1;
      }
    }
  }

  if (Kn_SUP == 1)
  {
    //---------------------------
    //   TLIFMOD
    //---------------------------
    for (n_i = 0 ; n_i < MOD_NBCOL ; n_i ++)
      ptb_LigneMod[n_i] = "";

    ptb_LigneMod[MOD_CTR_NF] = ptb_InRec_Cur[TLIFEST_CTR_NF];
    ptb_LigneMod[MOD_SEC_NF] = ptb_InRec_Cur[TLIFEST_SEC_NF];
    ptb_LigneMod[MOD_CRE_D]  =  Ksz_Cre_59;
    ptb_LigneMod[MOD_BALSHEY_NF]   =  Ksz_BALSHEY;
    ptb_LigneMod[MOD_BALSHTMTH_NF] = Ksz_BALSHTMTH;
    ptb_LigneMod[MOD_SSD_CF] = ptb_InRec_Cur[TLIFEST_SSD_CF];

    ptb_LigneMod[MOD_TYPMOD1_CT] = "201"; // [018]
    ptb_LigneMod[MOD_DISPLAY_B] = "1";                             // [023][024] // Pour Notification autre que ARRETE STAT on met DISPLAY_B à 1
    if (strcmp(Ksz_ORICOD, "ARRETE STAT") == 0)
    {
      ptb_LigneMod[MOD_TYPMOD1_CT] = "200";
      ptb_LigneMod[MOD_DISPLAY_B] = "0";                             // [023][024] // Pour Notification autre que ARRETE STAT on met DISPLAY_B à 1
    }

    if (strcmp(Ksz_ORICOD, "CNA AUTO") == 0)
    {
      ptb_LigneMod[MOD_TYPMOD1_CT] = "201";
    }

    if (strcmp(Ksz_ORICOD, "RETRO AUTO") == 0)
    {
      ptb_LigneMod[MOD_TYPMOD1_CT] = "202";
    }

    if (strcmp(Ksz_ORICOD, "RETRO INTERNE") == 0)
    {
      ptb_LigneMod[MOD_TYPMOD1_CT] = "203";
    }

    ptb_LigneMod[MOD_CUR_CF]    = ptb_InRec_Cur[TLIFEST_CUR_CF];
    ptb_LigneMod[MOD_ORICOD_LS] = Ksz_ORICOD;
    ptb_LigneMod[MOD_CREUSR_CF] = "dbo";
    ptb_LigneMod[MOD_LSTUPD_D]  =  Ksz_Cre_59;
    ptb_LigneMod[MOD_LSTUPDUSR_CF] = "dbo";
    ptb_LigneMod[MOD_TIMESTAMP_CF] = "00";

    // Delimitation champs avant ecriture
    ptb_LigneMod[MOD_NBCOL] = 0;

    // Ecriture de la ligne TLIFMOD
    n_WriteCols(Kp_Mod1Out1File, ptb_LigneMod, SEPARATEUR, 0);


    //---------------------------
    //   TLIFMOD2
    //---------------------------
    for (indv = 0; indv < 8 ; indv ++)
    {
      if (Acy[indv] !=  0)
      {
        sprintf(sz_Acy, "%d", Acy[indv]);
        indice = n_RechPilot( ptb_InRec_Cur[TLIFEST_CTR_NF],
                              ptb_InRec_Cur[TLIFEST_SEC_NF],
                              sz_Acy,
                              indice );

        sprintf(sz_comacc_b, "%1.1d", Kbd_PILOT[indice].COMACC_B);

        for (n_i = 0 ; n_i < MOD2_NBCOL ; n_i ++)
          ptb_LigneMod2[n_i] = "";


        ptb_LigneMod2[MOD2_CTR_NF]      = ptb_InRec_Cur[TLIFEST_CTR_NF];
        ptb_LigneMod2[MOD2_SEC_NF]      = ptb_InRec_Cur[TLIFEST_SEC_NF];
        ptb_LigneMod2[MOD2_CRE_D]       =  Ksz_Cre_59;
        ptb_LigneMod2[MOD2_BALSHEY_NF]  =  Ksz_BALSHEY;
        ptb_LigneMod2[MOD2_BALSHTMTH_NF] = Ksz_BALSHTMTH;
        ptb_LigneMod2[MOD2_ACY_NF]      = sz_Acy;
        ptb_LigneMod2[MOD2_COMACC_B]    = sz_comacc_b;

        sprintf(sz_TranMt1, "%-.3lf", Tb_Mt[indv][I_PRIPRMAMT_M]);
        ptb_LigneMod2[MOD2_PRIPRMAMT_M] = sz_TranMt1;

        sprintf(sz_TranMt2, "%-.3lf", Tb_Mt[indv][I_AFTPRMAMT_M]);
        ptb_LigneMod2[MOD2_AFTPRMAMT_M] = sz_TranMt2;

        sprintf(sz_TranMt3, "%-.3lf", Tb_Mt[indv][I_PRIRESTECAMT_M]);
        ptb_LigneMod2[MOD2_PRIRESTECAMT_M] = sz_TranMt3;

        sprintf(sz_TranMt4, "%-.3lf", Tb_Mt[indv][I_AFTRESTECAMT_M]);
        ptb_LigneMod2[MOD2_AFTRESTECAMT_M] = sz_TranMt4;

        sprintf(sz_TranMt5, "%-.3lf", Tb_Mt[indv][I_PRIRESDACAMT_M]);
        ptb_LigneMod2[MOD2_PRIRESDACAMT_M] = sz_TranMt5;

        sprintf(sz_TranMt6, "%-.3lf", Tb_Mt[indv][I_AFTRESDACAMT_M]);
        ptb_LigneMod2[MOD2_AFTRESDACAMT_M] = sz_TranMt6;

        sprintf(sz_TranMt7, "%-.3lf", Tb_Mt[indv][I_PRIRESFINAMT_M]);
        ptb_LigneMod2[MOD2_PRIRESFINAMT_M] = sz_TranMt7;

        sprintf(sz_TranMt8, "%-.3lf", Tb_Mt[indv][I_AFTRESFINAMT_M]);
        ptb_LigneMod2[MOD2_AFTRESFINAMT_M] = sz_TranMt8;
        ptb_LigneMod2[MOD2_CREUSR_CF] = "dbo";
        ptb_LigneMod2[MOD2_LSTUPD_D]  =  Ksz_Cre_59;
        ptb_LigneMod2[MOD2_LSTUPDUSR_CF] = "dbo";
        ptb_LigneMod2[MOD2_TIMESTAMP_CF] = "00";
        ptb_LigneMod2[MOD2_GAAP_NT] = ptb_InRec_Cur[TLIFEST_GAAP_NF]; //gaaps;

        // Delimitation champs avant ecriture
        ptb_LigneMod2[MOD2_NBCOL] = 0;

        // Ecriture de la ligne TLIFMOD2
        n_WriteCols(Kp_Mod2Out2File, ptb_LigneMod2, SEPARATEUR, 0);
      }
    }

    //---------------------------
    //   TLIFPEN
    //---------------------------
    for (n_i = 0 ; n_i < PEN_NBCOL ; n_i ++)
      ptb_LignePen[n_i] = "";

    ptb_LignePen[PEN_USR_CF] = "dbo";
    ptb_LignePen[PEN_CTR_NF] = ptb_InRec_Cur[TLIFEST_CTR_NF];
    ptb_LignePen[PEN_SEC_NF] = ptb_InRec_Cur[TLIFEST_SEC_NF];
    ptb_LignePen[PEN_CRE_D] =  Ksz_Cre_59;
    ptb_LignePen[PEN_BALSHEY_NF] =  Ksz_BALSHEY;
    ptb_LignePen[PEN_BALSHTMTH_NF] = Ksz_BALSHTMTH;
    ptb_LignePen[PEN_PENSTS_CT] = "2";
    ptb_LignePen[PEN_UWGRP_CF] = "999";
    ptb_LignePen[PEN_CREUSR_CF] = "dbo";
    ptb_LignePen[PEN_LSTUPD_D]  =  Ksz_Cre_59;
    ptb_LignePen[PEN_LSTUPDUSR_CF] = "dbo";
    ptb_LignePen[PEN_TIMESTAMP_CF] = "00";
    // Delimitation champs avant ecriture
    ptb_LignePen[PEN_NBCOL] = 0;
    // Ecriture de la ligne TLIFPEN
    n_WriteCols(Kp_PenOut3File, ptb_LignePen, SEPARATEUR, 0);
  }

  return OK;
}



/*==============================================================================
objet : fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul etablissement
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt2Acmtrst(char **ptb_InRec_Cur)
{
  int pris = 0;
  int result = 0;
  int i = 0;

  if ( (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43220") != 0) && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43210") != 0) && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43323") != 0)
       && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43313") != 0) && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43324") != 0) && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43314") != 0)
       && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43820") != 0) && (strcmp(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF], "43810") != 0))
  {
  	result = n_FindTsubTRSBaseDettrncod(Dett_Base,atoi(ptb_InRec_Cur[TLIFEST_DETTRNCOD_CF]));
 		for ( i =0; i <Dett_Base->nb_Dettrn; i++)
 		{
 	// Premiums ACMTRS 1010/1401
    	//029 if ( Dett_Base->ACMTRS[i] == 1010 || Dett_Base->ACMTRS[i] == 1401 )
    	if ( Dett_Base->ACMTRS[i] == 1010)
    	{
    	  Tb_Mt[indv][I_PRIPRMAMT_M] += Kd_MtAv; //1010
        Tb_Mt[indv][I_AFTPRMAMT_M] += Kd_MtAp;
        pris = 1;
    	}
  		// ResTech ACMTRS 1400
    	if ( Dett_Base->ACMTRS[i] == 1400 )
    	{
        Tb_Mt[indv][I_PRIRESTECAMT_M] += Kd_MtAv;
        Tb_Mt[indv][I_AFTRESTECAMT_M] += Kd_MtAp;
        pris = 1;
    	}
  		// ResTech FIN ACMTRS 1
    	if ( Dett_Base->ACMTRS[i] == 1450 )
    	{
        Tb_Mt[indv][I_PRIRESFINAMT_M] += Kd_MtAv;
        Tb_Mt[indv][I_AFTRESFINAMT_M] += Kd_MtAp;
        pris = 1;
    	}
  		// ResTech DAC ACMTRS 1400
    	if ( Dett_Base->ACMTRS[i] == 1460 )
    	{
        Tb_Mt[indv][I_PRIRESDACAMT_M] += Kd_MtAv;
        Tb_Mt[indv][I_AFTRESDACAMT_M] += Kd_MtAp;
        pris = 1;
    	}
    } //Fin for	
    
//    // Cumul dans le structure de cumul
//    //switch ( atoi ( ptb_InRec_Cur[TLIFEST_ACMTRS_NT] ) )
//    switch ( Dett_Base->ACMTRS[i] )
//    {
// 
//    		
//    // wrtprm_m : written premium
//    // acceptation
//    case 1010 :
//    case 1011 :
//    case 1013 :
//    case 1014 :
//    // retro
//    case 2010 :
//    case 2011 :
//    case 2013 :
//    case 2014 :
//      Tb_Mt[indv][I_PRIPRMAMT_M] += Kd_MtAv; //1010
//      Tb_Mt[indv][I_AFTPRMAMT_M] += Kd_MtAp;
//      Tb_Mt[indv][I_PRIRESTECAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESTECAMT_M] += Kd_MtAp;
//      Tb_Mt[indv][I_PRIRESDACAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESDACAMT_M] += Kd_MtAp;
//      Tb_Mt[indv][I_PRIRESFINAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESFINAMT_M] += Kd_MtAp;
//      pris = 1;
//      break;
//
//    // Résultat technique
//    // acceptation
//    case 1021 :
//    case 1022 :
//    case 1063 :
//    case 1093 :     //[011]
//    case 1543 :     //[012]
//    case 1544 :     //[014]
//    case 1064 :
//    case 1094 :     //[011]
//    case 1073 :
//    case 1074 :
//    case 1083 :
//    case 1084 :
//    case 1100 :
//    case 1110 :
//    case 1140 :
//    case 1150 :
//    case 1160 :
//    case 1200 :
//    case 1210 :
//    case 1220 :
//    case 1231 :
//    case 1232 :
//    case 1243 :
//    case 1244 :
//    case 1263 :
//    case 1264 :
//    //[021]
//    case 1503 :
//    case 1523 :
//    case 1533 :
//    case 1504 :
//    case 1524 :
//    case 1534 :
//    case 1603 :
//    case 1623 :
//    case 1633 :
//    case 1604 :
//    case 1624 :
//    case 1634 :
//    /*    case 1533 :   //[020]
//        case 1534 :   //[020] */
//    // retro
//    case 2021 :
//    case 2022 :
//    case 2063 :
//    case 2093 :     //[011]
//    case 2543 :     //[012]
//    case 2064 :
//    case 2094 :     //[011]
//    case 2073 :
//    case 2074 :
//    case 2083 :     //[04]
//    case 2084 :     //[04]
//    case 2100 :
//    case 2110 :     //[10]
//    case 2140 :
//    case 2145 :     //[10]
//    case 2150 :
//    case 2160 :
//    case 2200 :
//    case 2210 :
//    case 2220 :
//    case 2231 :
//    case 2232 :
//    case 2243 :
//    case 2244 :
//    case 2544 :     //[14]
//    case 2263 :     //[05]
//    case 2264 :     //[05]
//    case 2503 :     //[021]
//    case 2523 :
//    case 2533 :
//    case 2504 :
//    case 2524 :
//    case 2534 :
//    case 2603 :
//    case 2623 :
//    case 2633 :
//    case 2604 :
//    case 2624 :
//    case 2634 :
//      Tb_Mt[indv][I_PRIRESTECAMT_M] += Kd_MtAv; //1400
//      Tb_Mt[indv][I_AFTRESTECAMT_M] += Kd_MtAp; //1400
//      Tb_Mt[indv][I_PRIRESDACAMT_M] += Kd_MtAv;//1460
//      Tb_Mt[indv][I_AFTRESDACAMT_M] += Kd_MtAp;//
//      Tb_Mt[indv][I_PRIRESFINAMT_M] += Kd_MtAv;//1450
//      Tb_Mt[indv][I_AFTRESFINAMT_M] += Kd_MtAp;
//      pris = 1;
//      break;
//
//    // Résultat Tech. + Financier
//    // acceptation
//    case 1340 :
//    case 1350 :
//    case 1360 :     //[014] Int. Reçu/Solde technique
//    // retro
//    case 2340 :
//    case 2350 :
//    case 2360 :     //[014] Int. Reçu/Solde technique
//      Tb_Mt[indv][I_PRIRESDACAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESDACAMT_M] += Kd_MtAp;
//      Tb_Mt[indv][I_PRIRESFINAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESFINAMT_M] += Kd_MtAp;
//      pris = 1;
//      break;
//    // Résultat Tech. + FIN + VOBA + CNA [07]
//    // acceptation
//    case 1163 :
//    case 1164 :
//    case 1183 :
//    case 1184 :
//    case 1193 :
//    case 1194 :
//    // retro [02]
//    case 2163 :     //[07]
//    case 2164 :     //[07]
//    case 2183 :
//    case 2184 :
//    case 2193 :
//    case 2194 :
//      Tb_Mt[indv][I_PRIRESDACAMT_M] += Kd_MtAv;
//      Tb_Mt[indv][I_AFTRESDACAMT_M] += Kd_MtAp;
//      pris = 1;
//      break;
//    } //Fin FOR
//		}
		
    // gestion des motifs depassement du seuil au niveau ACMTRS
    if (pris == 1)
    {
      if (strcmp(ptb_InRec_Cur[TLIFEST_ORICOD_LS], "ARRETE STAT") == 0)
      {
        Tb_Diff[indv][0] += (Kd_MtAp - Kd_MtAv);                        // stock diff AS
      }

      if ( (strcmp(ptb_InRec_Cur[TLIFEST_ORICOD_LS], "CNA AUTO") == 0) ||
           (strcmp(ptb_InRec_Cur[TLIFEST_ORICOD_LS], "CNA AUTO 5") == 0) ) // [013]
      {
        Tb_Diff[indv][1] += (Kd_MtAp - Kd_MtAv);                        // stock diff CNA
      }

      if (strcmp(ptb_InRec_Cur[TLIFEST_ORICOD_LS], "RETRO INTERNE") == 0)
      {
        Tb_Diff[indv][2] += (Kd_MtAp - Kd_MtAv);                        // stock diff RETRO INTERNE
      }

      if (strcmp(ptb_InRec_Cur[TLIFEST_ORICOD_LS], "RETRO AUTO") == 0)
      {
        Tb_Diff[indv][3] += (Kd_MtAp - Kd_MtAv);                        // stock diff RETRO AUTO
      }

      if (fabs(Tb_Diff[indv][0]) > fabs(Tb_Diff[indv][1]) ||              // si diff AS > diff CNA
          fabs(Tb_Diff[indv][0]) > fabs(Tb_Diff[indv][2]) ||              // si diff AS > diff RETRO INT
          fabs(Tb_Diff[indv][0]) > fabs(Tb_Diff[indv][3]))                // si diff AS > diff RETRO AUT
      {
        Tb_Diff[indv][7]  = 0;                                          // 0 = AS
        Tb_Diff[indv][4]  = Tb_Diff[indv][0];                           // max diff pour AC
      }

      if (fabs(Tb_Diff[indv][1]) > fabs(Tb_Diff[indv][0]) ||              // si diff CNA > diff AS
          fabs(Tb_Diff[indv][1]) > fabs(Tb_Diff[indv][2]) ||              // si diff AS > diff RETRO INT
          fabs(Tb_Diff[indv][1]) > fabs(Tb_Diff[indv][3]))                // si diff AS > diff RETRO AUT
      {
        Tb_Diff[indv][7]  = 1;                                          // 1 = CNA
        Tb_Diff[indv][4]  = Tb_Diff[indv][1];                           // max diff pour AC
      }

      if (fabs(Tb_Diff[indv][2]) > fabs(Tb_Diff[indv][0]) ||              // si diff RETRO > diff AS
          fabs(Tb_Diff[indv][2]) > fabs(Tb_Diff[indv][1]) ||              // si diff AS > diff RETRO INT
          fabs(Tb_Diff[indv][2]) > fabs(Tb_Diff[indv][3]))                // si diff AS > diff RETRO AUT
      {
        Tb_Diff[indv][7]  = 2;                                          // 2 = RETRO INT
        Tb_Diff[indv][4]  = Tb_Diff[indv][2];                           // max diff pour ac
      }

      if (fabs(Tb_Diff[indv][3]) > fabs(Tb_Diff[indv][0]) ||              // si diff RETRO > diff AS
          fabs(Tb_Diff[indv][3]) > fabs(Tb_Diff[indv][1]) ||              // si diff AS > diff RETRO INT
          fabs(Tb_Diff[indv][3]) > fabs(Tb_Diff[indv][2]))                // si diff AS > diff RETRO AUT
      {
        Tb_Diff[indv][7]  = 3;                                          // 3 = RETRO AUT
        Tb_Diff[indv][4]  = Tb_Diff[indv][3];                           // max diff pour ac
      }

      if (fabs(Tb_Diff[indv][4]) > fabs(Tb_Diff[9][4]))                   // si MAX diff ac > max diff ac save
      {
        Tb_Diff[9][7]  = Tb_Diff[indv][7];                              // save code motif de max diff
        Tb_Diff[9][4]  = Tb_Diff[indv][4];                              // save max diff
        Tb_Diff[9][5]  = Acy[indv];                                     // save AC ayant max diff
      }
    }
  }


  return OK;
}



/*==============================================================================
objet : fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul annee bilan
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt3Acy(char **ptb_InRec_Cur)
{
  if  ( Acys != Acy[indv] )
  {
    indv ++;
    Acy[indv] = atoi(ptb_InRec_Cur[TLIFEST_ACY_NF]);
    Acys = atoi(ptb_InRec_Cur[TLIFEST_ACY_NF]);
  }

  return OK;
}



/*==========================================================================
Objet :    Recherche un pilotage dans la table charge en memoire
Nom:       n_RechPilot
Parametres: la prevision recherche
Retour:    indice de le ligne du pilotage cherchee
           -1 si non trouvee
Modifications : 
          [026] Erreur de tri entre le pilote et le Lifest => suppression de
                l'utilisation de l'indice dans la boucle
===========================================================================*/
int n_RechPilot (char *sz_ctr, char *sz_sec, char *sz_acy, int n_indice)
{
  int i ;

  for (i = 0; i < Kn_NbLigPilot; i++)                   //[026]
  {
    if ( strcmp(sz_ctr, Kbd_PILOT[i].CTR_NF) == 0  &&
         ( atoi(sz_sec) == Kbd_PILOT[i].SEC_NF ) &&
         ( atoi(sz_acy) == Kbd_PILOT[i].ACY_NF  ) )
    {
      return i ;
    }
  }

  return -1 ;
}



/*==========================================================================
Objet : Recherche un pilotage dans la table charge en memoire
Nom:    n_RechSeuil
Parametres: la prevision recherche
Retour: indice de le ligne du pilotage cherchee
        -1 si non trouvee
===========================================================================*/
int n_RechSeuil (char **ptb_InRec_Cur, int n_indix)
{
  int x ;

  for (x = n_indix; x < Kn_NbLigSeuil; x++)
  {
    if ( (atoi(ptb_InRec_Cur[TLIFEST_SSD_CF]) == Kbd_SEUIL[x].SSD_CF)    &&
         (atoi(ptb_InRec_Cur[TLIFEST_ESB_CF]) == Kbd_SEUIL[x].ESB_CF)    )
    {
      return x ;
    }
  }

  return -1 ;
}



/*==============================================================================
objet : Affiche une structure de type T_LIFDRI_ALL 
==============================================================================*/
void affiche (T_LIFDRI_ALL  *bd_Lu)                                           //[026] Modification du type de la structure T_LIFDRI => T_LIFDRI_ALL
{
  printf("ctr=|%s|   sec=|%d|  uwy=|%d|   autupd=|%d|   comacc=|%d| \n",
         bd_Lu->CTR_NF,
         bd_Lu->SEC_NF,
         bd_Lu->UWY_NF,
         bd_Lu->AUTUPD_B,
         bd_Lu->COMACC_B );
}



/*==========================================================================
Objet : Copie le contenu du fichier en entree dans un tableau
Nom:    n_ChargerPilot
Parametres: Le pointeur du fichier
            Le tableau de structures
Retour: 0
===========================================================================*/
int n_ChargerPilot()
{
  int n_EOF = 0;
  T_LIFDRI_ALL  bd_Lu;                                                      //[026] Modification du type de la structure T_LIFDRI => T_LIFDRI_ALL
  char MsgAno[300];

  DEBUT_FCT("n_ChargerPilot");

  if ( n_OpenFileAppl ("ESTC7610_I3", "rb", &Kp_PilotFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  Kn_NbLigPilot = 0;

  // Tant que la fin de fichier n'est pas atteinte,...
  while ( n_EOF == 0 )
  {
    // ... lecture d'une ligne dans le fichier.
    if ( fread(&bd_Lu, sizeof(T_LIFDRI_ALL ), 1, Kp_PilotFile) <= 0 )     //[026] Modification du type de la structure T_LIFDRI => T_LIFDRI_ALL
      // Fin de fichier, mise a jour du flag
      n_EOF = 1;
    else
    {
      // Ecriture dans log si depassement du tableau
      if ( Kn_NbLigPilot >= NB_MAX_PILOT)
      {
        sprintf(MsgAno, "The number of Driving records NB_MAX_PILOT (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
                bd_Lu.CTR_NF,
                bd_Lu.SEC_NF,
                bd_Lu.UWY_NF);
        n_WriteAno(MsgAno);
        // [015]
        printf("The number of Driving records NB_MAX_PILOT (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
               bd_Lu.CTR_NF,
               bd_Lu.SEC_NF,
               bd_Lu.UWY_NF);
        RETURN_VAL(0);
      }

      // Enregistrement ecrit dans le tableau
      Kbd_PILOT[Kn_NbLigPilot++] = bd_Lu;
    }
  }

  RETURN_VAL (0);
}



/*==========================================================================
Objet :     Copie le contenu du fichier en entree dans un tableau
Nom:        n_ChargerSeuil
Parametres: Le pointeur du fichier
            Le tableau de structures
Retour: 0
===========================================================================*/
int n_ChargerSeuil()
{
  int nx_EOF = 0;
  T_LIFTHR bd_Lus;
  char MsgAno[300];

  DEBUT_FCT("n_ChargerSeuil");

  if ( n_OpenFileAppl ("ESTC7610_I4", "rb", &Kp_SeuilFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  Kn_NbLigSeuil = 0;

  // Tant que la fin de fichier n'est pas atteinte,...
  while ( nx_EOF == 0 )
  {
    // ... lecture d'une ligne dans le fichier.
    if ( fread(&bd_Lus, sizeof(T_LIFTHR), 1, Kp_SeuilFile) <= 0 )
      // Fin de fichier, mise a jour du flag
      nx_EOF = 1;
    else
    {
      // Ecriture dans log si depassement du tableau
      if ( Kn_NbLigSeuil >= NB_MAX_SEUIL)
      {
        sprintf(MsgAno, "The number of Driving records NB_MAX_SEUIL (/SSD %d /ESB %d /CUR %s) overflows the program's storage capacity",
                bd_Lus.SSD_CF,
                bd_Lus.ESB_CF,
                bd_Lus.CUR_CF);
        n_WriteAno(MsgAno);
        // [015]
        printf("The number of Driving records NB_MAX_SEUIL (/SSD %d /ESB %d /CUR %s) overflows the program's storage capacity",
               bd_Lus.SSD_CF,
               bd_Lus.ESB_CF,
               bd_Lus.CUR_CF);

        RETURN_VAL(0);
      }

      // Enregistrement ecrit dans le tableau
      Kbd_SEUIL[Kn_NbLigSeuil++] = bd_Lus;
    }
  }
  RETURN_VAL (0);
}

// ----------------------------------------------------------------------------
// objet:  Lit le fichier Kp_SubTRSBaseFile et les met en memoire
// ----------------------------------------------------------------------------

int n_ChargerTsubTRSBaseDettrncod(FILE *Kp_SubTRSBaseFile)
{
       int n_EOF = 0;
        T_SUBTRSBASE bd_Lu;

        DEBUT_FCT("ChargerTsubTRSBase"); 

           /* Tant que la fin de fichier n'est pas atteinte,... */
        while ( n_EOF == 0 )
        {
                /* ... lecture d'une ligne dans le fichier. */
                if (fread(&bd_Lu,sizeof(T_SUBTRSBASE),1,Kp_SubTRSBaseFile) <= 0 )
                        /* Fin de fichier, mise a jour du flag */
                      n_EOF = 1;
                else {
                        /* Ecriture dans log si depassement du tableau */
                       if ( Kn_NbLigSubTRSBasefile >= 1500) {
                                  return -1;
                        }
                        
                        
                    /* Enregistrement ecrit dans le tableau */   	 
                      Kbd_SubTRSBase[Kn_NbLigSubTRSBasefile] = bd_Lu;
                      printf("%d %d %s\n", Kbd_SubTRSBase[Kn_NbLigSubTRSBasefile].PRS_CF, Kbd_SubTRSBase[Kn_NbLigSubTRSBasefile].ACMTRS_NT, Kbd_SubTRSBase[Kn_NbLigSubTRSBasefile].DETTRNCOD_CF);
                      Kn_NbLigSubTRSBasefile++; 
                     
                }
        }
         return 0;
}

/*==========================================================================
     Objet :    Recuperer une structure T_SUBTRSBase grace au dettrncod

     Nom:       n_FindTsubTRSBaseDettrncod

     Parametres:
                pointure sur stucture T_DETTRN_ACMTR_Base
                Dettrncod
          

     Retour:    0/-1
===========================================================================*/
int n_FindTsubTRSBaseDettrncod(T_DETTRN_ACMTRS_Base *pbd_lu,int Dettrncod)
{
       int i,j  = 0;
       pbd_lu->nb_Dettrn=0;

       for(i=0;i<Kn_NbLigSubTRSBasefile-1;i++)
       {    
        	 if((Kbd_SubTRSBase[i].PRS_CF == 569)&&(Dettrncod== atoi(Kbd_SubTRSBase[i].DETTRNCOD_CF)))
					 {
							pbd_lu->Adjsig[j]=Kbd_SubTRSBase[i].ADJSIG_B;
							//sprintf(pbd_lu->DETTRN[j],"%s",Kbd_SubTRSBase[i].DETTRNCOD_CF);
							pbd_lu->DETTRN[j]=Kbd_SubTRSBase[i].DETTRNCOD_CF;
							pbd_lu->ACMTRS[j]=Kbd_SubTRSBase[i].ACMTRS_NT;

							pbd_lu->nb_Dettrn++;
							j++;
        	}
       }
       if (j==0)
           return -1;
       return 0;
}

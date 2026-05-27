/*==============================================================================
nom de l'application          : Calcul des SNEMs
nom du source                 : ESTM1011.c
revision                      : $Revision:   1.5  $
date de creation              : 22/07/1997
auteur                        : O.LE ROY
references des specifications : ESTID01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
   En entree :  perimetre PERICASE des SNEMs,
                fichier de travail des SNEMs
    fichier des taux de change
    DLTOTGTAA
    DLRGTAA
   En sortie : FT des SNEMs
               delta GT SNEMs
------------------------------------------------------------------------------
historique des modifications :
 <jj/mm/aaaa>   <auteur>  <description de la modification>
  31/01/2003     J. Ribot  ajout colonne retintamt_m sur fichier en sortie
  01/02/2016     Florent   ajout 30 colonnes pour format GT à 71 colonnes
==============================================================================*/
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include <ESTC1016.h>

/*----------------------*/
/* variables de travail */
/*----------------------*/
int   Kb_FTparticipe;

char  Ksz_MessageErr[256], /* Message d'erreur */
      Ksz_SNEMFILCOD[9],
      Ksz_SNEMCOD[9],
      Ksz_CLODAT[9];

double  Kd_SPSAPcomplets,
        Kd_SNEMBP, /* SNEM du bilan precedent */
        Kd_TauxCharges, /* Taux de charges */
        Kd_Premium;

char  Ksz_SNEMBPCUR_CF[3]; /* devise de la SNEM du bilan precedent */

FILE  *Kp_InputFilExc, /* pointeur sur le fichier des cours de change */
      *Kp_OutputFilFTSNEM, /* pointeur sur le fichier Fichier de travail en sortie */
      *Kp_OutputFilGTSNEM; /* pointeur sur le fichier GT SNEM en sortie */

T_RUPTURE_VAR Kbd_RuptPER;  /* rupture sur le perimetre */
T_RUPTURE_SYNC_VAR  Kbd_SyncFTSNEM,/* synchro fichier de travail-perimetre*/
                    Kbd_SyncGTSNEM,/* synchro GT SNEM -perimetre*/
                    Kbd_SyncDLTOTGTAA,/* synchro  GT Estimations -perimetre*/
                    Kbd_SyncDLRGTAA,/* synchro GT Retro interne -perimetre*/
                    Kbd_SyncFLOARAT;/* synchro FLOARAT - perimetre */

/*-----------------------------------------*/
/* declaration des prototypes de fonctions */
/*-----------------------------------------*/

int n_InitPER(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePER(char **pbd_InRec_Cur);

int n_InitFTSNEM(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ConditionSyncFTSNEM(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneFTSNEM(char **ptb_InRecOwner, char **pbd_InRecChild) ;
int n_ActionPereSansFilsFTSNEM(char **ptb_InRecOwner);

int n_InitGTSNEM(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ConditionSyncGTSNEM(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneGTSNEM(char **ptb_InRecOwner, char **pbd_InRecChild) ;

int n_InitDLTOTGTAA(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ConditionSyncDLTOTGTAA(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneDLTOTGTAA(char **ptb_InRecOwner, char **pbd_InRecChild) ;

int n_InitDLRGTAA(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ConditionSyncDLRGTAA(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneDLRGTAA(char **ptb_InRecOwner, char **pbd_InRecChild) ;

int n_InitFLOARAT(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ConditionSyncFLOARAT(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneFLOARAT(char **ptb_InRecOwner, char **pbd_InRecChild) ;


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm (argc  , argv) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* initialisation des postes comptables SNEMestimee et SNEMfiliale */

  strcpy(Ksz_SNEMFILCOD, "11423102");
  strcpy(Ksz_SNEMCOD, "11423002");


  /* Recuperation des parametres d'entree */
  strcpy(Ksz_CLODAT, psz_GetCharArgv(1));

  /* ouverture du fichier en entree des cours de change FCURQUOT */
  if ( n_OpenFileAppl ( "ESTM1011_I1", "rb", &Kp_InputFilExc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture des fichiers en sortie */
  if ( n_OpenFileAppl ("ESTM1011_O1", "wt", &Kp_OutputFilFTSNEM) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTM1011_O2", "wt", &Kp_OutputFilGTSNEM) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_RuptPER */
  if ( n_InitPER(&Kbd_RuptPER) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_SyncFTSNEM */
  if ( n_InitFTSNEM(&Kbd_SyncFTSNEM) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_SyncGTSNEM */
  if ( n_InitGTSNEM(&Kbd_SyncGTSNEM) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_SyncDLTOTGTAA */
  if ( n_InitDLTOTGTAA(&Kbd_SyncDLTOTGTAA) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_SyncDLRGTAA */
  if ( n_InitDLRGTAA(&Kbd_SyncDLRGTAA) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_SyncFLOARAT */
  if ( n_InitFLOARAT(&Kbd_SyncFLOARAT) )
    ExitPgm ( ERR_XX , "" );

  /* lancement du traitement du fichier */
  if ( n_ProcessingRuptureVar (&Kbd_RuptPER) == ERR )
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I1", &(Kp_InputFilExc)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I2", &(Kbd_RuptPER.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I3", &(Kbd_SyncFTSNEM.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I4", &(Kbd_SyncGTSNEM.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I5", &(Kbd_SyncDLTOTGTAA.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I6", &(Kbd_SyncDLRGTAA.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_I7", &(Kbd_SyncFLOARAT.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_O1", &Kp_OutputFilFTSNEM))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTM1011_O2", &Kp_OutputFilGTSNEM))
    ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );

  exit(0) ;

}


/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du
  fichier maitre.

retour :
  0
==============================================================================*/
int n_InitPER(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPER");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTM1011_I2", "rt", &(pbd_Rupt->pf_InputFil)))
    RETURN_VAL (ERR);

  pbd_Rupt->n_NbRupture = 0  ;
  pbd_Rupt->n_ActionLigne = n_ActionLignePER ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne du PERIMETRE

retour :
  0 ----> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePER(char **ptb_InRec_Cur)
{
  char    sz_Bilan[5],
          sz_Mois[3],
          MsgAno[250];

  double  d_Ratio = 1,
          d_Aliment;

  int n_Bilan, n_Age;

  double d_CoeffSinistre[15],
         d_CoeffPrime[15],
         d_SNEMBPconv,
         d_PrimeSNEM3112,
         d_SinistreSNEM3112,
         d_deltaSNEM,
         d_SNEM3112,
         d_SNEM,
         d_Mois;

  DEBUT_FCT("n_ActionLignePER");

  Kb_FTparticipe = 0;
  Kd_SPSAPcomplets = 0;
  Kd_SNEMBP = 0;

  /* Recherche du SPSAPcomplets et eventuelle annulation de SP incomplets */
  Kd_Premium = 0;
  n_ProcessingRuptureSyncVar(&Kbd_SyncGTSNEM, ptb_InRec_Cur);

  /* Recherche de la SNEM Fin de bilan predent */
  n_ProcessingRuptureSyncVar(&Kbd_SyncFTSNEM, ptb_InRec_Cur);

  /* Recherche d'un eventuel Taux de change */
  Kd_TauxCharges = 0;
  n_ProcessingRuptureSyncVar(&Kbd_SyncFLOARAT, ptb_InRec_Cur);


  d_SNEMBPconv = Kd_SNEMBP;

  if (Kb_FTparticipe != 0) {

    if (strcmp(ptb_InRec_Cur[PER_EGPCUR_CF], Ksz_SNEMBPCUR_CF) != 0) {
      d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ),
                           atoi(ptb_InRec_Cur[PER_UWY_NF]) - 1 , Ksz_SNEMBPCUR_CF,
                           ptb_InRec_Cur[PER_EGPCUR_CF] ) ;

      /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
      if ( d_Ratio < 0 )
      {
        sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
                 ptb_InRec_Cur[PER_EGPCUR_CF], Ksz_SNEMBPCUR_CF,
                 ptb_InRec_Cur[PER_CTR_NF],  ptb_InRec_Cur[PER_END_NT],
                 ptb_InRec_Cur[PER_SEC_NF],  ptb_InRec_Cur[PER_UWY_NF],
                 ptb_InRec_Cur[PER_UW_NT] ) ;
        n_WriteAno( MsgAno ) ;

        /* On ne calcule pas la SNEM */
        RETURN_VAL(0);
      }
      else    d_SNEMBPconv = Kd_SNEMBP * d_Ratio ;
    }
  }

  /*-------------------*/
  /* Calcul de la SNEM */
  /*-------------------*/
  /* determination de l'age de l'affaire et des coefficients de prime et sinistre relatifs à cet age */

  strncpy(sz_Bilan, Ksz_CLODAT, 4);
  n_Bilan = atoi(sz_Bilan);
  n_Age = n_Bilan - atoi(ptb_InRec_Cur[PER_UWY_NF]);

  d_CoeffSinistre[0] = 0;
  d_CoeffSinistre[1] = 0;
  d_CoeffSinistre[2] = 3.40;
  d_CoeffSinistre[3] = 2.00;
  d_CoeffSinistre[4] = 1.40;
  d_CoeffSinistre[5] = 1.00;
  d_CoeffSinistre[6] = 0.70;
  d_CoeffSinistre[7] = 0.50;
  d_CoeffSinistre[8] = 0.35;
  d_CoeffSinistre[9] = 0.25;
  d_CoeffSinistre[10] = 0.20;
  d_CoeffSinistre[11] = 0.15;
  d_CoeffSinistre[12] = 0.10;
  d_CoeffSinistre[13] = 0.05;
  d_CoeffSinistre[14] = 0;


  d_CoeffPrime[0] = 1;
  d_CoeffPrime[1] = 1;
  d_CoeffPrime[2] = 0.95;
  d_CoeffPrime[3] = 0.85;
  d_CoeffPrime[4] = 0.75;
  d_CoeffPrime[5] = 0.65;
  d_CoeffPrime[6] = 0.55;
  d_CoeffPrime[7] = 0.45;
  d_CoeffPrime[8] = 0.35;
  d_CoeffPrime[9] = 0.25;
  d_CoeffPrime[10] = 0.20;
  d_CoeffPrime[11] = 0.15;
  d_CoeffPrime[12] = 0.10;
  d_CoeffPrime[13] = 0.05;
  d_CoeffPrime[14] = 0;

  /* prise en compte du decalage*/
  /*
  ** Evol SNEM / Montagnac(4/5/99) : Changement du calcul de l'aliment
  */
  if (n_Age == 0)
    d_Aliment = (12 + atof(ptb_InRec_Cur[PER_DIFMTH_NF])) / 12 * ((1 - Kd_TauxCharges) * Kd_Premium);
  else
    d_Aliment = (1 - Kd_TauxCharges) * Kd_Premium;

  if (n_Age <= 14) {
    /* Calcul de la valeur de la SNEM au 31/12 du bilan */

    d_PrimeSNEM3112 = (-1) * d_Aliment * d_CoeffPrime[n_Age];
    d_SinistreSNEM3112 = Kd_SPSAPcomplets * d_CoeffSinistre[n_Age];

    if (d_PrimeSNEM3112 < d_SinistreSNEM3112)
      d_SNEM3112 = d_PrimeSNEM3112;
    else
      d_SNEM3112 = d_SinistreSNEM3112;

    /* Calcul de la difference de SNEM entre les 2 bilans */
    d_deltaSNEM = d_SNEM3112 - d_SNEMBPconv;
    /* Mensualisation : s'il s'agit d'une FAC avec exercice=bilan, on ne mensualise pas */
    if (n_Age != 0) {
      /* modif du 6-2-2002 a la demande de florence car pb snem sur sorema et comportement different entre        */
      strncpy(sz_Mois, Ksz_CLODAT + 4, 2);
      d_Mois = atoi(sz_Mois);

      d_deltaSNEM = d_Mois / 12 * d_deltaSNEM;
    }
    /* valeur de la SNEM pour le libelle d'inventaire */
    d_SNEM = d_SNEMBPconv + d_deltaSNEM;
    /* Emission d'une nouvelle ligne de FTSNEM */
    fprintf(Kp_OutputFilFTSNEM, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%-.3lf~%s~%-.3lf~%-.3lf~%s~%-.8lf\n",
            ptb_InRec_Cur[PER_SSD_CF],
            ptb_InRec_Cur[PER_ACCESB_CF],
            Ksz_CLODAT,
            ptb_InRec_Cur[PER_CTR_NF],
            ptb_InRec_Cur[PER_END_NT],
            ptb_InRec_Cur[PER_SEC_NF],
            ptb_InRec_Cur[PER_UWY_NF],
            ptb_InRec_Cur[PER_UW_NT],
            ptb_InRec_Cur[PER_SCOEGP_M],
            ptb_InRec_Cur[PER_EGPCUR_CF],
            Kd_SPSAPcomplets,
            ptb_InRec_Cur[PER_DIFMTH_NF],
            Kd_SNEMBP,
            Ksz_SNEMBPCUR_CF,
            d_SNEM3112,
            d_SNEM,
            ptb_InRec_Cur[PER_CTRRET_B],
            Kd_TauxCharges);

    /* Emission d'une ligne GTSNEM */
    if (d_SNEM != 0) {
      fprintf( Kp_OutputFilGTSNEM, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~%.3lf~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n",
               ptb_InRec_Cur[PER_SSD_CF] /* 0 */,
               ptb_InRec_Cur[PER_ACCESB_CF] /* 1 */,
               Ksz_CLODAT,
               Ksz_CLODAT + 4,
               Ksz_CLODAT + 6,
               Ksz_SNEMCOD,
               ptb_InRec_Cur[PER_CTR_NF] /* 7 */,
               ptb_InRec_Cur[PER_END_NT] /* 8 */,
               ptb_InRec_Cur[PER_SEC_NF] /* 9 */,
               ptb_InRec_Cur[PER_UWY_NF] /* 10 */,
               ptb_InRec_Cur[PER_UW_NT] /* 11 */,
               ptb_InRec_Cur[PER_UWY_NF] /* 10 */,
               Ksz_CLODAT,
               Ksz_CLODAT + 4,
               Ksz_CLODAT + 4,
               ptb_InRec_Cur[PER_EGPCUR_CF] /* 17 */,
               d_SNEM,
               ptb_InRec_Cur[PER_CED_NF] /* 19 */,
               ptb_InRec_Cur[PER_PRD_NF] /* 20 */,
               ptb_InRec_Cur[PER_GENPRMPAY_NF] /* 21 */,
               ptb_InRec_Cur[PER_GANPAYORD_NT] /* 22 */,
               0.000);
    }
  }

  /* Annulations du DLTOTGTAA */
  n_ProcessingRuptureSyncVar(&Kbd_SyncDLTOTGTAA, ptb_InRec_Cur);

  /* Annulations du DLRGTAA */
  n_ProcessingRuptureSyncVar(&Kbd_SyncDLRGTAA, ptb_InRec_Cur);

  RETURN_VAL (0);
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du PERIMETRE avec l'esclave FTSNEM

retour :
  0
==============================================================================*/
int n_InitFTSNEM(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitFTSNEM");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTM1011_I3", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync  = n_ConditionSyncFTSNEM ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne     = n_ActionLigneFTSNEM ;

  pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsFTSNEM ;

  pbd_Rupt->c_Separ         = '~' ;

  RETURN_VAL (0);
}

/*==============================================================================
objet :
  fonction de test de synchro

retour :
  0 ---> synchro
  sinon, non trouve
==============================================================================*/
int n_ConditionSyncFTSNEM(
  char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
  char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
)
{
  static  int ret;

  DEBUT_FCT("n_ConditionSyncFTSNEM");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[WFS_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[WFS_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[WFS_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[WFS_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[WFS_UW_NT])) != 0) return ret;
  RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction d'action pour chaque ligne du fichier de travail

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionLigneFTSNEM(
  char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
  char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
)
{
  int n_Bilan;
  char  sz_Bilan[5],
        sz_LastBilan[9];

  DEBUT_FCT("n_ActionLigneFTSNEM");

  strncpy(sz_Bilan, Ksz_CLODAT, 4);
  sz_Bilan[4] = 0;
  n_Bilan = atoi(sz_Bilan);
  n_Bilan = n_Bilan - 1;
  sprintf(sz_LastBilan, "%4d1231", n_Bilan);

  if (strcmp(pbd_InRecChild[WFS_CLODAT_D], sz_LastBilan) == 0) {
    /* On considere ici que le FT participe vraiment */
    Kb_FTparticipe = 1;
    Kd_SNEMBP = atof(pbd_InRecChild[WFS_SNEMCLODAT_M]);
    strcpy(Ksz_SNEMBPCUR_CF, pbd_InRecChild[WFS_EGPCUR_CF]);
    /* printf("SNEM BP %-.3lf",Kd_SNEMBP); */
  }

  RETURN_VAL (0);
}

/*==============================================================================
objet :
        Si aucune ligne du fichier de travail n'est identifiee dans le perimetre

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionPereSansFilsFTSNEM(char **ptb_InRecOwner)
{
  DEBUT_FCT("n_PereSansFilsFTSNEM");
  RETURN_VAL (0);
}


/*==============================================================================
objet :
 Initialisation de la synchronisation du PERIMETRE avec l'esclave GTSNEM

retour :
 0
==============================================================================*/
int n_InitGTSNEM(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitGTSNEM");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTM1011_I4", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGTSNEM ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGTSNEM ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
  objet :
  fonction de test de synchro du GT SNEM avec le perimetre

retour :
 0 ---> synchro
 sinon, non trouve
==============================================================================*/
int n_ConditionSyncGTSNEM(char **pbd_InRecOwner, char **pbd_InRecChild)
{
  static  int ret;

  DEBUT_FCT("n_ConditionSyncGTSNEM");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT])) != 0) return ret;
  RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction d'action pour chaque ligne du fichier de travail

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionLigneGTSNEM(char **ptb_InRecOwner, char **pbd_InRecChild)
{
  double d_Montant;
  char sz_Montant[20],
       sz_TRNCOD_CF[9];

  DEBUT_FCT("n_ActionLigneGTSNEM");

  /*
  ** Evol SNEM / Montagnac(4/5/99) : Si on a un autre poste que 10000,
  ** la prime utilisée pour le calcul de l'aliment vaut 0
  */
  if (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10000") == 0)
    Kd_Premium = atof(pbd_InRecChild[GTE_ACMAMT_M]);

  if ((ptb_InRecOwner[PER_CTRNAT_CT][0] == 'F') &&
      (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10030") == 0 ||
       strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10130") == 0 ||
       strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10430") == 0)) {
    /* Annulations FACs FAR1,2 PNA cedantes */

    d_Montant = atof(pbd_InRecChild[GTE_ACMAMT_M]);
    d_Montant = d_Montant * (-1);
    sprintf(sz_Montant, "%-.3lf", d_Montant);
    pbd_InRecChild[GT_AMT_M] = sz_Montant;
    pbd_InRecChild[GT_CUR_CF] = pbd_InRecChild[GTE_ACMCUR_CF];

    if  (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10030") == 0)
      strcpy(sz_TRNCOD_CF, "11410006");

    if  (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10130") == 0)
      strcpy(sz_TRNCOD_CF, "11430006");

    if  (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "10430") == 0)
      strcpy(sz_TRNCOD_CF, "11436006");

    pbd_InRecChild[GT_TRNCOD_CF] = sz_TRNCOD_CF;

    if (ptb_InRecOwner[PER_CTRRET_B][0] == '1')
      pbd_InRecChild[GT_TRNCOD_CF] = Ksz_SNEMFILCOD;

    fprintf( Kp_OutputFilGTSNEM, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~%.3lf\n",
             pbd_InRecChild[GT_SSD_CF] /* 0 */,
             pbd_InRecChild[GT_ESB_CF] /* 1 */,
             Ksz_CLODAT,
             Ksz_CLODAT + 4,
             Ksz_CLODAT + 6,
             pbd_InRecChild[GT_TRNCOD_CF] /* 5 */,
             pbd_InRecChild[GT_CTR_NF] /* 7 */,
             pbd_InRecChild[GT_END_NT] /* 8 */,
             pbd_InRecChild[GT_SEC_NF] /* 9 */,
             pbd_InRecChild[GT_UWY_NF] /* 10 */,
             pbd_InRecChild[GT_UW_NT] /* 11 */,
             pbd_InRecChild[GT_UWY_NF] /* 12 */,
             Ksz_CLODAT,
             Ksz_CLODAT + 4,
             Ksz_CLODAT + 4,
             pbd_InRecChild[GT_CUR_CF] /* 17 */,
             pbd_InRecChild[GT_AMT_M] /* 18 */,
             pbd_InRecChild[GT_CED_NF] /* 19 */,
             pbd_InRecChild[GT_BRK_NF] /* 20 */,
             pbd_InRecChild[GT_PAY_NF] /* 21 */,
             pbd_InRecChild[GT_KEY_NF] /* 22 */,
             0.000);

  }

  if (
    (
      ( strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "-20000") == 0)
      &&
      ptb_InRecOwner[PER_CTRNAT_CT][0] == 'P'
    )
    ||
    (
      (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "-20000") == 0)
      &&
      ptb_InRecOwner[PER_CTRNAT_CT][0] == 'N'
      &&
      ( (atoi( ptb_InRecOwner[PER_NAT_CF] ) == 40) || (atoi( ptb_InRecOwner[PER_NAT_CF] ) == 41) )
    )
    ||
    (
      (strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "20000") == 0)
      &&
      (
        (
          ptb_InRecOwner[PER_CTRNAT_CT][0] == 'N'
          &&
          (atoi( ptb_InRecOwner[PER_NAT_CF] ) != 40)   // Ajout OG 19/12/02
          &&
          (atoi( ptb_InRecOwner[PER_NAT_CF] ) != 41)   // Ajout OG 19/12/02
        )
        || ptb_InRecOwner[PER_CTRNAT_CT][0] == 'F'
      )
    )
  )
  {
    /* SPSAPcomplet */
    Kd_SPSAPcomplets = atof(pbd_InRecChild[GTE_ACMAMT_M]);
  }

  /**********************************************************/
  /* Modif du 23/12/1998 Yves Bourdaillet                   */
  /* On prend en compte le poste de regroupement 28030      */
  /* On blanchit les positions cedantes en 11423102         */
  /**********************************************************/

  if ((strcmp(pbd_InRecChild[GTE_ACMTRS_NT], "28030") == 0) && (ptb_InRecOwner[PER_CTRNAT_CT][0] == 'N'))  {

    d_Montant = atof(pbd_InRecChild[GTE_ACMAMT_M]);
    d_Montant = d_Montant * (-1);
    sprintf(sz_Montant, "%-.3lf", d_Montant);
    pbd_InRecChild[GT_AMT_M] = sz_Montant;
    pbd_InRecChild[GT_CUR_CF] = pbd_InRecChild[GTE_ACMCUR_CF];

    strcpy(sz_TRNCOD_CF, "11423102");
    pbd_InRecChild[GT_TRNCOD_CF] = sz_TRNCOD_CF;
    fprintf( Kp_OutputFilGTSNEM, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~%.3lf~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n",
             pbd_InRecChild[GT_SSD_CF] /* 0 */,
             pbd_InRecChild[GT_ESB_CF] /* 1 */,
             Ksz_CLODAT,
             Ksz_CLODAT + 4,
             Ksz_CLODAT + 6,
             pbd_InRecChild[GT_TRNCOD_CF] /* 5 */,
             pbd_InRecChild[GT_CTR_NF] /* 7 */,
             pbd_InRecChild[GT_END_NT] /* 8 */,
             pbd_InRecChild[GT_SEC_NF] /* 9 */,
             pbd_InRecChild[GT_UWY_NF] /* 10 */,
             pbd_InRecChild[GT_UW_NT] /* 11 */,
             pbd_InRecChild[GT_UWY_NF] /* 12 */,
             Ksz_CLODAT,
             Ksz_CLODAT + 4,
             Ksz_CLODAT + 4,
             pbd_InRecChild[GT_CUR_CF] /* 17 */,
             pbd_InRecChild[GT_AMT_M] /* 18 */,
             pbd_InRecChild[GT_CED_NF] /* 19 */,
             pbd_InRecChild[GT_BRK_NF] /* 20 */,
             pbd_InRecChild[GT_PAY_NF] /* 21 */,
             pbd_InRecChild[GT_KEY_NF] /* 22 */,
             0.000);
  }
  RETURN_VAL (0);
}

/*==============================================================================
objet :
 Initialisation de la synchronisation du PERIMETRE avec l'esclave DLTOTGTAA

retour :
 0
==============================================================================*/
int n_InitDLTOTGTAA(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitDLTOTGTAA");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTM1011_I5", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncDLTOTGTAA ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne = n_ActionLigneDLTOTGTAA ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet :
 fonction de test de synchro du DLTOTGTAA SNEM avec le perimetre

retour :
 0 ---> synchro
 sinon, non trouve
==============================================================================*/
int n_ConditionSyncDLTOTGTAA(char **pbd_InRecOwner, char **pbd_InRecChild)
{
  static  int ret;

  DEBUT_FCT("n_ConditionSyncDLTOTGTAA");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT])) != 0) return ret;
  RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction d'action pour chaque ligne du fichier de travail

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionLigneDLTOTGTAA(char **ptb_InRecOwner, char **pbd_InRecChild)
{
  double d_Montant;
  char sz_Montant[20];

  DEBUT_FCT("n_ActionLigneDLTOTGTAA");
  if (  (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1141000", 7) == 0) || /* PNAea  */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1143000", 7) == 0) || /* FARea  */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1143600", 7) == 0) || /* FAR2ea */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1149410", 7) == 0)) /* IBNR2e */
  {
    /* printf("n_ActionLigneDLTOTGTAA"); */
    d_Montant = atof(pbd_InRecChild[GTE_AMT_M]);
    d_Montant = d_Montant * (-1);
    sprintf(sz_Montant, "%-.3lf", d_Montant);
    pbd_InRecChild[GT_AMT_M] = sz_Montant;

    n_WriteCols(Kp_OutputFilGTSNEM, pbd_InRecChild, '~', 0);
  }
  RETURN_VAL (0);
}

/*==============================================================================
objet :
 Initialisation de la synchronisation du PERIMETRE avec l'esclave DLRGTAA

retour :
 0
==============================================================================*/
int n_InitDLRGTAA(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitDLRGTAA");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTM1011_I6", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncDLRGTAA ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne = n_ActionLigneDLRGTAA ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet :
 fonction de test de synchro du GT SNEM avec le perimetre

retour :
 0 ---> synchro
 sinon, non trouve
==============================================================================*/
int n_ConditionSyncDLRGTAA(char **pbd_InRecOwner, char **pbd_InRecChild)
{
  static  int ret;

  DEBUT_FCT("n_ConditionSyncDLRGTAA");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT])) != 0) return ret;
  RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction d'action pour chaque ligne du fichier de travail

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionLigneDLRGTAA(char **ptb_InRecOwner, char **pbd_InRecChild)
{
  double d_Montant;
  char sz_Montant[20],
       sz_CTRNCOD_CF[9];
  DEBUT_FCT("n_ActionLigneDLRGTAA");

  if (  (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1141000", 7) == 0) || /* PNAea  */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1143000", 7) == 0) || /* FARea  */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1143600", 7) == 0) || /* FAR2ea */
        (strncmp(pbd_InRecChild[GT_TRNCOD_CF], "1149410", 7) == 0)) /* IBNR2e */
  {
    d_Montant = atof(pbd_InRecChild[GTE_AMT_M]);
    d_Montant = d_Montant * (-1);
    sprintf(sz_Montant, "%-.3lf", d_Montant);
    pbd_InRecChild[GT_AMT_M] = sz_Montant;
    pbd_InRecChild[GT_TRNCOD_CF] = Ksz_SNEMFILCOD;

    /* Remise a zero du poste de contrepartie */
    strcpy(sz_CTRNCOD_CF, "");
    pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_CTRNCOD_CF;

    n_WriteCols(Kp_OutputFilGTSNEM, pbd_InRecChild, '~', 0);
  }
  RETURN_VAL (0);
}

/*==============================================================================
objet :
 Initialisation de la synchronisation du PERIMETRE avec l'esclave FLOARAT

retour :
 0
==============================================================================*/
int n_InitFLOARAT(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitFLOARAT");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTM1011_I7", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncFLOARAT ;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_ActionLigne = n_ActionLigneFLOARAT ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet :
 fonction de test de synchro du GT SNEM avec le perimetre

retour :
 0 ---> synchro
 sinon, non trouve
==============================================================================*/
int n_ConditionSyncFLOARAT(char **pbd_InRecOwner, char **pbd_InRecChild)
{
  static  int ret;

  DEBUT_FCT("n_ConditionSyncFLOARAT");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[LOA_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[LOA_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[LOA_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[LOA_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[LOA_UW_NT])) != 0) return ret;
  RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction d'action pour chaque ligne du fichier de travail

retour :
        0 ---> synchro
        sinon, non trouve
==============================================================================*/
int n_ActionLigneFLOARAT(char **ptb_InRecOwner, char **pbd_InRecChild)
{
  double  d_COMMIS,
          d_OVECOM,
          d_TAX,
          d_BROKER;

  DEBUT_FCT("n_ActionLigneFLOARAT");

  d_COMMIS = (double)atof(pbd_InRecChild[LOA_COMMIS_R]);
  d_OVECOM = (double)atof(pbd_InRecChild[LOA_OVECOM_R]);
  d_TAX = (double)atof(pbd_InRecChild[LOA_TAX_R]);
  d_BROKER = (double)atof(pbd_InRecChild[LOA_BROKER_R]);

  Kd_TauxCharges = d_COMMIS + d_OVECOM + d_TAX + d_BROKER;

  RETURN_VAL (0);
}

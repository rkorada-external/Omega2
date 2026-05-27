/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2307.c
revision                      : $Revision:   1.3  $
date de creation              : 30/09/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Synchronisation du fichier des mouvements retro a 100% en attente
        TOUTTRAA avec le perimetre retrocession - Elimination des mouvements
  pour lesquels le perimetre ne participe pas - Elimination des postes
  provisions - Elimination de la filiale SCOR Vie (4) - Passage au
  format du GT -

  Synchronisation du fichier des mouvements saisis ou calcules en attente
        TOUTTRAI avec le perimetre retrocession - Elimination des mouvements
  pour lesquels le perimetre ne participe pas - Elimination des postes
  provisions - Elimination de la filiale SCOR Vie (4) - Passage au
  format du GT -
------------------------------------------------------------------------------
historique des modifications :
 <jj/mm/aaaa>   <auteur>    <description de la modification>
  30/01/03       J. Ribot   ajout colonne retintamt_m sur fichier en sortie
  06/04/2014     JBG        :spot:25773 Modify void main declaration to int main
  01/02/2016     Florent   ajout 30 colonnes pour format GT à 71 colonnes
=============================================================================*/
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitPER(T_RUPTURE_VAR  *);
static int n_InitTOUTTRAA(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTOUTTRAA(char **, char**);
static int n_ConditionSyncTOUTTRAA(char **, char **);
static int n_ActionLignePER(char **);
static int n_InitTOUTTRAI(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTOUTTRAI(char **, char**);
static int n_ConditionSyncTOUTTRAI(char **, char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_GT_part;
static FILE *Kp_Dettrs;
static FILE *Kp_GT_100;

static T_RUPTURE_VAR   Kbd_RuptPER;
static T_RUPTURE_SYNC_VAR  Kbd_RuptTOUTTRAI;
static T_RUPTURE_SYNC_VAR  Kbd_RuptTOUTTRAA;

static char Ksz_clodat[9];

/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de problme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm (argc  , argv) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2307_O1", "wt", &Kp_GT_100) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2307_O2", "wt", &Kp_GT_part) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2307_I4", "rb", &Kp_Dettrs) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Recuperation du parametre du programme : le libelle d'inventaire */
  sprintf(Ksz_clodat, "%8.8s", psz_GetCharArgv(1));

  /* Initialisation de la variable Kbd_RuptPER  */
  if ( n_InitPER(&Kbd_RuptPER) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la varible Kbd_RuptTOUTTRAA */
  if ( n_InitTOUTTRAA(&Kbd_RuptTOUTTRAA) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la varible Kbd_RuptTOUTTRAI */
  if ( n_InitTOUTTRAI(&Kbd_RuptTOUTTRAI) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* lancement du traitement du fichier maitre */
  if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_O1", &Kp_GT_100) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_O2", &Kp_GT_part) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_I1", &(Kbd_RuptPER.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_I2", &(Kbd_RuptTOUTTRAA.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_I3", &(Kbd_RuptTOUTTRAI.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2307_I4", &Kp_Dettrs) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );

  exit(OK) ;

}

/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
  0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPER(T_RUPTURE_VAR  *pbd_RuptPER)
{
  memset(pbd_RuptPER, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC2307_I1", "rt", &(pbd_RuptPER->pf_InputFil)) == ERR)
    return ERR;

  pbd_RuptPER->n_NbRupture = 0;
  pbd_RuptPER->n_ActionLigne = n_ActionLignePER;
  pbd_RuptPER->c_Separ = SEPARATEUR;

  return OK ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec l'esclave

retour :
  OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitTOUTTRAA(T_RUPTURE_SYNC_VAR  *pbd_RuptTOUTTRAA)
{
  memset( pbd_RuptTOUTTRAA, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl ("ESTC2307_I2", "rt", &(pbd_RuptTOUTTRAA->pf_InputFil)) == ERR)
    return ERR;

  pbd_RuptTOUTTRAA->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_RuptTOUTTRAA->ConditionEndSync  = n_ConditionSyncTOUTTRAA;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_RuptTOUTTRAA->n_ActionLigne     = n_ActionLigneTOUTTRAA;

  pbd_RuptTOUTTRAA->c_Separ = SEPARATEUR;

  return OK ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLigneTOUTTRAA(
  char *tpsz_ReadBufferPER[] ,
  char *tpsz_ReadBufferTOUTTRAA[]
)
{
  char sz_trncod[9];
  short n_type;
  char MsgAno[200];

  strcpy(sz_trncod, tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF]);

  /* recherche du type de poste */
  n_type = n_TypePoste(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF], Kp_Dettrs) ;

  if (n_type != 0) {
    if
    (
      ((
         ( atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 5)
         || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 6)
         || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 7)
         || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 8)

       )
       ||
       ( (n_type != 3) && (n_type != 0) )
      )
      &&
      (n_type != 2))
    {

      /* le suffixe du poste comptable est force a 4 */
      sz_trncod[7] = '4'; //donc RETARDRETINT_B=1

      // ecriture en sortie d'un enregistrement au format du GT 71 colonnes : RETROAUTO=1
      fprintf(Kp_GT_100, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf~~~~~~~~~~~~~~~~~1~~~~0~~~~~~~~~\n",
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SSD_CF],
              "",
              Ksz_clodat,    /* annee libelle d'inventaire */
              Ksz_clodat + 4, /* mois libelle d'inventaire */
              Ksz_clodat + 6, /* jour libelle d'inventaire */
              sz_trncod,
              "",
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CTR_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_END_NT],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SEC_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_UWY_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_UW_NT],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_OCCYEA_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACCYER_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SCOSTRMTH_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SCOENDMTH_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CLM_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACPCUR_CF],
              (-1) * atof(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CED_M]),
              "", /* CED_NF */
              "", /* BRK_NF */
              "", /* PAY_NF */
              "", /* KEY_NF */
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETCTR_NF],
              "0", /* RETEND_NT */
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETSEC_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RTY_NF],
              "1",  /* RETUW_NT */
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_OCCYEA_NF],
              Ksz_clodat,    /* annee libelle d'inventaire */
              Ksz_clodat + 4, /* mois libelle d'inventaire */
              Ksz_clodat + 4, /* mois libelle d'inventaire */
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CLM_NF],
              tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACPCUR_CF],
              (-1) * atof(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CED_M]),
              "",  /* PLC_NT */
              "",  /* RTO_NF */
              "",  /* INT_NF */
              "",  /* RETPAY_NF */
              "", /* RETKEY_NF */
              0.000); /* RETINTAMT_M */
    }
  }/*(n_type != 0)*/
  else
  {
    /*------------------------------------------------------------*/
    /* si le type de poste renvoye par la fonction n_TypePoste    */
    /* est 0 , ca signifie que                                    */
    /* le poste passe en parametre n'a pas ete trouve dans DETTRS */
    /* et dans ce cas une anomalie est generee                    */
    /*------------------------------------------------------------*/
    if (n_type == 0)
    {
      sprintf(MsgAno, "The transaction code %s could not be found in table TDETTRS", tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF]);
      n_WriteAno(MsgAno);
    }
  }
  return (OK);
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0       ---> pbd_InRecOwner = pbd_InRecChild
  > 0     ---> pbd_InRecOwner > pbd_InRecChild
  < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ConditionSyncTOUTTRAA(
  char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
  char *tpsz_ReadBufferTOUTTRAA[]     /* adresse de la ligne de l'esclave */
)
{
  int ret ;
  DEBUT_FCT("n_ConditionSyncTOUTTRAA");

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF], tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETCTR_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF], tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETSEC_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF], tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RTY_NF])) != 0)
    RETURN_VAL (ret);

  RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
  /* lancement de la 1ere synchro */
  if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTOUTTRAA, tpsz_ReadBufferPER) == ERR)
    return ERR;

  /* lancement de la 2eme synchro */
  if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTOUTTRAI, tpsz_ReadBufferPER) == ERR)
    return ERR;

  return OK;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec l'esclave

retour :
  OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitTOUTTRAI(T_RUPTURE_SYNC_VAR  *pbd_RuptTOUTTRAI)
{

  memset( pbd_RuptTOUTTRAI, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl ("ESTC2307_I3", "rt", &(pbd_RuptTOUTTRAI->pf_InputFil)) == ERR)
    return ERR;

  pbd_RuptTOUTTRAI->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_RuptTOUTTRAI->ConditionEndSync  = n_ConditionSyncTOUTTRAI;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_RuptTOUTTRAI->n_ActionLigne     = n_ActionLigneTOUTTRAI;

  pbd_RuptTOUTTRAI->c_Separ = SEPARATEUR;

  return OK ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLigneTOUTTRAI(
  char *tpsz_ReadBufferPER[] ,
  char *tpsz_ReadBufferTOUTTRAI[]
)
{
  char sz_trncod[9];
  char sz_AcPc[9];
  char sz_blcshtyear[5];
  char sz_blcshtmonth[3];
  char MsgAno[200];
  short n_type ;

  if (atoi(tpsz_ReadBufferPER[PER_LOB_CF]) != 30 && atoi(tpsz_ReadBufferPER[PER_LOB_CF]) != 31)
    /* elimination de la filiale SCOR Vie */
  {
    /* recherche du type de poste */
    n_type = n_TypePoste(tpsz_ReadBufferTOUTTRAI[TOUTTRAI_TRNCOD_CF], Kp_Dettrs) ;

    if (n_type != 0) {
      if
      (
        ( (
            ( atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 5)
            || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 6)
            || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 7)
            || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF]) == 8)
          )
          ||
          ( (n_type != 3) && (n_type != 0) )
        )
        && ( n_type != 2 ) )
      {
        /*---------------------------------------------*/
        /* le suffixe du poste comptable est force a 4 */
        /*---------------------------------------------*/
        strcpy(sz_trncod, tpsz_ReadBufferTOUTTRAI[TOUTTRAI_TRNCOD_CF]);
        sz_trncod[7] = '4';//donc RETARDRETINT_B=1

        /*----------------------------------------------------*/
        /* calcul de l'annee de compte/periode de compte SCOR */
        /*----------------------------------------------------*/

        /* recuperation de l'annee et du mois du libelle d'inventaire */
        sprintf(sz_blcshtyear, "%4.4s", Ksz_clodat);
        sprintf(sz_blcshtmonth, "%2.2s", Ksz_clodat + 4);


        /* si l'annee de compte cedante est inferieure */
        /* a l'annee du libelle d'inventaire */

        if ( atoi(tpsz_ReadBufferTOUTTRAI[TOUTTRAI_ACCYER_NF]) <
             atoi(sz_blcshtyear) )
        {
          /* alors on prend l'annee de compte cedante comme annee */
          /* de compte SCOR et 01-12 comme periode de compte */

          strcpy(sz_AcPc, tpsz_ReadBufferTOUTTRAI[TOUTTRAI_ACCYER_NF]);
          strcat(sz_AcPc, "0112");
        }
        else
        {
          /* sinon on prend l'annee du libelle d'inventaire comme Ac */
          /* et le mois du libelle d'inventaire comme Pc */

          strcpy(sz_AcPc, sz_blcshtyear);
          strcat(sz_AcPc, sz_blcshtmonth);
          strcat(sz_AcPc, sz_blcshtmonth);
        }

        /*--------------------------------------------------------*/
        /* Ecriture en sortie d'un enregistrement au format du GT */
        /* L'enregistrement est ecrit dans le GT des mouvements   */
        /* a la part (Kp_GT_part) si le code placement est bien   */
        /* renseigne dans le fichier en entree, sinon dans le GT  */
        /* des mouvements 100% (Kp_GT_100).                       */
        /*--------------------------------------------------------*/
        // ecriture en sortie d'un enregistrement au format du GT 71 colonnes : RETROAUTO=0
        fprintf((b_IsBlankOrEmpty(tpsz_ReadBufferTOUTTRAI[TOUTTRAI_PLC_NT]) == TRUE ? Kp_GT_100 : Kp_GT_part),
                "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf~~~~~~~~~~~~~~~~~0~~~~0~~~~~~~~~\n",
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_SSD_CF],
                "",     /* ESB_CF */
                Ksz_clodat,    /* annee libelle d'inventaire */
                Ksz_clodat + 4, /* mois libelle d'inventaire */
                Ksz_clodat + 6, /* jour libelle d'inventaire */
                sz_trncod,
                "",     /* DBLTRNCOD_CF */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_CTR_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_END_NT],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_SEC_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_UWY_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_UW_NT],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_OCCYEA_NF],
                sz_AcPc,     /* ACY_NF */
                sz_AcPc + 4, /* SCOSTRMTH_NF */
                sz_AcPc + 6, /* SCOENDMTH_NF */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RCL_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_CUR_CF],
                (-1) * atof(tpsz_ReadBufferTOUTTRAI[TOUTTRAI_TRN_M]),
                "", /* CED_NF */
                "", /* BRK_NF */
                "", /* PAY_NF */
                "", /* KEY_NF */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RETCTR_NF],
                "0", /* RETEND_NT */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RETSEC_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RTY_NF],
                "1",  /* RETUW_NT */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_OCCYEA_NF],
                Ksz_clodat,    /* annee libelle d'inventaire */
                Ksz_clodat + 4, /* mois libelle d'inventaire */
                Ksz_clodat + 4, /* mois libelle d'inventaire */
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RCL_NF],
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_CUR_CF],
                (-1) * atof(tpsz_ReadBufferTOUTTRAI[TOUTTRAI_TRN_M]),
                tpsz_ReadBufferTOUTTRAI[TOUTTRAI_PLC_NT],
                "",  /* RTO_NF */
                "",  /* INT_NF */
                "",  /* RETPAY_NF */
                "", /* RETKEY_NF */
                0.000); /* RETINTAMT_M */
      }
    }/*(n_type != 0)*/
    else
    {

      /*------------------------------------------------------------*/
      /* si le type de poste renvoye par la fonction n_TypePoste    */
      /* est 0 , ca signifie que                                    */
      /* le poste passe en parametre n'a pas ete trouve dans DETTRS */
      /* et dans ce cas une anomalie est generee                    */
      /*------------------------------------------------------------*/

      if (n_type == 0)
      {
        sprintf(MsgAno, "The transaction code %s could not be found in table TDETTRS", tpsz_ReadBufferTOUTTRAI[TOUTTRAI_TRNCOD_CF]);
        n_WriteAno(MsgAno);
      }
    }
  }


  return (OK);
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0       ---> pbd_InRecOwner = pbd_InRecChild
  > 0     ---> pbd_InRecOwner > pbd_InRecChild
  < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ConditionSyncTOUTTRAI(
  char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
  char *tpsz_ReadBufferTOUTTRAI[]     /* adresse de la ligne de l'esclave */
)
{
  int ret ;
  DEBUT_FCT("n_ConditionSync");

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF], tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RETCTR_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF], tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RETSEC_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF], tpsz_ReadBufferTOUTTRAI[TOUTTRAI_RTY_NF])) != 0)
    RETURN_VAL (ret);

  RETURN_VAL(0);
}

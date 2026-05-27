/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2303.c
revision                      : $Revision:   1.3  $
date de creation              : 13/08/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Operateur de versement : GTAa * versements ===> GTAr100%

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    30/01/03       J. Ribot   ajout colonne retintamt_m sur fichier en sortie
    04/10/06       J. Ribot   Spot 13237 passe MAX_TGTA de 10000 15000
    06/12/07       J. Ribot   Spot 14791 ajout init variable sz_rettrncod suite plantage a cause du champ invalide
[04] 06/07/2011 Roger Cassis  :spot:21408  - Changement GT_TRN_NT en GT_TRN_NT2
[05] 06/04/2014 JBG           :spot:25773 Modify void main declaration to int main
[06] 25/09/2014 Roger Cassis  :spot:25036  - Retro pending force day to 14
[07] 05/10/2015   -=Dch=-     :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF)
[08] 28/01/2016 Florent       :spot:29066 gestion GLT à 71 colonnes
[09] 03/02/2016 Roger Cassis  :spot:30120  - Agrandissement tableaux FCES 1000 -> 10000 et GT 15000 -> 50000
[10] 22/06/2016 Florent       :spot:30516 RETROAUTO_B,SPEENTNAT_CT et RETARDRETINT_B peuvent être vide (NULL)
[11] 22/06/2016 -=Dch=-  	  :spot:29162 Ajout de la synchro section/exercice/ordre avec le fichier IADVPERICASE
[12] 09/06/2017 Roger Cassis  :spot:32479 Agrandissement du tableau MAX_TGTA de 50000 a 100000
[13] 14/06/2017 Roger Cassis  :spira:61789 Optimisation de la remise a zero du tableau TGTA et TCES
[14] 18/09/2017 Roger Cassis  :spira:64254 Agrandissement encore du compteur GTA a 150000
[15] 19/01/2022 MZM  :spira:99819 Agrandissement encore du compteur GTA a 2000000
[16] 08/02/2022 MZM  :Spira:98240 Ajout champ GT_GAAPCOD_NT et GT_I17PRDCOD_CT et definition champs et Impact sur ESTC2303
[17] 05/11/2024 Mr JYP:spira 111665/112295 wrong SSD/ESB for retro
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

// position des champs dans le cas d'un GT enrichi en entree */
#define GTES_ENTPERYEA_NF 41
#define GTES_ENTPERMTH_NF 42
#define GTES_VALPERYEA_NF 43
#define GTES_VALPERMTH_NF 44
#define GTES_TRN_NT2 45   // [004]
#define GTES_ACCTYP_NF 46
#define GTES_COMMAC_LL 47

//[16] Redefinition des colonnes du struct.h

#define GT_NEWCOLS1_NF 62
#define GT_NEWCOLS2_NF 63
#define GT_NEWCOLS3_NF 64
#define GT_NEWCOLS4_NF 65
#define GT_NEWCOLS5_NF 66
#define GT_NEWCOLS6_NF 67
#define GT_NEWCOLS7_NF 68
#define GT_NEWCOLS8_NF 69
#define GT_NEWCOLS9_NF 70

/* nombre max de versements pour une section donnee d'un contrat acceptation */
#define MAX_TCES 10000  // [09]

/*  nombre max d'ecritures dans le GTAa pour un meme casex acceptation */
#define MAX_TGTA 2000000  // [09] [12] [14]

//#define DBG_MODE 

typedef struct {
  char CTR_NF[10];
  unsigned char END_NT;
  unsigned char SEC_NF;
  short UWY_NF;
  unsigned char UW_NT;
  char RETCTR_NF[10];
  unsigned char RETEND_NT;
  unsigned char RETSEC_NF;
  short RTY_NF;
  unsigned char RETUW_NT;
  int CESACCSTA_N;
  int CESACCEND_N;
  double CESSH_R;
  unsigned char SSD_CF;
  unsigned char ESB_CF;
  char RETCTRCAT_CF[3];
  unsigned char ACCADMTYP_CT;
  unsigned char RETACCADM_B;
  unsigned char CLECUTPER_B;
  int CLECUTPER_NB;
  char ACCFAM_CT [6];
} T_CES;

typedef struct {
  unsigned char SSD_CF;
  unsigned char ESB_CF;
  short BALSHEY_NF;
  unsigned char BALSHRMTH_NF;
  unsigned char BALSHRDAY_NF;
  char TRNCOD_CF[9];
  char DBLTRNCOD_CF[9];
  char CTR_NF[10];
  unsigned char END_NT;
  unsigned char SEC_NF;
  short UWY_NF;
  unsigned char UW_NT;
  char OCCYEA_NF[10];
  short ACY_NF;
  unsigned char SCOSTRMTH_NF;
  unsigned char SCOENDMTH_NF;
  char CLM_NF[10];
  char CUR_CF[4];
  double AMT_M;
  int CED_NF;
  int BRK_NF;
  int PAY_NF;
  char KEY_NF[3];
  char TRN_NT[11];
  char ORICOD_LS[17];
  char RETROAUTO_B[2];
  char SPEENTNAT_CT[2];
  char EVT_NF[11];
  char REVT_NF[11];
  char RETARDRETINT_B[2];
  char NEWCOLS1_NF[11];
  char NEWCOLS2_NF[11];
  char NEWCOLS3_NF[11];
  char NEWCOLS4_NF[11];
  char NEWCOLS5_NF[11];
  char NEWCOLS6_NF[11];
  char NEWCOLS7_NF[11];
  char NEWCOLS8_NF[11];
  char NEWCOLS9_NF[11];
//Pour la version des ESID0091.cmd, ESIJ0091.cmd et ESPJ0091.cmd
  short ENTPERYEA_NF;
  short ENTPERMTH_NF;
  short VALPERYEA_NF;
  short VALPERMTH_NF;
  char TRN_NT2[11];
  short ACCTYP_NF;
  char COMMAC_LL[65];
} T_GTA;

typedef struct {
  char Contract [10];
  char Nature[2];
} T_PERIMETRE;
/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitGTA(T_RUPTURE_VAR  *);
static int n_InitCES(T_RUPTURE_SYNC_VAR  *);
static int n_InitPerimetre(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneCES(char **, char**);
static int n_ConditionSync(char **, char **);
static int n_ContratNatureSync(char** , char **);
static int n_ActionLigneGTA(char **);
static int n_ActionLignePerimetre(char **, char **);
static int n_ConditionRuptureGTA(char **, char **);
static int n_ActionFirstGTA(char **);
static int n_ActionLastGTA(char ** );
static void EcrireGTAr100(T_CES LigneVersement, T_GTA LigneGTAa, char * sz_PosteRetro);
static void StockeLigneAcc(char ** tpsz_ReadBufferGTA);
static void StockeLigneVers(char ** tpsz_ReadBufferCES);

char *trim(char *s) ;

extern int n_ProcessingRuptureVar(T_RUPTURE_VAR *);
extern int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *, char**);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static T_CES   TCES[MAX_TCES]; /* pour stocker lignes du fichier versements */
static T_PERIMETRE CTR;
static T_GTA   TGTA[MAX_TGTA]; /* pour stocker lignes du fichier GTAa */

static FILE *Kp_Gtar100;   /* fichier de sortie */
static FILE *Kp_Dettrs, *Kp_Rettrf;

static T_RUPTURE_VAR   Kbd_RuptGTA;
static T_RUPTURE_SYNC_VAR  Kbd_RuptCES, Kbd_Perimetre;

static BOOL Kb_GTA_COLS;  // Si GTA colonnes à 71
static int Kn_GTA;  /* taille effective du tableau T_GTA */
static int Kn_GTAMax;  /* [13] taille relle max du tableau T_GTA utilisé par les enregistrements chargés */
static int Kn_CES;  /* taille effective du tableau T_CES */
static int Kn_CESMax;  /* [13] taille relle max du tableau T_CES utilisé par les enregistrements chargés */

static BOOL Kb_CESDepass; /* pour controler le depassement de la */
static BOOL Kb_GTADepass; /* capacite maximale des tableaux T_CES et T_GTA */

static BOOL Kb_ReturnStatus = 0; /* statut de retour du programme */

static char Ksz_clodat[9];  /* 1er parametre du pgm : libelle d'inventaire */
static int Kn_GTE;        /* 2eme parametre du pgm : option GT enrichi */
long int Lignes; // pour debug

static char VERSION_ESTC2303_C[150] = "__version__: ESTC2303.c version [017] 05/11/2024 choose correct retro SSD/ESB " ;

/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{

  /* Initialisation des signaux */
  InitSig () ;
  #ifdef DBG_MODE 
  Lignes=0;
  #endif

  if ( n_BeginPgm (argc  , argv) == ERR )
    ExitPgm ( ERR_XX , "" );

  printf("Running with %s \n", VERSION_ESTC2303_C );  

  if ( n_OpenFileAppl ("ESTC2303_I3", "rb", &Kp_Dettrs) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2303_I4", "rb", &Kp_Rettrf) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2303_O1", "wt", &Kp_Gtar100) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* stockage des parametres du programme */
  sprintf(Ksz_clodat, "%s", psz_GetCharArgv(1));
  Kn_GTE = n_GetIntArgv(2);
  
  Kn_GTAMax = MAX_TGTA; // [13]
  Kn_CESMax = MAX_TCES; // [13]

  /* Initialisation de la variable Kbd_RuptGTA  */
  if ( n_InitGTA(&Kbd_RuptGTA) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la varible Kbd_RuptCES */
  if ( n_InitCES(&Kbd_RuptCES) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la varible Kbd_Perimetre */
  if ( n_InitPerimetre(&Kbd_Perimetre) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* lancement du traitement du fichier maitre */
  if ( n_ProcessingRuptureVar(&Kbd_RuptGTA) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2303_I3", &Kp_Dettrs) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2303_I4", &Kp_Rettrf) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2303_I5", &(Kbd_Perimetre.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );


  if ( n_CloseFileAppl ("ESTC2303_O1", &Kp_Gtar100) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2303_I1", &(Kbd_RuptGTA.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl ("ESTC2303_I2", &(Kbd_RuptCES.pf_InputFil)) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );

  exit(Kb_ReturnStatus) ;

}

/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
  0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTA(T_RUPTURE_VAR  *pbd_RuptGTA)
{
  memset(pbd_RuptGTA, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC2303_I1", "rt", &(pbd_RuptGTA->pf_InputFil)) == ERR)
    return ERR;

  pbd_RuptGTA->n_NbRupture = 1;
  pbd_RuptGTA->n_ActionLigne     = n_ActionLigneGTA;

  pbd_RuptGTA->n_ConditionRupture[0] = n_ConditionRuptureGTA;
  pbd_RuptGTA->n_ActionFirst[0] = n_ActionFirstGTA;
  pbd_RuptGTA->n_ActionLast[0] = n_ActionLastGTA;

  pbd_RuptGTA->c_Separ = '~';

  return OK ;
}

/*==============================================================================
objet :
  Test de rupture sur CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT
        pour le fichier pere (GTAa)

retour :
  0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
static int n_ConditionRuptureGTA(char ** tpsz_ReadBufferGTA,
                                 char ** tpsz_ReadBufferGTA_Cur)
{

  if (strcmp(tpsz_ReadBufferGTA[GT_CTR_NF], tpsz_ReadBufferGTA_Cur[GT_CTR_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferGTA[GT_END_NT], tpsz_ReadBufferGTA_Cur[GT_END_NT]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferGTA[GT_SEC_NF], tpsz_ReadBufferGTA_Cur[GT_SEC_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferGTA[GT_UWY_NF], tpsz_ReadBufferGTA_Cur[GT_UWY_NF]) != 0)
    return (1);

  if (strcmp(tpsz_ReadBufferGTA[GT_UW_NT], tpsz_ReadBufferGTA_Cur[GT_UW_NT]) != 0)
    return (1);

  return (0);
}

/*==============================================================================
objet :
  Fonction lancee en rupture premiere sur l'acceptation
        pour le fichier GTAa

retour :
  OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirstGTA(char ** tpsz_ReadBufferGTA)
{
  /* initialisation de TCES et TGTA */
  Kn_GTA = 0;
  Kn_CES = 0;
  memset(TCES, 0, Kn_CESMax * sizeof(T_CES)); // [13]
  memset(TGTA, 0, Kn_GTAMax * sizeof(T_GTA)); // [13]

  Kb_GTADepass = 0;
  Kb_CESDepass = 0;

  if ( n_ProcessingRuptureSyncVar(&Kbd_RuptCES, tpsz_ReadBufferGTA) == ERR)
    return ERR;

  return (OK);
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec l'esclave

retour :
  OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitCES(T_RUPTURE_SYNC_VAR  *pbd_RuptCES)
{

  memset( pbd_RuptCES, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl ("ESTC2303_I2", "rt", &(pbd_RuptCES->pf_InputFil)) == ERR)
    return ERR;

  pbd_RuptCES->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_RuptCES->ConditionEndSync = n_ConditionSync;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_RuptCES->n_ActionLigne    = n_ActionLigneCES;

  pbd_RuptCES->c_Separ = '~';

  return OK ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec l'esclave

retour :
  OK ---> traitement correctement effectue
  ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPerimetre(T_RUPTURE_SYNC_VAR  *pbd_Perimetre)
{

  memset( pbd_Perimetre, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl ("ESTC2303_I5", "rt", &(pbd_Perimetre->pf_InputFil)) == ERR)
    return ERR;

  pbd_Perimetre->n_NbRupture = 0;

  /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Perimetre->ConditionEndSync = n_ContratNatureSync;

  /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Perimetre->n_ActionLigne = n_ActionLignePerimetre;

  pbd_Perimetre->c_Separ = '~';

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
static int n_ActionLigneCES(
  char *tpsz_ReadBufferGTA[] ,
  char *tpsz_ReadBufferCES[]
)
{
  char MsgAno[300];

  /* stockage de la ligne courante dans TCES */
  if (Kb_CESDepass == 0)
  {
    if (Kn_CES < MAX_TCES)
    {
      StockeLigneVers(tpsz_ReadBufferCES);
      Kn_CES++;
      Kn_CESMax = Kn_CES+1;  // [13]
    }
    else
    {
      sprintf(MsgAno, "The number of records in CESSION file for contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program's storage capacity",
              tpsz_ReadBufferCES[CES_CTR_NF],
              tpsz_ReadBufferCES[CES_END_NT],
              tpsz_ReadBufferCES[CES_SEC_NF],
              tpsz_ReadBufferCES[CES_UWY_NF],
              tpsz_ReadBufferCES[CES_UW_NT]);

      n_WriteAno(MsgAno);
      Kb_CESDepass = 1;
      Kb_ReturnStatus = 1;
    }
  }

  return (OK);
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLignePerimetre (
  char *tpsz_ReadBufferGTA[] ,
  char *tpsz_ReadBufferPerimeter[]
)
{
  memset(CTR.Contract, 0, sizeof (CTR.Contract));
  // récupération de la nature du contrat en cours
  if (strcmp(tpsz_ReadBufferGTA[GT_CTR_NF] , tpsz_ReadBufferPerimeter[PER_CTR_NF]) == 0)
  {
    strcpy(CTR.Contract, tpsz_ReadBufferPerimeter[PER_CTR_NF]);
    strcpy(CTR.Nature , tpsz_ReadBufferPerimeter[PER_CTRNAT_CT]);
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
static int n_ConditionSync(
  char *tpsz_ReadBufferGTA[] ,   /* adresse de la ligne du maitre */
  char *tpsz_ReadBufferCES[]     /* adresse de la ligne de l'esclave */
)
{

  int ret ;
  DEBUT_FCT("n_ConditionSync");

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_CTR_NF], tpsz_ReadBufferCES[CES_CTR_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_END_NT], tpsz_ReadBufferCES[CES_END_NT])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_SEC_NF], tpsz_ReadBufferCES[CES_SEC_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UWY_NF], tpsz_ReadBufferCES[CES_UWY_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UW_NT], tpsz_ReadBufferCES[CES_UW_NT])) != 0)
    RETURN_VAL (ret);

  RETURN_VAL(0);
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0       ---> pbd_InRecOwner = pbd_InRecChild
  > 0     ---> pbd_InRecOwner > pbd_InRecChild
  < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ContratNatureSync(
  char *tpsz_ReadBufferGTA[] ,   /* adresse de la ligne du maitre */
  char *tpsz_ReadBufferPeri[]     /* adresse de la ligne de l'esclave */
)
{

  int ret = 0 ;
  DEBUT_FCT("n_ContratNatureSync");

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_CTR_NF], tpsz_ReadBufferPeri[PER_CTR_NF])) != 0)
  	RETURN_VAL(ret) ;

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_END_NT], tpsz_ReadBufferPeri[PER_END_NT])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_SEC_NF], tpsz_ReadBufferPeri[PER_SEC_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UWY_NF], tpsz_ReadBufferPeri[PER_UWY_NF])) != 0)
    RETURN_VAL (ret);

  if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UW_NT], tpsz_ReadBufferPeri[PER_UW_NT])) != 0)
    RETURN_VAL (ret);



  RETURN_VAL(ret);
}

/*==============================================================================
objet :
    Fonction de traitement de chaque enregistrement pere

retour :
  OK --->
  ERR --->
==============================================================================*/

static int  n_ActionLigneGTA(char *tpsz_ReadBufferGTA[])
{
  char MsgAno[300];
 
  #ifdef DBG_MODE 
  	printf("Ligne:%lu- /CTR:%s /SEC:%s /UWY:%s\n",Lignes++,tpsz_ReadBufferGTA[GT_CTR_NF], tpsz_ReadBufferGTA[GT_SEC_NF], tpsz_ReadBufferGTA[GT_UWY_NF]);
  #endif
  /* stocker la ligne courante dans TGTA */
  if ( (Kb_CESDepass == 0) && (Kb_GTADepass == 0) )
  {
    if (Kn_GTA < MAX_TGTA)
    {
      StockeLigneAcc(tpsz_ReadBufferGTA);
      Kn_GTA ++;
      Kn_GTAMax = Kn_GTA+1; // [13]
      n_ProcessingRuptureSyncVar(&Kbd_Perimetre, tpsz_ReadBufferGTA);
    }
    else
    {
      sprintf(MsgAno, "The number of records in GTA file for contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s /Kn_GTA = %d /MAX_TGTA = %d) overflows the program storage capacity",
              tpsz_ReadBufferGTA[GT_CTR_NF],
              tpsz_ReadBufferGTA[GT_END_NT],
              tpsz_ReadBufferGTA[GT_SEC_NF],
              tpsz_ReadBufferGTA[GT_UWY_NF],
              tpsz_ReadBufferGTA[GT_UW_NT],
              Kn_GTA,
              MAX_TGTA);

      n_WriteAno(MsgAno);
      Kb_GTADepass = 1;
      Kb_ReturnStatus = 1;
    }
  }

  return OK;
}

/*==============================================================================
objet :
  Fonction lancee en rupture derniere sur l'acceptation
        pour le fichier GTAa

retour :
  OK --->
        ERR --->
==============================================================================*/
static int n_ActionLastGTA(char ** tpsz_ReadBufferGTA)
{
  int i, j, n_acy;
  char sz_trncod[9], sz_rettrncod[9];
  char MsgAno[300];

  /* traitement des tableaux TGTA et TCES */
  if ( (Kb_CESDepass == 0) && (Kb_GTADepass == 0) && (Kn_CES != 0) )
  {

    for (i = 0; i < Kn_CES; i++) /* boucle sur les versements */
    {
      strcpy(sz_trncod, "");
      strcpy(sz_rettrncod, "");
      n_acy = 0;

      for (j = 0; j < Kn_GTA; j++) /* boucle sur le GT acceptation */
      {
        /* le versement n'est pris en compte que si l'annee de */
        /* compte est incluse dans les bornes des annees    */
        /* d'application du versement */

        if ( ( TCES[i].CESACCSTA_N <= TGTA[j].ACY_NF ) &&
             ( TGTA[j].ACY_NF <= TCES[i].CESACCEND_N )
           )
        {
          /* pour optimiser, le nouveau poste comptable n'est pas */
          /* calcule a chaque iteration sur le GT acceptation   */
          /* mais seulement quand le poste comptable et/ou l'annee */
          /* de compte changent (ce sont les deux seuls parametres */
          /* de la fonction de tranformation de poste qui proviennent */
          /* du GTA) */

          if (  (strcmp(TGTA[j].TRNCOD_CF, sz_trncod) != 0) ||
                (TGTA[j].ACY_NF != n_acy)
             )
          {
            strcpy(sz_trncod, TGTA[j].TRNCOD_CF);
            n_acy = TGTA[j].ACY_NF;


            strcpy(sz_rettrncod, GetRetroPoste(
                     trim(sz_trncod),
                     trim(CTR.Nature),
                     (int)TCES[i].ACCADMTYP_CT,
                     trim(TCES[i].ACCFAM_CT),
                     Kp_Dettrs,
                     Kp_Rettrf));
          }
          if (strcmp(sz_rettrncod, "") == 0) /* non trouve */
          {
            sprintf(MsgAno,
                    "Either the transaction code DETTRS_CF=%s was not found in reference table TDETTRS or the key (/DETTRS_CF=%s /ACCADMTYP_CT=%d /RETACCADM_B=%d) was not found in reference table TRETTRF",
                    sz_trncod,
                    sz_trncod,
                    (int)TCES[i].ACCADMTYP_CT,
                    (int)TCES[i].RETACCADM_B);

            n_WriteAno(MsgAno);
            /***** 30 01 98: modif provisoire : le plantage du programme est suspendu *****/
            /*** (par la mise en commentaire de l'instruction Kb_ReturnStatus=1) *****/
            /***** si on ne trouve pas le poste dans dettrs ou rettrf (pour faire ****/
            /*** passer le rapprochement - pb avec le poste 17440000) ***/
            /*** A retablir une fois le probleme avec le poste 17440000 resolu ****/
            /** dans TRETTRF ****/
            /*                       Kb_ReturnStatus=1; */
          }
          else if (strcmp(sz_trncod, sz_rettrncod) != 0)
          {
            /* ecriture d'une ligne en sortie */
            EcrireGTAr100(TCES[i], TGTA[j], sz_rettrncod);
          }
        }
      }
    }
  }
  return (OK);
}

static void EcrireGTAr100(T_CES TCES, T_GTA TGTA, char * sz_rettrncod)
{
  char sz_Brk_nf [10] = "" ;
//  char *psz_RETARDRETINT_B;
  double montant;

  if (TGTA.BRK_NF != 0) {
    sprintf (sz_Brk_nf, "%d", TGTA.BRK_NF);
  }
  // [05] [06]
  if (sz_rettrncod[7] == '4')
  {
    TGTA.RETARDRETINT_B[0] = '1';
  }
  else
    TGTA.RETARDRETINT_B[0] = '\0';// retard RETRO vide par défaut

  montant = TGTA.AMT_M * (-1.) * TCES.CESSH_R;

  // Tronc commun de 41 colonnes
  fprintf(Kp_Gtar100, "%d~%d~%4.4s~%2.2s~%2.2s~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%s~%d~%s~%s~%d~%d~%d~%d~%s~%4.4s~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf",
          TCES.SSD_CF,
          TCES.ESB_CF,
          Ksz_clodat,
          Ksz_clodat + 4,
          Ksz_clodat + 6,
          sz_rettrncod,
          "",
          TGTA.CTR_NF,
          TGTA.END_NT,
          TGTA.SEC_NF,
          TGTA.UWY_NF,
          TGTA.UW_NT,
          TGTA.OCCYEA_NF,
          TGTA.ACY_NF,
          TGTA.SCOSTRMTH_NF,
          TGTA.SCOENDMTH_NF,
          TGTA.CLM_NF,
          TGTA.CUR_CF,
          montant, //   TGTA.AMT_M * (-1.) * TCES.CESSH_R,
          TGTA.CED_NF,
          sz_Brk_nf,
          TGTA.PAY_NF,
          TGTA.KEY_NF,
          TCES.RETCTR_NF,
          TCES.RETEND_NT,
          TCES.RETSEC_NF,
          TCES.RTY_NF,
          TCES.RETUW_NT,
          TGTA.OCCYEA_NF,
          Ksz_clodat,
          Ksz_clodat + 4,
          Ksz_clodat + 4,
          TGTA.CLM_NF,
          TGTA.CUR_CF,
          montant, //   TGTA.AMT_M * (-1.) * TCES.CESSH_R,
          "",
          "",
          "",
          "",
          "",
          0.000); /* RETINTAMT_M */

  /* cas du GT non enrichi en entree" */
  if (Kn_GTE == 0)
  {
    if (Kb_GTA_COLS == 1)
    {
      fprintf(Kp_Gtar100, "~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s",
              TGTA.TRN_NT,
              TGTA.ORICOD_LS,
              TGTA.RETROAUTO_B,
              TGTA.SPEENTNAT_CT,
              TGTA.EVT_NF,
              TGTA.REVT_NF,
              TGTA.RETARDRETINT_B,
              TGTA.NEWCOLS1_NF,
              TGTA.NEWCOLS2_NF,
              TGTA.NEWCOLS3_NF,
              TGTA.NEWCOLS4_NF,
              TGTA.NEWCOLS5_NF,
              TGTA.NEWCOLS6_NF,
              TGTA.NEWCOLS7_NF,
              TGTA.NEWCOLS8_NF,
              TGTA.NEWCOLS9_NF);
    }
    fprintf(Kp_Gtar100, "\n");
  }
  else
  { // si gestion écritures service des ESID0091.cmd, ESIJ0091.cmd et ESPJ0091.cmd
    fprintf(Kp_Gtar100, "%d~%d~%d~%d~%s~%d~%d~%02d~%02d~%s\n",
            TGTA.ENTPERYEA_NF,
            TGTA.ENTPERMTH_NF,
            TGTA.VALPERYEA_NF,
            TGTA.VALPERMTH_NF,
            TGTA.TRN_NT2,
            TGTA.ACCTYP_NF,
            TGTA.BALSHEY_NF,
            TGTA.BALSHRMTH_NF,
            TGTA.BALSHRDAY_NF,
            TGTA.COMMAC_LL);
  }
}

static void StockeLigneVers(char ** tpsz_ReadBufferCES)
{
  #ifdef DBG_MODE
  printf("Kn_CES : %d\n",Kn_CES);
  if (Lignes > 421046)
  printf("stop");
  #endif
  strcpy(TCES[Kn_CES].CTR_NF, tpsz_ReadBufferCES[CES_CTR_NF]);
  TCES[Kn_CES].END_NT = (unsigned char) atoi(tpsz_ReadBufferCES[CES_END_NT]);
  TCES[Kn_CES].SEC_NF = (unsigned char) atoi(tpsz_ReadBufferCES[CES_SEC_NF]);
  TCES[Kn_CES].UWY_NF = (short) atoi(tpsz_ReadBufferCES[CES_UWY_NF]);
  TCES[Kn_CES].UW_NT = (unsigned char) atoi(tpsz_ReadBufferCES[CES_UW_NT]);
  strcpy(TCES[Kn_CES].RETCTR_NF, tpsz_ReadBufferCES[CES_RETCTR_NF]);
  TCES[Kn_CES].RETEND_NT = (unsigned char) atoi(tpsz_ReadBufferCES[CES_RETEND_NT]);
  TCES[Kn_CES].RETSEC_NF = (unsigned char) atoi(tpsz_ReadBufferCES[CES_RETSEC_NF]);
  TCES[Kn_CES].RTY_NF = (short) atoi(tpsz_ReadBufferCES[CES_RTY_NF]);
  TCES[Kn_CES].RETUW_NT = (unsigned char) atoi(tpsz_ReadBufferCES[CES_RETUW_NT]);
  TCES[Kn_CES].CESACCSTA_N = atoi(tpsz_ReadBufferCES[CES_CESACCSTA_N]);
  TCES[Kn_CES].CESACCEND_N = atoi(tpsz_ReadBufferCES[CES_CESACCEND_N]);
  TCES[Kn_CES].CESSH_R = atof(tpsz_ReadBufferCES[CES_CESSH_R]);
  TCES[Kn_CES].SSD_CF = (unsigned char) atoi(tpsz_ReadBufferCES[CES_SSD_CF]);
  TCES[Kn_CES].ESB_CF = (unsigned char) atoi(tpsz_ReadBufferCES[CES_ESB_CF]);
  strcpy(TCES[Kn_CES].RETCTRCAT_CF, tpsz_ReadBufferCES[CES_RETCTRCAT_CF]);
  TCES[Kn_CES].ACCADMTYP_CT = (unsigned char) atoi(tpsz_ReadBufferCES[CES_ACCADMTYP_CT]);
  TCES[Kn_CES].RETACCADM_B = (unsigned char) atoi(tpsz_ReadBufferCES[CES_RETACCADM_B]);
  TCES[Kn_CES].CLECUTPER_B = (unsigned char) atoi(tpsz_ReadBufferCES[CES_CLECUTPER_B]);
  TCES[Kn_CES].CLECUTPER_NB = (unsigned char) atoi(tpsz_ReadBufferCES[CES_CLECUTPER_NB]);
  strcpy(TCES[Kn_CES].ACCFAM_CT , tpsz_ReadBufferCES[CES_ACCFAM_CT]);
}

static void StockeLigneAcc(char ** tpsz_ReadBufferGTA)
{
  TGTA[Kn_GTA].SSD_CF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]);
  TGTA[Kn_GTA].ESB_CF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_ESB_CF]);
  TGTA[Kn_GTA].BALSHEY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_BALSHEY_NF]);
  TGTA[Kn_GTA].BALSHRMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRMTH_NF]);
  TGTA[Kn_GTA].BALSHRDAY_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRDAY_NF]);
  strcpy(TGTA[Kn_GTA].TRNCOD_CF, tpsz_ReadBufferGTA[GT_TRNCOD_CF]);
  strcpy(TGTA[Kn_GTA].DBLTRNCOD_CF, tpsz_ReadBufferGTA[GT_DBLTRNCOD_CF]);
  strcpy(TGTA[Kn_GTA].CTR_NF, tpsz_ReadBufferGTA[GT_CTR_NF]);
  TGTA[Kn_GTA].END_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_END_NT]);
  TGTA[Kn_GTA].SEC_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SEC_NF]);
  TGTA[Kn_GTA].UWY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_UWY_NF]);
  TGTA[Kn_GTA].UW_NT = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_UW_NT]);
  strcpy(TGTA[Kn_GTA].OCCYEA_NF, tpsz_ReadBufferGTA[GT_OCCYEA_NF]);
  TGTA[Kn_GTA].ACY_NF = (short) atoi(tpsz_ReadBufferGTA[GT_ACY_NF]);
  TGTA[Kn_GTA].SCOSTRMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOSTRMTH_NF]);
  TGTA[Kn_GTA].SCOENDMTH_NF = (unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOENDMTH_NF]);
  strcpy(TGTA[Kn_GTA].CLM_NF, tpsz_ReadBufferGTA[GT_CLM_NF]);
  strcpy(TGTA[Kn_GTA].CUR_CF, tpsz_ReadBufferGTA[GT_CUR_CF]);
  TGTA[Kn_GTA].AMT_M = atof(tpsz_ReadBufferGTA[GT_AMT_M]);
  TGTA[Kn_GTA].CED_NF = atoi(tpsz_ReadBufferGTA[GT_CED_NF]);
  TGTA[Kn_GTA].BRK_NF = atoi(tpsz_ReadBufferGTA[GT_BRK_NF]);
  TGTA[Kn_GTA].PAY_NF = atoi(tpsz_ReadBufferGTA[GT_PAY_NF]);
  strcpy(TGTA[Kn_GTA].KEY_NF, tpsz_ReadBufferGTA[GT_KEY_NF]);

  //si on a 71 colonnes on gère un format GT à 71 colonnes
  if ( tpsz_ReadBufferGTA[GT_NEWCOLS9_NF] != 0 )
  {
    Kb_GTA_COLS = 1;
    strcpy(TGTA[Kn_GTA].TRN_NT, tpsz_ReadBufferGTA[GT_TRN_NT]);
    strcpy(TGTA[Kn_GTA].ORICOD_LS, tpsz_ReadBufferGTA[GT_ORICOD_LS]);
    TGTA[Kn_GTA].RETROAUTO_B[0] = '1'; // c'est toujours de la RETRO AUTO dans ce programme
    TGTA[Kn_GTA].SPEENTNAT_CT[0] = tpsz_ReadBufferGTA[GT_SPEENTNAT_CT][0];
    strcpy(TGTA[Kn_GTA].EVT_NF, tpsz_ReadBufferGTA[GT_EVT_NF]);
    strcpy(TGTA[Kn_GTA].REVT_NF, tpsz_ReadBufferGTA[GT_EVT_NF]); //on mets l'évenement acceptation dans la RETRO car c'est la génération de la RETRO AUTO
    TGTA[Kn_GTA].RETARDRETINT_B[0] = tpsz_ReadBufferGTA[GT_RETARDRETINT_B][0];
    strcpy(TGTA[Kn_GTA].NEWCOLS1_NF, tpsz_ReadBufferGTA[GT_NEWCOLS1_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS2_NF, tpsz_ReadBufferGTA[GT_NEWCOLS2_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS3_NF, tpsz_ReadBufferGTA[GT_NEWCOLS3_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS4_NF, tpsz_ReadBufferGTA[GT_NEWCOLS4_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS5_NF, tpsz_ReadBufferGTA[GT_NEWCOLS5_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS6_NF, tpsz_ReadBufferGTA[GT_NEWCOLS6_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS7_NF, tpsz_ReadBufferGTA[GT_NEWCOLS7_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS8_NF, tpsz_ReadBufferGTA[GT_NEWCOLS8_NF]);
    strcpy(TGTA[Kn_GTA].NEWCOLS9_NF, tpsz_ReadBufferGTA[GT_NEWCOLS9_NF]);
  }
  if (Kn_GTE == 1 ) // si gestion écritures service des ESID0091.cmd, ESIJ0091.cmd et ESPJ0091.cmd
  {
    TGTA[Kn_GTA].ENTPERYEA_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ENTPERYEA_NF]);
    TGTA[Kn_GTA].ENTPERMTH_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ENTPERMTH_NF]);
    TGTA[Kn_GTA].VALPERYEA_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_VALPERYEA_NF]);
    TGTA[Kn_GTA].VALPERMTH_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_VALPERMTH_NF]);
    strcpy(TGTA[Kn_GTA].TRN_NT2, tpsz_ReadBufferGTA[GTES_TRN_NT2]); // [004]
    TGTA[Kn_GTA].ACCTYP_NF = (short) atoi(tpsz_ReadBufferGTA[GTES_ACCTYP_NF]);
    strcpy(TGTA[Kn_GTA].COMMAC_LL , tpsz_ReadBufferGTA[GTES_COMMAC_LL]);
  }
}

char *trim(char *s)
{
  char *ptr;

  if (!*s)
    return s;      // handle empty string
  for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
  ptr[1] = '\0';
  return s;
}

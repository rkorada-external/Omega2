/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Extraction des dernieres previsions
nom du source                 : ESTC2156.c
revision                      : $Revision:   1.0  $
date de creation              : 20/02/2014
auteur                        : A.Ben Jeddou
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :   
                
                 
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
 [001]  24/03/2016    S.ASKRI      spot 30386: spira 44460 modification du calcul de la base
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <float.h>
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

        
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define MAX_COUPLE_ANALYSIS    50
#define Kn_MaxPostes           20000   

/*-----------------------------*/
/* definition des types prives */
/*-----------------------------*/
typedef struct
{
    int               indice; // nombre de couple
    char              Dettrncod1[MAX_COUPLE_ANALYSIS][6];
    double            Montant1[MAX_COUPLE_ANALYSIS];
    char              Dettrncod2[MAX_COUPLE_ANALYSIS][6];
    double            Montant2[MAX_COUPLE_ANALYSIS];
    int               Det_Calculated[MAX_COUPLE_ANALYSIS];
    unsigned char     TRSinputType[MAX_COUPLE_ANALYSIS];
    double            M_Base[MAX_COUPLE_ANALYSIS];
    short             context[MAX_COUPLE_ANALYSIS];
    int               ACMTRS[MAX_COUPLE_ANALYSIS];
    T_DETTRN_ANALY_B  Dett_Base[MAX_COUPLE_ANALYSIS];
} T_COUPLE_ANALY;

/*----------------------*/
/* variables de travail */
/*----------------------*/
int   Kn_NbLigTrslnk;

static FILE *Kp_SubTRSBaseFile,       /* pointeur sur les pilotages */
            *Kp_SubTRSFile,
            *Kp_SubTRSAssoFile, 
            *Kp_SubTRSBpropFile,
            *Kp_TrslnkFil,            /*trslnk*/
            *Kp_PrevOutFile;          /* pointeur sur les dernieres previsions en sortie */

T_TRSLNK Kbd_TRSLNK[Kn_MaxPostes];

static T_RUPTURE_VAR       bd_RuptPrev;       /* gestion rupture sur les previsions */
static T_RUPTURE_VAR       bd_RuptAnaly;
static T_RUPTURE_SYNC_VAR  bd_RuptAnalySync;
static T_COUPLE_ANALY      Couple_Analy;
//static T_RUPTURE_SYNC_VAR  bd_RuptTrslnk;                  // gestion synchro trslnk-perimetre


static char Ksz_DateJour[11];           // Date de traitement
static T_SUBTRS SubtrsLigne;
static T_SUBTRSASSO SubTrsAssoLigne;
static T_SUBTRSESBPROP     bd_SubTrsEsBprop;

/*--------------------*/
/* procedures locales */
/*--------------------*/
static int n_InitPrev(T_RUPTURE_VAR *);
static int n_InitAnaly(T_RUPTURE_VAR *);
static int n_InitAnalySync(T_RUPTURE_SYNC_VAR *);
static int n_IsRPrev(char **, char **);
static int n_IsRAnaly(char **, char **);
static int n_IsR2Analy(char **, char **);
static int n_ActionFirstRuptPrev(char **);
static int n_ActionLignePrev(char **);
static int n_ActionLastRuptPrev(char **);
static int n_ConditionSyncAnaly (char ** ,char **);
static int n_ActionLigneAnalySync(char ** , char **);
static int n_ActionLigneAnaly(char **);
static int n_ChargerTRSLNK ();
static int n_RechPoste(char*, int);
void init_SubTrsEsBprop();


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
  int i, j;

  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR)
    ExitPgm(ERR_XX, "");

  /* Sauvegarde de la date passee */
  (void)snprintf(Ksz_DateJour, 11, "%s", psz_GetCharArgv(1));
  memset(&Couple_Analy, 0, sizeof(T_COUPLE_ANALY));
  for (j = 0; j < MAX_COUPLE_ANALYSIS; j++)
  {  
    for (i = 0; i < 200; i++)
    {
      Couple_Analy.Dett_Base[j].DETTRN[i] = (char*)malloc(sizeof(char) * 6);
      (void)snprintf(Couple_Analy.Dett_Base[j].DETTRN[i], 6, "%s", "");
      Couple_Analy.Dett_Base[j].Adjsig[i] = (unsigned char)0;
    }
  } 

  /* Ouverture des fichiers */
  if (n_OpenFileAppl("ESTC2156_O", "wt", &Kp_PrevOutFile) == ERR)
    ExitPgm(ERR_XX, "Cannot create ESTC2156_O file!");

  if (n_OpenFileAppl("ESTC2156_I3", "rb", &Kp_SubTRSBaseFile) == ERR)
    ExitPgm( ERR_XX, "Cannot open ESTC2156_I3 file!");

  if (n_OpenFileAppl("ESTC2156_I4", "rb", &Kp_SubTRSFile) == ERR)
    ExitPgm(ERR_XX, "Cannot open ESTC2156_I4 file!");

  if (n_OpenFileAppl("ESTC2156_I5", "rb", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm(ERR_XX, "Cannot open ESTC2156_I5 file!");

  if (n_OpenFileAppl("ESTC2156_I7", "rb", &Kp_TrslnkFil) == ERR)
    ExitPgm(ERR_XX, "Cannot open ESTC2156_I7 file!");

   if (n_OpenFileAppl ("ESTC2156_I8","rb",&Kp_SubTRSBpropFile) == ERR)
        ExitPgm(ERR_XX, "Cannot open ESTC2156_I8 file!");

  /* Initialisation de la varible bd_RuptPrev */
  if (n_InitPrev(&bd_RuptPrev) == ERR)
    ExitPgm(ERR_XX, "Call of n_InitPrev() fails");

  if (n_InitAnalySync(&bd_RuptAnalySync) == ERR)
    ExitPgm(ERR_XX, "Call of n_InitAnalySync() fails");

  if (n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile) != 0)
    ExitPgm(ERR_XX, "Call of n_ChargerTsubTRSAsso() fails");
  if (n_ChargerTsubTRSBase(Kp_SubTRSBaseFile) != 0)
    ExitPgm(ERR_XX, "Call of n_ChargerTsubTRSBase() fails");
  if (n_ChargerTsubTRS(Kp_SubTRSFile) != 0)
    ExitPgm(ERR_XX, "Call of n_ChargerTsubTRS() fails");
  if( n_ChargerTRSLNK () == ERR )                                                 
    ExitPgm ( ERR_XX , "Cal of n_ChargerTRSLNK() fails" ) ;
  /* Chargement de Kbd_SUBTRSESBPROP en memoire */
  if (n_ChargerSUBTRSESBPROP(Kp_SubTRSBpropFile) != 0)
    {
        //RETURN_VAL(errorMsg("Error loading Kbd_SUBTRSESBPROP. Error in ESTC3700.\n"));
        ExitPgm(ERR_XX, "cal of n_ChargerSUBTRSESBPROP() fails");
    }

  if (n_InitAnaly(&bd_RuptAnaly) != 0)
    ExitPgm(ERR_XX, "");

  /* Lancement du traitement du fichier */
  if (n_ProcessingRuptureVar(&bd_RuptAnaly) == ERR)
    ExitPgm(ERR_XX, "Call of n_ProcessingRuptureVar() fails");


  /* Lancement du traitement du fichier */
  if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)
    ExitPgm(ERR_XX, "Call of n_ProcessingRuptureVar() fails");

  /* Fermeture fichier */
  if (n_CloseFileAppl("ESTC2156_I6", &(bd_RuptAnaly.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I6 file!");

  if (n_CloseFileAppl("ESTC2156_I1", &(bd_RuptPrev.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I1 file!");

  if (n_CloseFileAppl("ESTC2156_I2", &(bd_RuptAnalySync.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I2 file!");

  if (n_CloseFileAppl("ESTC2156_I4", &Kp_SubTRSFile) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I4 file!");

  if (n_CloseFileAppl("ESTC2156_I3", &Kp_SubTRSBaseFile) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I3 file!");

  if (n_CloseFileAppl("ESTC2156_I5", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I5 file!");

  if (n_CloseFileAppl("ESTC2156_I7", &Kp_TrslnkFil) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I7 file!");

  if (n_CloseFileAppl("ESTC2156_I8", &Kp_SubTRSBpropFile) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_I8 file!");

  if (n_CloseFileAppl("ESTC2156_O", &Kp_PrevOutFile) == ERR)
    ExitPgm(ERR_XX, "Cannot close properly ESTC2156_O file!");

  for (j = 0; j < MAX_COUPLE_ANALYSIS; j++)
  {  
    for (i = 0; i < 200; i++)
    {
      (void)free(Couple_Analy.Dett_Base[j].DETTRN[i]);
    }
  }

  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Call of n_EndPgm() fails");

  exit(0);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre.
retour :
        0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitPrev");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2156_I1", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsRPrev;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPrev;
  pbd_Rupt->n_ActionLigne = n_ActionLignePrev;
  pbd_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Perim
retour :    OK
==============================================================================*/
int n_InitAnaly(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitAnaly");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier */
  if (n_OpenFileAppl("ESTC2156_I6", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsRAnaly; //n_IsRAnaly
  pbd_Rupt->n_ActionLigne = n_ActionLigneAnaly;
  pbd_Rupt->c_Separ = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Perim
retour :    OK
==============================================================================*/
int n_InitAnalySync(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitAnaly");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC2156_I2", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR2Analy; //n_IsR2Analy
  pbd_Rupt->ConditionEndSync      = n_ConditionSyncAnaly; 
  pbd_Rupt->n_ActionLigne         = n_ActionLigneAnalySync;
  pbd_Rupt->c_Separ               = '~';

  RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice/Annee de compte

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsRPrev");

  if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_END_NT], ptb_InRec_Cur[PRE_END_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UW_NT], ptb_InRec_Cur[PRE_UW_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF]) != 0)
    RETURN_VAL(1);
  // if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0)   //[001]
  //   RETURN_VAL(1);

  RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice/Annee de compte

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsRAnaly(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsRAnaly");

  if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_END_NT], ptb_InRec_Cur[PRE_END_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UW_NT], ptb_InRec_Cur[PRE_UW_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF] ,ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ESTMTH_NF] ,ptb_InRec_Cur[PRE_ESTMTH_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0)
    RETURN_VAL(1);
 
  RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice/Annee de compte

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR2Analy(char **ptb_InRec, char **ptb_InRec_Cur)
{
  int ret = 0;

  DEBUT_FCT("n_IsRAnaly");
  
  if ((ret = strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF])) != 0)
    RETURN_VAL(ret);
  
  if ((ret = strcmp(ptb_InRec[PRE_END_NT], ptb_InRec_Cur[PRE_END_NT])) != 0)
    RETURN_VAL(ret);

  if ((ret = strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF])) != 0)
    RETURN_VAL(ret);
  
  if ((ret = strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF])) != 0)
    RETURN_VAL(ret);
  
  if ((ret = strcmp(ptb_InRec[PRE_UW_NT], ptb_InRec_Cur[PRE_UW_NT])) != 0)
    RETURN_VAL(ret);
  
  if ((ret = strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF])) != 0)
    RETURN_VAL(ret);
  
  if ((ret = strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF])) != 0)
    RETURN_VAL(ret);

  if ((ret = strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF])) != 0)
    RETURN_VAL(ret);
 

  RETURN_VAL(ret);
}


/*==============================================================================
objet :     fonction de test de synchro
retour :    0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
            > 0     ---> pbd_InRecOwne> > pbd_InRecChild
            < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncAnaly(char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                         char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret = 0;
  DEBUT_FCT("n_ConditionSyncAnaly");
 
  if ((ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PRE_CTR_NF])) != 0)
    RETURN_VAL(ret);
  if ((ret =strcmp(pbd_InRecOwner[PRE_END_NT],pbd_InRecChild[PRE_END_NT]))  !=0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PRE_SEC_NF])) != 0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],pbd_InRecChild[PRE_UWY_NF])) != 0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_UW_NT],pbd_InRecChild[PRE_UW_NT]))  != 0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_ACY_NF],pbd_InRecChild[PRE_ACY_NF])) != 0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_ESTMTH_NF],pbd_InRecChild[PRE_ESTMTH_NF])) != 0)
    RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PRE_GAAP_NF],pbd_InRecChild[PRE_GAAP_NF])) != 0)
    RETURN_VAL(ret);


  RETURN_VAL(ret);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPrev (char **ptb_InRec_Cur)
{
  int j;

  DEBUT_FCT("n_ActionFirstRuptPrev");

  for (j = 0; j < Couple_Analy.indice; j++)
  {
    Couple_Analy.Det_Calculated[j] = 0;
    Couple_Analy.M_Base[j] = 0.0;
    Couple_Analy.Montant1[j] = 0.0;
    Couple_Analy.Montant2[j] = 0.0;
  }


  RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
  int j = 0;
  int i = 0;

  DEBUT_FCT("n_ActionLignePrev");
   
  while (j < Couple_Analy.indice)
  {
   i = 0;
    while (i < (Couple_Analy.Dett_Base[j].nb_Dettrn))
    {
      if (strcmp(Couple_Analy.Dett_Base[j].DETTRN[i], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) == 0)  
      {
        Couple_Analy.M_Base[j] = Couple_Analy.M_Base[j] + atof(ptb_InRec_Cur[PRE_ESTMNT_M])* (double)Couple_Analy.Dett_Base[j].Adjsig[i];
        //i = Couple_Analy.Dett_Base[j].nb_Dettrn;  // [001]
      }  
      i++;
    }
    j++;
  }

   

  RETURN_VAL(0);
}


/*==============================================================================
objet :
        Fonction lancee a la fin de chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionLastRuptPrev(char **ptb_InRec_Cur)
{
  int ret;

  DEBUT_FCT("n_ActionLastRuptPrev");

  ret = n_ProcessingRuptureSyncVar(&bd_RuptAnalySync, ptb_InRec_Cur);
     
  RETURN_VAL(ret);
}


/*==============================================================================
objet :
        Fonction lancee a la fin de chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionLigneAnalySync(char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                           char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  char sz_Mnt[50];
  char *psz_ligne[PRE_NBCOL+1];
  char sz_new_cre[20], sz_dettrn[6], sz_batch[2], sz_spimod[2], sz_acmtrs[5], sz_lob[4], sz_gaap[2];
  int ret, j, k = 0;
  int n_lob, gaap, i = 0;

  DEBUT_FCT("n_ActionLastRuptPrev");
  (void)snprintf(sz_spimod, 2, "1");
  (void)snprintf(sz_dettrn, 6, "     ");
  
  (void)snprintf(sz_lob, 4, "   ");
  (void)snprintf(sz_gaap, 2, " ");
  n_lob = atoi(sz_lob);
  gaap = atoi(sz_gaap);
  for (j = 0; j < PRE_NBCOL; j++)
  {
    psz_ligne[j] = pbd_InRecChild[j];
  }
  psz_ligne[PRE_NBCOL] = NULL;


  memset(&SubtrsLigne, 0, sizeof(T_SUBTRS)); 
  ret = n_FindTsubTRS(&SubtrsLigne, psz_ligne[PRE_DETTRNCOD_CF]);
  
  if (SubtrsLigne.TRSNATURE_CT != (unsigned char)2)
    RETURN_VAL(OK);
               
  (void)snprintf(sz_batch, 2, "1");
  psz_ligne[PRE_BATCH_B] = sz_batch;
  (void)snprintf(sz_new_cre, 20, "%s %s", Ksz_DateJour, "23:59:27");
  psz_ligne[PRE_CRE_D] = sz_new_cre;
 
  k = 0;
  j = -1;

  while ((k <= Couple_Analy.indice) && (j == -1))
  {

    if (strcmp(Couple_Analy.Dettrncod1[k], psz_ligne[PRE_DETTRNCOD_CF]) == 0) 
    {
      Couple_Analy.Montant2[k] = atof(psz_ligne[PRE_ESTMNT_M]);
      Couple_Analy.Det_Calculated[k] = 1; 
      j = k;
    }
           
    else if (strcmp(Couple_Analy.Dettrncod2[k], psz_ligne[PRE_DETTRNCOD_CF]) == 0) 
    {
      Couple_Analy.Montant1[k] = atof(psz_ligne[PRE_ESTMNT_M]);
      Couple_Analy.Det_Calculated[k] = 3; 
      j = k;
    }
    k++;
  }
 
  if (Couple_Analy.Det_Calculated[j] == 1)
  {
    if (Couple_Analy.TRSinputType[j] == (unsigned char)1) // amount
    {
      switch (Couple_Analy.context[j])
      {
        case 1: //Ratio = Amount * Base, with Ratio in %
          Couple_Analy.Montant1[j] = (Couple_Analy.Montant2[j] * Couple_Analy.M_Base[j]) / 100;
          break;

        case 2: //Ratio = Amount * Base, with Ratio in ‰
          Couple_Analy.Montant1[j] = (Couple_Analy.Montant2[j] * Couple_Analy.M_Base[j]) / 1000;
          break;    

        case 3:   // Base = Amount * Ratio, with Ratio in %
          if ((Couple_Analy.Montant2[j] > DBL_EPSILON) || (Couple_Analy.Montant2[j] < -DBL_EPSILON))
            Couple_Analy.Montant1[j] = (Couple_Analy.M_Base[j] / Couple_Analy.Montant2[j]) * 100;
          break;

        case 4: //Base = Amount * Ratio, with Ratio in ‰
          if ((Couple_Analy.Montant2[j] > DBL_EPSILON) || (Couple_Analy.Montant2[j] < -DBL_EPSILON))
            Couple_Analy.Montant1[j] = (Couple_Analy.M_Base[j] / Couple_Analy.Montant2[j]) * 1000;
          break;
      }

    }
    else if (Couple_Analy.TRSinputType[j] == (unsigned char)3) //Ratio
    {
      switch (Couple_Analy.context[j])
      {
        case 1: //Amount = Ratio * Base, with Ratio in %
            Couple_Analy.Montant1[j] = (Couple_Analy.Montant2[j] * Couple_Analy.M_Base[j]) * 100;
          break;

        case 2: //Amount = Ratio * Base, with Ratio in ‰
            Couple_Analy.Montant1[j] = (Couple_Analy.Montant2[j] * Couple_Analy.M_Base[j]) * 1000;
          break;    

        case 3:   // Base = Amount * Ratio, with Ratio in %
          if ((Couple_Analy.Montant2[j] > DBL_EPSILON) || (Couple_Analy.Montant2[j] < -DBL_EPSILON))
            Couple_Analy.Montant1[j] = (Couple_Analy.M_Base[j] / Couple_Analy.Montant2[j]) * 100;
          break;

       case 4: //Base = Amount * Ratio, with Ratio in ‰
          if ((Couple_Analy.Montant2[j] > DBL_EPSILON) || (Couple_Analy.Montant2[j] < -DBL_EPSILON))
            Couple_Analy.Montant1[j] = (Couple_Analy.M_Base[j] / Couple_Analy.Montant2[j]) * 1000;
          break;
      }
    }
    (void)snprintf(sz_Mnt, 50, "%.3lf", Couple_Analy.Montant1[j]);
    psz_ligne[PRE_ESTMNT_M] = sz_Mnt;
    (void)snprintf(sz_dettrn, 6, "%s", Couple_Analy.Dettrncod2[j]);
    psz_ligne[PRE_DETTRNCOD_CF] = sz_dettrn;
    psz_ligne[PRE_SPIMOD_CT] = sz_spimod;
    n_lob = atoi(pbd_InRecChild[PRE_LOB_CF]);
    gaap = atoi(pbd_InRecChild[PRE_GAAP_NF]);

     if(gaap == 5)
    {
      init_SubTrsEsBprop();
      n_RechSUBTRSESBPROP(&bd_SubTrsEsBprop, psz_ligne[PRE_DETTRNCOD_CF], pbd_InRecChild[PRE_SSD_CF], pbd_InRecChild[PRE_ESB_CF]);
      /* Si le gaap accept est interdit, la valeur de l'estimation est mise à zéro */
         if ( bd_SubTrsEsBprop.GAAP5TRS_CT == 3)
        {
            RETURN_VAL(OK); 
        }
    }

 // Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT
    if ((n_lob == 30) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '1'))
    {
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 1);
    }else if ((n_lob == 31) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '1'))
    {
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 3);
    }else if ((n_lob == 30) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '2'))
    {
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 2);
    }else if ((n_lob == 31) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '2'))
    {
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 4);
    }
    
    if (i==-1)
    {
        RETURN_VAL(OK);
    }
    else
    {
       (void)snprintf(sz_acmtrs, 5, "%d", Kbd_TRSLNK[i].ACMTRS_NT);
       psz_ligne[PRE_ACMTRS_NT] = sz_acmtrs;
    }

    (void)n_WriteCols(Kp_PrevOutFile, psz_ligne, '~', 0);

  }
  else if (Couple_Analy.Det_Calculated[j] == 3)
  {     
    if (Couple_Analy.TRSinputType[j] == (unsigned char)3) // amount car le TRSinputType[j] est celui du Couple_Analy.Dettrncod1[j]
    {
      switch (Couple_Analy.context[j])
      {
        case 1: //Amount = Ratio * Base, with Ratio in %
          Couple_Analy.Montant2[j]= (Couple_Analy.Montant1[j] * Couple_Analy.M_Base[j]) / 100;
          break;

        case 2: //Amount = Ratio * Base, with Ratio in ‰
          Couple_Analy.Montant2[j]= (Couple_Analy.Montant1[j] * Couple_Analy.M_Base[j]) / 1000;
          break;    

        case 3:   // Base = Amount * Ratio, with Ratio in %
          if ((Couple_Analy.Montant1[j] > DBL_EPSILON) || (Couple_Analy.Montant1[j] < -DBL_EPSILON))
            Couple_Analy.Montant2[j]= (Couple_Analy.M_Base[j] / Couple_Analy.Montant1[j]) * 100;
          break;

        case 4: //Base = Amount * Ratio, with Ratio in ‰
          if ((Couple_Analy.Montant1[j] > DBL_EPSILON) || (Couple_Analy.Montant1[j] < -DBL_EPSILON))
            Couple_Analy.Montant2[j]= (Couple_Analy.M_Base[j] / Couple_Analy.Montant1[j]) * 1000;
          break;

        default:
          break;
      }        
    }
    else if (Couple_Analy.TRSinputType[j] == (unsigned char)1) //Ratio
    {
      switch (Couple_Analy.context[j])
      {
        case 1: //Amount = Ratio * Base, with Ratio in %
          Couple_Analy.Montant2[j]= (Couple_Analy.Montant1[j] * Couple_Analy.M_Base[j]) * 100;
          break;

        case 2: //Amount = Ratio * Base, with Ratio in ‰
          Couple_Analy.Montant2[j]= (Couple_Analy.Montant1[j] * Couple_Analy.M_Base[j]) * 1000;
          break;    

        case 3:   // Base = Amount * Ratio, with Ratio in %
          if ((Couple_Analy.Montant1[j] > DBL_EPSILON) || (Couple_Analy.Montant1[j] < -DBL_EPSILON))
            Couple_Analy.Montant2[j]= (Couple_Analy.M_Base[j] / Couple_Analy.Montant1[j]) * 100;
          break;

        case 4: //Base = Amount * Ratio, with Ratio in ‰
          if ((Couple_Analy.Montant1[j] > DBL_EPSILON) || (Couple_Analy.Montant1[j] < -DBL_EPSILON))
            //Couple_Analy.Montant2[j]= (Couple_Analy.M_Base[j] / Couple_Analy.Montant1[j]) * 1000;
            Couple_Analy.Montant2[j]= (Couple_Analy.M_Base[j] / Couple_Analy.Montant1[j]) * 1000;
          break;

        default :
          break;
      }
    }

    (void)snprintf(sz_Mnt, 50, "%.3lf", Couple_Analy.Montant2[j]);
    psz_ligne[PRE_ESTMNT_M] = sz_Mnt;
    n_lob = atoi(pbd_InRecChild[PRE_LOB_CF]);
    psz_ligne[PRE_SPIMOD_CT] = sz_spimod;
    (void)snprintf(sz_dettrn, 6, "%s", Couple_Analy.Dettrncod1[j]);
    psz_ligne[PRE_DETTRNCOD_CF] = sz_dettrn;
    gaap = atoi(pbd_InRecChild[PRE_GAAP_NF]);

    if(gaap == 5)
    {
      init_SubTrsEsBprop();
      n_RechSUBTRSESBPROP(&bd_SubTrsEsBprop, psz_ligne[PRE_DETTRNCOD_CF], pbd_InRecChild[PRE_SSD_CF], pbd_InRecChild[PRE_ESB_CF]);
      /* Si le gaap accept est interdit, la valeur de l'estimation est mise à zéro */
         if ( bd_SubTrsEsBprop.GAAP5TRS_CT == 3)
        {
            RETURN_VAL(OK);
        }
    }

// Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT
    if ((n_lob == 30) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '1'))
    
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 1);
    else if ((n_lob == 31) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '1'))
    
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 3);
    else if ((n_lob == 30) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '2'))
    
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 2);
    else if ((n_lob == 31) && (pbd_InRecChild[PRE_ACMTRS_NT][0] == '2'))
    
    	i = n_RechPoste(psz_ligne[PRE_DETTRNCOD_CF], 4);
    
    
    if (i==-1)
    {
        RETURN_VAL(OK);
    }
    else
    {
       (void)snprintf(sz_acmtrs, 5, "%d", Kbd_TRSLNK[i].ACMTRS_NT);
       psz_ligne[PRE_ACMTRS_NT] = sz_acmtrs;
    }

    (void)n_WriteCols(Kp_PrevOutFile, psz_ligne, '~', 0);
  }

 RETURN_VAL(0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAnaly(char **ptb_InRec_Cur)
{
  char *psz_ligne[PRE_NBCOL+1];
  int j=0;
  int new_cpt = 0;
  int m=0;

  DEBUT_FCT("n_ActionLigneAnaly");

  for (j = 0; j < PRE_NBCOL; j++)
  {
    psz_ligne[j] = ptb_InRec_Cur[j];
  }
  psz_ligne[PRE_NBCOL] = 0;

  memset(&SubtrsLigne, 0, sizeof(T_SUBTRS)); 
  memset(&SubTrsAssoLigne, 0, sizeof(T_SUBTRSASSO));

  if (n_FindTsubTRS(&SubtrsLigne,psz_ligne[PRE_DETTRNCOD_CF]) != 0)
     RETURN_VAL(OK); //ERR

  if (SubtrsLigne.TRSNATURE_CT != (unsigned char)2)
     {
     	RETURN_VAL(OK);

     }


  j = 0;      
  while ((new_cpt == 0) && (j < Couple_Analy.indice))
  {
    if(strcmp(Couple_Analy.Dettrncod1[j],psz_ligne[PRE_DETTRNCOD_CF])==0)
      new_cpt = 1;

    if(strcmp(Couple_Analy.Dettrncod2[j],psz_ligne[PRE_DETTRNCOD_CF])==0)
      new_cpt = 1;

    j++;
  }

  if (new_cpt == 0)  
  {
    j = Couple_Analy.indice;
    if (j < MAX_COUPLE_ANALYSIS)
    {
      m = n_FindTsubTRSAsso(&SubTrsAssoLigne, 2, 4, psz_ligne[PRE_DETTRNCOD_CF]);
      if (m == -1)
      	RETURN_VAL(OK);
      strcpy(Couple_Analy.Dettrncod1[j],SubTrsAssoLigne.DETTRNCOD1_CF);
      strcpy(Couple_Analy.Dettrncod2[j],SubTrsAssoLigne.DETTRNCOD2_CF);
      if (strcmp(SubTrsAssoLigne.DETTRNCOD1_CF,psz_ligne[PRE_DETTRNCOD_CF])==0)
         Couple_Analy.TRSinputType[j]= SubtrsLigne.TRSINPUTTYPE_CT;
      else //strcmp(SubTrsAssoLigne.DETTRNCOD2_CF,psz_ligne[PRE_DETTRNCOD_CF])==0
      {
        if(SubtrsLigne.TRSINPUTTYPE_CT == (unsigned char)1)  //le TRSinputType[j] est celui du Couple_Analy.Dettrncod1[j]
          Couple_Analy.TRSinputType[j] = (unsigned char)3;

        if(SubtrsLigne.TRSINPUTTYPE_CT == (unsigned char)3)  //le TRSinputType[j] est celui du Couple_Analy.Dettrncod1[j]
          Couple_Analy.TRSinputType[j] = (unsigned char)1;
      }
      Couple_Analy.context[j] = SubTrsAssoLigne.CTX_NT;
      Couple_Analy.ACMTRS[j] = SubTrsAssoLigne.ACMTRS_NT;               
      m = n_FindTsubTRSBase(&(Couple_Analy.Dett_Base[j]), (short)(Couple_Analy.ACMTRS[j]));
      if (m == -1)
      	RETURN_VAL(OK);
      Couple_Analy.indice++;
    }
    else
      RETURN_VAL(ERR);
  }

  RETURN_VAL(OK);
}


// ----------------------------------------------------------------------------
// objet:  Lit le fichier binaire des postes et les met en memoire
// ----------------------------------------------------------------------------
int n_ChargerTRSLNK ()
{
  int n_EOF = 0;
  T_TRSLNK bd_Lu;
  char MsgAno[300];

    DEBUT_FCT("n_ChargerTRSLNK");

    Kn_NbLigTrslnk=0;

    /* Tant que la fin de fichier n'est pas atteinte,... */
    while (n_EOF == 0)
    {
        if (fread(&bd_Lu,sizeof(T_TRSLNK),1,Kp_TrslnkFil)<=0)
            n_EOF = 1;
        else
        {
            if ( Kn_NbLigTrslnk + 1 >= Kn_MaxPostes )
            {
                // depassement tableau
                sprintf(MsgAno,"The number of link (/PRS %d /ACMTRS %d /DETTRS %s) overflows the program's storage capacity",
                            bd_Lu.PRS_CF,
                            bd_Lu.ACMTRS_NT,
                            bd_Lu.DETTRS_CF);
                n_WriteAno(MsgAno);
                RETURN_VAL(ERR);
            }
            else
            if (bd_Lu.PRS_CF == 500)
                // Enregistrement ecrit dans le tableau
                Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
        }
    }

  RETURN_VAL(OK);
}



// ----------------------------------------------------------------------------
// objet : fonction de recherche du poste
// retour: 0       ---> Pas de rupture
//         < 0     ---> On n'est pas arrive au bloc synchrone
//         > 0     ---> On a depasse le bloc synchrone
// ----------------------------------------------------------------------------
int n_RechPoste(char *sz_poste, int N)
{
  int n_indice, ret;
  char tmp[9];

    DEBUT_FCT("n_RechPoste");

    //Ksz_vide[0]=0;
    n_indice=0;
    memset(tmp,0, sizeof(tmp));
    //strcpy(nb, N);

    sprintf(tmp, "%d", N); // Conversion de l'entier
    strcat(tmp, "1");
    strcat(tmp, sz_poste);
    strcat(tmp, "0");
    

    while (1==1)
    {
        // Comparaison des codes
        ret=strcmp(tmp,Kbd_TRSLNK[n_indice].DETTRS_CF); //avec poste+prefix et suffix

        // S'ils sont egaux, retourner l'indice
        if (ret==0)
            RETURN_VAL(n_indice);

        // Si la ligne est passee, retourner -1 (echec)
        if (ret<0)
            RETURN_VAL(-1);

        // Ligne suivante
        n_indice++;

        // Si on est a la fin du tableau, echec
        if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
    }
}

/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsEsBprop

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsEsBprop()
{
            strcpy(bd_SubTrsEsBprop.DETTRNCOD_CF, "");
            bd_SubTrsEsBprop.SSD_CF=0;
            bd_SubTrsEsBprop.ESB_CF=0;
            bd_SubTrsEsBprop.GLTFEEDING_B=0;
            bd_SubTrsEsBprop.INTERNRETRO_B=0;
            bd_SubTrsEsBprop.SRVFEEDING_B=0;
            bd_SubTrsEsBprop.PREMIUMPNPEGPI_B=0;
            bd_SubTrsEsBprop.RETROAUTO_B=0;
            bd_SubTrsEsBprop.COMACIMPACT_B=0;
            bd_SubTrsEsBprop.CASHFLOWPOS_CT=0;
            bd_SubTrsEsBprop.GAAP1TRS_CT=0;
            bd_SubTrsEsBprop.GAAP2TRS_CT=0;
            bd_SubTrsEsBprop.GAAP3TRS_CT=0;
            bd_SubTrsEsBprop.GAAP4TRS_CT=0;
            bd_SubTrsEsBprop.GAAP5TRS_CT=0;
            strcpy(bd_SubTrsEsBprop.CRE_D,"");
            strcpy(bd_SubTrsEsBprop.CREUSR_CF,"");
            strcpy(bd_SubTrsEsBprop.LSTUPD_D,"");
            strcpy(bd_SubTrsEsBprop.LSTUPDUSR_CF,"");
}

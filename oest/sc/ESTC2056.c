
/*==============================================================================
nom de l'application          : Détermination des constitutions et libérations
nom du source                 : ESTC2056.c
revision                      : $Revision:   1.0  $
date de creation              : 11/05/2015
auteur                        : S.ASKRI
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
		   01/09/2015  SAS   spot 29286  modification du sens de tri pour les entrees et retraits de portefeuille
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <float.h>
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define Kn_MaxPostes 5000
#define COL 57
#define PRE_ACMDET_NT 54
#define PRE_VAL 55

/*-----------------------------*/
/* definition des types prives */
/*-----------------------------*/
typedef struct
{
  char              Dettrncod1[6];
  char              Dettrncod2[6];
  int               Code;
} T_DEF_DettCod;

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_SubTRSAssoFile,
       *Kp_PrevOutFile;

T_SUBTRSASSO Kbd_SubTRSASSO[10000];

static T_RUPTURE_VAR       bd_RuptPrev;       /* gestion rupture sur les previsions */

static T_SUBTRSASSO   SubTrsAssoLigne;
static T_DEF_DettCod  DEF_DettCod[Kn_MaxPostes];

/*--------------------*/
/* procedures locales */
/*--------------------*/
static int n_InitPrev(T_RUPTURE_VAR *);
static int n_ActionLignePrev(char **);
static int n_ReturnDett(int, int, char*);

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

  if (n_BeginPgm(argc, argv) == ERR)                                    ExitPgm(ERR_XX, "");

  if (PRE_NBCOL >= 55)                                                  ExitPgm(ERR_XX, "too much columns in previsions!");

  memset(&DEF_DettCod, 0, sizeof(Kn_MaxPostes));


  /* Ouverture des fichiers */
  if (n_OpenFileAppl("ESTC2056_O", "wt", &Kp_PrevOutFile) == ERR)       ExitPgm(ERR_XX, "Cannot create ESTC2056_O file!");
  if (n_OpenFileAppl("ESTC2056_I1", "rb", &Kp_SubTRSAssoFile) == ERR)   ExitPgm(ERR_XX, "Cannot open ESTC2056_I1 file!");

  /* Initialisation de la varible bd_RuptPrev */
  if (n_InitPrev(&bd_RuptPrev) == ERR)                                  ExitPgm(ERR_XX, "Call of n_InitPrev() fails");
  if (n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile) != 0)                     ExitPgm(ERR_XX, "Call of n_ChargerTsubTRSAsso() fails");


  /* Lancement du traitement du fichier */
  if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)                      ExitPgm(ERR_XX, "Call of n_ProcessingRuptureVar() fails");
  /* Fermeture fichier */
  if (n_CloseFileAppl("ESTC2056_I", &(bd_RuptPrev.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "Cannot close properly ESTC2056_I file!");
  if (n_CloseFileAppl("ESTC2056_I1", &Kp_SubTRSAssoFile) == ERR)        ExitPgm(ERR_XX, "Cannot close properly ESTC2056_I1 file!");
  if (n_CloseFileAppl("ESTC2056_O", &Kp_PrevOutFile) == ERR)            ExitPgm(ERR_XX, "Cannot close properly ESTC2056_O file!");
  if (n_EndPgm() == ERR)                                                ExitPgm(ERR_XX, "Call of n_EndPgm() fails");

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

  if (n_OpenFileAppl("ESTC2056_I", "rt", &(pbd_Rupt->pf_InputFil)) != OK)
    RETURN_VAL(ERR);

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne         = n_ActionLignePrev;
  pbd_Rupt->c_Separ               = SEPARATEUR;

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
  int j = 0, tmp = 0, ret = 0;
  char dettacmtrs[12] = {0}, sz_acmtrs[5] = {0}, sz_dettrn[6], dett[3] = {0}; //sz_batch[2];//sz_new_cre[20],
  char *psz_ligne[COL + 2] = {NULL};

  memset(&SubTrsAssoLigne, 0, sizeof(T_SUBTRSASSO));
  memset(dettacmtrs, 0, sizeof(*dettacmtrs) * 12);
  memset(sz_dettrn, 0, sizeof(sz_dettrn));

  DEBUT_FCT("n_ActionLignePrev");

  for (j = 0; j < PRE_NBCOL + 1; j++)
  {
    psz_ligne[j] = ptb_InRec_Cur[j];  
  }
  psz_ligne[PRE_NBCOL + 1] = NULL;

  if (n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != -1) //cas d'une constitution
  {
    tmp = 2;
    snprintf(dett,3, "%d", 3);        // pour la vérification des constitutions
    snprintf(sz_dettrn, 6, "%s", ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
    snprintf(sz_acmtrs, 5, "%s", ptb_InRec_Cur[PRE_ACMTRS_NT]);
    sz_acmtrs[3] = '3';               //modification de la dernière valeur de l'acmtrs      
    psz_ligne[PRE_ADJCOD_CT] = "1";                                  
  }
  else  if (n_FindTsubTRSAssoCons(1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != -1) // cas d'une libération
  {
    tmp = 1;
    snprintf(dett,3, "%d", 4);       // pour la vérification des libérations
    ret = n_ReturnDett(1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
    sprintf(sz_dettrn, "%d", ret); 
    snprintf(sz_acmtrs, 5, "%s", ptb_InRec_Cur[PRE_ACMTRS_NT]);
    sz_acmtrs[3] = '3';
    psz_ligne[PRE_ADJCOD_CT] = "0";  //ADJCOD=0 pour les libérations pour ne pas faire de compléments
  }
  else if (n_FindTsubTRSAsso(&SubTrsAssoLigne, 5, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != -1) // cas d'une entrée
  {
    tmp = 1;
    snprintf(dett,3, "%d", 1);       // pour la vérification des entrées
    snprintf(sz_dettrn, 6, "%s", ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
    snprintf(sz_acmtrs, 5, "%s", ptb_InRec_Cur[PRE_ACMTRS_NT]);
    sz_acmtrs[3] = '1';
    psz_ligne[PRE_ADJCOD_CT] = "1";
  }
  else if (n_FindTsubTRSAssoCons(5, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != -1) // cas d'un retrait
  {
    tmp = 2;
    snprintf(dett,3, "%d", 2);      // pour la vérification des retraits
    ret = n_ReturnDett(5, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);  //récupération du dettrncod1
    sprintf(sz_dettrn, "%d", ret);
    snprintf(sz_acmtrs, 5, "%s", ptb_InRec_Cur[PRE_ACMTRS_NT]);
    sz_acmtrs[3] = '1';                                         //modification de la dernière valeur de l'acmtrs
    psz_ligne[PRE_ADJCOD_CT] = "1";
  }
  else  //SINON -dans les autres cas-
  {
    tmp = 0;
    snprintf(dett,3, "%d", 0);
    snprintf(sz_dettrn, 6, "%s", ptb_InRec_Cur[PRE_DETTRNCOD_CF]); //récupération du dettrncod
    snprintf(sz_acmtrs, 5, "%s", ptb_InRec_Cur[PRE_ACMTRS_NT]);    //récupération de l'acmtrs
    psz_ligne[PRE_ADJCOD_CT] = "1";
  }

  sprintf(dettacmtrs, "%s%s%d", sz_acmtrs, sz_dettrn, tmp); //valeur du nouveau champs --concaténation de l'acmtrs, dettrncod et tmp

  psz_ligne[PRE_ACMDET_NT] = dettacmtrs;
  psz_ligne[PRE_VAL] = dett;

  n_WriteCols(Kp_PrevOutFile, psz_ligne, '~', 0);

  RETURN_VAL(0);

}

/*==========================================================================
     Objet :    Recuperer le code détail (contre partie) d'un poste donné (pour un DETTRNCOD)
     à partir de la structure T_SUBTRSASSO grace a l association et le context

     Nom:       n_ReturnDett

     Parametres:
                pointeur sur stucture TRSASSO
                Association
                context
                DETTRNCOD lib

     Retour:    DETTRNCOD/-1
===========================================================================*/
int n_ReturnDett(int Asso, int contx, char *DETRNCOD)
{
  int i;

  for (i = 0; i < sizeof(T_SUBTRSASSO); i++)
  { if ((Asso == atoi(Kbd_SubTRSASSO[i].ASSOTYP_CT)) && (contx == Kbd_SubTRSASSO[i].CTX_NT) && ((strcmp(DETRNCOD, Kbd_SubTRSASSO[i].DETTRNCOD2_CF) == 0)))
    {
      return atoi(Kbd_SubTRSASSO[i].DETTRNCOD1_CF);
    }
  }
  return -1 ;
}



/*==========================================================================*/
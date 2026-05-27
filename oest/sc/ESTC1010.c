/*==============================================================================
nom de l'application          : Calcul de PNA,EPP,RPP
nom du source                 : ESTC1010.c
revision                      : $Revision: 1.4 $
date de creation              : 22/07/1997
auteur                        : O.LE ROY
references des specifications : ESTID01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
   En entree : perimetre IADPERICASE,
               fichier de travail des traites.
   En sortie : GT des PNA,
               GT des EPP,
               GT des RPP,
               fichier de travail des traites (pour chaque ligne du fichier de
               travail .
------------------------------------------------------------------------------
historique des modifications :
[01] 30/08/2004 MDJ         :spot:10422 - Modification des Date D'effet, Date d'échéance,
                             Durée des Polices, et Taux de Polices,
                             pour LOB = '04' et SSD_CF = 2, 3, 12
[02] 04/10/2004 MDJ         :spot:10422 - Modification Incluant Periode Comptable à + 2ans
                             Important : NE PAS Stocker "Periode Comptable + 2 ans" en sortie
                             "Periode Comptable + 2 ans" ne sert qu'aux calculs
[03] 15/10/2004 MDJ         :spot:10422 - Correction Exercice + 2
[04] 27/03/2008 J. Ribot    :spot:15219  ASE15 : recompilation des programmes C
[05] 13/07/2010 D.GATIBELZA indentation et traces.
[06] 17/01/2011 D.GATIBELZA :spot:16142 V10 CALCUL ESTIMATION PNA/ FAR ; correction sur les années de compte inférieures à l'exercice
[07] 15/03/2012 Florent/Roger :spot:????? debug calcul PNA en erreur trace dans //Florent
[08] 25/09/2013 -=Dch=-     ajout d'un control des valeur max d'indice pour les structures FTTR
[09] 06/04/2014 JBG         :spot:25773 Modify void main declaration to int main
[10] 28/01/2015 F.MAragnes  :spot:28140  Modification appel calculExerciceSeuil nouveau prototype  n_CalculExerciceSeuil(short ssd_cf , short esb_cf, char *lob_cf, short nat_cf );
                              appel des fonctions init_calculExerciceSeuil pour charger les données du fichier FTTHRHLDUWY en mémoire, ferme_calculExerciceSeuil pour liberer la mémoire
[11] 09/10/2015 Florent     :spot:29177  Calcul PNA sans restriction sur l’annee d’exercice pour chaque C/S/A et Poste
[12] 19/02/2016 Gaëlle/Florent :spot:30227 PROD (EST08c2) - Correction bug PNA portefeuille prime
[13] 01/03/2016  Florent    :spot:29066 GLT à 71 colonnes
[14] 21/02/2018  MZA        :spira:61688 Ne plus Estimer / Calculer les PNA lorsque "earned = "O"
[015] 22/05/2018  MZA       :spira:61688 Ne plus Estimer / Calculer les PNA lorsque "earned = "O" (Prise en compte du type comptable 2)
[016] 24/08/2019 S.Behague  :REQ_9.2: REQ.P.9.2 - Change in UPR calculation rules
[017] 24/08/2019 B.LAGHA    :spot:82318: Delete all condition about LOB_CF ==/!= 4 and add '*(-1)' to d_PPNAAvecUnderlyingRiskDate formula
[018] 05/02/2020 HR         :spira 81898 UPR - Blank Cedant positions   
[019] 28/08/2020 HR         :spira 81898 addition of BALSHEYEAR
[020]  25/11/2020 HR         :fix for SPIRA 81898
[021] 15/09/2021 HR          :80865 rupture 
[022] 18/11/2021 MZA        :spira:100208 Pas de calcul d'estimation de charge et de DAC sur traité Asie TR0002282 exo 2020 et 2021 ; 
                                          reactivation du commentaire ecriture dans FTTR  
[023] 26/11/2021 HR/MZM     :Spira:80865 Annulation partielle  
[024] 20/01/2022 MZM        :Spira:100208 Prise en compte des PNA dans le fichier FTTR                                              
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/
/* structures internes au programme */
/*----------------------------------*/

// MOD002 : Ajout de sz_LOB_CF dans la description de TABLE
typedef struct {
  int n_UWY_NF;
  int n_SSD_CF;
  int n_ESB_CF;
  int n_POLDURMTH_NF;
  double d_INSPOL_R;
  char sz_SECINC_D[9];
  char sz_EXP_D[9];
  int n_PRMPRTSCL_B;
  int n_DIFMTH_NF;
  int n_ACCADMTYP_CT;
  int n_CED_NF;
  int n_BRK_NF;
  int n_PAY_NF;
  int n_KEY_NF;
  int n_ERNPRMADM_B;
  char sz_EGPCUR_CF[4];
  char sz_LOB_CF[3];
} T_PERICARACT; /* Caracteristiques du perimetre pour chaque exercice d'un CAS*/


/*----------------------*/
/* variables de travail */
/*----------------------*/
#define Kn_NbrePeriCaractMAX 100 /* Nbre d'element max du tableau */
#define Kn_NbreTsupMAX 2000      /* Nbre d'element max du tableau */
#define Kn_NbreTinitMAX 2000      /* Nbre d'element max du tableau */

char Ksz_MessageErr[256]; /* Message d'erreur */
char Ksz_CLODAT[9];

/*019*/
char  Ksz_BALSHEYEAR[5];

T_PERICARACT  Ktb_PeriCaract[Kn_NbrePeriCaractMAX];
T_FT        Ktb_Tsup[Kn_NbreTsupMAX], Ktb_Tinit[Kn_NbreTinitMAX];

FILE *Kp_dGTAaTrPNA_Fil,    /* pointeur sur dGT des PNA traites en sortie           */
     *Kp_dGTAaEPP_Fil,      /* pointeur sur le dGT des RPP  en sortie               */
     *Kp_dGTAaRPP_Fil,      /* pointeur sur le dGT des EPP en sortie                */
     *Kp_FTTr_Fil,          /* pointeur sur le fichier de travail traite en sortie  */
     *Kp_InputFilExc;       /* pointeur sur le fichier binaire des cours de change  */

T_RUPTURE_VAR Kbd_RuptPER;          /* rupture sur le perimetre                     */
T_RUPTURE_SYNC_VAR Kbd_RuptFTTr;    /* synchro fichier de travail-perimetre         */

int Kb_SyncFTTr,            /* Indicateur de synchro. fichier de travail-perimetre  */
    Kn_ACCADMTYP_CT,        /* Nature du contrat/Avenant/Section                    */
    Kn_UWORG_CF,            /* Nature du contrat/Avenant/Section                    */
    Kn_NbLTsup,             /* Nombre de lignes dans tsup                           */
    Kn_NbLTinit,            /* Nombre de lignes dans tinit                          */
    Kn_NbLPeriCaract;       /* Nombre de lignes de PeriCaract                       */

char **Kptb_InRecCur;

/*-----------------------------------------*/
/* declaration des prototypes de fonctions */
/*-----------------------------------------*/

double dch_CalculCoeffPna(
  char          *pc_EXP_D,
  char          *pc_CLODAT_D,
  char    *pc_SCOSTRDAT_D,
  char    *pc_SCOENDDAT_D,
  unsigned char c_POLDURMTH_NF,
  unsigned char c_EARPRM_B)  ;


int n_InitPER(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePER(char **pbd_InRec_Cur);
int n_IsR1PER(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPER(char **ptb_InRec_Cur);
int n_ActionLastRuptPER(char **ptb_InRec_Cur);

int n_InitFTTr(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneFTTr(char **ptb_InRecOwner, char **pbd_InRecChild) ;
int n_ConditionSyncFTTr(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionFilsSansPereFTTr(char **ptb_InRecChild );

//[018]
int n_ActionLigneFTTrbis( char **ptb_InRecOwner, char **pbd_InRecChild, double d_PPNAc);

int n_CalculExerciceSeuil(short ssd_cf , short esb_cf, char *lob_cf, short nat_cf );
void n_finCalculSeuil();
int n_WriteFTTr( T_FT *Ktb_TFT );
int n_CherchePeriIndAff(int n_UWY_NF);

double d_ChercheTinitPart(int n_UWY_NF);

double d_PPNAAvecDecalage(int n_SCOSTRa,
                          int n_SCOSTRm,
                          int n_SCOENDa,
                          int n_SCOENDm,
                          int n_DIFMTH_NF,
                          int n_POLDURMTH_NF,
                          char sz_SECINC_D[9],
                          char sz_EXP_D[9],
                          char sz_CLODAT_D[9],
                          double d_INSPOL_R,
                          double d_PRIME,
                          int n_ERNPRMADM_B,
                          int n_UWY_NF);

int n_EcrireGT(T_FT *ptb_TsupInit,
               char sz_TRNCOD_CF[9],
               double d_Montant,
               int n_IndAff,
               int n_ACY_NF,
               int n_SCOSTRMTH,
               int n_SCOENDMTH,
               int b_Decalage,
               FILE *pf_NomFic,
               int b_RPP);

double d_PPNAAvecUnderlyingRiskDate ( double d_MontantEGPI, char sz_UnderlyingRiskDate[9], char sz_Clodat[9], char sz_InceptionDate[9]) ;

double d_CalculCoeffPna (
  char          *pc_EXP_D,       /* i - Date de fin de l'exercice de la section*/
  char          *pc_CLODAT_D,    /* i -  Date de calcul (necessairement une date de fin de mois)*/
  char          *pc_SCOSTRDAT_D, /* i Date de debut de periode */
  char          *pc_SCOENDDAT_D, /* i Date de fin de periode */
  unsigned char c_POLDURMTH_NF,  /* i - Duree des polices d'origine*/
  unsigned char c_EARPRM_B );
  

/*==============================================================================
objet   :   point d'entree du programme
retour  :   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  /* Initialisation des signaux */
  InitSig();

  if ( n_BeginPgm (argc  , argv) == ERR ) ExitPgm ( ERR_XX , "" );

  /* Recuperation des parametres d'entree */
  strcpy(Ksz_CLODAT, psz_GetCharArgv(1));

  /*019*/
  strcpy(Ksz_BALSHEYEAR, psz_GetCharArgv(2));

  /* ouverture des fichiers en sortie */
  if ( n_OpenFileAppl ("ESTC1010_I3", "rb", &Kp_InputFilExc) == ERR ) ExitPgm ( ERR_XX , "" );
  if ( n_OpenFileAppl ("ESTC1010_O1", "wt", &Kp_dGTAaTrPNA_Fil) == ERR ) ExitPgm ( ERR_XX , "" );
  if ( n_OpenFileAppl ("ESTC1010_O2", "wt", &Kp_dGTAaEPP_Fil) == ERR ) ExitPgm ( ERR_XX , "" );
  if ( n_OpenFileAppl ("ESTC1010_O3", "wt", &Kp_dGTAaRPP_Fil) == ERR ) ExitPgm ( ERR_XX , "" );
  if ( n_OpenFileAppl ("ESTC1010_O4", "wt", &Kp_FTTr_Fil) == ERR ) ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_RuptPER */
  if ( n_InitPER(&Kbd_RuptPER) ) ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable Kbd_RuptFTTr */
  if ( n_InitFTTr(&Kbd_RuptFTTr) ) ExitPgm ( ERR_XX , "" );
  // spot 28140 Initialisation  CalculExerciceSeuil
  if (n_initCalculExerciceSeuil("ESTC1010_I4")) ExitPgm ( ERR_XX , "" );

  /* lancement du traitement du fichier */
  if ( n_ProcessingRuptureVar (&Kbd_RuptPER) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_I1", &(Kbd_RuptPER.pf_InputFil))) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_I2", &(Kbd_RuptFTTr.pf_InputFil))) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_I3", &(Kp_InputFilExc))) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_O1", &Kp_dGTAaTrPNA_Fil)) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_O2", &Kp_dGTAaEPP_Fil)) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_O3", &Kp_dGTAaRPP_Fil)) ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC1010_O4", &Kp_FTTr_Fil)) ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR ) ExitPgm ( ERR_XX , "" );
  n_finCalculSeuil();
  exit(0) ;
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour: 0
==============================================================================*/
int n_InitPER(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPER");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC1010_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    RETURN_VAL (ERR);

  pbd_Rupt->n_NbRupture = 1  ;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1PER;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPER;
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPER;
  pbd_Rupt->n_ActionLigne = n_ActionLignePER ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture du niveau 1
retour: 0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1PER(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1PER");

  //[021] rupture with ACCADMTÂ¨YP_CT

  if ((strcmp(ptb_InRec[PER_CTR_NF], ptb_InRec_Cur[PER_CTR_NF]) != 0) ||
      (strcmp(ptb_InRec[PER_END_NT], ptb_InRec_Cur[PER_END_NT]) != 0) ||
      (strcmp(ptb_InRec[PER_SEC_NF], ptb_InRec_Cur[PER_SEC_NF]) != 0) ||
      (((strcmp(ptb_InRec[PER_ACCADMTYP_CT], ptb_InRec_Cur[PER_ACCADMTYP_CT]) != 0) && 
       (strcmp(ptb_InRec[PER_ACCADMTYP_CT], "2") == 0))  ||
      ((strcmp(ptb_InRec[PER_ACCADMTYP_CT], ptb_InRec_Cur[PER_ACCADMTYP_CT]) != 0) && 
       (strcmp(ptb_InRec_Cur[PER_ACCADMTYP_CT], "2") == 0)) ) )
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere sur CTR_NF/END_NT/SEC_NF
==============================================================================*/
int n_ActionFirstRuptPER ( char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionFirstRuptPER");

  memset(Ktb_Tsup, 0, Kn_NbreTsupMAX * sizeof(T_FT));
  memset(Ktb_Tinit, 0, Kn_NbreTsupMAX * sizeof(T_FT));
  memset(Ktb_PeriCaract, 0, Kn_NbrePeriCaractMAX * sizeof(T_PERICARACT));

  Kn_NbLTsup = 0;
  Kn_NbLTinit = 0;
  Kn_NbLPeriCaract = 0;

  RETURN_VAL(0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du PERIMETRE
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePER(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePER");

  /* Conservation du pointeur sur la ligne pour ecrire des anomalies dans des fonctions */
  Kptb_InRecCur = ptb_InRec_Cur;

  /* Initialisation de la variable globale type comptable */
  Kn_ACCADMTYP_CT = atoi(ptb_InRec_Cur[PER_ACCADMTYP_CT]);
  Kn_UWORG_CF = atoi(ptb_InRec_Cur[PER_UWORG_CF]);


  /* pour les Facultatives rien a faire */
  if (ptb_InRec_Cur[PER_CTRNAT_CT][0] == 'F')
    RETURN_VAL (0);

  /* cas des prop de type 1 et 3 */ 
  /* [014] pour les TRAITES DONC ERNPRMADM_B = 0 ne plus generer de PNA   */
   if (ptb_InRec_Cur[PER_CTRNAT_CT][0] == 'P' && (Kn_ACCADMTYP_CT == 1 || Kn_ACCADMTYP_CT == 3 || Kn_ACCADMTYP_CT == 4 || Kn_ACCADMTYP_CT == 5)) 
  {
    /* chargement en table de certaines caracteristiques du perimetre */
    if (Kn_NbLPeriCaract == Kn_NbrePeriCaractMAX)
    {
      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s : maximum number of UWY/UW is reached ; increase Kn_NbrePeriCaractMAX value", ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF]);
      n_WriteAno( Ksz_MessageErr);
    }
    else
    {
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_SSD_CF       = atoi(ptb_InRec_Cur[PER_SSD_CF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_ESB_CF       = atoi(ptb_InRec_Cur[PER_ACCESB_CF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_UWY_NF       = atoi(ptb_InRec_Cur[PER_UWY_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_POLDURMTH_NF = atoi(ptb_InRec_Cur[PER_POLDURMTH_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].d_INSPOL_R     = (double)atof(ptb_InRec_Cur[PER_INSPOL_R]);
      strcpy(Ktb_PeriCaract[Kn_NbLPeriCaract].sz_SECINC_D,    ptb_InRec_Cur[PER_SECINC_D]);
      strcpy(Ktb_PeriCaract[Kn_NbLPeriCaract].sz_EXP_D,       ptb_InRec_Cur[PER_EXP_D]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_PRMPRTSCL_B  = atoi(ptb_InRec_Cur[PER_PRMPRTSCL_B]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_DIFMTH_NF    = atoi(ptb_InRec_Cur[PER_DIFMTH_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_ACCADMTYP_CT = atoi(ptb_InRec_Cur[PER_ACCADMTYP_CT]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_CED_NF       = atoi(ptb_InRec_Cur[PER_CED_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_BRK_NF       = atoi(ptb_InRec_Cur[PER_PRD_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_PAY_NF       = atoi(ptb_InRec_Cur[PER_GENPRMPAY_NF]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_KEY_NF       = atoi(ptb_InRec_Cur[PER_GANPAYORD_NT]);
      Ktb_PeriCaract[Kn_NbLPeriCaract].n_ERNPRMADM_B  = atoi(ptb_InRec_Cur[PER_ERNPRMADM_B]);
      strcpy(Ktb_PeriCaract[Kn_NbLPeriCaract].sz_EGPCUR_CF,   ptb_InRec_Cur[PER_EGPCUR_CF]);
      strcpy(Ktb_PeriCaract[Kn_NbLPeriCaract].sz_LOB_CF,      ptb_InRec_Cur[PER_LOB_CF]);             // MOD002
	  
      Kn_NbLPeriCaract++;
    }
  }
  n_ProcessingRuptureSyncVar(&Kbd_RuptFTTr, ptb_InRec_Cur);

  RETURN_VAL (0);
}

/*==============================================================================
objet : Fonction lancee a chaque rupture derniere sur CTR_NF/END_NT/SEC_NF
==============================================================================*/
int n_ActionLastRuptPER ( char **ptb_InRec_Cur)
{
  char sz_Deff0[9], sz_Dech0[9], /* Dates d'effet et d'echeance de l'exercice precedent le premier exercice */
       sz_CALC_D[9],            /* date de fin d'ex d'affichage pour le Calcul de PPNA */
       MsgAno[400];             /* Message d'anomalie */

  int n_DureePremierExercice,
      n_CursTinit,              /* indice de la ligne courante de Tinit */
      n_CursTsup,               /* indice de la ligne courante de Tsup  */
      n_IndTsup,                /* Pointeur relatif a l'exercice d'affichage dans Tsup */
      n_MinAffTsup, n_MaxAffTsup, /* indices de la premiere et de la derniere ligne correspondant a l'exercice d'affichage dans tsup */
      n_Generees,               /* Nombre de lignes generees pour l'exercice d'affichage courant par Tinit et tsup  sur l'exercice d'affichage suivant dans tsup */
      n_IndAff,                 /* indice de la ligne correspondant a l'exercice d'affichage dans Ktb_PeriCaract */
      n_ExAff,                  /* Exercice d'affichage */
      n_ACCADMTYPNextAff,       /* Type Comptable de l'exercice suivant ExAff */
      b_Generate,               /* Doit on generer une ligne dans Tsup */
      b_Decalage,               /* Doit on appliquer le Decalage lors de l'ecriture d'EPP, RPP dans le GT */
      n_CLOMTH_NF,              /* Mois de passage de la RPP et de l'EPP dans le GT */
      n_CLOYEA_NF,              /* Annee de passage de l'inventaire */
      n_MaxExAff = 0;           //dernier exercice du contrat

  //019
      int n_CURCLODAT_Y, n_CURCLODAT_M;

  double d_PartAff,             /* part SCOR pour l'exercice d'affichage */
         d_PartNextAff,         /* part SCOR pour l'exercice d'affichage suivant */
         d_RPP,                 /* RPP a reporter pour l'exercice d'affichage suivant */
         d_SumEPPc = 0,         /* somme des EPP cedantes */
         d_SumEPPe = 0,         /* somme des EPP estimees */
         d_SumEPPa = 0,         /* somme des EPP actualisees */
         d_SumRPPe = 0,         /* somme des RPP estimees */
         d_SumRPPa = 0,         /* somme des RPP actualisees */

         /*[018] [020]*/
         d_SumPPNACZeroing = 0,
         d_SumPPNACZeroing_2 = 0,
         d_SumLPPNAcZeroing_2 = 0,

         d_RatioEPP, d_RatioPRM;

 //[020] begin	 
  double d_SumRPPcZeroing = 0,         /* somme des RPP actualisees */
         d_SumPPNAcZeroing = 0,        /* somme des RPP actualisees */
         d_SumLPPNAcZeroing = 0;       /* somme des RPP actualisees */

  double d_SumRPPc = 0,         /* somme des RPP actualisees */
         d_SumPPNAc = 0,        /* somme des RPP actualisees */
         d_SumLPPNAc = 0;       /* somme des RPP actualisees */
 //[020] end  

  /* bits de presence des comptes cedante et autorisation d'Ecriture*/
  //[020] Zeroing + b_EcrireRPPa_2 b_EcrireEPPa_2
  unsigned char b_lPPNACZeroing = 0, b_EPPC = 0, b_RPPCZeroing = 0, b_PPNACZeroing = 0, b_EcrireEPPech, b_EcrireEPPe, b_EcrireEPPa, b_EcrireRPPe, b_EcrireRPPa, b_EcrireRPPa_2, b_EcrireEPPa_2;
  //[020]
  unsigned char b_lPPNAC = 0, b_RPPC = 0, b_PPNAC = 0;

  /*[018] */
  unsigned char b_EcrirePPNAC;
  unsigned char b_EcrireLPPNAC;

  DEBUT_FCT("n_ActionLastRuptPER");

  n_MaxExAff = atoi(ptb_InRec_Cur[PER_UWY_NF]); //[009] Calcul PNA, dernier exe dans le périmètre
  /* eclatement de la date de passage d'inventaire */
  o_ExtractionAnneeMois(Ksz_CLODAT, &n_CLOYEA_NF, &n_CLOMTH_NF);

  /*---------------------------------*/
  /* cas des prop de type 1 et 3     */
  /*---------------------------------*/
  

  /* [014] DEBUT */
  if ( ptb_InRec_Cur[PER_CTRNAT_CT][0] == 'P' &&
       (Kn_ACCADMTYP_CT == 1 || Kn_ACCADMTYP_CT == 3 || Kn_ACCADMTYP_CT == 4 || Kn_ACCADMTYP_CT == 5) )
         
  {
    /*-------------------------------*/
    /* Traitement prealable sur tsup */
    /*-------------------------------*/
    for (n_CursTsup = 0; n_CursTsup < Kn_NbLTsup; n_CursTsup++)
    {
      /* La ligne 0 de Ktb_PeriCaract contient le premier Exercice de souscription */
      n_AddDays(sz_Dech0, 1, '-', Ktb_PeriCaract[0].sz_SECINC_D);

      n_DiffDate(Ktb_PeriCaract[0].sz_EXP_D, &n_DureePremierExercice, Ktb_PeriCaract[0].sz_SECINC_D);

      n_AddDays(sz_Deff0, n_DureePremierExercice + 1, '-', Ktb_PeriCaract[0].sz_SECINC_D);

      Ktb_Tsup[Kn_NbLTsup + n_CursTsup] = Ktb_Tsup[n_CursTsup];
      strcpy(Ktb_Tsup[Kn_NbLTsup + n_CursTsup].WFCOD_NT, "8000");
      Ktb_Tsup[Kn_NbLTsup + n_CursTsup].ACY_NF = Ktb_Tsup[n_CursTsup].UWYDIS_NF + 1;
      Ktb_Tsup[Kn_NbLTsup + n_CursTsup].UWYDIS_NF = Ktb_Tsup[n_CursTsup].UWYDIS_NF + 1;
      Ktb_Tsup[Kn_NbLTsup + n_CursTsup].SSD_CF = Ktb_Tsup[n_CursTsup].SSD_CF;      
       Ktb_Tsup[Kn_NbLTsup + n_CursTsup].EPPEA_M = d_PPNAAvecDecalage( Ktb_Tsup[n_CursTsup].UWY_NF,
       Ktb_Tsup[n_CursTsup].SCOSTRMTH_NF,
       Ktb_Tsup[n_CursTsup].UWY_NF,
       Ktb_Tsup[n_CursTsup].SCOENDMTH_NF,
       Ktb_PeriCaract[0].n_DIFMTH_NF,
       12,
       sz_Deff0,
       sz_Dech0,
       sz_Dech0,
       1,
       Ktb_Tsup[n_CursTsup].PRM_M,
       Ktb_PeriCaract[0].n_ERNPRMADM_B,
       Ktb_PeriCaract[0].n_UWY_NF );

    }

    /*------------------------------------------------------*/
    /* generations de lignes dans Tsup depuis Tsup et Tinit */
    /*------------------------------------------------------*/

    /* Initialisation des indices de reperage dans Tsup et Tinit */
    n_MinAffTsup = Kn_NbLTsup;
    n_MaxAffTsup = 2 * Kn_NbLTsup;
    n_CursTinit = 0;

    n_ExAff = Ktb_Tsup[Kn_NbLTsup].UWYDIS_NF;
    /* Boucle sur Tsup et Tinit pour les exercices d'affichage */
    do
    {
      n_Generees = 0;
      d_PartAff = 0;
      d_PartNextAff = 0;

      n_IndAff = n_CherchePeriIndAff(n_ExAff);
      d_PartAff = d_ChercheTinitPart(n_ExAff);

      /* Recherche part SCOR et type comptable de l'exercice suivant */
      if (n_ExAff < Ktb_PeriCaract[Kn_NbLPeriCaract - 1].n_UWY_NF)
        d_PartNextAff = d_ChercheTinitPart(n_ExAff + 1);

      n_ACCADMTYPNextAff = Ktb_PeriCaract[n_IndAff + 1].n_ACCADMTYP_CT;

      /* Boucle sur Tsup pour l'exercice d'affichage ->Nles lignes dans Tsup */
      for (n_IndTsup = 0; n_IndTsup < (n_MaxAffTsup - n_MinAffTsup); n_IndTsup++)
      {
        b_Generate = 0;
        n_CursTsup = n_IndTsup + n_MinAffTsup;

        if (Ktb_Tsup[n_CursTsup].PRM_M != 0)
        {
          d_RPP = 0;

          if (strcmp(Ktb_PeriCaract[n_IndAff].sz_EXP_D, Ksz_CLODAT) < 0
              /* On ne fait pas de calcul de RPP pour l'EPP initiale */
              && Ktb_Tsup[n_CursTsup].UWY_NF >= Ktb_PeriCaract[0].n_UWY_NF
              /* On ne calcule pas avec la date de fin d'exercice pour type 4 et 5 (resilies)*/
              && Ktb_PeriCaract[n_IndAff].n_ACCADMTYP_CT != 4
              && Ktb_PeriCaract[n_IndAff].n_ACCADMTYP_CT != 5)
          {
            /* Calcul avec la date de calcul = date d'echeance de l'exercice d'affichage */
            sprintf(sz_CALC_D, "%04d1231", n_ExAff);
            d_RPP = d_PPNAAvecDecalage( Ktb_Tsup[n_CursTsup].UWY_NF,
                                        Ktb_Tsup[n_CursTsup].SCOSTRMTH_NF,
                                        Ktb_Tsup[n_CursTsup].UWY_NF,
                                        Ktb_Tsup[n_CursTsup].SCOENDMTH_NF,
                                        Ktb_PeriCaract[n_IndAff].n_DIFMTH_NF,
                                        Ktb_PeriCaract[n_IndAff].n_POLDURMTH_NF,
                                        Ktb_PeriCaract[n_IndAff].sz_SECINC_D,
                                        Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                        Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                        Ktb_PeriCaract[n_IndAff].d_INSPOL_R,
                                        Ktb_Tsup[n_CursTsup].PRM_M,
                                        Ktb_PeriCaract[n_IndAff].n_ERNPRMADM_B,
                                        Ktb_PeriCaract[n_IndAff].n_UWY_NF);
            b_Generate = 1;
          }
          else
          {
            /* Calcul avec la date de calcul = date d'arrete */

            /* prime non issue de la prime de base (Exercice  present dans perimetre */
            if (Ktb_Tsup[n_CursTsup].UWY_NF >= Ktb_PeriCaract[0].n_UWY_NF)
               d_RPP = d_PPNAAvecDecalage( Ktb_Tsup[n_CursTsup].UWY_NF,
                                           Ktb_Tsup[n_CursTsup].SCOSTRMTH_NF,
                                           Ktb_Tsup[n_CursTsup].UWY_NF,
                                           Ktb_Tsup[n_CursTsup].SCOENDMTH_NF,
                                           Ktb_PeriCaract[n_IndAff].n_DIFMTH_NF,
                                           Ktb_PeriCaract[n_IndAff].n_POLDURMTH_NF,
                                           Ktb_PeriCaract[n_IndAff].sz_SECINC_D,
                                           Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                           Ksz_CLODAT,
                                           Ktb_PeriCaract[n_IndAff].d_INSPOL_R,
                                           Ktb_Tsup[n_CursTsup].PRM_M,
                                           Ktb_PeriCaract[n_IndAff].n_ERNPRMADM_B,
                                           Ktb_PeriCaract[n_IndAff].n_UWY_NF);
            else
              /* prime issue de la prime de base (Exercice  present dans perimetre */
              d_RPP = d_PPNAAvecDecalage( Ktb_Tsup[n_CursTsup].UWY_NF,
                                          Ktb_Tsup[n_CursTsup].SCOSTRMTH_NF,
                                          Ktb_Tsup[n_CursTsup].UWY_NF,
                                          Ktb_Tsup[n_CursTsup].SCOENDMTH_NF,
                                          Ktb_PeriCaract[0].n_DIFMTH_NF,
                                          12,
                                          sz_Deff0, /* Deja calc au traitement prealable*/
                                          sz_Dech0, /* Deja calc au traitement prealable*/
                                          Ksz_CLODAT,
                                          1,
                                          Ktb_Tsup[n_CursTsup].PRM_M,
                                          Ktb_PeriCaract[0].n_ERNPRMADM_B,
                                          Ktb_PeriCaract[0].n_UWY_NF);
          }

		   Ktb_Tsup[n_CursTsup].RPPEA_M = (-1) * d_RPP;

          if (d_RPP != 0 && b_Generate == 1 && d_PartNextAff != 0)
          {
            /* Creation d'une ligne supplementaire dans Tsup */
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].CLODAT_D,  Ksz_CLODAT);
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].CTR_NF,    Ktb_Tsup[n_CursTsup].CTR_NF);
            Ktb_Tsup[n_MaxAffTsup + n_Generees].END_NT =          Ktb_Tsup[n_CursTsup].END_NT;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SEC_NF =          Ktb_Tsup[n_CursTsup].SEC_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UWY_NF =          Ktb_Tsup[n_CursTsup].UWY_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UW_NT  =          Ktb_Tsup[n_CursTsup].UW_NT;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].ACY_NF =          Ktb_Tsup[n_CursTsup].ACY_NF + 1;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SCOSTRMTH_NF =    Ktb_Tsup[n_CursTsup].SCOSTRMTH_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SCOENDMTH_NF =    Ktb_Tsup[n_CursTsup].SCOENDMTH_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UWYDIS_NF =       1 + Ktb_Tsup[n_CursTsup].UWYDIS_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SSD_CF =          Ktb_Tsup[n_CursTsup].SSD_CF;
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].WFCOD_NT,  "8000");
            Ktb_Tsup[n_MaxAffTsup + n_Generees].WFTYP_CF =        Ktb_Tsup[n_CursTsup].WFTYP_CF;
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].EGPCUR_CF, Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF);

            /* Modication OLR du 25/08/98 pour la prise en compte du taux de change */
            d_RatioEPP = 1;
            d_RatioPRM = 1;

            if (strcmp(Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF, Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) != 0)
            {
              d_RatioEPP = d_GetTaux( Kp_InputFilExc,
                                      (char)Ktb_PeriCaract[n_IndAff].n_SSD_CF,
                                      n_CLOYEA_NF,
                                      Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                                      Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) ;

              d_RatioPRM = d_GetTaux( Kp_InputFilExc,
                                      (char)Ktb_PeriCaract[n_IndAff].n_SSD_CF,
                                      Ktb_Tsup[n_CursTsup].UWY_NF,
                                      Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                                      Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) ;

              /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
              if ((d_RatioEPP < 0) || (d_RatioPRM < 0))
              {
                if (d_RatioEPP < 0)
                {
                  sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %d - UW %s ) \n",
                           Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF,
                           Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                           ptb_InRec_Cur[PER_CTR_NF],
                           ptb_InRec_Cur[PER_END_NT],
                           ptb_InRec_Cur[PER_SEC_NF],
                           n_CLOYEA_NF,
                           ptb_InRec_Cur[PER_UW_NT] ) ;
                  d_RatioEPP = 1;
                }

                if (d_RatioPRM < 0)
                {
                  sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %d - UW %s ) \n",
                           Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF,
                           Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                           ptb_InRec_Cur[PER_CTR_NF],
                           ptb_InRec_Cur[PER_END_NT],
                           ptb_InRec_Cur[PER_SEC_NF],
                           Ktb_Tsup[n_CursTsup].UWY_NF,
                           ptb_InRec_Cur[PER_UW_NT] ) ;
                  d_RatioPRM = 1;
                }

                n_WriteAno( MsgAno ) ;
              }
            }

            /* Fin de la modification pour Taux de change */
            Ktb_Tsup[n_MaxAffTsup + n_Generees].PRM_M = d_RatioPRM * d_PartNextAff * (Ktb_Tsup[n_CursTsup].PRM_M / d_PartAff);

            /* l'EPP pour Aff+1 = -RPP pour Aff */
			Ktb_Tsup[n_MaxAffTsup + n_Generees].EPPEA_M = d_RatioEPP * (-1) * d_PartNextAff * (Ktb_Tsup[n_CursTsup].RPPEA_M / d_PartAff);			
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SHR_R = d_PartNextAff;

            Ktb_Tsup[n_MaxAffTsup + n_Generees].ACCADMTYP_CT = n_ACCADMTYPNextAff;

            n_Generees++;
          } /* Fin de la condition de generation d'une nouvelle ligne */
        } /* Fin du Test PRM!=0 */
      } /* Fin de la boucle sur Tsup pour l'exercice d'affichage en cours */

      /* Petite synchro sur Tinit au cas ou manquerais un exercice d'afichage */
      while ( n_CursTinit < Kn_NbLTinit && Ktb_Tinit[n_CursTinit].UWYDIS_NF != n_ExAff && Ktb_Tinit[n_CursTinit].UWYDIS_NF < n_ExAff )
        n_CursTinit++;

      /* Rajout OLR pour accrochage du premier exercice d'affichage de Tinit 23/07/1998*/
      if (Ktb_Tinit[n_CursTinit].UWYDIS_NF > n_ExAff)
      {
        n_ExAff = Ktb_Tinit[n_CursTinit].UWYDIS_NF;
        d_PartAff = 0;
        d_PartNextAff = 0;

        n_IndAff = n_CherchePeriIndAff(n_ExAff);
        d_PartAff = d_ChercheTinitPart(n_ExAff);

        /* Recherche part SCOR et type comptable de l'exercice suivant */
        if (n_ExAff < Ktb_PeriCaract[Kn_NbLPeriCaract - 1].n_UWY_NF)
          d_PartNextAff = d_ChercheTinitPart(n_ExAff + 1);

        n_ACCADMTYPNextAff = Ktb_PeriCaract[n_IndAff + 1].n_ACCADMTYP_CT;
      }
      /* Fin Rajout OLR 23/07/1998 */

      /* Boucle sur les lignes de Tinit correspondant a l'exercice d'affichage*/
      while (n_CursTinit < Kn_NbLTinit && Ktb_Tinit[n_CursTinit].UWYDIS_NF == n_ExAff)
      {
        b_Generate = 0;

        if (Ktb_Tinit[n_CursTinit].PRM_M != 0)
        {
          d_RPP = 0;

          if ( strcmp(Ktb_PeriCaract[n_IndAff].sz_EXP_D, Ksz_CLODAT) < 0
               /* On ne calcule pas avec la date de fin d'exercice pour type 4 et 5 (resilies)*/
               && Ktb_PeriCaract[n_IndAff].n_ACCADMTYP_CT != 4
               && Ktb_PeriCaract[n_IndAff].n_ACCADMTYP_CT != 5)
          {
            /* Calcul avec la date de calcul = date d'echeance de l'exercice d'affichage */
            sprintf(sz_CALC_D, "%04d1231", n_ExAff);
            d_RPP = d_PPNAAvecDecalage( Ktb_Tinit[n_CursTinit].ACY_NF,
                                        Ktb_Tinit[n_CursTinit].SCOSTRMTH_NF,
                                        Ktb_Tinit[n_CursTinit].ACY_NF,
                                        Ktb_Tinit[n_CursTinit].SCOENDMTH_NF,
                                        Ktb_PeriCaract[n_IndAff].n_DIFMTH_NF,
                                        Ktb_PeriCaract[n_IndAff].n_POLDURMTH_NF,
                                         
                                        Ktb_PeriCaract[n_IndAff].sz_SECINC_D,
                                        Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                        Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                        Ktb_PeriCaract[n_IndAff].d_INSPOL_R,
                                        Ktb_Tinit[n_CursTinit].PRM_M,
                                        Ktb_PeriCaract[n_IndAff].n_ERNPRMADM_B,
                                        Ktb_PeriCaract[n_IndAff].n_UWY_NF);

            b_Generate = 1;
          }
          else
            /* Calcul avec la date de calcul = date d'arrete */
            d_RPP = d_PPNAAvecDecalage ( Ktb_Tinit[n_CursTinit].ACY_NF,
                                         Ktb_Tinit[n_CursTinit].SCOSTRMTH_NF,
                                         Ktb_Tinit[n_CursTinit].ACY_NF,
                                         Ktb_Tinit[n_CursTinit].SCOENDMTH_NF,
                                         Ktb_PeriCaract[n_IndAff].n_DIFMTH_NF,
                                         Ktb_PeriCaract[n_IndAff].n_POLDURMTH_NF,
                                         Ktb_PeriCaract[n_IndAff].sz_SECINC_D,
                                         Ktb_PeriCaract[n_IndAff].sz_EXP_D,
                                         Ksz_CLODAT,
                                         Ktb_PeriCaract[n_IndAff].d_INSPOL_R,
                                         Ktb_Tinit[n_CursTinit].PRM_M,
                                         Ktb_PeriCaract[n_IndAff].n_ERNPRMADM_B,
                                         Ktb_PeriCaract[n_IndAff].n_UWY_NF);

			Ktb_Tinit[n_CursTinit].RPPEA_M = (-1) * d_RPP;
			
          if (d_RPP != 0 && b_Generate == 1 && d_PartNextAff != 0)
          {
            /* Creation d'une ligne supplementaire dans Tsup */
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].CLODAT_D,  Ksz_CLODAT);
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].CTR_NF,    Ktb_Tinit[n_CursTinit].CTR_NF);
            Ktb_Tsup[n_MaxAffTsup + n_Generees].END_NT =          Ktb_Tinit[n_CursTinit].END_NT;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SEC_NF =          Ktb_Tinit[n_CursTinit].SEC_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UWY_NF =          Ktb_Tinit[n_CursTinit].UWY_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UW_NT  =          Ktb_Tinit[n_CursTinit].UW_NT;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].ACY_NF =          Ktb_Tinit[n_CursTinit].ACY_NF + 1;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SCOSTRMTH_NF =    Ktb_Tinit[n_CursTinit].SCOSTRMTH_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SCOENDMTH_NF =    Ktb_Tinit[n_CursTinit].SCOENDMTH_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].UWYDIS_NF =       1 + Ktb_Tinit[n_CursTinit].UWYDIS_NF;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SSD_CF =          Ktb_Tinit[n_CursTinit].SSD_CF;
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].WFCOD_NT,  "8000");
            Ktb_Tsup[n_MaxAffTsup + n_Generees].WFTYP_CF =        Ktb_Tinit[n_CursTinit].WFTYP_CF;
            strcpy(Ktb_Tsup[n_MaxAffTsup + n_Generees].EGPCUR_CF, Ktb_Tinit[n_CursTinit].EGPCUR_CF);

            /* Modication OLR du 25/08/98 pour la prise en compte du taux de change */
            d_RatioEPP = 1;
            d_RatioPRM = 1;	

            if (strcmp(Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF, Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) != 0)
            {
              d_RatioEPP = d_GetTaux( Kp_InputFilExc,
                                      (char)Ktb_PeriCaract[n_IndAff].n_SSD_CF,
                                      n_CLOYEA_NF,
                                      Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                                      Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) ;

              d_RatioPRM = d_GetTaux( Kp_InputFilExc,
                                      (char)Ktb_PeriCaract[n_IndAff].n_SSD_CF,
                                      Ktb_Tinit[n_CursTinit].UWY_NF,
                                      Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                                      Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF) ;

              /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
              if ((d_RatioEPP < 0) || (d_RatioPRM < 0))
              {
                if (d_RatioEPP < 0)
                {
                  sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %d - UW %s ) \n",
                           Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF,
                           Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                           ptb_InRec_Cur[PER_CTR_NF],
                           ptb_InRec_Cur[PER_END_NT],
                           ptb_InRec_Cur[PER_SEC_NF],
                           n_CLOYEA_NF,
                           ptb_InRec_Cur[PER_UW_NT] ) ;
                  d_RatioEPP = 1;
                }

                if (d_RatioPRM < 0)
                {
                  sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %d - UW %s ) \n",
                           Ktb_PeriCaract[n_IndAff + 1].sz_EGPCUR_CF,
                           Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,
                           ptb_InRec_Cur[PER_CTR_NF],
                           ptb_InRec_Cur[PER_END_NT],
                           ptb_InRec_Cur[PER_SEC_NF],
                           Ktb_Tinit[n_CursTinit].UWY_NF,
                           ptb_InRec_Cur[PER_UW_NT] ) ;
                  d_RatioPRM = 1;
                }

                n_WriteAno( MsgAno ) ;
              }
            }

            Ktb_Tsup[n_MaxAffTsup + n_Generees].PRM_M = d_RatioPRM * d_PartNextAff * (Ktb_Tinit[n_CursTinit].PRM_M / d_PartAff);

            /* l'EPP pour Aff+1 = -RPP pour Aff */
			Ktb_Tsup[n_MaxAffTsup + n_Generees].EPPEA_M = d_RatioEPP * (-1) * d_PartNextAff * (Ktb_Tinit[n_CursTinit].RPPEA_M / d_PartAff);							
            Ktb_Tsup[n_MaxAffTsup + n_Generees].SHR_R = d_PartNextAff;
            Ktb_Tsup[n_MaxAffTsup + n_Generees].ACCADMTYP_CT = n_ACCADMTYPNextAff;

            n_Generees++;
          } /* Fin de la condition de generation d'une nouvelle ligne */
        } /* Fin du Test PRM!=0 */

        n_CursTinit++;
      } /* Fin boucle sur Tinit pour l'exercice d'affichage en cours */

      n_MinAffTsup = n_MaxAffTsup;
      n_MaxAffTsup = n_MaxAffTsup + n_Generees;

      n_ExAff++;
    }
    while (n_CursTinit < Kn_NbLTinit && strcmp(Ktb_PeriCaract[n_IndAff].sz_EXP_D, Ksz_CLODAT) < 0 && n_ExAff <= n_MaxExAff); //[009]

    /* Fin du do, on s'arrete si on n'a rien genere dans tsup ou si la date de fin de l'exercice d'affichage > libelle d'inventaire */
    /* On decharge Tsup et Tinit dans le fichier de travail */
    for (n_CursTsup = 0; n_CursTsup < n_MaxAffTsup; n_CursTsup++) {
      n_WriteFTTr(&Ktb_Tsup[n_CursTsup]);
    }

    for (n_CursTinit = 0; n_CursTinit < Kn_NbLTinit; n_CursTinit++) {
      n_WriteFTTr(&Ktb_Tinit[n_CursTinit]);
    }

    /*--------------------------------------------------------*/
    /* Analyse de Tsup et Tinit pour les Ecritures dans le GT */
    /*--------------------------------------------------------*/
    /* eclatement de la date de passage d'inventaire */
    o_ExtractionAnneeMois(Ksz_CLODAT, &n_CLOYEA_NF, &n_CLOMTH_NF);
    n_CursTsup = Kn_NbLTsup;
    n_CursTinit = 0;

    /* Boucle par Exercice d'affichage */
    for (n_ExAff = Ktb_Tinit[0].UWYDIS_NF; n_ExAff <= n_CLOYEA_NF; n_ExAff++)
    {
      n_IndAff = n_CherchePeriIndAff(n_ExAff);

      /* Initialisation des bits de comptes cedantes a non trouves */
      //[020] begin
      b_lPPNACZeroing = 0;
      b_EPPC = 0;
      b_RPPCZeroing = 0;
      b_PPNACZeroing = 0;
      
      b_RPPC = 0;
      b_PPNAC = 0;
      b_lPPNAC = 0;
      //[020] end

      /* initialisation des sommes d' EPP cedante, EPP estimee ou actualisee? RPP estimee ou actualisee */
      d_SumEPPc = 0;
      d_SumEPPe = 0;
      d_SumEPPa = 0;
      d_SumRPPe = 0;
      d_SumRPPa = 0;
	  
      //[020] begin
      d_SumRPPcZeroing = 0;
      d_SumPPNAcZeroing = 0;
      
      d_SumRPPc = 0;
      d_SumPPNAc = 0;
      d_SumLPPNAc = 0;

      d_SumLPPNAcZeroing = 0;
      //[020 end

      /* Petite synchro sur Tinit pour trouver (ou pas)l'Exercice d'aff */
      // [007] -=Dch=-
      while ((Ktb_Tinit[n_CursTinit].UWYDIS_NF < n_ExAff) && (n_CursTinit < Kn_NbreTinitMAX))
      {
        n_CursTinit ++;
      }
      /*Boucle sur Tinit pour Trouver les lignes correspondant a l'exercice d'affichage(=Annee de compte pour types 1 et 3) */
      while (Ktb_Tinit[n_CursTinit].UWYDIS_NF == n_ExAff && n_CursTinit < Kn_NbLTinit)
      {
        /* recuperation des estimations */
        if (Ktb_Tinit[n_CursTinit].WFTYP_CF == 'E')
        {
			d_SumEPPe = d_SumEPPe + Ktb_Tinit[n_CursTinit].EPPEA_M;
			d_SumRPPe = d_SumRPPe + Ktb_Tinit[n_CursTinit].RPPEA_M;
        }

        if (Ktb_Tinit[n_CursTinit].WFTYP_CF == 'C')
        {
          d_SumEPPa = d_SumEPPa + Ktb_Tinit[n_CursTinit].EPPEA_M;
          d_SumRPPa = d_SumRPPa + Ktb_Tinit[n_CursTinit].RPPEA_M;
        }

        /* recuperation des comptes cedantes (uniquement dans Tinit) */
        /* 019 ACY = CLOSING YEAR */ 

        o_ExtractionAnneeMois(Ksz_CLODAT, &n_CURCLODAT_Y, &n_CURCLODAT_M);

        if (Ktb_Tinit[n_CursTinit].LPPNAC_M != 0 && n_CURCLODAT_Y == Ktb_Tinit[n_CursTinit].ACY_NF)
        {
          d_SumLPPNAcZeroing = d_SumLPPNAcZeroing + Ktb_Tinit[n_CursTinit].LPPNAC_M;
        }

        if (Ktb_Tinit[n_CursTinit].EPPC_M != 0)
        {
          d_SumEPPc = d_SumEPPc + Ktb_Tinit[n_CursTinit].EPPC_M;
        }

        if (Ktb_Tinit[n_CursTinit].RPPC_M != 0 && n_CURCLODAT_Y == Ktb_Tinit[n_CursTinit].ACY_NF)
        {
          d_SumRPPcZeroing = d_SumRPPcZeroing + Ktb_Tinit[n_CursTinit].RPPC_M;
        }

        if (Ktb_Tinit[n_CursTinit].PPNAC_M != 0 && n_CURCLODAT_Y == Ktb_Tinit[n_CursTinit].ACY_NF)
        {
          d_SumPPNAcZeroing = d_SumPPNAcZeroing + Ktb_Tinit[n_CursTinit].PPNAC_M;
        }

        //[020] begin
        if (Ktb_Tinit[n_CursTinit].LPPNAC_M != 0)
        {
          d_SumLPPNAc = d_SumLPPNAc + Ktb_Tinit[n_CursTinit].LPPNAC_M;
        }

        if (Ktb_Tinit[n_CursTinit].RPPC_M != 0)
        {
          d_SumRPPc = d_SumRPPc + Ktb_Tinit[n_CursTinit].RPPC_M;
        }

        if (Ktb_Tinit[n_CursTinit].PPNAC_M != 0)
        {
          d_SumPPNAc = d_SumPPNAc + Ktb_Tinit[n_CursTinit].PPNAC_M;
        }
        //[020] end      

        n_CursTinit++;
      }

      /* Si la somme des montants Cedantes est non nulle on met le bit de presence a 1*/
      if (fabs(d_SumLPPNAcZeroing) >= 1)
        b_lPPNACZeroing = 1;
      if (fabs(d_SumEPPc) >= 1)
        b_EPPC = 1;
      if (fabs(d_SumRPPcZeroing) >= 1)
        b_RPPCZeroing = 1;
      if (fabs(d_SumPPNAcZeroing) >= 1)
        b_PPNACZeroing = 1;
      
      //[020] begin
      if (fabs(d_SumLPPNAc) >= 1)
        b_lPPNAC = 1;
      if (fabs(d_SumRPPc) >= 1)
        b_RPPC = 1;
      if (fabs(d_SumPPNAc) >= 1)
        b_PPNAC = 1;
      //[020 end

      /*Boucle sur Tsup pour Trouver les lignes correspondant a l'exercice d'affichage(=Annee de compte pour types 1 et 3) */

      /* Petite synchro sur Tsup pour trouver (ou pas)l'Exercice d'aff */
      //[007] -=Dch=-
      while (Ktb_Tsup[n_CursTsup].UWYDIS_NF < n_ExAff && n_CursTsup < Kn_NbreTsupMAX )
        n_CursTsup++;

      while (Ktb_Tsup[n_CursTsup].UWYDIS_NF == n_ExAff && n_CursTsup < Kn_NbreTsupMAX)
      {
        /* recuperation des estimations */
        if (Ktb_Tsup[n_CursTsup].WFTYP_CF == 'E')
        {
			d_SumEPPe = d_SumEPPe + Ktb_Tsup[n_CursTsup].EPPEA_M;
			d_SumRPPe = d_SumRPPe + Ktb_Tsup[n_CursTsup].RPPEA_M;
        }

        if (Ktb_Tsup[n_CursTsup].WFTYP_CF == 'C')
        {
          d_SumEPPa = d_SumEPPa + Ktb_Tsup[n_CursTsup].EPPEA_M;
          d_SumRPPa = d_SumRPPa + Ktb_Tsup[n_CursTsup].RPPEA_M;
        }

        n_CursTsup++;
      }

      /* Calcul des bits d'ecriture d'EPP et de RPP dans le GT */
      b_EcrireEPPech = (b_EPPC && Ktb_PeriCaract[n_IndAff].n_PRMPRTSCL_B == 1 && d_SumEPPe != d_SumEPPc);

      //[020] begin
      b_EcrireEPPe = !b_EPPC && !b_lPPNACZeroing && (d_SumEPPe != 0);
      b_EcrireEPPa = !b_EPPC && !b_lPPNACZeroing && (d_SumEPPa != 0);
      b_EcrireRPPa = !b_RPPCZeroing && !b_PPNACZeroing  && (d_SumRPPa != 0);
      b_EcrireEPPa_2 = !b_EPPC && !b_lPPNAC && (d_SumEPPa != 0);
      b_EcrireRPPe = !b_RPPC && !b_PPNAC  && (d_SumRPPe != 0);
      b_EcrireRPPa_2 = !b_RPPC && !b_PPNAC  && (d_SumRPPa != 0);
      //[020] end

      /* [018] [019] [020]*/ 
      b_EcrirePPNAC = b_PPNACZeroing;
      b_EcrireLPPNAC = b_lPPNACZeroing;
      d_SumPPNACZeroing = -1 *  d_SumPPNAcZeroing;
      d_SumPPNACZeroing_2 = d_SumPPNAcZeroing + d_SumLPPNAcZeroing + d_SumRPPcZeroing;
      d_SumLPPNAcZeroing_2 = -1 * d_SumLPPNAcZeroing;

      /* Appel du module d'Ecriture dans le GT */
      if (b_EcrireEPPech)
      {
        n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                    "11300002",
                    d_SumEPPe - d_SumEPPc,
                    n_IndAff,
                    n_CLOYEA_NF,
                    n_CLOMTH_NF,
                    n_CLOMTH_NF,
                    1,
                    Kp_dGTAaEPP_Fil,
                    0);
      }

      if (b_EcrireEPPe)
      {
        n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                    "11300002",
                    d_SumEPPe,
                    n_IndAff,
                    n_ExAff,
                    1,
                    1,
                    0,
                    Kp_dGTAaEPP_Fil,
                    0);
      }
      // spot 28140 Modificaiton   des parametres d'appel de la fonction n_CalculExerciceSeuil
      //[020] b_EcrireEPPa_2 
      if ( n_CursTinit > 0 &&
           ((Ktb_Tinit[n_CursTinit - 1 ].UWYDIS_NF) > (n_CalculExerciceSeuil( atoi(ptb_InRec_Cur[PER_SSD_CF]), atoi(ptb_InRec_Cur[PER_ACCESB_CF]), ptb_InRec_Cur[PER_LOB_CF], atoi(ptb_InRec_Cur[PER_NAT_CF]) )  ))   &&
           (b_EcrireEPPa_2))
      {
        n_EcrireGT(&Ktb_Tinit[n_CursTinit - 1],
                   "11300006",
                   d_SumEPPa,
                   n_IndAff,
                   n_ExAff,
                   1,
                   1,
                   0,
                   Kp_dGTAaEPP_Fil
                   , 0);
      }

      /* date de passage des RPP */
      if (n_ExAff < n_CLOYEA_NF)
      {
        n_CLOMTH_NF = 12 ;
        b_Decalage = 0;
      }
      else
        b_Decalage = 1;


      if (b_EcrireRPPe)
      {
        n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                    "11301002",
                    d_SumRPPe,
                    n_IndAff,
                    n_ExAff,
                    n_CLOMTH_NF,
                    n_CLOMTH_NF,
                    b_Decalage,
                    Kp_dGTAaRPP_Fil,
                    1);
      }
      // spot 28140 Modificaiton des parametres d'appel de la fonction n_CalculExerciceSeuil
      /* Modification GLE le 17/02/2016 - ajout d'une condition en sortie sur la méthode de cession de prime */
      //On va chercher dans le péricase la prime émise pour l'exercice qu'on doit écrire
      //[020] begin b_EcrireRPPa_2
      if ( n_CursTinit > 0 &&
           ((Ktb_Tinit[n_CursTinit - 1].UWYDIS_NF) >= (n_CalculExerciceSeuil(atoi(ptb_InRec_Cur[PER_SSD_CF]), atoi(ptb_InRec_Cur[PER_ACCESB_CF]), ptb_InRec_Cur[PER_LOB_CF], atoi(ptb_InRec_Cur[PER_NAT_CF]))))
           && (b_EcrireRPPa_2))
      {
        n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                    "11301006",
                    d_SumRPPa,
                    n_IndAff,
                    n_ExAff,
                    n_CLOMTH_NF,
                    n_CLOMTH_NF,
                    b_Decalage,
                    Kp_dGTAaRPP_Fil,
                    1);
      }
      //[020] end

      //[018] [019]
      if ( b_EcrirePPNAC && (d_SumPPNACZeroing != 0) )
      {

        //n_ActionLigneFTTrbis( ptb_InRec_Cur, NULL, d_SumPPNACZeroing);

        n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                     "11410002",
                     d_SumPPNACZeroing,
                     n_IndAff,
                     n_ExAff,
                     n_CLOMTH_NF,
                     n_CLOMTH_NF,
                     b_Decalage,
                     Kp_dGTAaTrPNA_Fil,
                     1);
      
        if ( b_EcrireLPPNAC && (d_SumLPPNAcZeroing_2 != 0) ) 
        {
       
         n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                     "11301002",
                     d_SumPPNACZeroing_2,
                     n_IndAff,
                     n_ExAff,
                     n_CLOMTH_NF,
                     n_CLOMTH_NF,
                     b_Decalage,
                     Kp_dGTAaRPP_Fil,
                     1);
        }
      }

      //[018] [019]
      //if ( b_EcrireLPPNAC && (d_SumLPPNAcZeroing_2 != 0) )
      //{

        //n_ActionLigneFTTrbis( ptb_InRec_Cur, NULL, d_SumPPNACZeroing);

        /*n_EcrireGT( &Ktb_Tinit[n_CursTinit - 1],
                     "11411002",
                     d_SumLPPNAcZeroing_2,
                     n_IndAff,
                     n_ExAff,
                     n_CLOMTH_NF,
                     n_CLOMTH_NF,
                     b_Decalage,
                     Kp_dGTAaTrPNA_Fil,
                     1);
      }*/
    } /* Fin de la bouble sur les Exercices d'affichage */

  }/* Fin des operations pour les traites proportionnels de type 1 et 3 */

  RETURN_VAL(0);
}


/*==============================================================================
objet : Initialisation de la synchronisation du PERIMETRE avec l'esclave FTTr
retour: 0
===============================================================================*/
int n_InitFTTr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitFTTr");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTC1010_I2", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync  = n_ConditionSyncFTTr ;         /* fonction du test de la ligne du maitre avec l'esclave */
  pbd_Rupt->n_ActionLigne     = n_ActionLigneFTTr ;           /* fonction d'action sur la ligne courante du fichier esclave */
  pbd_Rupt->n_FilsSansPere    = n_ActionFilsSansPereFTTr ;

  pbd_Rupt->c_Separ         = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de synchro
retour: 0 ---> synchro
      sinon, non trouve
==============================================================================*/
/*                adresse de la ligne du maitre, de l'esclave */
int n_ConditionSyncFTTr( char **pbd_InRecOwner , char **pbd_InRecChild )
{
  static    int ret;

  DEBUT_FCT("n_ConditionSyncFTTr");

  if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FT_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FT_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FT_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FT_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FT_UW_NT])) != 0) return ret;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne de FTTr qui n'a pas de correspondance
        dans le PERIMETRE.
        Ces lignes correspondent normalement a l'aliment factice calcule pour
        l'exercice precedent le premier exercice de souscription.
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereFTTr(char **ptb_InRecChild )
{
  DEBUT_FCT("n_ActionFilsSansPereFTTr");
  if (atoi(ptb_InRecChild[FT_WFCOD_NT]) == 9000)
  {
    if (Kn_NbLTsup == Kn_NbreTsupMAX)
    {
      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s : maximum number of UWY/UW is reached ; increase Kn_NbreTsupMAX value", ptb_InRecChild[FT_CTR_NF], ptb_InRecChild[FT_END_NT], ptb_InRecChild[FT_SEC_NF]);
      n_WriteAno( Ksz_MessageErr);
    }
    else
    {
      /* chargement dans Tsup */
      strcpy(Ktb_Tsup[Kn_NbLTsup].CLODAT_D,   ptb_InRecChild[FT_CLODAT_D]);
      strcpy(Ktb_Tsup[Kn_NbLTsup].CTR_NF,     ptb_InRecChild[FT_CTR_NF]);
      Ktb_Tsup[Kn_NbLTsup].END_NT =           atoi(ptb_InRecChild[FT_END_NT]);
      Ktb_Tsup[Kn_NbLTsup].SEC_NF =           atoi(ptb_InRecChild[FT_SEC_NF]);
      Ktb_Tsup[Kn_NbLTsup].UWY_NF =           atoi(ptb_InRecChild[FT_UWY_NF]);
      Ktb_Tsup[Kn_NbLTsup].UW_NT =            atoi(ptb_InRecChild[FT_UW_NT]);
      Ktb_Tsup[Kn_NbLTsup].ACY_NF =           atoi(ptb_InRecChild[FT_ACY_NF]);
      Ktb_Tsup[Kn_NbLTsup].SCOSTRMTH_NF =     atoi(ptb_InRecChild[FT_SCOSTRMTH_NF]);
      Ktb_Tsup[Kn_NbLTsup].SCOENDMTH_NF =     atoi(ptb_InRecChild[FT_SCOENDMTH_NF]);
      Ktb_Tsup[Kn_NbLTsup].UWYDIS_NF =        atoi(ptb_InRecChild[FT_UWYDIS_NF]);
      Ktb_Tsup[Kn_NbLTsup].SSD_CF =           atoi(ptb_InRecChild[FT_SSD_CF]);
      strcpy(Ktb_Tsup[Kn_NbLTsup].WFCOD_NT,   ptb_InRecChild[FT_WFCOD_NT]);
      Ktb_Tsup[Kn_NbLTsup].WFTYP_CF =         *ptb_InRecChild[FT_WFTYP_CF];
      strcpy(Ktb_Tsup[Kn_NbLTsup].EGPCUR_CF,  ptb_InRecChild[FT_EGPCUR_CF]);
      Ktb_Tsup[Kn_NbLTsup].PRM_M =            (double)atof(ptb_InRecChild[FT_PRM_M]);
      Ktb_Tsup[Kn_NbLTsup].PPNAC_M =          (double)atof(ptb_InRecChild[FT_PPNAC_M]);
      Ktb_Tsup[Kn_NbLTsup].PPNAEA_M =         (double)atof(ptb_InRecChild[FT_PPNAEA_M]);
      Ktb_Tsup[Kn_NbLTsup].RPPC_M =           (double)atof(ptb_InRecChild[FT_RPPC_M]);
      Ktb_Tsup[Kn_NbLTsup].RPPEA_M =          (double)atof(ptb_InRecChild[FT_RPPEA_M]);
      Ktb_Tsup[Kn_NbLTsup].LPPNAC_M =         (double)atof(ptb_InRecChild[FT_LPPNAC_M]);
      Ktb_Tsup[Kn_NbLTsup].EPPC_M =           (double)atof(ptb_InRecChild[FT_EPPC_M]);
      Ktb_Tsup[Kn_NbLTsup].EPPEA_M =          (double)atof(ptb_InRecChild[FT_EPPEA_M]);
      Ktb_Tsup[Kn_NbLTsup].RECC_M =           (double)atof(ptb_InRecChild[FT_RECC_M]);
      Ktb_Tsup[Kn_NbLTsup].RECE_M =           (double)atof(ptb_InRecChild[FT_RECE_M]);
      Ktb_Tsup[Kn_NbLTsup].BCC_M =            (double)atof(ptb_InRecChild[FT_BCE_M]);
      Ktb_Tsup[Kn_NbLTsup].SHR_R =            (double)atof(ptb_InRecChild[FT_SHR_R]);
      Ktb_Tsup[Kn_NbLTsup].ACCADMTYP_CT =     (double)atof(ptb_InRecChild[FT_ACCADMTYP_CT]);

      Kn_NbLTsup++;
    }

    RETURN_VAL(0);
  }

  RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne de FTTr synchronisee avec le PER
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
/*             adresse de la ligne du maitre, de l'esclave */
int n_ActionLigneFTTr( char **ptb_InRecOwner, char **ptb_InRecChild )
{
  double d_PRIME = 0,   /* prime de la periode  */
         d_PPNAe = 0,   /* PPNA calculee        */
         d_INSPOL_R = 1, /* Taux des polices     */
         d_PPNAe_earned = 0 ; /* PPNA à 0 ou non calcule pour les traites dont  earned = "O" */

  char  sz_PPNAe[30],
  			sz_PPNAe007[30],       //[024]
        sz_LibPlusDec[9],
        sz_TRNCOD_CF[9];

  int n_SCOENDm,        /* mois de fin de periode cedante   */
      n_SCOENDa,        /* annee de fin de periode cedante  */
      n_SCOSTRm,        /* mois de debut de periode cedante */
      n_SCOSTRa,        /* annee de debut de periode cedante*/
      n_FinMoinsLib, n_LibMoinsDeb, n_FinMoinsDeb,
      n_DIFMTH_NF,      /* decalage(negatif)                */
      n_MoinsDIFMTH_NF, /* oppose du decalage (positif)     */
      n_POLDURMTH_NF,   /* Duree des polices                */
      n_LibPlusDeca,    /* annee libelle d'inventaire plus decalage */
      n_LibPlusDecm;    /* mois libelle d'inventaire plus decalage  */


  char sz_LibPlusDeca[5];   //[006]
  char *tmp_ACY_NF;         //[006]

  DEBUT_FCT("n_ActionLigneFTTr");
  /*----------------------------------------------*/
  /* Preliminaires calculs sur les dates          */
  /*----------------------------------------------*/

  /* Conversions das zones employees lors des calculs */
  n_DIFMTH_NF = atoi(ptb_InRecOwner[PER_DIFMTH_NF]);
  n_MoinsDIFMTH_NF = -1 * n_DIFMTH_NF;
  d_INSPOL_R = atof(ptb_InRecOwner[PER_INSPOL_R]);
  n_POLDURMTH_NF = atoi(ptb_InRecOwner[PER_POLDURMTH_NF]);
  d_PRIME = atof(ptb_InRecChild[FT_PRM_M]);

  /* calcul des mois et annee de (libelle d'inventaire +decalage) */
  n_AddMonths( sz_LibPlusDec, n_MoinsDIFMTH_NF , '-', Ksz_CLODAT );
  o_ExtractionAnneeMois(sz_LibPlusDec, &n_LibPlusDeca, &n_LibPlusDecm);

  /* Recuperation des mois et annees debut et fin de periode */
  n_SCOSTRa = atoi (ptb_InRecChild[FT_ACY_NF]);
  n_SCOSTRm = atoi (ptb_InRecChild[FT_SCOSTRMTH_NF]);
  n_SCOENDa = atoi (ptb_InRecChild[FT_ACY_NF]);
  n_SCOENDm = atoi (ptb_InRecChild[FT_SCOENDMTH_NF]);

  //[006] conversion de n_LibPlusDeca en chaine de caractères
  sprintf(sz_LibPlusDeca, "%04d", n_LibPlusDeca);

  /*--------------------------------------------------------------*/
  // REQ9.2 - if Underlying Risk policy end date exists PER_POLED_D
  if ( strcmp(ptb_InRecOwner[PER_POLED_D], "") != 0 )
  {
 		
      d_PPNAe = d_PPNAAvecUnderlyingRiskDate (d_PRIME, ptb_InRecOwner[PER_POLED_D], Ksz_CLODAT, ptb_InRecOwner[PER_SECINC_D]); // Nom date à changer
      /* determination du trncod */
      if (strcmp(ptb_InRecChild[FT_WFTYP_CF], "E") == 0)
        strcpy(sz_TRNCOD_CF, "11410002");
      else
        strcpy(sz_TRNCOD_CF, "11410006");
  
      fprintf( Kp_dGTAaTrPNA_Fil, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%d~%d~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~~\n",
               ptb_InRecOwner[PER_SSD_CF],                                                 // 01
               ptb_InRecOwner[PER_ACCESB_CF],                                              // 02
               Ksz_CLODAT,                                                                 // 03
               Ksz_CLODAT + 4,                                                             // 04
               Ksz_CLODAT + 6,                                                             // 05
               sz_TRNCOD_CF,                                                               // 06
               ptb_InRecOwner[PER_CTR_NF],                                                 // 07
               ptb_InRecOwner[PER_END_NT],                                                 // 08
               ptb_InRecOwner[PER_SEC_NF],                                                 // 09
               ptb_InRecOwner[PER_UWY_NF],                                                 // 10
               ptb_InRecOwner[PER_UW_NT],                                                  // 11
               ptb_InRecOwner[PER_UWY_NF],                                                 // 12
               n_LibPlusDeca < atoi(ptb_InRecOwner[PER_UWY_NF]) ? Ksz_CLODAT : sz_LibPlusDeca, // 13   //[006] n_LibPlusDeca
               //n_LibPlusDecm,                                                              // 14
               //n_LibPlusDecm,                                                              // 15
               atoi(ptb_InRecChild[FT_SCOSTRMTH_NF]),
               atoi(ptb_InRecChild[FT_SCOENDMTH_NF]),
               ptb_InRecOwner[PER_EGPCUR_CF],                                              // 16
               d_PPNAe,                                                                    // 17
               ptb_InRecOwner[PER_CED_NF],                                                 // 18
               ptb_InRecOwner[PER_PRD_NF],                                                 // 19
               ptb_InRecOwner[PER_GENPRMPAY_NF],                                           // 20
               ptb_InRecOwner[PER_GANPAYORD_NT]);            

			/* ecriture dans le Fichier de travail Traites*/
			
			//[024]
			sprintf(sz_PPNAe007, "%-.3lf", d_PPNAe);
  	  ptb_InRecChild[FT_PPNAEA_M] = sz_PPNAe007;
			
    	n_WriteCols(Kp_FTTr_Fil, ptb_InRecChild, '~', 0); //[022] Reactivation du commentaire
    	
  }// REQ9.2 
  else // Si la date n'existe pas les autres cas sont traités
  	{ 
  	/*---------------------------------*/
  	/* Cas des Non prop de type 3 et 5 */
  	/*---------------------------------*/
  	if ( ptb_InRecOwner[PER_CTRNAT_CT][0] == 'N'      &&
  	     (Kn_ACCADMTYP_CT == 3 || Kn_ACCADMTYP_CT == 5) &&
  	     Kn_UWORG_CF != 102                          &&
  	     Kn_UWORG_CF != 101                          &&
  	     Kn_UWORG_CF != 100 )
  	{
  	  /* difference en mois (libelle d'inventaire decale - debut de periode cedante) */
  	  n_LibMoinsDeb = (n_LibPlusDeca - n_SCOSTRa) * 12 + (n_LibPlusDecm - n_SCOSTRm) + 1;
  	
  	  /* difference en mois (fin de periode cedante - libelle d'inventaire decale */
  	  n_FinMoinsLib = (n_SCOENDa - n_LibPlusDeca) * 12 + (n_SCOENDm - n_LibPlusDecm);
  	
  	  /* difference en mois entre la fin et le debut de periode cedante */
  	  n_FinMoinsDeb = (n_SCOENDa - n_SCOSTRa) * 12 + (n_SCOENDm - n_SCOSTRm) + 1;
  	
  	  if (n_LibMoinsDeb < 0)
  	  {
  	    d_PPNAe = -1 * d_PRIME;
  	    sprintf(sz_PPNAe, "%-.3lf", d_PPNAe);
  	    ptb_InRecChild[FT_PPNAEA_M] = sz_PPNAe;
  	  }
  	
  	  if (n_LibMoinsDeb >= 0 && n_FinMoinsLib > 0)
  	  {
  	    if (n_FinMoinsDeb != 0)
  	    {
  	      d_PPNAe = -1 * d_PRIME * (double)n_FinMoinsLib / (double)n_FinMoinsDeb;
  	    }
  	    else
  	    {
  	      d_PPNAe = 0;
  	      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : PPNA = 0", ptb_InRecChild[FT_CTR_NF], ptb_InRecChild[FT_END_NT], ptb_InRecChild[FT_SEC_NF], ptb_InRecChild[FT_UWY_NF], ptb_InRecChild[FT_UW_NT]);
  	      n_WriteAno(Ksz_MessageErr);
  	    }
  	
  	    sprintf(sz_PPNAe, "%-.3lf", d_PPNAe);
  	    ptb_InRecChild[FT_PPNAEA_M] = sz_PPNAe;
  	  }
  	
  	  if (n_FinMoinsLib <= 0)
  	  {
  	    d_PPNAe = 0;
  	    sprintf(sz_PPNAe, "%-.3lf", d_PPNAe);
  	    ptb_InRecChild[FT_PPNAEA_M] = sz_PPNAe;
  	  }
  	
  	  //[006]
  	  tmp_ACY_NF = ptb_InRecChild[FT_ACY_NF];
  	  if (atoi(tmp_ACY_NF) < atoi(ptb_InRecOwner[PER_UWY_NF]))
  	  {
  	    ptb_InRecChild[FT_ACY_NF] = Ksz_CLODAT;
  	  }
  	
  	  /* ecriture dans le Fichier de travail Traites*/
  	  n_WriteCols(Kp_FTTr_Fil, ptb_InRecChild, '~', 0);
  	
  	  //[006]
  	  if (atoi(tmp_ACY_NF) < atoi(ptb_InRecOwner[PER_UWY_NF]))
  	  {
  	    ptb_InRecChild[FT_ACY_NF] = tmp_ACY_NF;
  	  }
  	
  	  /* determination du trncod */
  	  if (strcmp(ptb_InRecChild[FT_WFTYP_CF], "E") == 0)
  	    strcpy(sz_TRNCOD_CF, "11410002");
  	  else
  	    strcpy(sz_TRNCOD_CF, "11410006");
  	
  	  /* ecriture dans le GT(simple)*/    
  	  if (d_PPNAe != 0) 
  	  {
  	    //                          01 02    03    04    05 06  07 08 09 10 11 12    13   14   15  16     17 18 19 20 21
  	   fprintf( Kp_dGTAaTrPNA_Fil, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%02d~%02d~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~~\n",
  	            ptb_InRecOwner[PER_SSD_CF],                                                 // 01
  	            ptb_InRecOwner[PER_ACCESB_CF],                                              // 02
  	            Ksz_CLODAT,                                                                 // 03
  	            Ksz_CLODAT + 4,                                                             // 04
  	            Ksz_CLODAT + 6,                                                             // 05
  	            sz_TRNCOD_CF,                                                               // 06
  	            ptb_InRecOwner[PER_CTR_NF],                                                 // 07
  	            ptb_InRecOwner[PER_END_NT],                                                 // 08
  	            ptb_InRecOwner[PER_SEC_NF],                                                 // 09
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 10
  	            ptb_InRecOwner[PER_UW_NT],                                                  // 11
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 12
  	            n_LibPlusDeca < atoi(ptb_InRecOwner[PER_UWY_NF]) ? Ksz_CLODAT : sz_LibPlusDeca, // 13   //[006] n_LibPlusDeca
  	            n_LibPlusDecm,                                                              // 14
  	            n_LibPlusDecm,                                                              // 15
  	            ptb_InRecOwner[PER_EGPCUR_CF],                                              // 16
  	            d_PPNAe,                                                                    // 17
  	            ptb_InRecOwner[PER_CED_NF],                                                 // 18
  	            ptb_InRecOwner[PER_PRD_NF],                                                 // 19
  	            ptb_InRecOwner[PER_GENPRMPAY_NF],                                           // 20
  	            ptb_InRecOwner[PER_GANPAYORD_NT]);                                          // 21
  	  }
  	}
  	
  	
  	/*------------------------------------------------------*/
  	/* cas des prop de type 2,4,5 et des non prop de type 2 */
  	/*------------------------------------------------------*/
  	if ( (ptb_InRecOwner[PER_CTRNAT_CT][0] == 'P' && Kn_ACCADMTYP_CT == 2 ) ||
  	     (ptb_InRecOwner[PER_CTRNAT_CT][0] == 'N' && Kn_ACCADMTYP_CT == 2 ) )
  	      
  	
  	{
  	  d_PPNAe = d_PPNAAvecDecalage( n_SCOSTRa,
  	                                n_SCOSTRm,
  	                                n_SCOENDa,
  	                                n_SCOENDm,
  	                                n_DIFMTH_NF,
  	                                n_POLDURMTH_NF,
  	                                ptb_InRecOwner[PER_SECINC_D],
  	                                ptb_InRecOwner[PER_EXP_D],
  	                                Ksz_CLODAT,
  	                                d_INSPOL_R,
  	                                d_PRIME,
  	                                atoi(ptb_InRecOwner[PER_ERNPRMADM_B]),
  	                                atoi(ptb_InRecOwner[PER_UWY_NF]));
  	
	  /* [015] Ne plus estimer Traites Earned != '0', Uniquement pour les Proportionnels 
	    le montant de d_PPNAe est remis à 0 */
	  if  ((ptb_InRecOwner[PER_ERNPRMADM_B][0] == '0') && (ptb_InRecOwner[PER_CTRNAT_CT][0] == 'P' ) )
	  {
	     d_PPNAe = 0;
	     d_PPNAe_earned = 1 ; /* On remet les montants de PNAE a 0 dans les fichiers en sortie */
	  } 
				
				
  	  sprintf(sz_PPNAe, "%-.3lf", -1 * d_PPNAe);
  	  ptb_InRecChild[FT_PPNAEA_M] = sz_PPNAe;
  	
  	  //[006]
  	  tmp_ACY_NF = ptb_InRecChild[FT_ACY_NF];
  	  if (atoi(tmp_ACY_NF) < atoi(ptb_InRecOwner[PER_UWY_NF]))
  	  {
  	    ptb_InRecChild[FT_ACY_NF] = Ksz_CLODAT;
  	  }
  	
  	  /* ecriture dans le Fichier de travail Traites*/
  	  n_WriteCols(Kp_FTTr_Fil, ptb_InRecChild, '~', 0);
  	
  	  //[006]
  	  if (atoi(tmp_ACY_NF) < atoi(ptb_InRecOwner[PER_UWY_NF]))
  	  {
  	    ptb_InRecChild[FT_ACY_NF] = tmp_ACY_NF;
  	  }
  	
  	  /* determination du trncod */
  	  if (strcmp(ptb_InRecChild[FT_WFTYP_CF], "E") == 0)
  	    strcpy(sz_TRNCOD_CF, "11410002");
  	  else
  	    strcpy(sz_TRNCOD_CF, "11410006");
  	
  	  /* ecriture dans le GT(simple)*/
  	  
  	  /* [015] if (d_PPNAe != 0) */
  	  if ( (d_PPNAe != 0) || 
  	  	 ((d_PPNAe == 0) && (ptb_InRecOwner[PER_ERNPRMADM_B][0] == '0') && (ptb_InRecOwner[PER_CTRNAT_CT][0] == 'P' )))
  	  {
  	    //                          01 02    03    04    05 06  07 08 09 10 11 12    13   14   15  16     17 18 19 20 21
  	    fprintf(Kp_dGTAaTrPNA_Fil, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%02d~%02d~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~\n",
  	            ptb_InRecOwner[PER_SSD_CF],                                                 // 01
  	            ptb_InRecOwner[PER_ACCESB_CF],                                              // 02
  	            Ksz_CLODAT,                                                                 // 03
  	            Ksz_CLODAT + 4,                                                             // 04
  	            Ksz_CLODAT + 6,                                                             // 05
  	            sz_TRNCOD_CF,                                                               // 06
  	            ptb_InRecOwner[PER_CTR_NF],                                                 // 07
  	            ptb_InRecOwner[PER_END_NT],                                                 // 08
  	            ptb_InRecOwner[PER_SEC_NF],                                                 // 09
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 10
  	            ptb_InRecOwner[PER_UW_NT],                                                  // 11
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 12
  	            n_LibPlusDeca < atoi(ptb_InRecOwner[PER_UWY_NF]) ? Ksz_CLODAT : sz_LibPlusDeca, // 13   //[006] n_LibPlusDeca
  	            n_LibPlusDecm,                                                              // 14
  	            n_LibPlusDecm,                                                              // 15
  	            ptb_InRecOwner[PER_EGPCUR_CF],                                              // 16
  	            -1 * d_PPNAe,                                                               // 17
  	            ptb_InRecOwner[PER_CED_NF],                                                 // 18
  	            ptb_InRecOwner[PER_PRD_NF],                                                 // 19
  	            ptb_InRecOwner[PER_GENPRMPAY_NF],                                           // 20
  	            ptb_InRecOwner[PER_GANPAYORD_NT]);                                          // 21
  	  
  	  }
  	}
  	
  	/*---------------------------------*/
  	/* cas des prop de type 1 et 3     */
  	/*---------------------------------*/
  	if ( ptb_InRecOwner[PER_CTRNAT_CT][0] == 'P'  &&
  	     (Kn_ACCADMTYP_CT == 1 || Kn_ACCADMTYP_CT == 3 || Kn_ACCADMTYP_CT == 4 || Kn_ACCADMTYP_CT == 5 ) )
  	{
  	  if (atoi(ptb_InRecChild[FT_WFCOD_NT]) == 10000)
  	  {
  	    if (Kn_NbLTinit == Kn_NbreTinitMAX)
  	    {
  	      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s : maximum number of UWY/UW is reached ; increase Kn_NbreTinitMAX value", ptb_InRecChild[FT_CTR_NF], ptb_InRecChild[FT_END_NT], ptb_InRecChild[FT_SEC_NF]);
  	      n_WriteAno(Ksz_MessageErr);
  	    }
  	    else
  	    {
  	      /* chargement dans Tinit */
  	      strcpy(Ktb_Tinit[Kn_NbLTinit].CLODAT_D, ptb_InRecChild[FT_CLODAT_D]);
  	      strcpy(Ktb_Tinit[Kn_NbLTinit].CTR_NF, ptb_InRecChild[FT_CTR_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].END_NT = atoi(ptb_InRecChild[FT_END_NT]);
  	      Ktb_Tinit[Kn_NbLTinit].SEC_NF = atoi(ptb_InRecChild[FT_SEC_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].UWY_NF = atoi(ptb_InRecChild[FT_UWY_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].UW_NT = atoi(ptb_InRecChild[FT_UW_NT]);
  	      Ktb_Tinit[Kn_NbLTinit].ACY_NF = atoi(ptb_InRecChild[FT_ACY_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].SCOSTRMTH_NF = atoi(ptb_InRecChild[FT_SCOSTRMTH_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].SCOENDMTH_NF = atoi(ptb_InRecChild[FT_SCOENDMTH_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].UWYDIS_NF = atoi(ptb_InRecChild[FT_UWYDIS_NF]);
  	      Ktb_Tinit[Kn_NbLTinit].SSD_CF = atoi(ptb_InRecChild[FT_SSD_CF]);
  	      strcpy(Ktb_Tinit[Kn_NbLTinit].WFCOD_NT, ptb_InRecChild[FT_WFCOD_NT]);
  	      Ktb_Tinit[Kn_NbLTinit].WFTYP_CF = *ptb_InRecChild[FT_WFTYP_CF];
  	      strcpy(Ktb_Tinit[Kn_NbLTinit].EGPCUR_CF, ptb_InRecChild[FT_EGPCUR_CF]);
  	      Ktb_Tinit[Kn_NbLTinit].PRM_M = (double)atof(ptb_InRecChild[FT_PRM_M]);
  	      Ktb_Tinit[Kn_NbLTinit].PPNAC_M = (double)atof(ptb_InRecChild[FT_PPNAC_M]);
  	      Ktb_Tinit[Kn_NbLTinit].PPNAEA_M = (double)atof(ptb_InRecChild[FT_PPNAEA_M]);
  	      Ktb_Tinit[Kn_NbLTinit].RPPC_M = (double)atof(ptb_InRecChild[FT_RPPC_M]);
  	      Ktb_Tinit[Kn_NbLTinit].RPPEA_M = (double)atof(ptb_InRecChild[FT_RPPEA_M]);
  	      Ktb_Tinit[Kn_NbLTinit].LPPNAC_M = (double)atof(ptb_InRecChild[FT_LPPNAC_M]);
  	      Ktb_Tinit[Kn_NbLTinit].EPPC_M = (double)atof(ptb_InRecChild[FT_EPPC_M]);
  	      Ktb_Tinit[Kn_NbLTinit].EPPEA_M = (double)atof(ptb_InRecChild[FT_EPPEA_M]);
  	      Ktb_Tinit[Kn_NbLTinit].RECC_M = (double)atof(ptb_InRecChild[FT_RECC_M]);
  	      Ktb_Tinit[Kn_NbLTinit].RECE_M = (double)atof(ptb_InRecChild[FT_RECE_M]);
  	      Ktb_Tinit[Kn_NbLTinit].BCC_M = (double)atof(ptb_InRecChild[FT_BCE_M]);
  	      Ktb_Tinit[Kn_NbLTinit].SHR_R = (double)atof(ptb_InRecChild[FT_SHR_R]);
  	      Ktb_Tinit[Kn_NbLTinit].ACCADMTYP_CT = (double)atof(ptb_InRecChild[FT_ACCADMTYP_CT]);
			
  	      Kn_NbLTinit++;
  	    }
  	  }
  	} /* Fin Traites Props 1 ou 3 */
	} // Fin ELSE Underlyingdate existe

  RETURN_VAL (0);
}

/****************************************************************************
Objet : REQ9.2 Calcul PNA
retour : la valeur de la PNA
*****************************************************************************/
double d_PPNAAvecUnderlyingRiskDate ( double d_MontantEGPI, char sz_UnderlyingRiskDate[9], char sz_Clodat[9], char sz_InceptionDate[9])
{
  double d_PPNAe = 0;       /* PPNA calculee */
  int    n_UnderlyingRiskDateA, n_UnderlyingRiskDateM, n_UnderlyingRiskDateD, n_ClodatA, n_ClodatM, n_ClodatD, n_InceptionDateA, n_InceptionDateM, n_InceptionDateD;
  int n_DifferenceCloUnder=0, n_DifferenceIncUnder;

  o_ExtractionAnneeMoisJour(sz_UnderlyingRiskDate,&n_UnderlyingRiskDateA,&n_UnderlyingRiskDateM, &n_UnderlyingRiskDateD);
  o_ExtractionAnneeMoisJour(sz_Clodat,&n_ClodatA,&n_ClodatM, &n_ClodatD);
  o_ExtractionAnneeMoisJour(sz_InceptionDate,&n_InceptionDateA,&n_InceptionDateM, &n_InceptionDateD);

  /* Calcul des differences de dates */
  n_DifferenceCloUnder = nbJours_Entre_Deux_Dates(n_UnderlyingRiskDateD, n_UnderlyingRiskDateM, n_UnderlyingRiskDateA, n_ClodatD, n_ClodatM, n_ClodatA );
  n_DifferenceIncUnder = nbJours_Entre_Deux_Dates(n_UnderlyingRiskDateD, n_UnderlyingRiskDateM, n_UnderlyingRiskDateA, n_InceptionDateD, n_InceptionDateM, n_InceptionDateA);
  //n_DifferenceIncUnder = nbJours_Entre_Deux_Dates(n_ClodatD, n_ClodatM, n_ClodatA, n_InceptionDateD, n_InceptionDateM, n_InceptionDateA);  

 
  /* Formule de calcul : UPR = EGPI x (Closing Date - Underlying Risk Policy End Date ) / ( Inception Date - Underlying Risk Policy End Date) */
  /* Si Closing Date >= Underlying Risk Policy End Date --> PNA = 0 */
  

  d_PPNAe = (-1) * (d_MontantEGPI * (n_DifferenceCloUnder) / (n_DifferenceIncUnder));
  if ( strcmp(sz_Clodat, sz_UnderlyingRiskDate) >= 0 )
 	{
 		d_PPNAe = 0;
 	}
  RETURN_VAL(d_PPNAe);
}

/****************************************************************************
Objet : Appel du calcul de PPNA avec decalage par rapport aux periodes de compte
retour : la valeur de la PNA
*****************************************************************************/
double d_PPNAAvecDecalage ( int n_SCOSTRa, int n_SCOSTRm, int n_SCOENDa, int n_SCOENDm, int n_DIFMTH_NF, int n_POLDURMTH_NF,
                            char sz_SECINC_D[9], char sz_EXP_D[9], char sz_CALCDAT_D[9], double d_INSPOL_R, double d_PRIME, int n_ERNPRMADM_B, int n_UWY_NF )
{
  int n_MoinsDIFMTH_NF;
  double d_PPNAe = 0,       /* PPNA calculee */
         d_PourcPNAe1 = 0,  /* Pourcentage de PNA sur les polices a un an */
         d_PourcPNAe2 = 0;  /* Pourc de PNA sur les polices de duree differ de un an */

  char sz_SCOSTR_D[9],
       sz_SCOENDPlusUnJour_D[9],
       sz_SCOEND_D[9],
       sz_STRMoinsDec[9],
       sz_ENDMoinsDec[9];

  /* reconstitution de la date de debut de periode */
  sprintf(sz_SCOSTR_D, "%04d%02d01", n_SCOSTRa, n_SCOSTRm);

  /* reconstitution de la date de fin de periode */
  if (n_SCOENDm < 12)
  {
    sprintf(sz_SCOENDPlusUnJour_D, "%04d%02d01", n_SCOENDa, (1 + n_SCOENDm));
    n_AddDays( sz_SCOEND_D, 1, '-', sz_SCOENDPlusUnJour_D );
  }
  else
    sprintf (sz_SCOEND_D, "%04d1231", n_SCOENDa);

  /* Calcul des dates de debut et fin de periode moins le decalage */
  n_MoinsDIFMTH_NF = -1 * n_DIFMTH_NF;
  n_AddMonths( sz_STRMoinsDec, n_MoinsDIFMTH_NF , '+', sz_SCOSTR_D );
  n_AddMonths( sz_ENDMoinsDec, n_MoinsDIFMTH_NF , '+', sz_SCOEND_D );

  /* En cas d'une ecriture d'ajustement, c'est a dire date de debut de periode de l'ecriture > date de fin d'exercice, la prime de cette ecriture correspond a un risque dans l'exercice en cours.
  Donc les dates debut et fin du risque sont egales a [1 - 12] de l'exercice moins le decalage */
  if (strcmp(sz_EXP_D, sz_STRMoinsDec) < 0)
  {
    sprintf(sz_SCOSTR_D, "%d0101", n_UWY_NF);
    sprintf(sz_SCOEND_D, "%d1231", n_UWY_NF);
    n_AddMonths( sz_STRMoinsDec, n_MoinsDIFMTH_NF , '+', sz_SCOSTR_D );
    n_AddMonths( sz_ENDMoinsDec, n_MoinsDIFMTH_NF , '+', sz_SCOEND_D );
  }

  /* Appel du module de calcul */
  if (n_POLDURMTH_NF != 12)
  {
    d_PourcPNAe1 = d_CalculCoeffPna ( sz_EXP_D, sz_CALCDAT_D, sz_STRMoinsDec, sz_ENDMoinsDec, 12, (unsigned char)n_ERNPRMADM_B);
    d_PourcPNAe2 = d_CalculCoeffPna ( sz_EXP_D, sz_CALCDAT_D, sz_STRMoinsDec, sz_ENDMoinsDec, n_POLDURMTH_NF, (unsigned char)n_ERNPRMADM_B);

    if (d_PourcPNAe2 != -1)
    {
      d_PPNAe = (d_INSPOL_R * d_PourcPNAe2 + ((double)1 - d_INSPOL_R) * d_PourcPNAe1) * d_PRIME;
    }
    else
    {
      /* Cas POLDURMTH_NF = 0 */
      
      d_PPNAe = 0;
      
      sprintf (Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : POLDURMTH_NF = 0", Kptb_InRecCur[PER_CTR_NF], Kptb_InRecCur[PER_END_NT], Kptb_InRecCur[PER_SEC_NF], Kptb_InRecCur[PER_UWY_NF], Kptb_InRecCur[PER_UW_NT]);
      n_WriteAno(Ksz_MessageErr);
    }
  }
  else
  {
  	
    d_PourcPNAe1 = d_CalculCoeffPna ( sz_EXP_D, sz_CALCDAT_D, sz_STRMoinsDec, sz_ENDMoinsDec, 12, n_ERNPRMADM_B);
    d_PPNAe = d_INSPOL_R * d_PourcPNAe1 * d_PRIME;
  }
  return d_PPNAe;
}

/******************************************************************************
Objet : Chercher l'indice dans la table Ktb_PeriCaract pour lequel la colonne Exercice correspond au parametre en entree
renvoi: l'indice
******************************************************************************/
int n_CherchePeriIndAff(int n_UWY_NF)
{
  int i, b_Trouve;

  i = 0;
  b_Trouve = 0;

  while (i < Kn_NbLPeriCaract && b_Trouve == 0)
  {
    b_Trouve = (Ktb_PeriCaract[i].n_UWY_NF == n_UWY_NF);
    i++;
  }

  if (b_Trouve)
    return (i - 1);
  else
    return Kn_NbLPeriCaract;
}

/******************************************************************************
Objet : Renvoi la Part SCOR pour l'exercice demande
renvoi: la part SCOR (double)
******************************************************************************/
double d_ChercheTinitPart(int n_UWY_NF)
{
  int i, b_Trouve;

  i = 0;
  b_Trouve = 0;

  while (i < Kn_NbLTinit && b_Trouve == 0)
  {
    b_Trouve = (Ktb_Tinit[i].UWYDIS_NF == n_UWY_NF);
    i++;
  }

  if (b_Trouve)
    return Ktb_Tinit[i - 1].SHR_R;
  else
    return 0;
}


/******************************************************************************
objet  : Ecrire un enregistrement dans le Fichier de Travail
renvoie: rien

Description:
  Modification GLE : 12/02/2016 - ajout cas de prime émise sur cession de prime pour écrire les données en sortie

*******************************************************************************/
int n_WriteFTTr( T_FT *Ktb_TFT )
{
  double d_Eppea ; /* variable intermediaire: montant d'EPP estime ou actualise */
  double d_Rppea ; /* variable intermediaire: montant d'RPP estime ou actualise */
  //[018] 
  double d_PPNAEA ;
  double d_RPPEA ;

  char sz_ACY_NF[5];   //[006]

  /* positionnement du montant d'EPP estime ou actualise */
  d_Eppea = Ktb_TFT->EPPEA_M ;

  /* positionnement du montant d'RPP estime ou actualise */
  d_Rppea = Ktb_TFT->RPPEA_M ;

  /* [018] */
  d_PPNAEA = (-1) * Ktb_TFT->PPNAC_M ;
  d_RPPEA  = Ktb_TFT->PPNAC_M + Ktb_TFT->RPPC_M + Ktb_TFT->RPPEA_M;

  //[006] conversion de n_LibPlusDeca en chaine de caractères
  sprintf(sz_ACY_NF, "%04d", Ktb_TFT->ACY_NF);

  /* ecriture en sortie dans le fichier de travail */
  //                      01    02 03 04 05 06    07 08 09   10 11 12 13    14    15    16    17    18    19    20    21    22    23    24    25    26    27 28             
  fprintf(Kp_FTTr_Fil, "%8.8s~%9.9s~%d~%d~%d~%d~%4.4s~%d~%d~%04d~%d~%s~%c~%3.3s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.8f~%d\n",
          Ktb_TFT->CLODAT_D,                                              // 01
          Ktb_TFT->CTR_NF,                                                // 02
          Ktb_TFT->END_NT,                                                // 03
          Ktb_TFT->SEC_NF,                                                // 04
          Ktb_TFT->UWY_NF,                                                // 05
          Ktb_TFT->UW_NT,                                                 // 06
          Ktb_TFT->ACY_NF < Ktb_TFT->UWY_NF ? Ksz_CLODAT : sz_ACY_NF,     // 07   //[006] Ktb_TFT->ACY_NF,
          Ktb_TFT->SCOSTRMTH_NF,                                          // 08
          Ktb_TFT->SCOENDMTH_NF,                                          // 09
          Ktb_TFT->UWYDIS_NF,                                             // 10
          Ktb_TFT->SSD_CF,                                                // 11
          Ktb_TFT->WFCOD_NT,                                              // 12
          Ktb_TFT->WFTYP_CF,                                              // 13
          Ktb_TFT->EGPCUR_CF,                                             // 14
          Ktb_TFT->PRM_M,                                                 // 15
          Ktb_TFT->PPNAC_M,                                               // 16
          //[018]
          d_PPNAEA,                                                       //17
          //Ktb_TFT->PPNAEA_M,                                              // 17 old
          Ktb_TFT->RPPC_M,                                                // 18
          //[018]
          d_RPPEA,                                                        //19
          //d_Rppea,                                                        // 19 old
          Ktb_TFT->LPPNAC_M,                                              // 20
          Ktb_TFT->EPPC_M,                                                // 21
          d_Eppea,                                                        // 22
          Ktb_TFT->RECC_M,                                                // 23
          Ktb_TFT->RECE_M,                                                // 24
          Ktb_TFT->BCC_M,                                                 // 25
          Ktb_TFT->BCE_M,                                                 // 26
          Ktb_TFT->SHR_R,                                                 // 27
          Ktb_TFT->ACCADMTYP_CT );                                        // 28

  return 0;
}

/*==============================================================================
objet : [018] spira 81898 fonction lancee aprÃ¨s rupture pour Ã©crire la PNAC
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
/*             adresse de la ligne du maitre, de l'esclave */
int n_ActionLigneFTTrbis( char **ptb_InRecOwner, char **ptb_InRecChild, double d_PPNAc)
{

  char  sz_LibPlusDec[9],
        sz_TRNCOD_CF[9];

  int n_DIFMTH_NF,      /* decalage(negatif)                */
      n_MoinsDIFMTH_NF, /* oppose du decalage (positif)     */
      n_LibPlusDeca,    /* annee libelle d'inventaire plus decalage */
      n_LibPlusDecm,    /* mois libelle d'inventaire plus decalage  */
      n_POLDURMTH_NF;   

  char sz_LibPlusDeca[5];   //[006]

  DEBUT_FCT("n_ActionLigneFTTrbis");
  /*----------------------------------------------*/
  /* Preliminaires calculs sur les dates          */
  /*----------------------------------------------*/

  /* Conversions das zones employees lors des calculs */
  n_DIFMTH_NF = atoi(ptb_InRecOwner[PER_DIFMTH_NF]);
  n_MoinsDIFMTH_NF = -1 * n_DIFMTH_NF;
  n_POLDURMTH_NF = atoi(ptb_InRecOwner[PER_POLDURMTH_NF]);

  /* calcul des mois et annee de (libelle d'inventaire +decalage) */
  n_AddMonths( sz_LibPlusDec, n_MoinsDIFMTH_NF , '-', Ksz_CLODAT );
  o_ExtractionAnneeMois(sz_LibPlusDec, &n_LibPlusDeca, &n_LibPlusDecm);

  //[006] conversion de n_LibPlusDeca en chaine de caractères
  sprintf(sz_LibPlusDeca, "%04d", n_LibPlusDeca);

  	/*---------------------------------*/
  	/* traite  type different de 2     */
  	/*---------------------------------*/
  	if ( Kn_ACCADMTYP_CT == 1 || Kn_ACCADMTYP_CT == 3 || Kn_ACCADMTYP_CT == 4 || Kn_ACCADMTYP_CT == 5 )
  	{

  	  //sprintf(sz_PPNAc, "%-.3lf", d_PPNAc);
  	  strcpy(sz_TRNCOD_CF, "11410002");
  	
  	  /* ecriture dans le GT(simple)*/    
  	  if (d_PPNAc!= 0) 
  	  {
  	    //                          01 02    03    04    05 06  07 08 09 10 11 12    13   14   15  16     17 18 19 20 21
  	   fprintf( Kp_dGTAaTrPNA_Fil, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%4.4s~%02d~%02d~~%s~%-.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~~\n",
  	            ptb_InRecOwner[PER_SSD_CF],                                                 // 01
  	            ptb_InRecOwner[PER_ACCESB_CF],                                              // 02
  	            Ksz_CLODAT,                                                                 // 03
  	            Ksz_CLODAT + 4,                                                             // 04
  	            Ksz_CLODAT + 6,                                                             // 05
  	            sz_TRNCOD_CF,                                                               // 06
  	            ptb_InRecOwner[PER_CTR_NF],                                                 // 07
  	            ptb_InRecOwner[PER_END_NT],                                                 // 08
  	            ptb_InRecOwner[PER_SEC_NF],                                                 // 09
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 10
  	            ptb_InRecOwner[PER_UW_NT],                                                  // 11
  	            ptb_InRecOwner[PER_UWY_NF],                                                 // 12
  	            n_LibPlusDeca < atoi(ptb_InRecOwner[PER_UWY_NF]) ? Ksz_CLODAT : sz_LibPlusDeca, // 13   //[006] n_LibPlusDeca
  	            n_LibPlusDecm,                                                              // 14
  	            n_LibPlusDecm,                                                              // 15
  	            ptb_InRecOwner[PER_EGPCUR_CF],                                              // 16
  	            d_PPNAc,                                                                    // 17
  	            ptb_InRecOwner[PER_CED_NF],                                                 // 18
  	            ptb_InRecOwner[PER_PRD_NF],                                                 // 19
  	            ptb_InRecOwner[PER_GENPRMPAY_NF],                                           // 20
  	            ptb_InRecOwner[PER_GANPAYORD_NT]);                                          // 21
  	  }
  	}
  	

  RETURN_VAL (0);
}

/******************************************************************************
objet:  ECRIRE dans les GT des EPP/RPP pour les proportionnels de type 1 et 3

Description:
  Modification GLE : 12/02/2016 - ajout cas de prime émise sur cession de prime pour écrire les données en sortie

*******************************************************************************/
int n_EcrireGT ( T_FT *ptb_TsupInit, char sz_TRNCOD_CF[9], double d_Montant, int n_IndAff, int n_ACY_NF, int n_SCOSTRMTH_NF, int n_SCOENDMTH_NF, int b_Decalage, FILE *pf_NomFic, int b_RPP )
{
  int n_MoinsDIFMTH_NF;
  char sz_STRMoinsDec[9],
       sz_ENDMoinsDec[9],
       sz_SCOSTR_D[9],
       sz_SCOEND_D[9];
  char sz_ACY_NF[5];   //[006]

  DEBUT_FCT("n_EcrireGT");

  //On va chercher dans le péricase si prime acquise pour l'exercice qu'on doit écrire on sort uniquement pour les RPP !
  if ( b_RPP == 1 )
  {
    if ( Ktb_PeriCaract[n_CherchePeriIndAff(ptb_TsupInit->UWYDIS_NF)].n_ERNPRMADM_B == 0 ) //prime acquise
      return 0;
  }

  if (b_Decalage == 1)
  {
    /* Reconstitution des dates de debut et de fin de periode */
    sprintf(sz_SCOSTR_D, "%04d%02d01", n_ACY_NF, n_SCOSTRMTH_NF);
    sprintf(sz_SCOEND_D, "%04d%02d01", n_ACY_NF, n_SCOENDMTH_NF);

    /* Calcul des dates de debut et fin de periode plus le decalage */
    n_MoinsDIFMTH_NF = -1 * Ktb_PeriCaract[n_IndAff].n_DIFMTH_NF;
    n_AddMonths( sz_STRMoinsDec, n_MoinsDIFMTH_NF , '-', sz_SCOSTR_D );
    n_AddMonths( sz_ENDMoinsDec, n_MoinsDIFMTH_NF , '-', sz_SCOEND_D );

    /* Et on reeclate */
    o_ExtractionAnneeMois(sz_STRMoinsDec, &n_ACY_NF, &n_SCOSTRMTH_NF);
    o_ExtractionAnneeMois(sz_STRMoinsDec, &n_ACY_NF, &n_SCOENDMTH_NF);
  }

  //[006] conversion de n_LibPlusDeca en chaine de caractères
  sprintf(sz_ACY_NF, "%04d", n_ACY_NF);

  /* Ecriture dans le GT */
  /*ajout une colonne pour retintamt_m */
  //                  01 02    03    04    05    06     07 08 09 10 11 12    13 14 15  16     17 18 19 20 21
  fprintf(pf_NomFic, "%d~%d~%4.4s~%2.2s~%2.2s~%8.8s~~%9.9s~%d~%d~%d~%d~%d~%4.4s~%d~%d~~%s~%-.3lf~%d~%d~%d~%d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GTA~~~~~~~~~~~~~~\n",
          Ktb_PeriCaract[n_IndAff].n_SSD_CF,                  // 01
          Ktb_PeriCaract[n_IndAff].n_ESB_CF,                  // 02
          Ksz_CLODAT,                                         // 03
          Ksz_CLODAT + 4,                                     // 04
          Ksz_CLODAT + 6,                                     // 05
          sz_TRNCOD_CF,                                       // 06
          ptb_TsupInit->CTR_NF,                               // 07
          ptb_TsupInit->END_NT,                               // 08
          ptb_TsupInit->SEC_NF,                               // 09
          ptb_TsupInit->UWYDIS_NF,                            // 10
          ptb_TsupInit->UW_NT,                                // 11
          ptb_TsupInit->UWYDIS_NF,                            // 12
          n_ACY_NF < Ktb_Tinit->UWY_NF ? Ksz_CLODAT : sz_ACY_NF, // 13    [006]
          n_SCOSTRMTH_NF,                                     // 14
          n_SCOENDMTH_NF,                                     // 15
          Ktb_PeriCaract[n_IndAff].sz_EGPCUR_CF,              // 16
          d_Montant,                                          // 17
          Ktb_PeriCaract[n_IndAff].n_CED_NF,                  // 18
          Ktb_PeriCaract[n_IndAff].n_BRK_NF,                  // 19
          Ktb_PeriCaract[n_IndAff].n_PAY_NF,                  // 20
          Ktb_PeriCaract[n_IndAff].n_KEY_NF);                 // 21

  RETURN_VAL(0);
}

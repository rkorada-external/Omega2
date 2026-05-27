/*==============================================================================
 Nom de l'application          : ESTIMATION IFRS17
 Nom du source                 : ESTC1060.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 31/08/2012
 Auteur                        : D. Chteboul - R. Cassis
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
 Description :
   Reformate les données au format GT avec les PATTERNSII_ANNEES montants correspondant aux PATTERNSII_ANNEES années en 1 seul montant

------------------------------------------------------------------------------
     Historique des modifications :
[02] 01/06/2012   -=Dch=-  :spot:23937 SOLVENCY II
[03] 29/08/2012 R. Cassis  :spot:24041 SOLVENCY II - refonte
[03] 20/02/2013 PEZOUT     :spot:24875 SOLVENCY II
[03] 29/02/2013 PEZOUT     :spot:24905 SOLVENCY II
[04] 16/04/2014 -=Dch=-    :spot:24905 SOLVENCY II corrections techniques
[XX] 02/06/2014 JBG        :spot:25773 Warnings suppress in compile
[05] 04/12/2014 C. DESPRET :spot:26391 Depots a retirer des montants des BAD DEBTS
[06] 21/04/2015 P. Menant  :spot:26391
[07] 01/06/2015 Florent    :spot:26391 maj de PPEZOUT (PPZ)
[08] 11/06/2015 F.MA       :spot:28941 FMA
[09] 13/05/2016 Florent    :spot:30543 on passe à 65 années
[10] 18/11/2016 Florent    :spira:57799 Mise au format à 71 colonnes pour les fichiers EST_DLDSIIGT*
[11] 05/02/2019 Quentin Desmettre : EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
[12] 10/04/2019 Linh DOAN  :spira:77079 Generating IFRS 17 Group TL file
[13] 12/02/2020 Linh DOAN  :spira 82420 : REQ11.7 - Initial future, expense transaction
[14] 30/06/2020 Linh DOAN  :spira:79070 : REQ11.7.2
[15] 30/06/2020 Linh DOAN  :spira:79070 : remove norme checking in STD
[16] 01/07/2020 Linh DOAN  :spira:79070 : remove doublon 49400 on 11.6
[17] 06/08/2020 Linh DOAN  :spira:87876 : Using PRSMAP for REQ11.4 and 11.5
[18] 27/10/2020 Linh DOAN  :spira 90921 : reverse sign in EGPI DAC TL generation + fix norme
[19] 27/05/2021 Linh DOAN  :spira 91532 : recompilation des programmes C
[20] 02/08/2021 Linh DOAN  :spira:98114 : TTECLEDA/R.RETINTAMT- do not force to 0 when lerging GTL files
[21] 21/09/2021 Linh DOAN  :spira 90502 : fix format
[22] 07/10/2021 Linh DOAN  :spira 90502 : fix error retro
[23]  05/07/2022  JBD     :spira 104778:  Build new closing for I17S norm
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include "estutil.c"
#include "ESTC3001.h"
#include "ESFC3740.h"



static char VERSION_ESFC3742_C[150] = "__version__: ESFC3742.c [22] 07/10/2021 12:00:00 spira 98114 using PRSMAP  @NLD";


T_RUPTURE_VAR Kbd_ruptDldSIIGT;

FILE *Kp_OutputFilDldSIIGTAA; /* pointeur sur le fichier de sortie AA formaté avec les nouvelles colonnes */
FILE *Kp_OutputFilDldSIIGTRA; /* pointeur sur le fichier de sortie RA formaté avec les nouvelles colonnes */

FILE *Kp_InputTRSLNK; // file Kp_InputBOPRSLNK
//FILE *Kp_InputFilFBOPRSLNK; /* pointer on the input file FBOPRSLNK (binary file), not used any more */

int Kn_NbLigTrslnk;
int Kn_FBOPRSLNK; /* number of line in the file FBOPRSLNK */

FILE *Kp_FBOPRSLNK;

FILE *Kp_OutputANO;

FILE *Kp_GetDbltrncod; /* Pointeur sur le fichier des poste de contrepartie */
FILE *Kp_FilePrsMap;   /* Pointeur sur le fichier des PrsMap */

char Ksz_DBLTRNCOD_CF[9]; /* Poste contrepartie */

int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs);

char gsz_Annee[5], gsz_Mois[3], gsz_Jour[3]; // de la Date de cloture Ex: 20111201
//double n_Total;
double td_Total[4];
char sz_NormeTotal[10] = "Z";
char sz_norme[5];

int n_NormeCur;
int temp_n_ChargerFBOPRSLNK;
int temp_n_RechTrn;
char sz_Clodat_d[9] = "19990101";
char sz_Somme[21] = "";
char sz_trncod[9];



// ruture variables
PrsMapData Kp_PrsMap[Kn_MaxFPRSMAP];

int Kn_SizeFPRSMAP = 0;
/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
char n_GetNorme(const char *Norme_CF);

int n_InitDldSIIGT(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneDldSIIGT(char **ptb_InRecChild);
int n_ActionPremiereLigneDldSIIGT(char **ptb_InRecChild);
int n_ActionDerniereLigneDldSIIGT(char **ptb_InRecChild);
int writeLine(char **ptb_InRecChild, char *sz_Clodat_d, const char *sz_inittrncod, char *sz_Somme, const char *sz_amctrs3);
int n_TestRupture(char **ptsz_LigneSuiv, char **ptsz_LigneCour);

void resetRuptureData();

// R02-03  Discount at Locked in rates Transformation (REQ11.4/5)
void processEscompteInline(char **ptb_InRecChild);

int n_WriteLogLevel(int c_level, char *sz_message);
int n_LoadFPRSMAP(FILE *filePrsMap);

/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  //char sz_Clodat_d[9] = "";
  // Initialisation des signaux

  InitSig();

  if (n_BeginPgm(argc, argv) == ERR)
    ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESFC3742_O1", "wt", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie AA.");

  /* Ouverture du fichier contenant le poste de contrepartie */
  if (n_OpenFileAppl("ESFC3742_I2", "rt", &Kp_GetDbltrncod) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileApplGetDbltrncod");
  }

  /* Ouverture du fichier contenant le prsmap */
  if (n_OpenFileAppl("ESFC3742_I3", "rt", &Kp_FilePrsMap) == ERR)
  {
    ExitPgm(ERR_XX, "Erreur appel fonction n_OpenFileApplPrsMap");
  }

  if (n_OpenFileAppl("ESFC3742_O2", "wt", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie RA.");

  if (n_OpenFileAppl("ESFC3742_O3", "wt", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie.");

  // chargement de la date de clotûre fournie au programme
  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
  strcpy(sz_norme, psz_GetCharArgv(2));
  

  printf("Running %s \n", VERSION_ESFC3742_C);

  
  printf("Main norme=%s \n", sz_norme);
  printf("CLODAT=%s \n", sz_Clodat_d);

  Kn_SizeFPRSMAP = n_LoadFPRSMAP(Kp_FilePrsMap);
  //char normeOut = n_GetNorme(sz_norme);

  // Initialisation des variables de gestion de ruptures
  if (n_InitDldSIIGT(&Kbd_ruptDldSIIGT))
    ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitDldSIIGT");

  /* lancement du traitement du fichier FTECLEDSII_RET */
  if (n_ProcessingRuptureVar(&Kbd_ruptDldSIIGT) != OK)
    ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne.");

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESFC3742_I1", &(Kbd_ruptDldSIIGT.pf_InputFil)))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESFC3742_I2", &(Kp_GetDbltrncod)) == ERR)
  {
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FDETTRS");
  }

  if (n_CloseFileAppl("ESFC3742_I3", &(Kp_FilePrsMap)) == ERR)
  {
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier FPRSMAP");
  }

  if (n_CloseFileAppl("ESFC3742_O1", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier AA.");

  if (n_CloseFileAppl("ESFC3742_O2", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier AR.");

  if (n_CloseFileAppl("ESFC3742_O3", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ANO.");

  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  // libération mémoire
  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la collection des valeurs OCI : EXPENSES_FUTURE, EXPENSES_INCURRED, RA_FUTURE, RA_INCURRED
 Parametre(s) :     none
 Retour :           rien
==============================================================================*/
void resetRuptureData()
{
  int k;

  for (k = 0; k < Kn_SizeFPRSMAP; k++)
  {
    Kp_PrsMap[k].dsiValue = 0.0;
  }
}

/*==============================================================================
 Objet :            Ecriture de la collection des valeurs OCI : EXPENSES_FUTURE, EXPENSES_INCURRED, RA_FUTURE, RA_INCURRED
 Parametre(s) :     none
 Retour :           rien
==============================================================================*/
void writeRuptureData(char **ptb_InRecChild, char *sz_Clodat_d)
{
  int j;
  //static char *sz_acmtrs;
  static char sz_acmtrs3_default[5];

  
  for (j = 0; j < Kn_SizeFPRSMAP; j++)
  {
    if ((Kp_PrsMap[j].dsiValue >= EPSILON || Kp_PrsMap[j].dsiValue <= -EPSILON) && strlen(Kp_PrsMap[j].trscodeDSI)> 0)
    {
      sprintf(sz_Somme, "%18.3f", Kp_PrsMap[j].dsiValue);
      sprintf(sz_acmtrs3_default, "%.4d", Kp_PrsMap[j].grp751);
      writeLine(ptb_InRecChild, sz_Clodat_d, Kp_PrsMap[j].trscodeDSI, sz_Somme, sz_acmtrs3_default);
    }
  }
}
/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitDldSIIGT(T_RUPTURE_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitDldSIIGT");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier maitre Perimetre de souscription */
  if (n_OpenFileAppl("ESFC3742_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_TestRupture;

  pbd_Rupt->b_EoF = TRUE;

  pbd_Rupt->n_ActionLigne = n_ActionLigneDldSIIGT;

  pbd_Rupt->n_ActionFirst[0] = n_ActionPremiereLigneDldSIIGT;
  //pbd_Rupt->n_ActionLigne=n_ActionLigneRupture;
  pbd_Rupt->n_ActionLast[0] = n_ActionDerniereLigneDldSIIGT;

  pbd_Rupt->c_Separ = '~';

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneDldSIIGT(char **ptb_InRecChild)
{
  DEBUT_FCT("n_ActionLigneDldSIIGT");

  // R02-03  Discount at Locked in rates Transformation (REQ11.4)
  // R02-04 Discount unwind Transformation (REQ11.5)
  processEscompteInline(ptb_InRecChild);

  RETURN_VAL(OK);
}



/*==============================================================================
 Objet :            R02-03  Discount at Locked in rates Transformation (REQ11.4 & 11.5)
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
void processEscompteInline(char **ptb_InRecChild)
{


  static int j = 0;

  
  for (j = 0; j < Kn_SizeFPRSMAP; j++)
  {
    // remove grouping 751 from spec
    //if ((atoi(ptb_InRecChild[GT2_ACMTRS_NT]) == ESCOMPTE_ACMTRS_NT[k])  && (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) == ESCOMPTE_ACMTRS3_NT[k]))
    if ((atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) == Kp_PrsMap[j].grp751) && (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0))
    {
      // Discount DSI SII Scope 
      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "DSI", 3) == 0) && (strlen(Kp_PrsMap[j].trscodeDSI)> 0))
      {
          Kp_PrsMap[j].dsiValue += atof(ptb_InRecChild[GT2_TOTAUX_M]);
          break;
      }

      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0)
      {
          // Discount LKI SII Scope 
          if (strlen(Kp_PrsMap[j].trscodeLKI)> 0 ){
            sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
            writeLine(ptb_InRecChild, sz_Clodat_d, Kp_PrsMap[j].trscodeLKI, sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
          }
          // Discount DSI SII Scope 
          if (strlen(Kp_PrsMap[j].trscodeDSI)> 0)
            Kp_PrsMap[j].dsiValue -= atof(ptb_InRecChild[GT2_TOTAUX_M]);
        break;
      }

      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0) && (strlen(Kp_PrsMap[j].trscodeFWD)> 0) )
      {
        // Discount Foward SII Scope (REQ11.5)
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, Kp_PrsMap[j].trscodeFWD, sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
          return;
        
      }
    }
 } 
}

/**************************************************************************/
int writeLine(char **ptb_InRecChild, char *sz_Clodat_d, const char *sz_inittrncod, char *sz_Somme, const char *sz_amctrs3)
{

  static char sz_amctrs3_local[6] = "";

  static char sz_trncod[9] = "";
  static char sz_charicod[15] = "I17GGTA";

  static int i;

  static char *DldSIIGT[GT_NBCOL2 + 2]; // tableau de pointeur a l'image du fichier en sortie:  73 colonnes

  static char norme = 'I';

  
  norme = n_GetNorme(sz_norme);
  
  if (norme == 'R')
  {
    n_WriteAno("ERROR : Norme Incorrecte \n");
    // skip this line
    return 1;
  }

  
  // chargement de la date de clotûre fournie au programme

  sprintf(gsz_Annee, "%.4s", sz_Clodat_d);
  sprintf(gsz_Mois, "%.2s", &sz_Clodat_d[4]);
  sprintf(gsz_Jour, "%.2s", &sz_Clodat_d[6]);
 
  sprintf(sz_charicod, "%sGTA", sz_norme);
  sprintf(sz_amctrs3_local, "%.5s", sz_amctrs3);

  memset(DldSIIGT, 0, sizeof(DldSIIGT));

  DldSIIGT[GT_SSD_CF] = ptb_InRecChild[GT_SSD_CF];
  DldSIIGT[GT_ESB_CF] = ptb_InRecChild[GT_ESB_CF];
  DldSIIGT[GT_BALSHEY_NF] = gsz_Annee;
  DldSIIGT[GT_BALSHRMTH_NF] = gsz_Mois;
  DldSIIGT[GT_BALSHRDAY_NF] = gsz_Jour;
  DldSIIGT[GT_DBLTRNCOD_CF] = "";
  DldSIIGT[GT_CTR_NF] = ptb_InRecChild[GT_CTR_NF];
  DldSIIGT[GT_END_NT] = ptb_InRecChild[GT_END_NT];
  DldSIIGT[GT_SEC_NF] = ptb_InRecChild[GT_SEC_NF];
  DldSIIGT[GT_UWY_NF] = ptb_InRecChild[GT_UWY_NF];
  DldSIIGT[GT_UW_NT] = ptb_InRecChild[GT_UW_NT];
  DldSIIGT[GT_OCCYEA_NF] = gsz_Annee;
  DldSIIGT[GT_ACY_NF] = gsz_Annee;
  DldSIIGT[GT_SCOSTRMTH_NF] = gsz_Mois;
  DldSIIGT[GT_SCOENDMTH_NF] = gsz_Mois;
  DldSIIGT[GT_CLM_NF] = "";
  DldSIIGT[GT_CUR_CF] = ptb_InRecChild[GT2_ACMCUR_CF];
  DldSIIGT[GT_AMT_M] = sz_Somme;
  DldSIIGT[GT_CED_NF] = ptb_InRecChild[GT_CED_NF];
  DldSIIGT[GT_BRK_NF] = ptb_InRecChild[GT_BRK_NF];
  DldSIIGT[GT_PAY_NF] = ptb_InRecChild[GT_PAY_NF];
  DldSIIGT[GT_KEY_NF] = ptb_InRecChild[GT_KEY_NF];
  DldSIIGT[GTSII_SEG_NF] = ptb_InRecChild[GTSII_SEG_NF];
  if (b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF]))
  {
    DldSIIGT[GT_RETCTR_NF] = "";
    DldSIIGT[GT_RETEND_NT] = "";
    DldSIIGT[GT_RETSEC_NF] = "";
    DldSIIGT[GT_RTY_NF] = "";
    DldSIIGT[GT_RETUW_NT] = "";
    DldSIIGT[GT_RETOCCYEA_NF] = "";
    DldSIIGT[GT_RETACY_NF] = "";
    DldSIIGT[GT_RETSCOSTRMTH_NF] = "";
    DldSIIGT[GT_RETSCOENDMTH_NF] = "";
    DldSIIGT[GT_RCL_NF] = "";
    DldSIIGT[GT_RETCUR_CF] = "";
    DldSIIGT[GT_RETAMT_M] = "";
    DldSIIGT[GT_PLC_NT] = "";
    DldSIIGT[GT_RTO_NF] = "";
    DldSIIGT[GT_INT_NF] = "";
    DldSIIGT[GT_RETPAY_NF] = "";
    DldSIIGT[GT_RETKEY_CF] = "";
    DldSIIGT[GT_RETINTAMT_M] = "0"; // 0 pour l'instant - sera mis a jour dans autre prog
  }
  else
  {
    DldSIIGT[GT_RETCTR_NF] = ptb_InRecChild[GT_RETCTR_NF];
    DldSIIGT[GT_RETEND_NT] = ptb_InRecChild[GT_RETEND_NT];
    DldSIIGT[GT_RETSEC_NF] = ptb_InRecChild[GT_RETSEC_NF];
    DldSIIGT[GT_RTY_NF] = ptb_InRecChild[GT_RTY_NF];
    DldSIIGT[GT_RETUW_NT] = ptb_InRecChild[GT_RETUW_NT];
    DldSIIGT[GT_RETOCCYEA_NF] = gsz_Annee;
    DldSIIGT[GT_RETACY_NF] = gsz_Annee;
    DldSIIGT[GT_RETSCOSTRMTH_NF] = gsz_Mois;
    DldSIIGT[GT_RETSCOENDMTH_NF] = gsz_Mois;
    DldSIIGT[GT_RCL_NF] = "";
    DldSIIGT[GT_RETCUR_CF] = ptb_InRecChild[GT2_ACMCUR_CF];
    DldSIIGT[GT_RETAMT_M] = sz_Somme;
    DldSIIGT[GT_PLC_NT] = ptb_InRecChild[GT_PLC_NT];
    DldSIIGT[GT_RTO_NF] = ptb_InRecChild[GT_RTO_NF];
    DldSIIGT[GT_INT_NF] = ptb_InRecChild[GT_INT_NF];
    DldSIIGT[GT_RETPAY_NF] = ptb_InRecChild[GT_RETPAY_NF];
    DldSIIGT[GT_RETKEY_CF] = ptb_InRecChild[GT_RETKEY_CF];
    DldSIIGT[GT_RETINTAMT_M] = "0"; // spira 98114
  }

  if (b_IsBlankOrEmpty(ptb_InRecChild[GT_CTR_NF]))
  {
    DldSIIGT[GT_CTR_NF] = "";
    DldSIIGT[GT_END_NT] = "";
    DldSIIGT[GT_SEC_NF] = "";
    DldSIIGT[GT_UWY_NF] = "";
    DldSIIGT[GT_UW_NT] = "";
  }

  // Remise a blanc de la fin de l'enregistrement
  for (i = GT_BUKRS_CF; i < GT_NBCOL2; i++)
  {
    DldSIIGT[i] = "";
  }

  //TODO : check GT_ORICOD_LS, should I change it ?

  DldSIIGT[GT_ORICOD_LS] = sz_charicod;

  //strcpy(DldSIIGT[GT_ORICOD_LS],sz_charicod);

  DldSIIGT[GT_ACMTRS3_NT] = sz_amctrs3_local;

  if (strncmp(ptb_InRecChild[GT2_TYP_CT], "A", 1) == 0)
  {
    DldSIIGT[GT_RETINTAMT_M] = "0"; // spira 98114
    sprintf(sz_trncod, "11%.5s%c", sz_inittrncod, norme);
    DldSIIGT[GT_TRNCOD_CF] = sz_trncod;

    n_PosteContre(sz_trncod, Kp_GetDbltrncod); //Ksz_DBLTRNCOD_CF
    DldSIIGT[GT_DBLTRNCOD_CF] = Ksz_DBLTRNCOD_CF;

    n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
  }
  else
  {
    if (!b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF])){
      DldSIIGT[GT_RETINTAMT_M] = sz_Somme; // spira 98114

      sprintf(sz_trncod, "21%.5s%c", sz_inittrncod, norme);
      DldSIIGT[GT_TRNCOD_CF] = sz_trncod;

      n_PosteContre(sz_trncod, Kp_GetDbltrncod); //Ksz_DBLTRNCOD_CF
      DldSIIGT[GT_DBLTRNCOD_CF] = Ksz_DBLTRNCOD_CF;

      n_WriteCols(Kp_OutputFilDldSIIGTRA, DldSIIGT, SEPARATEUR, 0);
      // doulication TECLEDA
      n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
    }
  }
  return 0;
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture première du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereLigneDldSIIGT					***/
/***									***/
/*** Parametres:							***/
/***	i ptb_InRecChild : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_ActionPremiereLigneDldSIIGT(char **ptb_InRecChild)
{
  resetRuptureData();

  RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionDerniereLigneDldSIIGT					***/
/***									***/
/*** Parametres:							***/
/***	i ptb_InRecChild : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_ActionDerniereLigneDldSIIGT(char **ptb_InRecChild)
{

  //char sz_Somme	[14];

  writeRuptureData(ptb_InRecChild, sz_Clodat_d);

  RETURN_VAL(OK);
}

/**===========================================================================
objet	:	Fonction pour retourner symbole norme a rensigner dans TRNCOD 
retour 	:   Caractere a renseigner dans TRNCOD	
==============================================================================*/
char n_GetNorme(const char *Norme_CF)
{
  if (strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0) //[23]
    return 'I';
  else if (strcmp(Norme_CF, "I17P") == 0)
    return 'K';
  else if (strcmp(Norme_CF, "I17L") == 0)
    return 'M';
  else
    return 'R';
}

int n_TestRupture(
    char *ptsz_LigneSuiv[],
    char *ptsz_LigneCour[])
{
  static int n_Ret;

  //Accept CSUOE :  Contract / Section / UWY / Order / Endorsemen
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF])))
  {
    return n_Ret;
  }

  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT])))
  {
    return n_Ret;
  }

  // Retro
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_RETCTR_NF], ptsz_LigneCour[GT_RETCTR_NF])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_RETEND_NT], ptsz_LigneCour[GT_RETEND_NT])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_RETSEC_NF], ptsz_LigneCour[GT_RETSEC_NF])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_RTY_NF], ptsz_LigneCour[GT_RTY_NF])))
  {
    return n_Ret;
  }

  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_RETUW_NT], ptsz_LigneCour[GT_RETUW_NT])))
  {
    return n_Ret;
  }
  // SEGNAT et ACCRET
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT2_NAT_CF], ptsz_LigneCour[GT2_NAT_CF])))
  {
    return n_Ret;
  }
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT2_TYP_CT], ptsz_LigneCour[GT2_TYP_CT])))
  {
    return n_Ret;
  }
  // placement
  if ((n_Ret = strcmp(ptsz_LigneSuiv[GT_PLC_NT], ptsz_LigneCour[GT_PLC_NT])))
  {
    return n_Ret;
  }
  // currency
  return (strcmp(ptsz_LigneSuiv[GT_CUR_CF], ptsz_LigneCour[GT_CUR_CF]));
}

/**************************************************************************/
/*** Objet : fonction qui renvoie le type du poste contrepartie         ***/
/***         correspondant au poste comptable passe en parametre        ***/
/***         (recherche dans FDETTRS, fichier image de la table TDETTRS ***/
/***         de BRET)                                                   ***/
/***                                                                    ***/
/*** Nom : n_PosteContre                                                ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***   i sz_trncod : chaine contenant le poste comptable,               ***/
/***   i Kp_Dettrs : pointeur sur le fichier d'entree.                  ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***   OK                                                               ***/
/**************************************************************************/

int n_PosteContre(char *sz_trncod, FILE *Kp_Dettrs)
{
  static int b_PremierAppel = 0;
  static int n_NbreLignes;
  static T_DETTRS bd_TDETTRS[MAX_TDETTRS];
  int n_position;

  DEBUT_FCT("n_PosteContre");
  //   printf("TRNCOD =  %s\n", sz_trncod);
  /* S'il s'agit du premier appel a la fonction, on charge la table en memoire */
  if (b_PremierAppel == 0)
  {
    printf("MAX_TDETTRS =  %d\n", MAX_TDETTRS);
    n_NbreLignes = n_LoadTDETTRS(Kp_Dettrs, bd_TDETTRS);
    //       printf("n_NbreLignes =  %d\n", n_NbreLignes);
    b_PremierAppel = 1;
  }

  /* Calcul de la position du poste comptable dans la table TDETTRS */
  n_position = n_GetPosDettrs(sz_trncod, bd_TDETTRS, n_NbreLignes);

  /* Si le poste n'est pas trouve dans la table on sort et on renvoie 0 */
  if (n_position == -1)
  {
    *Ksz_DBLTRNCOD_CF = '\0';
  }

  /* On renvoie le type de poste trouve */
  else
  {
    strcpy(Ksz_DBLTRNCOD_CF, bd_TDETTRS[n_position].CTRSCOD_CF);
  }
  //   printf("Contre partie =  %s \n", Ksz_DBLTRNCOD_CF);
  RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction qui charge la table TPRSMAP afin de cherher       ***/
/***         le poste comptable de REQ11.4 et REQ11.5                   ***/
/*** Nom : n_LoadFPRSMAP                                                ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***   i filePrsMap : pointeur sur le fichier d'entree.                  ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***   Nb de lignes TPRSMAP                                                               ***/
/**************************************************************************/

int n_LoadFPRSMAP(FILE *filePrsMap)
{
  int i = 0;

  char sz_message[255]; 	
  DEBUT_FCT("n_LoadFPRSMAP");

  char buffer[MAXLINE];
  char **tab = NULL;
  while (fgets(buffer, MAXLINE, filePrsMap) != NULL)
  {
    //printf("\nn_LoadFPRSMAP buffer=[%s] i=%d ", buffer, i);
    fflush(stdout);

    tab = split(buffer, SEPARATOR, 1);
    Kp_PrsMap[i].grp750 = atoi(tab[PRSMAP_PARM2]);
    Kp_PrsMap[i].grp751 = atoi(tab[PRSMAP_PARM3]);

    strcpy(Kp_PrsMap[i].trscodeLKI, tab[PRSMAP_PARM6]);
    strcpy(Kp_PrsMap[i].trscodeDSI, tab[PRSMAP_PARM7]);
    strcpy(Kp_PrsMap[i].trscodeFWD, tab[PRSMAP_PARM8]);
    i++;
    if (i > Kn_MaxFPRSMAP)
    {
      sprintf(sz_message, "la taille du tableau  Kp_PrsMap, %d, depasse la taille allouee %d", i, Kn_MaxFPRSMAP);
      n_WriteAno(sz_message);
      RETURN_VAL(i);
    }
  }

  sprintf(sz_message, "n_LoadFPRSMAP nb line = %d\n", i);
  //n_WriteLogLevel(0, sz_message);

  RETURN_VAL(i);
}


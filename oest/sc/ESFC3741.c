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
   Reformate les donn�es au format GT avec les PATTERNSII_ANNEES montants correspondant aux PATTERNSII_ANNEES ann�es en 1 seul montant

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
[09] 13/05/2016 Florent    :spot:30543 on passe � 65 ann�es
[10] 18/11/2016 Florent    :spira:57799 Mise au format � 71 colonnes pour les fichiers EST_DLDSIIGT*
[11] 05/02/2019 Quentin Desmettre : EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
[12] 10/04/2019 Linh DOAN  :spira:77079 Generating IFRS 17 Group TL file
[13] 12/02/2020 Linh DOAN  :spira 82420 : REQ11.7 - Initial future, expense transaction
[14] 30/06/2020 Linh DOAN  :spira:79070 : REQ11.7.2
[15] 30/06/2020 Linh DOAN  :spira:79070 : remove norme checking in STD
[16] 01/07/2020 Linh DOAN  :spira:79070 : remove doublon 49400 on 11.6
[17] 29/07/2020 Linh DOAN  :spira:87876 : remove doublons on PRSMAP
[18] 06/08/2020 Linh DOAN  :spira:87876 : reduce code scope to REQ 11.7 and 11.7.2 + REQ12.4
[19] 18/09/2020 Linh DOAN  :spira:86224 : fix retro CSM 
[20] 06/10/2020 Linh DOAN  :spira:88483 : change rule for 41611 
[21] 27/10/2020 Linh DOAN  :spira 90921 : reverse sign in EGPI DAC TL generation + fix norme
[22] 03/02/2021 Linh DOAN  :spira 91991 : fix norme for CSM/LKI
[23] 27/05/2021 Linh DOAN  :spira 91532 : recompilation des programmes C
[24] 02/08/2021 Linh DOAN  :spira:98114 : TTECLEDA/R.RETINTAMT- do not force to 0 when lerging GTL files
[25] 02/08/2021 Linh DOAN  :spira 92544 : IFRS17-BDT : No GLT for internal retro
[26] 07/09/2021 Linh DOAN  :spira 97767 : I17 - FWH initial bookings
[27] 14/09/2021 Linh DOAN  :spira 90502 : fix min of groups
[28] 21/09/2021 Linh DOAN  :spira 90502 : fix format
[29] 07/10/2021 Linh DOAN  :spira 90502 : fix error retro   
[30] 13/01/2022 MZM        :spira 99819 : fix Calcul Retro  
[31] 07/03/2022 HR         :spira 101640 : REQ 11.01 - I17 Local - No initial acquisition expense in RATECCLO
[32]  05/07/2022  JBD	  :spira 104778:  Build new closing for I17S norm
[33] 14/11/2024  JYP	  :revert SPIRA 100297 : IFRS17 RAD AE integration
[34] 14/11/2024 DAD        :spira 112307: Undiscounted RAP transactions
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include "estutil.c"
#include "ESTC3001.h"
#include <utctlib.h>
#include <util.h>
#include <stdarg.h>
#include "ESFC3740.h"
/*
#include <util.h>
#include "struct.h"
#include "estserv.h"
*/


/*
EGP = EGPI
PR = Premium
CL = Claim
AE = Acquisition Expenses
ME = Maintenance Expenses
RAD = Risk Adjustment
BDT = Bad debt
*/
/*----------------------*/
/* variables de travail */
/*----------------------*/

static char VERSION_ESFC3741_C[150] = "__version__: ESFC3741.c [30] 13/01/2022 spira 99819 ACY Par UWY AT INI";


T_RUPTURE_VAR Kbd_ruptDldSIIGT;

FILE *Kp_OutputFilDldSIIGTAA; /* pointeur sur le fichier de sortie AA format� avec les nouvelles colonnes */
FILE *Kp_OutputFilDldSIIGTRA; /* pointeur sur le fichier de sortie RA format� avec les nouvelles colonnes */

FILE *Kp_InputTRSLNK; // file Kp_InputBOPRSLNK
//FILE *Kp_InputFilFBOPRSLNK; /* pointer on the input file FBOPRSLNK (binary file), not used any more */

int Kn_NbLigTrslnk;
int Kn_FBOPRSLNK; /* number of line in the file FBOPRSLNK */

FILE *Kp_FBOPRSLNK;

FILE *Kp_OutputANO;

FILE *Kp_GetDbltrncod; /* Pointeur sur le fichier des poste de contrepartie */

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

double amnt_INI_BDT_LKI = 0;
int is_INI_BDT_LKI = 0;


// ruture variables
PairData Kp_OCI[Kn_MaxData];

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


// R02-06 CSM/LC transaction transformation (REQ12.2 & 12.4)
void processCSMLCInline(char **ptb_InRecChild);

//Retro One Day Gain
void processRetroOneDayGainInline(char **ptb_InRecChild);

// 11.7 BPR-EST-906572 - Closing at inception
void processClosAtInceptionInline(char **ptb_InRecChild);

void updateFirstValue(Postion_GT i, double value);
void updateSecondValue(Postion_GT i, double value);

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
    ExitPgm(ERR_XX, "Probl�me lors de l'appel de la m�thode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESFC3741_O1", "wt", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie AA.");

  /* Ouverture du fichier contenant le poste de contrepartie */
   if (n_OpenFileAppl("ESFC3741_I2", "rt", &Kp_GetDbltrncod) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetDbltrncod");
   }
  
  if (n_OpenFileAppl("ESFC3741_O2", "wt", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie RA.");

  if (n_OpenFileAppl("ESFC3741_O3", "wt", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie.");

  // chargement de la date de clot�re fournie au programme
  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
  strcpy(sz_norme, psz_GetCharArgv(2));
  

  printf("Running %s \n", VERSION_ESFC3741_C);

  
  printf("Main norme=%s \n", sz_norme);
  printf("CLODAT=%s \n", sz_Clodat_d);

  //char normeOut = n_GetNorme(sz_norme);

  // Initialisation des variables de gestion de ruptures
  if (n_InitDldSIIGT(&Kbd_ruptDldSIIGT))
    ExitPgm(ERR_XX, "Probl�me lors de l'ex�cution de la m�thode n_InitDldSIIGT");

  /* lancement du traitement du fichier FTECLEDSII_RET */
  if (n_ProcessingRuptureVar(&Kbd_ruptDldSIIGT) != OK)
    ExitPgm(ERR_XX, "Erreur lors du traitement ligne � ligne.");

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESFC3741_I1", &(Kbd_ruptDldSIIGT.pf_InputFil)))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESFC3741_I2", &(Kp_GetDbltrncod)) == ERR) {
      ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier FDETTRS");
   }


  if (n_CloseFileAppl("ESFC3741_O1", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier AA.");

  if (n_CloseFileAppl("ESFC3741_O2", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier AR.");

  if (n_CloseFileAppl("ESFC3741_O3", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier ANO.");

  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Probl�me lors de l'appel de la m�thode n_EndPgm.");

  // lib�ration m�moire
  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la collection des valeurs OCI : EXPENSES_FUTURE, EXPENSES_INCURRED, RA_FUTURE, RA_INCURRED
 Parametre(s) :     none
 Retour :           rien
==============================================================================*/
void resetRuptureData()
{
  Postion_GT i;

  for (i = FIRST_POST; i < LAST_POST; i++)
  {
    Kp_OCI[i].valuePresent = 0;
    Kp_OCI[i].firstValue = 0.0;
    Kp_OCI[i].secondValue = 0.0;
    Kp_OCI[i].acmtrs3_code = 0;
  }
  
  amnt_INI_BDT_LKI = 0.0;
  is_INI_BDT_LKI = 0;

}

/*==============================================================================
 Objet :            Ecriture de la collection des valeurs OCI : EXPENSES_FUTURE, EXPENSES_INCURRED, RA_FUTURE, RA_INCURRED
 Parametre(s) :     none
 Retour :           rien
==============================================================================*/
void writeRuptureData(char **ptb_InRecChild, char *sz_Clodat_d)
{
  static Postion_GT i;
  
  //static char *sz_acmtrs;
  static char sz_acmtrs3_default[5];

  for (i = FIRST_POST; i < LAST_POST; i++)
  {
    if (Kp_OCI[i].valuePresent  > 0 )
    {
      //   sz_Somme est le delta
      sprintf(sz_Somme, "%18.3f", Kp_OCI[i].firstValue - Kp_OCI[i].secondValue);
      sprintf(sz_acmtrs3_default, "%.4d", Kp_OCI[i].acmtrs3_code);
      // Min (INI_BDT_LKI,0)
      //if ( ((Kp_OCI[i].firstValue - Kp_OCI[i].secondValue) < -EPSILON) || (i != INI_BDT_LKI) ) 
        writeLine(ptb_InRecChild, sz_Clodat_d, TransCode[i], sz_Somme, sz_acmtrs3_default);
    }
  }

  //
  if ((is_INI_BDT_LKI ==1)  && (amnt_INI_BDT_LKI < -EPSILON )) {
     sprintf(sz_Somme, "%18.3f", amnt_INI_BDT_LKI);
     sprintf(sz_acmtrs3_default, "%.4d", 3225);
     writeLine(ptb_InRecChild, sz_Clodat_d, "41611", sz_Somme, sz_acmtrs3_default);
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
  if (n_OpenFileAppl("ESFC3741_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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

 
  // R02-06 CSM/LC transaction transformation (REQ12.2 & 12.4)
  processCSMLCInline(ptb_InRecChild);

  // Closing at Inception (REQ11.7 & 11.7.2)
  processClosAtInceptionInline(ptb_InRecChild);

  // Retro One Day Gaine
  //processRetroOneDayGainInline(ptb_InRecChild);  

  RETURN_VAL(OK);
}


void updateACMTRS3Code(Postion_GT i, short value)
{
  Kp_OCI[i].acmtrs3_code = value;
}

void updateFirstValue(Postion_GT i, double value)
{
  Kp_OCI[i].valuePresent = 1;
  Kp_OCI[i].firstValue +=value;
}

void updateSecondValue(Postion_GT i, double value)
{
  Kp_OCI[i].valuePresent = 1;
  Kp_OCI[i].secondValue +=value;
}



/*==============================================================================
 Objet :            R02-06 Retro One Day Gain transaction transformation ()
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
// REQ 08.01 http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908786
// REQ 11.07.02 

void processRetroOneDayGainInline(char **ptb_InRecChild)
{
  // only in INI mode


  if ((strncmp(ptb_InRecChild[GT2_TYP_CT], "R", 1) == 0) &&(atoi(ptb_InRecChild[GT2_ACMTRS_NT]) == 170) && (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) == 3330) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSM", 3) == 0))
  {
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      writeLine(ptb_InRecChild, sz_Clodat_d, "49500", sz_Somme, "3500");
      sprintf(sz_Somme, "%.3f", -atof(ptb_InRecChild[GT2_TOTAUX_M]));
      writeLine(ptb_InRecChild, sz_Clodat_d, "49501", sz_Somme, "3500");
      return;
    
  }
}

/*==============================================================================
 Objet :            R02-06 CSM/LC transaction transformation (REQ12.2 & 12.4)
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
// REQ 08.01 http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908786
// REQ 12.02
// REQ 12.04 http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/EXT-IFRS17-907797

void processCSMLCInline(char **ptb_InRecChild)
{
  // only in INI mode
  static int i_IniProStatus = 0;


  if ((atoi(ptb_InRecChild[GT2_ACMTRS_NT]) == 170) 
&& (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) == 3330) 
&& (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0) 
&& (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSM", 3) == 0)
&& (strcmp(ptb_InRecChild[GT2_NORME], sz_norme) == 0)
)
  {
    
    if (strncmp(ptb_InRecChild[GT2_TYP_CT], "A", 1) == 0)
    {
      if (strcmp(sz_norme, "I17G") == 0 || strcmp(sz_norme, "I17S") == 0) //[32]
      {
        i_IniProStatus = atoi(ptb_InRecChild[GT2_GRPINIPRO_CF]);
      }
      else if (strcmp(sz_norme, "I17P") == 0)
      {
        i_IniProStatus = atoi(ptb_InRecChild[GT2_PARINIPRO_CF]);
      }
      else if (strcmp(sz_norme, "I17L") == 0)
      {
        i_IniProStatus = atoi(ptb_InRecChild[GT2_LOCINIPRO_CF]);
      }

      if ( i_IniProStatus == 1) // Nouvelle relge CSM
      {
        // Book LC transaction
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "49500", sz_Somme, "3420");
        return;
      }
      // profitable
      if (i_IniProStatus > 1) // Nouvelle regle CSM
      {
        // Book CSM
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "49400", sz_Somme, "3320");
        return;
      }
    }
    else
    {
      // Book CSM for Retro
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      writeLine(ptb_InRecChild, sz_Clodat_d, "49400", sz_Somme, "3320");
      return;
    }
  }
}

// Closing At Inception 11.7 and 11.7.2
// BPR-EST-906572 - Closing at inception          http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-906572
// BPR-EST-911737 - Retro contract at inception   http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-911737
void processClosAtInceptionInline(char **ptb_InRecChild)
{
  // 38 codes � g�n�rer
  // finally only 19 codes


  static int acmtrs = 0;
  static int acmtrs3 = 0;

  
  // gere uniquement BDT INI
  // INI_BDT_LKI,                  // INI_BDT_LKI - Bad debt INI	41611|3225 : min (Total  Amount (BDT / LKI / 105 + BDT / LKI / 205 + BDT / LKI / 320) , 0)
  // spira 92544 : IFRS17-BDT : No GLT for internal retro

  if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3) == 0) && (strncmp(ptb_InRecChild[GT2_TYP_CT], "AI", 2) != 0) &&
  (strncmp(ptb_InRecChild[GT2_TYP_CT], "RI", 2) != 0))
  {
    
    //**** REQ 11.4 DSC Current *****//
    if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0)  {

        //Current BDT/LKI (105,205,320)
        acmtrs = atoi(ptb_InRecChild[GT2_ACMTRS_NT]);
        acmtrs3 = atoi(ptb_InRecChild[GT2_ACMTRS3_NF]);
        if ((acmtrs==105 ) ||(acmtrs==205) || (acmtrs==320)){
           //  BDT Current Futures 
           //** updateFirstValue(INI_BDT_LKI, atof(ptb_InRecChild[GT2_TOTAUX_M]));
           //** updateACMTRS3Code(INI_BDT_LKI,3225); 
           amnt_INI_BDT_LKI += atof(ptb_InRecChild[GT2_TOTAUX_M]);
           is_INI_BDT_LKI = 1;
           return;
        }  
    }      
  }
  
  switch (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]))
  {

  
  case 3201:
    /*
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLACC", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLRET", 5) == 0)))
    {
      //printf("Initital Loss Corridor = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //writeLine(ptb_InRecChild, sz_Clodat_d, "49431", sz_Somme, "3221");
      //[spira 82420] Initial claims conversion :
      if (strstr(ptb_InRecChild[GT_TRNCOD_CF], "1A494302") != NULL) 
      {
        writeLine(ptb_InRecChild, sz_Clodat_d, "49431", ptb_InRecChild[GT_AMT_M], "3221");
        return;
      }
      if (strstr(ptb_InRecChild[GT_TRNCOD_CF], "2A494302") != NULL)
      {
        writeLine(ptb_InRecChild, sz_Clodat_d, "49431", ptb_InRecChild[GT_RETAMT_M], "3221");
        return;
      }
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      
      //INI_BDT_LKI 41611|3225, min (Total amount of Future Receivables ( BDT/LKI/105/1051 ), 0)   
      // BDT	LKI	105	1051
      // BDT	LKI	205	2053
      // BDT	LKI	320	( 3201, 3202 )
      

      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M])-atof(ptb_InRecChild[GT2_ACMAMT_M]));
      if (atof(ptb_InRecChild[GT2_TOTAUX_M]) < - EPSILON){ // uniquement n�gative
                writeLine(ptb_InRecChild, sz_Clodat_d, "41611", ptb_InRecChild[GT2_TOTAUX_M], "3225");
      }
      

      return;
    }

    */
    // [34]
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAP", 3) == 0) && ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IALKI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRLKI", 5) == 0)))
    {
      //Initial RA undiscounted
      //RAP	IALKI	320	3201	Initial RA Undiscounted	42770	3174	At closing type ="INI" (Closing at inception)  => Transaction amount =  Initial amount of Remaining RA at current rate � Cashflow  ( RAD / IALKI  or IRLKII / 3201)

      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M])); //GT2_TOTAUX_M >> GT2_ACMAMT_M
      writeLine(ptb_InRecChild, sz_Clodat_d, "42771", sz_Somme, "3174");
      return;
    }

     
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0) && ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IALKI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRLKI", 5) == 0)))
    {
      //Initial RA undiscounted
      //RAD	IALKI	320	3201	Initial RA Undiscounted	42770	3174	At closing type ="INI" (Closing at inception)  => Transaction amount =  Initial amount of Remaining RA at current rate � Cashflow  ( RAD / IALKI  or IRLKII / 3201)

      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M])); //GT2_TOTAUX_M >> GT2_ACMAMT_M
      writeLine(ptb_InRecChild, sz_Clodat_d, "42770", sz_Somme, "3174");
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //Initial RA LKI	42700|3177 : RAD	LKI	320	3201,	 Transaction amount = (Total amount - Initial amount) of Remaining RA at locked in rate � Discounted  ( RAD / LKI / 320 /3201)
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M])-atof(ptb_InRecChild[GT2_ACMAMT_M]));
      writeLine(ptb_InRecChild, sz_Clodat_d, "42700", sz_Somme, "3177");
      return;
    }
  

    break;

/*
  case 3202:

    // future loss corridor
    
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLACC", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLRET", 5) == 0)))
    {
      //printf("Initital Loss Corridor = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //writeLine(ptb_InRecChild, sz_Clodat_d, "20071", sz_Somme, "3222");
      //[spira 82420] Initial claims conversion :
      if (strstr(ptb_InRecChild[GT_TRNCOD_CF], "1A200712") != NULL)
      {
        writeLine(ptb_InRecChild, sz_Clodat_d, "20071", ptb_InRecChild[GT_AMT_M], "3222");
        return;
      }
      if (strstr(ptb_InRecChild[GT_TRNCOD_CF], "2A200712") != NULL){
        writeLine(ptb_InRecChild, sz_Clodat_d, "20071", ptb_InRecChild[GT_RETAMT_M], "3222");
        return;
      }
      return;
    }
   // 
   
     
    }

    break;
*/
  case 2090:

    /* 43611 d�j� fait par ESFD3630
    //  Acquisition Expenses Future  attention repeter, il faut grouper
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "PRACC", 5) == 0))
    {
      //printf("Acquisition Expenses Future = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      writeLine(ptb_InRecChild, sz_Clodat_d, "43611", sz_Somme, "2190");
      return;
    }
    */

   // move from 11.1

   if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && ((!strncmp(ptb_InRecChild[GT2_PATTYP_CT], "PRACC", 5) || !strncmp(ptb_InRecChild[GT2_PATTYP_CT], "PRRET", 5)) ||
    (!strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLACC", 5) || !strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLRET", 5))))
      {
       
        //[31]
        if ((strcmp(sz_norme, "I17G") == 0 || strcmp(sz_norme, "I17S") == 0) && strstr(ptb_InRecChild[GT_TRNCOD_CF], "1143610I") != NULL) //[32]
        {
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT_AMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "43611", sz_Somme, "2190"); //ptb_InRecChild[GT2_ACMTRS3_NF]
          return;
        }
        if (strcmp(sz_norme, "I17P") == 0 && strstr(ptb_InRecChild[GT_TRNCOD_CF], "1143610K") != NULL)
        {
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT_AMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "43611", sz_Somme, "2190"); //ptb_InRecChild[GT2_ACMTRS3_NF]
          return;
        }
        if (strcmp(sz_norme, "I17L") == 0 && strstr(ptb_InRecChild[GT_TRNCOD_CF], "1143610M") != NULL)
        {
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT_AMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "43611", sz_Somme, "2190"); //ptb_InRecChild[GT2_ACMTRS3_NF]
          return;
        }
        /*if (strstr(ptb_InRecChild[GT_TRNCOD_CF], "2143610I") != NULL){

          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT_RETAMT_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "43611", sz_Somme, "2190"); //ptb_InRecChild[GT2_ACMTRS3_NF]
          return;
        }*/
    }

   
    break;

  case 3115:
    // attention  // il faut v�rifier si la norme est � controler // && (strncmp(ptb_InRecChild[GT2_NORME], "I17", 3) == 0)
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "INF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_NORME], "I17", 3) == 0)) 
    {
      
      //Maintenance Expenses Future Initial
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));  //GT2_TOTAUX_M >> GT2_ACMAMT_M
      writeLine(ptb_InRecChild, sz_Clodat_d, "46061", sz_Somme, "3223");
      return;
    }
    break;

   case 7029:

    //spira 97767 : I17 - FWH initial bookings


   if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLACC", 5) == 0)
     )
    {

        // Initial FWH undiscounted in TL| 1181201I| = Total of 7029 / pattern type = CLACC / closing type = INI
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "81201", sz_Somme , ptb_InRecChild[GT2_ACMTRS3_NF]);
        return;
    }

    break;

  
  default:

    break;
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

  //TODO get norme from input

  norme = n_GetNorme(sz_norme);
  
  if (norme == 'R')
  {
    n_WriteAno("ERROR : Norme Incorrecte \n");
    // skip this line
    return 1;
  }

  
  // chargement de la date de clot�re fournie au programme

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
  DldSIIGT[GT_ACY_NF] = ptb_InRecChild[GT_UWY_NF] ;  // DldSIIGT[GT_ACY_NF] = gsz_Annee;   //[30] 
  DldSIIGT[GT_SCOSTRMTH_NF] = gsz_Mois;
  DldSIIGT[GT_SCOENDMTH_NF] = gsz_Mois;
  DldSIIGT[GT_CLM_NF] = "";
  DldSIIGT[GT_CUR_CF] = ptb_InRecChild[GT2_ACMCUR_CF];
  DldSIIGT[GT_AMT_M] = sz_Somme;
  DldSIIGT[GT_CED_NF] = ptb_InRecChild[GT_CED_NF];
  DldSIIGT[GT_BRK_NF] = ptb_InRecChild[GT_BRK_NF];
  DldSIIGT[GT_PAY_NF] = ptb_InRecChild[GT_PAY_NF];
  DldSIIGT[GT_KEY_NF] = ptb_InRecChild[GT_KEY_NF];
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
    DldSIIGT[GT_RETACY_NF] = ptb_InRecChild[GT_RTY_NF];   //[30]DldSIIGT[GT_RETACY_NF] = gsz_Annee;      
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
    DldSIIGT[GT_DBLTRNCOD_CF]=Ksz_DBLTRNCOD_CF;

    n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
  }
  else
  {
    if (!b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF])){
      DldSIIGT[GT_RETINTAMT_M] = sz_Somme; // spira 98114
      sprintf(sz_trncod, "21%.5s%c", sz_inittrncod, norme);
      DldSIIGT[GT_TRNCOD_CF] = sz_trncod;

      n_PosteContre(sz_trncod, Kp_GetDbltrncod); //Ksz_DBLTRNCOD_CF
      DldSIIGT[GT_DBLTRNCOD_CF]=Ksz_DBLTRNCOD_CF;

      n_WriteCols(Kp_OutputFilDldSIIGTRA, DldSIIGT, SEPARATEUR, 0);
      // doulication TECLEDA
      n_WriteCols(Kp_OutputFilDldSIIGTAA, DldSIIGT, SEPARATEUR, 0);
    }
  }
  return 0;
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premi�re du 	***/
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
  if (strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0) //[32]
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
    static int b_PremierAppel=0;
    static int n_NbreLignes;
    static T_DETTRS bd_TDETTRS[MAX_TDETTRS];
    int n_position;

   DEBUT_FCT("n_PosteContre");
//   printf("TRNCOD =  %s\n", sz_trncod);
/* S'il s'agit du premier appel a la fonction, on charge la table en memoire */
    if ( b_PremierAppel==0 ) {
       n_NbreLignes = n_LoadTDETTRS(Kp_Dettrs, bd_TDETTRS);
//       printf("n_NbreLignes =  %d\n", n_NbreLignes);	
       b_PremierAppel=1;
    }

/* Calcul de la position du poste comptable dans la table TDETTRS */
    n_position = n_GetPosDettrs(sz_trncod, bd_TDETTRS, n_NbreLignes);

/* Si le poste n'est pas trouve dans la table on sort et on renvoie 0 */
   if (n_position == -1) {
         *Ksz_DBLTRNCOD_CF = '\0';
   }

/* On renvoie le type de poste trouve */
   else {
      strcpy(Ksz_DBLTRNCOD_CF, bd_TDETTRS[n_position].CTRSCOD_CF);
   }
//   printf("Contre partie =  %s \n", Ksz_DBLTRNCOD_CF);
   RETURN_VAL(OK);
}



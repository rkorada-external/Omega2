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
[17] 05/08/2020 Linh DOAN  :spira:87876 : rebuild GLT transformation
[18] 24/09/2020 Linh DOAN  :spira:87920 : NDIC accounting
[19] 05/10/2020 Linh DOAN  :spira:88483 : add grouping 1010 and 1011
[20] 13/10/2020 Linh DOAN  :spira:90502 : bad debt booking
[21] 19/10/2020 Linh DOAN  :spira:90502 : bad debt booking - remove grouping 1011
[22] 23/10/2020 Linh DOAN  :spira:90502 : bad debt booking - remove grouping 1011
[23] 27/10/2020 Linh DOAN  :spira:90921 : reverse sign of change of EGPI DAC TL generation + fix norme
[24] 30/10/2020 Linh DOAN  :spira:90987 : change EXP/EGPPI to EXP/EGPCL
[25] 27/11/2020 Linh DOAN  :spira:91116 : spira 90052,91705,91116
[26] 04/05/2021 Linh DOAN  :spira:95499 : bad debt LKI (42617, 41617)
[27] 27/05/2021 Linh DOAN  :spira:91532 : recompilation des programmes C
[28] 06/07/2021 Linh DOAN  :spira:97339 : REQ 11.06 - Bad debt change in booking transaction adjustment : 49350, 49440
[29] 02/08/2021 Linh DOAN  :spira:98114 : TTECLEDA/R.RETINTAMT- do not force to 0 when lerging GTL files
[30] 04/08/2021 Linh DOAN  :spira 92544 : IFRS17-BDT : No GLT for internal retro
[31] 04/08/2021 Linh DOAN  :spira 96994 : REQ 11.04 - Error in the pattern type used for the TL data generation of Bad debt OCI
[32] 07/09/2021 Linh DOAN  :spira 97767 : I17 - FWH initial bookings
[33] 21/09/2021 Linh DOAN  :spira 90502 : fix format
[34] 07/10/2021 Linh DOAN  :spira 90502 : fix error retro
[35] 18/11/2021 MiS        :spira 100258: REQ 11.01 - No Internal Acquisition Expense at Q4 in Bookings TL
[36] 14/12/2021 DaD        :spira 100992: Change in EST / Change in EGPI needs to be multiply by (-1) except for the grouping 1051 and 2211
[37] 04/02/2022 HR         :spira 100977: I17 - Criteria to compute Revenue / EXP / CSM
[38] 04/02/2022 MZM        :spira 100372: REQ 11.05 - IFRS 17 - Error in unwind booking for some transactions
[39] 10/02/2022 MZM        :spira 101733: Change in EST / Change in EGPI MAJ Signe et calcul
[40] 25/02/2022 MZM        :spira 101440:  R03-13 All "REQ 11.6 Change in EGPI" / TL Multi Year - RAD ; AND R03-06 : UPDATE RULE (Rollback)
[41] 28/02/2022 DaD        :spira 100992:  Fix Bug : Change in EST / Change in EGPI MAJ Signe in STEP 30
[42] 14/03/2022 DaD        :spira 102818: Reverse spira 101733
[43]  05/07/2022  JBD     :spira 104778:  Build new closing for I17S norm
[44] 11/08/2022 JYP        :spira 100297: TL RAD-I*DSI/I*LKI now calculated by ESFC3650 
[45] 06/03/2023 HR         :spira 108973: Change in EGPI position- estimates incorrect on some retro NP - Copy
[46] 10/05/2023 MZM        :spira 109732: I17 - No undiscounted RA at closing in RATECCLO : Reactivation "TL RAD-I*DSI/I*LKI" 
[47] 24/05/2023 HR        :spira 109607: I17 - Delete Change in EGPI/Estimates on IAE
[48] 10/11/2023 DAD        :spira 110682: I17 - Include BDT / FWD / 1010
[49] 12/11/2024 DAD        :spira 112307: Undiscounted RAP transactions

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

static char VERSION_ESFC3740_C[150] = "__version__: ESFC3740.c [49] Spira 112307 - Undiscounted RAP transactions";

T_RUPTURE_VAR Kbd_ruptDldSIIGT;

FILE *Kp_OutputFilDldSIIGTAA; /* pointeur sur le fichier de sortie AA format� avec les nouvelles colonnes */
FILE *Kp_OutputFilDldSIIGTRA; /* pointeur sur le fichier de sortie RA format� avec les nouvelles colonnes */

FILE *Kp_InputTRSLNK; // file Kp_InputBOPRSLNK
//FILE *Kp_InputFilFBOPRSLNK; /* pointer on the input file FBOPRSLNK (binary file), not used any more */

int Kn_NbLigTrslnk;
int Kn_FBOPRSLNK; /* number of line in the file FBOPRSLNK */

FILE *Kp_FBOPRSLNK;

FILE *Kp_OutputANO;

FILE   *Kp_GetDbltrncod; /* Pointeur sur le fichier des poste de contrepartie */

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
PairData Kp_OCI[LAST_POST+1];

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

// R02-00 Acquisition Expenses Transformation (REQ11.1)
void processAcquisitionExpensesInline(char **ptb_InRecChild);
// R02-01  Maintenance Expenses Transformation (REQ11.2) : cashflow
void processMaintenanceExpensesInline(char **ptb_InRecChild);

// R02-02  Risk Adjustment Transformation (REQ12.1)
void processRiskAdjustmentInline(char **ptb_InRecChild);

// R02-03  Discount at Locked in rates Transformation (REQ11.4/5)
void processEscompteInline(char **ptb_InRecChild);

// R02-05 IFRS17 revenue Transformation (REQ11.6)
void processRevenueInline(char **ptb_InRecChild);

// R02-06 CSM/LC transaction transformation (REQ12.2 & 12.4)
void processCSMLCInline(char **ptb_InRecChild);


void processAllGroupInline(char **ptb_InRecChild);

//R03-05 Standard Accounting Transactions Scope (REQ11.1 & 11.2)
//void processStdTLInline(char **ptb_InRecChild);

// 11.7 BPR-EST-906572 - Closing at inception
//void processClosAtInceptionInline(char **ptb_InRecChild);

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
  if (n_OpenFileAppl("ESFC3740_O1", "wt", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie AA.");

  /* Ouverture du fichier contenant le poste de contrepartie */
   if (n_OpenFileAppl("ESFC3740_I2", "rt", &Kp_GetDbltrncod) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplGetDbltrncod");
   }
  
  if (n_OpenFileAppl("ESFC3740_O2", "wt", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie RA.");

  if (n_OpenFileAppl("ESFC3740_O3", "wt", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Probl�me lors de l'ouverture du fichier de sortie.");

  // chargement de la date de clot�re fournie au programme
  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
  strcpy(sz_norme, psz_GetCharArgv(2));
  

  printf("Running %s \n", VERSION_ESFC3740_C);

  
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
  if (n_CloseFileAppl("ESFC3740_I1", &(Kbd_ruptDldSIIGT.pf_InputFil)))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESFC3740_I2", &(Kp_GetDbltrncod)) == ERR) {
      ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier FDETTRS");
   }


  if (n_CloseFileAppl("ESFC3740_O1", &Kp_OutputFilDldSIIGTAA))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier AA.");

  if (n_CloseFileAppl("ESFC3740_O2", &Kp_OutputFilDldSIIGTRA))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier AR.");

  if (n_CloseFileAppl("ESFC3740_O3", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Probl�me lors de la fermeture du fichier ANO.");

  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Probl�me lors de l'appel de la m�thode n_EndPgm.");

  // lib�ration m�moire
  exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la collection des valeurs OCI 
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
  

}

/*==============================================================================
 Objet :            Ecriture de la collection des valeurs OCI 
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
    if (Kp_OCI[i].valuePresent  > 0)
    {
      //   sz_Somme est le delta
      sprintf(sz_Somme, "%18.3f", Kp_OCI[i].firstValue - Kp_OCI[i].secondValue);
      
      sprintf(sz_acmtrs3_default, "%.4d", Kp_OCI[i].acmtrs3_code);
      writeLine(ptb_InRecChild, sz_Clodat_d, TransCode[i], sz_Somme, sz_acmtrs3_default);
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
  if (n_OpenFileAppl("ESFC3740_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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

  // remove checking norm
  
  // R02-01  Maintenance Expenses Transformation (REQ11.2) : cashflow
  processMaintenanceExpensesInline(ptb_InRecChild);

  // R02-03  Discount at Locked in rates Transformation (REQ11.4)
  processEscompteInline(ptb_InRecChild);

  // R02-02  Risk Adjustment Transformation (REQ12.1)
  processRiskAdjustmentInline(ptb_InRecChild);

  // R02-05 IFRS17 revenue Transformation (REQ11.6)
  processRevenueInline(ptb_InRecChild);

  processAllGroupInline(ptb_InRecChild);

  
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
 Objet :            R02-01  Maintenance Expenses Transformation (REQ11.2) : cashflow
 URL   :            http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-906427
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
void processMaintenanceExpensesInline(char **ptb_InRecChild)
{

  // generer 
  /*
  
  - Maintenance Expenses Incurred Undiscounted	: CSF	INF 	314	3114	Maintenance Expenses Incurred Undiscounted	46070	3114	Transaction amount =  Amount Total amount of Inflated Incurred maintenance expense prospective stock ( CSF / INF / 314 / 3114 )
  - Maintenance Expenses Future Undiscounted    : CSF	INF		314	3115	Maintenance Expenses Future Undiscounted	  46060	3115	Transaction amount = Amount Total amount of Inflated Remaining maintenance expenses prospective stock ( CSF / INF / 314 / 3115 )
  */

  //if (strncmp(ptb_InRecChild[GT2_ACMTRS_NT], "314", 3) == 0) // remove checking ACMTRS_NT]
  {
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "INF", 3) == 0))
    {
      // R01-01 1. Inflated Incurred maintenance expense prospective stock
      if (strncmp(ptb_InRecChild[GT2_ACMTRS3_NF], "3114", 4) == 0)
      {
        //printf("Inflated Incurred maintenance expense prospective stock   >> 46070 >> Maintenance Expenses Incurred Undiscounted, value=%f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "46070", sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
        return;
      }

      // R01-01 2. Inflated Remaining maintenance expenses prospective stock
      if (strncmp(ptb_InRecChild[GT2_ACMTRS3_NF], "3115", 4) == 0)
      {
        //printf("Inflated Remaining maintenance expenses prospective stock >> 46060 >> Maintenance Expenses Future Undiscounted, value =%f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        // totaux of CSF~INF,3115
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "46060", sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
        return;
      }
    }
    
  }
}

/*==============================================================================
 Objet :            R02-03  Discount at Current and at Locked in rates Transformation (REQ11.4 )
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
void processEscompteInline(char **ptb_InRecChild)
{
 
  static int acmtrs3 = 0;

  
  // gere uniquement BDT
  // BDT_CUR_ICR  (42616/4122) BDT Current Incurred   DSI-LKI ( 1010 + 1011 + 2014 + 3010 + 3011)
  // BDT_CUR_FUT  (41616/4102) BDT Current Futures   DSI-LKI  ( 1051 + 2053 + 3201 + 3202 )
  // BDT_LKI_ICR  (42617/3097) BDT LKI Incurred  DSC/LKI  T-I ( 1010 + 1011 + 2014 + 3010 + 3011)
  // BDT_LKI_FUT  (41617/1097) BDT LKI Futures   DSC/LKI  T-I ( 1051 + 2053 + 3201 + 3202 )

  // BDT_FWD_ICR  (42618/4226) BDT FWD Incurred   BDT/FWD T-I ( 1010 + 1011 + 2014 + 3010 + 3011 ) 
  // BDT_FWD_FUT  (41619/4206) BDT FWD Futures    BDT/FWD T-I ( 1051 + 2053 + 3201 + 3202 )


//*****************************************************************/
// new spec
// gere uniquement BDT
  // BDT_CUR_ICR  (42616/4122) BDT Current Incurred   BDT/BDT - BDT/LKI  ( 1010 + 2014 + 3010 + 3011)
  // BDT_CUR_FUT  (41616/4102) BDT Current Futures   BDT/BDT - BDT/LKI  ( 1051 + 2053 + 3201 + 3202 )
  // BDT_LKI_ICR  (42617/3097) BDT LKI Incurred  BDT/LKI  T ( 1010 + 2014 + 3010 + 3011)
  // BDT_LKI_FUT  (41617/1097) BDT LKI Futures   BDT/LKI  T ( 1051 + 2053 + 3201 + 3202 )

  // BDT_FWD_ICR  (42618/4226) BDT FWD Incurred   BDT/FWD T-I ( 1010 + 2014 + 3010 + 3011 ) 
  // BDT_FWD_FUT  (41619/4206) BDT FWD Futures    BDT/FWD T-I ( 1051 + 2053 + 3201 + 3202 )

  
  // spira 92544 : IFRS17-BDT : No GLT for internal retro
  // check RI/AI
   
  if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3) == 0)  && (strncmp(ptb_InRecChild[GT2_TYP_CT], "AI", 2) != 0) 
  &&   (strncmp(ptb_InRecChild[GT2_TYP_CT], "RI", 2) != 0))
  {
    
    acmtrs3 = atoi(ptb_InRecChild[GT2_ACMTRS3_NF]);
    
      //**** REQ 11.4 DSC Current *****//
      //BDT/DSI >> BDT/BDT 96994
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "BDT", 3) == 0)  {

        if ((acmtrs3==1010)  || (acmtrs3==2014) ||  (acmtrs3==3010) || (acmtrs3==3011) ){
           //  BDT Current Incurred
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "42616", sz_Somme, "4122");
          return;
          
        }
        if ((acmtrs3==1051) ||(acmtrs3==2053 ) || (acmtrs3==3201) ||  (acmtrs3==3202) ){
          // BDT Current Futures
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "41616", sz_Somme, "4102");
          return;
          
        }
        return;
       
      }

      //BDT/LKI 
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0)  {

        if ((acmtrs3==1010) || (acmtrs3==2014) ||  (acmtrs3==3010) || (acmtrs3==3011) ){
           //  BDT LKI Incurred
           sprintf(sz_Somme, "%.3f", -atof(ptb_InRecChild[GT2_TOTAUX_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "42616", sz_Somme, "4122");
           //BDT LKI Incurred
           sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "42617", sz_Somme, "3097");
           return; 
          }
          
        
        if ((acmtrs3==1051) ||(acmtrs3==2053 ) || (acmtrs3==3201) ||  (acmtrs3==3202) ){
          // BDT Current Futures
          sprintf(sz_Somme, "%.3f", -atof(ptb_InRecChild[GT2_TOTAUX_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "41616", sz_Somme, "4102");
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "41617", sz_Somme, "1097");

          return;
          
        }
        

      }
       //****  REQ 11.5 Uwind  *****//
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0)  {

        //BDT/FWD 
         if ((acmtrs3==1010)  || (acmtrs3==2014) ||  (acmtrs3==3010) || (acmtrs3==3011) ){
           //  BDT Current Incurred 

           sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "42618", sz_Somme, "4226");
           return;
         }

        //BDT/FWD 
        if ((acmtrs3==1051) ||(acmtrs3==2053 ) || (acmtrs3==3201) ||  (acmtrs3==3202) ){
           //  BDT Current Futures 
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "41619", sz_Somme, "4206");
          return;
        }
      }
      return;
  }

  

  //RAD/FWD 
  
  //[38] 42760 ==> 42660 ; 
  //     42750 ==> 42650
  
  if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0)) 
  {

  //if (strcmp( ptb_InRecChild[GT_CTR_NF], "TR0011595") == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2021  && strcmp( ptb_InRecChild[GT_RETCTR_NF], "RP0002234") == 0 && atoi(ptb_InRecChild[GT_RTY_NF]) == 2021  && (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) ==3201 ) )  
  //	printf("Debug 007 RAD acmtrs3 = %d ; atof(ptb_InRecChild[GT2_TOTAUX_M]) = %.3f ; atof(ptb_InRecChild[GT2_ACMAMT_M]) = %.3f\n", atoi(ptb_InRecChild[GT2_ACMTRS3_NF]), atof(ptb_InRecChild[GT2_TOTAUX_M]), atof(ptb_InRecChild[GT2_ACMAMT_M])) ;

    
    acmtrs3 = atoi(ptb_InRecChild[GT2_ACMTRS3_NF]);
            

        if (acmtrs3==3010){
           //  Incurred Risk Adjustment Unwind	42760	
           sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "42760", sz_Somme, "4223"); //[38]
           return;
         }
        if (acmtrs3==3201){
           //  Future Risk Adjustment Unwind 42750	4203
           sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
           writeLine(ptb_InRecChild, sz_Clodat_d, "42750", sz_Somme, "4203"); //[38]
           return;
         }         

  }

}

/*==============================================================================
 Objet :            R02-02  Risk Adjustment Transformation (REQ12.1)
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
void processRiskAdjustmentInline(char **ptb_InRecChild)
{

  /* [46]
RAD	"IADSI IRDSI "	320	3201	Future RA Undiscounted	42780	3172 : AMT=INITIAL
RAD	LKI	320	3201	Future RA LKI	42710	3176 , AMT = TOTAUX - INITIAL
RAD	DSI	320	3201	Future RA OCI	42730	4103 , AMT = RAD/DSI - RAD/LKI : (RA_FUTURES)

RAD	"IADSI IRDSI "	301	3010	Incurred RA Undiscounted	42781	3173 : AMT=INITIAL
RAD	LKI	301	3010	Incurred RA LKI	42720	3175 , AMT = TOTAUX - INITIAL
RAD	DSI	301	3010	Incurred RA OCI	42740	4123 , AMT = RAD/DSI - RAD/LKI : (RA_INCURRED) 

  */
  //static Postion_GT i;

  //[46]

  if ((strncmp(ptb_InRecChild[GT2_ACMTRS_NT], "301", 3) == 0) && (strncmp(ptb_InRecChild[GT2_ACMTRS3_NF], "3010", 4) == 0))
  {
    // 42740	4123
    // i = RA_INCURRED;
    // [49]
    if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAP", 3) == 0)
    {
      // Assumed / Retro Incurred Prudence RA at current rate - Cashflow
      // Incurred RA prudence Undiscounted
      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IADSI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRDSI", 5) == 0))
        {
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "42783",sz_Somme , "3173");
          return;
        }
    }

    if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0)
    {
      // 1. Incurred RA at current rate . Cashflow:

      // assumed contract or retro
      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IADSI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRDSI", 5) == 0))
      {
        //printf("Incurred RA at current rate . Cashflow: >> 42781 >> Incurred RA Undiscounted ptb_InRecChild[GT2_ACMAMT_M]=%f \n", atof(ptb_InRecChild[GT2_ACMAMT_M]));
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "42781",sz_Somme , "3173");
        return;
      }
    

      // 3. Incurred RA at current rate . Discounted:
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "DSI", 3) == 0)
      {
        //printf("Incurred RA at current rate . Discounted >> 42740 >> first Inccured Expenses ptb_InRecChild[GT_AMT_M]=%f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateFirstValue(RA_INCURRED, atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateACMTRS3Code(RA_INCURRED, 4123);
        return;
      }

      // 4. Incured RA at locked in rate . Discounted:
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0) 
      {
        //printf("Incurred RA at current rate . Discounted >> 42740 >> first Inccured Expenses ptb_InRecChild[GT_AMT_M]=%f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateSecondValue(RA_INCURRED, atof(ptb_InRecChild[GT2_TOTAUX_M]));

        //printf("Incured RA at locked in rate . Discounted >> 42720 >> Incurred RA DSC = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M])-atof(ptb_InRecChild[GT2_ACMAMT_M]));
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "42720", sz_Somme, "3175");
        return;
      }
    }
  }

  //[46]

  if ((strncmp(ptb_InRecChild[GT2_ACMTRS_NT], "320", 3) == 0)&& (strncmp(ptb_InRecChild[GT2_ACMTRS3_NF], "3201", 4) == 0))
  {
    // 42730	4103
    // i = RA_FUTURE;
    // [49]
    if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAP", 3) == 0) 
    {
      // Assumed / Retro RA Prudence Future at current rate - Cashflow
      // Future RA prudence Undiscounted
      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IADSI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRDSI", 5) == 0))
      {
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "42782", sz_Somme,"3172");
          return;
      }
    }

    if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0)
    {
      // 5. Remaining RA at current rate . Cashflow:
      // assumed contract or retro
      if ((strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IADSI", 5) == 0) || (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "IRDSI", 5) == 0))
      {
        
        // Future RA Undiscounted 42780

          //printf("Remaining RA at current rate . Cashflow >> 42780 >> Future RA Undiscounted  = %f \n", atof(ptb_InRecChild[GT2_ACMAMT_M]));
          sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_ACMAMT_M]));
          writeLine(ptb_InRecChild, sz_Clodat_d, "42780", sz_Somme,"3172");
          return;
      }

      // 7. Remaining RA at current rate . Discounted:
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "DSI", 3) == 0)
      {
        //printf("Remaining RA at current rate . Discounted >> 42730 >> First Value Future RA Discounted  = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateFirstValue(RA_FUTURE, atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateACMTRS3Code(RA_FUTURE, 4103);
        return;
      }

      // 8. Remaining RA at locked in rate . Discounted:
      if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0)
      {
        // Future RA DSC 42710 
        //printf("Remaining RA at current rate . Cashflow >> 42710 >> Future RA DSC = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M])-atof(ptb_InRecChild[GT2_ACMAMT_M]));
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M]));
        writeLine(ptb_InRecChild, sz_Clodat_d, "42710", sz_Somme, "3175");

        //printf("Remaining RA at current rate . Discounted >> 42730 >> Second Value Future RA Discounted  = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateSecondValue(RA_FUTURE, atof(ptb_InRecChild[GT2_TOTAUX_M]));

        return;
        
      }
    }
  }
}



// R02-05 IFRS17 revenue Transformation (REQ11.6)
/*==============================================================================
 Objet :            R02-05 IFRS17 revenue Transformation (REQ11.6)
 Parametre(s) :     rien
 Retour :           rien
==============================================================================*/
void processRevenueInline(char **ptb_InRecChild)
{

  //37
  double CSM_PAT_PREV = 0;
  double CSM_PAT_PREV_RP = 0;
  double LC_PAT_PREV = 0;
  
  if( strcmp(ptb_InRecChild[GT2_LC_PAT_PREV],"") != 0 ) {
      LC_PAT_PREV = atof(ptb_InRecChild[GT2_LC_PAT_PREV]);
  }
  
  if( strcmp(ptb_InRecChild[GT2_CSM_PAT_PREV],"") != 0 )   {
      CSM_PAT_PREV = atof(ptb_InRecChild[GT2_CSM_PAT_PREV]);
  }  
  if( strcmp(ptb_InRecChild[GT2_CSM_PAT_PREV_RP],"") != 0 )   {
      CSM_PAT_PREV_RP = atof(ptb_InRecChild[GT2_CSM_PAT_PREV_RP]);
  }  

  //static Postion_GT i = CHG_EST_FUTURE_FIX_PRE;
  
  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {

  switch (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]))
  {

  case 1010:

    // Discount unwind SII Scope (REQ11.5)
    // add grouping 1010
    //EXP	EARPR	105	1051	Change in Estimates - Future Receivables	
    //12121	6500	Transaction amount = Total amount of Future Fixed Premiums ( DSC / LKI / 1051  ) � Total amount of Earned Expected Future Fixed Premiums ( EXP / EARPR / 105 / 1051 )

    //i = CHG_EST_FUTURE_FIX_PRE; // 12121/6500 CHG_EST_FUTURE_FIX_PRE

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums  RETEST first value = %f \n", (-1)*atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateFirstValue(CHG_EST_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M])); //[39], [42]
      updateACMTRS3Code(CHG_EST_FUTURE_FIX_PRE,6500);
      
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARPR", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed RETEST Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateSecondValue(CHG_EST_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M])); //[39]
      updateACMTRS3Code(CHG_EST_FUTURE_FIX_PRE,6500);
      return;
      // sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M] );
      // writeLine(ptb_InRecChild, sz_Clodat_d, "99906", sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
    }

    //i = CHG_EGPI_FUTURE_FIX_PRE; //1010, spira 91116 add groupe 1010, then transcode 10121 = groupings (1010 , 1051)

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateSecondValue(CHG_EGPI_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_FIX_PRE, 6520); //Change in EGPI - Future fixed premiums
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPPR", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateFirstValue(CHG_EGPI_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_FIX_PRE, 6520);
      return;
    }

    break;  


  case 1051:

    // Discount unwind SII Scope (REQ11.5)
    // same grouping 1010
    //EXP	EARPR	105	1051	Change in Estimates - Future Receivables	12121	6500	Transaction amount = Total amount of Future Fixed Premiums ( DSC / LKI / 1051  ) � Total amount of Earned Expected Future Fixed Premiums ( EXP / EARPR / 105 / 1051 )

    //i = CHG_EST_FUTURE_FIX_PRE; // 12121/6500 CHG_EST_FUTURE_FIX_PRE

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateFirstValue(CHG_EST_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M])); //[39], [42]
      updateACMTRS3Code(CHG_EST_FUTURE_FIX_PRE,6500);
      
      return;
    } 

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARPR", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateSecondValue(CHG_EST_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M])); //[39]
      updateACMTRS3Code(CHG_EST_FUTURE_FIX_PRE,6500);
      return;
      // sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M] );
      // writeLine(ptb_InRecChild, sz_Clodat_d, "99906", sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
    }

    //EXP	EGPPR	105	1051	Change in EGPI - Future Receivables	
    //10121	6520	Transaction amount = Total amount of Future EGPI Expected Fixed Premiums ( EXP / EGPPR / 1051 ) � Total amount of Future Fixed Premiums ( DSC / FWD / 1051 )

    //i = CHG_EGPI_FUTURE_FIX_PRE; //1051

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateSecondValue(CHG_EGPI_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_FIX_PRE, 6520); //Change in EGPI - Future fixed premiums
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPPR", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateFirstValue(CHG_EGPI_FUTURE_FIX_PRE, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_FIX_PRE, 6520);
      return;
    }

    break;
 
  case 2031:
    

    //EXP	EARAE	203	2031	Change in Estimates - DAC Brokerage	
    //43062	6200	Transaction amount = Total amount of DAC Brokerage ( DSC / LKI / 203 / 2031 ) � Total amount of Earned Expected DAC Brokerage ( EXP / EARAE / 203 / 2031 )
    // Change in Estimates - DAC Brokerage	43062|6200 : EXP/EARAE/203/2031
    //i = CHG_EST_DAC_BRK;

     if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EST_DAC_BRK, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_DAC_BRK, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_BRK, 6220); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EST_DAC_BRK, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_DAC_BRK, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_BRK, 6220); 
      return;
    }


    // EXP	EGPAE	203	2031	Change in EGPI - DAC Brokerage
    //	43065|6220	Transaction amount = Total amount of EGPI Expected DAC Brokerage ( EXP/EGPAE/2031 ) � Total amount of DAC Brokeraget ( DSC / FWD / 203 / 2031 )
    // 	Change in EGPI - DAC Brokerage	43065|6220 : EXP/EGPAE/203/2031
    //i = CHG_EGPI_DAC_BRK;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EGPI_DAC_BRK, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_DAC_BRK, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_DAC_BRK, 6220); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EGPI_DAC_BRK, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_DAC_BRK, atof(ptb_InRecChild[GT2_TOTAUX_M])); 
      updateACMTRS3Code(CHG_EGPI_DAC_BRK, 6220); 
      return;
    }


    break ;
  
  case 2032:
     //EXP	EARCL	203	2032	Change in Estimates - DAC Variables	
     //43063	6100	Transaction amount = Total amount of DAC Variables ( DSC / LKI / 203 / 2032 ) � Total amount of Earned Expected DAC Variables ( EXP / EARCL / 203 / 2032 )
    // Change in Estimates - DAC Variables	43063|6100 : EXP/EARCL/203/2032
    //i = CHG_EST_DAC_VAR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EST_DAC_VAR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_DAC_VAR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_VAR, 6100); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARCL", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EST_DAC_VAR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_DAC_VAR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_VAR, 6100); 
      return;
    }

    // EXP	EGPCL	203	2032	Change in EGPI - DAC Variables	
    //43066	6120	Transaction amount = Total amount of EGPI Expected DAC Variables ( EXP / EGPCL / 2032 ) � Total amount of DAC Variables ( DSC / FWD / 203 / 2032 )
    // Change in EGPI - DAC Variables	43066|6120 :  EXP/EGPCL/203/2032
    //i = CHG_EGPI_DAC_VAR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EGPI_DAC_VAR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_DAC_VAR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_DAC_VAR, 6120); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPCL", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EGPI_DAC_VAR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_DAC_VAR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_DAC_VAR, 6120); 
      return;
    }
   
    break ;
    
  case 2035:
    
    //EXP	EARAE	203	2035	Change in Estimates - DAC Brokerage IFRS17	
    //43064	6200	 Transaction amount = Total amount of DAC Brokerage IFRS17 ( DSC / LKI / 203 / 2035 ) � Total amount of Earned Expected DAC Brokerage IFRS17 ( EXP / EARAE / 203 / 2035 )
    // Change in Estimates - DAC Brokerage IFRS17	43064|6200 : EXP/EARAE/203/2035
    //i = CHG_EST_DAC_BRK17;
     if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EST_DAC_BRK17, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_DAC_BRK17, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_BRK17, 6220); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EST_DAC_BRK17, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_DAC_BRK17, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_DAC_BRK17, 6220); 
      return;
    }

    //EXP	EGPAE	203	2035	Change in EGPI - DAC Brokerage IFRS17	43067	6220	
    //Transaction amount = Total amount of EGPI Expected DAC Brokerage IFRS17 ( EXP / EGPAE / 2035 ) � Total amount of DAC Brokerage IFRS17 ( DSC / FWD / 203 / 2035 )
    // Change in EGPI - DAC Brokerage IFRS17	43067|6220 : EXP/EGPAE/203/2035
    //i = CHG_EGPI_DAC_BRK17;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EGPI_DAC_BRK17, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_DAC_BRK17, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_DAC_BRK17, 6220); 
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EGPI_DAC_BRK17, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_DAC_BRK17, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_DAC_BRK17, 6220); 
      return;
    }


    break ;
     
  case 2053:
    // EXP	EARAE	205	2053	Change in Estimates - Future Acquisition Cost	12200	6200	Transaction amount = Total amount of Future Brokerage ( DSC / LKI / 2053 ) � Total amount of Earned Expected Future Brokerage ( EXP / EARAE / 205 / 2053 )

    //i = CHG_EST_FUTURE_BRKR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EST_FUTURE_BRKR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_FUTURE_BRKR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_BRKR, 6200); // Change in Estimates - Future brokerage new group
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EST_FUTURE_BRKR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_FUTURE_BRKR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_BRKR, 6200); // Change in Estimates - Future brokerage new group

      return;
    }

    // EXP	EGPAE	205	2053	Change in EGPI - Future Acquisition Cost	
    // 12220	6220	Transaction amount = Total amount of Future EGPI Expected Brokerage ( EXP / EGPAE / 2053 ) � Total amount of Future Brokerage ( DSC / FWD / 2053 )
    //i = CHG_EGPI_FUTURE_BRKR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums first value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateSecondValue(CHG_EGPI_FUTURE_BRKR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_FUTURE_BRKR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_BRKR, 6220); // Change in EGPI - Future brokerage new group
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPAE", 5) == 0))
    {
      //printf("Future EGPI Expected Fixed Premiums seconde value = %f \n", atof(ptb_InRecChild[GT2_TOTAUX_M]));
      // updateFirstValue(CHG_EGPI_FUTURE_BRKR, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_FUTURE_BRKR, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_BRKR, 6220); // Change in EGPI - Future brokerage new group
      return;
    }

    break;
  case 2090:
    
    //Change in Estimates - Acquisition expenses 43667|6600 :  /EXP/EARAE/209/2090	
    // 43667	6600	Transaction amount = Total amount of Internal Acquisition Expenses Future ( DSC / LKI / 2090 ) � Total amount of Earned Expected Future Internal Acquisition Expenses ( EXP / EARAE / 209 / 2090 )
    //i = CHG_EST_FUTURE_ACQU_EXP;

    //[47]
    /*if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {

      // updateFirstValue(CHG_EST_FUTURE_ACQU_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_FUTURE_ACQU_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_ACQU_EXP, 6600); // Change in Estimates - Acquisition Expenses Future
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARAE", 5) == 0))
    {

      // updateSecondValue(CHG_EST_FUTURE_ACQU_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_FUTURE_ACQU_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_ACQU_EXP, 6600);
      return;
    }*/

    //CHG_EGPI_FUTURE_ACQU_EXP, Change in EGPI - Acquisition expenses	43666|6620 : EXP/EGPAE/209/2090	
    //43666	6620	Transaction amount = Total amount of Future EGPI Expected Internal Acquisition Expenses ( EXP / EGPAE / 2090 ) � Total amount of Internal Acquisition Expenses Future ( DSC / FWD / 2090 )
    //i = CHG_EGPI_FUTURE_ACQU_EXP;

    //[47]
	/*if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

      // updateSecondValue(CHG_EGPI_FUTURE_ACQU_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_FUTURE_ACQU_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_ACQU_EXP, 6620);
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPAE", 5) == 0))
    {

      // updateFirstValue(CHG_EGPI_FUTURE_ACQU_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_FUTURE_ACQU_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateACMTRS3Code(CHG_EGPI_FUTURE_ACQU_EXP, 6620); //Change in EGPI - Acquisition Expenses Future
      return;
    }*/

    // [35]
   if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "PRACC", 5) == 0))
   {
      updateFirstValue(CHG_IAE_FUTURE_UNDIS, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_IAE_FUTURE_UNDIS, 2090);
      return;
   }

    break;

  case 3201:
    
    //CHG_EST_RA, Change in Estimates - Risk adjustment	49300|6300 : EXP/EARRA/320/3201	
     //49300	6300	Transaction amount = Total amount of Risk adjustment on future claims ( RAD / LKI / 3201 ) � Total amount of  Earned Expected Risk adjustment on future claims ( EXP / EARRA / 3201) 
     //i = CHG_EST_RA; // Change in Estimates - (retro) risk adjustment

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {

      // updateFirstValue(CHG_EST_RA, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]    //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      updateFirstValue(CHG_EST_RA, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_RA, 6300); 
      return;  
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARRA", 5) == 0))
    {

      // updateSecondValue(CHG_EST_RA, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_RA, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_RA, 6300);
      return;
    }

    //i = CHG_EGPI_RA;
    //49320	6320	Transaction amount = Total amount of Future EGPI Expected RA ( EXP / EGPRA / 3201 ) � Total amount of Remaining RA discount forward ( RAD / FWD / 3201 )

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "RAD", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

  	//if (strcmp( ptb_InRecChild[GT_CTR_NF], "TR0011595") == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2021  && strcmp( ptb_InRecChild[GT_RETCTR_NF], "RP0002234") == 0 && atoi(ptb_InRecChild[GT_RTY_NF]) == 2021  && (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) ==3201 ) )  
    //  printf("Debug 008 RAD acmtrs3 = %d ; atof(ptb_InRecChild[GT2_TOTAUX_M]) = %.3f ; atof(ptb_InRecChild[GT2_ACMAMT_M]) = %.3f\n", atoi(ptb_InRecChild[GT2_ACMTRS3_NF]), atof(ptb_InRecChild[GT2_TOTAUX_M]), atof(ptb_InRecChild[GT2_ACMAMT_M])) ;
      
      // updateSecondValue(CHG_EGPI_RA, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_RA, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //[40]updateSecondValue(CHG_EGPI_RA, (-1)*(atof(ptb_InRecChild[GT2_TOTAUX_M]) - atof(ptb_InRecChild[GT2_ACMAMT_M])));      
      updateACMTRS3Code(CHG_EGPI_RA, 6320);
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPRA", 5) == 0))
    {

  	//if (strcmp( ptb_InRecChild[GT_CTR_NF], "TR0011595") == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2021  && strcmp( ptb_InRecChild[GT_RETCTR_NF], "RP0002234") == 0 && atoi(ptb_InRecChild[GT_RTY_NF]) == 2021  && (atoi(ptb_InRecChild[GT2_ACMTRS3_NF]) ==3201 ) )  
    //  printf("Debug 009 GT2_PATCAT_CT = EXP : RAD acmtrs3 = %d ; atof(ptb_InRecChild[GT2_TOTAUX_M]) = %.3f ; atof(ptb_InRecChild[GT2_ACMAMT_M]) = %.3f\n", atoi(ptb_InRecChild[GT2_ACMTRS3_NF]), atof(ptb_InRecChild[GT2_TOTAUX_M]), atof(ptb_InRecChild[GT2_ACMAMT_M])) ;
      

      // updateFirstValue(CHG_EGPI_RA, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]    //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      updateFirstValue(CHG_EGPI_RA, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_RA, 6320);                           //Change in EGPI - Risk adjustment
      return;
    }


    break;
  /*
  case 3202:
    i = CHG_EST_FUTURE_LOSS_CORRIDOR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      updateFirstValue(i, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(i, 6100); // Change in Estimates - Future loss corridor
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARCL", 5) == 0))
    {
      updateSecondValue(i, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      return;
    }

    i = CHG_EGPI_FUTURE_LOSS_CORRIDOR;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

      updateSecondValue(i, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPCL", 5) == 0))
    {
      updateFirstValue(i, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(i, 6120); //Change in EGPI - Future loss corridor
      return;
    }

    break;

  */
  case 3115:
    
    // CHG_EST_MAINT_EXP, Change in Estimates - Maintenance expense future	46077|6640 : EXP/EARME/314/3115	
    // DSC/LKI -EXP/EARME of 3115
    //i = CHG_EST_MAINT_EXP;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      // updateFirstValue(CHG_EST_MAINT_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_MAINT_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_MAINT_EXP, 6640); // Change in Estimates - Maintenance expenses
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARME", 5) == 0))
    {

      // updateSecondValue(CHG_EST_MAINT_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_MAINT_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_MAINT_EXP, 6640);
      return;
    }

    //CHG_EGPI_MAINT_EXP,	Change in EGPI - Maintenance expense future	46075|6660 : EXP/EGPME/314/3115 : old 46076
    // (EXP/EGPME) - (DSC/FWD) of 3115 
    //i = CHG_EGPI_MAINT_EXP;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

      // updateSecondValue(CHG_EGPI_MAINT_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_MAINT_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_MAINT_EXP, 6660); 
      break;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPME", 5) == 0))
    {

      // updateFirstValue(CHG_EGPI_MAINT_EXP, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]      //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      updateFirstValue(CHG_EGPI_MAINT_EXP, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_MAINT_EXP, 6660); 
      return;
    }
    break;

    case 2211:
    // NDIC 
    // new spec , spira 91705 : EARNE to EARCL
    // CHG_EST_NDIC Change in Estimates - NDIC, 49340|6100 : EXP/EARCL/221/2211
    // Total EARNE (EXP / EARCL / 221 / 2211) - Total LKI (DSC / LKI / 221 / 2211)
    //i = CHG_EST_NDIC;

     if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARCL", 5) == 0))
    {

      updateFirstValue(CHG_EST_NDIC, atof(ptb_InRecChild[GT2_TOTAUX_M]));       
      updateACMTRS3Code(CHG_EST_NDIC, 6100);                               //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      return;
    }
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {

      updateSecondValue(CHG_EST_NDIC, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_NDIC, 6100);                               //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      break;
    }


    //i = CHG_EGPI_NDIC;
    // 49360	6120	Transaction amount = Amount Total EGPPI (EXP / EGPPI / 221 / 2211) -  Total FWD (DSC / FWD / 221 / 2211)
    // before : Total EGPPI (EXP / EGPPI / 221 / 2211) -  Total FWD (DSC / FWD / 221 / 2211)
    // spira 90987 : Total FWD (DSC / FWD / 221 / 2211) - Total EGPCL (EXP / EGPCL / 221 / 2211)
    // 	49360	6120	Transaction amount =�Total FWD (DSC / FWD / 221 / 2211) - Amount Total EGPCL (EXP / EGPCL / 221 / 2211)

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

      updateFirstValue(CHG_EGPI_NDIC, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_NDIC, 6120); 
      break;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPCL", 5) == 0))
    {

            
      updateSecondValue(CHG_EGPI_NDIC, atof(ptb_InRecChild[GT2_TOTAUX_M])); 
      updateACMTRS3Code(CHG_EGPI_NDIC, 6120);                               //atoi(ptb_InRecChild[GT2_ACMTRS3_NF])
      return;
    }
    break;
    

  default:
    
    break;
  }
  } 
 

  //TODO : 3 codes of spira 82711
  /*
    Change in Estimates - DAC Brokerage
    Change in Estimates - DAC Brokerage IFRS17
    Change in Estimates - DAC Variables
  */
}

void processAllGroupInline(char **ptb_InRecChild)
{
    //static Postion_GT i; 
    //Change in Estimates - Bad debt	49350|6100 : EXP/EARBD/*/*
    //  BDT/LKI - EXP/EARBD 
    //i=CHG_EST_BDT;

  //37
  double CSM_PAT_PREV = 0;
  double CSM_PAT_PREV_RP = 0;
  double LC_PAT_PREV = 0;
  
  if( strcmp(ptb_InRecChild[GT2_LC_PAT_PREV],"") != 0 ) {
      LC_PAT_PREV = atof(ptb_InRecChild[GT2_LC_PAT_PREV]);
  }
  
  if( strcmp(ptb_InRecChild[GT2_CSM_PAT_PREV],"") != 0 )   {
      CSM_PAT_PREV = atof(ptb_InRecChild[GT2_CSM_PAT_PREV]);
  }  
  if( strcmp(ptb_InRecChild[GT2_CSM_PAT_PREV_RP],"") != 0 )   {
      CSM_PAT_PREV_RP = atof(ptb_InRecChild[GT2_CSM_PAT_PREV_RP]);
  }  

  //static Postion_GT i = CHG_EST_FUTURE_FIX_PRE;
    	
    static int acmtrs3=0;

    acmtrs3 = atoi(ptb_InRecChild[GT2_ACMTRS3_NF]);

  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3) == 0) && (strncmp(ptb_InRecChild[GT2_TYP_CT], "AI", 2) != 0) 
		&&  (strncmp(ptb_InRecChild[GT2_TYP_CT], "RI", 2) != 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
     	//  Spira 97339 
      //  [41] [48]
       if (acmtrs3==1010 || acmtrs3==1051 || (acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
 	       
      		updateFirstValue(CHG_EST_BDT, atof(ptb_InRecChild[GT2_TOTAUX_M]));      
      		updateACMTRS3Code(CHG_EST_BDT, 6100);   
      		return;
	      }
        //  [41]
        // if ((acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
 	       
      	// 	updateFirstValue(CHG_EST_BDT, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M]));      
      	// 	updateACMTRS3Code(CHG_EST_BDT, 6100);   
      	// 	return;
	      // }
    }

    }
    
  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {
    
    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARBD", 5) == 0) 
		&& (strcmp(ptb_InRecChild[GT2_ACCRET], "R") == 0))
    {
      //  Spira 97339
      //  [41] [48]
      if (acmtrs3==1010 || acmtrs3==1051 || (acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
                
        updateSecondValue(CHG_EST_BDT, atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateACMTRS3Code(CHG_EST_BDT, 6100);
        return;
      }
      //  [41]
      // if ((acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
                
      //   updateSecondValue(CHG_EST_BDT, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //   updateACMTRS3Code(CHG_EST_BDT, 6100);
      //   return;
      // }
    }

    }
    //Change in EGPI - Bad debt	49440|6120 : EXP/EGPBD/*/*	
    // EXP/EGPBD  - BDT/FWD  : all grouping
    //i = CHG_EGPI_BDT;

  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3) == 0) && (strncmp(ptb_InRecChild[GT2_TYP_CT], "AI", 2) != 0) 
		&&  (strncmp(ptb_InRecChild[GT2_TYP_CT], "RI", 2) != 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {
      //  Spira 97339
      //  [41] [48]
      if (acmtrs3==1010 || acmtrs3==1051 || (acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
      
        updateSecondValue(CHG_EGPI_BDT, atof(ptb_InRecChild[GT2_TOTAUX_M]));
        updateACMTRS3Code(CHG_EGPI_BDT, 6120);
        return;
      }
      //  [41]
      // if ((acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
      
      //   updateSecondValue(CHG_EGPI_BDT, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M]));
      //   updateACMTRS3Code(CHG_EGPI_BDT, 6120);
      //   return;
      // }
    }

    }

  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPBD", 5) == 0) 
		&& (strcmp(ptb_InRecChild[GT2_ACCRET], "R") == 0))
    {
      //  [41] [48]
      if (acmtrs3==1010 || acmtrs3==1051 || (acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
            
        updateFirstValue(CHG_EGPI_BDT, atof(ptb_InRecChild[GT2_TOTAUX_M])); 
        updateACMTRS3Code(CHG_EGPI_BDT, 6120);                               //Change in EGPI - Bad debt
        return;
      }
      //  [41]
      // if ((acmtrs3==2053) || (acmtrs3==3201)|| (acmtrs3==3202)){
            
      //   updateFirstValue(CHG_EGPI_BDT, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); 
      //   updateACMTRS3Code(CHG_EGPI_BDT, 6120);                               //Change in EGPI - Bad debt
      //   return;
      // }
    }

    }
		
  //SPIRA 108973
  //if ( CSM_PAT_PREV != 1 || LC_PAT_PREV != 1 ) {
  if ( ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") != 0 && (CSM_PAT_PREV != 1 || LC_PAT_PREV != 1) ) || ( strcmp(ptb_InRecChild[GT2_CTRCAT_CF], "02") == 0 && CSM_PAT_PREV_RP != 1 ) ) {

// Future claim : (DSC/LKI) -(EXP/EARCL) of  3201 and 3202 
 if (strncmp(ptb_InRecChild[GT2_ACMTRS_NT], "320", 3) == 0){

  // CHG_EST_FUTURE_CLM, Change in Estimates - Future Claim	49100|6100 :  EXP/EARCL/320/*
  //i = CHG_EST_FUTURE_CLM;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "LKI", 3) == 0))
    {
      // updateFirstValue(CHG_EST_FUTURE_CLM, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EST_FUTURE_CLM, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_CLM, 6100); //Change in Estimates - Future claims
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EARCL", 5) == 0))
    {
      // updateSecondValue(CHG_EST_FUTURE_CLM, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EST_FUTURE_CLM, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EST_FUTURE_CLM, 6100);
      return;
    }
   // CHG_EGPI_FUTURE_CLM, Change in EGPI - Future Claim	49120|6120 : EXP/EGPCL/320/* 	
   //  EXP/EGPCL - DSC/FWD of 3201 and 3202
    //i = CHG_EGPI_FUTURE_CLM;

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "FWD", 3) == 0))
    {

      // updateSecondValue(CHG_EGPI_FUTURE_CLM, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateSecondValue(CHG_EGPI_FUTURE_CLM, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_CLM, 6120);
      return;
    }

    if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "EXP", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "EGPCL", 5) == 0))
    {
      // updateFirstValue(CHG_EGPI_FUTURE_CLM, (-1) * atof(ptb_InRecChild[GT2_TOTAUX_M])); // [41]
      updateFirstValue(CHG_EGPI_FUTURE_CLM, atof(ptb_InRecChild[GT2_TOTAUX_M]));
      updateACMTRS3Code(CHG_EGPI_FUTURE_CLM, 6120); //Change in EGPI - Future claims
      return;
    }
  }

   }

	//spira 97767 : I17 - FWH initial bookings


   if ((strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3) == 0) && (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "CLACC", 5) == 0)
     && (acmtrs3==7029 ) )
    {

        //LRC FWH undiscounted in TL�1181203I�= Total of 7029 / pattern type = CLACC / closing type = POS or INV
        sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[GT2_TOTAUX_M]));

        writeLine(ptb_InRecChild, sz_Clodat_d, "81203", sz_Somme, ptb_InRecChild[GT2_ACMTRS3_NF]);
        return;
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
    DldSIIGT[GT_RETINTAMT_M] ="0"; // spira 98114
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
      // doublication TECLEDA
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
  if (strcmp(Norme_CF, "I17G") == 0 || strcmp(Norme_CF, "I17S") == 0) //[43]
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



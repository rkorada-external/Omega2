/*==============================================================================
 Nom de l'application          : ESTIMATION SOLVENCY
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
[11] 05/02/2019 Q.Desmetre :REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
[12] 22/05/2019 Y.Thomas   :spira 78204 78211 fix currency
[13] 23/05/2019 C.Socie    :spira 78211 fixe calculation 
[14] 30/04/2020 C.Socie    :spira 86176 EBS - ULAE - No GLT amounts
[15] 19/06/2020 C.Socie    :spira 87700 : IFRS17 Bad debt management : Change sign in AN sum
[16] 18/05/2020 KBagwe	   :spira 86940-EBS - Funds Held impact on Discount - Revert (same 82679)
[17] 24/09/2020 KBagwe	   :spira 88994-EBS - ULAE - No GLT amounts - Accounting transaction change	
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <structA.h>
#include <estserv.h>
#include "estutil.c"
#include "ESTC3001A.h"

/* DEBUG mode : 1 to activate, 0 to deactivate*/
#define DEBUG 0

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define GTSII_AM01_M 54

#define GT2_CUR_CF    17  //[12]
#define GT2_RETCUR_CF 33  //[12]
#define GT2_ACMTRS_NT 41
#define GT2_ACMAMT_M  42
#define GT2_ACMCUR_CF 43
#define GT2_ACCRET    48
#define GT2_NORME     49
#define GT2_PATCAT_CT 51
#define GT2_PATTYP_CT 52
#define GT2_TOTAUX  122

/*----------------------*/
/* variables de travail */
/*----------------------*/
T_RUPTURE_VAR Kbd_ruptDldSIIGT;
T_RUPTURE_VAR Kbd_ruptDldSIIGT2;
FILE *Kp_OutputFilDldSIIGT ; /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE *Kp_InputTRSLNK;
FILE *Kp_InputDldSII;
FILE *Kp_OutputANO;
char gsz_Annee[5], gsz_Mois[3], gsz_Jour[3]; // de la Date de cloture Ex: 20111201
//double n_Total;
double td_Total[4];
char sz_NormeTotal[10] = "Z";
int n_NormeCur;

int countDldSII=0;
int mapCounter;
int k;
int lastkeyIndex=0;
int lastkeyIfd=0;


/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
int n_InitDldSIIGT(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneDldSIIGT(char **ptb_InRecChild);
int n_init_TRNCOD(char *psz_ACCRET_NF, int psz_ACMTRS_NT, char *psz_NORME_CF, char *psz_DETTRS_CF);

// [011]
int n_InitDldSIIGTRNew(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneDldSIIGTRNew		( char **ptb_InRecChild );
int n_ConditionSyncDldSIIGT2	( char **pbd_InRecOwner,  char **pbd_InRecChild  );
int n_ConditionRupture_DldSIIGT	(char  **pbd_InRecChild, char  **pbd_InRecChild_Cur);
void   ChargementDldSIIData();
char* getKey(char **row);
unsigned long GenerateHash(char* str, unsigned int len);

long getFileNbLigne(FILE * fl);
int searchDldSIIData(char  **pbd_InRecOwner);
void calcul (int i, char  **pbd_InRecOwner, double d_Somme, int n_NormeCur);
//char key[240] ;


T_DATAMAP * tmap;
T_DldSIIGT * tDLDSII;
 

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
  char sz_Clodat_d[9] = "";
  // Initialisation des signaux
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1060A_O1", "wt", &Kp_OutputFilDldSIIGT)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
  if (n_OpenFileAppl("ESTC1060A_O2", "wt", &Kp_OutputANO)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );

  // TRSLNK est un fichier binaire
  if (n_OpenFileAppl("ESTC1060A_I2", "rb", &Kp_InputTRSLNK)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );

  if (n_OpenFileAppl("ESTC1060A_I1", "rb", &Kp_InputDldSII)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );


  // chargement de la date de clotûre fournie au programme
  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
  sprintf(gsz_Annee, "%.4s", sz_Clodat_d);
  sprintf(gsz_Mois, "%.2s", &sz_Clodat_d[4]);
  sprintf(gsz_Jour, "%.2s", &sz_Clodat_d[6]);

  // chargement des données du fichier binaire TRSLNK en memoire
  if ( n_ChargerTRSLNK(PRS_EBS_INVENT_ACCEP, Kp_InputTRSLNK) == -1 ) // [003]
    ExitPgm( ERR_XX , "" ) ;


  // fermeture du fichier binaire
  if (n_CloseFileAppl("ESTC1060A_I2", &Kp_InputTRSLNK))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier binaire d'input.");



 // Initialisation des variables de gestion de ruptures
  if (n_InitDldSIIGTRNew(&Kbd_ruptDldSIIGT2))
    ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitDldSIIGT");

 /* lancement du traitement du fichier FTECLEDSII_RET */
  if (n_ProcessingRuptureVar(&Kbd_ruptDldSIIGT2) != OK)
    ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );


  if (n_CloseFileAppl("ESTC1060A_I1", &(Kbd_ruptDldSIIGT2.pf_InputFil)))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier binaire d'input.");

   // fermeture du fichier binaire
  if (n_CloseFileAppl("ESTC1060A_I2", &Kp_InputDldSII))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier binaire d'input.");


  // Initialisation des variables de gestion de ruptures
  if (n_InitDldSIIGT(&Kbd_ruptDldSIIGT))
    ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitDldSIIGT");
 
  /* lancement du traitement du fichier FTECLEDSII_RET */
  if (n_ProcessingRuptureVar(&Kbd_ruptDldSIIGT) != OK)
    ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1060A_I1", &(Kbd_ruptDldSIIGT.pf_InputFil)))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESTC1060A_O1", &Kp_OutputFilDldSIIGT))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");

  if (n_CloseFileAppl("ESTC1060A_O2", &Kp_OutputANO))
    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ANO.");

 
  if (n_EndPgm() == ERR)
    ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  // libération mémoire
  exit(OK);
}


/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitDldSIIGT(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitDldSIIGT" ) ;

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier maitre Perimetre de souscription */
  if (n_OpenFileAppl("ESTC1060A_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneDldSIIGT;
  pbd_Rupt->c_Separ       = '~';

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
  
  char *DldSIIGT[GT_NBCOL2 + 1];   // tableau de pointeur a l'image du fichier en sortie
  double n_Somme = 0;
  char sz_Somme[30] = "";
  char sz_trncod[9], sz_mask[5];   // [006]
  int i = 0;/* Added for Phase1b Migration */
  int       acmtrs;	               // [012]

  memset(DldSIIGT, 0 , sizeof(DldSIIGT));

  if ( ptb_InRecChild[GT2_NORME] == 0 )
  {
    n_WriteCols( Kp_OutputANO, ptb_InRecChild, SEPARATEUR, 0 );
    RETURN_VAL( OK );
  }

  if ( b_IsBlankOrEmpty(ptb_InRecChild[GT2_NORME]) ){
    RETURN_VAL( OK );
	}

  if (strcmp(ptb_InRecChild[GT2_NORME],"ALLNO") == 0){   //MOD[16]
	  
	  strcpy(ptb_InRecChild[GT2_NORME], "SII");
	  n_ActionLigneDldSIIGT(ptb_InRecChild);
	  
	  strcpy(ptb_InRecChild[GT2_NORME], "IFRSI");
	  n_ActionLigneDldSIIGT(ptb_InRecChild);
	  
	  strcpy(ptb_InRecChild[GT2_NORME], "GIM");
	  n_ActionLigneDldSIIGT(ptb_InRecChild);
	  
	  strcpy(ptb_InRecChild[GT2_NORME], "EV");
	  n_ActionLigneDldSIIGT(ptb_InRecChild);
	  
	  RETURN_VAL( OK );
  }
  
  memset(sz_trncod, 0, sizeof(sz_trncod));

  acmtrs = 0;

  if      (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC"  , 3 ) == 0){
    acmtrs = 10000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "BDT"  , 3 ) == 0 && strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3 ) == 0){
    acmtrs = 20000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "RMNTP", 5 ) == 0 && strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3 ) == 0){
    acmtrs = 30000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "INF"  , 3 ) == 0 && strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3 ) == 0){
    acmtrs = 60000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF"  , 3 ) == 0){
    acmtrs = 40000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "ICR"  , 3 ) == 0){
    acmtrs = 50000;
	}
  else if (strncmp(ptb_InRecChild[GT2_PATTYP_CT], "RMNTP", 5 ) == 0 && strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3 ) == 0){
    acmtrs = 70000;
	}

  acmtrs += atoi(ptb_InRecChild[GT2_ACMTRS_NT]);

  n_init_TRNCOD(ptb_InRecChild[GT2_ACCRET], acmtrs, ptb_InRecChild[GT2_NORME], sz_trncod);
  strncpy(sz_mask, &(sz_trncod[2]), 4);   // [006]
  sz_mask[4] = '\0';                      // [006]

	  
    // Calcul somme des PATTERNSII_ANNEES années
    for (i = GTSII_AM01_M; i < GTSII_AM01_M + PATTERNSII_ANNEES; i++ )
    {
      n_Somme += atof(ptb_InRecChild[i]);
    }

  if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "BDT", 3 ) == 0)
  {
    sprintf(sz_Somme, "%.3f", n_Somme );
  }
  else if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "DSC", 3 ) == 0)
  {
    if (atoi(ptb_InRecChild[GT2_ACMTRS_NT]) == 317 ){
      sprintf(sz_Somme, "%.3f", atof(ptb_InRecChild[54]) );	  
	}
    else
	{
		
		sprintf(sz_Somme, "%.3f", n_Somme - atof(ptb_InRecChild[GT2_ACMAMT_M]));
      // [012]
	 /* if (strcmp(ptb_InRecChild[GT2_ACMTRS_NT], "301") == 0)
	  {
         Synchronisation with the PATTERN file 
		if( strcmp(ptb_InRecChild[GT2_NORME], sz_NormeTotal) < 0 )
		{
			//n_ProcessingRuptureSyncVar(&Kbd_ruptDldSIIGT_new, ptb_InRecChild);
			searchDldSIIData(ptb_InRecChild);
			strcpy(sz_NormeTotal, ptb_InRecChild[GT2_NORME]);
			n_NormeCur = n_GetNormeTRN(ptb_InRecChild[GT2_NORME]); //[14]
	
			n_Somme = td_Total[n_NormeCur];
			td_Total[n_NormeCur] = 0.0;
			#if DEBUG == 1
			printf( "somme finale pour norme %s : %f\n", ptb_InRecChild[GT2_NORME], n_Somme);
			#endif
		
			sprintf(sz_Somme, "%.3f", n_Somme);
		}	
	 }else{
		sprintf(sz_Somme, "%.3f", n_Somme - atof(ptb_InRecChild[GT2_ACMAMT_M]));
	  	strcpy(sz_NormeTotal,"Z");   //[13]
	  }*/
	}
  }
  else if (strncmp(ptb_InRecChild[GT2_PATCAT_CT], "CSF", 3 ) == 0)
  {
    sprintf(sz_Somme, "%.3f", n_Somme);
  }
  else
  {
    sprintf(sz_Somme, "%.3f", n_Somme);
  }

  DldSIIGT[GT_SSD_CF] = ptb_InRecChild[GT_SSD_CF];
  DldSIIGT[GT_ESB_CF] = ptb_InRecChild[GT_ESB_CF];
  DldSIIGT[GT_BALSHEY_NF] = gsz_Annee;
  DldSIIGT[GT_BALSHRMTH_NF] = gsz_Mois;
  DldSIIGT[GT_BALSHRDAY_NF] = gsz_Jour;
  DldSIIGT[GT_TRNCOD_CF] = sz_trncod;
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
  DldSIIGT[GT_CUR_CF] = ptb_InRecChild[GT2_CUR_CF]; //[12]
  DldSIIGT[GT_AMT_M] = sz_Somme;
  DldSIIGT[GT_CED_NF] = ptb_InRecChild[GT_CED_NF];
  DldSIIGT[GT_BRK_NF] = ptb_InRecChild[GT_BRK_NF];
  DldSIIGT[GT_PAY_NF] = ptb_InRecChild[GT_PAY_NF];
  DldSIIGT[GT_KEY_NF] = ptb_InRecChild[GT_KEY_NF];
  if ( b_IsBlankOrEmpty(ptb_InRecChild[GT_RETCTR_NF]) )
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
    DldSIIGT[GT_RETINTAMT_M] = "0";        // 0 pour l'instant - sera mis a jour dans autre prog
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
    DldSIIGT[GT_RETCUR_CF] = ptb_InRecChild[GT2_RETCUR_CF]; //[12]
    DldSIIGT[GT_RETAMT_M] = sz_Somme;

    DldSIIGT[GT_PLC_NT] = ptb_InRecChild[GT_PLC_NT];
    DldSIIGT[GT_RTO_NF] = ptb_InRecChild[GT_RTO_NF];
    DldSIIGT[GT_INT_NF] = ptb_InRecChild[GT_INT_NF];
    DldSIIGT[GT_RETPAY_NF] = ptb_InRecChild[GT_RETPAY_NF];
    DldSIIGT[GT_RETKEY_CF] = ptb_InRecChild[GT_RETKEY_CF];
    DldSIIGT[GT_RETINTAMT_M] = "0";        // 0 pour l'instant - sera mis a jour dans autre prog
  }

  if ( b_IsBlankOrEmpty(ptb_InRecChild[GT_CTR_NF]) )
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
  DldSIIGT[GT_ORICOD_LS] = "EBSGTA";
  
DldSIIGT[GT_ACMTRS3_NT] = ptb_InRecChild[123];
  	strcpy(sz_NormeTotal,"Z");   //[13]
	
  if (strcmp(sz_mask, "9999") != 0) {// [006]
 
    n_WriteCols( Kp_OutputFilDldSIIGT, DldSIIGT, SEPARATEUR, 0 );
}

  RETURN_VAL( OK );
}

/*==============================================================================
objet :
  fonction de recherche du poste à partir de la NORME_CF solvency
retour :
 >= 0 ok, c'est l'index dans le tableau
 < 0 pas trouvé
==============================================================================*/
int n_init_TRNCOD(char *psz_ACCRET_NF, int psz_ACMTRS_NT, char *psz_NORME_CF, char *psz_DETTRS_CF)
{
  DEBUT_FCT("n_init_TRNCOD");

  int n_acmtrs; // 3 chiffres
  //short n_calc_acmtrs; //normalement en 5 chiffres
  short n_typeCTR_CPTA = 2;
  short n_norme;
  short n_poste_calc;

  n_norme = n_GetNormeTRN(psz_NORME_CF); //[14]
  if ( n_norme == -1 )
    RETURN_VAL( -1 );

  if ( b_IsBlankOrEmpty(psz_ACCRET_NF) || strncmp(psz_ACCRET_NF, "A", 1 ) == 0 )
    n_typeCTR_CPTA = 1;

  n_acmtrs = psz_ACMTRS_NT;

  //n_calc_acmtrs = n_typeCTR_CPTA * 10000 + n_norme * 1000 + n_acmtrs;
  // en commentaire temporairement 11/10/2012 Florent
  //if( n_RechPosteTRSLNK(PRS_EBS_INVENT_ACCEP, n_calc_acmtrs, psz_DETTRS_CF) == -1)
  //{ // on n'a pas trouvé psz_DETTRS_CF
  switch (n_acmtrs)
  {
  case 10101:
  case 10201: n_poste_calc = 1007; break;

  case 10105:
  case 10205:
  case 10320: n_poste_calc = 4160; break;

  case 10301: n_poste_calc = 4260; break;

  case 20101:
  case 20201: n_poste_calc = 1008; break;

  case 20105:
  case 20205:
  case 20320: n_poste_calc = 4161; break;

  case 20301:
  //[005] les Bad Debts sont retirees des "Claim Reserves BDT"
  // PPZ 20150529
  case 20901:
  case 20902:
  case 20702:  n_poste_calc = 4261; break;

  case 13114: n_poste_calc = 4260; break;
  case 13115: n_poste_calc = 4160; break;

  case 63114: n_poste_calc = 4601; break;
  case 63115:  n_poste_calc = 4611; break;

  case 10317: n_poste_calc = 4945; break;

  default: n_poste_calc = 9999; break;  // [006]
  }
  sprintf(psz_DETTRS_CF, "%dA%d%d2", n_typeCTR_CPTA, n_poste_calc, n_norme);

  RETURN_VAL( 0 );
  //}
}



long getFileNbLigne(FILE * fl)
{
  long nbligne = 1;
  char lg[LONGBUF];
  rewind(fl); // on se remet au d?but
  while ( fgets(lg, LONGBUF, fl) != NULL)  nbligne++;
  rewind(fl);
  return (nbligne - 1);
}

int searchDldSIIData(char  **pbd_InRecOwner){
	int i=0;
	double d_Somme = 0;
	char* key ;
	int keyIndex=0;

	n_NormeCur = n_GetNormeTRN(pbd_InRecOwner[GT2_NORME]); //[14]
		
	key = getKey(pbd_InRecOwner);
	long hashkey =  GenerateHash(key, strlen(key));
				
	keyIndex=-1;
	
	for (i=lastkeyIndex;i<mapCounter; i++){
		if (hashkey == tmap[i].key){
			lastkeyIndex = i;
			keyIndex=lastkeyIndex;
			break;
		}
	}
	if (keyIndex == -1){
		td_Total[n_NormeCur] =0 ;
		return -1;
	}

    //printf("keyIndex  : %d , count = %d \n ",keyIndex, tmap[keyIndex].count);
	for (i=0;i<tmap[keyIndex].count; i++){
		d_Somme =0;
		// if (strcmp( pbd_InRecOwner[GT_CTR_NF], "02T025844" )  == 0 && atoi(pbd_InRecOwner[GT_UWY_NF]) == 2018){
		//	printf("count = %d, keyIndex  : %d , index = %d  , i = %d , norm= %s \n",tmap[keyIndex].count, keyIndex, tmap[keyIndex].index[i], 
		//				i, tDLDSII[tmap[keyIndex].index[i]].NORME );
	    //} 		
		if ( b_IsBlankOrEmpty(pbd_InRecOwner[GT2_ACCRET]) || strncmp(pbd_InRecOwner[GT2_ACCRET], "A", 1 ) == 0 ){
			

			if (strcmp( pbd_InRecOwner[GT_CTR_NF], tDLDSII[tmap[keyIndex].index[i]].CTR_NF )  == 0 &&
					atoi(pbd_InRecOwner[GT_END_NT]) == tDLDSII[tmap[keyIndex].index[i]].END_NT &&  
					atoi(pbd_InRecOwner[GT_SEC_NF]) == tDLDSII[tmap[keyIndex].index[i]].SEC_NF && 
					atoi(pbd_InRecOwner[GT_UWY_NF]) == tDLDSII[tmap[keyIndex].index[i]].UWY_NF && 
					atoi(pbd_InRecOwner[GT_UW_NT]) == tDLDSII[tmap[keyIndex].index[i]].UW_NT  && 
					
					strcmp( pbd_InRecOwner[GT_RETCTR_NF], tDLDSII[tmap[keyIndex].index[i]].RETCTR_NF )  == 0   &&
		 			atoi(pbd_InRecOwner[GT_RETEND_NT]) == tDLDSII[tmap[keyIndex].index[i]].RETEND_NT && 
					atoi(pbd_InRecOwner[GT_RETSEC_NF]) == tDLDSII[tmap[keyIndex].index[i]].RETSEC_NF && 
					atoi(pbd_InRecOwner[GT_RTY_NF]) == tDLDSII[tmap[keyIndex].index[i]].RTY_NF && 
					atoi(pbd_InRecOwner[GT_RETUW_NT]) == tDLDSII[tmap[keyIndex].index[i]].RETUW_NT  &&
					atoi(pbd_InRecOwner[GT_PLC_NT]) == tDLDSII[tmap[keyIndex].index[i]].PLC_NT && 
					atoi(pbd_InRecOwner[GT_RTO_NF]) == tDLDSII[tmap[keyIndex].index[i]].RTO_NF &&		
					strncmp( pbd_InRecOwner[GT2_CUR_CF], tDLDSII[tmap[keyIndex].index[i]].CUR_CF, 3 )  == 0 && 
					strncmp(pbd_InRecOwner[GT2_NORME], tDLDSII[tmap[keyIndex].index[i]].NORME, strlen(pbd_InRecOwner[GT2_NORME])) == 0		 
					)
			{
				calcul (tmap[keyIndex].index[i], pbd_InRecOwner,d_Somme, n_NormeCur);
			}		
		}else{
			if (strcmp( pbd_InRecOwner[GT_RETCTR_NF], tDLDSII[tmap[keyIndex].index[i]].RETCTR_NF )  == 0   &&
		 			atoi(pbd_InRecOwner[GT_RETEND_NT]) == tDLDSII[tmap[keyIndex].index[i]].RETEND_NT && 
					atoi(pbd_InRecOwner[GT_RETSEC_NF]) == tDLDSII[tmap[keyIndex].index[i]].RETSEC_NF && 
					atoi(pbd_InRecOwner[GT_RTY_NF]) == tDLDSII[tmap[keyIndex].index[i]].RTY_NF && 
					atoi(pbd_InRecOwner[GT_RETUW_NT]) == tDLDSII[tmap[keyIndex].index[i]].RETUW_NT  &&
					atoi(pbd_InRecOwner[GT_PLC_NT]) == tDLDSII[tmap[keyIndex].index[i]].PLC_NT && 
					atoi(pbd_InRecOwner[GT_RTO_NF]) == tDLDSII[tmap[keyIndex].index[i]].RTO_NF &&					
					
					strcmp( pbd_InRecOwner[GT_CTR_NF], tDLDSII[tmap[keyIndex].index[i]].CTR_NF )  == 0 &&
					atoi(pbd_InRecOwner[GT_END_NT]) == tDLDSII[tmap[keyIndex].index[i]].END_NT && 
					atoi(pbd_InRecOwner[GT_SEC_NF]) == tDLDSII[tmap[keyIndex].index[i]].SEC_NF && 
					atoi(pbd_InRecOwner[GT_UWY_NF]) == tDLDSII[tmap[keyIndex].index[i]].UWY_NF && 
					atoi(pbd_InRecOwner[GT_UW_NT]) == tDLDSII[tmap[keyIndex].index[i]].UW_NT && 
					strncmp( pbd_InRecOwner[GT2_CUR_CF], tDLDSII[tmap[keyIndex].index[i]].CUR_CF, 3 )  == 0 &&
					strncmp( pbd_InRecOwner[GT2_RETCUR_CF], tDLDSII[tmap[keyIndex].index[i]].RETCUR_CF, 3 )  == 0 &&
					strncmp(pbd_InRecOwner[GT2_NORME], tDLDSII[tmap[keyIndex].index[i]].NORME, strlen(pbd_InRecOwner[GT2_NORME])) == 0			
 					
					)
			{
				calcul (tmap[keyIndex].index[i], pbd_InRecOwner,d_Somme, n_NormeCur);
			}		
			
		}
	}
	return OK;
	
}

	
void calcul (int i, char  **pbd_InRecOwner, double d_Somme ,int n_NormeCur){
	/*int j;
	for (j = 0; j < PATTERNSII_ANNEES; j++ )
	{
			d_Somme += tDLDSII[i].Amt[j];
	}*/
	
	d_Somme = tDLDSII[i].TOTAUX;
	//printf( "tDLDSII[i].ACMTRS_NT %d \n" , tDLDSII[i].ACMTRS_NT);
	if( tDLDSII[i].ACMTRS_NT == 301  || tDLDSII[i].ACMTRS_NT == 401 )
	{
		td_Total[n_NormeCur] = td_Total[n_NormeCur] + (d_Somme - tDLDSII[i].ACMAMT_M);
		//	printf( "td_Total[n_NormeCur] 1 %f \n" , td_Total[n_NormeCur]);
	}
	else if ( tDLDSII[i].ACMTRS_NT == 702  || tDLDSII[i].ACMTRS_NT == 902 )
	{
		td_Total[n_NormeCur] = td_Total[n_NormeCur] - (d_Somme - tDLDSII[i].ACMAMT_M);
     	//printf( "td_Total[n_NormeCur] 1 %f \n" , td_Total[n_NormeCur]);
	}

}



int n_InitDldSIIGTRNew(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitDldSIIGT" ) ;

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier maitre Perimetre de souscription */
  if (n_OpenFileAppl("ESTC1060A_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneDldSIIGTRNew;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

int n_ActionLigneDldSIIGTRNew		( char **ptb_InRecChild ){
	char* key = "" ;		
	if ( strcmp( ptb_InRecChild[GT2_PATCAT_CT], "DSC" )   != 0 ) {
 				return OK;
	}
				
	if (strcmp(ptb_InRecChild[GT2_ACMTRS_NT], "301") != 0){
		if (strcmp(ptb_InRecChild[GT2_ACMTRS_NT], "401") != 0){
			if (strcmp(ptb_InRecChild[GT2_ACMTRS_NT], "702") != 0){
				if (strcmp(ptb_InRecChild[GT2_ACMTRS_NT], "902") != 0){
					return OK;				
				}
			}			
		}
	}
	int found;
	if (countDldSII == 0){
		  int nbLigneCS = getFileNbLigne(Kp_InputDldSII);

		   tDLDSII = malloc( nbLigneCS * sizeof (T_DldSIIGT));
	
			tmap =  malloc( nbLigneCS * sizeof (T_DATAMAP));
	}
		

    tDLDSII[countDldSII].SSD_CF =  atoi(ptb_InRecChild[GT_SSD_CF]);
 	strcpy(tDLDSII[countDldSII].CTR_NF		,ptb_InRecChild[GT_CTR_NF]     );
	
	tDLDSII[countDldSII].END_NT =  atoi(ptb_InRecChild[GT_END_NT]);
	tDLDSII[countDldSII].SEC_NF =  atoi(ptb_InRecChild[GT_SEC_NF]);
	tDLDSII[countDldSII].UWY_NF =  atoi(ptb_InRecChild[GT_UWY_NF]);
	tDLDSII[countDldSII].UW_NT  =  atoi(ptb_InRecChild[GT_UW_NT]);
	strcpy(tDLDSII[countDldSII].CUR_CF		,ptb_InRecChild[GT_CUR_CF]	    );
	strcpy(tDLDSII[countDldSII].RETCTR_NF		,ptb_InRecChild[GT_RETCTR_NF]  );
	tDLDSII[countDldSII].RETEND_NT =  atoi(ptb_InRecChild[GT_RETEND_NT]);
	tDLDSII[countDldSII].RETSEC_NF =  atoi(ptb_InRecChild[GT_RETSEC_NF]);
	tDLDSII[countDldSII].RTY_NF =  atoi(ptb_InRecChild[GT_RTY_NF]);
	tDLDSII[countDldSII].RETUW_NT =  atoi(ptb_InRecChild[GT_RETUW_NT]);
	strcpy(tDLDSII[countDldSII].RETCUR_CF		,ptb_InRecChild[GT_RETCUR_CF]  );
	tDLDSII[countDldSII].RETAMT_M	=	atof(ptb_InRecChild[GT_RETAMT_M]);
	tDLDSII[countDldSII].PLC_NT =  atoi(ptb_InRecChild[GT_PLC_NT]);
	tDLDSII[countDldSII].RTO_NF =  atoi(ptb_InRecChild[GT_RTO_NF]);
	tDLDSII[countDldSII].ACMTRS_NT =  atoi(ptb_InRecChild[GT2_ACMTRS_NT]);
	tDLDSII[countDldSII].ACMAMT_M	=	atof(ptb_InRecChild[GT2_ACMAMT_M]);
	strcpy(tDLDSII[countDldSII].ACCRET		,ptb_InRecChild[GT2_ACCRET]    );
	strcpy(tDLDSII[countDldSII].NORME		,ptb_InRecChild[GT2_NORME]     );
	strcpy(tDLDSII[countDldSII].PATCAT_CT		,ptb_InRecChild[GT2_PATCAT_CT] );
	strcpy(tDLDSII[countDldSII].PATTYP_CT		,ptb_InRecChild[GT2_PATTYP_CT] );
	tDLDSII[countDldSII].TOTAUX	=	atof(ptb_InRecChild[GT2_TOTAUX]);
	/*int j;
	int n=0;
	for (j = GTSII_AM01_M; j < GTSII_AM01_M + PATTERNSII_ANNEES; j++ )
	{
		tDLDSII[countDldSII].Amt[n] = atof(ptb_InRecChild[j]);
		n++;
	}*/
	
	key = getKey(ptb_InRecChild);
	long hashkey =  GenerateHash(key, strlen(key));
	
	

	found=0;
	if (mapCounter > 0 ){	
			if (mapCounter > 1000){
				lastkeyIfd = mapCounter- 1000;
			}
			for (k = mapCounter; k >= lastkeyIfd;k--){
				//if (strcmp( ptb_InRecChild[GT_CTR_NF], "20T003334" )  == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2014){
				//					printf(">>>>>>> k = %d , key : %lu ,  value : %lu   \n",k,  tmap[k].key, hashkey);
				//}
					if (hashkey == tmap[k].key ){
						tmap[k].index[tmap[k].count] = countDldSII;
						tmap[k].count= tmap[k].count+1;
						found = 1;
 						break;					
					}
			}
			if(found == 0){						
				//strcpy(tmap[mapCounter].key, key);
				tmap[mapCounter].key = hashkey;
				tmap[mapCounter].index[0]=countDldSII;
				tmap[mapCounter].count= 1;	
				mapCounter++;
							//if (strcmp( ptb_InRecChild[GT_CTR_NF], "20T003334" )  == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2014){
							//		printf("key : %s ,  value : %lu   \n", key, hashkey);

							//		printf("B = count = %d, keyIndex  : %d , index = %d  , i = %d , norm= %s \n",tmap[mapCounter-1].count, mapCounter, tmap[mapCounter-1].index[0], 
							//					tmap[mapCounter-1].count-1, tDLDSII[tmap[mapCounter-1].index[0]].NORME );
							//}	

			}
						 
	}else{
			tmap[mapCounter].key = hashkey;
			tmap[mapCounter].index[0]=countDldSII;
			tmap[mapCounter].count= 1;
			mapCounter++;
						//if (strcmp( ptb_InRecChild[GT_CTR_NF], "20T003334" )  == 0 && atoi(ptb_InRecChild[GT_UWY_NF]) == 2014){
							//	printf("key : %s ,  value : %lu   \n", key, hashkey);

						//		printf("C = count = %d, keyIndex  : %d , index = %d  , i = %d , norm= %s \n",tmap[mapCounter-1].count, mapCounter, tmap[mapCounter-1].index[0], 
						//					tmap[mapCounter-1].count-1, tDLDSII[tmap[mapCounter-1].index[0]].NORME );
						//	}	
	}
 

 
   countDldSII++;
 
   return OK;

}


char* getKey(char **row){
	char* keyreturn = NULL;
	char strkey[240];

	if ( !b_IsBlankOrEmpty(row[GT_CTR_NF]) && !b_IsBlankOrEmpty(row[GT_RETCTR_NF]) ){
		sprintf(strkey,"%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
		row[GT_CTR_NF], row[GT_END_NT], row[GT_SEC_NF], row[GT_UWY_NF], row[GT_UW_NT],row[GT_CUR_CF],
		row[GT_RETCTR_NF], row[GT_RETEND_NT], row[GT_RETSEC_NF], row[GT_RTY_NF], row[GT_RETUW_NT], 
		row[GT_PLC_NT], row[GT_RTO_NF],row[GT_RETCUR_CF],row[GT2_NORME]	);
	}else{

		if (b_IsBlankOrEmpty(row[GT_RETCTR_NF])){
			sprintf(strkey,"%s%s%s%s%s%s%s",
			row[GT_CTR_NF], row[GT_END_NT], row[GT_SEC_NF], row[GT_UWY_NF], row[GT_UW_NT],row[GT_CUR_CF],row[GT2_NORME]);
		}
		if (b_IsBlankOrEmpty(row[GT_CTR_NF])){
			sprintf(strkey,"%s%s%s%s%s%s%s%s%s%s",
			row[GT_RETCTR_NF], row[GT_RETEND_NT], row[GT_RETSEC_NF], row[GT_RTY_NF], row[GT_RETUW_NT], 
			row[GT_PLC_NT], row[GT_RTO_NF], row[GT_RETCUR_CF] , row[GT_CUR_CF],row[GT2_NORME]);
		}
	}
	
	keyreturn =strkey;
	/*if (strcmp( row[GT_CTR_NF], "20T003334" )  == 0 && atoi(row[GT_UWY_NF]) == 2014){
		printf(" returnKEY =  %s , key = %s \n", keyreturn, strkey); 
	}*/
	return keyreturn;
}

unsigned long GenerateHash(char* str, unsigned int len)
{
   unsigned int result = 0;
   unsigned int b    = 378551;
   unsigned int a    = 63689;
   unsigned int i    = 0;

   for(i=0; i<len; str++, i++)
   {
      result = result*a + (*str);
      a = a*b;
   }

   return result;
}

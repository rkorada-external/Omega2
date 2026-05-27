/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3003.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur              : -=Dch=-
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
 Historique des modifications :
________________
[01]  01/06/2012   -=Dch=-  :spot:23937 SOLVENCY II
[02]  01/06/2012   -=Dch=-  :spot:24041 SOLVENCY II control du PatternID
[03]  18/01/2013   -=Dch=-  :spot:24698 SOLVENCY II Correction du controle de LOB_CF/SEGNAT_CT/NORME_CF avant sortie fichier
[04]  15/07/2015 Florent   :spot:28941 correction warnings
[05]  30/05/2016 Florent   :spot:30543 on passe à 65 années
[06]  07/01/2020 Charles Socie  SPIRA: 80581  REQ3.3.1- Missing step in discount ILL pattern upload
[07]  02/11/2020 KBagwe	: Spira: 89097- REQ 53.3 - Impact on discount pattern load
[08]  07/01/2020 Charles Socie  SPIRA: 97223 delete LOB file
==============================================================================*/
/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "ESTC3001.h"

FILE *Kp_OutputPATERNSII;
FILE *Kp_InputCOEF_R;
FILE *Kp_InputPATERNSII;
FILE *Kp_OutputPATSEGSII;

/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
long getFileNbLigne(FILE *);
void ChargementDataPatternID();
double CalculTaux(double, int);
void split(char* sz_enr, const char* separateur, char** tp_enr);
long GetPatternID(const int id);
long GetNextPatternID(const char* , const char*,  const int );
void EcrireFichier();
size_t GetCountNature(const int id);


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/
T_FPATTERNSII_JOIN_ESB* kpbd_FPATTERNSII; //[07]
char Ksz_ReadBuffer[MAX_LINESIZE + 4];

// variable pour les tailles de tableaux alloués dynamiquement
long Kl_sizeFLOGSII, Kl_sizeFPATTERNSII;
char Ksz_CurrILLPatternID[22];

char Ksz_CRE_D[22] ;      // Passé en paramètre
char Ksz_USER_CF[5] ;
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
  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Récupération des 1 paramètre
  memset(Ksz_CRE_D, 0, sizeof(Ksz_CRE_D));
  strcpy(Ksz_CRE_D, psz_GetCharArgv(1));

  memset(Ksz_USER_CF, 0, sizeof(Ksz_USER_CF));
  strcpy(Ksz_USER_CF, psz_GetCharArgv(2));

  Kl_sizeFPATTERNSII = 0;

  // Ouverture des fichiers binaires et des fichiers de sortie

  if (n_OpenFileAppl("ESTC3003_O1", "wt", &Kp_OutputPATERNSII) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'output." );
  if (n_OpenFileAppl("ESTC3003_O2", "wt", &Kp_OutputPATSEGSII) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'output(TRACESEG)." );

  if (n_OpenFileAppl("ESTC3003_I1", "rt", &Kp_InputPATERNSII) == ERR ) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier d'input I3." );


  // Initialisation des fichiers de données en entrée
  ChargementDataPatternID();
  EcrireFichier();

  //Libération des pointeurs de structure.
  free(kpbd_FPATTERNSII);

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC3003_O1", &Kp_OutputPATERNSII)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'output.");
  if (n_CloseFileAppl("ESTC3003_O2", &Kp_OutputPATSEGSII )) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'output(TRACESEG).");

  if (n_CloseFileAppl("ESTC3003_I1", &(Kp_InputPATERNSII ))) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  exit(OK);
}

/* ------------------------------------------------------------------------------------------------ */
/* Fonction    : double CalculTaux(double discount, double liquid, int annee) */
/* Description : Recalcul le taux                                                                   */
/* ------------------------------------------------------------------------------------------------ */
double CalculTaux (double discount, int annee)
{
  return pow((1.0 / (1.0 + discount)), annee - 0.5);
}

/* -----------------------------------------------------------------------*/
/*   Fonction    : void ChargementDataPatternID()                         */
/*  Description : Chargement des patternID par DATA                       */
/* -----------------------------------------------------------------------*/
void ChargementDataPatternID()
{
  char* psz_enr;
  char *tp_FPATTERNSII[PAT_NBCOL+1];	 //[07]
  int idx = 0; // index du tableau de structure
  int j = 0;

  Kl_sizeFPATTERNSII = getFileNbLigne(Kp_InputPATERNSII) ;
  if (Kl_sizeFPATTERNSII < 1 ) ExitPgm(ERR_XX, "Erreur de chargement de FPATTERNSII");

  kpbd_FPATTERNSII = calloc(Kl_sizeFPATTERNSII, sizeof(T_FPATTERNSII_JOIN_ESB));
  if ( ! kpbd_FPATTERNSII )  ExitPgm(ERR_XX, "Erreur d'allocation de FPATTERNSII");

  memset(Ksz_ReadBuffer, 0, sizeof(Ksz_ReadBuffer));
  memset(tp_FPATTERNSII, 0, sizeof(tp_FPATTERNSII));
  while ( fgets(Ksz_ReadBuffer, sizeof(Ksz_ReadBuffer), Kp_InputPATERNSII) != NULL )
  {
    if ( strstr(Ksz_ReadBuffer, "~DSC~DSC~") != NULL )
    {
      //suppression du retour chariot
      Ksz_ReadBuffer[strcspn(Ksz_ReadBuffer, "\n")] = '\0';
      psz_enr = Ksz_ReadBuffer;
      //initialisation uniquement des colonnes dont on a besoin
      split(psz_enr, SEPARATEUR_SPLIT, tp_FPATTERNSII);
      strcpy(kpbd_FPATTERNSII[idx].db_pat.PATTYP_CT, tp_FPATTERNSII[PAT_PATTYP_CT]);	 //[07]
      strcpy(kpbd_FPATTERNSII[idx].db_pat.CUR_CF, tp_FPATTERNSII[PAT_CUR_CF]);			 //[07]
      strcpy(kpbd_FPATTERNSII[idx].db_pat.NORME_CF, tp_FPATTERNSII[PAT_NORME_CF]);		 //[07]
      strcpy(kpbd_FPATTERNSII[idx].db_pat.PATTERN_ID, tp_FPATTERNSII[PAT_PATTERN_ID]);	 //[07]
      strcpy(kpbd_FPATTERNSII[idx].db_pat.CRE_D, tp_FPATTERNSII[PAT_CRE_D]);			 //[07]
      strcpy(kpbd_FPATTERNSII[idx].ESB_CF, tp_FPATTERNSII[PAT_ESB_CF]);					 //[07]
      for (j = 0 ; j < PATTERNSII_ANNEES ; j++)
      {
        kpbd_FPATTERNSII[idx].db_pat.AN[j] = atof(tp_FPATTERNSII[PAT_AN1 + j]);			 //[07]
      }
      idx++;
    }
  }
  Kl_sizeFPATTERNSII = idx;

  rewind(Kp_InputPATERNSII); // on se remet au début
}

/* ------------------------------------------------------------------------------------*/
/* Retour tableau des chaines recupérer. Terminé par NULL.                             */
/* Le dernier pointeur est toujours NULL et donc indique la fin du tableau             */
/* on assume que tp_enr a été alloué avec le nombre de colonnes + 1                    */
/*               sz_enr va être modifié pour mettre 0 binaire à la place du séparateur */
/* ------------------------------------------------------------------------------------*/
void split(char* sz_enr, const char* separateur, char** tp_enr)
{
  int i = 0;
  while ((tp_enr[i] = strsep(&sz_enr, separateur)))  i++;
}


/* -----------------------------------------------------------------------*/
/*   Fonction    : int getFileNbLigne(FILE *fl)                            */
/*  Description : Renvoi le nombre de ligne dans un fichier                */
/*  ATTENTION   : Remet la position au début du  fichier                  */
/* -----------------------------------------------------------------------*/
long getFileNbLigne(FILE * fl)
{
  long nbligne = 1;
  rewind(fl); // on se remet au début
  while ( fgets(Ksz_ReadBuffer, sizeof(Ksz_ReadBuffer), fl) != NULL)
    nbligne++;
  rewind(fl);
  return (nbligne - 1);
}

void EcrireFichier()
{
  char sz_annees[PATTERNSII_ANNEES][TAILLE_PATTERNSII_TAUX];
  char* psz_enr;
  char *tp_FPATTERNSII[PAT_NBCOL + 2]; //dernier pointeur NULL pour la limite
  int currLobByNorme = -1;
  int compteurLob = 0;
  int i_an = 0;
  char sz_RATING_CF[6];
  char *psz_CRE_D;
  double d_anneesIN[PATTERNSII_ANNEES];

  memset(Ksz_ReadBuffer, 0, sizeof(Ksz_ReadBuffer));
  memset(tp_FPATTERNSII, 0, sizeof(tp_FPATTERNSII));
  while (fgets(Ksz_ReadBuffer, sizeof(Ksz_ReadBuffer), Kp_InputPATERNSII) != NULL)
  {
	  
    //suppression du retour chariot
    Ksz_ReadBuffer[strcspn(Ksz_ReadBuffer, "\n")] = '\0';
    psz_enr = Ksz_ReadBuffer;
    split(psz_enr, SEPARATEUR_SPLIT, tp_FPATTERNSII);
    memset(sz_annees, 0, sizeof(sz_annees));
  
    if( strncmp(tp_FPATTERNSII[PAT_PATTYP_CT],"DSC",3) == 0){ //[06]
		//sauvegarde de la valeur de CRE_D de l'enregistrement
		psz_CRE_D = tp_FPATTERNSII[PAT_CRE_D];
		//Maj du tableau de pointeur pour la sortie de PATTERNS DSI
		tp_FPATTERNSII[PAT_PATTYP_CT] = PATTYP_DISCILLIQ;
		tp_FPATTERNSII[PAT_RATING_CF] = sz_RATING_CF;
		tp_FPATTERNSII[PAT_CREUSR_CF] = Ksz_USER_CF;

		//on modifie l'enregistrement pour le faire pointer sur les données à écrire
		for (i_an = 0 ; i_an < PATTERNSII_ANNEES; i_an++)
		{
		  //sauvegardes des taux en entrée
		  d_anneesIN[i_an] = atof(tp_FPATTERNSII[PAT_AN1 + i_an]);
		  //et on change pour le mettre sur les valeurs calculées dans cette fonction
		  tp_FPATTERNSII[PAT_AN1 + i_an] = sz_annees[i_an];
		}

		  for (i_an = 0; i_an < PATTERNSII_ANNEES ; i_an++)
		  {
			snprintf(sz_annees[i_an], TAILLE_PATTERNSII_TAUX, "%.8f", CalculTaux(d_anneesIN[i_an], i_an + 1));
		  }
		  tp_FPATTERNSII[PAT_CRE_D] = Ksz_CRE_D;
		  n_WriteCols(Kp_OutputPATERNSII, tp_FPATTERNSII, SEPARATEUR, 0);

		  tp_FPATTERNSII[PAT_CRE_D] = psz_CRE_D;

		  fprintf(Kp_OutputPATSEGSII, "%s~%s~%s~~%s~%s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
				  Ksz_CRE_D, //clodat
				  PER_CF_NEW,
				  tp_FPATTERNSII[PAT_SSD_CF],
				  tp_FPATTERNSII[PAT_LOB_CF],
				  tp_FPATTERNSII[PAT_CUR_CF],
				  tp_FPATTERNSII[PAT_NORME_CF],
				  PATCAT_DISCOUNT,
				  PATTYP_DISCILLIQ,
				  tp_FPATTERNSII[PAT_PATTERN_ID],
				  PATCAT_DISCOUNT, PATTYP_DISCOUNT, tp_FPATTERNSII[PAT_PATTERN_ID],
				  Ksz_USER_CF,
				  Ksz_CRE_D,
				  tp_FPATTERNSII[PAT_ESB_CF] );				 //[07]
		  if (currLobByNorme == compteurLob )
		  {
			currLobByNorme = -1;
		  }
		
	}
    else if( strncmp(tp_FPATTERNSII[PAT_PATTYP_CT],"ILL",3) == 0){  //[06]
	   n_WriteCols(Kp_OutputPATERNSII, tp_FPATTERNSII, SEPARATEUR, 0);
    }
  } 
}

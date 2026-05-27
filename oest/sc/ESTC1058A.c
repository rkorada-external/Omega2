/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1058.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
      Historique des modifications :
[02] 01/06/2012 -=Dch=-  :spot:23937 SOLVENCY II
[03] 01/01/2013 -=Dch=-  :spot:24041 SOLVENCY II
[04] 20/02/2013 =PEZOUT=-:spot:24875 SOLVENCY II
[05] 13/05/2016 Florent  :spot:30543 on passe à 65 années
[06] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
[07] 14/10/2019 Chalres Socie : SPIRA 77191 : IFRS17 Bad debt management : discount at lock in rate (REQ11.4)
[08] 19/06/2020 Chalres Socie : SPIRA 87700 : IFRS17 Bad debt management : Change sign in AN sum
[09] 26/08/2020 HR : SPIRA 82685 : struct.h
[10] 07/09/2020 Chalres Socie : SPIRA 89751 : INI - Bad Debt Curve KO
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include <struct.h>
#include "ESTC3001A.h"
#include "ESTC1058.h"

/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC1058A_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputRemainToPay;
FILE *Kp_InputRating;
FILE *Kp_InputPattern;
FILE *Kp_OutputBatch;

// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF et LOB_CF
T_FPATTERNSII_JOIN * pBaddbt;
T_RATING  * pRating;

char * Trim(char *s);
//void     ExtractLineCSWithNoSync();      // sortie des pattern cash flow non utilisée
/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
int nb_Rating = 0; // pour stocker le nombre de RATING_CF chargée dynamiquement
int nb_Pattern = 0;
int nb_Remain = 0;
int compteur = 0;

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
  InitSig ();

  // input parmetre

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1058A_O1", "wt", &Kp_OutputBatch)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );

  // Ouverture du fichier de cash flow ( pattern incrementales )
  if (n_OpenFileAppl("ESTC1058A_I2", "rt", &Kp_InputPattern) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de pattern." );
  if (n_OpenFileAppl("ESTC1058A_I3", "rt", &Kp_InputRating) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de RATING_CF." );

  //Chargement des ratings dans un tableau
  ChargementRating();
  //chargement des baddebt dans un tableau
  ChargementPattern();

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );


  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1058A_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC1058A_I2", &Kp_InputPattern))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Pattern.");
  if (n_CloseFileAppl("ESTC1058A_I3", &Kp_InputRating))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Devise (CUR_CF).");
  if (n_CloseFileAppl("ESTC1058A_O1", &Kp_OutputBatch))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  // libération mémoire
  free(pRating);
  exit(OK);
}

void ChargementRating()
{
  // on va déterminer le nombre de ligne , et donc le nombre de RATING_CF à charger
  nb_Rating  = getFileNbLigne(Kp_InputRating);
  char buffer[LONGBUF];
  char **tab = NULL;
  size_t compteur = 0;


  // en cas d'erreur on sort en affichant un message
  if (nb_Rating > 0 )
  {
    //on retaille le tableau de RATING_CF
    pRating = malloc( nb_Rating * sizeof (T_RATING));
    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputRating) != NULL)
    { // tab contient maintenant les données de la ligne en cours :
      // ex. tab[0] = retrocessionnaire , tab[1] = RATING_CF
      buffer[strlen(buffer) - 1] = 0; // suppression du retour chariot

      tab = split(buffer, SEPARATEUR_SPLIT , 1);

      strcpy(pRating[compteur].retroc, Trim(tab[0]));
      strcpy(pRating[compteur].RATING_CF, Trim(tab[1]));

      compteur++;
      freeTableau(tab);
    }
  }

}

char * Trim(char *s)
{
  char *ptr;
  if (!s)
    return (char*) NULL;   // handle  pour les chaines NULL
  if (!*s)
    return s;      // handle pour les chaine à 0

  for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
  ptr[1] = '\0';
  return s;
}

/* -----------------------------------------------------------------------*/
/*   Fonction    : int getFileNbLigne(FILE *fl)                */
/*  Description : Renvoi le nombre de ligne dans un fichier              */
/*  ATTENTION   : Remet la position au début du  fichier            */
/* -----------------------------------------------------------------------*/
long getFileNbLigne(FILE * fl)
{
  long nbligne = 1;
  char lg[LONGBUF];
  rewind(fl); // on se remet au début
  while ( fgets(lg, LONGBUF, fl) != NULL)  nbligne++;
  rewind(fl);
  return (nbligne - 1);
}

// procedure de vidage du tableau
void freeTableau(char** tab)
{
  int i = 0; /* Added for Phase1b Migration */
  for (i = 0; tab[i] != NULL; i++) /* Updated for Phase1b Migration */
  {
    free(tab[i]);
  }
}

/* ----------------------------------------------------------------------------*/
/* Retour tableau des chaines recupérer. Terminé par NULL.              */
/* chaine : chaine à splitter                              */
/* delim : delimiteur qui sert à la decoupe                    */
/* vide : 0 : on n'accepte pas les chaines vides                  */
/*        1 : on accepte les chaines vides                      */
/* ----------------------------------------------------------------------------*/
char** split(char* chaine, const char* delim, int vide)
{

  char** Tableau = NULL;          //tableau de chaine, tableau resultat
  char *ptr;                     //pointeur sur une partie de
  int sizeStr;                   //taille de la chaine à recupérer
  int sizeTab = 0;               //taille du tableau de chaine
  char* largestring;             //chaine à traiter

  int sizeDelim = strlen(delim); //taille du delimiteur
  largestring = chaine;          //comme ca on ne modifie pas le pointeur d'origine


  while ( (ptr = strstr(largestring, delim)) != NULL )
  {
    sizeStr = ptr - largestring;

    //si la chaine trouvé n'est pas vide ou si on accepte les chaine vide
    if (vide == 1 || sizeStr != 0)
    {
      //on alloue une case en plus au tableau de chaines
      sizeTab++;
      Tableau = (char**) realloc(Tableau, sizeof(char*)*sizeTab);

      //on alloue la chaine du tableau
      Tableau[sizeTab - 1] = (char*) malloc( sizeof(char) * (sizeStr + 1) );
      strncpy(Tableau[sizeTab - 1], largestring, sizeStr);
      Tableau[sizeTab - 1][sizeStr] = '\0';
    }

    //on decale le pointeur largestring  pour continuer la boucle apres le premier elément traiter
    ptr = ptr + sizeDelim;
    largestring = ptr;
  }

  //si la chaine n'est pas vide, on recupere le dernier "morceau"
  if (strlen(largestring) != 0)
  {
    sizeStr = strlen(largestring);
    sizeTab++;
    Tableau = (char**) realloc(Tableau, sizeof(char*)*sizeTab);
    Tableau[sizeTab - 1] = (char*) malloc( sizeof(char) * (sizeStr + 1) );
    strncpy(Tableau[sizeTab - 1], largestring, sizeStr);
    Tableau[sizeTab - 1][sizeStr] = '\0';
  }
  else if (vide == 1)
  { //si on fini sur un delimiteur et si on accepte les mots vides,on ajoute un mot vide
    sizeTab++;
    Tableau = (char**) realloc(Tableau, sizeof(char*)*sizeTab);
    Tableau[sizeTab - 1] = (char*) malloc( sizeof(char) * 1 );
    Tableau[sizeTab - 1][0] = '\0';

  }

  //on ajoute une case à null pour finir le tableau
  sizeTab++;
  Tableau = (char**) realloc(Tableau, sizeof(char*)*sizeTab);
  Tableau[sizeTab - 1] = NULL;

  return Tableau;
}

/*==============================================================================
 Objet :            Chargement des données provenant du fichier de cash flow dans les structures qui vont bien
 Parametre(s) :     pCS est la structure sur laquelle faire le chargement
           tab est un pointeur de pointeur de tableau de la ligne en cours de lecture.
          Les champs ont déjà été splitté avec le séparateur qui va bien

 Retour :           pointeur sur la nouvelle structure
==============================================================================*/
void  addPattern(  char **tab, int idx)
{
    int taille;
    int j = 0; /* Added for Phase1b Migration */
    // on ajoute l'enregistrement en cours
	if (strncmp(tab[PAT_NORME_CF],"ALLNO",5) == 0){
	  strcpy(pBaddbt[idx].db_pat.SSD_CF, tab[PAT_SSD_CF]);
	  strcpy(pBaddbt[idx].db_pat.PATCAT_CT, tab[PAT_PATCAT_CT]);
	  strcpy(pBaddbt[idx].db_pat.PATTYP_CT , tab[PAT_PATTYP_CT]);
	  strcpy(pBaddbt[idx].db_pat.SEG_NF , tab[PAT_SEG_NF]);
	  pBaddbt[idx].db_pat.UWY_NF = atoi(tab[PAT_UWY_NF]);
	  strcpy(pBaddbt[idx].db_pat.CUR_CF, tab[PAT_CUR_CF]);
	  strcpy(pBaddbt[idx].db_pat.LOB_CF , tab[PAT_LOB_CF]);
	  strcpy(pBaddbt[idx].db_pat.RATING_CF, tab[PAT_RATING_CF]);
	  strcpy(pBaddbt[idx].db_pat.NORME_CF , tab[PAT_NORME_CF]);
	  pBaddbt[idx].db_pat.BALSHEY_NF = atoi(tab[PAT_BALSHEY_NF]);
	  strcpy(pBaddbt[idx].db_pat.PATTERN_ID, tab[PAT_PATTERN_ID]);
	  strcpy(pBaddbt[idx].db_pat.CRE_D, tab[PAT_CRE_D]);
	  strcpy(pBaddbt[idx].db_pat.CREUSR_CF , tab[PAT_CREUSR_CF]);
	  // TOTAUX ignoré
	  //

	  // on va supprimer le retour chariot si il y en a un
	  taille = strlen(tab[PAT_AN_FIN + 1]);
	  if (tab[PAT_AN_FIN + 1][taille - 1] == '\n')
	  {
		strncpy(pBaddbt[idx].jointure , tab[PAT_AN_FIN + 1], taille - 1);
	  }
	  else
		strcpy(pBaddbt[idx].jointure , tab[PAT_AN_FIN + 1]);

	  // on charge les PATTERNSII_ANNEES années
	  for (j = 0; j < PATTERNSII_ANNEES; j++) /* Updated for Phase1b Migration */
	  {
		pBaddbt[idx].db_pat.AN[j] = atof(tab[PAT_AN1 + j]);
	  }
	  //pBaddbt[idx].used = 0;   // pour vérifier l'utilisation lors du print final
	}
}
/*==============================================================================
 Objet :            Chargement des données provenant du fichier de Discount
 Parametre(s) :     aucun
 Retour :           aucun
==============================================================================*/

void ChargementPattern()
{

  char buffer[LONGBUF];
  int sizep = 0;
  nb_Pattern = getFileNbLigne(Kp_InputPattern);

  char **tab = NULL;
  if (nb_Pattern > 0)
  {
    // on retaille le pointeur sur le tableau de pattern
    pBaddbt = (T_FPATTERNSII_JOIN*) realloc(pBaddbt, nb_Pattern *  sizeof(T_FPATTERNSII_JOIN));

    while (fgets( buffer, LONGBUF, Kp_InputPattern) != NULL)
    {
      tab = split(buffer, SEPARATEUR_SPLIT , 1);
      addPattern(tab, sizep);
      sizep++;
      freeTableau(tab);
    }
  }
}


/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchIN(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC1058A_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchIN(char **ptb_InRec_Cur)
{
  char   buf[LONGBUF];          // pour le buffer de sortie ESCOMPTE
  double total, calcul;            // taux en cours du Bad Debt
  int    idRating = -1;
  int    idPattern = -1;
  char   Curr_rating[4];
  char   Curr_pattern[18];
  char   comment_CF[250];
  int i;
  int x = 0;   /* Added for Phase1b Migration */
  int col = 0; /* Added for Phase1b Migration */
  int idx = 0; /* Added for Phase1b Migration */

  DEBUT_FCT("n_ActionLigneRfrBatchIN");
  //ptb_InRec_Cur contient la ligne courante
  // on va comparer le contenu de la colonne ptb_InRec_Cur[RBD_RTO_NF], [RBD_NORME] et [RBD_SEG_NF]
  //avec le contenu des colonnes des patterns et RATING_CF
  memset(buf, 0, sizeof(buf));
  memset(Curr_rating, 0, sizeof(Curr_rating));
  memset(Curr_pattern, 0, sizeof(Curr_pattern));
  memset(comment_CF, 0, sizeof(comment_CF));

  // on va chercher le RATING_CF du retrocessionnaire , à condition que l'on ait un retrocessionaire sur la ligne courante

  if (strlen(Trim(ptb_InRec_Cur[RBD_RTO_NF])) > 0)
  {
    for (x = 0; x < nb_Rating; x++) /* Updated for Phase1b Migration */
    {
      if (strncmp(ptb_InRec_Cur[RBD_RTO_NF], pRating[x].retroc, strlen(pRating[x].retroc)) == 0)
      {
        idRating = x;
        strcpy(Curr_rating, pRating[x].RATING_CF);
        break;
      }
    }
  }

    // si on a une erreur dans le RATING_CF ou la NORME_CF
  if (idRating == -1)
  {
    strcpy(comment_CF, "RATING_CF non trouve");
		if( strcmp(Curr_rating,"") == 0){
			sprintf(Curr_rating, "%s", "NR");
		}
  }
  
  // on va chercher maintenant la pattern
  for (x = 0; x < nb_Pattern; x++) /* Updated for Phase1b Migration */
  {
    if ( strncmp(pBaddbt[x].db_pat.RATING_CF, Curr_rating , strlen(Curr_rating)) == 0 && strlen(Curr_rating) != 0 && strlen(Curr_rating) == strlen(pBaddbt[x].db_pat.RATING_CF))  //[10]
    {
        idPattern = x;
		strcpy(Curr_pattern, pBaddbt[x].db_pat.PATTERN_ID);
        break;
    }
  }


  if (idPattern == -1)
  {
    strcat (comment_CF, "Pattern non trouvee");
	strcpy(ptb_InRec_Cur[RBD_PAT_NF],"ERR");
  }


  // on va préparer toutes les colonnes avant les PATTERNSII_ANNEES années
  // on commence par mettre la 1ere colonne dans le buffer
  sprintf(buf, "%s", ptb_InRec_Cur[RBD_SSD_CF]);

  //puis tout le reste des colonnes qui précèdent les montants annuels
  for (col = 1; col <= RBD_RATING; col++) /* Updated for Phase1b Migration */
  {
    if (col == RBD_ACMTRS_NT)
    {
      sprintf(buf, "%s~%d", buf, atoi(ptb_InRec_Cur[col]));
    }
    else if (col == RBD_RATING)
      sprintf(buf, "%s~%s", buf, Curr_rating);
	else if (col == RBD_NORME)
	  sprintf(buf, "%s~%s", buf, "ALLNO");
    else
      sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);

  }

  // on ne fait le calcul que si il n'y a pas d'erreur
  calcul = 0;
  total = 0;

  if (idPattern == -1)
  {
	sprintf(buf , "%s~BDT~RMNTP~ERR", buf); //[07]
    for (idx = 0; idx < PATTERNSII_ANNEES; idx++) /* Updated for Phase1b Migration */
    {
      sprintf(buf, "%s~%.3f", buf, calcul);
    }
  }
  else
  {
	sprintf(buf , "%s~BDT~RMNTP~%s", buf, Curr_pattern); //[07]
    for (idx = 0; idx < PATTERNSII_ANNEES; idx++) /* Updated for Phase1b Migration */
    {
		calcul = 0;
		for(i = idx ; i < PATTERNSII_ANNEES ; i++){
			calcul += atof(ptb_InRec_Cur[RBD_AN1+i]);
		}
		calcul = (-1 * calcul) * pBaddbt[idPattern].db_pat.AN[idx]; //[08]
		if (calcul > 99999999999999.99)
			calcul = 99999999999999.99;
		total += calcul;
		sprintf(buf, "%s~%.3f", buf, calcul);
		}
	}

  if (total > 99999999999999.99)
    total = 99999999999999.99;

  // Ecriture de la ligne courante
	//[06] add ACMTRS3 at the end of te file 
  fprintf(Kp_OutputBatch, "%s~~%s~%s~%.3f~%s\n", buf, Curr_rating, comment_CF, total, ptb_InRec_Cur[RBD_ACMTRS3_NT] );

  return OK;
 }




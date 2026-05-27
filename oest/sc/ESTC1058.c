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
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC3001.h"
#include "ESTC1058.h"

/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC1058_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputRemainToPay;
FILE *Kp_InputRating;
FILE *Kp_InputPattern;
FILE *Kp_OutputBatch;
FILE *Kp_OutputStats;
FILE *Kp_OutputErr;

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

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  // ${PRG}_I1=${DTMP}/${PRG}_GTSII.dat
  // ${PRG}_I2=${DTMP}/${PRG}_pattern.dat
  // ${PRG}_I3=${DTMP}/${PRG}_rating.dat

  if (n_OpenFileAppl("ESTC1058_O1", "wt", &Kp_OutputBatch)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
  if (n_OpenFileAppl("ESTC1058_O2", "wt", &Kp_OutputStats)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
  if (n_OpenFileAppl("ESTC1058_O3", "wt", &Kp_OutputErr)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );

  // Ouverture du fichier de cash flow ( pattern incrementales )
//  if (n_OpenFileAppl("ESTC1058_I1", "rt", &Kp_InputRemainToPay) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de remaintopay." );
  if (n_OpenFileAppl("ESTC1058_I2", "rt", &Kp_InputPattern) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de pattern." );
  if (n_OpenFileAppl("ESTC1058_I3", "rt", &Kp_InputRating) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de RATING_CF." );

  //Chargement des ratings dans un tableau
  ChargementRating();
  //chargement des baddebt dans un tableau
  ChargementPattern();

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  // Impression des lignes du pattern cash flow non utilisées
  //  ExtractLineCSWithNoSync();
  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1058_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC1058_I2", &Kp_InputPattern))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Pattern.");
  if (n_CloseFileAppl("ESTC1058_I3", &Kp_InputRating))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Devise (CUR_CF).");
  if (n_CloseFileAppl("ESTC1058_O1", &Kp_OutputBatch))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");
  if (n_CloseFileAppl("ESTC1058_O2", &Kp_OutputStats))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier PIVOT.");
  if (n_CloseFileAppl("ESTC1058_O3", &Kp_OutputErr))            ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier erreur.");

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
  //if(nb_Rating <1) ExitPgm(ERR_XX, "Mauvais chargement du fichier de RATING_CF");
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
  //if(nb_Pattern <1) ExitPgm(ERR_XX, "Erreur de chargement du fichier des courbes de cash flow");
  if (nb_Pattern > 0)
  {
    // on retaille le pointeur sur le tableau de pattern
    pBaddbt = (T_FPATTERNSII_JOIN*) realloc(pBaddbt, nb_Pattern *  sizeof(T_FPATTERNSII_JOIN));

    while (fgets( buffer, LONGBUF, Kp_InputPattern) != NULL)
    {
      tab = split(buffer, SEPARATEUR_SPLIT , 1);
      addPattern(tab, sizep);
      sizep++;
      // on récupère la colonne qui sert à la jointure
      //strcpy(pCS_LOB[sizeCS_LOB-1].joint_lob, tab[PAT_AN_FIN+2]);

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

  if (n_OpenFileAppl("ESTC1058_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
  char   bufStat[LONGBUF];        // pour le buffer de sortie PIVOT
  double total, calcul;            // taux en cours du Bad Debt
  int    idRating = -1;
  int    idPattern = -1;
  char   Curr_Norme[21];
  char   Curr_rating[4];
  char   comment_CF[250];
  int x = 0;   /* Added for Phase1b Migration */
  int col = 0; /* Added for Phase1b Migration */
  int idx = 0; /* Added for Phase1b Migration */

  DEBUT_FCT("n_ActionLigneRfrBatchIN");
  //ptb_InRec_Cur contient la ligne courante
  // on va comparer le contenu de la colonne ptb_InRec_Cur[RBD_RTO_NF], [RBD_NORME] et [RBD_SEG_NF]
  //avec le contenu des colonnes des patterns et RATING_CF
  memset(buf, 0, sizeof(buf));
  memset(bufStat, 0, sizeof(bufStat));

  memset(Curr_Norme, 0, sizeof(Curr_Norme));
  memset(Curr_rating, 0, sizeof(Curr_rating));
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
  if (idRating == -1)
    strcpy(Curr_rating, "NR");  // si pas de retro , on prendra le RATING_CF NR dans le fichier baddebt


  // on va chercher maintenant la pattern
  for (x = 0; x < nb_Pattern; x++) /* Updated for Phase1b Migration */
  {
    if (strncmp(ptb_InRec_Cur[RBD_NORME], pBaddbt[x].db_pat.NORME_CF, strlen(pBaddbt[x].db_pat.NORME_CF)) == 0)
    {
      if (strncmp(pBaddbt[x].db_pat.RATING_CF, Curr_rating , strlen(Curr_rating)) == 0)
      {
        idPattern = x;
        strcpy(Curr_Norme, pBaddbt[x].db_pat.NORME_CF);
        break;
      }
    }
  }


  // si on a une erreur dans le RATING_CF ou la NORME_CF
  if (idRating == -1)
  {
    strcpy(comment_CF, "RATING_CF non trouve");
  }
  if (idPattern == -1)
  {
    strcat (comment_CF, "Pattern non trouvee");
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
    else if (col == RBD_PAT_NF)
      sprintf(buf, "%s~%s", buf, pBaddbt[idPattern].db_pat.PATTERN_ID);
    else
      sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);

  }

  sprintf(buf , "%s~BDT~BDT~%s", buf, ptb_InRec_Cur[RBD_PAT_NF]);

  // on ne fait le calcul que si il n'y a pas d'erreur
  calcul = 0;
  total = 0;

  if (idPattern == -1)
  {
    for (idx = 0; idx < PATTERNSII_ANNEES; idx++) /* Updated for Phase1b Migration */
    {
      sprintf(buf, "%s~%.3f", buf, calcul);
    }
  }
  else
  {
    for (idx = 0; idx < PATTERNSII_ANNEES; idx++) /* Updated for Phase1b Migration */
    {
      calcul = atof(ptb_InRec_Cur[RBD_AN1 + idx]) * pBaddbt[idPattern].db_pat.AN[idx];
      if (calcul > 99999999999999.99)
        calcul = 99999999999999.99;
      total += calcul;
      sprintf(buf, "%s~%.3f", buf, calcul);
    }
  }

  if (total > 99999999999999.99)
    total = 99999999999999.99;

  // ecriture du fichier pivot
  sprintf( bufStat, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~0~0~0~0~0~0~0~0~0~0~0~%s~0~0~%.3f~0~0",
           ptb_InRec_Cur[RBD_SSD_CF]  ,
           ptb_InRec_Cur[RBD_ESB_CF]  ,
           ptb_InRec_Cur[RBD_CTR_NF]  ,
           ptb_InRec_Cur[RBD_END_NT]  ,
           ptb_InRec_Cur[RBD_SEC_NF]  ,
           ptb_InRec_Cur[RBD_UWY_NF]  ,
           ptb_InRec_Cur[RBD_UW_NT]  ,
           ptb_InRec_Cur[RBD_CUR_CF]  ,
           ptb_InRec_Cur[RBD_CED_NF]   ,
           ptb_InRec_Cur[RBD_BRK_NF]   ,
           ptb_InRec_Cur[RBD_PAY_NF]   ,
           ptb_InRec_Cur[RBD_KEY_NF]   ,
           ptb_InRec_Cur[RBD_RETCTR_NF],
           ptb_InRec_Cur[RBD_RETEND_NT],
           ptb_InRec_Cur[RBD_RETSEC_NF],
           ptb_InRec_Cur[RBD_RTY_NF]   ,
           ptb_InRec_Cur[RBD_RETUW_NT] ,
           ptb_InRec_Cur[RBD_RETCUR_CF],
           ptb_InRec_Cur[RBD_PLC_NT]   ,
           ptb_InRec_Cur[RBD_RTO_NF]   ,
           ptb_InRec_Cur[RBD_SEG_NF] ,
           ptb_InRec_Cur[RBD_NORME] ,
           total / atof(ptb_InRec_Cur[RBD_ACMAMT_MC])
           //0, //ULR, //0, //WPREMIUM, //0, //WCHARGES, //0, //WCLAIM, //0, //UPR, //0, //SCOEGP, //0, //FPREMIUM, //0, //UCR, //0, //PRCO, //0, //PRCI,
           //PRMDSC,//CLMDSC  // 0, //BDTRAT,0, //PRMRESD,0 //PRMRESB
         );
  // Ecriture de la ligne pivot

  fprintf(Kp_OutputStats, "%s\n", bufStat);
  // Ecriture de la ligne courante
  fprintf(Kp_OutputBatch, "%s~~%s~%s~%.3f\n", buf, Curr_rating, comment_CF, total );

  return OK;
}





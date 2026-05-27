/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1057.c
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
[02] 01/06/2012 =Dch=-    :spot:23937 SOLVENCY II
[03] 29/10/2012 R. Cassis :spot:24041 SOLVENCY II
[04] 23/01/2013 -=Dch=-   :spot:24698 SOLVENCY II re-livraison pour no de spot
[05] 30/01/2013 P. Pezout :spot:24659 SOLVENCY II livraison pour post-Omega
[06] 16/04/2014 -=Dch=-   :spot:23927 SOLVENCY II corrections techniques
[07] 27/05/2014 C.Despret :spot:26838 SOLVENCY II RMNTP : correction montant premiere annee
[06] 13/05/2016 Florent   :spot:30543 on passe à 65 années
[07] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
[08] 14/11/2019 KBagwe : Spira#82679 : EBS - Funds Held impact on Discount - Revert.
[09] 29/11/2019 Chalres Socie : SPIRA 77191 : IFRS17 Bad debt management : discount at lock in rate (REQ11.4)
[10] 26/08/2020 HR : SPIRA 82685 : struct.h
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include <struct.h>
#include "ESTC3001A.h"

/*--------------------------------------------------*/
/* Prototype des fonctions                          */
/*--------------------------------------------------*/
int   n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int   n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
void  ChargementCurrency();
char* GetDevisebyRef(const char * ref);
void  ChargementDiscount();
long  getFileNbLigne(FILE * fl);
void  freeTableau(char** tab);
char** split(char* chaine, const char* delim, int vide);
void  addPattern( char **tab, int idx);


/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC1057A_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputCurrency;
FILE *Kp_InputCumul;
FILE *Kp_InputPattern ;
FILE *Kp_OutputBatch;
FILE *Kp_OutputRemainToPay;
FILE *Kp_OutputStats;
FILE *Kp_OutputErr;

// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF et LOB_CF
T_FPATTERNSII_JOIN * pDiscount;
T_DEVISE  * pDevise;

int * GetTblPatternDiscount(const char * LOB_CF, const char * SEGNAT_CT, const char * devise, const char * NORME_CF);
long  lignes = 0;

//void     ExtractLineCSWithNoSync();      // sortie des pattern cash flow non utilisée
/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
int nb_Devise = 0 ; // pour stocker le nombre de devise chargée dynamiquement
int nb_Pattern = 0;
int nb_Cumul = 0;

int nb_CurrPattern = 0;
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

  // Ouverture des fichiers binaires et des fichiers de sortie
  // ${PRG}_I1=${DTMP}/${PRG}_cumul.dat
  // ${PRG}_I2=${DTMP}/${PRG}_pattern.dat
  // ${PRG}_I3=${DTMP}/${PRG}_currency.dat

  if (n_OpenFileAppl("ESTC1057A_O1", "wt", &Kp_OutputBatch)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 1er fichier (ESCOMPTE)." );
  if (n_OpenFileAppl("ESTC1057A_O2", "wt", &Kp_OutputRemainToPay)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 2e fichier(REMAINTOPAY). " );
  if (n_OpenFileAppl("ESTC1057A_O3", "wt", &Kp_OutputStats)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 3e fichier(Statistiques). " );
  if (n_OpenFileAppl("ESTC1057A_O4", "wt", &Kp_OutputErr)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 4e fichier(NOSYNC). " );

  // Ouverture du fichier de cash flow ( pattern incrementales )
  if (n_OpenFileAppl("ESTC1057A_I2", "rt", &Kp_InputPattern) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de cashflow." );
  if (n_OpenFileAppl("ESTC1057A_I3", "rt", &Kp_InputCurrency) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de CUR_CF." );


  //Chargement des CUR_CF dans un tableau
  ChargementCurrency();
  // on peut fermer le fichier , les donnees sont dans pDevise
  if (n_CloseFileAppl("ESTC1057A_I3", &Kp_InputCurrency))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Devise (CUR_CF).");
  //
  //chargement des cashflow dans un tableau
  ChargementDiscount();


  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );


  // Impression des lignes du pattern cash flow non utilisées
  //  ExtractLineCSWithNoSync();
  // Fermeture des fichiers ouverts

  if (n_CloseFileAppl("ESTC1057A_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC1057A_I2", &Kp_InputPattern))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Pattern Discount.");
  if (n_CloseFileAppl("ESTC1057A_O1", &Kp_OutputBatch))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");
  if (n_CloseFileAppl("ESTC1057A_O2", &Kp_OutputRemainToPay))    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier REMAINTOPAY.");
  if (n_CloseFileAppl("ESTC1057A_O3", &Kp_OutputStats))    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier Statistiques.");
  if (n_CloseFileAppl("ESTC1057A_O4", &Kp_OutputErr))    ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier NOSYNC.");


  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");


  // libération mémoire
  free(pDevise);
  exit(OK);

}


void ChargementCurrency()
{
  // on va déterminer le nombre de ligne , et donc le nombre de devise à charger
  nb_Devise  = getFileNbLigne(Kp_InputCurrency) ;
  char buffer[LONGBUF];
  char **tab = NULL;
  size_t compteur = 0;

  memset(buffer, 0, sizeof(buffer));
  // en cas d'erreur on sort en affichant un message
  //if(nb_Devise <1) ExitPgm(ERR_XX, "Mauvais chargement du fichier de devise ( CUR_CF.dat)");
  if (nb_Devise > 0 )
  {
    //on retaille le tableau de devise
    pDevise = malloc( nb_Devise * sizeof (T_DEVISE));

    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputCurrency) != NULL)
    { // tab contient maintenant les données de la ligne en cours :
      // BEF~Belgian Franc~EUR
      // ex. tab[0] = BEF , tab[1] = Belgian Franc , tab[2] = EUR
      tab = split(buffer, SEPARATEUR_SPLIT , 1);
      strncpy(pDevise[compteur].curr, tab[0], 3);
      strncpy(pDevise[compteur].ref, tab[2], 3);
      compteur++;
      freeTableau(tab);
    }
  }
}

char * GetDevisebyRef(const char * ref)
{
  // on va recherche la devise correspondant à la référence
  char * retour = NULL;
  int compteur = 0;/* Added for Phase1b Migration */
  retour = (char*) malloc(sizeof(char) * 4);
  memset(retour, 0, 4);
  for (compteur = 0 ; compteur < nb_Devise; compteur ++)  /* Updated for Phase1b Migration */
  {
    if (strncmp(ref ,  pDevise[compteur].curr, 3) == 0 )
    {
      // on a trouvé la devise
      strncpy(retour, pDevise[compteur].ref, 3);
      retour[3] = 0;
      break;
    }
  }
  return retour;
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
  int i = 0;  /* Added for Phase1b Migration */
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

  strcpy(pDiscount[idx].db_pat.SSD_CF, tab[PAT_SSD_CF]);
  strcpy(pDiscount[idx].db_pat.PATCAT_CT, tab[PAT_PATCAT_CT]);
  strcpy(pDiscount[idx].db_pat.PATTYP_CT , tab[PAT_PATTYP_CT]);
  strcpy(pDiscount[idx].db_pat.SEG_NF , tab[PAT_SEG_NF]);
  pDiscount[idx].db_pat.UWY_NF = atoi(tab[PAT_UWY_NF]);
  strcpy(pDiscount[idx].db_pat.CUR_CF, tab[PAT_CUR_CF]);
  strcpy(pDiscount[idx].db_pat.LOB_CF , tab[PAT_LOB_CF]);
  strcpy(pDiscount[idx].db_pat.RATING_CF, tab[PAT_RATING_CF]);
  strcpy(pDiscount[idx].db_pat.NORME_CF , tab[PAT_NORME_CF]);
  strcpy(pDiscount[idx].db_pat.SEGNAT_CT , tab[PAT_SEGNAT_CT]);
  pDiscount[idx].db_pat.BALSHEY_NF = atoi(tab[PAT_BALSHEY_NF]);
  strcpy(pDiscount[idx].db_pat.PATTERN_ID, tab[PAT_PATTERN_ID]);
  strcpy(pDiscount[idx].db_pat.CRE_D, tab[PAT_CRE_D]);
  strcpy(pDiscount[idx].db_pat.CREUSR_CF , tab[PAT_CREUSR_CF]);
  // TOTAUX ignoré
  //
  pDiscount[idx].db_pat.PATTERN_ID[21] = 0;

  // on va supprimer le retour chariot si il y en a un
  taille = strlen(tab[PAT_AN_FIN + 1]);
  if (tab[PAT_AN_FIN + 1][taille - 1] == '\n')
  {
    strncpy(pDiscount[idx].jointure , tab[PAT_AN_FIN + 1], taille - 1);
  }
  else
    strcpy(pDiscount[idx].jointure , tab[PAT_AN_FIN + 1]);

  for (j = 0; j < PATTERNSII_ANNEES; j++)
  {
    pDiscount[idx].db_pat.AN[j] = atof(tab[PAT_AN1 + j]);
  }
}
/*==============================================================================
 Objet :            Chargement des données provenant du fichier de Discount
 Parametre(s) :     aucun
 Retour :           aucun
==============================================================================*/

void ChargementDiscount()
{

  char buffer[LONGBUF];
  int sizep = 0;
  nb_Pattern = getFileNbLigne(Kp_InputPattern);


  char **tab = NULL;
  //if(nb_Pattern <1) ExitPgm(ERR_XX, "Erreur de chargement du fichier des courbes de cash flow");
  if (nb_Pattern > 0)
  {
    // on retaille le pointeur sur le tableau de pattern
    pDiscount = (T_FPATTERNSII_JOIN*) realloc(pDiscount, nb_Pattern *  sizeof(T_FPATTERNSII_JOIN)) ;

    while (fgets( buffer, LONGBUF, Kp_InputPattern) != NULL)
    {
      tab = split(buffer, SEPARATEUR_SPLIT , 1);
      addPattern(tab, sizep);
      sizep++;
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

  if (n_OpenFileAppl("ESTC1057A_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}


// Chargement d'un tableau de pattern pour une devise

int * GetTblPatternDiscount(const char * LOB_CF, const char * SEGNAT_CT, const char * devise, const char * NORME_CF)
{
  int* tbl = NULL;
  int* TblEsc = NULL;
  int indexMax = 0;
  int nbDisc = 1;
  int j = 0;
  int lenCurr = strlen(devise); // normalement : 3
  int lenLob = strlen(LOB_CF);
  int lenNorme = strlen(NORME_CF);
  char CurrNorme[21];
  int indNature = 0; // index de la SEGNAT_CT trouvée , si il y en a une
  int indLob = 0;
  int indNorme = 0;
  int x = 0;
  int y = 0;
  int index;

  for (x = 0 ; x < nb_Pattern; x++) /* Updated for Phase1b Migration */
  {
    if (strncmp(devise, pDiscount[x].db_pat.CUR_CF, lenCurr) == 0)
    {
      // on va récupérer le nombre de pattern qui correspondent à la devise
      nbDisc++;
      if ((*SEGNAT_CT == *pDiscount[x].db_pat.SEGNAT_CT) && (indNature == 0) && (strncmp(LOB_CF, pDiscount[x].db_pat.LOB_CF, lenLob) == 0))
        indNature = x;
      if ((strncmp(LOB_CF, pDiscount[x].db_pat.LOB_CF, lenLob) == 0) && (indLob == 0))
        indLob = x;
      for (index = 0; NORME_CF[index] != '\0'; ++index)
        if (NORME_CF[index] != ' ')
        {
          if ((strncmp(NORME_CF, pDiscount[x].db_pat.NORME_CF, lenNorme) == 0) && (indNorme == 0) && (strncmp(LOB_CF, pDiscount[x].db_pat.LOB_CF, lenLob) == 0))
          {
            indNorme = x;
            indLob = x;
          }
          break;
        }
    }
    // on retaille le pointeur sur le tableau de pattern
  }

  tbl = realloc(tbl, sizeof(int) * nbDisc);
//  pEsc = (T_FPATTERNSII_JOIN*) malloc ( (int)( nbDisc * sizeof(T_FPATTERNSII_JOIN)));


  if (tbl == NULL)
  {
    printf("Erreur de chargement dynamique de données\n");
    ExitPgm(ERR_XX, "Problème d'allocation de mémoire");
  }

  // initialisation du tableau d'entier
  for (x = 0; x < nbDisc; x++) /* Updated for Phase1b Migration */
  {
    tbl[x] = -1;
  }


  for (x = 0 ; x < nb_Pattern; x++)
  {
    if (strncmp(devise, pDiscount[x].db_pat.CUR_CF, lenCurr) == 0)
    {
      tbl[j] = x;
      j++;
    }
    else
      tbl[j] = -1 ;
  }

  // j contient le max index de tbl
  // tbl = realloc ( tbl , sizeof(int) * j);
  // TblEsc = realloc(NULL, sizeof(int) * j);
  if (indLob)
  {
    // on va supprimer les pattern dont la LOB_CF est différente
    for (x = 0 ; x < j ; x++) /* Updated for Phase1b Migration */
    {
      if (( tbl[x] != -1) && strncmp(LOB_CF, pDiscount[tbl[x]].db_pat.LOB_CF, lenLob) != 0)
      {
        tbl[x] = -1;
      }
    }
  }

  if (indNorme)
  {
    // on va supprimer les pattern dont la LOB_CF est différente
    for (x = 0 ; x < j ; x++) /* Updated for Phase1b Migration */
    {
      if (( tbl[x] != -1) && strcmp(NORME_CF, pDiscount[tbl[x]].db_pat.NORME_CF) != 0)
      {
        tbl[x] = -1;
      }
    }
  }

  if (indNature)
  {
    // on va supprimer les pattern dont la SEGNAT_CT est différente
    for (x = 0 ; x < j; x++) /* Updated for Phase1b Migration */
    {
      if (( tbl[x] != -1) && (*SEGNAT_CT != *pDiscount[tbl[x]].db_pat.SEGNAT_CT ))
      {
        tbl[x] = -1;
      }
    }
  }


  // on va vérifier que l'on ait qu'une seule NORME_CF
  for (x = 0; x < j ; x++) /* Updated for Phase1b Migration */
  {
    // on ne va vérifier que les valides
    if (tbl[x] != -1)
    {
      // on remet la NORME_CF à blanc
      memset(CurrNorme, 0 , sizeof(CurrNorme));
      strncpy(CurrNorme, pDiscount[tbl[x]].db_pat.NORME_CF, strlen(pDiscount[tbl[x]].db_pat.NORME_CF));
      for (y = 0; y < nbDisc; y++) /* Updated for Phase1b Migration */
      {
        // on ne va vérifier que les valides
        if (tbl[y] != -1)
        {
          //on va éviter de comparer la NORME_CF en cours ... a elle même
          if ((strncmp(CurrNorme, pDiscount[tbl[y]].db_pat.NORME_CF, strlen(CurrNorme)) == 0) && x != y )
          {
            tbl[y] = -1;
          }
        }
      }
    }
  }

  // on va rechercher combien on a de valeur ok
  for (x = 0 ; x < j ; x++)   /* Updated for Phase1b Migration */
  {
    if (tbl[x] != -1)
      indexMax++;
  }

  TblEsc = realloc(NULL, sizeof(int) * indexMax);

  indexMax = 0;
  for (x = 0 ; x < j ; x++)   /* Updated for Phase1b Migration */
  {
    if (tbl[x] != -1)
    {
      TblEsc[indexMax] = tbl[x];
      indexMax++;
    }
  }
  free(tbl);
  nb_CurrPattern = indexMax;
  return TblEsc;
}


/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchIN(char **ptb_InRec_Cur)
{
  char        buf[LONGBUF];         // pour le buffer de sortie ESCOMPTE
  char    buf2Pay[LONGBUF];       // pour le buffer de sortie REMAINTOPAY
  char    bufStat[LONGBUF];         // pour le buffer de sortie des stats
  double    amount, calcul, total, total2 ;           // montant du fichier cumul
  double  escompte[PATTERNSII_ANNEES];
  T_FPATTERNSII_JOIN   pDSC;
  int *     tbl = NULL;
  char*     monnaie;
  char      CurrLob[21];
  char      jointure[100] ;
  int     ExistLob;       // pour tester  si il y a une LOB_CF dans la ligne en cours de traitement
  int     ExistSegment;
  int     isOK = 0;     // pour vérifier la synchro , en cas d'erreur on renvoi la ligne dans un fichier nosync
  char    ratingDevise[6];
  int idx = 0;  /* Added for Phase1b Migration */
  int col = 0;  /* Added for Phase1b Migration */
  int i_an = 0 ;/* Added for Phase1b Migration */
  int j = 0;    /* Added for Phase1b Migration */
  int x = 0;   /* Added for Phase1b Migration */
  int     acmtrs;
  DEBUT_FCT("n_ActionLigneRfrBatchIN");


  //ptb_InRec_Cur contient la ligne courante
  // on va comparer le contenu de la colonne ptb_InRec_Cur[CML_CUR_CF]
  //avec le contenu des colonnes des patterns

  // on vérifie la LOB_CF
  memset(CurrLob , 0 , sizeof(CurrLob));
  memset(buf, 0, sizeof(buf));
  memset(buf2Pay, 0, sizeof(buf2Pay));
  memset(bufStat , 0, sizeof(bufStat));
  memset(jointure, 0, sizeof(jointure));
  memset(ratingDevise , 0 , sizeof(ratingDevise));

  ExistLob = strlen(ptb_InRec_Cur [CML_LOB_CF]) ;
  ExistSegment = strlen(ptb_InRec_Cur [CML_SEG_NF]) ;

  monnaie = malloc(sizeof(char) * 4);

  if (strlen(ptb_InRec_Cur [CML_ACMCUR_CF]))
  {
    // on récupère la devise de référence
    monnaie = GetDevisebyRef(ptb_InRec_Cur [CML_ACMCUR_CF]);
	if (strlen(monnaie) != 0)
      ptb_InRec_Cur[CML_ACMCUR_CF] = monnaie;
  }
  else
  {
    sprintf(monnaie, "%s", "EUR");
  }
  if (strlen(monnaie) != 0)
  {
    // on compare avec la jointure des discounts
    sprintf(jointure, "%s", monnaie);
    if (ExistLob > 0)
    {
      sprintf(CurrLob, "%s", ptb_InRec_Cur [CML_LOB_CF]);
      sprintf(jointure , "%s%s", jointure,  CurrLob);
    }

    // test de la function GetPatternDiscount
	if(strncmp(ptb_InRec_Cur[CML_NORME_CF],"I17G",4) != 0 || strncmp(ptb_InRec_Cur[CML_ACMTRS_NT],"314",3) != 0){
		tbl = GetTblPatternDiscount(CurrLob , ptb_InRec_Cur [CML_NAT_CF], monnaie, ptb_InRec_Cur[CML_NORME_CF]);
	}
	else{
		nb_CurrPattern = 0;
		isOK = 1;
	}
    // pDSC = GetPatternDiscount(CurrLob , ptb_InRec_Cur [CML_NAT_CF], monnaie);
    // nb_CurrPattern contient le nombre de pattern correspondants...
    for (idx = 0 ; idx < nb_CurrPattern; idx++) /* Updated for Phase1b Migration */
    {
      if (tbl[idx] != -1)
      {
        memcpy(&pDSC, &pDiscount[tbl[idx]], sizeof(T_FPATTERNSII_JOIN));

        sprintf(ratingDevise, "%s", pDSC.db_pat.RATING_CF);

        // d'abord l'entête
        sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
        //puis tout le reste des colonnes qui précèdent les montants annuels

        // on va recopier le buffer qui contient les premières colonnes
        sprintf(buf2Pay, "%s", buf);

		//[07] add ACMTRS3 at the end of te file 
        for (col = 1; col <= CML_TYP_CT; col++) /* Updated for Phase1b Migration */
        {
          if (col == CML_ACMTRS_NT)
          {
            if (strlen(ptb_InRec_Cur[CML_ACMTRS_NT]) == 3 &&
                ptb_InRec_Cur[CML_ACMTRS_NT][0] == '3' &&
                ptb_InRec_Cur[CML_ACMTRS_NT][1] == '0'  )
            {
              strcpy(ptb_InRec_Cur[CML_ACMTRS_NT], "301");
			  strcpy(ptb_InRec_Cur[CML_ACMTRS3_NT2], "3010");
            }
            acmtrs = atoi(ptb_InRec_Cur[CML_ACMTRS_NT]) + 00; // pour RMTP
            sprintf(buf2Pay, "%s~%d", buf2Pay, acmtrs);
          }

          if (col == CML_TRNCOD_CF)
          {
            sprintf(buf, "%s~", buf);  // pas de valeur dans cette colonne
            sprintf(buf2Pay, "%s~", buf2Pay);
          }
          else
          {
            sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
            if (col != CML_ACMTRS_NT)
            {
              sprintf(buf2Pay, "%s~%s", buf2Pay, ptb_InRec_Cur[col]);
            }
          }
        }
//[09]
		if(strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 && strcmp(ptb_InRec_Cur[CML_PATTYP_CT],"RMNTP") == 0 ){
			sprintf(buf, "%s~%s~%s~BDT~BDT~%s" ,
					buf,
					pDSC.db_pat.NORME_CF , // NORME_CF
					ptb_InRec_Cur[CML_RATING_CF],
					pDSC.db_pat.PATTERN_ID
				   );
		}
		else{
        // et le reste des colonnes de Discount
			sprintf(buf, "%s~%s~%s~%s~%s~%s" ,
					buf,
					pDSC.db_pat.NORME_CF , // NORME_CF
					ratingDevise,
					pDSC.db_pat.PATCAT_CT,
					pDSC.db_pat.PATTYP_CT,
					pDSC.db_pat.PATTERN_ID
				   );
		}
			   
        // et le reste des colonnes de Discount
        sprintf(buf2Pay, "%s~%s~%s~BDT~RMNTP~%s" ,
                buf2Pay,
                pDSC.db_pat.NORME_CF , // NORME_CF
                ratingDevise,
                //pDSC.db_pat.PATCAT_CT,
                //pDSC.db_pat.PATTYP_CT,
                pDSC.db_pat.PATTERN_ID
               );

        // Puis la liste des taux calculés
        // on va d'abord la 1er année ( an 0)

        escompte[0] = pDSC.db_pat.AN[0] *  atof(ptb_InRec_Cur[CML_AN1]);
        sprintf(buf, "%s~%.3f", buf, escompte[0] );
        //[007]sprintf(buf2Pay, "%s~%.3f", buf2Pay , escompte[0]);

        calcul = 0;
        amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);

        //sprintf(buf2Pay, "%s~%.3f", buf2Pay, escompte[0]);

        for (i_an = 1; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
        {
          calcul = pDSC.db_pat.AN[i_an] *  atof(ptb_InRec_Cur[CML_AN1 + i_an]);
          escompte[i_an] = calcul;
          // on va stocker le résultat de chaque année pour le calcul du cumul rmpt
          sprintf(buf, "%s~%.3f", buf, calcul);
        }

        total2 = 0;
        // on va aussi faire la même chose pour le remaining to pay
        // [007]
        //for (col = 1; col < PATTERNSII_ANNEES; col++) /* Updated for Phase1b Migration */
        for (col = 0; col < PATTERNSII_ANNEES; col++) /* Updated for Phase1b Migration */
        {
          calcul = escompte[col];
          for (x = col + 1; x < PATTERNSII_ANNEES ; x++) /* Updated for Phase1b Migration */
          {
            calcul += escompte[x];
          }
          total2 += calcul;
          sprintf(buf2Pay, "%s~%.3f", buf2Pay, calcul);
        }

        total = 0;
        for (j = 0 ; j < PATTERNSII_ANNEES; j++) /* Updated for Phase1b Migration */
        {
          total += escompte[j];
        }

        isOK = 1; // on signale que la synchro est trouvée  , même si on n'écrit pas la ligne

        if (total != 0)
        {
          sprintf( bufStat, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~0~0~0~0~0~0~0~0~0~0~0~%s~%f~%f~0~0~0",
                   ptb_InRec_Cur[CML_SSD_CF] ,
                   ptb_InRec_Cur[CML_ESB_CF]   ,
                   ptb_InRec_Cur[CML_CTR_NF] ,
                   ptb_InRec_Cur[CML_END_NT] ,
                   ptb_InRec_Cur[CML_SEC_NF] ,
                   ptb_InRec_Cur[CML_UWY_NF] ,
                   ptb_InRec_Cur[CML_UW_NT]  ,
                   ptb_InRec_Cur[CML_CUR_CF] ,
                   ptb_InRec_Cur[CML_CED_NF],
                   ptb_InRec_Cur[CML_BRK_NF],
                   ptb_InRec_Cur[CML_PAY_NF],
                   ptb_InRec_Cur[CML_KEY_NF],
                   ptb_InRec_Cur[CML_RETCTR_NF],
                   ptb_InRec_Cur[CML_RETEND_NT],
                   ptb_InRec_Cur[CML_RETSEC_NF],
                   ptb_InRec_Cur[CML_RTY_NF],
                   ptb_InRec_Cur[CML_RETUW_NT],
                   ptb_InRec_Cur[CML_RETCUR_CF],
                   ptb_InRec_Cur[CML_PLC_NT],
                   ptb_InRec_Cur[CML_RTO_NF],
                   ExistSegment ? ptb_InRec_Cur[CML_SEG_NF] : CurrLob  ,
                   pDSC.db_pat.NORME_CF,
                   //0, //ULR, //0, //WPREMIUM, //0, //WCHARGES, //0, //WCLAIM, //0, //UPR, //0, //SCOEGP, //0, //FPREMIUM, //0, //UCR, //0, //PRCO, //0, //PRCI,
                   ((strncmp(ptb_InRec_Cur[CML_PATTYP_CT], "PR", 2) == 0) && (amount != 0 )) ? total / amount : 0.0,
                   ((strncmp(ptb_InRec_Cur[CML_PATTYP_CT], "CL", 2) == 0) && (amount != 0 )) ? total / amount : 0.0
                   //PRMDSC,
                   //CLMDSC  // 0, //BDTRAT,0, //PRMRESD,0 //PRMRESB
                 );


          fprintf(Kp_OutputStats, "%s\n", bufStat);

			
          // Ecriture de la ligne courante , à laquelle on ajoute les 4 colonnes de commentaires
          fprintf(Kp_OutputBatch, "%s~%s~%s~~%.3f~%s\n", buf, CurrLob, monnaie, total, ptb_InRec_Cur[CML_ACMTRS3_NT2] );

          //Pour le remaintopay on écrit la ligne que si c'est un PATTYP_CT retro
          if (*ptb_InRec_Cur[CML_TYP_CT] == 'R')
          {
            fprintf(Kp_OutputRemainToPay, "%s~%s~%s~~%.3f~%s\n", buf2Pay, CurrLob, monnaie, total2, ptb_InRec_Cur[CML_ACMTRS3_NT2] );
          }
        }

      }
    }
  }
  // si on a pas trouvé le RATING_CF, on sort la ligne en erreur
  if (isOK == 0)
  {
	  //[07]
    char TempACMTRS3[5];
    strcpy(TempACMTRS3,ptb_InRec_Cur[CML_ACMTRS3_NT2]); 
    // on va ajouter 3 colonnes vides au tableau de pointeur
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 1] = " ";
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 2] = monnaie;
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 3] = "Pattern non trouvee";
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 4] = "\0";

    n_WriteCols(Kp_OutputErr, ptb_InRec_Cur, '~', 0) ;
    // on vide la NORME_CF et on ressort aussi la ligne dans le fichier ESCOMPTE
    ptb_InRec_Cur[CML_NORME_CF] = 0;
    //strcpy(ptb_InRec_Cur[CML_RATING_CF],  "ERR");
    // on met les PATTERNSII_ANNEES années à 0
    // d'abord l'entête
    sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
    //puis tout le reste des colonnes qui précèdent les montants annuels
    for (col = 1; col <= CML_TYP_CT; col++) /* Updated for Phase1b Migration */
    {
      sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);

    }
	if(strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 && strcmp(ptb_InRec_Cur[CML_PATTYP_CT],"RMNTP") == 0 ){ //[09]
		sprintf(buf, "%s~~~BDT~BDT~ERR", buf);
	}
	else {
		sprintf(buf, "%s~~~DSC~DSI~ERR", buf);
		}
    for (i_an = 0; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
    {
      sprintf(buf, "%s~0", buf);
    }
    fprintf(Kp_OutputBatch, "%s~~~Pattern non trouvee~~%s\n", buf, TempACMTRS3) ;
 }
  return OK;
}


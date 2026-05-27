/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1056.c
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
[01]  01/06/2012 -=Dch=-  :      :spot:23937 SOLVENCY II
[02]  10/01/2013 Roger Cassis    :spot:24041 pour livraison dans spot
[03]  06/01/2014 Cyrille Despret :spot:26391 Gestion des pattern de PATTYP_CT ICR
                                              On peut avoir en entrée un fichier de données auquel on applique des patterns
                                              Avant, ce programme servait uniquement à appliquer des pattern des cash flow (PATTYP_CT CSF)
                                              Maintenant il sert aussi à appliquer de la même manière les patterns de PATTYP_CT ICR (incurred), aux IBNR par exemple
                                              Pour les patterns de category CSF, les types possible sont PRACC, PRRET, CLACC, CLRET
                                              Pour les patterns de category ICR, les types possible sont ICACC et ICRET
                                              Comme le programme est commun aux CSF et ICR, on considère que les 6 types de pattern sont possibles quel que soit la categorie
                                              (i.e. : le tableau pEtoile gere les 6 types)
[04]  26/01/2015  Cyrille Despret :spot:26391 Correction de la taille du tableau qui contient les colonnes vides pour les annees futures
[05]  -=Dch=-    15/06/2015       :spot:28941 SOLVENCY II - ULAE
[06]  13/05/2016 Florent          :spot:30543 on passe à 65 années
[07]  01/08/2016 -=Dch=-  		  :spot:30995 Ajout de la filiale 26 
[08]  16/09/2016 Roger Cassis   :spot:30995 On incremente le nombre de filiales a 50
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC3001.h"

/*------------*/
/* Constantes */
/*------------*/
#define NB_FILIALES 50  //[07] [08]

//Définition des colonnes de jointure du fichier cumul
#define  CML_NAT_CF  47
#define  CML_TYP_CT  48

// définition des colonnes de jointures cashflow SEG_NF ou LOB_CF
#define COL_CS_SEG   56
#define COL_CS_LOB   57

// Variable de fichiers
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

FILE *Kp_OutputFileRfrBatchOut;
FILE *Kp_InputCumul;
FILE *Kp_InputCashFlow;
FILE *Kp_OutputPatternBatchOut;
FILE *Kp_OutputFileRMNTP;
// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF et LOB_CF
T_FPATTERNSII_JOIN2 *pCS_SEG;
T_FPATTERNSII_JOIN2 *pCS_LOB;

int numLigne = 0; // pour debug

/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
void   ExtractLineCSWithNoSync();      // sortie des pattern cash flow non utilisée
int    n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int    n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
void   ChargementDataCashFlow();
long   getFileNbLigne(FILE * fl);
char*  Trim(char *s);
void   freeTableau(char** tab) ;
char** split(char* chaine, const char* delim, int vide);
int    getIndexCS(const int Col, const char * jointure, T_FPATTERNSII_JOIN2 * pCS, int sizeTableau, char * typecat, const char *);
T_FPATTERNSII_JOIN2 * addPattern( T_FPATTERNSII_JOIN2 * pCS , char **tab, int idx) ;

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/

char    clodat_d[10];               // Date de cloture
int     uwy_nf;                     // UWY_NF
char    PATTERN_ID[21];             // Identifiant pattern
int     Quarter  ;                  // pour récupérer le trimestre passé en paramètre
char    pattern_category[3];        // [003] pour récupérer le PATTYP_CT de pattern passé en second paramètre


// nombre de ligne du fichier de cashflow ( et donc de l'indice max du tableau de struct. associé)
int     sizeCS_SEG = 0 ;
int     sizeCS_LOB = 0 ;

int     nbSegment = 0;
int     MaxSegmentIndex = 50 ; // pour éviter les realloc, on va tailler le tableau par tranche de 50

// tableau des valeur ETOILE dans les segments
// le tableau est un tableau à 2 dimensions comme suit:
// pEtoile[a][b] ==> [a] correspond au numéro de SSD_CF et [b] est l'une des 4 valeurs CLACC, PRRET, CLRET, PRACC ( voir l'enum dans l'entête du fichier ). le contenu est 0 ou 1 .
// par défaut on va saisir 25 filiales
int ** pEtoile ;

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
  int i = 0; /* Added for Phase1b Migration */
  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");


  // Récupération des trois paramètres
  memset(clodat_d,   0, sizeof(clodat_d));
  memset(PATTERN_ID, 0, sizeof(PATTERN_ID));
  uwy_nf     = 0;


  Quarter = n_GetIntArgv(1);

  // [003] Pour récupérer la category du pattern passé en second paramètre
  strcpy(pattern_category, psz_GetCharArgv(2));



// A DECOMMENTER POUR RECUPERATION DU TRIMESTRE PASSE EN PARAMETRE

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1056_O1", "wt", &Kp_OutputFileRfrBatchOut)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 1er fichier d'output." );
  if (n_OpenFileAppl("ESTC1056_O2", "wt", &Kp_OutputPatternBatchOut)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 2e fichier d'output." );
  if (n_OpenFileAppl("ESTC1056_O3", "wt", &Kp_OutputFileRMNTP)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 3e fichier d'output." );

  // Ouverture du fichier de cash flow ( pattern incrementales )
  if (n_OpenFileAppl("ESTC1056_I2", "rt", &Kp_InputCashFlow) == ERR) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de cashflow." );

  // On va initialiser le tableau des filiales à vide
  pEtoile = malloc (NB_FILIALES  * sizeof(int*));
  for (i = 0 ; i < NB_FILIALES ; i++) /* Updated for Phase1b Migration */
  {
    //[003] Ajout des 2 types ICACC et ICRET
    //pEtoile[i] = malloc (4 * sizeof(int));
    pEtoile[i] = malloc (6 * sizeof(int));
    pEtoile[i][0] = 0;
    pEtoile[i][1] = 0;
    pEtoile[i][2] = 0;
    pEtoile[i][3] = 0;
    //[003] Ajout des 2 types ICACC et ICRET
    pEtoile[i][4] = 0;
    pEtoile[i][5] = 0;
  }
  //chargement des cashflow dans un tableau
  ChargementDataCashFlow();


  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );


  // Impression des lignes du pattern cash flow non utilisées
//  ExtractLineCSWithNoSync();
  // Fermeture des fichiers ouverts

  if (n_CloseFileAppl("ESTC1056_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

  if (n_CloseFileAppl("ESTC1056_I2", &Kp_InputCashFlow))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cash flow.");

  if (n_CloseFileAppl("ESTC1056_O1", &Kp_OutputFileRfrBatchOut))          ExitPgm(ERR_XX, "Problème lors de la fermeture du 1er fichier d'output.");

  if (n_CloseFileAppl("ESTC1056_O2", &Kp_OutputPatternBatchOut))          ExitPgm(ERR_XX, "Problème lors de la fermeture du 2e fichier d'output.");

  if (n_CloseFileAppl("ESTC1056_O3", &Kp_OutputFileRMNTP))              ExitPgm(ERR_XX, "Problème lors de la fermeture du 3e fichier d'output.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  free(pEtoile);
  exit(OK);
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


void ExtractLineCSWithNoSync()
{
  char buffer[LONGBUF];
  int i = 0;  /* Added for Phase1b Migration */
  memset(buffer, 0, sizeof(buffer));


  // vérification des pattern SEG_NF
  for (i = 0; i < (sizeCS_SEG - 1); i++) /* Updated for Phase1b Migration */
  {
    if (pCS_SEG[i].used == 1)
    {
      memset(buffer, 0, sizeof(buffer));
      sprintf(buffer, "%s~%s~%s~%s~%d~%s~%s~%s~%s~%s~%d~%s~%s~%s",
              pCS_SEG[i].db_pat.SSD_CF,
              pCS_SEG[i].db_pat.PATCAT_CT,
              pCS_SEG[i].db_pat.PATTYP_CT,
              pCS_SEG[i].db_pat.SEG_NF,
              pCS_SEG[i].db_pat.UWY_NF,
              pCS_SEG[i].db_pat.CUR_CF,
              pCS_SEG[i].db_pat.LOB_CF,
              pCS_SEG[i].db_pat.RATING_CF,
              pCS_SEG[i].db_pat.NORME_CF,
              pCS_SEG[i].db_pat.SEGNAT_CT,
              pCS_SEG[i].db_pat.BALSHEY_NF,
              pCS_SEG[i].db_pat.PATTERN_ID,
              pCS_SEG[i].db_pat.CRE_D,
              pCS_SEG[i].db_pat.CREUSR_CF );
      // Ecriture de la ligne courante
      fprintf(Kp_OutputPatternBatchOut, "%s\n", buffer);
    }
  }
  // vérification des pattern SEG_NF
  for (i = 0; i < (sizeCS_LOB - 1); i++) /* Updated for Phase1b Migration */
  {
    if (pCS_LOB[i].used == 1)
    {
      memset(buffer, 0, sizeof(buffer));
      sprintf(buffer, "%s\n%s~%s~%s~%s~%d~%s~%s~%s~%s~%s~%d~%s~%s~%s", buffer,
              pCS_LOB[i].db_pat.SSD_CF,
              pCS_LOB[i].db_pat.PATCAT_CT,
              pCS_LOB[i].db_pat.PATTYP_CT,
              pCS_LOB[i].db_pat.SEG_NF,
              pCS_LOB[i].db_pat.UWY_NF,
              pCS_LOB[i].db_pat.CUR_CF,
              pCS_LOB[i].db_pat.LOB_CF,
              pCS_LOB[i].db_pat.RATING_CF,
              pCS_LOB[i].db_pat.NORME_CF,
              pCS_LOB[i].db_pat.SEGNAT_CT,
              pCS_LOB[i].db_pat.BALSHEY_NF,
              pCS_LOB[i].db_pat.PATTERN_ID,
              pCS_LOB[i].db_pat.CRE_D,
              pCS_LOB[i].db_pat.CREUSR_CF );
      // Ecriture de la ligne courante
      fprintf(Kp_OutputPatternBatchOut, "%s\n", buffer);

    }
  }
}



/* -----------------------------------------------------------------------*/
/*  Fonction    : int getFileNbLigne(FILE *fl)                */
/*  Description : Renvoi le nombre de ligne dans un fichier             */
/*  ATTENTION   : Remet la position au début du  fichier           */
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
  int i = 0; //Added for Phase1b Migration */
  for (i = 0; tab[i] != NULL; i++) //Updated for Phase1b Migration */
  {
    free(tab[i]);
  }
}

/* ----------------------------------------------------------------------------*/
/* Retour tableau des chaines recupérer. Terminé par NULL.             */
/* chaine : chaine à splitter                             */
/* delim : delimiteur qui sert à la decoupe                   */
/* vide : 0 : on n'accepte pas les chaines vides                 */
/*        1 : on accepte les chaines vides                     */
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
          ( LOB_CF ou SEG_NF)
 Parametre(s) :     pCS est la structure sur laquelle faire le chargement ( LOB_CF ou SEG_NF)
          tab est un pointeur de pointeur de tableau de la ligne en cours de lecture.
          Les champs ont déjà été splitté avec le séparateur qui va bien

 Retour :           pointeur sur la nouvelle structure
==============================================================================*/
T_FPATTERNSII_JOIN2 * addPattern( T_FPATTERNSII_JOIN2 * pCS , char **tab, int sizeP)
{
  int idx = sizeP - 1 ;
  int j = 0 ; /* Added for Phase1b Migration */
  // on augmente la taille du tableau dynamique
  // pour ajouter l'enregistrement en cours
  pCS = (T_FPATTERNSII_JOIN2*) realloc(pCS, sizeP *  sizeof(T_FPATTERNSII_JOIN2)) ;

  strcpy(pCS[idx].db_pat.SSD_CF, tab[PAT_SSD_CF]);
  strcpy(pCS[idx].db_pat.PATCAT_CT, tab[PAT_PATCAT_CT]);
  strcpy(pCS[idx].db_pat.PATTYP_CT , tab[PAT_PATTYP_CT]);
  strcpy(pCS[idx].db_pat.SEG_NF , tab[PAT_SEG_NF]);
  pCS[idx].db_pat.UWY_NF = atoi(tab[PAT_UWY_NF]);
  strcpy(pCS[idx].db_pat.CUR_CF, tab[PAT_CUR_CF]);
  strcpy(pCS[idx].db_pat.LOB_CF , tab[PAT_LOB_CF]);
  strcpy(pCS[idx].db_pat.RATING_CF, tab[PAT_RATING_CF]);
  strcpy(pCS[idx].db_pat.NORME_CF , tab[PAT_NORME_CF]);
  pCS[idx].db_pat.BALSHEY_NF = atoi(tab[PAT_BALSHEY_NF]);
  strcpy(pCS[idx].db_pat.PATTERN_ID, tab[PAT_PATTERN_ID]);
  strcpy(pCS[idx].db_pat.CREUSR_CF , tab[PAT_CREUSR_CF]);
  pCS[idx].db_pat.TOTAUX = atof(tab[PAT_TOTAUX]);
  // TOTAUX ignoré
  // on charge les PATTERNSII_ANNEES années
  for (j = 0; j < PATTERNSII_ANNEES; j++) /* Updated for Phase1b Migration */
  {
    pCS[idx].db_pat.AN[j] = atof(tab[PAT_AN1 + j]);
  }
  pCS[idx].used = 0 ;   // pour vérifier l'utilisation lors du print final
  return pCS;
}

/*==============================================================================
 Objet :            Chargement des données provenant du fichier de cash flow
 Parametre(s) :     aucun
 Retour :           aucun
==============================================================================*/
void ChargementDataCashFlow()
{
  int nbLigneCS = getFileNbLigne(Kp_InputCashFlow);
  char buffer[LONGBUF];
  int txtype;

  char **tab = NULL;
  // if(nbLigneCS <1) ExitPgm(ERR_XX, "Erreur de chargement du fichier des courbes de cash flow");
  // on ne fait plus de plantage si le fichier est vide, on sort uniquement pour ne pas planter toute la chaine
  if (nbLigneCS > 0 )
  {
    while (fgets( buffer, LONGBUF, Kp_InputCashFlow) != NULL)
    {
      tab = split(buffer, SEPARATEUR_SPLIT , 1);

      // on va mettre une valeur dans le tableau étoile si nécessaire
      if (*tab[PAT_SEG_NF] == '*')
      {
        if (strncmp(tab[PAT_PATTYP_CT], "PRACC", 5) == 0)
          txtype = PRACC;
        if (strncmp(tab[PAT_PATTYP_CT], "PRRET", 5) == 0)
          txtype = PRRET;
        if (strncmp(tab[PAT_PATTYP_CT], "CLACC", 5) == 0)
          txtype = CLACC;
        if (strncmp(tab[PAT_PATTYP_CT], "CLRET", 5) == 0)
          txtype = CLRET;
        //[003] Ajout des 2 types ICACC et ICRET
        if (strncmp(tab[PAT_PATTYP_CT], "ICACC", 5) == 0)
          txtype = ICACC;
        if (strncmp(tab[PAT_PATTYP_CT], "ICRET", 5) == 0)
          txtype = ICRET;


        pEtoile[atoi(tab[PAT_SSD_CF]) - 1][txtype] = 1;
      }

      if (strlen(Trim(tab[PAT_SEG_NF])) == 0)
      {
        sizeCS_LOB++;
        pCS_LOB = addPattern(pCS_LOB, tab, sizeCS_LOB);
        // on récupère la colonne qui sert à la jointure
        strcpy(pCS_LOB[sizeCS_LOB - 1].joint_lob, tab[PAT_AN_FIN + 2]);
      }
      else
      {
        sizeCS_SEG++;
        pCS_SEG = addPattern(pCS_SEG, tab, sizeCS_SEG);
        // on récupère la colonne qui sert à la jointure
        strcpy(pCS_SEG[sizeCS_SEG - 1].joint_seg, tab[PAT_AN_FIN + 1]);
      }


      freeTableau(tab);
    }
  }
}

/*==============================================================================
 Objet :            Recherche de l'index de la struct T_FPATTERNSII_JOIN2 issue du fichier CashFlow
          correspondant à la colonne de jointure du fichier cumul
 Parametre(s) :     int col est le numéro de colonne de référence utilisé pour la comparaison,
          const char * jointure est le contenu de la valeur à comparer
 Retour :           l'index
==============================================================================*/
int getIndexCS(const int Col, const char * jointure, T_FPATTERNSII_JOIN2 * pCS, int sizeTableau, char * typecat, const char * ssd)
{
  int retour = -1; // retour par défaut
  size_t lenJ = strlen(jointure);
  char annee[5];
  char sType[6] ;
  char SEG_NF[10];
  int uwy;
  int SSD_CF = atoi(ssd);
  int itypeCat = 0; // PRAC , première valeur
  int SegmentLobFound = 0; // flag de SegLob
  int idx = 0; /* Added for Phase1b Migration */
  if (strncmp(typecat, "PRRET", 5) == 0)
    itypeCat = PRRET;
  if (strncmp(typecat, "CLACC", 5) == 0)
    itypeCat = CLACC;
  if (strncmp(typecat, "CLRET", 5) == 0)
    itypeCat = CLRET;

  if (strncmp(typecat, "ICACC", 5) == 0)
    itypeCat = ICACC;
  if (strncmp(typecat, "ICRET", 5) == 0)
    itypeCat = ICRET;


  // on va d'abord essayer de trouver la jointure
  // si on ne trouve pas la jointure dans la pattern , on va essayer de vérifer si on a une valeur étoile '*' dans le tableau
  // de pattern pour une même SSD_CF et année

  if (lenJ > 0)
  {
    memset(annee, 0, sizeof(annee));
    memset(sType, 0, sizeof(sType));
    memset(SEG_NF, 0, sizeof(SEG_NF));

    strncpy(annee , jointure + ( lenJ - 4), 4 ); // on récupère la date d'exercic
    uwy = atoi(annee);
    strncpy(SEG_NF, jointure, lenJ - 4);

    if (Col == PAT_AN_FIN + 1) // si on est sur une jointure SEG_NF
    {
      for (idx = 0; idx < sizeTableau ; idx++) /* Updated for Phase1b Migration */
      {
        if (atoi(pCS[idx].db_pat.SSD_CF) == SSD_CF)
        {
          if (strncmp(typecat, pCS[idx].db_pat.PATTYP_CT, 5) == 0 )
          {
            if (strncmp(SEG_NF,  pCS[idx].db_pat.SEG_NF, strlen(pCS[idx].db_pat.SEG_NF)) == 0)
            {
              SegmentLobFound = -2; // on flag pour dire que l'on a trouvé le SEG_NF, mais pas forcément la bonne année
              // on récupère la pattern du SEG_NF courant
              strcpy(PATTERN_ID, pCS[idx].db_pat.SEG_NF);
            }
            if (strncmp(jointure, pCS[idx].joint_seg, lenJ) == 0)
            {
              retour = idx;
              PATTERN_ID[0] = '\0';
              return retour;
              break; // ne sert pas à grand chose , le retour est faite à ligne qui précède
            }
          }

        }
      }
      // si le retour n'est pas fait dans les boucles précédentes
      // alors on va vérifier que des segments '*' existent
      if ((pEtoile[SSD_CF - 1][itypeCat]) && (SegmentLobFound == 0))
      {
        for (idx = 0 ; idx < sizeTableau; idx++) /* Updated for Phase1b Migration */
        {
          if (atoi(pCS[idx].db_pat.SSD_CF) == SSD_CF)
          {
            if ((pCS[idx].db_pat.SEG_NF[0] == '*') && (pCS[idx].db_pat.UWY_NF == uwy ) )
            {
              if (strncmp(typecat, pCS[idx].db_pat.PATTYP_CT, 5) == 0 )
              {
                retour = idx;
                PATTERN_ID[0] = '\0';
                return retour;
                break;
              }
            }
          }
        }
      }
    }
    else // donc une jointure LOB_CF
    {
      // on va supprimer les "0" précédents, (si la LOB_CF est < 10 par exemple)
      int  seglob = atoi(SEG_NF);
      sprintf(SEG_NF, "%d", seglob);

      for (idx = 0; idx < sizeTableau ; idx++) /* Updated for Phase1b Migration */
      {
        if (atoi(pCS[idx].db_pat.SSD_CF) == SSD_CF)
        {
          if (strncmp(SEG_NF,  pCS[idx].db_pat.LOB_CF, strlen(pCS[idx].db_pat.LOB_CF)) == 0)
          {
            SegmentLobFound = -2;
            // on récupère la pattern du SEG_NF courant
            strcpy(PATTERN_ID, pCS[idx].db_pat.SEG_NF);
          }
          if (strncmp(jointure, pCS[idx].joint_lob, lenJ) == 0)
          {
            if (strncmp(typecat, pCS[idx].db_pat.PATTYP_CT, 5) == 0 )
            {
              retour = idx;
              PATTERN_ID[0] = '\0';
              return retour;
              break;
            }
          }
        }
      }
      // si le retour n'est pas fait dans les boucles précédentes
      // alors on va vérifier que des segments '*' existent
      if ((pEtoile[SSD_CF - 1][itypeCat]) && (SegmentLobFound == 0))
      {
        for (idx = 0 ; idx < sizeTableau; idx++) /* Updated for Phase1b Migration */
        {
          if (atoi(pCS[idx].db_pat.SSD_CF) == SSD_CF)
          {
            if ((pCS[idx].db_pat.SEG_NF[0] == '*') && (pCS[idx].db_pat.UWY_NF == uwy ) )
            {
              if (strncmp(typecat, pCS[idx].db_pat.PATTYP_CT, 5) == 0 )
              {
                retour = idx;
                PATTERN_ID[0] = '\0';
                return retour;
                break;
              }
            }
          }
        }
      }
    }
  }
  retour = (SegmentLobFound == 0) ? retour : SegmentLobFound;
  return retour; // n'arrive que dans le cas du SEG_NF / LOB_CF trouvé , mais pas le bon UWY_NF
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

  if (n_OpenFileAppl("ESTC1056_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
  char   buf[LONGBUF];  // pour le buffer de sortie
  char   buf2[LONGBUF];
  double amount ;       // montant du fichier cumul
  double totalInterm ;
  double totalRMNTP ;
  double calcul, tx0, tx1, reliquat, coeff1, coeff2;       // variable pour stocker le resultat de trimesrialisation
  double txCSF[PATTERNSII_ANNEES];
  int    idx ;               // pour l'index du tableau de cashflow
  size_t isTypeSEG;
  char   jointure [100];
  T_FPATTERNSII_JOIN2   pCS;
  char   pattyp[6] ;
  int    lastYear;    // flag pour vérifier donner la dernière année de montant > 0

  DEBUT_FCT("n_ActionLigneRfrBatchIN");

  char  colonnevide[PATTERNSII_ANNEES];
  int x = 0;
  int i_an = 0;
  /* ajouté le 12/09/2012 pour la gestion des "*" dans les CUMULATIVE
  La règle est la suivante :
  si la courbe de pattern est une courbe accept, dans ce cas on doit vérifier le SEG_NF et l'année ( Prop. et Non Prop.)
  si on est en Retro , on vérifie le SEG_NF et l'UWY_NF retro pour le Prop., sinon La LOB_CF et l'UWY_NF Retro pour Non Prop.

  si LOB_CF ou SEG_NF contient des étoiles ("*" ) il faudra alors faire la jointure entre le PATTYP du pattern, et la nouvelle colonne PATTYP du GT
  permettant ainsi de savoir la SEGNAT_CT et le PATTYP_CT.
  */
  //ptb_InRec_Cur contient la ligne courante avec le contenu des colonnes du cashflow
  memset(pattyp, 0, sizeof(pattyp));
  memset(jointure, 0, sizeof(jointure));
  memset(colonnevide, '~', sizeof(colonnevide));
  colonnevide[PATTERNSII_ANNEES - 1] = 0;
  memset(buf , 0, sizeof(buf));
  memset(buf2 , 0, sizeof(buf2));
  // [003] Pour les patterns ICR, les 2 premieres lettre du pattyp sont IC
  // PRACC, PRRET, CLACC et CLRET pour CSF, mais ICACC et ICRET pour les ICR
  // Aussi quand on est en pattern ICR, on remplace les 2 premiers caracteres du PATTYP par IC
  if ( (strcmp(pattern_category, "ICR  ") == 0) || (strcmp(pattern_category, "ICR") == 0) ) {
    if (strlen(ptb_InRec_Cur[CML_PATTYP_1056]) >= 2) {
      ptb_InRec_Cur[CML_PATTYP_1056][0] = 'I';
      ptb_InRec_Cur[CML_PATTYP_1056][1] = 'C';
    }
    strcpy(pattyp, ptb_InRec_Cur[CML_PATTYP_1056]);
  }
  else {
    strcpy(pattyp, ptb_InRec_Cur[CML_PATTYP_1056]);
  }

  strcpy(jointure, ptb_InRec_Cur [CML_JOINTURE_1056]);

  if (strlen(jointure) < 4 ) // donc on a une valeur "*" sans UWY_NF par exemple
  {
    n_WriteCols(Kp_OutputPatternBatchOut, ptb_InRec_Cur, '~' , 0) ;
    return OK; // on doit passer à la ligne suivante
  }


  if (strncmp(ptb_InRec_Cur[CML_TYP_CT], "A", 1) == 0)
  {
    // PATTYP_CT Accept , donc on prend la struc. SEG_NF
    isTypeSEG = 1;

    idx = getIndexCS((int) (PAT_AN_FIN + 1), jointure , pCS_SEG, sizeCS_SEG, pattyp, ptb_InRec_Cur [CML_SSD_CF]);
    if (idx < 0 )
    {
      //on n'a pas trouvé de pattern pour l'UWY_NF , mais le SEG_NF a déjà été traité,
      // il faut donc mettre le montant dans l'année 1 et s'arrêter là
      amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);
      // D'abord "l'entête"
      sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
      // on va copier en boucle en partant de la 2e colonne
      for (x = CML_ESB_CF ; x < CML_PATTYP_1056 ; x++) /* Updated for Phase1b Migration */
      {
        sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[x]) ;
      }
      // on ajoute la colonne NORME_CF ( fixe et vide)
      // et le reste des colonnes de cash flow , NF pour Not found dans la colonne RATING_CF
      strcpy(buf2, buf);
      sprintf(buf, "%s~~~%s~%s~%s" , buf, pattern_category, ptb_InRec_Cur [CML_PATTYP_1056] , " "  ); // pattern_type passé en paramètre
      sprintf(buf, "%s~%.3f~%s", buf, amount, colonnevide);
      // Ajout de 4 colonnes d'info / commentaires
      sprintf(buf, "%s~~Pattern non trouvee~%.3f", buf, amount);
      // Ecriture de la ligne courante
      fprintf(Kp_OutputFileRfrBatchOut, "%s\n", buf);
      // la meme chose pour le remaining to pay ULAE
      amount = 0;
      sprintf(buf2, "%s~~~%s~%s~%s" , buf2, pattern_category, "RMNTP" , " "  ); // pattern_type passé en paramètre
      sprintf(buf2, "%s~%.3f~%s", buf2, amount, colonnevide);
      // Ajout de 4 colonnes d'info / commentaires
      sprintf(buf2, "%s~~Pattern non trouvee~%.3f", buf2, amount);
      if ((strcmp(ptb_InRec_Cur[CML_ACMTRS_NT], "3114") == 0) || (strcmp(ptb_InRec_Cur[CML_ACMTRS_NT], "3115") == 0))
      {
        //fprintf(Kp_OutputFileRMNTP, "%s\n",buf2);
      }
      return OK;
      //}
    }

    memcpy(&pCS, &pCS_SEG[idx], sizeof(pCS));
    // On identifie la ligne de pattern comme étant utilisée,
    // en mettant le flag used
    pCS_SEG[idx].used = 1;
  }
  else
  { // PATTYP_CT Retro
    // on vérifie si on doit prendre le SEG_NF ou la LOB_CF
    if (strncmp(ptb_InRec_Cur[CML_NAT_CF] , "P", 1) == 0)
    {
      // SEG_NF + retro
      isTypeSEG = 1 ;

      idx = getIndexCS((int) (PAT_AN_FIN + 1),  jointure, pCS_SEG, sizeCS_SEG, pattyp, ptb_InRec_Cur [CML_SSD_CF]);
      if (idx < 0)
      {
        //on n'a pas trouvé de pattern pour l'UWY_NF , mais le SEG_NF a déjà été traité,
        // il faut donc mettre le montant dans l'année 1 et s'arrêter là
        amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);
        // D'abord "l'entête"
        sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);

        // on va copier en boucle en partant de la 2e colonne
        for (x = CML_ESB_CF ; x < CML_PATTYP_1056 ; x++) /* Updated for Phase1b Migration */
        {
          sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[x]) ;
        }
        // on ajoute la colonne NORME_CF ( fixe et vide)
        // et le reste des colonnes de cash flow
        strcpy(buf2, buf);

        sprintf(buf, "%s~~~%s~%s~%s" , buf, pattern_category, ptb_InRec_Cur [CML_PATTYP_1056] , " "  ); //[003] pattern_type passé en paramètre
        sprintf(buf, "%s~%.3f~%s", buf, amount, colonnevide);
        // Ajout de 4 colonnes d'info / commentaires
        sprintf(buf, "%s~~Pattern non trouvee~%.3f", buf, amount);
        // Ecriture de la ligne courante
        fprintf(Kp_OutputFileRfrBatchOut, "%s\n", buf);

        sprintf(buf2, "%s~~~%s~%s~%s" , buf2, pattern_category, "RMNTP" , " "  ); // pattern_type passé en paramètre
        sprintf(buf2, "%s~%.3f~%s", buf2, amount, colonnevide);
        // Ajout de 4 colonnes d'info / commentaires
        sprintf(buf2, "%s~~Pattern non trouvee~%.3f", buf2, amount);

        //fprintf(Kp_OutputFileRMNTP, "%s\n",buf2);

        return OK;
        //}
      }

      memcpy(&pCS, &pCS_SEG[idx], sizeof(pCS));
      // On identifie la ligne de pattern comme étant utilisée,
      // en mettant le flag used
      pCS_SEG[idx].used = 1;
    }
    else
    {
      // LOB_CF + retro
      isTypeSEG =  0;
      idx = getIndexCS((int) (PAT_AN_FIN + 2),  jointure, pCS_LOB, sizeCS_LOB, pattyp, ptb_InRec_Cur [CML_SSD_CF]);
      if (idx < 0)
      {
        //on n'a pas trouvé de pattern pour l'UWY_NF , mais le SEG_NF a déjà été traité,
        // il faut donc mettre le montant dans l'année 1 et s'arrêter là
        amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);
        // D'abord "l'entête"
        sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
        // on va copier en boucle en partant de la 2e colonne
        for (x = CML_ESB_CF ; x < CML_PATTYP_1056 ; x++) /* Updated for Phase1b Migration */
        {
          sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[x]) ;
        }

        strcpy(buf2, buf);

        sprintf(buf, "%s~~~%s~%s~%s" , buf, pattern_category, ptb_InRec_Cur [CML_PATTYP_1056] , " " ); //[003] pattern_type passé en paramètre
        sprintf(buf, "%s~%.3f~%s", buf, amount, colonnevide);
        // Ajout de 4 colonnes d'info / commentaires
        sprintf(buf, "%s~~Pattern non trouvee~%.3f", buf, amount);
        // Ecriture de la ligne courante
        fprintf(Kp_OutputFileRfrBatchOut, "%s\n", buf);

        sprintf(buf2, "%s~~~%s~%s~%s" , buf2, pattern_category, "RMNTP" , " "  ); // pattern_type passé en paramètre
        sprintf(buf2, "%s~%.3f~%s", buf2, amount, colonnevide);
        // Ajout de 4 colonnes d'info / commentaires
        sprintf(buf2, "%s~~Pattern non trouvee~%.3f", buf2, amount);

        //fprintf(Kp_OutputFileRMNTP, "%s\n",buf2);
        return OK;

        //}
      }

      memcpy(&pCS, &pCS_LOB[idx], sizeof(pCS));
      // On identifie la ligne de pattern comme étant utilisée,
      // en mettant le flag used
      pCS_LOB[idx].used = 1;
    }
  }


  //2 cas possibles : NAT P et N  avec TYP A (Accept) , ou NAT P et PATTYP_CT R (retro) => comparaison avec colonnes cash flow de jointure (56 et 57)
  // on utilisera en sortie la structure LOB_CF ou SEG_NF que l'on a déjà chargé

  amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);

  // D'abord "l'entête"
  sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);

  // on va copier en boucle en partant de la 2e colonne
  for (x = CML_ESB_CF ; x < CML_PATTYP_1056 ; x++)
  {
    sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[x]) ;
  }

  strcpy(buf2, buf) ; // on fait une copie du buffer de sortie pour les rmntp
  // on ajoute la colonne NORME_CF ( fixe et vide)
  // et le reste des colonnes de cash flow
  sprintf(buf, "%s~%s~%s~%s~%s~%s" ,
          buf,
          "" , // NORME_CF
          pCS.db_pat.RATING_CF ,  //
          pCS.db_pat.PATCAT_CT , // PATCAT
          pCS.db_pat.PATTYP_CT  , //
          pCS.db_pat.PATTERN_ID
         );

  sprintf(buf2, "%s~%s~%s~%s~%s~%s" ,
          buf2,
          "" , // NORME_CF
          pCS.db_pat.RATING_CF ,  //
          pCS.db_pat.PATCAT_CT , // PATCAT
          "RMNTP"  , //
          pCS.db_pat.PATTERN_ID
         );




  // Puis la liste des taux calculés
  // On va prendre la trimestrialisation pour les 2 premières années

  lastYear = -1 ;
  tx0 = pCS.db_pat.AN[0];
  tx1 = pCS.db_pat.AN[1];

  if (Quarter == 4)
  {
    coeff1 = 1.0 ;
    coeff2 = 0.0 ;
  }
  else
  {
    coeff1 = (4 - Quarter) / 4.0;
    coeff2 = Quarter / 4.0 ;
  }

  calcul = amount * ((tx0 * coeff1) + (tx1 * coeff2)) ;
//  reliquat = tx0 - ((tx0 * coeff1) + (tx1 * coeff2));
  reliquat = 1  - (tx0 * coeff2) ;
  calcul = calcul / ((reliquat == 0) ? 1 : (reliquat)) ;

  txCSF[0] = calcul ;


  //calcul = amount * (tx1+ reliquat);
  //txCSF[1] = calcul ;

  if (txCSF[0] == 0)
  {
    lastYear = 1;
  }
  else
  {
    if (txCSF[1] == 0)
    {
      lastYear = 2;
    }
  }


  // on fait les années suivantes
  for (i_an = 1; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
  {
    //calcul = amount * pCS.an[i_an];
    calcul = amount * ((coeff1 * pCS.db_pat.AN[i_an]) + (coeff2 * ( (i_an == (PATTERNSII_ANNEES - 1)) ? 0 :  pCS.db_pat.AN[i_an + 1])));
    calcul = calcul / ((reliquat == 0) ? 1 : (reliquat)) ;
    txCSF[i_an] = calcul ;
    if ((calcul + lastYear) == -1)
    {
      lastYear = i_an + 1; // on flag la dernière année avec des montant
    }
  }

  if (lastYear == -1)
  {
    lastYear = PATTERNSII_ANNEES;
  }

  totalInterm = 0 ;  //  pour le calcul des sommes des PATTERNSII_ANNEES années
  for (i_an = 0; i_an < (PATTERNSII_ANNEES - 1) ; i_an++) /* Updated for Phase1b Migration */
  {
    totalInterm += txCSF[i_an] ;
  }
  txCSF[lastYear - 1] +=  amount - totalInterm ;


  //
  for (i_an = 0; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
  {
    sprintf(buf, "%s~%.3f", buf, txCSF[i_an]);
  }

  amount = 0;
  totalRMNTP = 0;

  for (i_an = 0; i_an < PATTERNSII_ANNEES ; i_an++)
  {
    for (x = i_an + 1; x < PATTERNSII_ANNEES; x++)
    {
      amount += txCSF[x] ;
    }
    sprintf(buf2, "%s~%.3f", buf2, amount);
    totalRMNTP += amount ;
    amount = 0;
  }

  // ajout de 3 colonnes vides + total de l'année
  // Ecriture de la ligne courante
  fprintf(Kp_OutputFileRfrBatchOut, "%s~~~~%.3f\n", buf, totalInterm );
  if ((strncmp(ptb_InRec_Cur[CML_TYP_CT], "A", 1) == 0) && ((strcmp(ptb_InRec_Cur[CML_ACMTRS_NT], "3114") == 0) || (strcmp(ptb_InRec_Cur[CML_ACMTRS_NT], "3115") == 0)))
  {
    fprintf(Kp_OutputFileRMNTP, "%s~~~~%.3f\n", buf2, totalRMNTP);
  }

  return OK;
}

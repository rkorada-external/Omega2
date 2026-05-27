/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1071A.c
 Date de creation              : 22/06/2015
 References des specifications : EST49  Spot 28941
 Squelette de base             : batch
 Auteur                        : FMA
------------------------------------------------------------------------------
  Description : Application de la la pattern INF/INF sur le fichier remain to pay
   Loader programs V2
------------------------------------------------------------------------------
      Historique des modifications :
[01] -=Dch=- 15/06/2015 :spot:28941 SOLVENCY II - ULAE
[02] Florent 13/05/2016 :spot:30543 on passe à 65 années
[03] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
[04] 09/01/2020 KBagwe  :#82575:REQ22.1 - ULAE
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC3001A.h"

/*------------*/
/* Constantes */
/*------------*/

/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC1057_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputCurrency;
FILE *Kp_InputRemainToPay;

FILE *Kp_InputPattern ;
FILE *Kp_OutputBatch;
FILE *Kp_OutputRemainToPay;
FILE *Kp_OutputStats;
FILE *Kp_OutputErr;

// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF et LOB_CF
T_FPATTERNSII_JOIN * pDiscount;
T_DEVISE  * pDevise;

void ChargementDiscount();
void ChargementCurrency();
int n_InitRfrBatchIN(T_RUPTURE_VAR  *pbd_Rupt);
long getFileNbLigne(FILE * fl) ;
int GetTblPatternDiscount( const char * devise, T_FPATTERNSII_JOIN **pattern, int *index);
char** split(char* chaine, const char* delim, int vide);
void freeTableau(char** tab);
int n_ActionLigneRfrBatchIN(char **ptb_InRec_Cur);

long    lignes = 0;

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

  if (n_OpenFileAppl("ESTC1071A_O1", "wt", &Kp_OutputRemainToPay)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier sortie REMAINTOPAY. " );

  if (n_OpenFileAppl("ESTC1071A_I3", "rt", &Kp_InputPattern) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de cashflow." );
  if (n_OpenFileAppl("ESTC1071A_I2", "rt", &Kp_InputCurrency) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de CUR_CF." );

  //Chargement des CUR_CF dans un tableau
  ChargementCurrency();
  // on peut fermer le fichier , les donnees sont dans pDevise
  if (n_CloseFileAppl("ESTC1071A_I2", &Kp_InputCurrency))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Devise (CUR_CF).");
  //
  //chargement des cashflow dans un tableau
  ChargementDiscount();

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  if (n_CloseFileAppl("ESTC1071A_I1", &Kbd_ruptRfrBatchIN.pf_InputFil))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC1071A_I3", &Kp_InputPattern))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Pattern Discount.");
  if (n_CloseFileAppl("ESTC1071A_O1", &Kp_OutputRemainToPay))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier sortie RemainToPay.");

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

  if (nb_Devise > 0 )
  {
    //on retaille le tableau de devise
    pDevise = malloc( nb_Devise * sizeof (T_DEVISE));

    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputCurrency) != NULL)
    {
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
  int i = 0;
  for (i = 0; tab[i] != NULL; i++)
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
  if( strncmp(tab[PAT_NORME_CF],"ALLNO",5) != 0){
	  return;
  }
  int j = 0;

  strcpy(pDiscount[idx].db_pat.SSD_CF, tab[PAT_SSD_CF]);
  strcpy(pDiscount[idx].db_pat.PATCAT_CT, tab[PAT_PATCAT_CT]);
  strcpy(pDiscount[idx].db_pat.PATTYP_CT, tab[PAT_PATTYP_CT]);
  strcpy(pDiscount[idx].db_pat.SEG_NF, tab[PAT_SEG_NF]);
  pDiscount[idx].db_pat.UWY_NF = atoi(tab[PAT_UWY_NF]);
  strcpy(pDiscount[idx].db_pat.CUR_CF, tab[PAT_CUR_CF]);
  strcpy(pDiscount[idx].db_pat.LOB_CF, tab[PAT_LOB_CF]);
  strcpy(pDiscount[idx].db_pat.RATING_CF, tab[PAT_RATING_CF]);
  strcpy(pDiscount[idx].db_pat.NORME_CF, tab[PAT_NORME_CF]);
  strcpy(pDiscount[idx].db_pat.SEGNAT_CT, tab[PAT_SEGNAT_CT]);
  pDiscount[idx].db_pat.BALSHEY_NF = atoi(tab[PAT_BALSHEY_NF]);
  strcpy(pDiscount[idx].db_pat.PATTERN_ID, tab[PAT_PATTERN_ID]);
  strcpy(pDiscount[idx].db_pat.CRE_D, tab[PAT_CRE_D]);
  strcpy(pDiscount[idx].db_pat.CREUSR_CF , tab[PAT_CREUSR_CF]);
  // TOTAUX ignoré
  pDiscount[idx].db_pat.PATTERN_ID[21] = 0;


  // on charge les PATTERNSII_ANNEES années
  for (j = 0; j < PATTERNSII_ANNEES; j++) /* Updated for Phase1b Migration */
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

  if (nb_Pattern > 0)
  {
    // on retaille le pointeur sur le tableau de pattern
    pDiscount = (T_FPATTERNSII_JOIN*) realloc(pDiscount, nb_Pattern *  sizeof(T_FPATTERNSII_JOIN)) ;

    while (fgets( buffer, LONGBUF, Kp_InputPattern) != NULL)
    {
      tab = split(buffer, SEPARATEUR_SPLIT , 1);
      if (strncmp( tab[PAT_NORME_CF], "ALLNO",5) == 0){		/* MOD[04] */
      	addPattern(tab, sizep);
      	sizep++;
      }
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

  if (n_OpenFileAppl("ESTC1071A_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

// Chargement d'un tableau de pattern pour une devise
int GetTblPatternDiscount( const char * devise, T_FPATTERNSII_JOIN **pattern, int *index)
{
  int lenCurr = strlen(devise);

  while (*index < nb_Pattern) /* Updated for Phase1b Migration */
  {
    if (strncmp(devise, pDiscount[*index].db_pat.CUR_CF, lenCurr) == 0)
    {
      *pattern = &pDiscount[*index];
      ++(*index);
      return 0;
    }
    // on retaille le pointeur sur le tableau de pattern
    ++(*index);
  }
  return 1;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchIN(char **ptb_InRec_Cur)
{
  char buf[LONGBUF];     // pour le buffer de sortie ESCOMPTE
  char buf2Pay[LONGBUF]; // pour le buffer de sortie REMAINTOPAY

  double  amount;
  double  calcul, total ; // montant du fichier cumul
  double  escompte[PATTERNSII_ANNEES];
  T_FPATTERNSII_JOIN *pDSC;
  char*     monnaie;
  char      CurrLob[21];
  int       acmtrs;
  int index = 0;
  char      ratingDevise[6];
  short col = 0 , i_an = 0;

  DEBUT_FCT("n_ActionLigneRfrBatchIN");

  //ptb_InRec_Cur contient la ligne courante
  // on va comparer le contenu de la colonne ptb_InRec_Cur[CML_CUR_CF]
  //avec le contenu des colonnes des patterns
  // on vérifie la LOB_CF
  memset(CurrLob , 0 ,sizeof(CurrLob));
  memset(buf, 0, sizeof(buf));
  memset(buf2Pay, 0, sizeof(buf2Pay));
  memset(ratingDevise , 0 , sizeof(ratingDevise));

  monnaie = malloc(sizeof(char) * 4);

  if (strlen(ptb_InRec_Cur [CML_ACMCUR_CF]))
  {
    // on récupère la devise de référence
    monnaie = GetDevisebyRef(ptb_InRec_Cur [CML_ACMCUR_CF]);
  }
  else
  {
    sprintf(monnaie, "%s", "EUR");
  }

  if (strlen(monnaie) != 0)
  {

    // test de la function GetPatternDiscount
    while (GetTblPatternDiscount(monnaie, &pDSC, &index) == 0)
    {
      if (pDSC != NULL)
      {
        // d'abord l'entête
        sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
        //puis tout le reste des colonnes qui précèdent les montants annuels

        // on va recopier le buffer qui contient les premières colonnes
        sprintf(buf2Pay, "%s", buf);

        // Puis la liste des taux calculés
        // on va d'abord la 1er année ( an 0)

        escompte[0] = pDSC->db_pat.AN[0] *  atof(ptb_InRec_Cur[CML_AN1]);

        calcul = 0;
        amount = atof(ptb_InRec_Cur[CML_ACMAMT_MC]);

        //sprintf(buf2Pay, "%s~%.3f", buf2Pay, escompte[0]);

        for (i_an = 1; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
        {
          calcul = pDSC->db_pat.AN[i_an] *  atof(ptb_InRec_Cur[CML_AN1 + i_an]);
          escompte[i_an] = calcul;
          // on va stocker le résultat de chaque année pour le calcul du cumul rmpt
        }

        for (col = 1; col <= CML_TYP_CT; col++) /* Updated for Phase1b Migration */
        {
          if (col == CML_ACMTRS_NT)
          {

            acmtrs = atoi(ptb_InRec_Cur[CML_ACMTRS_NT]) + 0; // pour RMTP
            sprintf(buf2Pay, "%s~%d", buf2Pay, acmtrs);
          }
          else if (col == CML_ACMAMT_MC)
          {
            sprintf(buf2Pay, "%s~%s", buf2Pay, ptb_InRec_Cur[CML_TOTAUX_MC]);
          }
          else
          {
            sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
            if (col != CML_ACMTRS_NT && col != CML_ACMAMT_MC)
            {
              sprintf(buf2Pay, "%s~%s", buf2Pay, ptb_InRec_Cur[col]);
            }
          }
        }

        // et le reste des colonnes de Discount
        sprintf(buf2Pay, "%s~%s~%s~CSF~INF~%s",
                buf2Pay,
                pDSC->db_pat.NORME_CF,
                pDSC->db_pat.RATING_CF,
                pDSC->db_pat.PATTERN_ID
               );

        // Puis la liste des taux calculés

        total = 0;
        calcul = 0;

        for (col = 0; col < PATTERNSII_ANNEES; col++) /* Updated for Phase1b Migration */
        {
          calcul = escompte[col];
          total += calcul;
          sprintf(buf2Pay, "%s~%.3f", buf2Pay, calcul);
        }
		//[03] add ACMTRS3 at the end of te file 
        fprintf(Kp_OutputRemainToPay, "%s~%s~%s~~%.3f~%s\n", buf2Pay, CurrLob, monnaie, total,ptb_InRec_Cur[CML_ACMTRS3_NT2] );
      }
    }
  }

  return OK;
}

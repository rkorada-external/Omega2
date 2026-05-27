/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3001.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :  Sélectionner les patterns unique
------------------------------------------------------------------------------
Historique des modifications :
          Date   Auteur  Description
[01]  01/06/2012 -=Dch=- :spot:23937
[02]  30/07/2012 -=Dch=- :spot:24041 ajout Err si courbe < 0
[03]  20/10/2014 Florent :spot:27789 pour agrandir le nombre de lignes dans le tableau des patterns et maj de la structure
[04]  28/04/2015 Florent :spot:26391 gestion de l'année bilan pour la clef de la recherche des doublons
[05]  11/06/2015 Florent :spot:28941 gestion des patterns inflated
[06]  13/05/2016 Florent :spot:30543 on passe à 65 années
[07]  09/03/2022 Charles SPIRA 102327 IFRS 17 - REQ 3.3.1 - DSI curves not loaded when multiple subledgers is loaded on the same subsidiary add new input type de fichier
==============================================================================*/
/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "ESTC3001.h"

/*--------------------------------------------------*/
/* Prototype des fonctions              */
/*--------------------------------------------------*/
int n_InitRfrBatchINArchive(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRfrBatchINArchive(char **pbd_InRec_Cur);
int n_InitRfrBatchINCourant(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRfrBatchINCourant(char **pbd_InRec_Cur);
void Upper(char * str);

/*-----------------------------------*/
/* Definition des variables globales */
/*-----------------------------------*/
T_RUPTURE_VAR Kbd_ruptRfrBatchINArchive;
T_RUPTURE_VAR Kbd_ruptRfrBatchINCourant;
FILE *Kp_OutputFileRfrBatchOutArchive;
FILE *Kp_OutputTrace;

extern int Ksz_Argc ;
T_FPATTERNSII *kpbd_patterns; //pour écrire les duplications pour TPATSEGSII
T_FPATTERNSII_CLE *kpbd_patterns_cle;
long nb_patterns;
int  compteur = 1; // début de numérotation pour la clé d'indexation

long Kl_Pattern_max;
char    type_fichier[5]; // type de fichier 
char Ksz_MessageErr[256]; /* Message d'erreur */

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
  //  printf("debut de traitement avec argc=%d \n",argc);
  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  //Le nombre de patterns à traiter/stocker
  Kl_Pattern_max = atoi(psz_GetCharArgv(1));
     if (Ksz_Argc == 2)
  { 
		strcpy(type_fichier, psz_GetCharArgv(2));
  }
  
  nb_patterns = 0;
  kpbd_patterns = (T_FPATTERNSII*)calloc((size_t)Kl_Pattern_max, sizeof(T_FPATTERNSII));
  if (kpbd_patterns == NULL)
  {
    sprintf(Ksz_MessageErr, "Impossible to allocate space for %ld patterns", Kl_Pattern_max);
    ExitPgm(ERR_XX, Ksz_MessageErr);
  }
  kpbd_patterns_cle = (T_FPATTERNSII_CLE*)calloc((size_t)Kl_Pattern_max, sizeof(T_FPATTERNSII_CLE));
  if (kpbd_patterns == NULL)
  {
    sprintf(Ksz_MessageErr, "Impossible to allocate space for %ld patterns keys", Kl_Pattern_max);
    ExitPgm(ERR_XX, Ksz_MessageErr);
  }

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC3001_O1", "wt", &Kp_OutputFileRfrBatchOutArchive)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du premier fichier d'output." );
  if (n_OpenFileAppl("ESTC3001_O2", "wt", &Kp_OutputTrace)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du second fichier d'output." );
  //------------------------
  // Chargement de l'archive
  //------------------------
  // REMARQUE: Le fichier en entrée est censé être trié par ordre de courbe de taux croissante
  //------------------------

  // Initialisation des variables de gestion de ruptures pour l'archive des patterns
  if (n_InitRfrBatchINArchive(&Kbd_ruptRfrBatchINArchive)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchINArchive");

  // Alimentation de l'archive des patterns
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchINArchive) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne de l'archive des patterns." );

  //------------------------------------------------------------------------------------------
  // Report des segments ou lobs de l'archive
  // Remarque: En revanche, le pattern de l'archive n'est pas écrit dans le fichier en sortie
  //------------------------------------------------------------------------------------------
  //

  //---------------------------------------------
  // Prise en compte du fichier des taux courants
  //---------------------------------------------

  // Initialisation des variables de gestion de ruptures pour le fichier des taux courants
  if (n_InitRfrBatchINCourant(&Kbd_ruptRfrBatchINCourant)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchINCourant");

  // Traitement du fichier des taux courants
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchINCourant) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne du fichier des taux courants." );

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC3001_I1", &(Kbd_ruptRfrBatchINArchive.pf_InputFil))) ExitPgm(ERR_XX, "Problème lors de la fermeture du premier fichier d'input.");
  if (n_CloseFileAppl("ESTC3001_I2", &(Kbd_ruptRfrBatchINCourant.pf_InputFil))) ExitPgm(ERR_XX, "Problème lors de la fermeture du second fichier d'input.");

  if (n_CloseFileAppl("ESTC3001_O1", &Kp_OutputFileRfrBatchOutArchive)) ExitPgm(ERR_XX, "Problème lors de la fermeture du premier fichier d'output.");
  if (n_CloseFileAppl("ESTC3001_O2", &Kp_OutputTrace)) ExitPgm(ERR_XX, "Problème lors de la fermeture du troisieme fichier de trace.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  free ( kpbd_patterns );
  Kl_Pattern_max = 0;

  exit(OK);
}

/*==============================================================================
 Objet :            Met en Majuscule la chaine de caractère fournit en parametre
 Parametre(s) :     Pointeur sur une chaine de caractère
==============================================================================*/
void Upper(char * str)
{
  char * p;
  for (p = str; *p != '\0'; ++p)
  {
    *p = toupper(*p);
  }
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchINArchive(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC3001_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchINArchive;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchINArchive(char **ptb_InRec_Cur)
{
  char  buf[TAILLE_PATTERNSII_TAUX];
  int   i;

  DEBUT_FCT("n_ActionLigneRfrBatchINArchive");

  // Si le tableau des patterns n'est pas rempli
  // alors on ajoute le pattern courant
  if (nb_patterns < Kl_Pattern_max)
  {
    // Mémorisation du pattern courant dans l'archive et on stock uniquement ce qu'on a besoin pour TPATSEGSII
    strcpy(kpbd_patterns[nb_patterns].SSD_CF, ptb_InRec_Cur[PAT_SSD_CF]);
    strcpy(kpbd_patterns[nb_patterns].PATCAT_CT, ptb_InRec_Cur[PAT_PATCAT_CT]);
    strcpy(kpbd_patterns[nb_patterns].PATTYP_CT, ptb_InRec_Cur[PAT_PATTYP_CT]);
    strcpy(kpbd_patterns[nb_patterns].SEG_NF, ptb_InRec_Cur[PAT_SEG_NF]);
    strcpy(kpbd_patterns[nb_patterns].CUR_CF, ptb_InRec_Cur[PAT_CUR_CF]);
    strcpy(kpbd_patterns[nb_patterns].LOB_CF, ptb_InRec_Cur[PAT_LOB_CF]);
    strcpy(kpbd_patterns[nb_patterns].RATING_CF, ptb_InRec_Cur[PAT_RATING_CF]);
    strcpy(kpbd_patterns[nb_patterns].NORME_CF, ptb_InRec_Cur[PAT_NORME_CF]);
    strcpy(kpbd_patterns[nb_patterns].SEGNAT_CT, ptb_InRec_Cur[PAT_SEGNAT_CT]);
    strcpy(kpbd_patterns[nb_patterns].PATTERN_ID, ptb_InRec_Cur[PAT_PATTERN_ID]);
    strcpy(kpbd_patterns[nb_patterns].CRE_D, ptb_InRec_Cur[PAT_CRE_D]);
    strcpy(kpbd_patterns[nb_patterns].CREUSR_CF, ptb_InRec_Cur[PAT_CREUSR_CF]);

    // Mise en forme à 8 décimales et concaténation des années de taux pour la clé
    memset(buf, 0, sizeof(buf));
    for (i = PAT_AN1; i <= PAT_AN_FIN; i++)
    {
      if (strlen(buf) == 0)
      {
        sprintf(buf, "%.8f", atof(ptb_InRec_Cur[i]));
      }
      else
      {
        sprintf(buf, "%s~%.8f", buf, atof(ptb_InRec_Cur[i]));
      }
    }

    //On fait actuellement sur ces colonnes :
    //Règle fournie le 7/06/2012 --ppz
    //Pour le dé doublonnage, l’objectif, c’est que pour une même clé, on ait pas les mêmes pattern chargées plusieurs fois
    //Comme clé, j’entends SSD_CF / SEG_NF / LOB_CF / DEVISE / NORME_CF / PATTYP_CT
    // Ajouts Florent 23/10/2012
    sprintf(kpbd_patterns_cle[nb_patterns].cle, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s",
            ptb_InRec_Cur[PAT_SSD_CF],
            ptb_InRec_Cur[PAT_PATCAT_CT],
            ptb_InRec_Cur[PAT_PATTYP_CT],
            ptb_InRec_Cur[PAT_SEG_NF],
            ptb_InRec_Cur[PAT_CUR_CF],
            ptb_InRec_Cur[PAT_LOB_CF],
            strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_DISCILLIQ, sizeof(PATTYP_DISCILLIQ)) == 0 ? "" : ptb_InRec_Cur[PAT_RATING_CF],
            ptb_InRec_Cur[PAT_NORME_CF],
            ptb_InRec_Cur[PAT_SEGNAT_CT],
            strstr(PATCAT_CUMULATIVE_INCURRED, ptb_InRec_Cur[PAT_PATCAT_CT]) == NULL ? "" : ptb_InRec_Cur[PAT_BALSHEY_NF],
            buf);
			
	if ( strcmp(type_fichier,"DSC") == 0 ){
		sprintf(kpbd_patterns_cle[nb_patterns].cle, "%s~%s", kpbd_patterns_cle[nb_patterns].cle, ptb_InRec_Cur[PAT_ESB_CF]);
	}
    // Incrémentation du nombre de patterns mémorisés
    nb_patterns++;
  }
  else
  {
    sprintf(Ksz_MessageErr, "Number of patterns max %ld too small for patterns to load %ld", Kl_Pattern_max, nb_patterns);
    ExitPgm(ERR_XX, Ksz_MessageErr);
  }
  return OK;
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchINCourant(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC3001_I2", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchINCourant;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchINCourant(char **ptb_InRec_Cur)
{
  T_FPATTERNSII*  archive;
  char   sz_courbe_courante[TAILLE_CLE_PATTERNSII];
  char   sz_Date[11];
  char   sz_Heure[11];
  char   sz_PATTERN_ID[22];
  int    i = 0;
  char   sLettre = 'Z';
  int    Yet = -1 ;
  int    j = 0;
  DEBUT_FCT("n_ActionLigneRfrBatchINCourant");

  // Récupération de la date système
  memset(sz_Date, 0, sizeof(sz_Date));
  memset(sz_Heure, 0, sizeof(sz_Heure));
  memset(sz_courbe_courante, 0, sizeof(sz_courbe_courante));

  //On fait actuellement sur ces colonnes :
  //Règle fournie le 7/06/2012 --ppz
  //Pour le dé doublonnage, l’objectif, c’est que pour une même clé, on ait pas les mêmes pattern chargées plusieurs fois
  //Comme clé, j’entends SSD_CF / SEG_NF / LOB_CF / DEVISE / NORME_CF / PATTYP_CT
  // Ajouts Florent 23/10/2012
  sprintf(sz_courbe_courante, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.8f",
          ptb_InRec_Cur[PAT_SSD_CF],
          ptb_InRec_Cur[PAT_PATCAT_CT],
          ptb_InRec_Cur[PAT_PATTYP_CT],
          ptb_InRec_Cur[PAT_SEG_NF],
          ptb_InRec_Cur[PAT_CUR_CF],
          ptb_InRec_Cur[PAT_LOB_CF],
          strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_DISCILLIQ, sizeof(PATTYP_DISCILLIQ)) == 0 ? "" : ptb_InRec_Cur[PAT_RATING_CF],
          ptb_InRec_Cur[PAT_NORME_CF],
          ptb_InRec_Cur[PAT_SEGNAT_CT],
          strstr(PATCAT_CUMULATIVE_INCURRED, ptb_InRec_Cur[PAT_PATCAT_CT]) == NULL ? "" : ptb_InRec_Cur[PAT_BALSHEY_NF],
          atof(ptb_InRec_Cur[PAT_AN1]));

  // Mise en forme à 8 décimales et concaténation des années de taux pour la clé
  for (j = PAT_AN1 + 1; j <= PAT_AN_FIN; j++)
  {
    sprintf(sz_courbe_courante, "%s~%.8f", sz_courbe_courante, atof(ptb_InRec_Cur[j]));
  }
  
  if( strcmp(type_fichier,"DSC") == 0){
	sprintf(sz_courbe_courante, "%s~%s", sz_courbe_courante, ptb_InRec_Cur[PAT_ESB_CF]);
  }

  // Recherche de la courbe de taux courante dans l'archive
  // si pas de pattern chargé ( archive vide par exemple )
  // on passe à la phase suivante
  if (nb_patterns > 0 )
  {
    for (i = 0; i < nb_patterns; i++)
    {
      // On sort dès qu'on a trouvé la courbe courante dans l'archive
      if (!strcmp(kpbd_patterns_cle[i].cle, sz_courbe_courante))
      {
        Yet = i;
        break;
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------------
  // Si on n'a pas trouvé la courbe de taux courante dans l'archive alors on doit l'ajouter et écrire le SEG_NF correspondant
  //--------------------------------------------------------------------------------------------------------------------------
  // (soit on a parcouru tout le tableau sans succès, soit le tableau n'est pas complet et on n'a pas trouvé la courbe courante)
  // soit le fichier de pattern est vide
  if (Yet == -1)
  {
    //-----------------------------------------------------------------------
    // Détermination du PATTERN_ID de la courbe de taux à ajouter à l'archive
    //-----------------------------------------------------------------------
    Upper(ptb_InRec_Cur[PAT_PATTYP_CT]);
    Upper(ptb_InRec_Cur[PAT_PATCAT_CT]);
    if (strncmp(ptb_InRec_Cur[PAT_PATCAT_CT], PATCAT_INCURRED, sizeof(PATCAT_INCURRED)) == 0) sLettre = 'I';
    if (strncmp(ptb_InRec_Cur[PAT_PATCAT_CT], PATCAT_BAD_DEBT, sizeof(PATCAT_BAD_DEBT)) == 0) sLettre = 'B';
    if (strncmp(ptb_InRec_Cur[PAT_PATCAT_CT], PATCAT_CUMULATIVE, sizeof(PATCAT_CUMULATIVE)) == 0) sLettre = 'C';
    if (strncmp(ptb_InRec_Cur[PAT_PATCAT_CT], PATCAT_DISCOUNT, sizeof(PATCAT_DISCOUNT)) == 0)
    {
      if (strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_DISCILLIQ, sizeof(PATTYP_DISCILLIQ)) == 0) sLettre = 'S';
      if (strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_DISCOUNT, sizeof(PATTYP_DISCOUNT)) == 0) sLettre = 'D';
      if (strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_ILLIQUIDITY, sizeof(PATTYP_ILLIQUIDITY)) == 0) sLettre = 'L';
    }
    if (strncmp(ptb_InRec_Cur[PAT_PATCAT_CT], PATCAT_INFLATION, sizeof(PATCAT_INFLATION)) == 0) sLettre = 'F';

    RecSysDate(sz_Date, sz_Heure);
    memset(sz_PATTERN_ID, 0, sizeof(sz_PATTERN_ID));
    sprintf(sz_PATTERN_ID, "%s%s%d%c", sz_Date, sz_Heure, compteur, sLettre);
    compteur++;

    //--------------------------------------------------------
    // Initialisation de la structure à ajouter dans l'archive
    //--------------------------------------------------------
    // après l'appel de fonction , n_ActionLigneRfrBatchINArchive
    // nb_patterns est incrémenté

    //-------------------------------------------------------------------------
    // Ajout du nouveau pattern dans l'archive (pour ne pas le créer deux fois)
    //-------------------------------------------------------------------------
    if (nb_patterns < Kl_Pattern_max)
    {
      n_ActionLigneRfrBatchINArchive (ptb_InRec_Cur);
      // on récupère un pointeur sur la dernière archive
      archive = &kpbd_patterns[nb_patterns - 1];
      strcpy(archive->PATTERN_ID, sz_PATTERN_ID);
      //création des traces pour les nouvelles DSI uniquement
      if ( strncmp(ptb_InRec_Cur[PAT_PATTYP_CT], PATTYP_DISCILLIQ, sizeof(PATTYP_DISCILLIQ)) == 0 )
      { //enregistre avec l'ancien PATTERN_ID
        fprintf(Kp_OutputTrace, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                ptb_InRec_Cur[PAT_CRE_D], // CLODAT_D
                PER_CF_NEW,
                ptb_InRec_Cur[PAT_SSD_CF],
                ptb_InRec_Cur[PAT_SEG_NF],
                ptb_InRec_Cur[PAT_LOB_CF],
                ptb_InRec_Cur[PAT_CUR_CF],
                ptb_InRec_Cur[PAT_NORME_CF],
                ptb_InRec_Cur[PAT_SEGNAT_CT],
                ptb_InRec_Cur[PAT_PATCAT_CT],
                ptb_InRec_Cur[PAT_PATTYP_CT],
                sz_PATTERN_ID,             //nouveau PATTERN_ID
                ptb_InRec_Cur[PAT_PATCAT_CT],
                PATTYP_DISCOUNT,
                ptb_InRec_Cur[PAT_PATTERN_ID], //ancien PATTERN_ID
                ptb_InRec_Cur[PAT_CREUSR_CF],
                ptb_InRec_Cur[PAT_CRE_D]);
      }

      //PATTERN_ID est le seul qu'on a besoin de modifier pour l'insert dans TPATTERNSII, car la création du PATTERN_ID se fait dans ce programme
      ptb_InRec_Cur[PAT_PATTERN_ID] = sz_PATTERN_ID;
      n_WriteCols(Kp_OutputFileRfrBatchOutArchive, ptb_InRec_Cur, SEPARATEUR, 0);
    }
    //-------------------------------------------------------------------
    // Sortie en erreur quand on a déjà atteint le nombre max de patterns
    //-------------------------------------------------------------------
    else
    {
      sprintf(Ksz_MessageErr, "Number of patterns max %ld too small for new patterns to load %ld", Kl_Pattern_max, nb_patterns);
      ExitPgm(ERR_XX, Ksz_MessageErr);
    }
  }
  //--------------------------------------------------------------------------
  // Sinon on a trouvé la courbe de taux courante dans l'archive et on ne doit
  // créer que le SEG_NF pointant sur le PATTERN_ID trouvé dans l'archive
  //--------------------------------------------------------------------------
  else
  {
    //Pas de trace de DUPLI pour le fichier Bad debt et discount illiquidity 
    if (   strncmp(kpbd_patterns[Yet].PATCAT_CT, PATCAT_BAD_DEBT, sizeof(PATCAT_BAD_DEBT)) != 0
        && strncmp(kpbd_patterns[Yet].PATTYP_CT, PATTYP_DISCILLIQ, sizeof(PATTYP_DISCILLIQ)) != 0 )
    {
      fprintf(Kp_OutputTrace, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
              ptb_InRec_Cur[PAT_CRE_D], // CLODAT_D
              PER_CF_DUPLI,
              kpbd_patterns[Yet].SSD_CF ,
              kpbd_patterns[Yet].SEG_NF,
              kpbd_patterns[Yet].LOB_CF ,
              kpbd_patterns[Yet].CUR_CF,
              kpbd_patterns[Yet].NORME_CF,
              kpbd_patterns[Yet].SEGNAT_CT,
              kpbd_patterns[Yet].PATCAT_CT,
              kpbd_patterns[Yet].PATTYP_CT,
              kpbd_patterns[Yet].PATTERN_ID,
              "",
              "",
              "",
              kpbd_patterns[Yet].CREUSR_CF,
              kpbd_patterns[Yet].CRE_D);
    }
  }
  return OK;
}

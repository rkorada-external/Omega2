/*==============================================================================
 Nom de l'application          : Prepare the aggregation for Calculation 
 Nom du source                 : ESTC2065.c
 Revision                      : $Revision: 0 $
 Date de creation              : 07/03/2019
 Auteur                        : Charles SOCIE
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Prepare the aggregation for Calculation
   Req 10.14 spira 77467 Group Cashflow for discount
------------------------------------------------------------------------------
     Historique des modifications :
[001] HR SPIRA 82685 : struct.h
[002]	30/06/2020	Charles SOCIE	SPIRA 87793 REQ10.14 - Impacts new configuration
[003]	09/11/2023	JYP/Florian	SPIRA 110485 : produce many outputs by ACMTRS
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC3001A.h"

/*----------------------------------------*/
static char VERSION_ESTC2065_C[150] = "__version__: ESTC2065.c version [003] 09/11/2023 apply FRSMAP setup" ;


/*--------------------------------------------------*/
/* Prototype des fonctions                          */
/*--------------------------------------------------*/
int   n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int   n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
void ChargementACMTRS();
long  getFileNbLigne(FILE * fl);
void  freeTableau(char** tab);
char** split(char* chaine, const char* delim, int vide);
int  MAX_DUPLICATE = 3; // for performence , need limit 
//définition des variables global 



/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
int nb_Acmtrs;

#define LGTH_SEGEST 100
#define SEPARATOR 	 "~"

/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC2065_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputAcmtrs ;
FILE *Kp_OutputBatch;

// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF et LOB_CF
T_FPATTERNSII_JOIN * pDiscount;
T_TPRSMAP * pAcmtrs;


long  lignes = 0; 

//void     ExtractLineCSWithNoSync();      // sortie des pattern cash flow non utilisée
/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
int nb_Devise = 0 ; // pour stocker le nombre de devise chargée dynamiquement
int nb_RIndex = 0 ; // pour stocker le nombre de Rate index chargée dynamiquement
int nb_LineACMTRS = 0;
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

  printf("Running with %s  \n", VERSION_ESTC2065_C);

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC2065_O1", "wt", &Kp_OutputBatch)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 1er fichier (ESCOMPTE)." );
   
  
  // Ouverture du fichier de cash flow ( pattern incrementales )
  if (n_OpenFileAppl("ESTC2065_I2", "rt", &Kp_InputAcmtrs) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier des ACMTRS." );
  
  //Chargement des CUR_CF dans un tableau
  ChargementACMTRS();

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  // Fermeture des fichiers ouverts

  if (n_CloseFileAppl("ESTC2065_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC2065_I2", &Kp_InputAcmtrs))  ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier des ACMTRS.");
  if (n_CloseFileAppl("ESTC2065_O1", &Kp_OutputBatch))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");


  // libération mémoire
  free(pAcmtrs);
  exit(OK);

}

/* ----------------------------------------------------------------------------*/
/*   Fonction    : void ChargementACMTRS()                    			   */
/*  Description : Charge en mémoire le fichier contenant les Currency         */
/* ----------------------------------------------------------------------------*/
void ChargementACMTRS()
{
  // on va déterminer le nombre de ligne 
  nb_Acmtrs = getFileNbLigne(Kp_InputAcmtrs) ;
  char buffer[LONGBUF];
  char **tabbuf = NULL;
  size_t compteur = 0;
  
  memset(buffer, 0, sizeof(buffer));
  // en cas d'erreur on sort en affichant un message
  if (nb_Acmtrs > 0 )
  {
    //on retaille le tabbufleau de devise
    pAcmtrs = malloc( nb_Acmtrs * sizeof (T_TPRSMAP));

    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputAcmtrs) != NULL)
    { // tabbuf contient maintenant les données de la ligne en cours :
      tabbuf = split(buffer, SEPARATEUR_SPLIT , 1);
      pAcmtrs[compteur].prs_cf = atoi(tabbuf[TPRSMAP_PRS_CF]);
      pAcmtrs[compteur].acmtrs_nt = atoi(tabbuf[TPRSMAP_ACMTRS_NT]);
	  pAcmtrs[compteur].parm2 = atoi(tabbuf[TPRSMAP_PARM2]);
	  pAcmtrs[compteur].parm3 = atoi(tabbuf[TPRSMAP_PARM3]);
	  pAcmtrs[compteur].parm4 = atoi(tabbuf[TPRSMAP_PARM4]);
	  pAcmtrs[compteur].parm9 = atoi(tabbuf[TPRSMAP_PARM9]);
	  compteur++;
      freeTableau(tabbuf);
    }
	nb_LineACMTRS = compteur;
  }
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
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchIN(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2065_I1", "rt", &(pbd_Rupt->pf_InputFil)))
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
  char buf[LONGBUF];         // pour le buffer de sortie ESCOMPTE
  int col, i = 0;
  T_TPRSMAP acmtrsRetrieve;
  double ACMAMT, TOTAUX, AN;
  DEBUT_FCT("n_ActionLigneRfrBatchIN");
  T_TPRSMAP NotFound;
  int j;
  int found = 0;
  char s_message[100];
	
  
	if ( atoi(ptb_InRec_Cur[CML_ACMTRS_NT]) == 401 && atoi(ptb_InRec_Cur[CML_TOTAUX_MC]) == 0){				
		return OK;
	}


   //On recupère les acmtrs correspondant 
   for( j=0;j< nb_LineACMTRS; j++)
   {	
		if(pAcmtrs[j].acmtrs_nt == atoi(ptb_InRec_Cur[CML_ACMTRS3_NT2]) )
		{

			acmtrsRetrieve = pAcmtrs[j] ;
            found++;
	        sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
            i = 0;

            	//puis tout le reste des colonnes qui précèdent les montants annuels
            	for (col = 1; col <= CML_ACMTRS3_NT2; col++) /* Updated for Phase1b Migration */
            	{
            		
            		if (col == CML_ACMTRS_NT && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0)
            		{
            			sprintf(buf, "%s~%d", buf,acmtrsRetrieve.parm2); 
            		}
            		else if (col == CML_ACMTRS3_NT2 && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0)
            		{
            			sprintf(buf, "%s~%d", buf,acmtrsRetrieve.parm3); 
            		}
            		else if (col == CML_PATTERN_ID && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0 && acmtrsRetrieve.parm9 != 0)
            		{
            			sprintf(buf, "%s~NULL", buf); 
            		}
            		else if (col == CML_PATTERN_ID && acmtrsRetrieve.parm9 == 0)
            		{
            			sprintf(buf, "%s~NODSC", buf); 
            		}
            		else if (col == CML_COMMENT && acmtrsRetrieve.parm9 == 0)
            		{
            			sprintf(buf, "%s~No discount for this grouping", buf); 
            		}
            		else if (col == CML_TOTAUX_MC && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0)
            		{
            			TOTAUX = acmtrsRetrieve.parm4 * atof(ptb_InRec_Cur[CML_TOTAUX_MC]);
            			sprintf(buf, "%s~%f", buf,TOTAUX); 
            		}
            		else if (col == CML_ACMAMT_MC && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0)
            		{
            			ACMAMT = acmtrsRetrieve.parm4 * atof(ptb_InRec_Cur[CML_ACMAMT_MC]);
            			sprintf(buf, "%s~%f", buf,ACMAMT); 
            		}
            		else if (col >= CML_AM01_MC && col <= CML_AM_FIN && acmtrsRetrieve.acmtrs_nt != -1 && acmtrsRetrieve.parm3 != 0)
            		{
            			AN = acmtrsRetrieve.parm4 * atof(ptb_InRec_Cur[CML_AM01_MC + i]);
            			i++;
            			sprintf(buf, "%s~%f", buf,AN); 
            		}
            		else
            		{
            			sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
            		}
            	}	
            
            	// Ecriture de la ligne courante
            	fprintf(Kp_OutputBatch, "%s\n", buf);

		}

		
        // optimisation 		
        if ( found == MAX_DUPLICATE )
        {
          sprintf(s_message,"WARNING: use maximum of %d setup for %s ", MAX_DUPLICATE, ptb_InRec_Cur[CML_ACMTRS3_NT2] ) ;
	      n_WriteLog('I',s_message);  
	      break;
        }	  
        if(pAcmtrs[j].acmtrs_nt > atoi(ptb_InRec_Cur[CML_ACMTRS3_NT2]) )
		{
		 break;
		}
	

   } // for each setup


    if ( found == 0 ) // no setup match 
	{	

	NotFound.acmtrs_nt = -1;
	sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);

	//puis tout le reste des colonnes qui précèdent les montants annuels
	for (col = 1; col <= CML_ACMTRS3_NT2; col++) 
	{
		if (col == CML_PATTERN_ID && NotFound.parm9 == 0)
		{
			sprintf(buf, "%s~NODSC", buf); 
		}
		else if (col == CML_COMMENT && NotFound.parm9 == 0)
		{
			sprintf(buf, "%s~No discount for this grouping", buf); 
		}
		else
		{
			sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
		}
    }

	// Ecriture de la ligne courante
	fprintf(Kp_OutputBatch, "%s\n", buf);
	
    }
	
	
  return OK;
}


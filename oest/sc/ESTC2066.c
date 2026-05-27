/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC2066.c
 Revision                      : $Revision: 0 $
 Date de creation              : 07/03/2019
 Auteur                        : Charles SOCIE
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Discount at Locked in rates calculation
------------------------------------------------------------------------------
     Historique des modifications :
MOD1 23/08/2019 :Kagwe : #80663-IFRS 17 - REQ 11.04 Maintenance expenses not discounted.
MOD2 29/11/2019 Chalres Socie : SPIRA 77191 : IFRS17 Bad debt management : discount at lock in rate (REQ11.4)
MOD3 04/03/2020 Charles Socie SPIRA : 83091 Use IFRS 17 discount batch chain for EBS discount
MOD4 22/04/2020 Charles Socie SPIRA : 85557 ULAE - Initial Amount DSC
MOD5 22/07/2020 JYP : SPIRA 82584 memory optimisation UAT failure
MOD6 26/08/2020 HR : SPIRA 82685 struct.h
MOD7 10/11/2020 Charles Socie SPIRA : 89102 REQ 53.3 - Impact on discount
MOD8 27/09/2021 Charles Socie SPIRA : 96840 Discount - Illiquidity segment management 
MOD9 05/07/2022 JYP  SPIRA : 105459 bugfix missing dates fields
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC3001A.h"

/*--------------------------------------------------*/
/* Prototype des fonctions                          */
/*--------------------------------------------------*/
int   n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int   n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
void  ChargementCurrency();
void  ChargementIlliquidity();
int  ChargementRateIndex();
char* GetDevisebyRef(const char * ref);
void  ChargementDiscount();
long  getFileNbLigne(FILE * fl);
void  freeTableau(char** tab);
char** split(char* chaine, const char* delim, int vide);
void  addPattern( char **tab, int idx);
char* n_RechPosteRateIndex(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * ctrtyp );
char* n_RechPosteIlliquidity(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * ctrtyp );


//définition des variables d'input
char sz_Clodat_d[9] = "";
char sz_ClodatY_d[5] = "";
char sz_ClodatM_d[3] = "";
char sz_ClodatD_d[3] = "";
char sz_Patcat_ct[5] = "";
char sz_Pattyp_ct[5] = "";
char sz_Norm_cf[5] = "";
int Kn_NbLigRatInd;
int Kn_NbLigIllInd;
int LkiBool = 0;
int sz_buffindice = 0;
char * rateindex;
char * illiquidity;
int arrPattern[7000];
int BuffRateIndex = 0;
int BuffIlliquidity = 0;
int BuffPattern = 0;
int BuffSsd = 0;
int BuffUw = 0;

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define LGTH_SEGEST 10000
#define SEPARATOR 	 "~"

/*
** Objet  : EssaiBatchIN (Maitre)
** Entree : ESTC2066_I1 */
T_RUPTURE_VAR Kbd_ruptRfrBatchIN;

// Variable de fichiers
FILE *Kp_InputCurrency;
FILE *Kp_InputRate;
FILE *Kp_InputIll;
FILE *Kp_InputCumul;
FILE *Kp_InputPattern ;
FILE *Kp_OutputBatch;

// Pointure de structure des cashflow
// découpage du fichier de pattern en SEG_NF
T_FPATTERNSII2_JOIN * pDiscount;
T_DEVISE  * pDevise;
T_ILLIQUIDITY * pIlliquidity;
T_RATEINDEX  CTRRateIndex[2];


int * GetTblPatternDiscount(const char * CTR_NF, const char * SEC_NF, const char * UWY_NF, const char * UW_NT, const char * END_NT, const char * SEGNAT_CT, const char * devise, const char * NORME_CF, int ssd_cf, int esb_cf, const char * ctrtyp);
int * GetTblPatternLKI(const char * CTR_NF, const char * SEC_NF, const char * UWY_NF, const char * UW_NT, const char * END_NT, const char * SEGNAT_CT, const char * devise, const char * NORME_CF,  int ssd_cf,  const char * ctrtyp,  int esb_cf);
long  lignes = 0; 

//void     ExtractLineCSWithNoSync();      // sortie des pattern cash flow non utilisée
/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
int nb_Devise = 0 ; // pour stocker le nombre de devise chargée dynamiquement
int nb_Contrat = 0; // pour stocker le nombre de Illiquidity chargée dynamiquement
int nb_RIndex = 0 ; // pour stocker le nombre de Rate index chargée dynamiquement
int nb_Pattern = 0;
int nb_Cumul = 0;
char * sz_retour = NULL;

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
  int i;
  // Initialisation des signaux
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");
  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC2066_O1", "wt", &Kp_OutputBatch)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 1er fichier (ESCOMPTE)." );
 
  // chargement de la date de clotûre fournie au programme
  strcpy(sz_Clodat_d, psz_GetCharArgv(1));
  strcpy(sz_Patcat_ct, psz_GetCharArgv(2));
  strcpy(sz_Pattyp_ct, psz_GetCharArgv(3));
  strcpy(sz_Norm_cf, psz_GetCharArgv(4));
  sz_retour = (char*) malloc(sizeof(char) * 4);
  rateindex = malloc(sizeof(char) * 33);
  illiquidity = malloc(sizeof(char) * 33);

  // init date values 
 if (strlen(sz_Clodat_d) == 8 ) 
    for (i=0;i<4;i++){
		strncpy(&sz_ClodatY_d[i],&sz_Clodat_d[i],1);
		if (i<2){
			strncpy(&sz_ClodatM_d[i],&sz_Clodat_d[i+4],1);
			strncpy(&sz_ClodatD_d[i],&sz_Clodat_d[i+6],1);
		}
	}
 else ExitPgm(ERR_XX, "length of date sz_Clodat_d should be 8, check parameters " );
 

  
  // Ouverture du fichier de cash flow ( pattern incrementales )
  if (n_OpenFileAppl("ESTC2066_I2", "rt", &Kp_InputPattern) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de cashflow." );
  if (n_OpenFileAppl("ESTC2066_I3", "rt", &Kp_InputCurrency) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier des devises." );
  if (n_OpenFileAppl("ESTC2066_I4", "rt", &Kp_InputRate) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier des Rate Index." );
  if (n_OpenFileAppl("ESTC2066_I5", "rt", &Kp_InputIll) == ERR )   ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier des Illiquidity." );

  //Chargement des CUR_CF dans un tableau
  ChargementCurrency();

  //Chargement des Illiquidity dans un tableau 
  ChargementIlliquidity();

  // on peut fermer le fichier , les donnees sont dans pDevise
  if (n_CloseFileAppl("ESTC2066_I3", &Kp_InputCurrency))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Devise (CUR_CF).");
  
  //Chargement des Rate Index dans un tableau
  if (strcmp(sz_Norm_cf,"EBS") != 0){
	Kn_NbLigRatInd = ChargementRateIndex();
  }

  //chargement des cashflow dans un tableau
  ChargementDiscount();

  // Initialisation des variables de gestion de ruptures
  if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");
  if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC2066_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
  if (n_CloseFileAppl("ESTC2066_I2", &Kp_InputPattern))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de Pattern Discount."); 
  if (n_CloseFileAppl("ESTC2066_I4", &Kp_InputRate))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier des Rate Index.");
  if (n_CloseFileAppl("ESTC2066_I5", &Kp_InputIll))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier des Illiquidity.");
  if (n_CloseFileAppl("ESTC2066_O1", &Kp_OutputBatch))          ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");


  // libération mémoire
  free(pDevise);
  free(pIlliquidity);
  exit(OK);

}

/* ----------------------------------------------------------------------------*/
/*   Fonction    : void ChargementCurrency()                    			   */
/*  Description : Charge en mémoire le fichier contenant les Currency         */
/* ----------------------------------------------------------------------------*/
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

/* ----------------------------------------------------------------------------*/
/*   Fonction    : void ChargementIlliquidity()                     			   */
/*  Description : Charge en mémoire le fichier contenant les Illiquidity         */
/* ----------------------------------------------------------------------------*/
void ChargementIlliquidity()
{
	DEBUT_FCT("ChargemenIlliquidity");
  // on va déterminer le nombre de ligne à charger
  nb_Contrat  = getFileNbLigne(Kp_InputIll) ;
  char buffer[LONGBUF];
  char **tab = NULL;
  size_t compteur = 0;

  memset(buffer, 0, sizeof(buffer));

  if (nb_Contrat > 0 )
  {
    //on retaille le tableau de devise
    pIlliquidity = malloc( nb_Contrat * sizeof (T_ILLIQUIDITY));

    // ... et on le charge
	while (fgets( buffer, LGTH_SEGEST, Kp_InputIll)!= NULL)
	{
		tab = split(buffer, SEPARATEUR_SPLIT , 1);
		strcpy(pIlliquidity[compteur].ctr_nf, tab[0]);
		pIlliquidity[compteur].end_nt = atoi(tab[1]);
		pIlliquidity[compteur].sec_nf = atoi(tab[2]);
		pIlliquidity[compteur].uwy_nf = atoi(tab[3]);
		pIlliquidity[compteur].uw_nt = atoi(tab[4]);
		strcpy(pIlliquidity[compteur].sgmt_ls, tab[7]);
		compteur++;
		freeTableau(tab);
	}
  }
}

/* -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*   Fonction    : char * n_RechPosteIlliquidity(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * typ )         */
/*  Description : recherche et renvoie les illiquidity correspondant a la Norme donnée en paramètre														  */
/* -------------------------------------------------------------------------------------------------------------------------------------------------------*/
char * n_RechPosteIlliquidity(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * typ )
{

	DEBUT_FCT("n_RechPosteTSEGEST");
	int i;
	const char * typRetro = "R";
	
	//On recupère les illiquidity correspondant a la Norme donnée en paramètre
	if (strncmp(typ,typRetro,1)==0){
		uw_nt = 0;
	}
	//On recupère les illiqidity correspondant a la Norme donnée en paramètre
	for( i=BuffIlliquidity ;i < nb_Contrat; i++){	
			if ( strcmp(pIlliquidity[i].ctr_nf,ctr_nf) == 0 ){
				if ( pIlliquidity[i].sec_nf == sec_nf ){
					if ( pIlliquidity[i].end_nt == end_nt){
						if ( pIlliquidity[i].uwy_nf == uwy_nf ){
							if ( pIlliquidity[i].uw_nt == uw_nt ){
									BuffIlliquidity = i;			
									RETURN_VAL(  pIlliquidity[i].sgmt_ls );
								}		
							}
						}
					}				
				}
	}
		for( i=BuffIlliquidity ;i > 0; i--){	
			if ( strcmp(pIlliquidity[i].ctr_nf,ctr_nf) == 0 ){
				if ( pIlliquidity[i].sec_nf == sec_nf ){
					if ( pIlliquidity[i].end_nt == end_nt){
						if ( pIlliquidity[i].uwy_nf == uwy_nf ){
							if ( pIlliquidity[i].uw_nt == uw_nt ){
									BuffIlliquidity = i;			
									RETURN_VAL(  pIlliquidity[i].sgmt_ls );
								}		
							}
						}
					}				
				}
	}

	RETURN_VAL( "" );	// Aucune occurence trouvée
}

/* ----------------------------------------------------------------------------*/
/*   Fonction    : int ChargementRateIndex()                     			   */
/*  Description : Charge en mémoire le fichier contenant les Rateindex         */
/* ----------------------------------------------------------------------------*/
int ChargementRateIndex()
{
	int i = 0 ;

	DEBUT_FCT("ChargementRateIndex");

	char buffer[LGTH_SEGEST];
	char **tab=NULL;
	int count=0;
	int typeIndex = 0;
	while (fgets( buffer, LGTH_SEGEST, Kp_InputRate)!= NULL)
	{
		count =0;
		tab = split(buffer, SEPARATOR ,1);
		
		count = CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].count;
		if (count == 0){
				CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA = malloc( 40000 * sizeof (T_RI_DATA));
		} 
		
		CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].count = count +1 ;			 //increament counter for each UWY when contract add in structure
		strcpy(CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_CTR_NF,  tab[RI_CTR_NF]);
		CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_END_NT =  atoi(tab[RI_END_NT]);
		CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_SEC_NF =  atoi(tab[RI_SEC_NF]);
		CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_UWY_NF =  atoi(tab[RI_UWY_NF]);
		CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_UW_NT =  atoi(tab[RI_UW_NT]);
		strcpy(CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_RATEINDEX_G ,  tab[RI_RATEINDEX_G]);
		strcpy(CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_RATEINDEX_P ,  tab[RI_RATEINDEX_P]);
		strcpy(CTRRateIndex[typeIndex].t_SSD[atoi(tab[RI_SSD_CF])].t_UWY[atoi(tab[RI_UWY_NF])].t_DATA[count].RI_RATEINDEX_L ,  tab[RI_RATEINDEX_L]);
	}
	RETURN_VAL( i );
}


/* -------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*   Fonction    : char * n_RechPosteRateIndex(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * typ )         */
/*  Description : recherche et renvoie les rateindex correspondant a la Norme donnée en paramètre														  */
/* -------------------------------------------------------------------------------------------------------------------------------------------------------*/
char * n_RechPosteRateIndex(const char * ctr_nf, int sec_nf, int uwy_nf, int uw_nt, int end_nt, int ssd_cf, const char * typ )
{

	DEBUT_FCT("n_RechPosteTSEGEST");
	int i;
	int typeIndex = 0;
	const char * typRetro = "R";
	
	//On recupère les rateindex correspondant a la Norme donnée en paramètre
	if (strncmp(typ,typRetro,1)==0){
		uw_nt = 0;
	}
	
if ( CTRRateIndex[0].t_SSD[BuffSsd].t_UWY[BuffUw].count != 0
			&& CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_SEC_NF == sec_nf 
			&& strcmp(CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_CTR_NF,ctr_nf) == 0 
			&& CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_END_NT == end_nt 
			&& CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_UW_NT == uw_nt
			&& CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_UWY_NF == uwy_nf){
				  if(strcmp(sz_Norm_cf,"I17G")==0 ){
						RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_RATEINDEX_G );
				  }
				  else if (strcmp(sz_Norm_cf,"I17P")==0){
						RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_RATEINDEX_P );
   			      }
				  else if (strcmp(sz_Norm_cf,"I17L")==0){
						RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[BuffSsd].t_UWY[BuffUw].t_DATA[BuffRateIndex].RI_RATEINDEX_L );
				  }
			}

	//On recupère les rateindex correspondant a la Norme donnée en paramètre
	for( i=0;i< CTRRateIndex[0].t_SSD[ssd_cf].t_UWY[uwy_nf].count; i++){
		if ( CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_SEC_NF ==sec_nf ){
			if ( strcmp(CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_CTR_NF,ctr_nf) == 0 ){
				if ( CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_END_NT ==end_nt){
					if ( CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_UW_NT == uw_nt ){
							  if(strcmp(sz_Norm_cf,"I17G")==0 ){
					        BuffSsd = ssd_cf;
									BuffUw = uwy_nf;
									BuffRateIndex = i;
									RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_RATEINDEX_G );
							  }
							  else if (strcmp(sz_Norm_cf,"I17P")==0){
									BuffRateIndex = i;
									RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_RATEINDEX_P );
							  }
							  else if (strcmp(sz_Norm_cf,"I17L")==0){
									BuffRateIndex = i;
									RETURN_VAL(  CTRRateIndex[typeIndex].t_SSD[ssd_cf].t_UWY[uwy_nf].t_DATA[i].RI_RATEINDEX_L );
							  }
						}
					}
				}				
			}
		}
	
	

	RETURN_VAL( "" );	// Aucune occurence trouvée
}

/* ----------------------------------------------------------------------------*/
/*   Fonction    : char * GetDevisebyRef(const char * ref)                     */
/*  Description : recherche et renvoie la devise correspondant à la référence  */
/* ----------------------------------------------------------------------------*/
char * GetDevisebyRef(const char * ref)
{
  // on va recherche la devise correspondant à la référence

  int compteur = 0;/* Added for Phase1b Migration */
    
  for (compteur = 0 ; compteur < nb_Devise; compteur ++)  /* Updated for Phase1b Migration */
  {
    if (strncmp(ref ,  pDevise[compteur].curr, 3) == 0 )
    {
      // on a trouvé la devise
      strncpy(sz_retour, pDevise[compteur].ref, 3);
      sz_retour[3] = 0;
      break;
    }
  }
  return sz_retour;
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

  strcpy(pDiscount[idx].db_pat.SSD_CF, tab[PAT2_SSD_CF]);
  strcpy(pDiscount[idx].db_pat.ESB_CF, tab[PAT2_ESB_CF]);
  strcpy(pDiscount[idx].db_pat.PATCAT_CT, tab[PAT2_PATCAT_CT]);
  strcpy(pDiscount[idx].db_pat.PATTYP_CT , tab[PAT2_PATTYP_CT]);
  strcpy(pDiscount[idx].db_pat.SEG_NF , tab[PAT2_SEG_NF]);
  pDiscount[idx].db_pat.UWY_NF = atoi(tab[PAT2_UWY_NF]);
  strcpy(pDiscount[idx].db_pat.CUR_CF, tab[PAT2_CUR_CF]);
  strcpy(pDiscount[idx].db_pat.LOB_CF , tab[PAT2_LOB_CF]);
  strcpy(pDiscount[idx].db_pat.RATING_CF, tab[PAT2_RATING_CF]);
  strcpy(pDiscount[idx].db_pat.NORME_CF , tab[PAT2_NORME_CF]);
  strcpy(pDiscount[idx].db_pat.SEGNAT_CT , tab[PAT2_SEGNAT_CT]);
  pDiscount[idx].db_pat.BALSHEY_NF = atoi(tab[PAT2_BALSHEY_NF]);
  strcpy(pDiscount[idx].db_pat.PATTERN_ID, tab[PAT2_PATTERN_ID]);
  strcpy(pDiscount[idx].db_pat.CRE_D, tab[PAT2_CRE_D]);
  strcpy(pDiscount[idx].db_pat.CREUSR_CF , tab[PAT2_CREUSR_CF]);
  
  taille = strlen(tab[PAT2_RATEINDEX]);
  if (tab[PAT2_RATEINDEX][taille - 1] == '\n')
  {
    strncpy(pDiscount[idx].db_pat.RATEINDEX, tab[PAT2_RATEINDEX], taille - 1);
  }
  else
    strcpy(pDiscount[idx].db_pat.RATEINDEX, tab[PAT2_RATEINDEX]);
  // TOTAUX ignoré
    
  // on va supprimer le retour chariot si il y en a un
  taille = strlen(tab[PAT2_AN_FIN + 1]);
  if (tab[PAT2_AN_FIN + 1][taille - 1] == '\n')
  {
    strncpy(pDiscount[idx].jointure , tab[PAT2_AN_FIN + 1], taille - 1);
  }
  else
    strcpy(pDiscount[idx].jointure , tab[PAT2_AN_FIN + 1]);

  for (j = 0; j < PATTERNSII_ANNEES; j++)
  {
    pDiscount[idx].db_pat.AN[j] = atof(tab[PAT2_AN1 + j]);
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
    pDiscount = (T_FPATTERNSII2_JOIN*) realloc(pDiscount, nb_Pattern *  sizeof(T_FPATTERNSII2_JOIN)) ;

    while (fgets( buffer, LONGBUF, Kp_InputPattern) != NULL)
    {
		tab = split(buffer, SEPARATEUR_SPLIT , 1);
		if(strncmp(sz_Norm_cf,"EBS",3) == 0 ){
			addPattern(tab, sizep);
			sizep++;
		}
		if (strncmp(sz_Pattyp_ct,tab[PAT2_PATTYP_CT],strlen(sz_Pattyp_ct)) == 0){
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

  if (n_OpenFileAppl("ESTC2066_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture   = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
  pbd_Rupt->c_Separ       = '~';

  return OK;
}

/*==============================================================================
 Objet :            Chargement d'un tableau de pattern pour une devise
 Parametre(s) :     SEGNAT_CT, devise, NORME_CF
 Retour :           En cas de probleme retourne un tableau vide
                    sinon retourne contenant le pattern associée 
==============================================================================*/
int * GetTblPatternDiscount(const char * CTR_NF, const char * SEC_NF, const char * UWY_NF, const char * UW_NT, const char * END_NT, const char * SEGNAT_CT, const char * devise, const char * NORME_CF, int ssd_cf, int esb_cf, const char * ctrtyp)
{
  int* tbl = NULL;
  int* TblEsc = NULL;
  int indexMax = 0;
  int nbDisc = 1;
  int j = 0;
  int lenCurr = strlen(devise); // normalement : 3
  char CurrNorme[21];
  int indNature = 0; // index de la SEGNAT_CT trouvée , si il y en a une
  int indNorme = 0;
  int x = 0;
  int y = 0;
  int index;

  // on va cherche la valeur de illiquidity correspondant au CSUOE ( si retro UW = 0 )
  if ( strcmp(sz_Norm_cf,"EBS") != 0){
	  if(strncmp(ctrtyp,"A",1) == 0 ){
		illiquidity = n_RechPosteIlliquidity(CTR_NF, atoi(SEC_NF), atoi(UWY_NF), atoi(UW_NT), atoi(END_NT), ssd_cf, ctrtyp);
	  }
	  else{
		illiquidity = n_RechPosteIlliquidity(CTR_NF, atoi(SEC_NF), atoi(UWY_NF), 0, atoi(END_NT), ssd_cf, ctrtyp);
		}

	  // si aucun illiquidity trouvée on retourne un tableau vide
	  if (illiquidity == NULL || illiquidity[0] == '\0' || strcmp(illiquidity,"") == 0) {
		  TblEsc = realloc(NULL, sizeof(int) * 1);
		  nb_CurrPattern = indexMax;
		  return TblEsc;
	  }
    }
	else {
		illiquidity = "0";
	}

  for (x = 0 ; x < nb_Pattern; x++) /* Updated for Phase1b Migration */
  {
	  
	if (strncmp(devise, pDiscount[x].db_pat.CUR_CF, lenCurr) == 0 && (strcmp(pDiscount[x].db_pat.RATEINDEX,illiquidity) == 0 || strcmp(sz_Norm_cf,"EBS") == 0 ))
	{
	  // on va récupérer le nombre de pattern qui correspondent à la devise
	  nbDisc++;
	  if ((*SEGNAT_CT == *pDiscount[x].db_pat.SEGNAT_CT) && (indNature == 0))
		indNature = x;
	  for (index = 0; NORME_CF[index] != '\0'; ++index)
		if (NORME_CF[index] != ' ')
		{
		  if ((strncmp(NORME_CF, pDiscount[x].db_pat.NORME_CF, strlen(pDiscount[x].db_pat.NORME_CF) == 0)) && (indNorme == 0))
		  {
			if (strcmp(sz_Norm_cf,"I17G") == 0 || strcmp(sz_Norm_cf,"EBS") == 0 || (strcmp(sz_Norm_cf,"I17G") != 0  && atoi(pDiscount[x].db_pat.SSD_CF) == ssd_cf && atoi(pDiscount[x].db_pat.ESB_CF) == esb_cf)){
				indNorme = x;
			}
		  }
		  break;
		}
	}
    // on retaille le pointeur sur le tableau de pattern
  }

  tbl = realloc(tbl, sizeof(int) * nbDisc);

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
    if (strncmp(devise, pDiscount[x].db_pat.CUR_CF, lenCurr) == 0 && ( strcmp(pDiscount[x].db_pat.RATEINDEX,illiquidity) == 0 || strcmp(sz_Norm_cf,"EBS") == 0 ))
    {
      tbl[j] = x;
      j++;
    }
    else
      tbl[j] = -1 ;
  }

  if (indNorme)
  {
    // on va supprimer les pattern dont la NORME_CF est différente
    for (x = 0 ; x < j ; x++) /* Updated for Phase1b Migration */
    {
      if (( tbl[x] != -1) && strncmp(NORME_CF, pDiscount[tbl[x]].db_pat.NORME_CF,strlen(pDiscount[tbl[x]].db_pat.NORME_CF)) != 0)
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
 Objet :            Chargement d'un tableau de pattern pour une devise
 Parametre(s) :     CSUOE, SEGNAT_CT, devise, NORME_CF, SSD_CF, CTRTYP
 Retour :           En cas de probleme retourne un tableau vide
                    sinon retourne contenant le pattern associée 
==============================================================================*/
int * GetTblPatternLKI(const char * CTR_NF, const char * SEC_NF, const char * UWY_NF, const char * UW_NT, const char * END_NT, const char * SEGNAT_CT, const char * devise, const char * NORME_CF, int ssd_cf, const char * ctrtyp, int esb_cf)
{
  int* TblEsc = NULL;
  int indexMax = 0;
  int nbDisc = 0;
  int lenCurr = strlen(devise); // normalement : 3
  int x = 0;
  arrPattern[0] =  '\0' ;

  nb_CurrPattern =0;
  // on va cherche la valeur de rate index correspondant au CSUOE ( si retro UW = 0 )
  if(strncmp(ctrtyp,"A",1) == 0){
    rateindex = n_RechPosteRateIndex(CTR_NF, atoi(SEC_NF), atoi(UWY_NF), atoi(UW_NT), atoi(END_NT), ssd_cf, ctrtyp);
  }
  else{
    rateindex = n_RechPosteRateIndex(CTR_NF, atoi(SEC_NF), atoi(UWY_NF), 0, atoi(END_NT), ssd_cf, ctrtyp);
  }
  // si aucun rateindex trouvée on retourne un tableau vide
  if (rateindex == NULL || rateindex[0] == '\0' || strcmp(rateindex,"") == 0) {
	  TblEsc = realloc(NULL, sizeof(int) * 1);
	  nb_CurrPattern = indexMax;
	  return TblEsc;
  }

  // on cherche les ligne de discount qui match 
    if (BuffPattern != 0 && strncmp(devise, pDiscount[BuffPattern].db_pat.CUR_CF, lenCurr) == 0 && strcmp(pDiscount[BuffPattern].db_pat.RATEINDEX,rateindex) == 0)
    {
		if (strcmp(sz_Norm_cf,"I17G") == 0 || strcmp(sz_Norm_cf,"EBS") == 0 || (strcmp(sz_Norm_cf,"I17G") != 0  && atoi(pDiscount[BuffPattern].db_pat.SSD_CF) == ssd_cf && atoi(pDiscount[BuffPattern].db_pat.ESB_CF) == esb_cf)){
			arrPattern[nbDisc] = BuffPattern;
			nbDisc++;		
		}
    } 
	else{
	  BuffPattern = 0;

	  for (x = 0 ; x < nb_Pattern; x++) /* Updated for Phase1b Migration */
	  {  
		if (strncmp(devise, pDiscount[x].db_pat.CUR_CF, lenCurr) == 0 && strcmp(pDiscount[x].db_pat.RATEINDEX,rateindex) == 0 )
		{
			if (strcmp(sz_Norm_cf,"I17G") == 0 || strcmp(sz_Norm_cf,"EBS") == 0 || (strcmp(sz_Norm_cf,"I17G") != 0  && atoi(pDiscount[x].db_pat.SSD_CF) == ssd_cf && atoi(pDiscount[x].db_pat.ESB_CF) == esb_cf)){
				arrPattern[nbDisc] = x;
				nbDisc++;		
				BuffPattern	= x;
			}
		 }     
	  }
	}

  // on recarde si on a trouvé des Discount sinon on retourne un tableau vide
  if (nbDisc == 0)
  {
	  TblEsc = realloc(NULL, sizeof(int) * 1);
	  nb_CurrPattern = indexMax;
	  return TblEsc;
  }

  TblEsc = realloc(NULL, sizeof(int) * nbDisc);

  indexMax=0;
  for (x = 0 ; x < nbDisc; x++)
  {
		TblEsc[indexMax] = arrPattern[x];
		indexMax++;   
  }

  nb_CurrPattern = nb_CurrPattern+indexMax;
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
  double    calcul, total;           // montant du fichier cumul
  char *    amount;
  double  escompte[PATTERNSII_ANNEES];
  T_FPATTERNSII2_JOIN   pDSC;
  char  norme[4][6] = {"EV","GIM","IFRSI","SII"};
  int NbNorme = 0;
  int *     tbl = NULL;
  char*     monnaie;
  char      jointure[100] ;
  int     isOK = 0;     // pour vérifier la synchro , en cas d'erreur on renvoi la ligne dans un fichier nosync
  char    ratingDevise[6];
  int idx = 0;  /* Added for Phase1b Migration */
  int col = 0;  /* Added for Phase1b Migration */
  int i_an = 0 ;/* Added for Phase1b Migration */
  int j = 0;    /* Added for Phase1b Migration */

  DEBUT_FCT("n_ActionLigneRfrBatchIN");

  //ptb_InRec_Cur contient la ligne courante
  // on va comparer le contenu de la colonne ptb_InRec_Cur[CML_CUR_CF]
  //avec le contenu des colonnes des patterns

  memset(buf, 0, sizeof(buf));
  memset(jointure, 0, sizeof(jointure));
  memset(ratingDevise , 0 , sizeof(ratingDevise));

	amount = ptb_InRec_Cur[CML_TOTAUX_MC];

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

  if (strlen(monnaie) != 0 && strncmp(ptb_InRec_Cur [CML_PATTERN_ID],"NODSC",5) !=0 )
  {
    // on compare avec la jointure des discounts
    sprintf(jointure, "%s", monnaie);

	// test de la function GetPatternDiscount
	if (strcmp(sz_Norm_cf,"EBS")== 0){
		LkiBool = 0;
		
		tbl = GetTblPatternDiscount(ptb_InRec_Cur[CML_CTR_NF] , ptb_InRec_Cur [CML_SEC_NF], ptb_InRec_Cur[CML_UWY_NF], ptb_InRec_Cur[CML_UW_NT], ptb_InRec_Cur[CML_END_NT], ptb_InRec_Cur [CML_NAT_CF], monnaie, norme[NbNorme], atoi(ptb_InRec_Cur [CML_SSD_CF]), atoi(ptb_InRec_Cur [CML_ESB_CF]), NULL);
	}
	else if (strcmp(sz_Pattyp_ct,"LKI")== 0 || strcmp(sz_Pattyp_ct,"FWD")== 0 )
	{
		LkiBool = 1;
		//the 1 condition is to check is the contract is Assum or Assume Retro
		if(strncmp(ptb_InRec_Cur[CML_TYP_CT],"A",1) == 0){
			tbl = GetTblPatternLKI(ptb_InRec_Cur[CML_CTR_NF] , ptb_InRec_Cur [CML_SEC_NF], ptb_InRec_Cur[CML_UWY_NF], ptb_InRec_Cur[CML_UW_NT], ptb_InRec_Cur[CML_END_NT], ptb_InRec_Cur[CML_NAT_CF], monnaie, sz_Norm_cf, atoi(ptb_InRec_Cur [CML_SSD_CF]), ptb_InRec_Cur [CML_TYP_CT], atoi(ptb_InRec_Cur [CML_ESB_CF]));
		}
		//if CML_CTR_NF is empty it will be pure RETRO contract
		else {
			tbl = GetTblPatternLKI(ptb_InRec_Cur[CML_RETCTR_NF] , ptb_InRec_Cur [CML_RETSEC_NF], ptb_InRec_Cur[CML_RTY_NF], ptb_InRec_Cur[CML_RETUW_NT], ptb_InRec_Cur[CML_RETEND_NT], ptb_InRec_Cur[CML_NAT_CF], monnaie, sz_Norm_cf, atoi(ptb_InRec_Cur [CML_SSD_CF]), ptb_InRec_Cur [CML_TYP_CT], atoi(ptb_InRec_Cur [CML_ESB_CF]));
		}
	}
	else
	{
		LkiBool = 0;
		if(strncmp(ptb_InRec_Cur[CML_TYP_CT],"A",1) == 0){
		tbl = GetTblPatternDiscount(ptb_InRec_Cur[CML_CTR_NF] , ptb_InRec_Cur [CML_SEC_NF], ptb_InRec_Cur[CML_UWY_NF], ptb_InRec_Cur[CML_UW_NT], ptb_InRec_Cur[CML_END_NT], ptb_InRec_Cur [CML_NAT_CF], monnaie, sz_Norm_cf, atoi(ptb_InRec_Cur[CML_SSD_CF]), atoi(ptb_InRec_Cur[CML_ESB_CF]), ptb_InRec_Cur[CML_TYP_CT]);
		}
		//if CML_CTR_NF is empty it will be pure RETRO contract
		else {
			tbl = GetTblPatternDiscount(ptb_InRec_Cur[CML_RETCTR_NF] , ptb_InRec_Cur [CML_RETSEC_NF], ptb_InRec_Cur[CML_RTY_NF], ptb_InRec_Cur[CML_RETUW_NT], ptb_InRec_Cur[CML_RETEND_NT], ptb_InRec_Cur[CML_NAT_CF], monnaie, sz_Norm_cf, atoi(ptb_InRec_Cur[CML_SSD_CF]), atoi(ptb_InRec_Cur[CML_ESB_CF]), ptb_InRec_Cur[CML_TYP_CT]);
		}
	}
	
	
    // nb_CurrPattern contient le nombre de pattern correspondants...
    for (idx = 0 ; idx < nb_CurrPattern; idx++) /* Updated for Phase1b Migration */
    {
      if (tbl[idx] != -1)
      {
		memcpy(&pDSC, &pDiscount[tbl[idx]], sizeof(T_FPATTERNSII2_JOIN));
		sprintf(ratingDevise, "%s", pDSC.db_pat.RATING_CF);

		// d'abord l'entête
		sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);

		//puis tout le reste des colonnes qui précèdent les montants annuels
		//[07] add ACMTRS3 at the end of te file 
		for (col = 1; col <= CML_TYP_CT; col++) /* Updated for Phase1b Migration */
		{
			if (col == CML_TRNCOD_CF)
			{
				sprintf(buf, "%s~", buf);  // pas de valeur dans cette colonne
			}
			else if ( (col == CML_ACMAMT_MC && (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"CSF",3) == 0 && (strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"INF",3) == 0 
			|| strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"RMNTP",4) == 0 )))
			||(col == CML_ACMAMT_MC && (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT",3) == 0 && (strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"RMNTP",4) == 0 )))){
				sprintf(buf, "%s~%s", buf, amount);
			}
			else if (col == CML_ACMAMT_MC && (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"RAD",3) == 0 && (strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IADSI",5) == 0 
			|| strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IALKI",5) == 0  || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRLKI",5) == 0 || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRDSI",5) == 0 ))){
				sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[CML_AMT_MC]);
			}
			else if (col == CML_RETAMT_MC && (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"RAD",3) == 0 && (strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IADSI",5) == 0 
			|| strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IALKI",5) == 0  || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRLKI",5) == 0 || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRDSI",5) == 0  ))){
				sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[CML_AMT_MC]);
			}
			else if (col == CML_RETINTAMT_MC && (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"RAD",3) == 0 && (strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IADSI",5) == 0 
			|| strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IALKI",5) == 0 || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRLKI",5) == 0 || strncmp(ptb_InRec_Cur[CML_PATTYP_CT],"IRDSI",5) == 0 ))){
				sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[CML_AMT_MC]);
			}
			else
			{ 
				switch(col)
				{
				case 2 : sprintf(buf, "%s~%s", buf, sz_ClodatY_d); 
					break;
				case 3 : sprintf(buf, "%s~%s", buf, sz_ClodatM_d);
					break;
				case 4 : sprintf(buf, "%s~%s", buf, sz_ClodatD_d);
					break;
				default : sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
				}
			}
		}	
		// et le reste des colonnes de Discount MOD2


		if(strcmp(ptb_InRec_Cur[CML_PATTYP_CT],"RMNTP") == 0 && strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 ){
				if (strcmp(sz_Pattyp_ct,"LKI")== 0){
					sprintf(buf, "%s~%s~%s~BDT~LKI~%s" ,  
					buf,
					sz_Norm_cf, // NORME_CF
					ptb_InRec_Cur[CML_RATING_CF],
					pDSC.db_pat.PATTERN_ID
				   );
			   }
			   	else if (strcmp(sz_Norm_cf,"EBS")== 0){
					sprintf(buf, "%s~%s~%s~BDT~BDT~%s" ,  
					buf,
					pDiscount[tbl[idx]].db_pat.NORME_CF, // NORME_CF
					ptb_InRec_Cur[CML_RATING_CF],
					pDSC.db_pat.PATTERN_ID
				   );
			   }
			   else{
					sprintf(buf, "%s~%s~%s~BDT~BDT~%s" ,  
					buf,
					sz_Norm_cf, // NORME_CF
					ptb_InRec_Cur[CML_RATING_CF],
					pDSC.db_pat.PATTERN_ID
				   );
			   }
		}
		else if (strcmp(sz_Norm_cf,"EBS")== 0){
			sprintf(buf, "%s~%s~%s~%s~%s~%s" ,
			buf,
			pDiscount[tbl[idx]].db_pat.NORME_CF, // NORME_CF
			ratingDevise,
			"DSC",
			"DSI",
			pDSC.db_pat.PATTERN_ID
		   );
		}
		else if (ptb_InRec_Cur[CML_PATTYP_CT][2] == 'R' && ptb_InRec_Cur[CML_PATTYP_CT][3] == 'E' && ptb_InRec_Cur[CML_PATTYP_CT][4] == 'T'){
			sprintf(buf, "%s~%s~%s~%s~%s~%s" ,  //BDT
				buf,
				sz_Norm_cf, // NORME_CF
				ratingDevise,
				sz_Patcat_ct,
				sz_Pattyp_ct,
				pDSC.db_pat.PATTERN_ID
			   );
			// et le reste des colonnes de Discount
		}
		else{
				sprintf(buf, "%s~%s~%s~%s~%s~%s" ,
				buf,
				sz_Norm_cf, // NORME_CF
				ratingDevise,
				sz_Patcat_ct,
				sz_Pattyp_ct,
				pDSC.db_pat.PATTERN_ID
			   );
		}

		// Puis la liste des taux calculés
		// on va d'abord la 1er année ( an 0)

		escompte[0] = pDSC.db_pat.AN[0] *  atof(ptb_InRec_Cur[CML_AN1]);
		sprintf(buf, "%s~%.3f", buf, escompte[0] );

		calcul = 0;


		for (i_an = 1; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
		{
		  calcul = pDSC.db_pat.AN[i_an] *  atof(ptb_InRec_Cur[CML_AN1 + i_an]);
		  escompte[i_an] = calcul;
		  // on va stocker le résultat de chaque année pour le calcul du cumul rmpt
		  sprintf(buf, "%s~%.3f", buf, calcul);
		} 

		total = 0;
		for (j = 0 ; j < PATTERNSII_ANNEES; j++) /* Updated for Phase1b Migration */
		{
		  total += escompte[j];
		}
		// Ecriture de la ligne courante , à laquelle on ajoute les 4 colonnes de commentaires
		isOK = 1; // on signale que la synchro est trouvée  , même si on n'écrit pas la ligne
		fprintf(Kp_OutputBatch, "%s~~%s~~%.3f~%s\n", buf, monnaie, total, ptb_InRec_Cur[CML_ACMTRS3_NT2] );
		NbNorme++;
		}
	}
  }

  // si on a pas trouvé le RATING_CF, on sort la ligne en erreur
  if (isOK == 0)
  {
    char TempACMTRS3[5];
	
    strcpy(TempACMTRS3,ptb_InRec_Cur[CML_ACMTRS3_NT2]); 
    // on va ajouter 3 colonnes vides au tableau de pointeur
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 1] = " ";
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 2] = monnaie;
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 3] = "";
    ptb_InRec_Cur[CML_AN1 + PATTERNSII_ANNEES + 4] = "\0";

    // on met les PATTERNSII_ANNEES années à 0
    // d'abord l'entête
    sprintf(buf, "%s", ptb_InRec_Cur[CML_SSD_CF]);
    //puis tout le reste des colonnes qui précèdent les montants annuels
	
 
 	for (col = 1; col <= CML_TYP_CT; col++) /* Updated for Phase1b Migration */
    {
		switch(col)
		{
			case 2 : sprintf(buf, "%s~%s", buf, sz_ClodatY_d); 
				break;
			case 3 : sprintf(buf, "%s~%s", buf, sz_ClodatM_d);
				break;
			case 4 : sprintf(buf, "%s~%s", buf, sz_ClodatD_d);
				break;
			default : sprintf(buf, "%s~%s", buf, ptb_InRec_Cur[col]);
		}
    }
	total = 0;
	for (j = 0 ; j < PATTERNSII_ANNEES; j++)
	{
		total += atof(ptb_InRec_Cur[CML_AN1+j]);
	}

	if (LkiBool == 1)
		{
		if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) == 0 ){
			if (strncmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT",3) == 0){
			sprintf(buf, "%s~%s~~BDT~LKI~NODSC", buf, sz_Norm_cf);
			}
			else {
				sprintf(buf, "%s~%s~~DSC~LKI~NODSC", buf, sz_Norm_cf);
			}
		}
		//MOD2
		else if(strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 ){
			sprintf(buf, "%s~%s~~BDT~LKI~ERR", buf, sz_Norm_cf);
			}
		else
		{
			sprintf(buf, "%s~%s~~%s~%s~ERR", buf, sz_Norm_cf, sz_Patcat_ct, sz_Pattyp_ct);
		}
	}
	else
	{
	//MOD2
		if(strcmp(ptb_InRec_Cur[CML_PATCAT_CT],"BDT") == 0 ){
			if (strncmp(sz_Norm_cf,"EBS",3)== 0){
				if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) == 0){
					sprintf(buf, "%s~%s~~BDT~BDT~NODSC", buf, pDiscount[tbl[idx]].db_pat.NORME_CF);
				}
				else if (strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NULL",4) == 0){
				sprintf(buf, "%s~%s~~DSC~DSI~ERR", buf,norme[NbNorme]);
				}
				else{
					sprintf(buf, "%s~%s~~BDT~BDT~ERR", buf,pDiscount[tbl[idx]].db_pat.NORME_CF);
				}
			}
			else
			{
				if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) == 0){
					sprintf(buf, "%s~%s~~BDT~BDT~NODSC", buf, sz_Norm_cf);
				}
				else {
					sprintf(buf, "%s~%s~~BDT~BDT~ERR", buf, sz_Norm_cf);
				}
			}
		}
		else if (strncmp(sz_Norm_cf,"EBS",3)== 0){
			if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) == 0){
				sprintf(buf, "%s~%s~~DSC~DSI~NODSC", buf, pDiscount[tbl[idx]].db_pat.NORME_CF);
			}
			else if (strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NULL",4) == 0){
				sprintf(buf, "%s~%s~~DSC~DSI~ERR", buf,norme[NbNorme]);
			}
			else {
				sprintf(buf, "%s~%s~~DSC~DSI~ERR", buf, pDiscount[tbl[idx]].db_pat.NORME_CF);
			}
		}
		else
		{
			if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) == 0){
				sprintf(buf, "%s~%s~~DSC~DSI~NODSC", buf, sz_Norm_cf);
			}
			else {
				sprintf(buf, "%s~%s~~%s~DSI~ERR", buf, sz_Norm_cf, sz_Patcat_ct);
			}
		}
    }

    for (i_an = 0; i_an < PATTERNSII_ANNEES  ; i_an++) /* Updated for Phase1b Migration */
    {
		sprintf(buf, "%s~%s", buf,ptb_InRec_Cur[CML_AN1+i_an]);
    }
	if(strncmp(ptb_InRec_Cur[CML_PATTERN_ID],"NODSC",5) ==0){
		fprintf(Kp_OutputBatch, "%s~~~No discount for this grouping~%f~%s\n", buf,total, TempACMTRS3) ; //MOD1
	}
	else {
		fprintf(Kp_OutputBatch, "%s~~~Pattern non trouvee~%f~%s\n", buf,total, TempACMTRS3) ; //MOD1
	}
	NbNorme++;
	}
	
	free(monnaie);
	
  return OK;
}



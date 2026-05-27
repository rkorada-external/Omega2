/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC2061.c
 Revision                      : $Revision: 1.0 $
 Date de creation              : 10/10/2018
 Auteur                        : Quentin Desmettre
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
    Calculation of the investment Income cashflow only if funds held are signed on the contract
------------------------------------------------------------------------------
 Historique des modifications :
[01]  05/10/2020 Charles Socie	SPIRA: 90301 FHNI - audit trail 
[02]  13/10/2020 Charles Socie	SPIRA: 90316 FHNI - Variable - No calculation 
==============================================================================*/


/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include "ESTC3001A.h"
#include "ESTC2060.h"

/*--------------------------------------------*/
/* Rupture variables                          */
/*--------------------------------------------*/
T_RUPTURE_VAR bd_ruptFWHNotBooked;

T_RUPTURE_SYNC_VAR bd_ruptSORT_CSF;  /* rupture variable for MERGE_SORT_CASHFLOW file 	 (ESTC2061_I2) */

T_RUPTURE_SYNC_VAR bd_ruptSORT_RMTP; /* rupture variable for MERGE_SORT_REMAINTOPAY file (ESTC2062_I2) */
T_RUPTURE_SYNC_VAR bd_ruptPATTERN_FWH; /* rupture variable for the PATTERN FWH file		 (ESTC2062_I3) */

/*--------------------------------------------*/
/* File variables							  */
/*--------------------------------------------*/
FILE *Kp_InputPATTERN_FWH;

FILE *Kp_OutputRMTP_FHNI;

/*--------------------------------------------*/
/* Functions prototypes						  */
/*--------------------------------------------*/
int n_InitFWHNotBooked          ( T_RUPTURE_VAR * pbd_Rupt );
int n_ActionLigneFWHNotBooked   ( char ** ptb_InRecCur );

int n_InitStatSORT_RMTP			( T_RUPTURE_SYNC_VAR  *pbd_Rupt );

int n_ConditionSyncSORT 		( char **pbd_InRecOwner,  char **pbd_InRecChild  );
int n_ActionLigneSORT_RMTP		( char **pbd_InRecOwner,  char **pbd_InRecChild  );

void LoadingPattern 			();
long getFileNbLine  			(FILE * fl);
void freeTable      			(char** tab);
char** split        			(char* chaine, const char* delim, int vide);
T_FPATTERNSII_FWH getPattern	(int rateIndex, char * currency);

double *CalculationFixedRate	(double rate, char ** currentline);
double *CalculationVariableRate	(double * rate, char ** currentline);
int WritingOutput				(FILE * OutputFile, double * output_rate, char ** currentLine, int isFixed);

/*--------------------------------------------*/
/* Definition of constants and private macros */
/*--------------------------------------------*/

#define DEBUG 0

char ** pbd_InRecNotBooked;

char ** pdb_InRecPatternFWH;

double Calcul[PATTERNSII_ANNEES];
int bool_csf = 0;

int nb_Pattern = 0;
int bool_pattern = 0;
T_FPATTERNSII_FWH * pPattern;

char asm_ret[2] = "A";		//Assume or internal retro

int RETURN_VAL_MOD(int ret);
int bool_newCSFrow = 0; // 1- means new row.
T_CSUOE_RETRO *  tdb_AssumeForRetro;
/*==============================================================================
 Object :
   Entry of the program

 Parameter(s) :
   int argc    : Number of arguments on command line;
   char **argv : parameters

 Return :
   If there is an issue, exit with ExitPgm(ERRCODE)
   else system call exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
	
	/* Init of signals */
	InitSig () ;
	
	#if DEBUG == 1
		printf("appel de main \n");
	#endif

	if (n_BeginPgm(argc, argv) == ERR) 
		ExitPgm(ERR_XX, "Issue when calling function n_BeginPGM.");
	
	strncpy(asm_ret,psz_GetCharArgv(1), strlen(psz_GetCharArgv(1)));
	
	
	/* Opening of the input file FSEGPATTERNFWH.dat */
	if ( n_OpenFileAppl ( "ESTC2061_I3","rt",&Kp_InputPATTERN_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	/* Opening of the output file EST_SIMU_CASHFLOW.dat */
	if ( n_OpenFileAppl ( "ESTC2061_O1","wt",&Kp_OutputRMTP_FHNI ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Init of the variable bd_ruptFWHNotBooked */
	if ( n_InitFWHNotBooked( &bd_ruptFWHNotBooked ) )
		ExitPgm( ERR_XX , "" );
	
	/* Init of the variable bd_ruptSORT_RMTP */
	if ( n_InitStatSORT_RMTP( &bd_ruptSORT_RMTP ) )
		ExitPgm( ERR_XX , "" );

	/* Loading of the pattern file in memory */
	LoadingPattern();

	/* treatment of the file GTSII_NOTBOOKED_FWH */
	if ( n_ProcessingRuptureVar( &bd_ruptFWHNotBooked ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Closing of opened files */
	if ( n_CloseFileAppl( "ESTC2061_I1", &(bd_ruptFWHNotBooked.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2061_I2", &(bd_ruptSORT_RMTP.pf_InputFil) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC2061_I3", &Kp_InputPATTERN_FWH ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC2061_O1", &Kp_OutputRMTP_FHNI ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	free(pPattern);
	
	exit(OK);
}

/*==============================================================================
 Object :
   Initialisation of the rupture variable for the file GTSII_NOTBOOKED_FWH 

 Parameter(s) :
   T_RUPTURE_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitFWHNotBooked( T_RUPTURE_VAR * pbd_Rupt )
{
	DEBUT_FCT( "n_InitFWHNotBooked" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );
	
	#if DEBUG == 1
		printf("appel de n_InitFWHNotBooked \n");
	#endif

	/* Opening of the input file GTSII_NOTBOOKED_FWH */
	if ( n_OpenFileAppl ( "ESTC2061_I1","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 0;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFWHNotBooked;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
	
}

/*==============================================================================
 Object :
   Actions to do for the current line of the file GTSII_NOTBOOKED_FWH

 Parameter(s) :
   char ** ptb_InRecCur : current line

 Return :
   OK
==============================================================================*/
int n_ActionLigneFWHNotBooked   ( char ** ptb_InRecCur )
{
	
	DEBUT_FCT( "n_ActionLigneFWHNotBooked" );
	
	#if DEBUG == 1
		printf("appel de n_ActionLigneFWHNotBooked \n");
	#endif
	
	if (strcmp(ptb_InRecCur[FWH_CTRTYP_NF],asm_ret) != 0){
			RETURN_VAL(OK);
	}
	
	if(tdb_AssumeForRetro != NULL){
		free(tdb_AssumeForRetro);
	}
		
	tdb_AssumeForRetro = malloc( RETRO_BUF * sizeof (T_CSUOE_RETRO));
	
	bool_newCSFrow=1; 			//New row
	n_ProcessingRuptureSyncVar(&bd_ruptSORT_RMTP, ptb_InRecCur);
	
	RETURN_VAL(OK);
	
}

/*==============================================================================
 Object :
   Initialisation of the rupture variable for the file MERGE_SORT_REMAINTOPAY

 Parameter(s) :
   T_RUPTURE_SYNC_VAR * pbd_Rupt : rupture variable

 Return :
   If there is an issue, return ERR
   else return OK
==============================================================================*/
int n_InitStatSORT_RMTP( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatSORT_RMTP" );
	
	#if DEBUG == 1
		printf("appel de n_InitStatSORT_RMTP \n");
	#endif

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* Opening of the input file EST_GTSII_CASHFLOW */
	if ( n_OpenFileAppl ( "ESTC2061_I2","rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Number of rupture to manage */
	pbd_Rupt->n_NbRupture = 0;

	/* Synchronisation test between the master and the child */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncSORT;

	/* Function called on the current line in the CASHFLOW file */
	pbd_Rupt->n_ActionLigne = n_ActionLigneSORT_RMTP;
	
	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
 Object :
   Key of the synchronization between FCTRFWH and MERGE_SORT_REMAINTOPAY file

 Parameter(s) :
   char **pbd_InRecOwner : FCTRFWH file
   char **pbd_InRecChild : MERGE_SORT_REMAINTOPAY file 

 Return :
   If the lines have the same keys, return 0
   else return the result of the first strcmp with a difference
==============================================================================*/
int n_ConditionSyncSORT (char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncSORT" );
	
    if (strcpy (tdb_AssumeForRetro[0].CUR_CF,  pbd_InRecChild[CML_CUR_CF]) != 0){
		bool_newCSFrow =1;
	}
			
	if (bool_newCSFrow == 1){
		bool_newCSFrow = 0;
		strcpy (tdb_AssumeForRetro[0].CTR_NF,  pbd_InRecChild[CML_CTR_NF]);
		tdb_AssumeForRetro[0].END_NT = atoi(pbd_InRecChild[CML_END_NT]);
		tdb_AssumeForRetro[0].SEC_NF = atoi(pbd_InRecChild[CML_SEC_NF]);
		tdb_AssumeForRetro[0].UWY_NF = atoi(pbd_InRecChild[CML_UWY_NF]);
		tdb_AssumeForRetro[0].UW_NT  = atoi(pbd_InRecChild[CML_UW_NT])  ;
		strcpy (tdb_AssumeForRetro[0].CUR_CF,  pbd_InRecChild[CML_CUR_CF]);
	}
	
	if ( strcmp( "A" , asm_ret ) == 0 ){
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_SSD_CF], pbd_InRecChild[CML_SSD_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_ESB_CF], pbd_InRecChild[CML_ESB_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_SEC_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_UWY_NF], pbd_InRecChild[CML_UWY_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_END_NT] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_UW_NT], pbd_InRecChild[CML_UW_NT] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
//		if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
	}else{
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_SSD_CF], pbd_InRecChild[CML_SSD_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_CTR_NF], pbd_InRecChild[CML_RETCTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
        if ( ( ret = strcmp( pbd_InRecOwner[FWH_END_NT], pbd_InRecChild[CML_RETEND_NT] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));		
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_SEC_NF], pbd_InRecChild[CML_RETSEC_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		//if ( ( ret = strcmp( pbd_InRecOwner[FWH_UW_NT], pbd_InRecChild[CML_RETUW_NT] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_PLC_NT], pbd_InRecChild[CML_PLC_NT] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( pbd_InRecOwner[FWH_RTO_NT], pbd_InRecChild[CML_RTO_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if ( ( ret = strcmp( tdb_AssumeForRetro[0].CTR_NF, pbd_InRecChild[CML_CTR_NF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		if (  tdb_AssumeForRetro[0].END_NT != atoi(pbd_InRecChild[CML_END_NT]) ) RETURN_VAL(RETURN_VAL_MOD(1));
		if (  tdb_AssumeForRetro[0].SEC_NF != atoi(pbd_InRecChild[CML_SEC_NF]) ) RETURN_VAL(RETURN_VAL_MOD(1));
		if (  tdb_AssumeForRetro[0].UWY_NF != atoi(pbd_InRecChild[CML_UWY_NF]) )RETURN_VAL(RETURN_VAL_MOD(1));
		if (  tdb_AssumeForRetro[0].UW_NT  != atoi(pbd_InRecChild[CML_UW_NT]) ) RETURN_VAL(RETURN_VAL_MOD(1));
		if ( ( ret = strcmp( tdb_AssumeForRetro[0].CUR_CF, pbd_InRecChild[CML_CUR_CF] ) ) != 0 ) RETURN_VAL(RETURN_VAL_MOD(ret));
		
	}

	RETURN_VAL( 0 );
	
}

/*==============================================================================
 Object :
   Actions to do each time the files FCTRFWH and MERGE_SORT_REMAINTOPAY are synchronized correctly

 Parameter(s) :
   char **pbd_InRecOwner : FCTRFWH file
   char **pbd_InRecChild : MERGE_SORT_REMAINTOPAY file 

 Return :
   OK
==============================================================================*/
int n_ActionLigneSORT_RMTP(
	char **pbd_InRecOwner ,  /* line in the NOTBOOKED file */
	char **pbd_InRecChild  ) /* line in the RMTP file */
{
	DEBUT_FCT( "n_ActionLigneSORT_RMTP" );
	
	#if DEBUG == 1
		printf("appel de n_ActionLigneSORT_RMTP \n");
	#endif
	
	int i;
	
	T_FPATTERNSII_FWH pattern;
	
	double fixed_rate;
	double variable_rate[PATTERNSII_ANNEES];
	double * output_rate = NULL;
	int isFixed;
	
	if( atoi(pbd_InRecOwner[FWH_CLMFUNVARINT_B]) == 0)
	{
		fixed_rate = atof(pbd_InRecOwner[FWH_CLMFUNINT_R]);
		output_rate = CalculationFixedRate(fixed_rate, pbd_InRecChild);
		isFixed = 1;
	}
	else
	{
		/* Synchronisation with the PATTERN file */
		//n_ProcessingRuptureSyncVar(&bd_ruptPATTERN_FWH, pbd_InRecOwner);
		
		pattern = getPattern(atoi(pbd_InRecOwner[FWH_CLMFUNVARBASE_CT]), pbd_InRecChild[CML_CUR_CF]);
		
		if (bool_pattern == 1)
		{		
			for (i=0;i<PATTERNSII_ANNEES;++i)
				variable_rate[i] = pattern.AN[i];
		
			strcpy(pbd_InRecChild[CML_PATTERN_ID], pattern.PATTERN_ID);
			output_rate = CalculationVariableRate(variable_rate, pbd_InRecChild);
			bool_pattern = 0;
			isFixed = 0;
		}
	}
	
	if (output_rate != NULL) {

		WritingOutput(Kp_OutputRMTP_FHNI, output_rate, pbd_InRecChild,isFixed);
	}
	
	RETURN_VAL(OK);
}

/*==============================================================================
 Object :
   Load the Pattern file in memory in the variable pPattern

 Parameter(s) :

 Return :
   none
==============================================================================*/
void LoadingPattern()
{
	#if DEBUG == 1
		printf("appel de LoadingPattern \n");
	#endif
	
  // on va déterminer le nombre de ligne , et donc le nombre de pattern à charger
  nb_Pattern  = getFileNbLine(Kp_InputPATTERN_FWH) ;
  
  char buffer[LONGBUF];
  char **tab = NULL;
  size_t compteur = 0;
  int i;

  memset(buffer, 0, sizeof(buffer));
  // en cas d'erreur on sort en affichant un message
  if (nb_Pattern > 0 )
  {
    //on retaille le tableau de devise
    pPattern = malloc( nb_Pattern * sizeof (T_FPATTERNSII_FWH));

    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputPATTERN_FWH) != NULL)
    {
		tab = split(buffer, SEPARATEUR_SPLIT , 1);
		strncpy(pPattern[compteur].CUR_CF, tab[PAT_CUR_CF], 3);
		strncpy(pPattern[compteur].PATTERN_ID, tab[PAT_PATTERN_ID], strlen(tab[PAT_PATTERN_ID]));
		pPattern[compteur].RATEINDEX_CT =  atoi(tab[PAT_RATEINDEX_CT]);
		for (i=0;i<PATTERNSII_ANNEES;++i)
			pPattern[compteur].AN[i] = atof(tab[PAT_AN1+i]);
		
		compteur++;
		freeTable(tab);
    }
  }
}

/* -----------------------------------------------------------------------*/
/*   Fonction    : int getFileNbLigne(FILE *fl)                */
/*  Description : Renvoi le nombre de ligne dans un fichier              */
/*  ATTENTION   : Remet la position au début du  fichier            */
/* -----------------------------------------------------------------------*/
long getFileNbLine(FILE * fl)
{
	#if DEBUG == 1
		printf("appel de getFileNbLine \n");
	#endif
	
  long nbline = 0;
  char lg[LONGBUF];
  rewind(fl); // on se remet au début
  while ( fgets(lg, LONGBUF, fl) != NULL)  nbline++;
  rewind(fl);
  return nbline;
}

// procedure de vidage du tableau
void freeTable(char** tab)
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

T_FPATTERNSII_FWH getPattern(int rateIndex, char * currency)
{
	#if DEBUG == 1
		printf("appel de getPattern \n");
	#endif
	
	T_FPATTERNSII_FWH pattern;
	
	int i = 0;

// [02] delete in while && pPattern[i].RATEINDEX_CT <= rateIndex
	while (i < nb_Pattern)
	{
		if ( pPattern[i].RATEINDEX_CT == rateIndex)
		{
			pattern = pPattern[i];
			bool_pattern = 1;
		}
		++i;
	}
	
	return pattern;
}

double * CalculationFixedRate (double rate, char ** currentLine)
{
	
	#if DEBUG == 1
		printf("appel de CalculationFixedRate \n");
	#endif
	
	int i;
	
	memset( Calcul, 0, sizeof( Calcul ) );
	Calcul[0] = rate * ( (currentLine[CML_AM01_MC] != NULL ? atof(currentLine[CML_AM01_MC]):0) + (currentLine[CML_ACMAMT_MC]!=NULL?atof(currentLine[CML_ACMAMT_MC]):0)) / 2;
	
	for (i=1;i<PATTERNSII_ANNEES;++i)
	{
		Calcul[i] = rate * ((currentLine[CML_AM01_MC+i] != NULL ? atof(currentLine[CML_AM01_MC+i]):0) + (currentLine[CML_AM01_MC+i-1]!=NULL?atof(currentLine[CML_AM01_MC+i-1]):0)) / 2;
	}
	
	RETURN_VAL(Calcul);
}


double * CalculationVariableRate (double * rate, char ** currentLine)
{
	
	#if DEBUG == 1
		printf("appel de CalculationVariableRate \n");
	#endif
	
	int i;
	
	memset( Calcul, 0, sizeof( Calcul ) );
	Calcul[0] = rate[0] * ( (currentLine[CML_AM01_MC] != NULL ? atof(currentLine[CML_AM01_MC]):0) + (currentLine[CML_ACMAMT_MC]!=NULL?atof(currentLine[CML_ACMAMT_MC]):0)) / 2;
	for (i=1;i<PATTERNSII_ANNEES;++i)
	{
		Calcul[i] = rate[i] * (atof(currentLine[CML_AM01_MC+i]) + atof(currentLine[CML_AM01_MC+i-1])) / 2;
	}
	
	RETURN_VAL(Calcul);
}


int WritingOutput (FILE * OutputFile, double * output_rate, char ** currentLine, int isFixed)
{
	
	#if DEBUG == 1
		printf("appel de WritingOutput \n");
	#endif
	
	double v_total = 0;      /* temporary variable for total of years */
	char total_buf[LONGBUF]; /* temporary buffer for total of years */
	int i;
	
	char   buf[LONGBUF]; /* Output buffer */
	char * outputLine[CML_AMT_EURO];
	
	memset ( outputLine, 0, sizeof( outputLine ) );
	
	for(i=0;i<CML_AMT_EURO;++i) {
		outputLine[i] = currentLine[i];
	}
	
	if (strncmp(outputLine[CML_ACMTRS3_NT2],"7029",4) == 0 && strncmp(outputLine[CML_ACMTRS_NT],"702",3) == 0){
		outputLine[CML_ACMTRS3_NT2] = "4011";
	}
	else if((strncmp(outputLine[CML_ACMTRS_NT],"702",3) == 0 && strncmp(outputLine[CML_ACMTRS3_NT2],"7029",4) != 0) || strncmp(outputLine[CML_ACMTRS_NT],"902",3) == 0){
		outputLine[CML_ACMTRS3_NT2] = "4010";
	}
	
	outputLine[CML_PATCAT_CT] = "CSF";
	outputLine[CML_PATTYP_CT] = "FHNI";
	outputLine[CML_ACMTRS_NT] = "401";
	
	/* sum of the 65 years calculated */
	for(i=0;i<PATTERNSII_ANNEES;++i)
		v_total += output_rate[i];
	
	sprintf(total_buf, "%f", v_total);
	
	outputLine[CML_TOTAUX_MC] = total_buf;
	outputLine[CML_ACMAMT_MC] = "0";
	outputLine[CML_AMT_MC] = "0";
	
	if(isFixed == 0){
		outputLine[CML_PATTERN_ID] = currentLine[CML_PATTERN_ID];
	} else {
		outputLine[CML_PATTERN_ID] = "0";
	}


	
	/* add the first column */
	sprintf(buf, "%s", outputLine[CML_SSD_CF]);
	
	/* add columns before years columns */
	for (i=CML_ESB_CF;i<CML_AM01_MC;++i)
		sprintf(buf, "%s~%s", buf, outputLine[i]);
	
	for (i=0;i<PATTERNSII_ANNEES;++i)
		sprintf(buf, "%s~%f", buf, output_rate[i]);
	
	/* add columns after years columns */
	for (i=CML_COEF_LOB;i<=CML_ACMTRS3_NT2;++i)
		sprintf(buf, "%s~%s", buf, outputLine[i]);
	
	fprintf(OutputFile, "%s\n", buf);
	
	RETURN_VAL (OK);
	
}

int RETURN_VAL_MOD(int ret){
	bool_newCSFrow= 1;
 	return ret;
}

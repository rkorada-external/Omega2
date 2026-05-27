/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1051.c
r�vision                      : $Revision: 1.0 $
date de cr�ation              : 20/04/2012
auteur                        : Roger Cassis
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:23802 - Ajout 8 informations au fichier format GT+3 cols
                 ACMTRS_NT,ACMAMT_MC,ACMCUR_CF,Seg,Lob,Nat,Type,Prs

------------------------------------------------------------------------------
historique des modifications :
[01] 29/08/2012 R. Cassis :spot:24041 - Solvency 2.
[02] 19/10/2012 -=Dch=-   :spot:24041 - Solvency 2.
[03]  20/01/2013 P. Pezout :spot:24698 ajout de la fonction is_TRT pour distinguer les natures P et F
[04]  20/01/2013 C. Despret :spot:25427 Modification de la fonction is_TRT pour distinguer les natures P et F pour 1B
                                        1er caractere du no de contrat = F->Facultative, T->Treaty                                          
[05]  12/05/2013 C. Despret :spot:25427 Passage de 20000 a 100000 pour la taille max du tableau des TRSLNK
[06]  09/01/2014 C. Despret :spot:28055 Suppression ecrasement memoire lors de l'affectation fin de ligne du tableau dans FilsSansPere
[07]  02/04/2015 P. Menant  :spot:26391 EST49, inclure les depots et les faire pointer vers des patterns CLACC ou CLRET
[08]  08/07/2015 Florent    :spot:29641 gestion retro interne
[09]  11/05/2016 S.Behague  :spot:30583 Spira 41148 
[10]  15/10/2018 C.Socie    IFRS17 EXT-IFRS17-903240 - REQ 10.03 - Cash flow: Flexibility on patterns to be apply on grouping 3
[11]  21/01/2019 L.ELFAHIM    Spira 68072 EBS - Cash Flow Table - Transactional Currency 
[13]  30/01/2019 Charles Socie : REQ 10.3 spira 73132 & 67648
[14] 21/01/2020 Charles Socie : SPIRA 82557 : EBS - Future - Currency
[15] 26/08/2020 HR : SPIRA 82685 : struct.h
[16] 19/01/2021 Charles Socie : SPIRA 93182 :  CSF calculation- Convert 1010, 2010,2013 and 2019 in EGPI currency before cahsflow calculation
[16] 16/03/2022 Charles Socie : SPIRA 101998 :  EBS - RET pattern KO
================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
//[005]
//#define Kn_MaxPostes 100000	/* Le nombre max de postes est fixe a 100000 */

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii; /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE   *Kp_OutputFilErr; /* pointeur sur le fichier de sortie avec les ligne passé en anomalie [10] */
FILE   *Kp_InputCurrency;     /* pointeur sur le fichier en entree des cours de change */  


T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptStatGta; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */

T_CURQUOT  * pDevise;


char ErrorMessageTcode[3000];
char ErrorMessageACMTRS3[3000];


static double GetTaux( char ssd_cf, short year, char* curency, char* targetcurrency );
int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLignePerUw     ( char **pbd_InRec_Cur );
int n_InitStatGta		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneStatGta   ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncStatGta ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ActionFilsSansPere(char **  ptb_InRecChild);
int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );
void ChargementCurrency();
char** split(char* chaine, const char* delim, int vide);
long  getFileNbLigne(FILE * fl);
void freeTableau(char** tab);


/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
int nb_Devise = 0 ; // pour stocker le nombre de devise chargée dynamiquement
char Ksz_Accret[2];          /* Type de fichier traité : Accept ou Retro (A/R) */
char Ksz_AnneeBilan[5];
char Ksz_Prs[4];
short s_Prs;

int  is_TRT(char *);
char * trim(char *); 
long   ligne=1;

#define SEPARATEUR_SPLIT "~"
#define LONGBUF 3000
#define GTPLUS_ACMTRS_NT   57
#define GTPLUS_ACMTRSL2_NT 58  
#define GTPLUS_ACMTRSL3_NT 59   
#define GTPLUS_TRNTYP_CT   60 	
#define GTPLUS_MAP_ACMTRS_NT   61
#define GTPLUS_PARM1       62

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{

	/* Initialisation des signaux */
	InitSig ();

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* recuperation des arguments passes au programme */
	strcpy(Ksz_Accret,psz_GetCharArgv(1));
	strcpy(Ksz_AnneeBilan,psz_GetCharArgv(2));
	strcpy(Ksz_Prs,psz_GetCharArgv(3));
	s_Prs = atoi(Ksz_Prs);

	
	// ouverture du fichier en entree des cours de change FCURQUOT  [11]
	if ( n_OpenFileAppl ( "ESTC1051A_I3","rt",&Kp_InputCurrency ) == ERR )
		ExitPgm( ERR_XX , "" );

	
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1051A_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des erreur */
	if ( n_OpenFileAppl ( "ESTC1051A_O2","wt",&Kp_OutputFilErr ) == ERR )
		ExitPgm( ERR_XX , "" );

	//Chargement des CUR_CF dans un tableau
    ChargementCurrency();

	if ( n_CloseFileAppl( "ESTC1051A_I3", &Kp_InputCurrency ) == ERR ) 
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptStatGta */
	if ( n_InitStatGta( &bd_RuptStatGta ) )
		ExitPgm( ERR_XX , "" );

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051A_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051A_I2", &( bd_RuptStatGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051A_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1051A_O2", &Kp_OutputFilErr ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

    free(pDevise);
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
  if (nb_Devise > 0 )
  {
    //on retaille le tableau de devise
    pDevise = malloc( nb_Devise * sizeof (T_CURQUOT));

    // ... et on le charge
    while (fgets( buffer, LONGBUF, Kp_InputCurrency) != NULL)
    { tab = split(buffer, SEPARATEUR_SPLIT , 1);
      pDevise[compteur].c_ssd = atoi(tab[0]);
      strncpy(pDevise[compteur].sz_cur, tab[1], 3);
	  pDevise[compteur].s_uwy = atoi(tab[2]);
	  pDevise[compteur].d_quot = atof(tab[3]);
      compteur++;
      freeTableau(tab);
    }
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
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1051A_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 0;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{

	DEBUT_FCT( "n_ActionLignePerUw" );

	/* synchronisation avec le fichier DTSTATGTXX */
	n_ProcessingRuptureSyncVar( &bd_RuptStatGta, ptb_InRec_Cur );

	RETURN_VAL( OK );
}



/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitStatGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatGta" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1051A_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncStatGta;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneStatGta;

	//if(*Ksz_Accret=='R')
		pbd_Rupt->n_FilsSansPere=n_ActionFilsSansPere;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}




/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncStatGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncStatGta" );

	if ( strcmp(Ksz_Accret, "A") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GT_SEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;
	}
	if ( strcmp(Ksz_Accret, "R") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTSII_RETCTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTSII_RETEND_NT] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[GTSII_RETSEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTSII_RTY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTSII_RETUW_NT] ) ) != 0 ) return ret;
	}

	RETURN_VAL( 0 );
}

/*==============================================================================
objet :
   	Recherche le cours de la devise d'origine de la filaile c_ssd et
	l'exercice s_uwy

retour :
	0 si probleme
	sinon le cours recherche
==============================================================================*/
static double GetTaux( char ssd_cf, short year, char* curency, char* targetcurrency ){
  // on va recherche la devise correspondant à la référence
  double d_QuotOrig = 0;
  double d_QuotDest = 1; 
  int count = 0;
  int compteur = 0;/* Added for Phase1b Migration */
  for (compteur = 0 ; compteur < nb_Devise; compteur ++)  /* Updated for Phase1b Migration */
  {
    if ( ssd_cf == pDevise[compteur].c_ssd &&  year == pDevise[compteur].s_uwy && (strncmp( curency, pDevise[compteur].sz_cur, 3) == 0 || strncmp( targetcurrency, pDevise[compteur].sz_cur, 3) == 0 ))
    {
      // on a trouvé la devise
	  if (strncmp( curency, pDevise[compteur].sz_cur, 3) == 0 ){
		  d_QuotOrig = pDevise[compteur].d_quot;
		  count += 1;
	  }
	  else {
		  d_QuotDest = pDevise[compteur].d_quot;
		  count += 1;
	  }
	  if(count == 2){
		  break;
	  }
    }
  }
      if( d_QuotDest <= 0 )
        RETURN_VAL ( (double)(-1));
    if( d_QuotOrig <= 0 )
        RETURN_VAL ( (double)(-1));
	
  RETURN_VAL(d_QuotOrig/d_QuotDest);	
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneStatGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

	//char	 *FctrestSii[64]; /* tableau de pointeur a l'image du fichier en sortie */
	char   sz_Trncod[9];
	char   sz_AcmTrs[6];
	char   sz_AcmAmt[25];
	char   sz_Nat[2];
	char   sz_Cur[4];
	char   sz_Patcat0[3];
	char   sz_Patcat[6];
	char   sz_Seglob[15];
//	char   sz_AcmTrs3[6];
	double d_AcmAmt = 0;     /* montant acceptation ou retrocession */
	
	double d_Ratio;      // ratio: cours montant de prime/cours aliment [11]
	char   MsgAno[300];  // message anomalie   [11]
	
	//int    i;
	long   l_AcmTrs;
	//int    n_indice_trn = 0;
	//int    n_indice_acmtrs = 0;
	char buf[3000];
	char BufferAno[100];
	int j;


	DEBUT_FCT( "n_ActionLigneStatGta" );

	memset( sz_Cur, 0, sizeof( sz_Cur ) );
	memset( sz_Nat, 0, sizeof( sz_Nat ) );
	memset( sz_Patcat, 0, sizeof( sz_Patcat ) );
	memset( sz_Seglob, 0, sizeof( sz_Seglob ) );
	memset( BufferAno,0,sizeof(BufferAno));

 
	sprintf(buf, "%s", ptb_InRecChild[GT_SSD_CF]);
	for (j=GT_ESB_CF;j<GT_DETTRS_CF-1;j++){
		  sprintf(buf, "%s~%s", buf, ptb_InRecChild[j]);
	}

	if ( *ptb_InRecChild[GTSII_TRNCOD_CF] == 0 ){
		sprintf(ErrorMessageTcode, "Transaction code does not belong to any grouping level 751 (TTRSLNK table)");
		fprintf(Kp_OutputFilErr, "%s~%s\n",buf , ErrorMessageTcode);
		RETURN_VAL(OK);
	}
	else if ( *ptb_InRecChild[GTPLUS_MAP_ACMTRS_NT] == 0){
		sprintf(ErrorMessageACMTRS3, "The grouping level 751 %s does not exist in the cash flow pattern mapping table (TPRSMAP)",  ptb_InRecChild[GTPLUS_ACMTRSL3_NT] );//Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL3_NT);
		fprintf(Kp_OutputFilErr, "%s~%s\n",buf , ErrorMessageACMTRS3);
		RETURN_VAL(OK);
	}
    // [09]
    if ( *ptb_InRecChild[GTPLUS_TRNTYP_CT] == '3' )
    {
        // Si les postes comptables du local GAAP, TRNTYP_CT = 3
        RETURN_VAL(OK);
    }
    
	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
		n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );
 		RETURN_VAL(OK);
	}

	// [001]

	// Pour l'accept 1er traitement 
	if (((*Ksz_Accret=='A') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
			|| ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='2') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='4'))))
	{
		if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			//fac
				strcpy(sz_Nat,"F");
		else
			if (atoi(ptb_InRecOwner[PER_NAT_CF]) < 30 ) 
				strcpy(sz_Nat,"P");
			else 
				strcpy(sz_Nat,"N");
	}
	else
	{
		if(*Ksz_Accret=='A')	
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
			//*sz_Nat='P';
		}
		else
			strcpy (sz_Nat,ptb_InRecChild[GTSII_NAT_CF]);
	}
		
	memset(sz_Trncod, 0, sizeof(sz_Trncod));
	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[GTSII_TRNCOD_CF] );
			
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	 d_Ratio = 1; 

	if( strncmp(ptb_InRecChild[GTSII_ACMTRS2_NT],"105",3) == 0 || strncmp(ptb_InRecChild[GTSII_ACMTRS2_NT],"205",3) == 0 || strncmp(ptb_InRecChild[GTSII_ACMTRS2_NT],"320",3) == 0
	|| strncmp(ptb_InRecChild[GTSII_ACMTRS3_NT2],"1010",4) == 0 || strncmp(ptb_InRecChild[GTSII_ACMTRS3_NT2],"2010",4) == 0 || strncmp(ptb_InRecChild[GTSII_ACMTRS3_NT2],"2013",4) == 0 || strncmp(ptb_InRecChild[GTSII_ACMTRS3_NT2],"2019",4) == 0){
		if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
		{
			d_AcmAmt = atof( ptb_InRecChild[GTSII_RETAMT_M] );
			
			if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_PCPCUR_CF] ) )
				sprintf( sz_Cur, "%s", "EUR" );
			else			
				sprintf( sz_Cur, "%s", ptb_InRecOwner[PER_PCPCUR_CF] );	

			if ( strcmp(Ksz_Accret, "R") == 0 && strcmp( ptb_InRecChild[GTSII_RETCUR_CF], sz_Cur ) != 0 )
			{
				d_Ratio = GetTaux((char) atoi( ptb_InRecChild[GTSII_SSD_CF] ), atoi( ptb_InRecChild[GTSII_BALSHEY_NF] ), ptb_InRecChild[GTSII_RETCUR_CF], sz_Cur );
			}		
		}
		else
		{
			d_AcmAmt = atof( ptb_InRecChild[GTSII_AMT_M] );
					
			if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_EGPCUR_CF] ) )
				sprintf(sz_Cur, "%s", ptb_InRecChild[GTSII_CUR_CF] );
			else
				sprintf(sz_Cur, "%s", ptb_InRecOwner[PER_EGPCUR_CF] );

			if ( strcmp( ptb_InRecChild[GTSII_CUR_CF], sz_Cur ) != 0 )
			{
				d_Ratio = GetTaux((char) atoi( ptb_InRecChild[GTSII_SSD_CF] ), atoi( ptb_InRecChild[GTSII_BALSHEY_NF] ), ptb_InRecChild[GTSII_CUR_CF], sz_Cur );
			}
		}

	// generation d'une anomalie si la fonction ne trouve pas de cours de devises [11] 
		if ( d_Ratio < 0 )
		{

			if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
			{
				sprintf( MsgAno, "The rates of retro currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
						 ptb_InRecChild[GTSII_RETCUR_CF], ptb_InRecOwner[PER_PCPCUR_CF], ptb_InRecChild[GTSII_RETCTR_NF],  ptb_InRecChild[GTSII_RETEND_NT], ptb_InRecChild[GTSII_RETSEC_NF], ptb_InRecChild[GTSII_RTY_NF], ptb_InRecChild[GT_UW_NT], ptb_InRecChild[GT_BALSHEY_NF] );
			}
			else
			{
				sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
						 ptb_InRecChild[GTSII_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_CTR_NF],  ptb_InRecChild[GT_END_NT], ptb_InRecChild[GT_SEC_NF], ptb_InRecChild[GT_UWY_NF], ptb_InRecChild[GT_UW_NT], ptb_InRecChild[GT_BALSHEY_NF] );
			}
			n_WriteAno( MsgAno );
			// montant positionne a zero 
			d_AcmAmt = 0;
			sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );
		}
		else{
			// conversion du montant acceptation en devise aliment 

			d_AcmAmt *= d_Ratio;
			sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );
		}
	}
	else{
		sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );
	}

	/* Synchro du fichier trslnk afin de recuperer ACMTRS_NT */
	l_AcmTrs=*ptb_InRecChild[GTPLUS_ACMTRS_NT] == 0 ? 0 : atof(ptb_InRecChild[GTPLUS_ACMTRS_NT]) ;
		
	snprintf( sz_AcmTrs, 6, "%ld", l_AcmTrs );              // [007]

 	if (strcmp(ptb_InRecChild[GTPLUS_PARM1],"") == 0 ){
		strcpy(sz_Patcat0, "NA");
	}
	else if ((strcmp(ptb_InRecChild[GTPLUS_PARM1], "CL")) == 0 )    // [010]
		strcpy(sz_Patcat0, "CL");
	else
		strcpy(sz_Patcat0, "PR");


	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		sprintf(sz_Patcat, "%sACC", sz_Patcat0);
	else
		sprintf(sz_Patcat, "%sRET", sz_Patcat0);

	if ((*Ksz_Accret=='R') && (*sz_Nat=='P' || *sz_Nat=='F') && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
	{
			sprintf(sz_Seglob, "%s", ptb_InRecChild [GTSII_SEGLOB_CF]);
	}
	else
	{	
		if (*sz_Nat =='N' && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
		{
			sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_LOB_CF],ptb_InRecChild[GTSII_RTY_NF]);
		}
		else
		{
			if ( strlen(trim(ptb_InRecOwner[PER_SEG_NF]))== 0 )
			{
				if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
				{
					sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_UWY_NF] );
				}
				else 
					sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_RTY_NF] );
			}
			else
			{
				if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
				{
					sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_SEG_NF],	ptb_InRecChild[GTSII_UWY_NF] );
				}
				else 
					sprintf(sz_Seglob, "%s%s", ptb_InRecOwner[PER_SEG_NF],	ptb_InRecChild[GTSII_RTY_NF]);
			}
	 	}
	}
	
	ptb_InRecChild[GTSII_ACMTRS_NT] = ptb_InRecChild[GTPLUS_ACMTRSL2_NT];
	if ( b_IsBlankOrEmpty(sz_Cur)){
		//si Retro on dois modifié les deux colonne Retro en plus 
		if( strcmp(Ksz_Accret, "R") == 0 ){
			ptb_InRecChild[GTSII_ACMAMT_MC] = ptb_InRecChild[GTSII_RETAMT_M];
			ptb_InRecChild[GTSII_ACMCUR_CF] = ptb_InRecChild[GTSII_RETCUR_CF];
		}
		else{
		ptb_InRecChild[GTSII_ACMAMT_MC] = ptb_InRecChild[GTSII_AMT_M];
		ptb_InRecChild[GTSII_ACMCUR_CF] = ptb_InRecChild[GTSII_CUR_CF];
		}
	}
	else{
		if( strcmp(Ksz_Accret, "R") == 0 ){
			ptb_InRecChild[GTSII_RETAMT_M] = sz_AcmAmt;
			ptb_InRecChild[GTSII_RETCUR_CF] = sz_Cur;
		}
		ptb_InRecChild[GTSII_ACMAMT_MC] = sz_AcmAmt;
		ptb_InRecChild[GTSII_AMT_M] = sz_AcmAmt;
		ptb_InRecChild[GTSII_ACMCUR_CF] = sz_Cur;
		ptb_InRecChild[GTSII_CUR_CF] = sz_Cur;
	}
	ptb_InRecChild[GTSII_PRS_CF] = Ksz_Prs;
	if ((*Ksz_Accret=='R') && (*sz_Nat=='P' || *sz_Nat=='F') && (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4' ))
	{
		ptb_InRecChild[GTSII_SEG_NF] = ptb_InRecChild [GTSII_SEG_NF] ;
	}
	else
	{
		ptb_InRecChild[GTSII_SEG_NF] = ptb_InRecOwner[PER_SEG_NF];
	}
	ptb_InRecChild[GTSII_LOB_CF] = ptb_InRecOwner[PER_LOB_CF];
	ptb_InRecChild[GTSII_NAT_CF] = sz_Nat;
	ptb_InRecChild[GTSII_TYP_CT] = ((*ptb_InRecChild[GTSII_TRNCOD_CF] =='1')|| (*ptb_InRecChild[GTSII_TRNCOD_CF] =='3')) ? "A" : "R" ; 
	ptb_InRecChild[GTSII_PATTYP_CT] = sz_Patcat;
	ptb_InRecChild[GTSII_SEGLOB_CF] = sz_Seglob;
	ptb_InRecChild[GTSII_ACMTRS3_NT] = ptb_InRecChild[GTPLUS_ACMTRSL3_NT];
	
    //[08] en cas de retro interne, ne pas ecrire la ligne
	if ( *ptb_InRecOwner[PER_CTRRET_B] == '1'  && strcmp(Ksz_Accret, "A") == 0)
	{
		ptb_InRecChild[GTSII_ACMTRS_NT] = "1";
	}	 
	
	n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );

	RETURN_VAL( OK );
}






/*==============================================================================
// renvoi 1 si TRT, 0 si FAC, -1 si pas une lettre !
==============================================================================*/
int is_TRT(char *contract)
{ 
  char thirdCar;
	thirdCar = toupper(contract[2]);
	
  char firstCar;
	firstCar = toupper(contract[0]);
		
  //[004]
	if(( thirdCar >= 'A' && thirdCar <= 'M') || firstCar == 'F') //'FAC' 
		return 0; 

	if(( thirdCar >= 'N' && thirdCar <= 'Z') || firstCar == 'T')  // Traité
		return 1; 
		
	if( firstCar == 'R')  // Rétro
		return 2; 
		
	
	return -1; 
} 


/*
	Trim permet de supprimer les espaces dans une chaine de caractères,
	si la chaine est vide (longueur =0), elle est retournée tel que.
	si la chaine contient des blancs, ils sont remplacés par des \0 et la chaine est renvoyée
*/
char *trim(char *s) 
{
    char *ptr;
    	
    if (!*s)
        return s;      // handle empty string
    for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
    ptr[1] = '\0';
    return s;
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int n_ActionFilsSansPere(char ** ptb_InRecChild)
{
	char   sz_Trncod[9];
	char   sz_AcmTrs[6];
	char   sz_AcmAmt[25];
	char   sz_Nat[2];
	char   sz_Cur[4];
	char   sz_Patcat0[3];
	char   sz_Patcat[6];
	char   sz_Seglob[15];
	double d_AcmAmt = 0;     /* montant acceptation ou retrocession */
	long   l_AcmTrs;
    char buf[3000];
	char BufferAno[100];
	int j;

	memset( sz_Cur, 0, sizeof( sz_Cur ) );
	memset( sz_Nat, 0, sizeof( sz_Nat ) );
	memset( sz_Patcat, 0, sizeof( sz_Patcat ) );
	memset( sz_Seglob, 0, sizeof( sz_Seglob ) );
	memset( sz_Trncod , 0 , sizeof(sz_Trncod) );
	memset( BufferAno,0,sizeof(BufferAno));

      sprintf(buf, "%s", ptb_InRecChild[GT_SSD_CF]);
      for (j=GT_ESB_CF;j<GT_DETTRS_CF-1;j++){
              sprintf(buf, "%s~%s", buf, ptb_InRecChild[j]);
       }

	if ( *ptb_InRecChild[GTSII_TRNCOD_CF] == 0 ){
		sprintf(ErrorMessageTcode, "Transaction code does not belong to any grouping level 751 (TTRSLNK table)");
		fprintf(Kp_OutputFilErr, "%s~%s\n",buf , ErrorMessageTcode);
		RETURN_VAL(OK);
	}
	else if ( *ptb_InRecChild[GTPLUS_MAP_ACMTRS_NT] == 0){
		sprintf(ErrorMessageACMTRS3, "The grouping level 751 %s does not exist in the cash flow pattern mapping table (TPRSMAP)",  ptb_InRecChild[GTPLUS_ACMTRSL3_NT] );//Ktbd_FBOTRSLNK[n_indice_trn].ACMTRSL3_NT);
		fprintf(Kp_OutputFilErr, "%s~%s\n",buf , ErrorMessageACMTRS3);
		RETURN_VAL(OK);
	}
	
    // [09]
    if ( *ptb_InRecChild[GTPLUS_TRNTYP_CT] == '3' )
   {
       // Si les postes comptables du local GAAP, TRNTYP_CT = 3
       RETURN_VAL(OK);
   }
    	
	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
		n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );
 		RETURN_VAL(OK);
	}


	if (*Ksz_Accret=='A')
	{
		if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
		}
		else 
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				if (is_TRT(ptb_InRecChild[GT_CTR_NF]) < 0)
					strcpy(sz_Nat,"N");
				else
					strcpy(sz_Nat,"P");
	}
	else
	{
		if(*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
		{
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"N");
		}
		else 
			if (is_TRT(ptb_InRecChild[GT_CTR_NF]) == 0)
			{
				//fac
				strcpy(sz_Nat,"F");
			}
			else
				strcpy(sz_Nat,"P");
	}	
	
	sz_Nat[1] = 0;

	

	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[GTSII_TRNCOD_CF] );
	sz_Trncod[8]=0;


		
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	if (*ptb_InRecChild[GTSII_TRNCOD_CF] == '2' || *ptb_InRecChild[GTSII_TRNCOD_CF] == '4')
	{
		d_AcmAmt = atof( ptb_InRecChild[GTSII_RETAMT_M] );
		sprintf( sz_Cur, "%s", ptb_InRecChild[GTSII_RETCUR_CF] );
	}
	else
	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
	{	
		d_AcmAmt = atof( ptb_InRecChild[GTSII_AMT_M] );
		sprintf( sz_Cur, "%s", ptb_InRecChild[GTSII_CUR_CF] );
	}
	sprintf( sz_AcmAmt, "%-.3f", d_AcmAmt );

	// [001]
	/* Synchro du fichier trslnk afin de recuperer ACMTRS_NT */
	l_AcmTrs=*ptb_InRecChild[GTPLUS_ACMTRS_NT] == 0 ? 0 : atof(ptb_InRecChild[GTPLUS_ACMTRS_NT]) ;
		
	snprintf( sz_AcmTrs, 6, "%ld", l_AcmTrs );             // [007]

	if (strcmp(ptb_InRecChild[GTPLUS_PARM1],"") == 0 ){
		strcpy(sz_Patcat0, "NA");
	}
	else if ((strcmp(ptb_InRecChild[GTPLUS_PARM1], "CL")) == 0 )    // [010]
		strcpy(sz_Patcat0, "CL");
	else
		strcpy(sz_Patcat0, "PR");

	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
		sprintf(sz_Patcat, "%sACC", sz_Patcat0);
	else
		sprintf(sz_Patcat, "%sRET", sz_Patcat0);

	if ((*Ksz_Accret=='A') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
	{
			sprintf(sz_Seglob, "*%s",   ptb_InRecChild[GTSII_UWY_NF] );
	}
	else
	{
			sprintf(sz_Seglob, "*%s", ptb_InRecChild[GTSII_RTY_NF] );
	}	
	
	//[006] Ecrasement memoire car GTSII_NBCOL+ 1 pointe au-dela du tableau : valeur max = GTSII_NBCOL
	//[006] Cela est deja fait par la ligne qui met "0" dans FctrestSii[GTSII_NBCOL] en fin de fonction...
	//[006] FctrestSii[GTSII_NBCOL+ 1]= NULL;


	if ( b_IsBlankOrEmpty(sz_Cur)){
		//si Retro on dois modifié les deux colonne Retro en plus 
		if( strcmp(Ksz_Accret, "R") == 0 ){
			ptb_InRecChild[GTSII_ACMAMT_MC] = ptb_InRecChild[GTSII_RETAMT_M];
			ptb_InRecChild[GTSII_ACMCUR_CF] = ptb_InRecChild[GTSII_RETCUR_CF];
		}
		else{
			ptb_InRecChild[GTSII_ACMAMT_MC] = ptb_InRecChild[GTSII_AMT_M];
			ptb_InRecChild[GTSII_ACMCUR_CF] = ptb_InRecChild[GTSII_CUR_CF];
		}
	}
	else{
		if( strcmp(Ksz_Accret, "R") == 0 ){
			ptb_InRecChild[GTSII_RETAMT_M] = sz_AcmAmt;
			ptb_InRecChild[GTSII_RETCUR_CF] = sz_Cur;
		}
		ptb_InRecChild[GTSII_ACMAMT_MC] = sz_AcmAmt;
		ptb_InRecChild[GTSII_AMT_M] = sz_AcmAmt;
		ptb_InRecChild[GTSII_ACMCUR_CF] = sz_Cur;
		ptb_InRecChild[GTSII_CUR_CF] = sz_Cur;
	}
	
	ptb_InRecChild[GTSII_ACMTRS_NT] = ptb_InRecChild[GTPLUS_ACMTRSL2_NT];
	//ptb_InRecChild[GTSII_ACMAMT_MC] = ptb_InRecChild[GTSII_AMT_M];
	//ptb_InRecChild[GTSII_ACMCUR_CF] = ptb_InRecChild[GTSII_CUR_CF];
	ptb_InRecChild[GTSII_PRS_CF] = Ksz_Prs;
	ptb_InRecChild[GTSII_SEG_NF] ="";
 	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3')))
		ptb_InRecChild[GTSII_SEG_NF] ="*";
	ptb_InRecChild[GTSII_LOB_CF] = "";
	ptb_InRecChild[GTSII_NAT_CF] = sz_Nat;
	if((*ptb_InRecChild[GTSII_TRNCOD_CF]=='1') || (*ptb_InRecChild[GTSII_TRNCOD_CF]=='3'))
	{
		ptb_InRecChild[GTSII_TYP_CT] = "A" ;
	}
	else 
		ptb_InRecChild[GTSII_TYP_CT] = "R" ;
	ptb_InRecChild[GTSII_PATTYP_CT] = sz_Patcat;
	ptb_InRecChild[GTSII_SEGLOB_CF] = sz_Seglob;
	ptb_InRecChild[GTSII_ACMTRS3_NT] = ptb_InRecChild[GTPLUS_ACMTRSL3_NT];
	
	n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );

 	RETURN_VAL(OK);
}




/*==============================================================================
nom de l'application          : Generation des Ultimates EBS
nom du source                 : ESTC2055.c
revision                      : 
date de creation              : 28/03/2017
auteur                        : Roger Cassis
references des specifications : :spira:60188
squelette de base             : batch
------------------------------------------------------------------------------
description :  Generation d'un fichier FULTIMATES à partir de celui d'IFRS en affectant les valeurs des ratios de la segmentation EBS

------------------------------------------------------------------------------
historique des modifications :
[01]   <07/03/2018>   spira60188: <MZM>    Remplacement du mode actuarial 'R' par 'S'
[02]   <30/05/2018>   spira60188: <MZM>    Prise en compte du mode actuarial issu de FSEGEST 
[03]   <27/07/2021>   :spira:67106 <RC>    Si pas de synchro sur l'exercice FSEGEST, on synchronise avec l'exercice 8888 de FSEGEST
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"
#include "estutil.c"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define LGTH_SEGEST 100
#define NB_SEGEST_MAX 10000

/*----------------------------------*/
/* Position des champs dans le fichier des Ultimates */
#define ULTIM_SSD_CF			5
#define ULTIM_UWY_NF			3
#define ULTIM_SEG_NF			100
#define ULTIM_AMORAT_CT   102     /* [01] */
#define ULTIM_ACTCLMAMT_M	104
#define ULTIM_ACTLOSRAT_R	105

/*----------------------------------*/
/* Position des champs dans le fichier des segments */
#define SEPARATOR 	 "~"
#define SEG_SSD_CF     0
#define SEG_SEG_NF     1
#define SEG_UWY_NF     2
#define SEG_CUR_CF     3
#define SEG_SEGNAT_CT  4
#define SEG_CLMAMT_M   5
#define SEG_LOSRAT_R   6
#define SEG_AMORAT_CT  7
/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE     *Kp_InputFilSegest ;     /* pointeur sur le fichier FSEGEST */
FILE 		*Kp_OutputFilUltimates ; /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR  	   bd_RuptPer ; /* variable de gestion de la rupture sur le perimetre */

T_SEGEST_SOLVENCY	Ktbd_Segest[NB_SEGEST_MAX] ; 	/* tableau permettant de charger en memoire FSEGEST */
int Kn_NbLig_Segest ;    	/* nombre de postes dans le tableau */

int n_InitUltim	     ( T_RUPTURE_VAR *pbd_Rupt );
int n_ActionLigneUltim ( char **pbd_InRec_Cur ) ;
int n_ChargerTSEGEST   ( void ) ;
int n_RechPosteTSEGEST ( char c_ssd, char *sz_seg, int n_uwy ) ;

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	char	c_ReturnStatus = 0 ;

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Recuperation des arguments */

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC2055_O1","wt",&Kp_OutputFilUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FSEGEST */
	if ( n_OpenFileAppl ( "ESTC2055_I2","rb",&Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement de TSEGEST en memoire */
	Kn_NbLig_Segest = n_ChargerTSEGEST( ) ;
	//printf("Kn_NbLig_Segest : %d\n",Kn_NbLig_Segest);

	/* Initialisation de la variable bd_RuptPer */
	if ( n_InitUltim( &bd_RuptPer ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2055_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2055_I2", &Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2055_O1", &Kp_OutputFilUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit( c_ReturnStatus ) ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Ultim »

retour :
	OK
==============================================================================*/
int n_InitUltim( T_RUPTURE_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitUltim" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2055_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	//pbd_Rupt->ConditionEndSync = n_ConditionSyncDlGtaa;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUltim;
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
int n_ActionLigneUltim( char **ptb_InRec_Cur )
{
	char  sz_LOSRAT_R[30] ;    /* zone de travail */
	char  sz_CLMAMT_M[30] ;    /* zone de travail */
	char  sz_Seg[12];
	int   n_indice = 0;
	int	n_Ssd = 0;
	int	n_Uwy = 0;

	DEBUT_FCT( "n_ActionLigneUltim" ) ;

	/* Recherche dans le fichier FSEGEST */
	/*************************************/

	n_Ssd = (char) atoi( ptb_InRec_Cur[ULTIM_SSD_CF] );
	n_Uwy = atoi( ptb_InRec_Cur[ULTIM_UWY_NF] );
	strcpy(sz_Seg, ptb_InRec_Cur[ULTIM_SEG_NF]);
	n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy);
  //printf("n_indice : %d - n_Ssd : %d - n_Uwy : %d - sz_Seg : %s\n",n_indice,n_Ssd,n_Uwy,sz_Seg);	

	if (n_indice > 0)
	{
		sprintf(sz_LOSRAT_R, "%-.8lf", Ktbd_Segest[n_indice].LOSRAT_R);
		ptb_InRec_Cur[ULTIM_ACTLOSRAT_R] = sz_LOSRAT_R;
		sprintf(sz_CLMAMT_M, "%-.3lf", Ktbd_Segest[n_indice].CLMAMT_M);
		ptb_InRec_Cur[ULTIM_ACTCLMAMT_M] = sz_CLMAMT_M;
		
		//[02]
		ptb_InRec_Cur[ULTIM_AMORAT_CT] = &Ktbd_Segest[n_indice].AMORAT_CT;
		
		/* printf("VERIF ptb_InRec_Cur[ULTIM_AMORAT_CT] =%s \n", ptb_InRec_Cur[ULTIM_AMORAT_CT]);
		 printf("02 VERIF ptb_InRec_Cur[ULTIM_AMORAT_CT] =%s ; sz_Seg=%s ; n_Uwy=%d ;ULTIM_SSD_CF=%d \n", ptb_InRec_Cur[ULTIM_AMORAT_CT], sz_Seg, n_Uwy, n_Ssd );		 
		*/
		
	}
	else
	{
		ptb_InRec_Cur[ULTIM_ACTLOSRAT_R] = "0.00000000";
		ptb_InRec_Cur[ULTIM_ACTCLMAMT_M] = "0.000";
	}		
		

	/*********************************/
	/* Ecriture du fichier en sortie */
	/*********************************/

//printf("n_indice 3 : %d - ULTIM_ACTLOSRAT_R : %s - ULTIM_ACTCLMAMT_M : %s\n",n_indice,ptb_InRec_Cur[ULTIM_ACTLOSRAT_R],ptb_InRec_Cur[ULTIM_ACTCLMAMT_M]);	
	n_WriteCols ( Kp_OutputFilUltimates, ptb_InRec_Cur, SEPARATEUR, 0 );
      
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
        Lit le fichier binaire FSEGEST et le charge en memoire

==============================================================================*/
int n_ChargerTSEGEST( void )
{
	int i = 0 ;
	char sz_message[200];

	DEBUT_FCT("n_ChargerTSEGEST");

	char buffer[LGTH_SEGEST];
	char **tab=NULL;
	while (fgets( buffer, LGTH_SEGEST, Kp_InputFilSegest)!= NULL)
	{
		tab = split(buffer, SEPARATOR ,1);
		Ktbd_Segest[i].SSD_CF = atoi(tab[SEG_SSD_CF]);
		//Pour le segment spéciale * on ne prend que ce caractère !
		if ( tab[SEG_SEG_NF][0] == '*')
			strcpy(Ktbd_Segest[i].SEG_NF, "*");
		else
			strcpy(Ktbd_Segest[i].SEG_NF, tab[SEG_SEG_NF]);
		Ktbd_Segest[i].UWY_NF = atoi(tab[SEG_UWY_NF]);
		strcpy(Ktbd_Segest[i].CUR_CF, tab[SEG_CUR_CF]);
		Ktbd_Segest[i].SEGNAT_CT = *tab[SEG_SEGNAT_CT];
		Ktbd_Segest[i].CLMAMT_M = atof(tab[SEG_CLMAMT_M]);
		Ktbd_Segest[i].LOSRAT_R = atof(tab[SEG_LOSRAT_R]);
		Ktbd_Segest[i].AMORAT_CT = *tab[SEG_AMORAT_CT];
		i++;
		if ( i > NB_SEGEST_MAX )
		{
			sprintf(sz_message,"la taille du tableau Ktbd_Segest depasse la taille allouee %d", i);
			n_WriteAno(sz_message);
			RETURN_VAL( i );
		}
	}

	RETURN_VAL( i );
}

/*==============================================================================
objet :
        fonction de recherche du segment/filiale/exercice
        Si pas trouve, retour -1
retour :

==============================================================================*/
int n_RechPosteTSEGEST( char c_ssd, char *sz_seg, int n_uwy )
{

	DEBUT_FCT("n_RechPosteTSEGEST");
	
	int n_indice, n_ret;

	for( n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )
	{
		// Localisation filiale
		n_ret = (int) c_ssd - Ktbd_Segest[n_indice].SSD_CF;

		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
		else
		{
			// Localisation Segment/exercice
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 ) continue;
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 && Ktbd_Segest[n_indice].UWY_NF == n_uwy ) RETURN_VAL( n_indice );
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 && Ktbd_Segest[n_indice].UWY_NF == 8888 ) RETURN_VAL( n_indice );  // [03]
		}
	}
	RETURN_VAL( -1 );	// Aucune occurence trouvée
}



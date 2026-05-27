/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2311.c
révision                      : $Revision: 1.2 $
date de création              : 16/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   SELECTION DES PROVISIONS ACCEPTATION NP ET FAC

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_POSTES_MAX 2000	/* Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem) */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */
FILE		*Kp_InputFilRetPar ; /* pointeur sur le fichier en entree des conversions de postes retrocession */

T_RUPTURE_VAR 			bd_RuptPerUw ; /* variable de gestion de la rupture sur le fichier des placements */
T_RUPTURE_SYNC_VAR  	   	bd_RuptGt ; /* variable de gestion de la synchronisation avec le GT */

T_RETPAR Ktbd_RetPar[NB_POSTES_MAX] ; 	/* tableau des postes comptables */
int Kn_NbLigRetPar ;			/* nombre de lignes du tableau des postes comptables */

int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitGt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerRETPAR( short s_TrtCod ) ;
int n_RechPoste( char *sz_post ) ;


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
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en sortie GT */
	if ( n_OpenFileAppl ( "ESTC2311_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FRETPAR */
	if ( n_OpenFileAppl ( "ESTC2311_I3","rb",&Kp_InputFilRetPar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

         /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
	/* chargement en memoire du tableau des postes comptables */
	Kn_NbLigRetPar = n_ChargerRETPAR( 715 ) ;
        if ( Kn_NbLigRetPar > NB_POSTES_MAX )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2311_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2311_I2", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2311_I3", &Kp_InputFilRetPar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2311_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
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
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESTC2311_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
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
	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* synchronisation avec le fichier GT */
	if ( ( strcmp( ptb_InRec_Cur[PER_LOB_CF], "30" ) != 0 && strcmp( ptb_InRec_Cur[PER_LOB_CF], "31" ) != 0 ) &&
		( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' || *ptb_InRec_Cur[PER_CTRNAT_CT] == 'F' ) )
		n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre »
	avec l’esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2311_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  int i ;
  char sz_TrnCod[9] ; /* variable intermediaire : poste comptable */

  DEBUT_FCT( "n_ActionLignePerUw" ) ;

  /* Si CTR_NF=11xxxxxxx alors ne prendre que les mouvements du GT ayant BALSHRMTH > 9 et UWY>=1998
  if (
      (ptb_InRecOwner[PER_CTR_NF][0]!='1' || ptb_InRecOwner[PER_CTR_NF][1]!='1' ||
       atoi(ptb_InRecOwner[PER_UWY_NF])>=1998 || atoi(ptb_InRecChild[GT_BALSHRMTH_NF]) > 9) &&
      (ptb_InRecOwner[PER_CTR_NF][0]!='1' || ptb_InRecOwner[PER_CTR_NF][1]!='1' ||
       ptb_InRecOwner[PER_CTR_NF][2]!='T' ||
       atoi(ptb_InRecOwner[PER_UWY_NF])!=1998 || atoi(ptb_InRecChild[GT_BALSHRMTH_NF]) > 9) &&
      (ptb_InRecOwner[PER_CTR_NF][0]!='1' || ptb_InRecOwner[PER_CTR_NF][1]!='1' ||
       ptb_InRecOwner[PER_CTR_NF][2]!='Z' ||
       atoi(ptb_InRecOwner[PER_UWY_NF])!=1998 || atoi(ptb_InRecChild[GT_BALSHRMTH_NF]) > 9)
     )
    */
      /* Recherche du DETTRS_CF correspondant au poste comptable */
      if ( ptb_InRecChild[GT_TRNCOD_CF][0] == '1' &&  ptb_InRecChild[GT_TRNCOD_CF][7] == '0' )
	{
	  /* recherche de l'indice de la table */
	  i = n_RechPoste( ptb_InRecChild[GT_TRNCOD_CF] ) ;

	  if ( i != -1 )
	    {
	      /* on pointe sur une zone de travail */
	      ptb_InRecChild[GT_TRNCOD_CF] = sz_TrnCod ;

	      /* memorisation du poste comptable */
	      strcpy( sz_TrnCod, Ktbd_RetPar[i].DETTRS_CF ) ;

	      /* les 2 prefixes sont forces a 1 et le suffixe a 0 */
	      sz_TrnCod[0] = '1' ;
	      sz_TrnCod[1] = '1' ;
	      sz_TrnCod[7] = '0' ;

	      /* ecriture en sortie dans le GT */
	      n_WriteCols( Kp_OutputFilGt, ptb_InRecChild, SEPARATEUR, 0 ) ;
	    }
	}

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire et le charge en memoire

==============================================================================*/
int n_ChargerRETPAR( short s_TrtCod )
{
	int i = 0 ;
        char MsgAno[300];

	DEBUT_FCT("n_ChargerRETPAR");

	while ( fread( &Ktbd_RetPar[i], sizeof( T_RETPAR ), 1, Kp_InputFilRetPar ) == 1 )
	{
		if ( Ktbd_RetPar[i].PRS_CF == s_TrtCod )
			i += 1 ;
                if ( i > NB_POSTES_MAX )
                 {

                          sprintf(MsgAno,"la taille du tableau Ktbd_RetPar depasse la taille allouee %d", i);
                          n_WriteAno(MsgAno);
                          RETURN_VAL( i );
                 }

	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du poste
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int n_indice, ret;

	DEBUT_FCT("n_RechPoste");

	n_indice = 0 ;

	while ( 1 == 1 )
	{
		/* Comparaison des codes */
		ret = strcmp( sz_poste, Ktbd_RetPar[n_indice].TRNCOD_CF );

		/* S'ils sont egaux, retourner l'indice */
		if ( ret == 0 ) RETURN_VAL( n_indice );

		/* Si la ligne est passee, retourner -1 (echec) */
		if ( ret < 0 ) RETURN_VAL( -1 );

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if ( n_indice >= Kn_NbLigRetPar ) RETURN_VAL( -1 );
	}
}







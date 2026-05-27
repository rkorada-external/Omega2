/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0007.c
revision                      : $Revision:   1.2  $
date de creation              : 24/09/1997
auteur                        : S. Llorente
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, retournant le contenu
	de la table TCLIENT 
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

-------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/


FILE  *Kp_OutputFilClient ;
 

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);

static CS_RETCODE n_RowFetchRetPar (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
CS_RETCODE n_Processing ();

/*----------------------------------------------------------------------------*/
 
/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(  int argc,  char *argv[]   )
{
	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
	   ExitPgm (ERR_XX, "");

	if (n_Connect () != CS_SUCCEED) 
	   ExitPgm (ERR_XX, "");
     
	if (n_OpenFileAppl ("ESTX0007_O1","wb",&Kp_OutputFilClient) == ERR )
	   ExitPgm (ERR_XX, "");

	if (n_Processing () != CS_SUCCEED) 
	   ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX0007_O1",&Kp_OutputFilClient) == ERR )
	   ExitPgm (ERR_XX, "");
        
	if (n_Disconnect () != CS_SUCCEED) 
	   ExitPgm (ERR_XX, "");

	if (n_EndPgm () == ERR)
	   ExitPgm (ERR_XX, "");

	exit (OK);
}


/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TCLIENT

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_RowFetchRetPar( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode;
	T_TCLIENT bd_Lu;

	DEBUT_FCT ("n_RowFetchRetPar") ;

	bd_Lu.CLI_NF = n_GetIntValue( pbd_utctlib, 0 ) ;
	bd_Lu.CLISSD_NF = c_GetTinyintValue( pbd_utctlib, 1 ) ;

	if ( fwrite( &bd_Lu, sizeof( T_TCLIENT ), 1, Kp_OutputFilClient ) <= 0 ) 
		RETURN_VAL(CS_FAIL);

	RETURN_VAL( CS_SUCCEED ) ;
}


/*==============================================================================
objet : 
   Lancement du traitement destine a ramener des lignes de la base.

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
CS_RETCODE n_Processing ()
{
	CS_RETCODE retcode;
	T_UTCTLIB  bd_utctlib;

	DEBUT_FCT("n_Processing");
	
	/* Initialise bd_utctlib avec la connection globale */
	n_SetGlobalUtctlib( &bd_utctlib ) ;
	bd_utctlib.n_RowFetchData = n_RowFetchRetPar;
	retcode = n_ProcessingProc( &bd_utctlib, 0, "BCLI..PsCLIENT_110" ) ;

	RETURN_VAL(retcode);
}


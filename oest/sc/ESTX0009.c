/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0009.c
revision                      : $Revision: 1$
date de creation              : 15/10/2018
auteur                        : C. SOCIE
references des specifications :
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, retournant le contenu
	de la table TMAPPING
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

-------------------------------------------------------------------------------
_________________

[001] HR SPIRA 82685 : struct.h
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include <struct.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/


FILE  *Kp_OutputFilTrsLnk ;


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

	if (n_OpenFileAppl ("ESTX0009_O1","wb",&Kp_OutputFilTrsLnk) == ERR )
	   ExitPgm (ERR_XX, "");

	if (n_Processing () != CS_SUCCEED)
	   ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX0009_O1",&Kp_OutputFilTrsLnk) == ERR )
	   ExitPgm (ERR_XX, "");

	if (n_Disconnect () != CS_SUCCEED)
	   ExitPgm (ERR_XX, "");

	if (n_EndPgm () == ERR)
	   ExitPgm (ERR_XX, "");

	exit (OK);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TRSLNK

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_RowFetchRetPar( T_UTCTLIB *pdb_utctlib )
{

	T_TMAPPING bd_Lu;

	DEBUT_FCT ("n_RowFetchRetPar") ;

                                 
	bd_Lu.PRS_CF = s_GetSmallintValue( pdb_utctlib ,0);                                                           
	bd_Lu.ACMTRS_NT = s_GetSmallintValue( pdb_utctlib ,1); 
	strcpy ( bd_Lu.PARM1, pc_GetStringValue	( pdb_utctlib ,2)); 	                                
	strcpy ( bd_Lu.PARM2, pc_GetStringValue	( pdb_utctlib ,3)); 	
	strcpy ( bd_Lu.PARM3, pc_GetStringValue	( pdb_utctlib ,4)); 	
	strcpy ( bd_Lu.PARM4, pc_GetStringValue	( pdb_utctlib ,5)); 	
	strcpy ( bd_Lu.PARM5, pc_GetStringValue	( pdb_utctlib ,6)); 	
	strcpy ( bd_Lu.PARM6, pc_GetStringValue	( pdb_utctlib ,7)); 	
	strcpy ( bd_Lu.PARM7, pc_GetStringValue	( pdb_utctlib ,8)); 	
	strcpy ( bd_Lu.PARM8, pc_GetStringValue	( pdb_utctlib ,9)); 	
	strcpy ( bd_Lu.PARM9, pc_GetStringValue	( pdb_utctlib ,10)); 	
	strcpy ( bd_Lu.PARM10, pc_GetStringValue ( pdb_utctlib ,11)); 	


	if ( fwrite( &bd_Lu, sizeof( T_TMAPPING ), 1, Kp_OutputFilTrsLnk ) <= 0 )
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
	retcode = n_ProcessingProc( &bd_utctlib, 0, "BREF..PsTMAPPING_01" ) ;
	RETURN_VAL(retcode);
}


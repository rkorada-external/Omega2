/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0008.c
revision                      : $Revision: 1.3 $
date de creation              : 11/05/2001
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
_________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           14/10/2008
Version:        8.1
Description:    ESTDOM16211 remplacer PsTBOPRSLNK_01 dans ESCJ0060 par un select  sans recalcul de la table
_________________
MODIFICATION    [002]
Auteur:         G.BUISSON
Date:           28/10/2008
Version:        8.1
Description:    Spot 16211 : Annule la modification précédente et remplace la procédure BSTA_PsTBOPRSLNK_01
                              par BSAR_PsTBOPRSLNK_01
[003]  11/05/2016 S.Behague  :spot:30583 Spira 41148
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
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

	if (n_OpenFileAppl ("ESTX0008_O1","wb",&Kp_OutputFilTrsLnk) == ERR )
	   ExitPgm (ERR_XX, "");

	if (n_Processing () != CS_SUCCEED)
	   ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX0008_O1",&Kp_OutputFilTrsLnk) == ERR )
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
	CS_RETCODE retcode;
	T_FBOTRSLNK bd_Lu;
	char sz_temp[2];

	DEBUT_FCT ("n_RowFetchRetPar") ;

	strcpy ( sz_temp, pc_GetStringValue	( pdb_utctlib ,0));                                  
	bd_Lu.TRSPFX_CF = sz_temp[0] ;                                                           
	bd_Lu.ACMTRSL0_NT = s_GetSmallintValue( pdb_utctlib ,1);                                 
	bd_Lu.ACMTRSL1_NT = s_GetSmallintValue( pdb_utctlib ,2);                                 
	bd_Lu.ACMTRSL2_NT = s_GetSmallintValue( pdb_utctlib ,3);                                 
	bd_Lu.ACMTRSL3_NT = s_GetSmallintValue( pdb_utctlib ,4);                                 
	bd_Lu.ACMTRSLL1_NT = s_GetSmallintValue( pdb_utctlib ,5);
	bd_Lu.ACMTRSLL2_NT = s_GetSmallintValue( pdb_utctlib ,6);
	bd_Lu.TRSTYP_NT = s_GetSmallintValue( pdb_utctlib ,7);                                   
	strcpy ( bd_Lu.DETTRS_CF, pc_GetStringValue	( pdb_utctlib ,8));                          
	strcpy ( bd_Lu.PCPTRS_CF, pc_GetStringValue	( pdb_utctlib ,9));                          
	strcpy ( sz_temp, pc_GetStringValue	( pdb_utctlib ,10));                                  
	bd_Lu.TRS_CF = sz_temp[0] ;                                                              
	strcpy ( bd_Lu.SUBTRS_CF, pc_GetStringValue	( pdb_utctlib ,11));                          
	bd_Lu.ESTIM_NT = s_GetSmallintValue( pdb_utctlib ,12);                                   
	bd_Lu.TRNTYP_CT = s_GetSmallintValue( pdb_utctlib ,13);                                  


	if ( fwrite( &bd_Lu, sizeof( T_FBOTRSLNK ), 1, Kp_OutputFilTrsLnk ) <= 0 )
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
	retcode = n_ProcessingProc( &bd_utctlib, 0, "BSAR..PsTBOPRSLNK_01" ) ;      //[002]
     //retcode = n_ProcessingProc( &bd_utctlib, 0, "BSTA..PsTTRSLNK_01" ) ;      [001] "BSTA..PsTBOPRSLNK_01"
	RETURN_VAL(retcode);
}


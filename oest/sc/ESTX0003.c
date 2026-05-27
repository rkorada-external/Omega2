/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0003.c
revision                      : $Revision:   1.0  $
date de creation              : 19/09/1997
auteur                        : M.Ha-Thuc
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, retournant le contenu
	de la table TRETPAR pour le code traitement 715
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
#include "estserv.h"
/*----------------------*/
/* Variables de travail */
/*----------------------*/


FILE  *Kp_OutputFilRetPar ;
 

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
int main(
   int argc,            /* nombre d'arguments           */
   char *argv[]         /* tableau des parametres       */
   )
{
        InitSig ();
        
        if (n_BeginPgm (argc, argv) == ERR)
           ExitPgm (ERR_XX, "");
  
        if (n_Connect () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
     
	if (n_OpenFileAppl ("ESTX0003_O1","wb",&Kp_OutputFilRetPar) == ERR )
           ExitPgm (ERR_XX, "");
        
        if (n_Processing () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESTX0003_O1",&Kp_OutputFilRetPar) == ERR )
           ExitPgm (ERR_XX, "");
        
        if (n_Disconnect () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
        
        if (n_EndPgm () == ERR)
           ExitPgm (ERR_XX, "");
        
        exit (OK);
}


/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TTRSLNK

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_RowFetchRetPar( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_RETPAR bd_lu;

DEBUT_FCT ("n_RowFetchRetPar") ;

bd_lu.PRS_CF = s_GetSmallintValue( pbd_utctlib, 0 ) ;
strcpy ( bd_lu.TRNCOD_CF, pc_GetStringValue( pbd_utctlib, 1 ) ) ;
strcpy ( bd_lu.DETTRS_CF, pc_GetStringValue( pbd_utctlib, 2 ) ) ;

if ( fwrite( &bd_lu, sizeof( T_RETPAR ), 1, Kp_OutputFilRetPar ) <= 0 ) RETURN_VAL(CS_FAIL);

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
        retcode = n_ProcessingProc( &bd_utctlib, 0, "BEST..PsRETPAR_01" ) ;

        RETURN_VAL(retcode);
}

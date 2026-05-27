/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0006.c
revision                      : $Revision:   1.0  $
date de creation              : 29/09/1997
auteur                        : KUHNA
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, retournant les Numeros filiale
        monnaie et code langue filiale. Ces informations proviennent
        de la table TSUBSID de la base BREF. 
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

        Ce programme est execute en phase preparatoire pour l'edition
        des ecarts entre resultats comptables et theoriques

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

typedef struct {
		unsigned char	SSD;		/*Filiale*/
		char		LAG;		/*Code langue filiale*/
		char    	LIBSSD[17];	/*Libelle filiale*/
		char    	LIBCUR[4];	/*Libelle monnaie*/
	       } T_LIB_SSD;
		

FILE  *Kp_LibSsd;
 

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);

static CS_RETCODE n_retcFetchRowLibSsdLob (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
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
     
  if (n_OpenFileAppl ("ESTX0006_O1","wb",&Kp_LibSsd) == ERR )
    ExitPgm (ERR_XX, "");
        
  if (n_Processing () != CS_SUCCEED) 
    ExitPgm (ERR_XX, "");
        
  if (n_CloseFileAppl ("ESTX0006_O1",&Kp_LibSsd) == ERR )
    ExitPgm (ERR_XX, "");
        
  if (n_Disconnect () != CS_SUCCEED) 
    ExitPgm (ERR_XX, "");
        
  if (n_EndPgm () == ERR)
    ExitPgm (ERR_XX, "");
        
  exit (OK);
}


/*==============================================================================
objet : 
   fonction d'extraction des donnees 

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLibSsdLob(T_UTCTLIB *pbd_utctlib )
{
  CS_RETCODE retcode;
  T_LIB_SSD bd_lu;

  DEBUT_FCT ("n_retcFetchRowLibSsdLob");

  /*Recuperation du numero filiale*/
  bd_lu.SSD = c_GetTinyintValue(pbd_utctlib ,0);

  /* Recuperation des libelles */
  bd_lu.LAG = *(pc_GetStringValue (pbd_utctlib ,1));
  strcpy (bd_lu.LIBSSD, pc_GetStringValue (pbd_utctlib ,2));
  strcpy (bd_lu.LIBCUR, pc_GetStringValue (pbd_utctlib ,3));

  if (fwrite(&bd_lu,sizeof(T_LIB_SSD),1,Kp_LibSsd)<=0)
     RETURN_VAL(CS_FAIL);

  RETURN_VAL(CS_SUCCEED);
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
  n_SetGlobalUtctlib (&bd_utctlib);

  bd_utctlib.n_RowFetchData = n_retcFetchRowLibSsdLob;
  retcode = n_ProcessingProc (&bd_utctlib,0,"BEST..PsSUBSID_03" ) ;

  RETURN_VAL(retcode);
}

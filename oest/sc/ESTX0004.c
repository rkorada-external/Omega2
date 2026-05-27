/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX0004.c
revision                      : $Revision:   1.0  $
date de creation              : 23/09/1997
auteur                        : KUHNA
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, retournant les Numeros filiale et lob
        et pour chaque filiale/lob les libelles filiales, monnaie filiale,
        code langue filiale, libelles lob. Ces informations proviennent
        des tables TSUBSID et TLOBH de la base BREF. 
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire. Il y autant de lignes dans ce fichier que de couples
        (filiale,lob) distincts.

        Ce programme est execute en phase preparatoire pour l'edition
        de synthese inventaire acceptation et retrocession.

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
		char		LOB[3];		/*Lob*/
		char		LAG;		/*Code langue filiale*/
		char    	LIBSSD[17];	/*Libelle filiale*/
		char    	LIBCUR[4];	/*Libelle monnaie*/
		char    	LIBLOB[17];	/*Libelle lob-filiale*/
	       } T_LIB_SSD_LOB;
		

FILE  *Kp_LibSsdLob;
 

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
     
  if (n_OpenFileAppl ("ESTX0004_O1","wb",&Kp_LibSsdLob) == ERR )
    ExitPgm (ERR_XX, "");
        
  if (n_Processing () != CS_SUCCEED) 
    ExitPgm (ERR_XX, "");
        
  if (n_CloseFileAppl ("ESTX0004_O1",&Kp_LibSsdLob) == ERR )
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
  T_LIB_SSD_LOB bd_lu;

  DEBUT_FCT ("n_retcFetchRowLibSsdLob");

  /*Recuperation du numero filiale et numero LOB*/
  bd_lu.SSD = c_GetTinyintValue(pbd_utctlib ,0);
  strcpy(bd_lu.LOB,pc_GetStringValue(pbd_utctlib ,1));

  /* Recuperation des libelles */
  bd_lu.LAG = *(pc_GetStringValue (pbd_utctlib ,2));
  strcpy (bd_lu.LIBSSD, pc_GetStringValue (pbd_utctlib ,3));
  strcpy (bd_lu.LIBCUR, pc_GetStringValue (pbd_utctlib ,4));
  strcpy (bd_lu.LIBLOB, pc_GetStringValue (pbd_utctlib ,5));

  if (fwrite(&bd_lu,sizeof(T_LIB_SSD_LOB),1,Kp_LibSsdLob)<=0)
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
  retcode = n_ProcessingProc (&bd_utctlib,0,"BEST..PsSUBSID_02" ) ;

  RETURN_VAL(retcode);
}

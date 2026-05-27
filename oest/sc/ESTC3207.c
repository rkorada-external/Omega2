/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTC3207.c
revision                      : $Revision:   1.0  $
date de creation              : 30/06/1997
auteur                        : M. HA-THUC
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure, qui transfert la table de parametrage des 
	automatisme en fichier.
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

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *Kp_OutputFilAutPar ; /* pointeur sur le fichier de sortie */

typedef struct  
{
CS_TINYINT		SSD_CF ;
CS_CHAR		CTRNAT_CT ;
CS_CHAR		LOB_CF[3] ;
CS_CHAR		PCPRSKTRY_CF[4] ;
CS_CHAR		SOB_CF[3] ;
CS_FLOAT		LIMPER_R ;
CS_TINYINT		QUANUM_NB ;
} T_AUTPAR ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE  n_retcFetchRowAutPar (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
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
        /* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Stockage de table dans un fichier binaire";
        
        InitSig ();
        
        if (n_BeginPgm (argc, argv) == ERR)
           ExitPgm (ERR_XX, "");
  
        if (n_Connect () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESTC3207_O1","wb",&Kp_OutputFilAutPar) == ERR )
           ExitPgm (ERR_XX, "");
         
        if (n_Processing () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESTC3207_O1",&Kp_OutputFilAutPar) == ERR )
           ExitPgm (ERR_XX, "");
        
        if (n_Disconnect () != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
        
        if (n_EndPgm () == ERR)
           ExitPgm (ERR_XX, "");
        
        exit (OK);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table BEST..TAUTPAR
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowAutPar( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_AUTPAR bd_lu;

DEBUT_FCT ("n_retcFetchRowAutPar");

bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
bd_lu.CTRNAT_CT = *pc_GetStringValue (pbd_utctlib, 1) ;
strcpy (bd_lu.LOB_CF, pc_GetStringValue (pbd_utctlib ,2));
strcpy (bd_lu.PCPRSKTRY_CF, pc_GetStringValue (pbd_utctlib ,3));
strcpy (bd_lu.SOB_CF, pc_GetStringValue (pbd_utctlib ,4));
bd_lu.LIMPER_R = f_GetNumericValue (pbd_utctlib ,5);
bd_lu.QUANUM_NB = c_GetTinyintValue (pbd_utctlib ,6);

if (fwrite(&bd_lu,sizeof(T_AUTPAR),1,Kp_OutputFilAutPar)<=0) 
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

        bd_utctlib.n_RowFetchData = n_retcFetchRowAutPar;
        retcode = n_ProcessingProc (&bd_utctlib,0,"BEST..PsAUTPAR_02");

        RETURN_VAL(retcode);
}


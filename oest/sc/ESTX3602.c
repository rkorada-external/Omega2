/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX3602.c
revision                      : $Revision:   1.1  $
date de creation              : 15/09/1998
auteur                        : M.HA-THUC
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Chargement de la table BEST..TSEGEST en fichier binaire

-------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    22/07/1999    B.MONTAGNAC  Suppression de l'extraction de BEST..TSOBBLOB
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE 	*Kp_Segest ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);

CS_RETCODE n_retcFetchRowSEGEST (T_UTCTLIB *pbd_utctlib) ;

CS_RETCODE n_Processing ();

/*---------------------------------------------------------*/
/* Definition de la structure du fichier binaire en sortie */
/*---------------------------------------------------------*/
typedef struct {
        int         	VRS_NF ;
        unsigned char   SSD_CF ;
        char	        SEGTYP_CT ;
        char            SEG_NF[11] ;
	short		UWY_NF ;
        char		CRE_D[9] ;
	char            CUR_CF[4] ;
	double		PRMAMT_M ;
	double		CLMAMT_M ;
	double		LOSRAT_R ;
	char		AMORAT_CT ;
} T_SEGEST ;



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
 T_UTCTLIB  bd_utctlib;
        
 InitSig ();
        
 if (n_BeginPgm (argc, argv) == ERR)
   ExitPgm (ERR_XX, "");
  
 if (n_LocalConnect (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");

 if (n_OpenFileAppl ("ESTX3602_O1","wb",&Kp_Segest) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_Processing (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");
        
 if (n_CloseFileAppl ("ESTX3602_O1",&Kp_Segest) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");
        
 if (n_EndPgm () == ERR)
   ExitPgm (ERR_XX, "");
        
 exit (OK);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TSEGEST

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
CS_RETCODE  n_retcFetchRowSEGEST( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode;
	T_SEGEST bd_lu;

  	DEBUT_FCT ("n_retcFetchRowSEGEST");

  	/* Alimentation de la structure receptrice */
  	bd_lu.VRS_NF = (int) ( f_GetNumericValue( pbd_utctlib, 0 ) ) ;
	bd_lu.SSD_CF = c_GetTinyintValue( pbd_utctlib, 1 ) ;
        bd_lu.SEGTYP_CT = c_GetTinyintValue( pbd_utctlib, 2 ) ;
        strcpy( bd_lu.SEG_NF, pc_GetStringValue( pbd_utctlib, 3) ) ;
	bd_lu.UWY_NF = s_GetSmallintValue( pbd_utctlib , 4 ) ;
	strcpy( bd_lu.CRE_D, pc_GetStringValue( pbd_utctlib, 5) ) ;
	strcpy( bd_lu.CUR_CF, pc_GetStringValue( pbd_utctlib, 6) ) ;
	bd_lu.PRMAMT_M = f_GetDecimalValue( pbd_utctlib, 7 ) ;
	bd_lu.CLMAMT_M = f_GetDecimalValue( pbd_utctlib, 8 ) ;
	bd_lu.LOSRAT_R = f_GetDecimalValue( pbd_utctlib, 9 ) ;  
	bd_lu.AMORAT_CT = *( pc_GetStringValue( pbd_utctlib, 10 ) ) ;      
  
  	/* Ecriture de la structure receptrice dans le fichier de sortie */
  	if ( fwrite( &bd_lu, sizeof( T_SEGEST ), 1, Kp_Segest ) <= 0 ) 
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
CS_RETCODE n_Processing (T_UTCTLIB  *pbd_utctlib)
{
    CS_RETCODE retcode;

    DEBUT_FCT("n_Processing");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowSEGEST;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSEGEST_01");

    RETURN_VAL(retcode);
}

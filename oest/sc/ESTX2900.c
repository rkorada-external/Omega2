/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX2900.c
revision                      : $Revision:   1.1  $
date de creation              : 08/04/1998
auteur                        : M.HA-THUC
references des specifications : 
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	extraction de la table de BTRAV..TESTACCTRSF ( transformation de
	poste de l'ancien systeme vers OMEGA )
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.
	idem pour la table BREF..TSOBBLOB
	idem pour la table BREF..TDETTRS

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
FILE 	*Kp_Acctrsf, *Kp_Sobblob, *Kp_Dettrs ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);

CS_RETCODE n_retcFetchRowACCTRSF (T_UTCTLIB *pbd_utctlib) ;
CS_RETCODE n_retcFetchRowSOBBLOB( T_UTCTLIB *pbd_utctlib ) ;
CS_RETCODE n_retcFetchRowDETTRS( T_UTCTLIB *pbd_utctlib ) ;
CS_RETCODE n_Processing ();

/*---------------------------------------------------------*/
/* Definition de la structure du fichier binaire en sortie */
/*---------------------------------------------------------*/
typedef struct {
        CS_CHAR         DETTRS_CF[9] ;
        CS_TINYINT	RENV_B ;
        CS_CHAR         PROPCRBTRS_CF[9] ;
        CS_CHAR         NPROPTRS_CF[9] ;
	CS_CHAR         FACTRS_CF[9] ;
        CS_CHAR         IBNRSSDTRS_CF[9] ;
} T_ACCTRSF ;

typedef struct {
	CS_CHAR    	LOB_CF[3] ;
	CS_CHAR    	SOB_CF[3] ;
	CS_CHAR    	PRDCOD_CT[4] ;
} T_SOBBLOB ;

typedef struct {
	CS_CHAR         DETTRS_CF[9] ;
	CS_CHAR         CTRSCOD_CF[9] ;
	CS_TINYINT      TRSTYP_CT ;
	CS_CHAR         RETTRSCOD_CF[9] ;
	CS_TINYINT      RET_B ;
	CS_TINYINT      COMP_B ;
} T_DETTRS;


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

 if (n_OpenFileAppl ("ESTX2900_O1","wb",&Kp_Acctrsf) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_OpenFileAppl ("ESTX2900_O2","wb",&Kp_Sobblob) == ERR )
   ExitPgm ( ERR_XX , "" );

 if (n_OpenFileAppl ("ESTX2900_O3","wb",&Kp_Dettrs) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_Processing (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");
        
 if (n_CloseFileAppl ("ESTX2900_O1",&Kp_Acctrsf) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_CloseFileAppl ("ESTX2900_O2",&Kp_Sobblob)== ERR)
   ExitPgm ( ERR_XX , "" );

 if (n_CloseFileAppl ("ESTX2900_O3",&Kp_Dettrs) == ERR )
   ExitPgm (ERR_XX, "");
        
 if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");
        
 if (n_EndPgm () == ERR)
   ExitPgm (ERR_XX, "");
        
 exit (OK);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TLIFDRI

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
CS_RETCODE  n_retcFetchRowACCTRSF( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_ACCTRSF bd_lu;

  DEBUT_FCT ("n_retcFetchRowACCTRSF");

  /* Alimentation de la structure receptrice */
  strcpy ( bd_lu.DETTRS_CF, pc_GetStringValue( pbd_utctlib, 0 ) ) ;
  bd_lu.RENV_B = c_GetTinyintValue ( pbd_utctlib, 1 ) ;
  strcpy ( bd_lu.PROPCRBTRS_CF, pc_GetStringValue( pbd_utctlib, 2 ) ) ;
  strcpy ( bd_lu.NPROPTRS_CF, pc_GetStringValue( pbd_utctlib, 3 ) ) ;
  strcpy ( bd_lu.FACTRS_CF, pc_GetStringValue( pbd_utctlib, 4 ) ) ;
  strcpy ( bd_lu.IBNRSSDTRS_CF, pc_GetStringValue( pbd_utctlib, 5 ) ) ;
  
  /* Ecriture de la structure receptrice dans le fichier de sortie */
  if ( fwrite( &bd_lu, sizeof( T_ACCTRSF ), 1, Kp_Acctrsf ) <= 0 ) 
    RETURN_VAL(CS_FAIL);

  RETURN_VAL(CS_SUCCEED);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BREF..TSOBBLOB
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
CS_RETCODE  n_retcFetchRowSOBBLOB( T_UTCTLIB *pbd_utctlib )
{
        CS_RETCODE retcode;
        T_SOBBLOB bd_lu;

        DEBUT_FCT ("n_retcFetchRowSOBBLOB");

        strcpy (bd_lu.LOB_CF, pc_GetStringValue (pbd_utctlib ,0));
        strcpy (bd_lu.SOB_CF, pc_GetStringValue (pbd_utctlib ,1));
        strcpy (bd_lu.PRDCOD_CT, pc_GetStringValue (pbd_utctlib ,2)); 

        if (fwrite(&bd_lu,sizeof(T_SOBBLOB),1,Kp_Sobblob)<=0) RETURN_VAL(CS_FAIL
);

        RETURN_VAL(CS_SUCCEED);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BREF..TDETTRS
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
CS_RETCODE  n_retcFetchRowDETTRS( T_UTCTLIB *pbd_utctlib )
{
        CS_RETCODE retcode;
        T_DETTRS bd_lu;

        DEBUT_FCT ("n_FetchRowDETTRS");

        strcpy (bd_lu.DETTRS_CF, pc_GetStringValue (pbd_utctlib ,0));
        strcpy (bd_lu.CTRSCOD_CF, pc_GetStringValue (pbd_utctlib ,1));
        bd_lu.TRSTYP_CT = c_GetTinyintValue (pbd_utctlib ,2);
        strcpy (bd_lu.RETTRSCOD_CF, pc_GetStringValue (pbd_utctlib ,3));
        bd_lu.RET_B = c_GetBitValue (pbd_utctlib ,4);
        bd_lu.COMP_B = c_GetBitValue (pbd_utctlib ,5);

        if (fwrite(&bd_lu,sizeof(T_DETTRS),1,Kp_Dettrs)<=0) RETURN_VAL(CS_FAIL);

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

    pbd_utctlib->n_RowFetchData = n_retcFetchRowACCTRSF;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsESTACCTRSF_01");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowSOBBLOB;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSOBBLOB_01");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowDETTRS;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsDETTRS_11");

    RETURN_VAL(retcode);
}

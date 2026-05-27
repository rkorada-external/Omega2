/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESIX0061.c
revision                      : $Revision:   1.1  $
date de creation              : 02/06/1997
auteur                        : C.Chavatte
references des specifications : ESIIV01F
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 3 procedures. La 1ere lui retourne le contenu
	de la table TSEGPAR, la 2eme celui de TCTRFIC, la 3eme celui de la
	table de pilotage TLIFDRI, la 4eme celui de TTRSLNK.
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
FILE *Kp_segpar, *Kp_ctrfic, *Kp_lifdri, *Kp_trslnk, *Kp_curquot;
FILE *Kp_Dettrs, *Kp_Rettrf, *Kp_Curcvsn;      

FILE* Kp_SubsidFilout;
FILE* Kp_AcmtrshFilout;
FILE* Kp_BanteclFilout;
FILE* Kp_GrpFilout;


static T_INDXCURQUOT Kbd_Adr[MAX_DEVISE] ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
void main (int argc,char* argv[]);
CS_RETCODE n_retcFetchRowSEGPAR (T_UTCTLIB *pbd_utctlib);
CS_RETCODE n_retcFetchRowCTRFIC (T_UTCTLIB *pbd_utctlib);
CS_RETCODE n_retcFetchRowLIFDRI (T_UTCTLIB *pbd_utctlib);
CS_RETCODE n_retcFetchRowTRSLNK (T_UTCTLIB *pbd_utctlib);
CS_RETCODE n_Processing ();
CS_RETCODE n_retcFetchRowCURQUOT(T_UTCTLIB *pdb_utctlib)  ;
CS_RETCODE n_ExtractCurQuot(T_UTCTLIB *pdb_utctlib)  ;
static CS_RETCODE  n_retcFetchRowDETTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowRETTRF( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowCURCVSN( T_UTCTLIB *pbd_utctlib );

static CS_RETCODE  n_retcFetchRowSSD( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowACMTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowUWGRP( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowANO( T_UTCTLIB *pbd_utctlib );



/*----------------------------------------------------------------------------*/
 
/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(
   int argc,            /* nombre d'arguments           */
   char *argv[]         /* tableau des parametres       */
   )
{
        T_UTCTLIB  bd_utctlib;
        
	/* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Stockage des tables dans un fichier binaire";
        
        InitSig ();
        
        if (n_BeginPgm (argc, argv) == ERR)
           ExitPgm (ERR_XX, "");
  
        if (n_LocalConnect (&bd_utctlib) != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O1","wb",&Kp_segpar) == ERR )
           ExitPgm (ERR_XX, "");
 
	if (n_OpenFileAppl ("ESIX0061_O2","wb",&Kp_ctrfic) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_OpenFileAppl ("ESIX0061_O3","wb",&Kp_lifdri) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_OpenFileAppl ("ESIX0061_O4","wb",&Kp_trslnk) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_OpenFileAppl ("ESIX0061_O5","wb",&Kp_curquot) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O6","wb",&Kp_Dettrs) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O7","wb",&Kp_Rettrf) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O8","wb",&Kp_Curcvsn) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_OpenFileAppl("ESIX0061_O9","wb",&Kp_SubsidFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O10","wb",&Kp_AcmtrshFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O11","wb",&Kp_BanteclFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O12","wb",&Kp_GrpFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

        if (n_Processing (&bd_utctlib) != CS_SUCCEED) 
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESIX0061_O1",&Kp_segpar) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O2",&Kp_ctrfic) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESIX0061_O3",&Kp_lifdri) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESIX0061_O4",&Kp_trslnk) == ERR )
           ExitPgm (ERR_XX, "");
        
	if (n_CloseFileAppl ("ESIX0061_O5",&Kp_curquot) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O6",&Kp_Dettrs) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O7",&Kp_Rettrf) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O8",&Kp_Curcvsn) == ERR )
           ExitPgm (ERR_XX, "");
        

	if ( n_CloseFileAppl ("ESIX0061_09",&Kp_SubsidFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O10",&Kp_AcmtrshFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O11",&Kp_BanteclFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O12",&Kp_GrpFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

    if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED) 
        ExitPgm (ERR_XX, "");
        
    if (n_EndPgm () == ERR)
        ExitPgm (ERR_XX, "");
        
    exit (OK);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TSEGPAR

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSEGPAR( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_SEGPAR bd_lu;

DEBUT_FCT ("n_retcFetchRowSEGPAR");

bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
bd_lu.UWGRP_CF = s_GetSmallintValue (pbd_utctlib ,1);
strcpy (bd_lu.ANLCTY_CF, pc_GetStringValue (pbd_utctlib ,2));
strcpy (bd_lu.CLINAT_CF, pc_GetStringValue (pbd_utctlib ,3));
bd_lu.ORDNBR_NT = c_GetTinyintValue (pbd_utctlib ,4);
strcpy (bd_lu.SEG_NF, pc_GetStringValue (pbd_utctlib ,5));

if (fwrite(&bd_lu,sizeof(T_SEGPAR),1,Kp_segpar)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TCTRFIC

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowCTRFIC( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_CTRFIC bd_lu;

DEBUT_FCT ("n_retcFetchRowCTRFIC");

bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
strcpy (bd_lu.LIFTRTTYP_CF, pc_GetStringValue (pbd_utctlib ,1));
bd_lu.UWGRP_CF = s_GetSmallintValue (pbd_utctlib ,2);
strcpy (bd_lu.ANLCTY_CF, pc_GetStringValue (pbd_utctlib ,3));
strcpy (bd_lu.ESTCTR_NF, pc_GetStringValue (pbd_utctlib ,4));

if (fwrite(&bd_lu,sizeof(T_CTRFIC),1,Kp_ctrfic)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TLIFDRI

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLIFDRI( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_LIFDRI bd_lu;

DEBUT_FCT ("n_retcFetchRowLIFDRI");
memset(&bd_lu,0,sizeof(bd_lu));
strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,1);
bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,2);
bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,4);
bd_lu.ACY_NF = s_GetSmallintValue (pbd_utctlib ,5);
bd_lu.BALSHEY_NF = s_GetSmallintValue (pbd_utctlib ,6);
bd_lu.BALSHTMTH_NF = c_GetTinyintValue (pbd_utctlib ,7);
bd_lu.AUTUPD_B = c_GetBitValue (pbd_utctlib ,8);
bd_lu.COMACC_B = c_GetBitValue (pbd_utctlib ,9);
strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,10));
bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,11);
bd_lu.UPD_NF = ' ';
bd_lu.CMT_NT = n_GetIntValue (pbd_utctlib ,12);
strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,13));
strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,14));
strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,15));

if (fwrite(&bd_lu,sizeof(T_LIFDRI),1,Kp_lifdri)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TTRSLNK

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRSLNK( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_TRSLNK bd_lu;

DEBUT_FCT ("n_retcFetchRowTRSLNK");

bd_lu.PRS_CF= s_GetSmallintValue (pbd_utctlib ,0);
bd_lu.ACMTRS_NT= s_GetSmallintValue (pbd_utctlib ,1);
strcpy (bd_lu.DETTRS_CF, pc_GetStringValue (pbd_utctlib ,2));

if (fwrite(&bd_lu,sizeof(T_TRSLNK),1,Kp_trslnk)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}





/*==============================================================================
objet :
   Lancement des 2 procédures

retour :
   En cas de problème, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel système exit()
==============================================================================*/
CS_RETCODE n_ExtractCurQuot(
	T_UTCTLIB		*pdb_utctlib
	)
{
	CS_RETCODE		retcode ;
	
	DEBUT_FCT("n_ExtractCurQuot");
	/*resevation de la place pour l'index au debut du fichier */
        if (fwrite(Kbd_Adr,sizeof(Kbd_Adr),1,Kp_curquot) != 1)
	   RETURN_VAL(CS_FAIL);

	/* Fonction de traitement d'une ligne   */
	pdb_utctlib->n_RowFetchData	= n_retcFetchRowCURQUOT;

	retcode=n_ProcessingProc(pdb_utctlib,0,"BREF..PsCURQUOT_09"); 


	/* ecriture de l'index au debut du fichier */
    	if(fseek(Kp_curquot,0,SEEK_SET)==-1L)
	   RETURN_VAL(CS_FAIL);
        if (fwrite(Kbd_Adr,sizeof(Kbd_Adr),1,Kp_curquot) != 1)
	   RETURN_VAL(CS_FAIL);
	
		
	RETURN_VAL(retcode);
}

/*==============================================================================
objet :
   Traitement d'une ligne, résultat du SELECT de la proc. ps_UTCTLIB_Example_out 

retour :
	on retourne CS_SUCCEED pour continuer le fecth
==============================================================================*/
CS_RETCODE  n_retcFetchRowCURQUOT	 		 (T_UTCTLIB *pdb_utctlib)
{
  CS_RETCODE retcode ;
  T_CURQUOT  bd_Art;
  static char sz_cur[4]="" ;
  static int n_cmpt=0 ;

  /* alimentation de la structure avec les ele de la ligne resultat */
  strcpy(bd_Art.sz_cur, pc_GetStringValue	( pdb_utctlib ,0));
  bd_Art.c_ssd = c_GetTinyintValue ( pdb_utctlib ,1);
  bd_Art.s_uwy = s_GetSmallintValue( pdb_utctlib ,2);
  bd_Art.d_quot= f_GetDecimalValue ( pdb_utctlib ,3);

  if(n_cmpt==0 || strcmp(bd_Art.sz_cur, Kbd_Adr[n_cmpt-1].sz_cur) != 0 )
  {
    strcpy( Kbd_Adr[n_cmpt].sz_cur, bd_Art.sz_cur) ;
    if(n_cmpt==0)
    {
      Kbd_Adr[0].l_Pos = 0 ;  
    }
    else
    {
      Kbd_Adr[n_cmpt].l_Pos=Kbd_Adr[n_cmpt-1].l_Pos+Kbd_Adr[n_cmpt-1].n_Nbr;
    }
    Kbd_Adr[n_cmpt].n_Nbr=0;
    n_cmpt++ ;
  }
  Kbd_Adr[n_cmpt-1].n_Nbr++;
	
  /* ecriture de bd_Art dans le fic kp_curquot */
  if (fwrite(&bd_Art,sizeof(T_CURQUOT),1,Kp_curquot) != 1)
    return(CS_FAIL);

  return(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BREF..TDETTRS
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowDETTRS( T_UTCTLIB *pbd_utctlib )
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
   fonction d'extraction des donnees de la table BREF..TRETTRF
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowRETTRF( T_UTCTLIB *pbd_utctlib )
{
        CS_RETCODE retcode;
        T_RETTRF bd_lu;

        DEBUT_FCT ("n_FetchRowRETTRF");

        strcpy (bd_lu.DETTRS_CF, pc_GetStringValue (pbd_utctlib ,0));
        bd_lu.ACCADMTYP_CT = c_GetTinyintValue (pbd_utctlib ,1);
        bd_lu.RETACCADM_B = c_GetBitValue (pbd_utctlib ,2);
        bd_lu.TRF_B = c_GetBitValue (pbd_utctlib ,3);
        bd_lu.DEL_B = c_GetBitValue (pbd_utctlib ,4);

        if (fwrite(&bd_lu,sizeof(T_RETTRF),1,Kp_Rettrf)<=0) RETURN_VAL(CS_FAIL);

        RETURN_VAL(CS_SUCCEED);
}



/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BRET..TCURCVSN
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowCURCVSN( T_UTCTLIB *pbd_utctlib )
{
        CS_RETCODE retcode;
        T_CURCVSN bd_lu;

        DEBUT_FCT ("n_retcFetchRowCURCVSN");

        strcpy (bd_lu.ACPCUR_CF, pc_GetStringValue (pbd_utctlib ,0));
        bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,1);
        strcpy (bd_lu.RETCTR_NF, pc_GetStringValue (pbd_utctlib ,2)); 
        bd_lu.RTY_NF = s_GetSmallintValue(pbd_utctlib ,3);
        bd_lu.PLC_NT = n_GetIntValue (pbd_utctlib ,4);
        strcpy (bd_lu.ACCCUR_CF, pc_GetStringValue (pbd_utctlib ,5));

        if (fwrite(&bd_lu,sizeof(T_CURCVSN),1,Kp_Curcvsn)<=0) RETURN_VAL(CS_FAIL
);

        RETURN_VAL(CS_SUCCEED);
}



/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSSD( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode=CS_SUCCEED;
	CS_TINYINT SSD_CF;
	CS_CHAR SSD_LS[20];
	T_SUBSID   bd_LibSsd;	/* Libelles filiale (indice issu de Kpn_indice) */

	DEBUT_FCT ("n_retcFetchRowSSD");

	bd_LibSsd.c_SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);

	/* Stockage du libelle et du code langue dans le tableau "par indice" */
	strcpy (bd_LibSsd.sz_LIB, pc_GetStringValue (pbd_utctlib ,1));
	strcpy (bd_LibSsd.sz_LAG_CF, pc_GetStringValue (pbd_utctlib ,2));


	if (fwrite(&bd_LibSsd,sizeof(bd_LibSsd),1,Kp_SubsidFilout)<=0) RETURN_VAL(CS_FAIL);

	RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TACMTRSH

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowACMTRS( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode=CS_SUCCEED;
	T_ACMTRS   bd_LibPoste;/* Libelles des postes d'une filiale */

	DEBUT_FCT ("n_retcFetchRowACMTRS");


	bd_LibPoste.c_SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
	bd_LibPoste.s_ACMTRS_NT = s_GetSmallintValue (pbd_utctlib ,1);
	strcpy(bd_LibPoste.sz_ACMTRS_LS,pc_GetStringValue (pbd_utctlib ,2));

	if (fwrite(&bd_LibPoste,sizeof(bd_LibPoste),1,Kp_AcmtrshFilout)<=0) RETURN_VAL(CS_FAIL);

	RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TBANTECL

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowANO( T_UTCTLIB *pbd_utctlib )
{
	static int n_indice=0;
	CS_RETCODE retcode=CS_SUCCEED;
	T_BANTECL 	bd_bantecl      ;

	DEBUT_FCT ("n_retcFetchRowANO");

	strcpy(bd_bantecl.sz_LAG_CF,pc_GetStringValue (pbd_utctlib ,0));

	bd_bantecl.n_COLVAL_CT 	= n_GetIntValue (pbd_utctlib ,1);
	strcpy(bd_bantecl.sz_COLVAL_LM,pc_GetStringValue (pbd_utctlib ,2));

	if (fwrite(&bd_bantecl,sizeof(bd_bantecl),1,Kp_BanteclFilout)<=0) RETURN_VAL(CS_FAIL);

	RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TGRP

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowUWGRP( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode=CS_SUCCEED;
	T_GRP 		bd_grp       ;

	DEBUT_FCT ("n_retcFetchRowUWGRP");

	bd_grp.s_GRP_CF = s_GetSmallintValue (pbd_utctlib ,0);
	bd_grp.c_SSD_CF = c_GetTinyintValue  (pbd_utctlib ,1);
	strcpy(bd_grp.sz_GRP_LS, pc_GetStringValue (pbd_utctlib ,2));

	if (fwrite(&bd_grp,sizeof(bd_grp),1,Kp_GrpFilout)<=0) RETURN_VAL(CS_FAIL);

	RETURN_VAL(retcode);
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
	char sz_SSDs[101];
	char *sz_COL_LS="EST_ANO21";

	DEBUT_FCT("n_Processing");


	pbd_utctlib->n_RowFetchData = n_retcFetchRowSEGPAR;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSEGPAR_02");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowCTRFIC;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsCTRFIC_02");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRI;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsLIFDRI_03");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowTRSLNK;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsTRSLNK_02");
    
	n_ExtractCurQuot(pbd_utctlib);

    pbd_utctlib->n_RowFetchData = n_retcFetchRowDETTRS;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsDETTRS_11");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowRETTRF;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsRETTRF_01");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowCURCVSN;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsCURCVSN_05");


	pbd_utctlib->n_RowFetchData = n_retcFetchRowSSD	;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBSID_11")	;


	pbd_utctlib->n_RowFetchData = n_retcFetchRowANO;
	n_ProcessingProc (pbd_utctlib,1,"BEST..PsBANTECL_02",
			"@p_col_ls",CS_INPUTVALUE,CS_CHAR_TYPE,sz_COL_LS,9,0);

	pbd_utctlib->n_RowFetchData = n_retcFetchRowACMTRS;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsACMTRSH_02");

	/* Ramene une seule ligne, lue dans Ksz_ungrp */
	pbd_utctlib->n_RowFetchData = n_retcFetchRowUWGRP;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsGRP_03");




    RETURN_VAL(retcode);
}




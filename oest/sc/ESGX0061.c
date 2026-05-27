#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *Kp_segpar, *Kp_ctrfic, *Kp_lifdri, *Kp_trslnk, *Kp_trslnkvret, *Kp_curquot;
FILE *Kp_Dettrs, *Kp_Rettrf, *Kp_Curcvsn, *Kp_Sobblob, *Kp_Segment;

;
FILE  *Kp_CurcvsnIndx, *Kp_OutputFilSsdActr;


static T_INDXCURQUOT Kbd_Adr[MAX_DEVISE] ;


/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);




static CS_RETCODE  n_retcFetchRowCURCVSNIndx( T_UTCTLIB *pbd_utctlib );
CS_RETCODE n_ExtractCurcsvnIndx( T_UTCTLIB              *pdb_utctlib);

CS_RETCODE n_ExecCmdWithFetch() ;


CS_RETCODE n_ExtractCurcsvnIndx( T_UTCTLIB		*pdb_utctlib);
static CS_RETCODE  n_retcFetchRowCURCVSNIndx( T_UTCTLIB *pbd_utctlib );
CS_RETCODE n_ExtractSSDACTR ();
static CS_RETCODE  n_retcFetchRowSSDACTR( T_UTCTLIB *pbd_utctlib);

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
{ //DEBUT

  T_UTCTLIB  bd_utctlib;

	/* alimentation du nom en clair du programme */
  Gbd_Tech.psz_PgmLabel = "Stockage des tables dans un fichier binaire";

  InitSig ();

  if (n_BeginPgm (argc, argv) == ERR) ExitPgm (ERR_XX, "");

  if (n_LocalConnect (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");




  /* Ouverture des fichiers */
	

	if (n_OpenFileAppl("ESGX0061_O1","wb",&Kp_CurcvsnIndx) == ERR ) ExitPgm ( ERR_XX , "" );
	if (n_OpenFileAppl("ESGX0061_O2","wb",&Kp_OutputFilSsdActr) == ERR ) ExitPgm ( ERR_XX , "" );




  if (n_ExtractCurcsvnIndx (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");

  if (n_ExtractSSDACTR (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");



	if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");

	if ( n_CloseFileAppl ("ESGX0061_O1", &Kp_CurcvsnIndx) == ERR )     ExitPgm ( ERR_XX, "" );
	if ( n_CloseFileAppl ("ESGX0061_O2", &Kp_OutputFilSsdActr) == ERR )     ExitPgm ( ERR_XX, "" );



  if (n_EndPgm () == ERR) ExitPgm (ERR_XX, "");

  exit (OK);
}



/*==============================================================================
objet :
   Lancement des 2 proc�dures:0


retour :
==============================================================================*/
CS_RETCODE n_ExtractCurcsvnIndx( T_UTCTLIB		*pdb_utctlib)
{
	CS_RETCODE		retcode ;

	DEBUT_FCT("n_ExtractCurcsvnIndx");	/*resevation de la place pour l'index au debut du fichier */
    memset(Kbd_Adr,0,sizeof(Kbd_Adr)) ;
    if(	fwrite(Kbd_Adr,sizeof(Kbd_Adr),1,Kp_CurcvsnIndx) != 1)
	   RETURN_VAL(CS_FAIL);

	
    retcode = n_ExecCmdWithFetch(pdb_utctlib,	
									"SELECT a.acpcur_cf,a.ssd_cf,a.retctr_nf,a.rty_nf,a.plc_nt,a.acccur_cf FROM    bret..tcurcvsn a ORDER BY acpcur_cf, ssd_cf, retctr_nf, rty_nf, plc_nt ",
                                    n_retcFetchRowCURCVSNIndx) ;

  	/* ecriture de l'index au debut du fichier */
   	if(	fseek(Kp_CurcvsnIndx,0,SEEK_SET)==-1L)
	   RETURN_VAL(CS_FAIL);
    if(	fwrite(Kbd_Adr,sizeof(Kbd_Adr),1,Kp_CurcvsnIndx) != 1)
	   RETURN_VAL(CS_FAIL);

	RETURN_VAL(retcode);
}
/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BRET..TCURCVSN
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowCURCVSNIndx( T_UTCTLIB *pbd_utctlib )
{
	T_CURCVSN bd_lu;
	static int n_cmpt=0 ;

	DEBUT_FCT ("n_retcFetchRowCURCVSN");

	strcpy (bd_lu.ACPCUR_CF, pc_GetStringValue (pbd_utctlib ,0));
	bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,1);
	strcpy (bd_lu.RETCTR_NF, pc_GetStringValue (pbd_utctlib ,2));
	bd_lu.RTY_NF = s_GetSmallintValue(pbd_utctlib ,3);
	bd_lu.PLC_NT = n_GetIntValue (pbd_utctlib ,4);
	strcpy (bd_lu.ACCCUR_CF, pc_GetStringValue (pbd_utctlib ,5));
	if(n_cmpt==0 || strcmp(bd_lu.ACPCUR_CF, Kbd_Adr[n_cmpt-1].sz_cur) != 0 )
	{
		strcpy( Kbd_Adr[n_cmpt].sz_cur, bd_lu.ACPCUR_CF) ;
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

	if (n_cmpt > MAX_DEVISE )
	{
	n_WriteAno ("The limit size of the table of structures Kbd_Adr[MAX_DEVISE] has been reached, you have to increase the value of MAX_DEVISE in the file estserv.h");
 	RETURN_VAL(CS_FAIL);
	}

	if (fwrite(&bd_lu,sizeof(T_CURCVSN),1,Kp_CurcvsnIndx)<=0)
		RETURN_VAL(CS_FAIL);

	RETURN_VAL(CS_SUCCEED);
}



CS_RETCODE n_ExtractSSDACTR (T_UTCTLIB		*pdb_utctlib)
{
        int retcode;
        char *query ;
        

		DEBUT_FCT("n_Processing");
		query=  "Select RETCTR_NF, RTY_NF, PLC_NT, RETSEC_NF, UW_NT, CTR_NF, UWY_NF, SEC_NF, END_NT, CLISSD_NF, RTOSSD_CF, SSD_CF from  BRET..TSSDACTR  a  order   by RETCTR_NF, RTY_NF, PLC_NT, RETSEC_NF asc ";
        
        printf("\nquery:%s\n",query);
        retcode = n_ExecCmdWithFetch(pdb_utctlib,query,
                                    n_retcFetchRowSSDACTR) ;

    
        return(retcode);
}

/*==============================================================================
objet : 
   fonction d'extraction des donnees de la table TTRSLNK

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSSDACTR( T_UTCTLIB *pbd_utctlib )
{
T_SSDACTR bd_Lu;
//static i = 0 ;

//i++;


DEBUT_FCT ("n_RowFetchRetPar") ;

//printf("%d\n",i);

//RETURN_VAL( CS_SUCCEED ) ;
strcpy ( bd_Lu.RETCTR_NF, pc_GetStringValue( pbd_utctlib, 0 ) ) ;
bd_Lu.RTY_NF = s_GetSmallintValue( pbd_utctlib, 1 ) ;
bd_Lu.PLC_NT = n_GetIntValue( pbd_utctlib, 2 ) ;
bd_Lu.RETSEC_NF	 = c_GetTinyintValue( pbd_utctlib, 3 ) ;
bd_Lu.UW_NT = c_GetTinyintValue( pbd_utctlib, 4 ) ;
strcpy ( bd_Lu.CTR_NF, pc_GetStringValue( pbd_utctlib, 5 ) ) ;
bd_Lu.UWY_NF = s_GetSmallintValue( pbd_utctlib, 6 ) ;
bd_Lu.SEC_NF =  c_GetTinyintValue( pbd_utctlib, 7 ) ;
bd_Lu.END_NT = c_GetTinyintValue( pbd_utctlib, 8 ) ;
bd_Lu.CLISSD_NF = n_GetIntValue( pbd_utctlib, 9 ) ;
bd_Lu.RTOSSD_CF = c_GetTinyintValue( pbd_utctlib, 10 ) ;
bd_Lu.SSD_CF = c_GetTinyintValue( pbd_utctlib, 11 ) ;


if ( fwrite( &bd_Lu, sizeof( T_SSDACTR ), 1, Kp_OutputFilSsdActr ) <= 0 ) RETURN_VAL(CS_FAIL);

RETURN_VAL( CS_SUCCEED ) ;
}

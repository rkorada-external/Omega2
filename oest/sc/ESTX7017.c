/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX7017.c
revision                      : $Revision:   1.5  $
date de creation              : 07/02/2007
auteur                        : J.Ribot
references des specifications : transfert portefeuille - SPOT EST 13720
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure. qui lui retourne le contenu
	de la table BTRT..TSECTION et BFAC..TSECTION (Non Prop uniquement)
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
#include <ESTX7017.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE  *Kp_trt;
FILE  *Kp_fac;

static CS_SMALLINT Ks_Annee ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowtrtsec (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */	 
static CS_RETCODE n_retcFetchRowfacsec (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
CS_RETCODE n_Processing (T_UTCTLIB  *pbd_utctlib);

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

	/* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Stockage des tables de correspondances dans des fichiers binaires";

	InitSig ();

	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm (ERR_XX, "");

	if (n_LocalConnect (&bd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");


	if (n_OpenFileAppl ("ESTX7017_O1","wb",&Kp_trt) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESTX7017_O2","wb",&Kp_fac) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_Processing (&bd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7017_O1",&Kp_trt) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7017_O2",&Kp_fac) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED)
        ExitPgm (ERR_XX, "");

    if (n_EndPgm () == ERR)
        ExitPgm (ERR_XX, "");

    exit (OK);
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

	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select  distinct CTR_NF,  "\
                                                "   UW_NT, "\
                                                "   END_NT,   "\
                                                "   UWY_NF,  "\
                                                "   SEC_NF,  "\
                                                "   NAT_CF  "\
                                                "  from BTRT..TSECTION where NAT_CF in ('30','31','32') ",
                                    n_retcFetchRowtrtsec) ;

	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select  distinct CTR_NF,  "\
                                                "   UW_NT, "\
                                                "   END_NT,   "\
                                                "   UWY_NF,  "\
                                                "   SEC_NF,  "\
                                                "   NAT_CF  "\
                                                "  from BFAC..TSECTION where NAT_CF in ('30','31','32') ",
                                    n_retcFetchRowfacsec) ;

RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BTRT..TSECTION
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowtrtsec( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_trt bd_lu;

DEBUT_FCT ("n_FetchRowtrtsec");

strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,1);
bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,2);
bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,4);
strcpy (bd_lu.NAT_CF, pc_GetStringValue (pbd_utctlib ,5));
//bd_lu.NAT_CF = c_GetTinyintValue (pbd_utctlib ,5);

if (fwrite(&bd_lu,sizeof(T_trt),1,Kp_trt)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BFAC..TSECTION
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowfacsec( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_fac bd_lu;

DEBUT_FCT ("n_FetchRowfacsec");

strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,1);
bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,2);
bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,4);
strcpy (bd_lu.NAT_CF, pc_GetStringValue (pbd_utctlib ,5));
//bd_lu.NAT_CF = c_GetTinyintValue (pbd_utctlib ,5);

if (fwrite(&bd_lu,sizeof(T_fac),1,Kp_fac)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

//strcpy (bd_lu.UW_NT, pc_GetStringValue (pbd_utctlib ,1));
//strcpy (bd_lu.END_NT, pc_GetStringValue (pbd_utctlib ,2));
//strcpy (bd_lu.UWY_NF, pc_GetStringValue (pbd_utctlib ,3));
//strcpy (bd_lu.SEC_NF, pc_GetStringValue (pbd_utctlib ,4));

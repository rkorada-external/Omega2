/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX7011.c
revision                      : $Revision: 1.2 $
date de creation              : 07/02/2007
auteur                        : J.Ribot
references des specifications : transfert portefeuille - SPOT EST 13720
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 1 procedure. qui lui retourne le contenu
	de la table BTRAV_TRANSF_POSTES (Generation entrees et retraits portefeuille
    a partir des postes ouvertures de provisions
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

-------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
       ...           ...            ...              ...
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <ESTX7011.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE  *Kp_postes;

static CS_SMALLINT Ks_Annee ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowpostes (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
CS_RETCODE n_Processing (T_UTCTLIB  *pbd_utctlib);

CS_RETCODE n_ExecCmdWithFetch() ;

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


	if (n_OpenFileAppl ("ESTX7011_O1","wb",&Kp_postes) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_Processing (&bd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7011_O1",&Kp_postes) == ERR )
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

	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select  POSTEFROM,  "\
                                                "   POSTETOIN,  "\
                                                "   POSTETOCPIN, "\
                                                "   POSTETOOUT,   "\
                                                "   POSTETOCPOUT  "\
                                                "  from BTRAV..TRANSF_POSTES",
                                    n_retcFetchRowpostes) ;

RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BTRAV..TRANSF_POSTES
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowpostes( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_postes bd_lu;

DEBUT_FCT ("n_FetchRowpostes");

strcpy (bd_lu.POSTEFROM, pc_GetStringValue (pbd_utctlib ,0));
strcpy (bd_lu.POSTETOIN, pc_GetStringValue (pbd_utctlib ,1));
strcpy (bd_lu.POSTETOCPIN, pc_GetStringValue (pbd_utctlib ,2));
strcpy (bd_lu.POSTETOOUT, pc_GetStringValue (pbd_utctlib ,3));
strcpy (bd_lu.POSTETOCPOUT, pc_GetStringValue (pbd_utctlib ,4));

if (fwrite(&bd_lu,sizeof(T_postes),1,Kp_postes)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}



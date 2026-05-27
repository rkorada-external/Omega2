/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX7012.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 03/02/2009
auteur                        : J.Ribot
references des specifications : transfert portefeuille - SPOT EST16765
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle
  1 procedure. qui lui retourne le contenu
	de la table BTRAV_EST_ESTD3050_TRANSF_PTF (Generation entrees et retraits portefeuille
    a partir des postes ouvertures de provisions
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.
  1 procedure. qui lui retourne le contenu
	de la table BTRAVEST_ESTD3050_TRANSF_CTPE (Generation entrees et retraits portefeuille
    a partir des postes ouvertures de provisions
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
#include <ESTX7012.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE  *Kp_ptf;
FILE  *Kp_ctpe;

static CS_SMALLINT Ks_Annee ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowptf (T_UTCTLIB *pbd_utctlib);  /* Updated for Phase1b Migration */
static CS_RETCODE n_retcFetchRowctpe (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
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


	if (n_OpenFileAppl ("ESTX7012_O1","wb",&Kp_ptf) == ERR )
           ExitPgm (ERR_XX, "");

  if (n_OpenFileAppl ("ESTX7012_O2","wb",&Kp_ctpe) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_Processing (&bd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7012_O1",&Kp_ptf) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7012_O2",&Kp_ctpe) == ERR )
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
                                                "   POSTETOOUT   "\
                                                "  from BTRAV..EST_ESTD3050_TRANSF_PTF",
                                    n_retcFetchRowptf) ;


	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select  ESSD_CF,  "\
                                                "   EESB_CF,  "\
                                                "   RSSD_CF,  "\
                                                "   RESB_CF,  "\
                                                "   POSTECP  "\
                                                "  from BTRAV..EST_ESTD3050_TRANSF_CTPE",
                                    n_retcFetchRowctpe) ;

RETURN_VAL(retcode);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BTRAV..TRANSF_PTF
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowptf( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_ptf bd_lu;

DEBUT_FCT ("n_FetchRowptf");

strcpy (bd_lu.POSTEFROM, pc_GetStringValue (pbd_utctlib ,0));
strcpy (bd_lu.POSTETOIN, pc_GetStringValue (pbd_utctlib ,1));
strcpy (bd_lu.POSTETOOUT, pc_GetStringValue (pbd_utctlib ,2));

if (fwrite(&bd_lu,sizeof(T_ptf),1,Kp_ptf)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table BTRAV..TRANSF_CTPE
retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowctpe( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_ctpe bd_lu;

DEBUT_FCT ("n_FetchRowctpe");

memset(&bd_lu,0,sizeof(bd_lu));
bd_lu.ESSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
bd_lu.EESB_CF = c_GetTinyintValue (pbd_utctlib ,1);
bd_lu.RSSD_CF = c_GetTinyintValue (pbd_utctlib ,2);
bd_lu.RESB_CF = c_GetTinyintValue (pbd_utctlib ,3);
strcpy (bd_lu.POSTECP, pc_GetStringValue (pbd_utctlib ,4));

if (fwrite(&bd_lu,sizeof(T_ctpe),1,Kp_ctpe)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}




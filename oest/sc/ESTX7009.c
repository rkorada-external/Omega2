/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX7009.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 29/11/2006
auteur                        : J.Ribot
references des specifications : transfert portefeuille - SPOT EST 13427
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	Ce programme appelle 4 procedures. La 1ere lui retourne le contenu
	de la table TRFCROSSREF, la 2eme celui de TCLMCROSSREF, la 3eme celui
        de la table TDETTRS, la 4eme celui de TFACROSSREF,.
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

-------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    09/03/2009   P. Coppin   Spot 16765  Transfert de portefeuille : Passage de 24 à 16 pour T1.TRFACCSTS_CT
===============================================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <ESTX7009.h>

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *Kp_crostrf, *Kp_crostclm, *Kp_dettrs, *Kp_crostrfa;

static CS_SMALLINT Ks_Annee ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowTRF (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
static CS_RETCODE n_retcFetchRowTCLM (T_UTCTLIB *pbd_utctlib);/* Updated for Phase1b Migration */
static CS_RETCODE n_retcFetchRowDETTRS (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */
static CS_RETCODE n_retcFetchRowTRFA (T_UTCTLIB *pbd_utctlib); /* Updated for Phase1b Migration */ 
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


	if (n_OpenFileAppl ("ESTX7009_O1","wb",&Kp_crostrf) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESTX7009_O2","wb",&Kp_crostclm) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESTX7009_O3","wb",&Kp_dettrs) == ERR )
		ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESTX7009_O4","wb",&Kp_crostrfa) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_Processing (&bd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7009_O1",&Kp_crostrf) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7009_O2",&Kp_crostclm) == ERR )
           ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7009_O3",&Kp_dettrs) == ERR )
		ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESTX7009_O4",&Kp_crostrfa) == ERR )
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


	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select distinct T1.CTR_NF,      "\
                                                   "   T1.SSD_CF,      "\
                                                   "   T1.DESTCTR_NF,  "\
                                                   "   T1.DESTSSD_CF,  "\
                                                   "   T1.ACCESB_CF,   "\
                                                   "   T1.DESTACCESB_CF,   "\
                                              "   convert(char(10),T1.LSTUPD_D,112) "\
                                    "    from BTRT..TRFCROSSREF T1    "\
                                    "      where T1.TRFSTS_CT = 2   "\
                                    "       and T1.TRFACCSTS_CT = 16   ",
				   n_retcFetchRowTRF) ;

	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select CLM_NF,  "\
                                                  "    SSD_CF,  "\
                                                  "    DESTCLM_NF,  "\
                                                  "    DESTSSD_NF   "\
                                               "  from BCTA..TCLMCROSSREF",
				    n_retcFetchRowTCLM) ;


	retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select DETTRS_CF,  "\
                                                  "   TRSTYP_CT  "\
                                               "  from BREF..TDETTRS",
                                    n_retcFetchRowDETTRS) ;

  retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select distinct T1.CTR_NF,      "\
                                                    "   T1.SSD_CF,      "\
                                                    "   T1.DESTCTR_NF,  "\
                                                    "   T1.DESTSSD_CF,  "\
                                                    "   T1.ACCESB_CF,   "\
                                                   "   T1.DESTACCESB_CF,   "\
                                               "   convert(char(10),T1.LSTUPD_D,112) "\
                                     "    from BFAC..TRFCROSSREF T1   "\
                                    "      where T1.TRFSTS_CT = 2   "\
                                    "       and T1.TRFACCSTS_CT = 16   ",

  			   n_retcFetchRowTRFA) ;


	RETURN_VAL(retcode);
}


////////////////    save ancien select trfcrossref  ////////////////////

//  retcode = n_ExecCmdWithFetch(pbd_utctlib,"Select distinct T1.CTR_NF,      "\
//                                                    "   T1.SSD_CF,      "\
//                                                    "   T1.DESTCTR_NF,  "\
//                                                    "   T1.DESTSSD_CF,  "\
//                                                    "   T2.ACCESB_CF,   "\
//                                               "   convert(char(10),T1.LSTUPD_D,112) "\
//                                     "    from BFAC..TRFCROSSREF T1, BFAC..TCONTR T2     "\
//                                    "      where T1.TRFSTS_CT = n_parm_SITE    "\
//                                    "       and T1.TRFACCSTS_CT = 36   "\
//                                     "       and T1.DESTCTR_NF = T2.CTR_NF",
//  			   n_retcFetchRowTRFA) ;

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TRFCROSSREF

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRF( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_TRFCROSSREF bd_lue;

DEBUT_FCT ("n_retcFetchRowTRF");

memset(&bd_lue,0,sizeof(bd_lue));
strcpy (bd_lue.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
bd_lue.SSD_CF = c_GetTinyintValue (pbd_utctlib ,1);
strcpy (bd_lue.DESTCTR_NF, pc_GetStringValue (pbd_utctlib ,2));
bd_lue.DESTSSD_CF = c_GetTinyintValue (pbd_utctlib ,3);
bd_lue.ACCESB_CF = c_GetTinyintValue (pbd_utctlib ,4);
bd_lue.DESTACCESB_CF = c_GetTinyintValue (pbd_utctlib ,5);
strcpy(bd_lue.LSTUPD_D ,pc_GetStringValue (pbd_utctlib ,6));

if (fwrite(&bd_lue,sizeof(T_TRFCROSSREF),1,Kp_crostrf)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TCLMCROSSREF

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTCLM( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_TCLMCROSSREF bd_lu;

DEBUT_FCT ("n_retcFetchRowTCLM");

memset(&bd_lu,0,sizeof(bd_lu));
bd_lu.CLM_NF = n_GetIntValue (pbd_utctlib ,0);
bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,1);
bd_lu.DESTCLM_NF = n_GetIntValue (pbd_utctlib ,2);
bd_lu.DESTSSD_CF = c_GetTinyintValue (pbd_utctlib ,3);

if (fwrite(&bd_lu,sizeof(T_TCLMCROSSREF),1,Kp_crostclm)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
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
bd_lu.TRSTYP_CT = c_GetTinyintValue (pbd_utctlib ,1);

if (fwrite(&bd_lu,sizeof(T_DETTRS),1,Kp_dettrs)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TRFACROSSREF

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRFA( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_TRFACROSSREF bd_lue;

DEBUT_FCT ("n_retcFetchRowTRFA");

memset(&bd_lue,0,sizeof(bd_lue));
strcpy (bd_lue.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
bd_lue.SSD_CF = c_GetTinyintValue (pbd_utctlib ,1);
strcpy (bd_lue.DESTCTR_NF, pc_GetStringValue (pbd_utctlib ,2));
bd_lue.DESTSSD_CF = c_GetTinyintValue (pbd_utctlib ,3);
bd_lue.ACCESB_CF = c_GetTinyintValue (pbd_utctlib ,4);
bd_lue.DESTACCESB_CF = c_GetTinyintValue (pbd_utctlib ,5);
strcpy(bd_lue.LSTUPD_D ,pc_GetStringValue (pbd_utctlib ,6));

if (fwrite(&bd_lue,sizeof(T_TRFACROSSREF),1,Kp_crostrfa)<=0)
	RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}




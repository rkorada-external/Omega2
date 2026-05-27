/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESIX0062.c
revision                      : $Revision:   1.1  $
date de creation              : 11/1997
auteur                        : Kuhna
references des specifications : ESIIV01F
squelette de base             : extraction
-------------------------------------------------------------------------------
description :
	extraction de la table de pilotage TLIFDRI triee par ctrt/Av/sec/
        ACY_NF/CDE_D
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.

-------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
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
FILE *Kp_lifdri;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowLIFDRI (T_UTCTLIB *pbd_utctlib); /* For Phase1b Migration */
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
 T_UTCTLIB  bd_utctlib;
        
 InitSig ();
        
 if (n_BeginPgm (argc, argv) == ERR)
   ExitPgm (ERR_XX, "");
  
 if (n_LocalConnect (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");

 if (n_OpenFileAppl ("ESIX0062_O1","wb",&Kp_lifdri) == ERR )
   ExitPgm (ERR_XX, "");

 if (n_Processing (&bd_utctlib) != CS_SUCCEED) 
   ExitPgm (ERR_XX, "");
        
 if (n_CloseFileAppl ("ESIX0062_O1",&Kp_lifdri) == ERR )
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
static CS_RETCODE  n_retcFetchRowLIFDRI( T_UTCTLIB *pbd_utctlib )
{
CS_RETCODE retcode;
T_LIFDRI bd_lu;

  DEBUT_FCT ("n_retcFetchRowLIFDRI");

  /* Mise a 'blanc' de la structure receptrice */
  memset(&bd_lu,0,sizeof(bd_lu));

  /* Alimentation de la structure receptrice */
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

  /* Ecriture de la structure receptrice dans le fichier de sortie */
  if (fwrite(&bd_lu,sizeof(T_LIFDRI),1,Kp_lifdri)<=0) 
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

    pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRI;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsLIFDRI_04");

    RETURN_VAL(retcode);
}

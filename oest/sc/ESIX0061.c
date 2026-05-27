/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESIX0061.c
revision                      : $Revision: 1.2 $
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
  <jj/mm/aaaa>  <auteur>    <description de la modification>
       ...           ...            ...              ...
  08/09/2003    G. BUISSON  Ajout du parametre BALSHTMTH_NF pour BEST..PsLIFDRI_03
                            pour eviter de prendre les lignes posterieures au mois
                            bilan a traiter suite au deblocage des periodes exceptionnelles

  08/06/2010    T.RIPERT    Ajout la cedant dans tctrfic dans l'extraction n_retcFetchRowCTRFIC

  01/05/2014    R. BEN EZZINE : Ajout de l'extraction des tables de paramétrages version 2B
[001] 09/07/2014 ABJ :spot:25773 Modification of n_retcFetchRowSUBTRSASSO()
[002] 09/23/2014 R. BEN EZZINE :spot:25773 Ajout des paramètres en entrée @p_balshtyea_nf et @p_balshtmth_nf
[003] 10/11/2015 R.BEN EZZINE :spot:29579 Impact Retro EST
[004] 11/11/2015 -=Dch=-  :spot:29162 Impact Retro P&C 
[005] 02/06/2016 S.Behague	:spot:30300 EST39
[006] 07/07/2016 MMA		:spot:30899	EST26B, Ajout du champ ESB (Ledger) dans l'extraction du CTRFIC
[007] 13/2/2019 R.Vieville REQ.L.02.05: Evolution quarterly 
=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *Kp_segpar, *Kp_ctrfic, *Kp_lifdri, *Kp_trslnk, *Kp_trslnkvret, *Kp_curquot;
FILE *Kp_Dettrs, *Kp_Rettrf, *Kp_Curcvsn, *Kp_Sobblob, *Kp_Segment;

FILE* Kp_SubsidFilout;
FILE* Kp_AcmtrshFilout;
FILE* Kp_LifthrFilout;
FILE* Kp_BanteclFilout;
FILE* Kp_GrpFilout;
FILE* Kp_CurcvsnIndx;
FILE* Kp_SubtrsFilout;
FILE* Kp_Subtrsblocklifest;
FILE* Kp_SubtrsAssoFilout;
FILE* Kp_SubtrsBaseFilout;
FILE* Kp_AccparFilout;
FILE* Kp_SubtrsEsbProp;
FILE* Kp_lifdri_all;
FILE* Kp_lifdriy_all;
FILE* Kp_lifdriq_all;
FILE* Kp_transcode;
FILE* Kp_transcodevret;

static T_INDXCURQUOT Kbd_Adr[MAX_DEVISE] ;
static CS_SMALLINT Ks_Annee ;

/*  Modif GIBU du 08/09/2003  */
static CS_TINYINT  Ks_Mois ;

/*----------------------------------*/
/* prototypes des fonctions privees */
/*----------------------------------*/
int main (int argc,char* argv[]);
static CS_RETCODE n_retcFetchRowSEGPAR (T_UTCTLIB *pbd_utctlib); /* For Phase1b Migration */
static CS_RETCODE n_retcFetchRowCTRFIC (T_UTCTLIB *pbd_utctlib); /* For Phase1b Migration */
static CS_RETCODE n_retcFetchRowLIFDRI (T_UTCTLIB *pbd_utctlib); /* For Phase1b Migration */
static CS_RETCODE n_retcFetchRowTRSLNK (T_UTCTLIB *pbd_utctlib); /* For Phase1b Migration */

static CS_RETCODE n_retcFetchRowTRSLNK_VRET (T_UTCTLIB *pbd_utctlib);

CS_RETCODE n_Processing ();
CS_RETCODE n_retcFetchRowCURQUOT(T_UTCTLIB *pdb_utctlib)  ;
CS_RETCODE n_ExtractCurQuot(T_UTCTLIB *pdb_utctlib)  ;
static CS_RETCODE  n_retcFetchRowDETTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowTRANSCODE( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowTRANSCODE_VRET( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowRETTRF( T_UTCTLIB *pbd_utctlib );
//static CS_RETCODE  n_retcFetchRowCURCVSN( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSOBBLOB( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSEGMENT( T_UTCTLIB *pbd_utctlib );

static CS_RETCODE  n_retcFetchRowSSD( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowACMTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowLIFTHR( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowUWGRP( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowANO( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowCURCVSNIndx( T_UTCTLIB *pbd_utctlib );

static CS_RETCODE  n_retcFetchRowSUBTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSUBTRSBLKLIF( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSUBTRSASSO( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSUBTRSBASE( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowACCPAR( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowSUBTRSESBPROP( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE n_retcFetchRowLIFDRI_ALL (T_UTCTLIB *pbd_utctlib);
static CS_RETCODE n_retcFetchRowLIFDRID_ALL (T_UTCTLIB *pbd_utctlib);
static CS_RETCODE n_retcFetchRowLIFDRIY_ALL (T_UTCTLIB *pbd_utctlib);




CS_RETCODE n_ExtractCurcsvnIndx( T_UTCTLIB              *pdb_utctlib);


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


  /* Initialisation des variables */
	Ks_Annee=n_GetIntArgv(1);

  /*  Modif GIBU du 08/09/2003  */
  Ks_Mois=n_GetIntArgv(2);

  /* Ouverture des fichiers */
	if (n_OpenFileAppl ("ESIX0061_O1","wb",&Kp_segpar) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O2","wb",&Kp_ctrfic) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O3","wb",&Kp_lifdri) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O4","wb",&Kp_trslnk) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O5","wb",&Kp_curquot) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O6","wb",&Kp_Dettrs) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl ("ESIX0061_O7","wb",&Kp_Rettrf) == ERR ) ExitPgm (ERR_XX, "");

	if (n_OpenFileAppl("ESIX0061_O9","wb",&Kp_SubsidFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O10","wb",&Kp_AcmtrshFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O11","wb",&Kp_BanteclFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O12","wb",&Kp_GrpFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O13","wb",&Kp_CurcvsnIndx) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O14","wb",&Kp_Sobblob) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESIX0061_O15","wb",&Kp_Segment) == ERR ) ExitPgm ( ERR_XX , "" );

 	if (n_OpenFileAppl("ESIX0061_O16","wb",&Kp_LifthrFilout) == ERR ) ExitPgm ( ERR_XX , "" );

 	if (n_OpenFileAppl("ESIX0061_O17","wb",&Kp_SubtrsFilout) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl("ESIX0061_O18","wb",&Kp_Subtrsblocklifest) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl("ESIX0061_O19","wb",&Kp_SubtrsAssoFilout) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl("ESIX0061_O20","wb",&Kp_SubtrsBaseFilout) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl("ESIX0061_O21","wb",&Kp_AccparFilout) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl("ESIX0061_O22","wb",&Kp_SubtrsEsbProp) == ERR ) ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl ("ESIX0061_O23","wb",&Kp_lifdri_all) == ERR ) ExitPgm (ERR_XX, "");

  if (n_OpenFileAppl ("ESIX0061_O24","wb",&Kp_transcode) == ERR ) ExitPgm (ERR_XX, "");

  if (n_OpenFileAppl ("ESIX0061_O25","wb",&Kp_transcodevret) == ERR ) ExitPgm (ERR_XX, "");

  if (n_OpenFileAppl ("ESIX0061_O26","wb",&Kp_trslnkvret) == ERR ) ExitPgm (ERR_XX, "");

  if (n_OpenFileAppl ("ESIX0061_O27","wb",&Kp_lifdriq_all) == ERR ) ExitPgm (ERR_XX, ""); // [007]

  if (n_OpenFileAppl ("ESIX0061_O28","wb",&Kp_lifdriy_all) == ERR ) ExitPgm (ERR_XX, ""); // [007]


  if (n_Processing (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");


  //Fermerture des fichiers
  if (n_CloseFileAppl ("ESIX0061_O1",&Kp_segpar) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O2",&Kp_ctrfic) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O3",&Kp_lifdri) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O4",&Kp_trslnk) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O5",&Kp_curquot) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O6",&Kp_Dettrs) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O7",&Kp_Rettrf) == ERR ) ExitPgm (ERR_XX, "");

	if ( n_CloseFileAppl ("ESIX0061_09",&Kp_SubsidFilout)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O10",&Kp_AcmtrshFilout)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O11",&Kp_BanteclFilout)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O12",&Kp_GrpFilout)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O13",&Kp_CurcvsnIndx)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O14",&Kp_Sobblob)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O15",&Kp_Segment)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O16",&Kp_LifthrFilout)== ERR) ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESIX0061_O17",&Kp_SubtrsFilout)== ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O18",&Kp_Subtrsblocklifest) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O19",&Kp_SubtrsAssoFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O20",&Kp_SubtrsBaseFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O21",&Kp_AccparFilout) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O22",&Kp_SubtrsEsbProp) == ERR ) ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESIX0061_O23",&Kp_lifdri_all) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O24",&Kp_transcode) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O25",&Kp_transcodevret) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O26",&Kp_trslnkvret) == ERR ) ExitPgm (ERR_XX, "");

	if (n_CloseFileAppl ("ESIX0061_O27",&Kp_lifdriq_all) == ERR ) ExitPgm (ERR_XX, ""); // [007]

	if (n_CloseFileAppl ("ESIX0061_O28",&Kp_lifdriy_all) == ERR ) ExitPgm (ERR_XX, ""); // [007]


	if (n_LocalDisconnect (&bd_utctlib) != CS_SUCCEED) ExitPgm (ERR_XX, "");

  if (n_EndPgm () == ERR) ExitPgm (ERR_XX, "");

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
T_CTRFIC    bd_lu;

  DEBUT_FCT ("n_retcFetchRowCTRFIC");

  /* SSD_CF */
  bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);

  //LIFTRTTYP_CF
  strcpy (bd_lu.LIFTRTTYP_CF, pc_GetStringValue (pbd_utctlib ,1));

  /* UWGRP_CF */
  bd_lu.UWGRP_CF = s_GetSmallintValue (pbd_utctlib ,2);

  /* ANLCTY_CF */
  strcpy (bd_lu.ANLCTY_CF, pc_GetStringValue (pbd_utctlib ,3));

  /* ESTCTR_NF */
  strcpy (bd_lu.ESTCTR_NF, pc_GetStringValue (pbd_utctlib ,4));

  /* CED_NF */
  /* TRIPERT  20100609 SPOT 19101 : Ajout la cédante  */
  bd_lu.CED_NF  = n_GetIntValue (pbd_utctlib ,5);
  /* FIN TRIPERT*/

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
   fonction d'extraction des donnees de la table TLIFDRI_ALL

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLIFDRI_ALL( T_UTCTLIB *pbd_utctlib )
{
T_LIFDRI_ALL bd_lu;

		DEBUT_FCT ("n_retcFetchRowLIFDRI_ALL");
		memset(&bd_lu,0,sizeof(bd_lu));

		strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
		bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,1);
		bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,2);
		bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
		bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,4);
		bd_lu.ACY_NF = s_GetSmallintValue (pbd_utctlib ,5);
		bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,6);
		bd_lu.BALSHEY_NF = s_GetSmallintValue (pbd_utctlib ,7);
		bd_lu.BALSHTMTH_NF = c_GetTinyintValue (pbd_utctlib ,8);
		bd_lu.AUTUPD_B = c_GetBitValue (pbd_utctlib ,9);
		bd_lu.COMACC_B = c_GetBitValue (pbd_utctlib ,10);
		bd_lu.PROPAG_RES_B = c_GetBitValue (pbd_utctlib ,11);
		bd_lu.SEGUPD_B = c_GetBitValue (pbd_utctlib ,12);
		strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,13));
		bd_lu.UPD_NF = ' ';
		bd_lu.CMT_NT = n_GetIntValue (pbd_utctlib ,14);
		strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,15));
		strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,16));
		strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,17));


		if (fwrite(&bd_lu,sizeof(T_LIFDRI_ALL),1,Kp_lifdri_all)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TLIFDRID_ALL

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLIFDRID_ALL( T_UTCTLIB *pbd_utctlib )
{
T_LIFDRI_ALL_QUARTER bd_lu;

		DEBUT_FCT ("n_retcFetchRowLIFDRID_ALL");
		memset(&bd_lu,0,sizeof(bd_lu));

		strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
		bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,1);
		bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,2);
		bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
		bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,4);
		bd_lu.ACY_NF = s_GetSmallintValue (pbd_utctlib ,5);
		bd_lu.ACM_NF = s_GetSmallintValue (pbd_utctlib ,6);
		bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,7);
		bd_lu.BALSHEY_NF = s_GetSmallintValue (pbd_utctlib ,8);
		bd_lu.BALSHTMTH_NF = c_GetTinyintValue (pbd_utctlib ,9);
		bd_lu.AUTUPD_B = c_GetBitValue (pbd_utctlib ,10);
		bd_lu.COMACC_B = c_GetBitValue (pbd_utctlib ,11);
		bd_lu.PROPAG_RES_B = c_GetBitValue (pbd_utctlib ,12);
		bd_lu.SEGUPD_B = c_GetBitValue (pbd_utctlib ,13);
		strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,14));
		bd_lu.UPD_NF = ' ';
		bd_lu.CMT_NT = n_GetIntValue (pbd_utctlib ,15);
		strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,16));
		strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,17));
		strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,18));


		if (fwrite(&bd_lu,sizeof(T_LIFDRI_ALL_QUARTER),1,Kp_lifdriq_all)<=0) RETURN_VAL(CS_FAIL);

		RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TLIFDRI_ALL pour le quarterly

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLIFDRIY_ALL( T_UTCTLIB *pbd_utctlib )
{
T_LIFDRI_ALL_QUARTER bd_lu;

		DEBUT_FCT ("n_retcFetchRowLIFDRIY_ALL");
		memset(&bd_lu,0,sizeof(bd_lu));

		strcpy (bd_lu.CTR_NF, pc_GetStringValue (pbd_utctlib ,0));
		bd_lu.END_NT = c_GetTinyintValue (pbd_utctlib ,1);
		bd_lu.SEC_NF = c_GetTinyintValue (pbd_utctlib ,2);
		bd_lu.UWY_NF = s_GetSmallintValue (pbd_utctlib ,3);
		bd_lu.UW_NT = c_GetTinyintValue (pbd_utctlib ,4);
		bd_lu.ACY_NF = s_GetSmallintValue (pbd_utctlib ,5);
		bd_lu.ACM_NF = s_GetSmallintValue (pbd_utctlib ,6);
		bd_lu.SSD_CF = c_GetTinyintValue (pbd_utctlib ,7);
		bd_lu.BALSHEY_NF = s_GetSmallintValue (pbd_utctlib ,8);
		bd_lu.BALSHTMTH_NF = c_GetTinyintValue (pbd_utctlib ,9);
		bd_lu.AUTUPD_B = c_GetBitValue (pbd_utctlib ,10);
		bd_lu.COMACC_B = c_GetBitValue (pbd_utctlib ,11);
		bd_lu.PROPAG_RES_B = c_GetBitValue (pbd_utctlib ,12);
		bd_lu.SEGUPD_B = c_GetBitValue (pbd_utctlib ,13);
		strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,14));
		bd_lu.UPD_NF = ' ';
		bd_lu.CMT_NT = n_GetIntValue (pbd_utctlib ,15);
		strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,16));
		strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,17));
		strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,18));


		if (fwrite(&bd_lu,sizeof(T_LIFDRI_ALL_QUARTER),1,Kp_lifdriy_all)<=0) RETURN_VAL(CS_FAIL);

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
   fonction d'extraction des donnees de la table TTRSLNK_VRET

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRSLNK_VRET( T_UTCTLIB *pbd_utctlib )
{
T_TRSLNK_RET bd_lu;

DEBUT_FCT ("n_retcFetchRowTRSLNK_VRET");


bd_lu.PRS_CF= s_GetSmallintValue (pbd_utctlib ,0);
bd_lu.ACMTRS_NT= s_GetSmallintValue (pbd_utctlib ,1);
strcpy (bd_lu.DETTRNCOD_CF, pc_GetStringValue (pbd_utctlib ,2));

if (fwrite(&bd_lu,sizeof(T_TRSLNK_RET),1,Kp_trslnkvret)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TRANSCODE_02

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRANSCODE_VRET( T_UTCTLIB *pbd_utctlib )
{
T_TRANSTCODE_VRET bd_lu;
	DEBUT_FCT ("n_retcFetchRowTRANSCODE_VRET");

	strcpy(bd_lu.TRANSTYP_CF, pc_GetStringValue(pbd_utctlib, 0));
	strcpy(bd_lu.FAMTRAN_CF, pc_GetStringValue(pbd_utctlib, 1));
	strcpy(bd_lu.CTRNAT_CT, pc_GetStringValue(pbd_utctlib ,2));
	bd_lu.ACCADMTYP_CT = s_GetSmallintValue(pbd_utctlib ,3);
	strcpy(bd_lu.ORIDETTRNCOD_CF , pc_GetStringValue(pbd_utctlib, 4));
	strcpy(bd_lu.TRADETTRNCOD_CF, pc_GetStringValue(pbd_utctlib, 5));


	if (fwrite(&bd_lu,sizeof(T_TRANSTCODE_VRET),1,Kp_transcodevret)<=0) RETURN_VAL(CS_FAIL);

	RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TRANSCODE

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowTRANSCODE( T_UTCTLIB *pbd_utctlib )
{
  	T_TRANSTCODE bd_lu;
	DEBUT_FCT ("n_retcFetchRowTRANSCODE");

	strcpy(bd_lu.TRANSTYP_CF, pc_GetStringValue(pbd_utctlib, 0));
	strcpy(bd_lu.FAMTRAN_CF, pc_GetStringValue(pbd_utctlib, 1));
	strcpy(bd_lu.CTRNAT_CT, pc_GetStringValue(pbd_utctlib ,2));
	bd_lu.ACCADMTYP_CT = s_GetSmallintValue(pbd_utctlib ,3);
	strcpy(bd_lu.ODETTRS_CF, pc_GetStringValue(pbd_utctlib, 4));
	strcpy(bd_lu.TRADETTRS_CF, pc_GetStringValue(pbd_utctlib, 5));

	if (fwrite(&bd_lu,sizeof(T_TRANSTCODE),1,Kp_transcode)<=0) RETURN_VAL(CS_FAIL);

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
	memset(Kbd_Adr,0,sizeof(Kbd_Adr)) ;
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
  T_CURQUOT  bd_Art;
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
   fonction d'extraction des donnees de la table BREF..TSOBBLOB
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSOBBLOB( T_UTCTLIB *pbd_utctlib )
{
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
   fonction d'extraction des donnees de la table BEST..TSEGMENT
retour :
                CS_SUCCEED
		CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSEGMENT( T_UTCTLIB *pbd_utctlib )
{
        T_SEGMENT bd_lu;

        DEBUT_FCT ("n_retcFetchRowSEGMENT");

        bd_lu.VRS_NF = (int) ( f_GetNumericValue( pbd_utctlib, 0 ) ) ;
        bd_lu.SSD_CF = c_GetTinyintValue( pbd_utctlib, 1 ) ;
        bd_lu.SEGTYP_CT = c_GetTinyintValue( pbd_utctlib, 2 ) ;
	strcpy( bd_lu.SEG_NF, pc_GetStringValue( pbd_utctlib, 3) ) ;
	strcpy( bd_lu.CUR_CF, pc_GetStringValue( pbd_utctlib, 4) ) ;
	bd_lu.SEGNAT_CT = *(pc_GetStringValue( pbd_utctlib, 5)) ;

        if ( fwrite( &bd_lu, sizeof( T_SEGMENT ), 1, Kp_Segment ) <= 0 )
		RETURN_VAL( CS_FAIL );

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
   fonction d'extraction des donnees de la table TLIFTHR

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowLIFTHR( T_UTCTLIB *pbd_utctlib )
{
	CS_RETCODE retcode=CS_SUCCEED;
	T_LIFTHR   bd_LibSeuil;/* Libelles des postes d'une filiale */

	DEBUT_FCT ("n_retcFetchRowLIFTHR");


	bd_LibSeuil.SSD_CF = c_GetTinyintValue (pbd_utctlib ,0);
  bd_LibSeuil.ESB_CF = c_GetTinyintValue (pbd_utctlib ,1);
//  bd_LibSeuil.ESB_CF = s_GetSmallintValue (pbd_utctlib ,1);
  strcpy( bd_LibSeuil.CUR_CF, pc_GetStringValue( pbd_utctlib, 2) );
  bd_LibSeuil.AMT_M= f_GetDecimalValue ( pbd_utctlib ,3);


	if (fwrite(&bd_LibSeuil,sizeof(bd_LibSeuil),1,Kp_LifthrFilout)<=0) RETURN_VAL(CS_FAIL);

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
   Lancement des 2 procédures

retour :
==============================================================================*/
CS_RETCODE n_ExtractCurcsvnIndx( T_UTCTLIB		*pdb_utctlib)
{
	CS_RETCODE		retcode ;

	DEBUT_FCT("n_ExtractCurcsvnIndx");	/*resevation de la place pour l'index au debut du fichier */
    memset(Kbd_Adr,0,sizeof(Kbd_Adr)) ;
    if(	fwrite(Kbd_Adr,sizeof(Kbd_Adr),1,Kp_CurcvsnIndx) != 1)
	   RETURN_VAL(CS_FAIL);

	/* Fonction de traitement d'une ligne   */
	pdb_utctlib->n_RowFetchData	= n_retcFetchRowCURCVSNIndx;
    retcode = n_ProcessingProc (pdb_utctlib,0,"BEST..PsCURCVSN_05");
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

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBTRS

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSUBTRS( T_UTCTLIB *pbd_utctlib )
{
T_SUBTRS bd_lu;

DEBUT_FCT ("n_retcFetchRowSUBTRS");

					sprintf(bd_lu.DETTRNCOD_CF,"%.2s%.1s%.2s",pc_GetStringValue (pbd_utctlib ,0),pc_GetStringValue (pbd_utctlib ,1),pc_GetStringValue (pbd_utctlib ,2));

					strcpy (bd_lu.SUBTRS_GL,pc_GetStringValue (pbd_utctlib ,3));
					strcpy (bd_lu.SUBTRS_GS,pc_GetStringValue (pbd_utctlib ,4));
					strcpy (bd_lu.SUBTRSEXP_D,pc_GetStringValue (pbd_utctlib ,5));
					strcpy (bd_lu.SUBTRSINC_D,pc_GetStringValue (pbd_utctlib ,6));
					bd_lu.CMT_NT = n_GetIntValue (pbd_utctlib ,7);
					bd_lu.TRSINPUTTYPE_CT = s_GetSmallintValue(pbd_utctlib ,8);
					bd_lu.TRSNATURE_CT = s_GetSmallintValue(pbd_utctlib ,9);
					strcpy (bd_lu.LOGSIG_CT,pc_GetStringValue (pbd_utctlib ,10));
					strcpy (bd_lu.LOB_CF,pc_GetStringValue (pbd_utctlib ,11));
					bd_lu.TRSTYPE_CT = s_GetSmallintValue(pbd_utctlib ,12);
					bd_lu.TRSPURERETRO_B = s_GetSmallintValue(pbd_utctlib ,13);
					bd_lu.DACTYPE_B   = s_GetSmallintValue(pbd_utctlib ,14);
					bd_lu.COMPLEMENT_B = s_GetSmallintValue(pbd_utctlib ,15);
					bd_lu.NEWBALSHEETPROPAG_B = s_GetSmallintValue(pbd_utctlib ,16);
					bd_lu.CELLPROTECEXC_B = s_GetSmallintValue(pbd_utctlib ,17);

if (fwrite(&bd_lu,sizeof(T_SUBTRS),1,Kp_SubtrsFilout)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);
}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBTRSBLOCKLIFEST

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSUBTRSBLKLIF( T_UTCTLIB *pbd_utctlib )
{
T_SUBTRSBLOCKLIFEST bd_lu;

DEBUT_FCT ("n_retcFetchRowSUBTRSBLKLIF");

					bd_lu.BLOCK_NF=s_GetSmallintValue (pbd_utctlib ,0);
					sprintf(bd_lu.DETTRNCOD_CF,"%.2s%.1s%.2s",pc_GetStringValue (pbd_utctlib ,1),pc_GetStringValue (pbd_utctlib ,2),pc_GetStringValue (pbd_utctlib ,3));
					bd_lu.RANKORDER_NT = s_GetSmallintValue(pbd_utctlib ,4);
	//				strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,5));
	//				strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,5));
					strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,5));
					strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,6));

if (fwrite(&bd_lu,sizeof(T_SUBTRSBLOCKLIFEST),1,Kp_Subtrsblocklifest)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);

}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBTRSASSO

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSUBTRSASSO( T_UTCTLIB *pbd_utctlib )
{
T_SUBTRSASSO bd_lu;

DEBUT_FCT ("n_retcFetchRowSUBTRSASSO");

//[001]
					strcpy (bd_lu.ASSOTYP_CT, pc_GetStringValue (pbd_utctlib ,0));
					bd_lu.CTX_NT = s_GetSmallintValue(pbd_utctlib ,1);
					strcpy (bd_lu.CTX_LL, pc_GetStringValue (pbd_utctlib ,2));
					strcpy (bd_lu.DETTRNCOD1_CF, pc_GetStringValue (pbd_utctlib ,3));
					strcpy (bd_lu.DETTRNCOD2_CF, pc_GetStringValue (pbd_utctlib ,4));
					strcpy (bd_lu.DETTRNCOD3_CF, pc_GetStringValue (pbd_utctlib ,5));
					bd_lu.GUI_B = s_GetSmallintValue(pbd_utctlib ,6);
					bd_lu.ACMTRS_NT = s_GetSmallintValue(pbd_utctlib ,7);
					strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,8));
					strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,9));
					strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,10));
					strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,11));

if (fwrite(&bd_lu,sizeof(T_SUBTRSASSO),1,Kp_SubtrsAssoFilout)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);

}



/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBTRSBASE

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSUBTRSBASE( T_UTCTLIB *pbd_utctlib )
{
T_SUBTRSBASE bd_lu;

DEBUT_FCT ("n_retcFetchRowSUBTRSBASE");


          bd_lu.PRS_CF= s_GetSmallintValue (pbd_utctlib ,0);
          bd_lu.ACMTRS_NT = s_GetSmallintValue(pbd_utctlib ,1);
          strcpy (bd_lu.DETTRNCOD_CF, pc_GetStringValue (pbd_utctlib ,2));
          bd_lu.ADJSIG_B = s_GetSmallintValue(pbd_utctlib ,3);
          strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,4));
					strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,5));
					strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,6));
					strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,7));

if (fwrite(&bd_lu,sizeof(T_SUBTRSBASE),1,Kp_SubtrsBaseFilout)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);

}

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TACCPAR

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowACCPAR( T_UTCTLIB *pbd_utctlib )
{
T_ACCPAR bd_lu;

DEBUT_FCT ("n_retcFetchRowACCPAR");


          bd_lu.PRS_CF= s_GetSmallintValue (pbd_utctlib ,0);
          bd_lu.ACMTRS_NT = s_GetSmallintValue(pbd_utctlib ,1);
          strcpy (bd_lu.DETTRNCOD_CF, pc_GetStringValue (pbd_utctlib ,2));
          strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,3));
					strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,4));
					strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,5));
					strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,6));

if (fwrite(&bd_lu,sizeof(T_ACCPAR),1,Kp_AccparFilout)<=0) RETURN_VAL(CS_FAIL);

RETURN_VAL(CS_SUCCEED);

}


/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBTRSESBPROP

retour :
                CS_SUCCEED
                CS_FAIL
==============================================================================*/
static CS_RETCODE  n_retcFetchRowSUBTRSESBPROP( T_UTCTLIB *pbd_utctlib )
{
T_SUBTRSESBPROP bd_lu;

DEBUT_FCT ("n_retcFetchRowSUBTRSESBPROP");

          sprintf(bd_lu.DETTRNCOD_CF,"%.2s%.1s%.2s",pc_GetStringValue (pbd_utctlib ,0),pc_GetStringValue (pbd_utctlib ,1),pc_GetStringValue (pbd_utctlib ,2));
					bd_lu.SSD_CF = s_GetSmallintValue(pbd_utctlib ,3);
					bd_lu.ESB_CF = s_GetSmallintValue(pbd_utctlib ,4);
					bd_lu.GLTFEEDING_B = s_GetSmallintValue(pbd_utctlib ,5);
          bd_lu.INTERNRETRO_B = s_GetSmallintValue(pbd_utctlib ,6);
          bd_lu.SRVFEEDING_B = s_GetSmallintValue(pbd_utctlib ,7);
          bd_lu.PREMIUMPNPEGPI_B = s_GetSmallintValue(pbd_utctlib ,8);
          bd_lu.RETROAUTO_B = s_GetSmallintValue(pbd_utctlib ,9);
          bd_lu.COMACIMPACT_B = s_GetSmallintValue(pbd_utctlib ,10);
          bd_lu.CASHFLOWPOS_CT = s_GetSmallintValue(pbd_utctlib ,11);
          bd_lu.GAAP1TRS_CT = s_GetSmallintValue(pbd_utctlib ,12);
          bd_lu.GAAP2TRS_CT = s_GetSmallintValue(pbd_utctlib ,13);
          bd_lu.GAAP3TRS_CT = s_GetSmallintValue(pbd_utctlib ,14);
          bd_lu.GAAP4TRS_CT = s_GetSmallintValue(pbd_utctlib ,15);
          bd_lu.GAAP5TRS_CT = s_GetSmallintValue(pbd_utctlib ,16);
					strcpy (bd_lu.CRE_D, pc_GetStringValue (pbd_utctlib ,17));
					strcpy (bd_lu.CREUSR_CF, pc_GetStringValue (pbd_utctlib ,18));
					strcpy (bd_lu.LSTUPD_D, pc_GetStringValue (pbd_utctlib ,19));
					strcpy (bd_lu.LSTUPDUSR_CF, pc_GetStringValue (pbd_utctlib ,20));

if (fwrite(&bd_lu,sizeof(T_SUBTRSESBPROP),1,Kp_SubtrsEsbProp)<=0) RETURN_VAL(CS_FAIL);

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
	char *sz_COL_LS="EST_ANO21";

	DEBUT_FCT("n_Processing");


	pbd_utctlib->n_RowFetchData = n_retcFetchRowSEGPAR;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSEGPAR_02");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowCTRFIC;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsCTRFIC_02");

/*  Debut Modif GIBU du 08/09/2003  */
/*  Ancienne version appel BEST..PsLIFDRI_03  */

/*    pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRI;
    retcode = n_ProcessingProc (pbd_utctlib,1,"BEST..PsLIFDRI_03",
		"@p_balshtyea_nf",CS_INPUTVALUE,CS_SMALLINT_TYPE,&Ks_Annee,sizeof(CS_SMALLINT),0);
*/

/* Nouvelle version appel BEST..PsLIFDRI_03  */
    pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRI;
    retcode = n_ProcessingProc (pbd_utctlib,2,"BEST..PsLIFDRI_03",
		"@p_balshtyea_nf",CS_INPUTVALUE,CS_SMALLINT_TYPE,&Ks_Annee,sizeof(CS_SMALLINT),0,
                "@p_balshtmth_nf",CS_INPUTVALUE,CS_TINYINT_TYPE,&Ks_Mois,sizeof(CS_TINYINT),0);

/* nouvelle procédure BEST..PsLIFDRI_ALL_01 */
 		pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRI_ALL;
    retcode = n_ProcessingProc (pbd_utctlib,2,"BEST..PsLIFDRI_ALL_01",
    "@p_balshtyea_nf",CS_INPUTVALUE,CS_SMALLINT_TYPE,&Ks_Annee,sizeof(CS_SMALLINT),0,
                "@p_balshtmth_nf",CS_INPUTVALUE,CS_TINYINT_TYPE,&Ks_Mois,sizeof(CS_TINYINT),0);

/* nouvelle procédure BEST..PsLIFDRIY_ALL_01 */
 		pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRIY_ALL; // [007]
    retcode = n_ProcessingProc (pbd_utctlib,2,"BEST..PsLIFDRIY_ALL_01",
    "@p_balshtyea_nf",CS_INPUTVALUE,CS_SMALLINT_TYPE,&Ks_Annee,sizeof(CS_SMALLINT),0,
                "@p_balshtmth_nf",CS_INPUTVALUE,CS_TINYINT_TYPE,&Ks_Mois,sizeof(CS_TINYINT),0);


/* nouvelle procédure BEST..PsLIFDRI_ALL_QUARTER_01 */
 		pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFDRID_ALL; // [007]
    retcode = n_ProcessingProc (pbd_utctlib,2,"BEST..PsLIFDRI_ALL_QUARTER_01",
    "@p_balshtyea_nf",CS_INPUTVALUE,CS_SMALLINT_TYPE,&Ks_Annee,sizeof(CS_SMALLINT),0,
                "@p_balshtmth_nf",CS_INPUTVALUE,CS_TINYINT_TYPE,&Ks_Mois,sizeof(CS_TINYINT),0);


/* Fin Modif GIBU du 08/09/2003 */

    pbd_utctlib->n_RowFetchData = n_retcFetchRowTRSLNK;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsTRSLNK_02");

	n_ExtractCurQuot(pbd_utctlib);

    pbd_utctlib->n_RowFetchData = n_retcFetchRowDETTRS;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsDETTRS_11");

    pbd_utctlib->n_RowFetchData = n_retcFetchRowRETTRF;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsRETTRF_01");


	pbd_utctlib->n_RowFetchData = n_retcFetchRowSOBBLOB;
    	retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSOBBLOB_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSEGMENT;
    	retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsSEGMENT_02");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSSD	;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBSID_11");


	pbd_utctlib->n_RowFetchData = n_retcFetchRowANO;
	n_ProcessingProc (pbd_utctlib,1,"BEST..PsBANTECL_02",
			"@p_col_ls",CS_INPUTVALUE,CS_CHAR_TYPE,sz_COL_LS,9,0);

	pbd_utctlib->n_RowFetchData = n_retcFetchRowACMTRS;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsACMTRSH_02");

	/* Ramene une seule ligne, lue dans Ksz_ungrp */
	pbd_utctlib->n_RowFetchData = n_retcFetchRowUWGRP;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsGRP_03");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowLIFTHR;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsLIFTHR_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSUBTRS;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBTRS_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSUBTRSBLKLIF;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBTRSBLKLIF_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSUBTRSASSO;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBTRSASSO_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSUBTRSBASE;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBTRSBASE_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowACCPAR;
	n_ProcessingProc (pbd_utctlib,0,"BEST..PsTACCPAR_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowSUBTRSESBPROP;
    n_ProcessingProc (pbd_utctlib,0,"BEST..PsSUBTRSESBPROP_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowTRANSCODE;
  	n_ProcessingProc (pbd_utctlib,0,"BEST..PsTRANSTCODE_01");

	pbd_utctlib->n_RowFetchData = n_retcFetchRowTRANSCODE_VRET;
  	n_ProcessingProc (pbd_utctlib,0,"BEST..PsTRANSTCODE_02");

  	 pbd_utctlib->n_RowFetchData = n_retcFetchRowTRSLNK_VRET;
    retcode = n_ProcessingProc (pbd_utctlib,0,"BEST..PsTRSLNK_04");

	n_ExtractCurcsvnIndx(pbd_utctlib);

    RETURN_VAL(retcode);
}




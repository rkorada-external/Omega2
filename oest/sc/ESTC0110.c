/*==============================================================================
Nom de l'application          : Separation du GT acceptation en vie et non vie
Nom du source                 : ESTC0109c
Revision                      : $Revision: 1.2 $
Date de creation              : 18/08/1998
Auteur                        : M.NAJI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Controle des contrats de CTRGRO qui ont plus d'un segment
  Controle des contrats absents du portefeuille
  Controle des contrats absents de la table d'affectation issue de l'infocentre

------------------------------------------------------------------------------
 Historique des modifications :
   13/08/2003  Olivier GIRAUX   On ajoute ds la fichier destiné au remplissage de BEST..TCTRANO, une colonne à 0 qui correspond
                                au champ NUMLINE. Ce champ est utilisé lors de la restitution des anomalies lors du chargement
                                des écritures de service et des estimations vie.
	   ...           ...            ...              ...
30/09/2004  M. DJELLOULI     Modificatioin TRI de FICHIER pour JOB d'entrée
07/12/2005  M. DJELLOULI     Correction Formatage du Fichier des Anomalies (Ajout de ~~ dans la génération)
27/03/2008  J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
17/10/2014  Floret      :spot:27466 Extraction de TCTRGRO au format de BEST..TCTRGRO + 1 field to test the nature
21/01/2019  M.NAJI  SPIRA 57605 add CTRGRO_UWY_NF 
21/02/2019  M.NAJI  SPIRA 57605  add SGEPOR_UWY_NF 
15/05/2019  M.NAJI  SPIRA 57605  Correction du dÃ©calage des la colonne UWY
13/11/2019	L. WERNERT SPIRA 79651 Add constant SEGPOR_SEGTYP_CT2 corresponding to the CTRGRO file format 
28/01/2022 HR CTRGRO_UWY_NF = 7 for filssanspere + numline
26/08/2022 M.NAJI : SPIRA 106492 CTRGRO_UWY_NF par CTRGRO_UWY_NF1 pour le fils  et corrigé le accolades dans n_ActionLigneSync
==============================================================================*/
/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"


//for the controls extra field needed just in this program
#define CTRGRO_CTRNAT_CF 20
#define CTRGRO_UWY_NF 21
#define CTRGRO_UWY_NF1 7
#define SEGPOR_SEGTYP_CT2 5

typedef struct {
        char            SEG_NF   [11] ;
        char            SEGNAT_CT ;
        int             CTRRET_B  ;
} T_SEGMENT1 ;

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		     	*Kp_OutputAno;

T_RUPTURE_VAR 		bd_RuptCTRGRO;
T_RUPTURE_SYNC_VAR 	bd_SEGPOR;
T_SEGMENT1		tb_Segment[2000] ;

int	Knb_Segments=0 ;
char	Ksz_VRS_NF[20] ;
/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_ChargeSegment(T_SEGMENT1 *pdb_Segment);

int n_InitRupture	(T_RUPTURE_VAR  *pbd_RuptCTRGRO);
int n_ActionLigne 	(char *ptsz_LigneCour[]);
int n_IsR1CTRGRO	( char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionF1CTRGRO	(char *ptsz_LigneCour[]);
int n_ActionL1CTRGRO	(char *ptsz_LigneCour[]);


/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync		(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPere(char **ptsz_LigneFils);
int n_ActionPereSansFils(char **ptsz_LigneMaitre);


int n_ChercheSegment(char *);

int numline = 0;

/**************************************************************************/
/*** Objet : Separation du fichier GT en dommages et vie		***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/



int main(
   int argc,
   char *argv[]
)
{

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }


   strcpy(Ksz_VRS_NF,psz_GetCharArgv(1));

/* Ouverture du fichier de sortie GT */
   if (n_OpenFileAppl("ESTC0110_O1", "wt", &Kp_OutputAno) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenGT");
   }

    if ( n_ChargeSegment(tb_Segment) == ERR )
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenGT");

/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_RuptCTRGRO ) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation du GTA avec le perimetre */
   if (n_InitSync(&bd_SEGPOR) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGTA");
   }


/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_RuptCTRGRO) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0110_I1", &(bd_RuptCTRGRO.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0110_I2", &(bd_SEGPOR.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }


   if (n_CloseFileAppl("ESTC0110_O1", &Kp_OutputAno) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplDom");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }


   exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture avec le fichier	***/
/***   	     IADVPERICASE						***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_RuptCTRGRO : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_RuptCTRGRO
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_RuptCTRGRO, 0, sizeof(T_RUPTURE_VAR));

   /* Ouverture du fichier maitre */

   if (n_OpenFileAppl("ESTC0110_I1", "rt", &(pbd_RuptCTRGRO->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }

   pbd_RuptCTRGRO->n_NbRupture = 1 ;
   pbd_RuptCTRGRO->n_ConditionRupture[0]= n_IsR1CTRGRO;
   pbd_RuptCTRGRO->n_ActionFirst[0]     = n_ActionF1CTRGRO;
   pbd_RuptCTRGRO->n_ActionLast[0]      = n_ActionL1CTRGRO;
   pbd_RuptCTRGRO->n_ActionLigne	=n_ActionLigne;
   pbd_RuptCTRGRO->c_Separ		= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation du maitre avec	***/
/***         l'esclave IADVPERICASE                                     ***/
/***									***/
/*** Nom : n_InitSync     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTC0110_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }


   pbd_Sync->ConditionEndSync	=n_ConditionSync;
   pbd_Sync->n_ActionLigne	=n_ActionLigneSync;
   pbd_Sync->n_FilsSansPere	=n_ActionFilsSansPere;
   pbd_Sync->n_PereSansFils	=n_ActionPereSansFils;
   pbd_Sync->c_Separ='~';

   RETURN_VAL(OK);
}



/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigne(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

/* Synchronisation avec le GTA */
   if( 	b_IsRupture(&bd_RuptCTRGRO, F1) == FALSE ||
	b_IsRupture(&bd_RuptCTRGRO, L1) == FALSE )
   {
	if ( 	 *ptsz_LigneCour[CTRGRO_CTRRET_B] == '0'  &&
		(*ptsz_LigneCour[CTRGRO_SEGTYP_CT] != 'E' || *ptsz_LigneCour[CTRGRO_CTRNAT_CF] != 'P' ))
 
        numline = numline + 1;        

	fprintf(Kp_OutputAno, "%s~%s~%s~%s~%s~%s~%s~3~%d~%s~\n",       // MOD01
		ptsz_LigneCour[CTRGRO_CTR_NF],    // 1
		ptsz_LigneCour[CTRGRO_END_NT],	  // 2		
		ptsz_LigneCour[CTRGRO_SEC_NF],	  // 3	
		ptsz_LigneCour[CTRGRO_VRS_NF],	  // 4	
		ptsz_LigneCour[CTRGRO_SSD_CF],	  // 5	
		ptsz_LigneCour[CTRGRO_SEGTYP_CT], // 6
		ptsz_LigneCour[CTRGRO_SEG_NF],	  // 7	
         										  // 8  ANO_CT
		numline,								  // 9  NUMLINE_NT
		ptsz_LigneCour[CTRGRO_UWY_NF]	  // 10 	
		);
   }

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction de test de rupture***/
/******/
/*** Nom : n_IsR1GTA ***/
/******/
/*** Parametres:                                                        ***/
/***    i ptsz_LineSuiv : pointeur sur la ligne suivante,               ***/
/***    i ptsz_LineCour : pointeur sur la ligne precedente.             ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***    0 si pas de rupture,                                            ***/
/***    1 si rupture.                                                   ***/
/**************************************************************************/

int n_IsR1CTRGRO(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   int n_ret;

   DEBUT_FCT("n_TestRupture");

   if ((n_ret = strcmp(ptsz_LigneSuiv[CTRGRO_CTR_NF], ptsz_LigneCour[CTRGRO_CTR_NF]))) {
      return n_ret;
   }
   if ((n_ret = strcmp(ptsz_LigneSuiv[CTRGRO_END_NT], ptsz_LigneCour[CTRGRO_END_NT]))) {
      return n_ret;
   }
   if ((n_ret = strcmp(ptsz_LigneSuiv[CTRGRO_SEC_NF], ptsz_LigneCour[CTRGRO_SEC_NF]))) {
      return n_ret;
   }
   //if ((n_ret = strcmp(ptsz_LigneSuiv[CTRGRO_SSD_CF], ptsz_LigneCour[CTRGRO_SSD_CF]))) {
   //   return n_ret;
   //}
   //if ( ( ret = strcmp( ptsz_LigneSuiv[CTRGRO_SEGTYP_CT], ptsz_LigneCour[CTRGRO_SEGTYP_CT] ) ) != 0 ) return ret ;
 
   RETURN_VAL(strcmp(ptsz_LigneSuiv[CTRGRO_UWY_NF],   ptsz_LigneCour[CTRGRO_UWY_NF]));
 
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre***/
/******/
/*** Nom : n_ActionLigneRupture***/
/******/
/*** Parametres:***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante***/
/******/
/*** Retour:***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionF1CTRGRO(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");

/* Synchronisation avec SEGPOR */

   n_ProcessingRuptureSyncVar(&bd_SEGPOR, ptsz_LigneCour);

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre***/
/******/
/*** Nom : n_ActionLigneRupture***/
/******/
/*** Parametres:***/
/***    i ptsz_LigneCour : pointeur sur la ligne courante***/
/******/
/*** Retour:***/
/***    OK si pas d'erreur,                                             ***/
/***    ERR si erreur.                                                  ***/
/**************************************************************************/

int n_ActionL1CTRGRO(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionLigneRupture");



   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation maitre esclave				***/
/***									***/
/*** Nom : n_ConditionSync						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSync");

/* MOD002 Modification Clé de RUPTURE par TRI Fichier JOB Entrée.
   if (s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_CTR_NF], ptsz_LigneEsclave[SEGPOR_CTR_NF])) {
      RETURN_VAL(s_ret);
   }

   if (s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_SEC_NF], ptsz_LigneEsclave[SEGPOR_SEC_NF])) {
      RETURN_VAL(s_ret);
   }

   if (s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_END_NT], ptsz_LigneEsclave[SEGPOR_END_NT])) {
      RETURN_VAL(s_ret);
   }

   if (s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_SSD_CF], ptsz_LigneEsclave[SEGPOR_SSD_CF])) {
      RETURN_VAL(s_ret);
   }

   RETURN_VAL (strcmp(ptsz_LigneMaitre[CTRGRO_SEGTYP_CT], ptsz_LigneEsclave[SEGPOR_SEGTYP_CT]));
*/

   if ((s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_CTR_NF], ptsz_LigneEsclave[SEGPOR_CTR_NF]))) {
      RETURN_VAL(s_ret);
   }

   if ((s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_END_NT], ptsz_LigneEsclave[SEGPOR_END_NT]))) {
      RETURN_VAL(s_ret);
   }

   if ((s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_SEC_NF], ptsz_LigneEsclave[SEGPOR_SEC_NF]))) {
      RETURN_VAL(s_ret);
   }

   //if ((s_ret = strcmp(ptsz_LigneMaitre[CTRGRO_SSD_CF], ptsz_LigneEsclave[SEGPOR_SSD_CF]))) {
   //   RETURN_VAL(s_ret);
   //}


   //RETURN_VAL (strcmp(ptsz_LigneMaitre[CTRGRO_SEGTYP_CT], ptsz_LigneEsclave[SEGPOR_SEGTYP_CT]));
   
   
  	// si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
	if (   *ptsz_LigneMaitre[CTRGRO_UWY_NF] == 0 || *ptsz_LigneMaitre[CTRGRO_UWY_NF] == '0' ) return 0 ;
	// sinon il faut que l'exercie synchronise 


   RETURN_VAL (strcmp(ptsz_LigneMaitre[CTRGRO_UWY_NF], ptsz_LigneEsclave[SEGPOR_UWY_NF]));


}
/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de l'esclave		***/
/***									***/
/*** Nom : n_ActionLigneSync						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   int n_Ind ;
   DEBUT_FCT("n_ActionLigneSync");

   n_Ind=n_ChercheSegment(ptsz_LigneMaitre[CTRGRO_SEG_NF]) ;
   if( n_Ind >= 0 )
   {
		// si on trouve un segment CTRGRO_SEG_NF du père (I1) 
		// et SEGPOR_CTRNAT_CT du père (I1) est différent de SEGNAT_CT du fils (I2)
		// alors on ecrit une erreur 4
		if ( (*ptsz_LigneEsclave[SEGPOR_CTRNAT_CT] != tb_Segment[n_Ind].SEGNAT_CT) != 0 )
		{
			numline = numline + 1;
			fprintf(Kp_OutputAno, "%s~%s~%s~%s~%s~%s~%s~4~%d~%s~\n",    //MOD01
				ptsz_LigneEsclave[SEGPOR_CTR_NF],	 // 1
				ptsz_LigneEsclave[SEGPOR_END_NT],    // 2		
				ptsz_LigneEsclave[SEGPOR_SEC_NF],    // 3	
				Ksz_VRS_NF,                          // 4	
				ptsz_LigneEsclave[SEGPOR_SSD_CF],    // 5	
				ptsz_LigneEsclave[SEGPOR_SEGTYP_CT], // 6
				ptsz_LigneMaitre[CTRGRO_SEG_NF],     // 7	
													 // 8  ANO_CT
				numline,                             // 9  NUMLINE_NT
				ptsz_LigneEsclave[CTRGRO_UWY_NF1]     // 10 	
				);
		}

		// si on trouve un segment CTRGRO_SEG_NF du père (I1) 
		// et le SEGPOR_CTRRET_B di fils (I2) est different CTRRET du segmenet 
		// et CTRGRO_CTRRET_B du père (I1) est vide 
		// et CTRGRO_SEGTYP_CT du père I1 est différent de 'E' ou et CTRGRO_CTRNAT_CF du père I1 est différent de 'P' 
		// alors on écrit unne erreur 5
		if ( atoi(ptsz_LigneEsclave[SEGPOR_CTRRET_B]) != tb_Segment[n_Ind].CTRRET_B )
		{
			if ((*ptsz_LigneMaitre[CTRGRO_CTRRET_B] == '0') && (*ptsz_LigneMaitre[CTRGRO_SEGTYP_CT] != 'E' || *ptsz_LigneMaitre[CTRGRO_CTRNAT_CF] != 'P' ))
			{
					numline = numline + 1;

				fprintf(Kp_OutputAno, "%s~%s~%s~%s~%s~%s~%s~5~%d~%s~\n",    //MOD01
					ptsz_LigneEsclave[SEGPOR_CTR_NF],	 // 1
					ptsz_LigneEsclave[SEGPOR_END_NT],    // 2		
					ptsz_LigneEsclave[SEGPOR_SEC_NF],    // 3	
					Ksz_VRS_NF,                          // 4	
					ptsz_LigneEsclave[SEGPOR_SSD_CF],    // 5	
					ptsz_LigneEsclave[SEGPOR_SEGTYP_CT], // 6
					ptsz_LigneMaitre[CTRGRO_SEG_NF],     // 7	
														 // 8  ANO_CT
					numline,                             // 9  NUMLINE_NT
					ptsz_LigneEsclave[CTRGRO_UWY_NF1]     // 10 	
					);
			}
		}
   }

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier ne 		***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFils						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionFilsSansPere(char *ptsz_Ligne[])
{
   DEBUT_FCT("int n_ActionFilsSansPere");
   if (     *ptsz_Ligne[SEGPOR_CTRRET_B] == '0'  &&
           (*ptsz_Ligne[SEGPOR_SEGTYP_CT] != 'E' || *ptsz_Ligne[SEGPOR_CTRNAT_CT] != 'P' ))

        numline = numline + 1;

	fprintf(Kp_OutputAno, "%s~%s~%s~%s~%s~%s~%s~1~%d~%s~\n",    //MOD01
		ptsz_Ligne[SEGPOR_CTR_NF],	  // 1
		ptsz_Ligne[SEGPOR_END_NT],    // 2		
		ptsz_Ligne[SEGPOR_SEC_NF],    // 3	
		Ksz_VRS_NF,                   // 4	
		ptsz_Ligne[SEGPOR_SSD_CF],    // 5	
		ptsz_Ligne[SEGPOR_SEGTYP_CT], // 6
		ptsz_Ligne[CTRGRO_SEG_NF],    // 7	
			  		  // 8  ANO_CT
	        numline,		  // 9  NUMLINE_NT
		//ptsz_Ligne[CTRGRO_UWY_NF]     // 10 	
		ptsz_Ligne[CTRGRO_UWY_NF1]     // 10 	
		);



  	 RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier ne 		***/
/***         correspond a la ligne courante du fichier maitre           ***/
/***									***/
/*** Nom : n_ActionPereSansFils						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPereSansFils(char *ptsz_Ligne[])
{
   DEBUT_FCT("int n_ActionPereSansFils");
   if ( *ptsz_Ligne[CTRGRO_CTRRET_B] == '0'  &&
   	(*ptsz_Ligne[CTRGRO_SEGTYP_CT] != 'E' || *ptsz_Ligne[CTRGRO_CTRNAT_CF] != 'P' ))

        numline = numline + 1;    

	fprintf(Kp_OutputAno, "%s~%s~%s~%s~%s~%s~%s~2~%d~%s~\n",    //MOD01
		ptsz_Ligne[SEGPOR_CTR_NF],	  // 1
		ptsz_Ligne[SEGPOR_END_NT],    // 2		
		ptsz_Ligne[SEGPOR_SEC_NF],    // 3	
		Ksz_VRS_NF,                   // 4	
		ptsz_Ligne[SEGPOR_SSD_CF],    // 5	
		ptsz_Ligne[SEGPOR_SEGTYP_CT2], // 6
		ptsz_Ligne[CTRGRO_SEG_NF],    // 7	
									  // 8  ANO_CT
		numline,							  // 9  NUMLINE_NT
		ptsz_Ligne[CTRGRO_UWY_NF]     // 10 	
		);

   RETURN_VAL(OK);
}


int n_ChargeSegment(T_SEGMENT1 *pdb_Segment)
{
	FILE    *pf;
	char    sz_Buff[201] ;
	int     i,j;
	char    *p;
	int len ;

	DEBUT_FCT ( "n_ChargeSegment" ) ;

  	if (n_OpenFileAppl("ESTC0110_I3", "rt", &pf) == ERR) {
           RETURN_VAL ( ERR ) ;
   	}

	while ( fgets(sz_Buff,200,pf) )
	{
        	p = sz_Buff ;
        	len = strlen(sz_Buff) ;
        	len--;
        	sz_Buff[len] = 0 ;
		i=j=0 ;
        	for(i=0; i < len; i++ )
        	{
                	if( sz_Buff[i]== '~' )
                	{
                        	sz_Buff[i] = 0;
				switch(j)
				{
				  case 3 : /* SEG_NF */
					   strcpy(pdb_Segment[Knb_Segments].SEG_NF,p) ;
				   break ;
				  case 6 : /* SEGNAT_CT */
					   pdb_Segment[Knb_Segments].SEGNAT_CT =*p;
				   break ;
				  case 7 : /* CTRRET_B */
				           pdb_Segment[Knb_Segments].CTRRET_B  =atoi(p);
				   break ;
				}
				p = sz_Buff + i + 1;
				j++ ;
                	}
        	}
		Knb_Segments++;
	}


   	if (n_CloseFileAppl("ESTC0110_I3", &pf) == ERR) {
           RETURN_VAL ( ERR ) ;
   	}

/*	for ( i=0 ; i<Knb_Segments; i++ )
	{
		printf("%s %c %d \n", 	pdb_Segment[i].SEG_NF,
					pdb_Segment[i].SEGNAT_CT,
					pdb_Segment[i].CTRRET_B);
	}
*/
        RETURN_VAL ( OK ) ;

}

int n_ChercheSegment(char *sz_SEG_NF)
{
	int i ;
	for( i=0; i<Knb_Segments; i++)
	{
		if( strcmp(tb_Segment[i].SEG_NF,sz_SEG_NF) == 0 )
			return i ;
	}
	return -1 ;
}

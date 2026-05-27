/******************************************************************************
 * Application      : Filtrer les poste pour le calcul de libération
 * Source           : ESTC2170.c
 * Revesion         : 0.1
 * Date de creation : 21/09/2020
 * Auteur           : B.Lagha
 *
 * ----------------------------------------------------------------------------
 * Description 
 * -----------
 * 	on filtre les poste de constitution pour prendre que les postes de reserve 
 *	qui satidfait les conditions suivantes :
 *		- un poste de reserve --> TRSTYP == 3
 *		- type de transformation est assumed family --> TRANSTYPE == 'ASSFA'
 *		- type d'assocition 5 --> ASSOTYP == 5
 *
 * ----------------------------------------------------------------------------
 * Historique des modifications
 * ----------------------------
 *  date de modif	Auteur		description
 *  -------------	------		-----------
 *
 *****************************************************************************/

/* inclusion des interfaces des composants importes */
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


/* Declaration des variables globales */
FILE *kp_PlcFile;          /* pointeur sur les placements           */
FILE *kp_PrevInFile;       /* pointeur sur les previsions en entree */
FILE *kp_PrevOutFile;      /* pointeur sur les previsions en sortie */
FILE *kp_PrevNoSyncOutFile;/* pointeur sur les previsions en sortie */
FILE *kp_SubTRSAssoFile;   /* pointeur sur le fichier FSUBTRSASSO   */
FILE *kp_SubTRSFile;       /* pointeur sur le fichier FSUBTRS       */
FILE *kp_TransTCode;       /* pointeur sur le fichier TRANSTCODE    */

T_SUBTRS            SubTrsLigne;                /* structure de ligne TSUBTRS     */
T_SUBTRSASSO        SubTrsAssoLigne;            /* structure de ligne TSUBTRSASSO */
static T_TRANSTCODE bd_TRANSTCODE[MAX_TDETTRS]; /* Structure BRET..TRTRANSTCODE */

T_RUPTURE_VAR       bd_RuptPlc;     /* gestion rupture sur placement  */
T_RUPTURE_SYNC_VAR  bd_RuptPrev;    /* gestion rupture sur prevision  */

/* Initialisateurs de rupture */
int n_InitPlc (T_RUPTURE_VAR *pbd_Rupt);
int n_InitPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt);

/* Conditions de rupture */
int n_ConditionSynchro (char **pbd_InRecOwner, char **pbd_InRecChild);

/* Les actions sur les ruptures*/
int n_ActionLignePlc (char **ptb_InRec_Cur);
int n_ActionLignePrev (char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFilsSansPere (char **ptb_InRec_Cur);

/* Fonctions complementaires */
void init_SubTrsAssoLigne();
void CompleterPoste (char *lob, char *DETTRN, int norme, char *ACMTRS, char *poste);

/* Variable globales*/
int Kn_NbTranstcode;


/* Point d'entre de l'application */
int main (int argc, char* argv[]){
	/* initialisation des signaux */
	InitSig();
	/* Initialisation du programme et recuperation des var d'env*/
	if ( n_BeginPgm (argc, argv) == ERR )
		ExitPgm (ERR_XX , "");

	/* Ouverture des fichiers */
	if (n_OpenFileAppl ("ESTC2170_O1", "wt", &kp_PrevOutFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_O2", "wt", &kp_PrevNoSyncOutFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_I1", "rt", &kp_PlcFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_I2", "rt", &kp_PrevInFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_I3", "rb", &kp_SubTRSAssoFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_I4", "rb", &kp_SubTRSFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_OpenFileAppl ("ESTC2170_I5", "rb", &kp_TransTCode) == ERR)
		ExitPgm (ERR_XX , "");

	/* Chargement en memoire du fichier pilotage */
	if (n_ChargerTsubTRS(kp_SubTRSFile) == ERR ) ExitPgm (ERR_XX , "");
	Kn_NbTranstcode = n_LoadTRANSTCODE(kp_TransTCode, bd_TRANSTCODE);
	init_SubTrsAssoLigne();
	if ( n_ChargerTsubTRSAsso(kp_SubTRSAssoFile) == ERR ) ExitPgm( ERR_XX , "");

	/* Initialisation de la rupture sur les placements */
	if (n_InitPlc(&bd_RuptPlc) == ERR )	ExitPgm (ERR_XX , "");
	/* Initialisation de la rupture sync entre les plc et les prev*/
	if ( n_InitPrev(&bd_RuptPrev) ) ExitPgm (ERR_XX , "");
	/* Lancement du traitement du fichier de placement */
	if ( n_ProcessingRuptureVar (&bd_RuptPlc) == ERR ) ExitPgm (ERR_XX , "");

	/* Fermiture des fichiers */
	if (n_CloseFileAppl ("ESTC2170_I1", &kp_PlcFile) == ERR )
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170_I2", &kp_PrevInFile) == ERR )
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170_I3", &kp_SubTRSAssoFile) == ERR )
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170_I4", &kp_SubTRSFile) == ERR )
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170I51",  &kp_TransTCode) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170_O1",  &kp_PrevOutFile) == ERR)
		ExitPgm (ERR_XX , "");

	if (n_CloseFileAppl ("ESTC2170_O2",  &kp_PrevNoSyncOutFile) == ERR)
		ExitPgm (ERR_XX , "");



	return EXIT_SUCCESS;
}


/*************************************************************************
 * Initialisation de la rupture sur le placement
 * Retour : OK (0) si elle termine avec success
 *************************************************************************/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt) {
	DEBUT_FCT("n_InitPlc");
	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	pbd_Rupt->pf_InputFil   = kp_PlcFile; 
	pbd_Rupt->n_NbRupture   = 0;
	pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;
	pbd_Rupt->c_Separ       = SEPARATEUR;

	RETURN_VAL (OK);
}


/*************************************************************************
 * Action sur chaque ligne du fihcier des placements
 * Description :
 * -------------
 *	Pour chaque nouvelle ligne dans le fichier des placements, nous 
 *	effectuons un appel de syncro entre cette ligne et les lignes des
 *	prevesions qui satisfait la condition de syncro.
 *************************************************************************/
int n_ActionLignePlc(char **ptb_InRec_Cur) {
	DEBUT_FCT("n_ActionLignePlc");

	n_ProcessingRuptureSyncVar (&bd_RuptPrev, ptb_InRec_Cur);

	RETURN_VAL (OK);
}


/*************************************************************************
 * Initialisation de rupture syncro entre les placements (maitre) et 
 * les previsions (esclave)
 * Retour : OK (0) si elle termine avec success
 *************************************************************************/
int n_InitPrev(T_RUPTURE_SYNC_VAR *pbd_Rupt) {
	DEBUT_FCT("n_InitPrev");
	memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

	pbd_Rupt->pf_InputFil      = kp_PrevInFile;
	pbd_Rupt->n_NbRupture      = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSynchro;
	pbd_Rupt->n_ActionLigne    = n_ActionLignePrev;
	pbd_Rupt->n_FilsSansPere   = n_ActionFilsSansPere;
	pbd_Rupt->c_Separ          = SEPARATEUR;

	RETURN_VAL (OK);
}


/*************************************************************************
 * Condition de rupture syncro entre le placement et les previsions
 * pbd_InRecOwner --> ligne du placement (maitre)
 * pbd_InRecChild --> ligne de prevision (esclave ou fils)
 * Retour :
 * --------                    (<<========>>)  
 *	si == 0 --> pbd_InRecOwner est sync avec pbd_InRecChild
 *	si  > 0 --> pbd_InRecOwner > pbd_InRecChild (le fils bougera)
 *	si  < 0 --> pbd_InRecOwner < pbd_InRecChild (le pere bougera)
 *************************************************************************/
int n_ConditionSynchro (char **pbd_InRecOwner, char **pbd_InRecChild) {
	DEBUT_FCT("n_ConditionSynchro");
	int ret = 0;

	if( (ret = strcmp(pbd_InRecOwner[PLA1_CTR_NF],pbd_InRecChild[PRE_CTR_NF])) != 0 )
		RETURN_VAL (ret);
	if( (ret = strcmp(pbd_InRecOwner[PLA1_END_NT],pbd_InRecChild[PRE_END_NT])) != 0 )
		RETURN_VAL (ret);
	if( (ret = strcmp(pbd_InRecOwner[PLA1_SEC_NF],pbd_InRecChild[PRE_SEC_NF])) != 0 )
		RETURN_VAL (ret);
	if( (ret = strcmp(pbd_InRecOwner[PLA1_UWY_NF],pbd_InRecChild[PRE_UWY_NF])) != 0 )
		RETURN_VAL (ret);
	if( (ret = strcmp(pbd_InRecOwner[PLA1_UW_NT],pbd_InRecChild[PRE_UW_NT]))   != 0 )
		RETURN_VAL (ret);

	RETURN_VAL (0);
}


/*************************************************************************
 * Action sur chaque ligne syncro entre les placements et les previsions
 * Description :
 * -------------
 *  ptb_InRecOwner --> ligne du maitre (plc)
 *  ptb_InRecChild --> ligne du fils/esclave (prevision)
 *************************************************************************/ 
int n_ActionLignePrev(char **ptb_InRecOwner, char **ptb_InRecChild) {
	DEBUT_FCT("n_ActionLignePrev");

	int  isASSFA        = 0;
	int  isASSTYPE5     = 0;
	int  sz_ACCTYP      = 0;
	char FAMTRN_CF[2]   ="0";
	char sz_DETTRS_CF[9]="";
	char TRADETTRS[9]   =""; 
	char TRADETTRS5[6]  ="";

	/* Si c'est une liberation alors nous la prenons pas */
	if (ptb_InRecChild[PRE_ACMTRS_NT][3] == '4')
	{
		n_WriteCols(kp_PrevNoSyncOutFile, ptb_InRecChild, SEPARATEUR, 0);
		RETURN_VAL (OK);
	}

	/* Test si le poste de prevision n'est pas un poste de reserve */
	int index = n_FindTsubTRS(&SubTrsLigne, ptb_InRecChild[PRE_DETTRNCOD_CF]);
	if (index == -1 || SubTrsLigne.TRSTYPE_CT != 3)
	{
		n_WriteCols(kp_PrevNoSyncOutFile, ptb_InRecChild, SEPARATEUR, 0);
		RETURN_VAL (OK);
	}

	/* Test si Assumed family */	
	if (strcmp(ptb_InRecOwner[PLA1_ACCFAM_CT], "") != 0) {
		isASSFA = 1;
		sz_ACCTYP = atoi(ptb_InRecOwner[PLA1_ACCTYP_CT]);
		strcpy(FAMTRN_CF,ptb_InRecOwner[PLA1_ACCFAM_CT]);
	}

	/* C'est Assumed family */
	if (isASSFA != 0)
	{
		/* Completer le poste a 5 pour avoir un poste a 8 */
		if (strcmp(ptb_InRecChild[PRE_DETTRS_CF], "        ") <= 0) {
			CompleterPoste (ptb_InRecChild[PRE_LOB_CF],
			                ptb_InRecChild[PRE_DETTRNCOD_CF],
			                atoi(ptb_InRecChild[PRE_GAAP_NF]),
			                ptb_InRecChild[PRE_ACMTRS_NT],
			                sz_DETTRS_CF);
		}
		else {
			sprintf (sz_DETTRS_CF, "%.8s%c", ptb_InRecChild[PRE_DETTRS_CF], 0);
			/* car dans la table TTRANSTCODE nous trouvons que des suffixes 0 et 2 */
			if (sz_DETTRS_CF[7] != '0' && sz_DETTRS_CF[7] != '2')
				sz_DETTRS_CF[7] = '0';
		}

		/* Utiliser le poste a 8 pour trouver le poste de transformation qui correspond */
		int index_postTran = n_GetPostranstcode(sz_DETTRS_CF,
									ptb_InRecOwner[PLA1_CTRNAT_CT], sz_ACCTYP,
									FAMTRN_CF, bd_TRANSTCODE, Kn_NbTranstcode);
		if ( index_postTran >= 0 )
		{
			sprintf(TRADETTRS, "%.8s%c", bd_TRANSTCODE[index_postTran].TRADETTRS_CF, 0);
			sprintf(TRADETTRS5, "%.5s%c", TRADETTRS+2, 0);

			/* Test si le poste de transformation est de type 5 */
			int reslt = -1;
			reslt = n_FindTsubTRSAssoCons(5, 1, TRADETTRS5);

			/*Si on rien trouver avec n_FindTsubTRSAssoCons on test avec n_FindTsubTRSAsso */
			if (reslt == -1)
				reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne,5,1,TRADETTRS5);

			/* on positionne isASSTYPE5 a 'true' */
			if (reslt != -1 )
				isASSTYPE5 = 1;
		}

	}

	/* Si le CTR et le poste verifie les conditions on ecrit la ligne en sortie sync */
	if (isASSFA != 0 && isASSTYPE5 != 0) 
		n_WriteCols(kp_PrevOutFile, ptb_InRecChild, SEPARATEUR, 0);
	else 
		n_WriteCols(kp_PrevNoSyncOutFile, ptb_InRecChild, SEPARATEUR, 0);


	RETURN_VAL (OK);
}


/*************************************************************************
 * Action a lancer si une prevision n'a pas de placement 
 * 
 *************************************************************************/
int n_ActionFilsSansPere (char **ptb_InRec_Cur) {
	DEBUT_FCT("n_ActionFilsSansPere");

	n_WriteCols(kp_PrevNoSyncOutFile, ptb_InRec_Cur, SEPARATEUR, 0);

	RETURN_VAL (OK);
}


/*************************************************************************
 * ** Objet : fonction permettant de formater le poste complement
 * ** (poste a 8 digits), ajoute prefixe, sous-prefixe et suffixe
 * ** Entree: type: 1 pour acceptation,
 * **               2 pour retrocession = 1er chiffre de l'ACMTRS
 * ***********************************************************************/
void CompleterPoste (char *lob, char *DETTRN, int norme, char *ACMTRS, char *poste) {
	DEBUT_FCT("CompleterPoste");

	int  n_lob;
	int  reslt;
	char TRN1[2];
	char TRN2[2];
	char TRN8[2];

	/* Calcul par defaut du poste complement */
	if (strcmp(lob, "0") == 0 && (norme == 0))
	{
		TRN1[0] = poste[0];
		TRN1[1] = 0;
		TRN2[0] = poste[1];
		TRN2[1] = 0;
		TRN8[0] = poste[7];
		sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, TRN8);
		poste[8] = 0;
		ACMTRS[3] = '4';
		return;
	}

	/* Calcul du 8eme cractere du poste a 8 digit 8 '.. ..... x' */
	n_lob = atoi(lob);
	switch (norme)
	{
		case 1: strcpy(TRN8, "2");
			break;
		case 2: strcpy(TRN8, "A");
			break;
		case 3: strcpy(TRN8, "C");
			break;
		case 4: strcpy(TRN8, "E");
			break;
		case 5: strcpy(TRN8, "G");
			break;
		default:
			strcpy(TRN8, "2");
	}
	TRN8[1] = 0;

	/* Calcul du 1er cractere du poste a 8 digit 1 'x. ..... .' */
	char type = ACMTRS[0];
	if ( (type == '1') && (n_lob == 31) )
		strcpy(TRN1, "1");
	if ( (type == '2') && (n_lob == 31) )
		strcpy(TRN1, "2");
	if ( (type == '1') && (n_lob == 30) )
		strcpy(TRN1, "3");
	if ( (type == '2') && (n_lob == 30) )
		strcpy(TRN1, "4");
	TRN1[1] = 0;

	/* Calcul du 2eme cractere du poste a 8 digit 2 '.x ..... .' */
	reslt = n_FindTsubTRS(&SubTrsLigne, DETTRN);
	if (reslt != -1)
	{
		if ((SubTrsLigne.TRSTYPE_CT == 1) ||
		    (SubTrsLigne.TRSTYPE_CT == 2) ||
		    (SubTrsLigne.TRSTYPE_CT == 3))
		{ strcpy(TRN2, "1"); }
		else if (SubTrsLigne.TRSTYPE_CT == 4 )
		{ strcpy(TRN2, "3"); }
		else
		{ strcpy(TRN2, "9"); }
	}
	if (DETTRN[0] == '2')
		strcpy(TRN2, "1");
	TRN2[1] = 0;

	//Cas particuliers :
	//------------------
	if (strcmp(DETTRN, "90860") == 0)
	{
		strcpy(TRN2, "1");
		TRN2[1] = 0;
	}
	// 81xxx ou 85xxx
	if ((DETTRN[0] == '8') && ((DETTRN[1] == '1') || (DETTRN[1] == '5')))
	{
		strcpy(TRN2, "2");
		TRN2[1] = 0;
	}

	if ((strcmp(DETTRN, "90300") == 0) ||
	    (strcmp(DETTRN, "90310") == 0) ||
	    (strcmp(DETTRN, "90320") == 0) ||
	    (strcmp(DETTRN, "90330") == 0) ||
	    (strcmp(DETTRN, "90410") == 0))
	{
		strcpy(TRN2, "3");
		TRN2[1] = 0;
	}

	// 82xxx ou 83xxx ou 84xxx
	if ((DETTRN[0] == '8') && (
	    (DETTRN[1] == '2') ||
	    (DETTRN[1] == '3') ||
	    (DETTRN[1] == '4') ))
	{
		strcpy(TRN2, "3");
		TRN2[1] = 0;
	}

	sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, "0");
	poste[8] = 0;
}


/*************************************************************************
 * Objet :    Initialisation de la structure TRSASSO
 * Nom:       init_SubTrsAssoLigne
 * Parametres:
 * Retour:    Rien
 * ***********************************************************************/
void init_SubTrsAssoLigne() {
	strcpy (SubTrsAssoLigne.ASSOTYP_CT,"");
	SubTrsAssoLigne.CTX_NT=0;
	strcpy (SubTrsAssoLigne.DETTRNCOD1_CF,"");
	strcpy(SubTrsAssoLigne.CTX_LL,"");
	strcpy (SubTrsAssoLigne.DETTRNCOD2_CF,"");
	strcpy (SubTrsAssoLigne.DETTRNCOD3_CF,"");
	SubTrsAssoLigne.GUI_B=0;
	SubTrsAssoLigne.ACMTRS_NT=0;
	strcpy(SubTrsAssoLigne.CRE_D,"");
	strcpy(SubTrsAssoLigne.CREUSR_CF,"");
	strcpy(SubTrsAssoLigne.LSTUPD_D,"");
	strcpy(SubTrsAssoLigne.LSTUPDUSR_CF,"");
}

// END 

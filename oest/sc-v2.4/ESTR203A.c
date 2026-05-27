/*==============================================================================
nom de l'application          : Edition du compte-rendu du calcul des
				complements vie
nom du source                 : ESTR203A.c
revision                      : $Revision:   1.1  $
date de creation              : 04/07/1997
auteur                        : C. Chavatte (C.G.I.)
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Le fichier des anomalies en entree est sous format bcp (avec
	des separateurs). Ce programme va modifier le format afin de
	realiser une impression avec Starjet. Le but est de placer a
	des positions bien precises les differents champs, de mettre
	des sous-titres par type d'anomalie et un saut de page avant
	chaque nouvelle unite de souscription.

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define Kn_NbMaxLignes 30
#define Kn_SSD_CF 100
#define Kn_ACMTRS_NT 150
#define Kn_Ano 15

#define MAXROW_SUBSID	  100
#define MAXROW_ACMTRS	  500
#define MAXROW_BANTECL	10000
#define MAXROW_GRP		 1000


/*-------------------------------------------*/
/* Titres des colonnes dans les deux langues */
/*-------------------------------------------*/
char Ksz_LibTitre1[2][25]={"Warning/anomaly","Avertissement/anomalie"};
char Ksz_LibTitre2[2][200]={
	"Contract Identifier   Section    Previous  Underwriting  Accounting  Accumulation transaction\n                                 currency    year          year      (code) (label)\n",
	"Identifiant contrat   Section    Ancienne    Exercice    Annee de    Poste regroupe\n                                  devise                  compte     (code) (libelle)\n"};


/*----------------------*/
/* variables de travail */
/*----------------------*/

char	Ksz_LAG_CF[2];

T_UTCTLIB Kbd_utctlib;

FILE* Kp_AnoFil;			/* Fichier en sortie */
FILE* Kp_SubsidFilout;
FILE* Kp_AcmtrshFilout;
FILE* Kp_BanteclFilout;
FILE* Kp_GrpFilout;
FILE* Kp_SubsidFil;
FILE* Kp_AcmtrshFil;
FILE* Kp_BanteclFil;
FILE* Kp_GrpFil;




int	Kn_page=1,	/* Numero de page */
	Kn_ligne=1,	/* Numero de ligne */
	Kpn_indice[Kn_SSD_CF],	/* Tableau dont l'indice est la filiale et */
			/* fournissant l'indice pour les libelles filiales */
	Kn_Annee,
	Kn_Mois;	/* Annee et mois de la periode */
unsigned char Kb_NewSsd=1; /* Indique si la filiale a change (=1) ou pas (=0) */
char	Ksz_date[2][11],/* Date du jour, format determine par la langue */
	Ksz_inv[2][11],	/* Libelle d'inventaire */
	Ksz_arr[2][11],	/* Date d'arrete */
	Kpsz_Ano[Kn_Ano][35],/* Libelles d'anomalie pour une filiale */
	Ksz_uwgrp[20];	/* Libelle de l'unite de souscription */

T_SUBSID	Ktbd_LibSsd	 [MAXROW_SUBSID];	/* Libelles filiale (indice issu de Kpn_indice) */
T_ACMTRS 	Ktbd_LibPoste[MAXROW_ACMTRS];	/* Libelles des postes d'une filiale */
T_BANTECL 	Ktbd_bantecl [MAXROW_BANTECL];
T_GRP 		Ktbd_grp	 [MAXROW_GRP]   ;

int Kn_NbSUBSID;
int Kn_NbACMTRS;
int Kn_NbBANTECL;
int Kn_NbGRP;



/* Structure de lecture des anomalies */
T_RUPTURE_VAR Kbd_RuptAno;

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitAno(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneAno(char **ptb_InRec_Cur);
int n_ActionFirstRuptPage (char **ptb_InRec_Cur);
int n_ActionLastRuptPage (char **ptb_InRec_Cur);
int n_ActionFirstRuptTitre (char **ptb_InRec_Cur);
int n_ActionLastRuptTitre (char **ptb_InRec_Cur);
int n_IsR1Page(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR1Titre(char **ptb_InRec,char **ptb_InRec_Cur);

static CS_RETCODE  n_retcFetchRowSSD( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowACMTRS( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowUWGRP( T_UTCTLIB *pbd_utctlib );
static CS_RETCODE  n_retcFetchRowANO( T_UTCTLIB *pbd_utctlib );

int n_RechPoste (char **sz_ACMTRS_LS,char *sz_SSD_CF, char *sz_ACMTRS_NT);
int n_RechGRP (char **psz_GRP_LS, char *sz_GRP_CF, char *sz_SSD_CF);
int n_RechBANTECL (char **psz_COLVAL_LM, char *sz_LAG_CF, char *sz_COLVAL_CT);
int n_RechSSD (T_SUBSID **pdb_Subsid,char *sz_SSD_CF);

void ReformatDate(char c_LAG_CF,char sz_DateInput[9], char sz_DateOutput[11]);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
	char sz_date[9];

        /* alimentation du nom en clair du programme */
        Gbd_Tech.psz_PgmLabel = "Edition du compte-rendu";

	/* Initialisation des signaux */
	InitSig ();

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Recuperation du libelle d'inventaire et de la date du jour */
	strcpy(sz_date,psz_GetCharArgv(1));
	ReformatDate('E',sz_date,Ksz_inv[0]);
	ReformatDate('F',sz_date,Ksz_inv[1]);

	strcpy(sz_date,psz_GetCharArgv(2));
	ReformatDate('E',sz_date,Ksz_date[0]);
	ReformatDate('F',sz_date,Ksz_date[1]);

	Kn_Annee=n_GetIntArgv(3);

	Kn_Mois=n_GetIntArgv(4);

	strcpy(sz_date,psz_GetCharArgv(5));
	ReformatDate('E',sz_date,Ksz_arr[0]);
	ReformatDate('F',sz_date,Ksz_arr[1]);


	n_InitAno(&Kbd_RuptAno);


	/* ouverture du fichier en sortie */
	if (n_OpenFileAppl("ESTR203A_O1","wt",&Kp_AnoFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_I2","rt",&Kp_SubsidFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_I3","rt",&Kp_AcmtrshFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_I4","rt",&Kp_BanteclFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_I5","rt",&Kp_GrpFil) == ERR )
		ExitPgm ( ERR_XX , "" );


	/* Chargement des fichiers binaires */
	n_ChargeTables() ;


	/*n_AfficheTables();*/

	/* Traitement principal */
	        if ( n_ProcessingRuptureVar (&Kbd_RuptAno) == ERR )
                ExitPgm ( ERR_XX , "" );
	

	if ( n_CloseFileAppl ("ESTR203A_I1",&(Kbd_RuptAno.pf_InputFil))== ERR)
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_I2",&Kp_SubsidFil)== ERR)
		ExitPgm ( ERR_XX , "" );


	if ( n_CloseFileAppl ("ESTR203A_I3",&Kp_AcmtrshFil)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_I4",&Kp_BanteclFil)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_I5",&Kp_GrpFil)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_O1",&Kp_AnoFil)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;
}



/*=============================================================================
 objet: Fonction de gestion du fichier d'anomalies en entree
=============================================================================*/
int n_InitAno(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitAno");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	/* Ouverture du fichier maitre */
	if (n_OpenFileAppl ("ESTR203A_I1","rt",&(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	/* Gestion de rupture */
	pbd_Rupt->n_NbRupture = 2;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Page;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPage;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPage;
	pbd_Rupt->n_ConditionRupture[1] = n_IsR1Titre;
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptTitre;
	pbd_Rupt->n_ActionLast[1] = n_ActionLastRuptTitre;

	/* Fonction executee pour chaque ligne : */
	pbd_Rupt->n_ActionLigne     = n_ActionLigneAno;

	/* Separateur utilise dans le fichier en entree */
	pbd_Rupt->c_Separ               = SEPARATEUR ;

	RETURN_VAL (0);
}

int n_ActionLigneAno(char **ptb_InRec_Cur)
{
	char *psz_LibPoste="Poste inconnu";
	int n_ACMTRS_NT;

	DEBUT_FCT("n_ActionLigneAno");

	/* Recherche du libelle du poste */
	n_RechPoste(&psz_LibPoste,ptb_InRec_Cur[ANO_SSD_CF],ptb_InRec_Cur[ANO_ACMTRS_NT]);

	/* Affichage de la ligne courante */
	fprintf(Kp_AnoFil,"     %-20.20s%-10.10s%-12.12s%-12.12s%-11.11s%-7.7s%-20.20s\n",
		ptb_InRec_Cur[ANO_CTR_NF],
		ptb_InRec_Cur[ANO_SEC_NF],
		ptb_InRec_Cur[ANO_PCPCUR_CF],
		ptb_InRec_Cur[ANO_UWY_NF],
		ptb_InRec_Cur[ANO_ACY_NF],
		ptb_InRec_Cur[ANO_ACMTRS_NT],
		psz_LibPoste);
	Kn_ligne++;

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de rupture du niveau 1

retour :
	0   ---> Pas de rupture
	1   ---> rupture
==============================================================================*/
int n_IsR1Page(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Page");

	if (strcmp(ptb_InRec[ANO_SSD_CF],ptb_InRec_Cur[ANO_SSD_CF])!=0)
	{
		Kb_NewSsd=1;
		RETURN_VAL(1);
	}

	if (strcmp(ptb_InRec[ANO_UWGRP_CF],ptb_InRec_Cur[ANO_UWGRP_CF])!=0)
		RETURN_VAL(1);


	if (Kn_ligne>Kn_NbMaxLignes) RETURN_VAL(1);

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de rupture du niveau 2

retour :
	0   ---> Pas de rupture
	1   ---> rupture
==============================================================================*/
int n_IsR1Titre(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Titre");

	if (strcmp(ptb_InRec[ANO_ANOCOD_CF],ptb_InRec_Cur[ANO_ANOCOD_CF])!=0)
	RETURN_VAL(1);

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptPage (char **ptb_InRec_Cur)
{
	char sz_LibSsd[20]="Filiale inconnue";
	char *psz_GRP_LS="Groupe inconnu";
	T_SUBSID *pbd_LibSsd;
        int b_Francais;

	DEBUT_FCT("n_ActionFirstRuptPage");


	/* Chargement du libelle de l'unite*/
	n_RechGRP (&psz_GRP_LS, ptb_InRec_Cur[ANO_UWGRP_CF],ptb_InRec_Cur[ANO_SSD_CF]);

	if( n_RechSSD (&pbd_LibSsd,ptb_InRec_Cur[ANO_SSD_CF]) == OK )
          {
             if (*(pbd_LibSsd->sz_LAG_CF) == 'F')
               b_Francais = 1;
             else
               b_Francais = 0;

               fprintf(Kp_AnoFil,"%c %-2.2d %s\n",
                        pbd_LibSsd->sz_LAG_CF[0],
                        atoi(ptb_InRec_Cur[ANO_SSD_CF]),
                        "1");

		fprintf(Kp_AnoFil,"%-10.10s%-10.10s%-20.20s%04d%02d%c   %-20.20s%10.10s%d\n",
			Ksz_date[b_Francais],Ksz_inv[b_Francais],
			psz_GRP_LS,Kn_Annee,Kn_Mois,
			pbd_LibSsd->sz_LAG_CF[0] ,
			pbd_LibSsd->sz_LIB ,
			Ksz_arr[b_Francais],Kn_page);
          }
	else
          {
                fprintf(Kp_AnoFil,"%c %-2.2d %s\n",
                        'F',
                        atoi(ptb_InRec_Cur[ANO_SSD_CF]),
                        "1");

		fprintf(Kp_AnoFil,"%-10.10s%-10.10s%-20.20s%04d%02d%c   %-20.20s%10.10s%d\n",
			Ksz_date[1],Ksz_inv[1],
			psz_GRP_LS,Kn_Annee,Kn_Mois,
			'F',
			"Filiale inconnue" ,
			Ksz_arr[1],Kn_page);
          }

	Kn_ligne=3;

	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRuptTitre (char **ptb_InRec_Cur)
{
	int n_ano;
	char n_ssd;
	char *sz_lib="Ano inconnue";
        int b_Francais;

	T_SUBSID *pdb_Subsid ;

	DEBUT_FCT("n_ActionFirstRuptTitre");

	/* Libelles d'anomalie */
	if( n_RechSSD (&pdb_Subsid,ptb_InRec_Cur[ANO_SSD_CF]) == OK )
	 	n_RechBANTECL (&sz_lib, pdb_Subsid->sz_LAG_CF,ptb_InRec_Cur[ANO_ANOCOD_CF]);

        if (*(pdb_Subsid->sz_LAG_CF) == 'F')
          b_Francais = 1;
        else
          b_Francais = 0;

	/* Edition du sous-titre */
	fprintf(Kp_AnoFil,"\n%s %s : %-s\n\n",
		Ksz_LibTitre1[b_Francais],ptb_InRec_Cur[ANO_ANOCOD_CF],sz_lib);

	/* Titres des colonnes */
	fprintf(Kp_AnoFil,"%s\n",Ksz_LibTitre2[b_Francais]);
	fprintf(Kp_AnoFil,"--------------------------------------------------------------------------------------------------------------------------------------------------\n");

	Kn_ligne+=6;

	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 2
==============================================================================*/
int n_ActionLastRuptTitre (char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastRuptTitre");

	/* Si on est en rupture sur le sous-titre a la ligne suivante, */
	/* il faut verifier qu'il reste assez de place pour ecrire les */
	/* lignes du sous-titre plus une ligne sur cette page. Dans le */
	/* cas contraire, on modifie le numero de ligne pour forcer le */
	/* saut de page au prochain passage.			       */
	if (Kn_ligne+6>Kn_NbMaxLignes) Kn_ligne=Kn_NbMaxLignes+1;

	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Fonction lancee a chaque rupture derniere de niveau 1
==============================================================================*/
int n_ActionLastRuptPage (char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastRuptPage");

	if (Kb_NewSsd==1)
	{
		Kb_NewSsd=0;
		Kn_page=1;
	}
        else
	        Kn_page++;

	Kn_ligne=1;
	fprintf(Kp_AnoFil,"\f");

	RETURN_VAL(0);
}

/*=============================================================================
 objet:
	Genere en sortie une date formatee en fonction du code langue:
	jj/mm/aaaa si code langue=F
	mm/jj/aaaa sinon
 parametres:
	c_LAG_CF	code langue
	sz_DateInput	date en entree, qui doit etre au format aaaammjj
	sz_DateOutput	date formatee en sortie
=============================================================================*/
void ReformatDate(char c_LAG_CF,char sz_DateInput[9], char sz_DateOutput[11])
{
	DEBUT_FCT("ReformatDate");

	if (c_LAG_CF=='F')
	{
		sz_DateOutput[0]=sz_DateInput[6];
		sz_DateOutput[1]=sz_DateInput[7];
		sz_DateOutput[3]=sz_DateInput[4];
		sz_DateOutput[4]=sz_DateInput[5];
	}
	else
	{
		sz_DateOutput[0]=sz_DateInput[4];
		sz_DateOutput[1]=sz_DateInput[5];
		sz_DateOutput[3]=sz_DateInput[6];
		sz_DateOutput[4]=sz_DateInput[7];
	}
	sz_DateOutput[2]='/';
	sz_DateOutput[5]='/';
	sz_DateOutput[6]=sz_DateInput[0];
	sz_DateOutput[7]=sz_DateInput[1];
	sz_DateOutput[8]=sz_DateInput[2];
	sz_DateOutput[9]=sz_DateInput[3];
	sz_DateOutput[10]=0;

	RETURN_VOID();

}


/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
/******************************************************************************/




/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID

retour :
   CS_SUCCEED
   CS_FAIL
==============================================================================*/
int n_Extract()
{
	char *sz_COL_LS="EST_ANO21";

	memset(Kpn_indice,-1,Kn_SSD_CF)	;

	/* Connexion a la base */
	if (n_LocalConnect (&Kbd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");



	if (n_OpenFileAppl("ESTR203A_O2","wt",&Kp_SubsidFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_O3","wt",&Kp_AcmtrshFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_O4","wt",&Kp_BanteclFilout) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTR203A_O5","wt",&Kp_GrpFilout) == ERR )
		ExitPgm ( ERR_XX , "" );


	Kbd_utctlib.n_RowFetchData = n_retcFetchRowSSD	;
	n_ProcessingProc (&Kbd_utctlib,0,"BEST..PsSUBSID_11")	;


	if (Ksz_LAG_CF[0]!='F') Ksz_LAG_CF[0]='E' ;
	Kbd_utctlib.n_RowFetchData = n_retcFetchRowANO;
	n_ProcessingProc (&Kbd_utctlib,1,"BEST..PsBANTECL_02",
			"@p_col_ls",CS_INPUTVALUE,CS_CHAR_TYPE,sz_COL_LS,9,0);

	Kbd_utctlib.n_RowFetchData = n_retcFetchRowACMTRS;
	n_ProcessingProc (&Kbd_utctlib,0,"BEST..PsACMTRSH_02");

	/* Ramene une seule ligne, lue dans Ksz_ungrp */
	Kbd_utctlib.n_RowFetchData = n_retcFetchRowUWGRP;
	n_ProcessingProc (&Kbd_utctlib,0,"BEST..PsGRP_03");


	if ( n_CloseFileAppl ("ESTR203A_02",&Kp_SubsidFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_03",&Kp_AcmtrshFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_04",&Kp_BanteclFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTR203A_05",&Kp_GrpFilout)== ERR)
		ExitPgm ( ERR_XX , "" );

	/* Deconnexion */
	if (n_LocalDisconnect (&Kbd_utctlib) != CS_SUCCEED)
		ExitPgm (ERR_XX, "");


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


/**********************************************************************************/
/**********************************************************************************/
/**********************************************************************************/
/**********************************************************************************/
/**********************************************************************************/
/**********************************************************************************/

/*==============================================================================
objet :
   fonction d'extraction des donnees de la table TSUBSID

retour :
   CS_SUCCEED
   CS_FAIL
==============================================================================*/
int n_ChargeTables()
{


	DEBUT_FCT ("n_ChargeTables");

	Kn_NbSUBSID=fread(Ktbd_LibSsd  ,sizeof(T_SUBSID)	,MAXROW_SUBSID	,Kp_SubsidFil);

	if( Kn_NbSUBSID <= 0 || Kn_NbSUBSID == MAXROW_SUBSID )
	{
		n_WriteAno("Tableau de chargement de TSUBSID est mal dimensionné ou erreur de lecture");
		RETURN_VAL(ERR);
	}

	Kn_NbACMTRS=fread(Ktbd_LibPoste,sizeof(T_ACMTRS)	,MAXROW_ACMTRS	,Kp_AcmtrshFil);
	if( Kn_NbACMTRS <= 0 || Kn_NbACMTRS == MAXROW_ACMTRS )
	{
		n_WriteAno("Tableau de chargement de TACMTRSH est mal dimensionné ou erreur de lecture");
		RETURN_VAL(ERR);
	}

	Kn_NbBANTECL=fread(Ktbd_bantecl ,sizeof(T_BANTECL)	,MAXROW_BANTECL	,Kp_BanteclFil);
	if( Kn_NbBANTECL <= 0 || Kn_NbBANTECL == MAXROW_BANTECL )
	{
		n_WriteAno("Tableau de chargement de TBANTECL est mal dimensionné ou erreur de lecture");
		RETURN_VAL(ERR);
	}

	Kn_NbGRP=	fread(Ktbd_grp	   ,sizeof(T_GRP)		,MAXROW_GRP		,Kp_GrpFil	);
	if( Kn_NbGRP <= 0 || Kn_NbGRP == MAXROW_GRP )
	{
		n_WriteAno("Tableau de chargement de TGRP est mal dimensionné ou erreur de lecture");
		RETURN_VAL(ERR);
	}

	RETURN_VAL(OK);

}


/*==============================================================================
objet :
   Affichage du contenu des fichiers binaire

retour :
   CS_SUCCEED
   CS_FAIL
==============================================================================*/
int n_AfficheTables()
{
	int  i ;
	DEBUT_FCT ("n_AfficheTables");

	printf("\n TSUBSID");

	for(i=0;i<Kn_NbSUBSID;i++)
		printf("%3d\t%-17s\t%3s\n",(int)Ktbd_LibSsd[i].c_SSD_CF, 
									 Ktbd_LibSsd[i].sz_LIB,
									 Ktbd_LibSsd[i].sz_LAG_CF);
								


	for(i=0;i<Kn_NbACMTRS;i++)
		printf("%3d\t%6d\t%-20s\n",(int)Ktbd_LibPoste[i].c_SSD_CF, 
								   (int)Ktbd_LibPoste[i].s_ACMTRS_NT,
								     	Ktbd_LibPoste[i].sz_ACMTRS_LS);
								

	for(i=0;i<Kn_NbBANTECL;i++)
		printf("%3s\t%6d\t%-33s\n",    Ktbd_bantecl[i].sz_LAG_CF, 
								     Ktbd_bantecl[i].n_COLVAL_CT,
									 Ktbd_bantecl[i].sz_COLVAL_LM);
								

	for(i=0;i<Kn_NbGRP;i++)
		printf("%5d\t%3d\t%-17s\n",(int)Ktbd_grp[i].s_GRP_CF, 
								   (int)Ktbd_grp[i].c_SSD_CF,
								        Ktbd_grp[i].sz_GRP_LS);
							
	RETURN_VAL(OK);
}

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/

/*=============================================================================
 objet: Ramener le libelle du poste passe en parametre
=============================================================================*/
int n_RechPoste (char **psz_ACMTRS_LS,char *sz_SSD_CF, char *sz_ACMTRS_NT)
{
	int i=0;

	DEBUT_FCT("n_RechPoste");


	/* Les postes sont classes par ordre croissant, on peut   */
	/* donc cesser la recherche des que le numero est depasse */


       while (   (i<Kn_NbACMTRS) 
              && (   (atoi(sz_SSD_CF) != (int)Ktbd_LibPoste[i].c_SSD_CF) 
                  || (Ktbd_LibPoste[i].s_ACMTRS_NT 
                                      != (short)atoi(sz_ACMTRS_NT))
                 )
             )
         {
           i++;
         }

	if( Kn_NbACMTRS <= i )
	{
		RETURN_VAL(ERR)	;
	}
	else
       {
		*psz_ACMTRS_LS = Ktbd_LibPoste[i].sz_ACMTRS_LS ;
       }

	RETURN_VAL(OK);
}



/*=============================================================================
 objet: Ramener le libelle du poste passe en parametre
=============================================================================*/
int n_RechSSD (T_SUBSID **pdb_Subsid,char *sz_SSD_CF)
{
	int i=0;

	DEBUT_FCT("n_RechSSD");


	/* Les postes sont classes par ordre croissant, on peut   */
	/* donc cesser la recherche des que le numero est depasse */


        while (  (i<Kn_NbSUBSID)
              && (atoi(sz_SSD_CF) != (int)Ktbd_LibSsd[i].c_SSD_CF)  )
         {
           i++;
         }

	if( Kn_NbSUBSID <= i ) 
	{
		RETURN_VAL(ERR)	;
	}
	else
          *pdb_Subsid = &Ktbd_LibSsd[i];


	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Ramener le libelle du poste passe en parametre
=============================================================================*/
int n_RechGRP (char **psz_GRP_LS, char *sz_GRP_CF, char *sz_SSD_CF)
{
	int i=0;

	DEBUT_FCT("n_RechGRP");


	/* Les postes sont classes par ordre croissant, on peut   */
	/* donc cesser la recherche des que le numero est depasse */


        while (    (i<Kn_NbGRP)
                && (   (atoi(sz_SSD_CF) != (int)Ktbd_grp[i].c_SSD_CF)
                    || (atoi(sz_GRP_CF) != (int)Ktbd_grp[i].s_GRP_CF)
                   )
              )
          i++;


	if( Kn_NbGRP <= i ) 
	{
		RETURN_VAL(ERR)	;
	}
	else
		*psz_GRP_LS = Ktbd_grp[i].sz_GRP_LS;


	RETURN_VAL(OK);
}

/*=============================================================================
 objet: Ramener le libelle du poste passe en parametre
=============================================================================*/
int n_RechBANTECL (char **psz_COLVAL_LM, char *sz_LAG_CF, char *sz_COLVAL_CT)
{
	int i;

	DEBUT_FCT("n_RechBANTECL");


	/* Les postes sont classes par ordre croissant, on peut   */
	/* donc cesser la recherche des que le numero est depasse */


       while (    (i<Kn_NbGRP)
               && (    (strcmp(sz_LAG_CF,Ktbd_bantecl[i].sz_LAG_CF) != 0)
                    || (atoi(sz_COLVAL_CT) != Ktbd_bantecl[i].n_COLVAL_CT)
                  )
             )
        i++;

	if( Kn_NbBANTECL <= i ) 
	{
		RETURN_VAL(ERR)	;
	}
	else
		*psz_COLVAL_LM = Ktbd_bantecl[i].sz_COLVAL_LM;


	RETURN_VAL(OK);
}





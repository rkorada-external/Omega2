/*==============================================================================
nom de l'application          : Generation Retrocession
nom du source                 : ESTC2135.c
revision                      : $Revision: 1.13 $
date de creation              : 29/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Calcul des previsions retrocession

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
     12/02/03       J. Ribot       sz_lib_oricod[11] = "RETRO AUTO"
     21/11/03       J. Ribot       ajout acces tlifdri pour test sur AUTUPD_B
                                   + ajout fichier anos
     07/07/04       J. Ribot       cre_d + "23:59:20" pour "RETRO AUTO" a partir RETRO INTERNE
     31/03/05       J. Ribot       recherche dans "n_RechPilot" avec PRE_ACY_NF au lieu PLA_RTY_NF
     14/09/06       J. Ribot       SPOT 11064 le poste 1150 donne 2145 en retro
    ---------------
     14/05/2008          [006]     ESTVIE15401 Agrandissement d'un tableau en mémoire
                                   agrandissement de NB_MAX_PILOT 20000 => 40000
     20/05/2008     GIBU [007]     Spot 15439 : On perd l'année bilan entre le moment où on récupère
                                   le paramètre et le moment où il est utilisé pour créer le fichier
                                   (on récupère NULL dans BALSHEY_NF). Changement de date.
     11/06/2008     GIBU [008]     Spot 11064 : Dans le cas d'un 1150, le poste doit se verser dans le 2145
                                   la modif du 14/09/2006 ne fonctionne pas
_________________
MODIFICATION    [009]
Auteur:         D.GATIBELZA
Date:           28/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
_________________
MODIFICATION    [010]
Auteur:         JF-VDV
Date:           02/09/2010
Version:        10.1
Description:   [18754] Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1543 en dupliquant comme le 1093 et le 2543 comme le 2093
_________________
MODIFICATION    [011]
Auteur:         D.GATIBELZA
Date:           27/09/2010
Version:        10.1
Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC

[012]  05/11/2010  Roger CASSIS     :spot:18754 - Suppression des postes 1093,1543,1094.
                                                  Ajout conditions 1163, 1164 (VOBA) et 1193,1194 (CNA Conso)
_________________
MODIFICATION    [013]
Auteur:         D.GATIBELZA
Date:           03/11/2010
Version:        10.1
Description:    ESTVIE20655 Agrandissement d'un tableau en mémoire:
                NB_MAX_PILOT 40000 => 100000
________________
25/06/13     Prajakta    Phase1B migration code changes for warning removal
MODIFICATION    [014] Modification initialisation SubtrsAsso
MODIFICATION    [015] - SBE - 31/10/2014 Implémentation SUBTRSESBPROP
[016] 24/11/2014 ABJ  spot:25773  Ajout de la generation de la retro sur 1393 et 1363
[017] 16/06/2015 S.Behague spot:28937:Spira 39708 Poste Manquants RETRO AUTO
[018] 16/12/2015 RBE spot:29971: correction n_IsR1Prev
[018] 12/01/2015 RBE spot:30025: Correction Pool retro selon type comptable Retro
[019] 10/11/2015 R.BEN EZZINE  :spot:29579 Impact Retro EST
[020] 19/09/2016 MMA Spot:31218 Spira:55249 : Correction d'un débordement de mémoire + nettoyage variables inutilisés
[022] 10/04/2018 HH Huynh :spira:62073 Lors synchronisation entre fichier placement et estimation, filtrage  pour l’exercice ,
				l’année de compte est comprise entre limites BLCSHTSTR_D et BLCSHTEND_D,sinon si non, la ligne estimation est
				recopiée dans un nouveau fichier d’anomalie qui sera ensuite zippé
[024] 12/03/2019 sbehague    :spira:70044 REQ.L.02.05: Evolution quarterly
[025] 08/10/2019 BEL         :spira:69067 correction du probleme des postes avec des mauvais ACMTRS.
[026] 09/01/2020 BEL         :spira:84032 correction de la gestion du type comptable.
[027] 07/04/2020 BEL         :spira:60627 Predre en compte l'Assumed family dans la transformation de poste.
[028] 29/06/2020 BEL         :spira:88060 Assumed family : Utilisation des pposte a 8 digits dans la transformation de poste.
[030] 09/11/2021 sbehague    :spira:100220 ESID2040 job in error
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

#define PLA1_ACCADMTYP_CT 33

FILE            *Kp_PlcFile;                    /* pointeur sur les placements */
FILE            *Kp_PrevInFile;                 /* pointeur sur les previsions en entree */
FILE            *Kp_PrevOutFile;                /* pointeur sur les previsions en sortie */
FILE            *Kp_CoursFile;                  /* pointeur sur les derniers cours connus */
FILE            *Kp_PilotFile;                  /* pointeur sur les pilotages */
FILE            *Kp_AnoFile;                    /* pointeur sur le fichier des anomalies */
FILE            *Kp_SubTRSAssoFil;
FILE            *Kp_EsBpropIFil;				/* Pointeur sur le fichier FSUBTRSESBPROP */
FILE            *Kp_transtcode;
FILE            *Kp_TrslnkFil;
FILE            *Kp_SubTRSFile;					/* [025] : Pointeur sur le fichier FSUBTRS */

T_SUBTRS                SubTrsLigne;			/* [025 : structure de ligne TSUBTRS] */
T_RUPTURE_VAR           bd_RuptPlc;             /* gestion rupture sur placement */
T_RUPTURE_VAR           bd_RuptTACCPAR;
T_RUPTURE_SYNC_VAR      bd_RuptPrev;            /* gestion rupture sur prev */
T_LIFDRI_ALL        Kbd_PILOT[NB_MAX_PILOT];    /* Fichier pilotage charge en memoire */
int             Kn_NbLigPilot;                  /* Nombre de lignes dans le fichier pilotage */
T_SUBTRSASSO SubTrsAssoLigne;
T_SUBTRSESBPROP SubTrsEsBprop;					// Structure EsBprop

static T_TRANSTCODE bd_TRANSTCODE[MAX_TDETTRS]; /* [028] Structure BRET..TRTRANSTCODE */
int Kn_NbTranstcode ;							/* [028] bd_TRANSTCODE length */

int n_InitPlc(T_RUPTURE_VAR *pbd_Rupt);
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePlc(char **pbd_InRec_Cur);
int n_IsR1Plc(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPlc(char **ptb_InRec_Cur);
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR );
int n_RechercheTACCPAR( int ACMTRS );
void init_SubTrsAssoLigne();
void init_SubTrsEsBprop();

int n_InitPrev(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSynchro (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePrev  (char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFilsSansPere (char **ptb_InRec_Cur);
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec, char **ptb_InRec_Cur);
void CompleterPoste (char *lob, char *DETTRN, int norme, char *ACMTRS, char *poste); /* [025] */

T_TRSLNK  Kbd_TRSLNK[NB_MAX_TRSLNK];

int n_TraitePlaPrev(
        char **ptb_Pla ,         /* adresse de la ligne du maitre */
        char **Pre) ;         /* adresse de la ligne de l'esclave */

char      s_DateBilan[5];

int n_ChargerPilot();
int n_RechPilot (char **, char **, int );

int             Kn_OK1=0;
int             Kn_OK2=0;

int     Ind_FilsSansPere=0;

int     Kn_annee ;      	/* Annee Bilan */
char    Ksz_Balshey[5] ;   	/* Annee Bilan */
char 	Ksz_Balshtmth[3] ;	/* Mois Bilan */
char	Ksz_Cre[20] ;	  /* date de creation des previsions en sortie */
char	sz_Batch[2] = "1"; // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
char	Ksz_Cre2[20] ;	/* date de creation des previsions en sortie pour retro interne */

char	Kn_PLCSTS_CT[3];

char	Ksz_Ctr[10] ;	/* contrat */
char	Ksz_End[3] ;	/* endorsement */
char	Ksz_Sec[3] ;	/* section */
int		Kb_CONRETCTR_B;	/* Indicateur generation retro */
char	*Ktb_PlacSave[PLA1_NBCOL+1] ;
/* char  *Ktb_PlacSavd[33] ;     zone sauvegarde pour placement avant syncro avec = sur ctr end sec */

typedef struct {
    int  Dettrs[1000];
    int  Acmtrs[1000];
    int  nb_acmtrs;
}T_POSTE_ACCPAR_DET;

T_POSTE_ACCPAR_DET ACM_DETT;

typedef struct {
    char    PRS_CF[4];
    char    CTR_NF[10];
    char    SEC_NF[3];
    char    UWY_NF[5];
    char    ACMTRS[6];
    char    DETTRNCOD[6];
    char    ESTMNT_M[60];
    char    GAAP_NT[2];
} T_ACMTRS_BASE;

T_ACMTRS_BASE Kbd_Acmtrs_base[5000];

int Kn_Acmtrs_base = 0;

char    Ksz_Clodat[9] ;
int cptPlac = 0;
int cptPrev = 0;
int cptConditionSynchro = 0 ;
int cptTraitePlaPrev = 0 ;
int cptFilsSansPere = 0;


/*******************************************************************************
** objet  :
**   point d'entree du programme
** retour :
**   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
**   Sinon, par l'appel systeme exit()
*******************************************************************************/
int main(int argc ,char *argv[])
{
	char	sz_Cre[9];
	memset(&ACM_DETT,sizeof(T_POSTE_ACCPAR_DET),0);

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Recuperation de l'annee bilan */
	strcpy( Ksz_Balshey, psz_GetCharArgv(1) ) ;
	Kn_annee = atoi( Ksz_Balshey );
	strcpy(s_DateBilan, Ksz_Balshey);

	/* Recuperation de la date de lancement du batch */
	strcpy (sz_Cre, psz_GetCharArgv(2));

	/* Recuperation du mois bilan */
	strcpy( Ksz_Balshtmth, psz_GetCharArgv(3) ) ;

	strcpy( Ksz_Clodat, psz_GetCharArgv(4) ) ;

	/* Formatage de la date de creation des previsions en sortie */
	/*	sprintf( Ksz_Cre, "%s %s", sz_Cre, "23:59:59" ) ; */
	sprintf( Ksz_Cre, "%s %s", sz_Cre, "23:59:15" ) ;

	/* Formatage de la date de creation des previsions en sortie si retro interne*/
	sprintf( Ksz_Cre2, "%s %s", sz_Cre, "23:59:20" ) ;

	/* Ouverture des fichiers */
	if ( n_OpenFileAppl ("ESTC2135_O1","wt",&Kp_PrevOutFile) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_O2","wt",&Kp_AnoFile) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_I3","rb",&Kp_CoursFile) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_I6","rb",&Kp_SubTRSAssoFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_I7","rb",&Kp_EsBpropIFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* [025] : Ajout de l'entree SUBTRS */
	if ( n_OpenFileAppl ("ESTC2135_I8","rb",&Kp_SubTRSFile) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_I9","rb",&Kp_transtcode) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2135_I10","rb",&Kp_TrslnkFil) == ERR )
		ExitPgm ( ERR_XX , "" );


	/* Chargement en memoire du fichier pilotage */
	n_ChargerTsubTRS(Kp_SubTRSFile); /* [025]*/ 
	n_ChargerTRSLNK500(Kp_TrslnkFil);
	n_ChargerPilot();
	init_SubTrsAssoLigne();
	init_SubTrsEsBprop();
	Kn_NbTranstcode = n_LoadTRANSTCODE(Kp_transtcode, bd_TRANSTCODE); // [028]


	if ( n_ChargerTsubTRSAsso(Kp_SubTRSAssoFil) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_ChargerSUBTRSESBPROP(Kp_EsBpropIFil) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_InitTACCPAR(&bd_RuptTACCPAR) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPlc */
	if ( n_InitPlc(&bd_RuptPlc) )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible bd_RuptPrev */
	if ( n_InitPrev(&bd_RuptPrev) )
		ExitPgm ( ERR_XX , "" );

	if ( n_ProcessingRuptureVar (&bd_RuptTACCPAR) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar (&bd_RuptPlc) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Fermeture fichier */
	if (n_CloseFileAppl ("ESTC2135_I1",&(bd_RuptPlc.pf_InputFil)) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I2",&(bd_RuptPrev.pf_InputFil)) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I5",&(bd_RuptTACCPAR.pf_InputFil))== ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I3",&Kp_CoursFile))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I4",&Kp_PilotFile) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I6",&Kp_SubTRSAssoFil) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I7",&Kp_EsBpropIFil) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I8",&Kp_SubTRSFile) == ERR) // [025]
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I9",&Kp_transtcode) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_I10",&Kp_TrslnkFil) == ERR)
		ExitPgm ( ERR_XX , "" );


	if (n_CloseFileAppl ("ESTC2135_O1",&Kp_PrevOutFile) == ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2135_O2",&Kp_AnoFile) == ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(0);
}


/*******************************************************************************
** objet  :
**   fonction d'initialisation de la variable de gestion de rupture du
**   fichier maitre.
** retour :
**          0
*******************************************************************************/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPlc");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	Ktb_PlacSave[0]=0;

	if ( n_OpenFileAppl ("ESTC2135_I1","rt",&(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 1 ;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPlc;

	pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;
	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL (0);
}


/*******************************************************************************
** objet  :
**      Initialisation de la synchronisation du maitre avec l'esclave
** retour :
**      OK
*******************************************************************************/
int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPrev");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	/* n_OpenFileAppl ("ESTC2135_I2","rt",&(pbd_Rupt->pf_InputFil)); */
	if ( n_OpenFileAppl ("ESTC2135_I2","rt",&(pbd_Rupt->pf_InputFil)))
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 1;

	pbd_Rupt->ConditionEndSync      = n_ConditionSynchro ;
	pbd_Rupt->n_ActionLigne         = n_ActionLignePrev ;
	pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere;

	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
	pbd_Rupt->n_ActionFirst[0]       = n_ActionFirstRuptPrev;

	pbd_Rupt->c_Separ               = '~' ;

	RETURN_VAL (OK);
}


/*******************************************************************************
** objet  :
**      fonction de test de synchro
** retour :
**      0       ---> pbd_InRecOwner = pbd_InRecChild
**                      ( egalite de rubriques a synchroniser)
**      > 0     ---> pbd_InRecOwne> > pbd_InRecChild
**      < 0     ---> pbd_InRecOwne> < pbd_InRecChild
*******************************************************************************/
int n_ConditionSynchro (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
	int ret;
	DEBUT_FCT("n_ConditionSynchro");

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


/*******************************************************************************
** objet  :
**      fonction de test de rupture du niveau 1
** retour :
**      0   ---> Pas de rupture
**      1   ---> rupture
*******************************************************************************/
int n_IsR1Plc(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Plc");

	if (strcmp(ptb_InRec[PLA1_CTR_NF],ptb_InRec_Cur[PLA1_CTR_NF])!=0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PLA1_END_NT],ptb_InRec_Cur[PLA1_END_NT])!=0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PLA1_SEC_NF],ptb_InRec_Cur[PLA1_SEC_NF])!=0)
		RETURN_VAL(1);

	RETURN_VAL (0);
}


/*******************************************************************************
** objet  :
**      fonction lancee pour chaque ligne du maitre
** retour :
**      0 ----> traitement correctement effectue
**      ERR --> probleme rencontre
*******************************************************************************/
int n_ActionFirstRuptPlc(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPlc");

	/* lancement synchro */
	strcpy(Ksz_Ctr , ptb_InRec_Cur[PLA1_CTR_NF]);
	strcpy(Ksz_End , ptb_InRec_Cur[PLA1_END_NT]);
	strcpy(Ksz_Sec , ptb_InRec_Cur[PLA1_SEC_NF]);
	Kb_CONRETCTR_B = atof( ptb_InRec_Cur[PLA1_CONRETCTR_B]);

	RETURN_VAL (0);
}


/*******************************************************************************
** objet  :
**      fonction lancee pour chaque ligne du maitre
** retour :
**      0 ----> traitement correctement effectue
**      ERR --> probleme rencontre
*******************************************************************************/
int n_ActionLignePlc(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLignePlc");

	/* lancement synchro */
	n_ProcessingRuptureSyncVar (&bd_RuptPrev, ptb_InRec_Cur);

	RETURN_VAL (0);
}


/*******************************************************************************
** objet  :     fonction de test de rupture du niveau 1
** retour :    0   ---> Pas de rupture
**          1   ---> rupture
*******************************************************************************/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Prev");

	if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_END_NT],ptb_InRec_Cur[PRE_END_NT])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_UW_NT] ,ptb_InRec_Cur[PRE_UW_NT]) !=0)           RETURN_VAL(1);

	RETURN_VAL (0);
}


/*******************************************************************************
** Purpose : function performing treatments link to each rupture of Estimations file
** Return value : OK ---> treatment properly done
**              ERR --> an error occurs
*******************************************************************************/
int n_ActionFirstRuptPrev(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPrev");

	//Remise à zero du flag FilsSansPere - Le flag du contrat précédent était parfois encore positionné
	Ind_FilsSansPere=0;
	memset(Kbd_Acmtrs_base , 0 , sizeof(Kbd_Acmtrs_base));
	Kn_Acmtrs_base = 0;

	RETURN_VAL (0);
}


/*******************************************************************************
** objet  :
**      fonction lancee pour chaque prevision ne participant
**      pas a aucun placement
** retour :
**      OK ---> traitement correctement effectue
**      ERR--> probleme rencontre
*******************************************************************************/
int n_ActionFilsSansPere (char **ptb_InRec_Cur)
{
	int ret = 0 ;
	DEBUT_FCT("n_ActionFilsSansPere");

	/* Reconduire la prevision si pas de generation automatique */
	/*     if ( atoi(ptb_InRec_Cur[PRE_RETCOD_CT]) != 1 ) */
	/************************************************************/
	/* MODIF 8 01 1998 : prevision reconduite sans condition    */
	/* 24/04/03      n_WriteCols(Kp_PrevOutFile,ptb_InRec_Cur,'~',0);    */

	/* test sur zones de sauvegarde avant syncro placement */
	if (Ktb_PlacSave[0]!=0)
		if ((strcmp(ptb_InRec_Cur[PRE_CTR_NF],Ktb_PlacSave[PLA1_CTR_NF])==0) &&
		    (strcmp(ptb_InRec_Cur[PRE_END_NT],Ktb_PlacSave[PLA1_END_NT])==0) &&
		    (strcmp(ptb_InRec_Cur[PRE_SEC_NF],Ktb_PlacSave[PLA1_SEC_NF])==0))
		{
			/*Ktb_PlacSavd[0]=0; */
			Ind_FilsSansPere = 1;

			if ( atoi(ptb_InRec_Cur[PRE_ACY_NF]) >= atoi(Ksz_Balshey) )
			{
				ret = n_TraitePlaPrev(Ktb_PlacSave , ptb_InRec_Cur); //SBE - On écrit la ligne si on est en ACY > année bilan - 07 10 2014
			}
		}
	
    RETURN_VAL (ret);
}


/*******************************************************************************
** objet  :
**      fonction lancee pour chaque ligne synchronisee
** retour :
**      OK ---> traitement correctement effectue
**      ERR --> probleme rencontre
*******************************************************************************/
int n_ActionLignePrev(
        char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
        char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	int ret = 0 ;
	static char	sz_PLA_SSD_CF     [4],
	            sz_PLA_ESB_CF     [4],
	            sz_PLA_RETCTR_NF  [10],
	            sz_PLA_RETEND_NT  [4],
	            sz_PLA_RETSEC_NF  [4],
	            sz_PLA_RTY_NF     [5],
	            sz_PLA_RETUW_NT   [4],
	            sz_PLA_PLC_NT     [11],
	            sz_PLA_PLCSTS_CT  [3],
	            sz_PLA_OVRCOM_R   [16],
	            sz_PLA_RTO_NF     [6],
	            sz_PLA_INT_NF     [6],
	            sz_PLA_PAY_NF     [6],
	            sz_PLA_KEY_CF     [6],
	            sz_PLA_ORICUR_B   [2],
	            sz_PLA_SSDRTO_B   [2],
	            sz_PLA_RETSIGSHA_R[16],
	            sz_PLA_LOB_CF     [4],
	            sz_PLA_RAICOM_B   [2],
	            sz_PLA_RETOVRCOM_B[2],
	            sz_PLA_CTR_NF     [10],
	            sz_PLA_END_NT     [4],
	            sz_PLA_SEC_NF     [4],
	            sz_PLA_UWY_NF     [5],
	            sz_PLA_UW_NT      [4],
	            sz_PLA_CUR_CF     [4],
	            sz_PLA_CESSH_R    [16],
	            sz_PLA_CLMFUN_R   [16],
	            sz_PLA_URRFUN_R   [16],
	            sz_PLA_CLMFUNINT_R[16],
	            sz_PLA_URRFUNINT_R[16],
	            sz_PLA_CONRETCTR_B[2],
	            sz_PLA_OVRBASIS_NT[4],
	            sz_PLA_ACCFAM_CT  [7],
	            sz_PLA_ACCTYP_CT  [2],
	            sz_PLA_CTRNAT_CT  [2],
	            sz_PLA_DEPORI_B   [2],
	            sz_PLA_BLCSHTSTR_D[9],  // [022]
	            sz_PLA_BLCSHTEND_D[9];  // [022]
	         /* sz_PLA_RTOCTY_CF  [3]; */


	/* 24/04/03        n_WriteCols(Kp_PrevOutFile,ptb_InRecChild,'~',0);  */
	// Sauvegarder l'acmtrs, dettrncod et le montant du prs_cf = 50
	if (strcmp(ptb_InRecChild[PRE_PRS_CF], "50" ) == 0)
	{
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].CTR_NF,    "%s", ptb_InRecChild[PRE_CTR_NF]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].SEC_NF,    "%s", ptb_InRecChild[PRE_SEC_NF]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].UWY_NF,    "%s", ptb_InRecChild[PRE_UWY_NF]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].ACMTRS,    "%s", ptb_InRecChild[PRE_ACMTRS_NT]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].DETTRNCOD, "%s", ptb_InRecChild[PRE_DETTRNCOD_CF]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].ESTMNT_M,  "%s", ptb_InRecChild[PRE_ESTMNT_M]);
		sprintf(Kbd_Acmtrs_base[Kn_Acmtrs_base].GAAP_NT,   "%s", ptb_InRecChild[PRE_GAAP_NF]);

		Kn_Acmtrs_base++;
		if (Kn_Acmtrs_base > 5000)
		{
			printf("Kbd_Acmtrs_base trop petit !\n");
			ExitPgm(ERR_XX, "");
		}

		return ret;
	}

	ret = n_TraitePlaPrev( ptb_InRecOwner ,    ptb_InRecChild) ;

	strcpy(sz_PLA_SSD_CF     ,ptb_InRecOwner[PLA1_SSD_CF      ]);
	strcpy(sz_PLA_ESB_CF     ,ptb_InRecOwner[PLA1_ESB_CF      ]);
	strcpy(sz_PLA_RETCTR_NF  ,ptb_InRecOwner[PLA1_RETCTR_NF   ]);
	strcpy(sz_PLA_RETEND_NT  ,ptb_InRecOwner[PLA1_RETEND_NT   ]);
	strcpy(sz_PLA_RETSEC_NF  ,ptb_InRecOwner[PLA1_RETSEC_NF   ]);
	strcpy(sz_PLA_RTY_NF     ,ptb_InRecOwner[PLA1_RTY_NF      ]);
	strcpy(sz_PLA_RETUW_NT   ,ptb_InRecOwner[PLA1_RETUW_NT    ]);
	strcpy(sz_PLA_PLC_NT     ,ptb_InRecOwner[PLA1_PLC_NT      ]);
	strcpy(sz_PLA_PLCSTS_CT  ,ptb_InRecOwner[PLA1_PLCSTS_CT   ]);
	strcpy(sz_PLA_OVRCOM_R   ,ptb_InRecOwner[PLA1_OVRCOM_R    ]);
	strcpy(sz_PLA_RTO_NF     ,ptb_InRecOwner[PLA1_RTO_NF      ]);
	strcpy(sz_PLA_INT_NF     ,ptb_InRecOwner[PLA1_INT_NF      ]);
	strcpy(sz_PLA_PAY_NF     ,ptb_InRecOwner[PLA1_PAY_NF      ]);
	strcpy(sz_PLA_KEY_CF     ,ptb_InRecOwner[PLA1_KEY_CF      ]);
	strcpy(sz_PLA_ORICUR_B   ,ptb_InRecOwner[PLA1_ORICUR_B    ]);
	strcpy(sz_PLA_SSDRTO_B   ,ptb_InRecOwner[PLA1_SSDRTO_B    ]);
	strcpy(sz_PLA_RETSIGSHA_R,ptb_InRecOwner[PLA1_RETSIGSHA_R ]);
	strcpy(sz_PLA_LOB_CF     ,ptb_InRecOwner[PLA1_LOB_CF      ]);
	strcpy(sz_PLA_RAICOM_B   ,ptb_InRecOwner[PLA1_RAICOM_B    ]);
	strcpy(sz_PLA_RETOVRCOM_B,ptb_InRecOwner[PLA1_RETOVRCOM_B ]);
	strcpy(sz_PLA_CTR_NF     ,ptb_InRecOwner[PLA1_CTR_NF      ]);
	strcpy(sz_PLA_END_NT     ,ptb_InRecOwner[PLA1_END_NT      ]);
	strcpy(sz_PLA_SEC_NF     ,ptb_InRecOwner[PLA1_SEC_NF      ]);
	strcpy(sz_PLA_UWY_NF     ,ptb_InRecOwner[PLA1_UWY_NF      ]);
	strcpy(sz_PLA_UW_NT      ,ptb_InRecOwner[PLA1_UW_NT       ]);
	strcpy(sz_PLA_CUR_CF     ,ptb_InRecOwner[PLA1_CUR_CF      ]);
	strcpy(sz_PLA_CESSH_R    ,ptb_InRecOwner[PLA1_CESSH_R     ]);
	strcpy(sz_PLA_CLMFUN_R   ,ptb_InRecOwner[PLA1_CLMFUN_R    ]);
	strcpy(sz_PLA_URRFUN_R   ,ptb_InRecOwner[PLA1_URRFUN_R    ]);
	strcpy(sz_PLA_CLMFUNINT_R,ptb_InRecOwner[PLA1_CLMFUNINT_R ]);
	strcpy(sz_PLA_URRFUNINT_R,ptb_InRecOwner[PLA1_URRFUNINT_R ]);
	strcpy(sz_PLA_CONRETCTR_B,ptb_InRecOwner[PLA1_CONRETCTR_B ]);
	strcpy(sz_PLA_OVRBASIS_NT,ptb_InRecOwner[PLA1_OVRBASIS_NT ]);
	strcpy(sz_PLA_ACCFAM_CT  ,ptb_InRecOwner[PLA1_ACCFAM_CT   ]);
	strcpy(sz_PLA_ACCTYP_CT  ,ptb_InRecOwner[PLA1_ACCTYP_CT   ]);
	strcpy(sz_PLA_CTRNAT_CT  ,ptb_InRecOwner[PLA1_CTRNAT_CT   ]);
	strcpy(sz_PLA_DEPORI_B   ,ptb_InRecOwner[PLA1_DEPORI_B    ]);

	/*strcpy(sz_PLA_RTOCTY_CF, ptb_InRecOwner[PLA1_RTOCTY_CF  ]);  */
	strcpy(sz_PLA_BLCSHTSTR_D,ptb_InRecOwner[PLA1_BLCSHTSTR_D ]);// [022]
	strcpy(sz_PLA_BLCSHTEND_D,ptb_InRecOwner[PLA1_BLCSHTEND_D ]);// [022]

	Ktb_PlacSave[PLA1_SSD_CF     ]= sz_PLA_SSD_CF       ;
	Ktb_PlacSave[PLA1_ESB_CF     ]= sz_PLA_ESB_CF       ;
	Ktb_PlacSave[PLA1_RETCTR_NF  ]= sz_PLA_RETCTR_NF    ;
	Ktb_PlacSave[PLA1_RETEND_NT  ]= sz_PLA_RETEND_NT    ;
	Ktb_PlacSave[PLA1_RETSEC_NF  ]= sz_PLA_RETSEC_NF    ;
	Ktb_PlacSave[PLA1_RTY_NF     ]= sz_PLA_RTY_NF       ;
	Ktb_PlacSave[PLA1_RETUW_NT   ]= sz_PLA_RETUW_NT     ;
	Ktb_PlacSave[PLA1_PLC_NT     ]= sz_PLA_PLC_NT       ;
	Ktb_PlacSave[PLA1_PLCSTS_CT  ]= sz_PLA_PLCSTS_CT    ;
	Ktb_PlacSave[PLA1_OVRCOM_R   ]= sz_PLA_OVRCOM_R     ;
	Ktb_PlacSave[PLA1_RTO_NF     ]= sz_PLA_RTO_NF       ;
	Ktb_PlacSave[PLA1_INT_NF     ]= sz_PLA_INT_NF       ;
	Ktb_PlacSave[PLA1_PAY_NF     ]= sz_PLA_PAY_NF       ;
	Ktb_PlacSave[PLA1_KEY_CF     ]= sz_PLA_KEY_CF       ;
	Ktb_PlacSave[PLA1_ORICUR_B   ]= sz_PLA_ORICUR_B     ;
	Ktb_PlacSave[PLA1_SSDRTO_B   ]= sz_PLA_SSDRTO_B     ;
	Ktb_PlacSave[PLA1_RETSIGSHA_R]= sz_PLA_RETSIGSHA_R  ;
	Ktb_PlacSave[PLA1_LOB_CF     ]= sz_PLA_LOB_CF       ;
	Ktb_PlacSave[PLA1_RAICOM_B   ]= sz_PLA_RAICOM_B     ;
	Ktb_PlacSave[PLA1_RETOVRCOM_B]= sz_PLA_RETOVRCOM_B  ;
	Ktb_PlacSave[PLA1_CTR_NF     ]= sz_PLA_CTR_NF       ;
	Ktb_PlacSave[PLA1_END_NT     ]= sz_PLA_END_NT       ;
	Ktb_PlacSave[PLA1_SEC_NF     ]= sz_PLA_SEC_NF       ;
	Ktb_PlacSave[PLA1_UWY_NF     ]= sz_PLA_UWY_NF       ;
	Ktb_PlacSave[PLA1_UW_NT      ]= sz_PLA_UW_NT        ;
	Ktb_PlacSave[PLA1_CUR_CF     ]= sz_PLA_CUR_CF       ;
	Ktb_PlacSave[PLA1_CESSH_R    ]= sz_PLA_CESSH_R      ;
	Ktb_PlacSave[PLA1_CLMFUN_R   ]= sz_PLA_CLMFUN_R     ;
	Ktb_PlacSave[PLA1_URRFUN_R   ]= sz_PLA_URRFUN_R     ;
	Ktb_PlacSave[PLA1_CLMFUNINT_R]= sz_PLA_CLMFUNINT_R  ;
	Ktb_PlacSave[PLA1_URRFUNINT_R]= sz_PLA_URRFUNINT_R  ;
	Ktb_PlacSave[PLA1_CONRETCTR_B]= sz_PLA_CONRETCTR_B  ;
	Ktb_PlacSave[PLA1_OVRBASIS_NT]= sz_PLA_OVRBASIS_NT  ;
	Ktb_PlacSave[PLA1_ACCFAM_CT  ]= sz_PLA_ACCFAM_CT    ;
	Ktb_PlacSave[PLA1_ACCTYP_CT  ]= sz_PLA_ACCTYP_CT    ;
	Ktb_PlacSave[PLA1_CTRNAT_CT  ]= sz_PLA_CTRNAT_CT    ;
	Ktb_PlacSave[PLA1_DEPORI_B   ]= sz_PLA_DEPORI_B     ;
	Ktb_PlacSave[PLA1_BLCSHTSTR_D]= sz_PLA_BLCSHTSTR_D  ;// [022]
	Ktb_PlacSave[PLA1_BLCSHTEND_D]= sz_PLA_BLCSHTEND_D  ;// [022]
	Ktb_PlacSave[PLA1_NBCOL]= 0 ;

	return ret ;
}


/*******************************************************************************
** objet  :
**      fonction lancee pour chaque ligne synchronisee
** retour :
**      OK ---> traitement correctement effectue
**      ERR --> probleme rencontre
*******************************************************************************/
//    adresse de la ligne du maitre, de l'esclave
int n_TraitePlaPrev( char **ptb_Pla, char **Pre)
{
	double d_montant_1=0, d_montant_2=0, d_montant_3=0;       /* previsions */
	char sz_montant_1[25], sz_montant_2[25], sz_montant_3[25], sz_montant_tmp[25];
	double d_taux;
	int n_type_poste=0;
	int n_poste_1=0, n_poste_2=0, n_poste_3=0;             /* postes en sortie */
	char sz_new[] = "I";
	char sz_lib_oricod[11] = "RETRO AUTO";
	double dw_montant_1=0;
	int indice = 0;
	char sz_DeTTRN[6];
	char sz_DETR[9] = "";
	char Det_RS0,Det_RS1,Det_RS8;
	int reslt=0;
	int retAuto=0, result_bprop = 0;
	int n_indice=0;
	char val [2];
	char yearSTR_D[5];
	char yearEND_D[5];
	int dateACY;
	//int result;                     [020]
	//char Acmtrs_new[5];             [020]
	//char Ori_Ctr[10]="CTRAAABBB";
	//char Ori_Sec[2]="A";
	//int  n_Ori_Sec=0;
	//char Ori_Uwy[4]="YYYY";
	int  sz_ACCTYP=0;        //[027]
	char TRANSTYP_CF[6]="";  //[027]
	char sz_DETTRNCOD[6]=""; //[027]
	char FAMTRN_CF[2]="0";   //[027]
	char sz_DETTRS_CF[9]="";

	char *psz_ligne[PRE_NBCOL+1];
	int j =0;

	for (j=0;j<PRE_NBCOL;j++)
	{
		psz_ligne[j]=Pre[j];
	}
	psz_ligne[PRE_NBCOL]=0;

	DEBUT_FCT("n_TraitePlaPrev");

		// [028] : START 
		/* Sauvegarde de DETTRS_CF si existe sinon on le calcul a partir de DETTRNCOD_CF */
		if (strcmp(psz_ligne[PRE_DETTRS_CF], "        ") <= 0){
                    CompleterPoste (psz_ligne[PRE_LOB_CF],
                                    psz_ligne[PRE_DETTRNCOD_CF],
                                    atoi(psz_ligne[PRE_GAAP_NF]),
                                    psz_ligne[PRE_ACMTRS_NT],
                                    sz_DETTRS_CF);
		}
		else {
			sprintf (sz_DETTRS_CF, "%.7s%c", psz_ligne[PRE_DETTRS_CF], 0);
			// car dans la table TTRANSTCODE nous trouvons que des suffixes 0 et 2
			if (sz_DETTRS_CF[7] != '0' && sz_DETTRS_CF[7] != '2'){
				sz_DETTRS_CF[7] = '0';
			}
		}
		// [028] : END 

	/* ajout jr 21/11/03 acces a tableau fichier tlifdri pour test AUTUPD_B */
	/* recherche de la cle dans la table de pilotage */
	indice = n_RechPilot (ptb_Pla, Pre, indice);
	Kn_OK1=1;
	Kn_OK2=0;

	if (indice == -1)
	{
		Kn_OK1 = 0;
		Kn_OK2 = 1;
	}

	if ( Kn_OK1 == 1 )
	{
		if (Kbd_PILOT[indice].AUTUPD_B == 0)
		{
			Kn_OK2 = 1;
		}
	}

	psz_ligne[PRE_ORICTR_NF]=psz_ligne[PRE_CTR_NF];
	psz_ligne[PRE_ORISEC_NF]=psz_ligne[PRE_SEC_NF];
	psz_ligne[PRE_ORIUWY_NF]=psz_ligne[PRE_UWY_NF];

    //[015] Changement de recupération de flag RETRO_AUTO
    result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, psz_ligne[PRE_DETTRNCOD_CF], psz_ligne[PRE_SSD_CF], psz_ligne[PRE_ESB_CF]);
    if ( result_bprop != (-1) )
	{
		retAuto=SubTrsEsBprop.RETROAUTO_B;
	}

    if ( atoi(ptb_Pla[PLA1_CONRETCTR_B]) == 1   &&      //  generation retro auto      =1
         //atoi(psz_ligne[PRE_RETCOD_CT]) != 0          &&      //  poste a passer en retro    =1  non trouve dans fichier pilot (FLIFDRI)
        retAuto != 0          &&
	    (Kn_OK2 == 1 ||                                // ou AUTUPD_B = 0 (remplace pas les previsions par la compta)
	     atoi(psz_ligne[PRE_ACMTRS_NT]) == 1163 || atoi(psz_ligne[PRE_ACMTRS_NT]) == 1164 ||  // [012]
	     atoi(psz_ligne[PRE_ACMTRS_NT]) == 1363 || atoi(psz_ligne[PRE_ACMTRS_NT]) == 1364 ||  //[016]
	     atoi(psz_ligne[PRE_ACMTRS_NT]) == 1393 || atoi(psz_ligne[PRE_ACMTRS_NT]) == 1394 ||
	     atoi(psz_ligne[PRE_ACMTRS_NT]) == 1193 || atoi(psz_ligne[PRE_ACMTRS_NT]) == 1194 )
		)  // [012]
	{
	    if ( Ind_FilsSansPere == 1 && atoi(ptb_Pla[PLA1_PLCSTS_CT]) == 19 ) /** Added for Phase1b migration **/
        {
			RETURN_VAL (0);
        }

		Ind_FilsSansPere = 0;

		// printf("TRAITEMENT RETRO\n");
		if (strcmp(ptb_Pla[PLA1_CUR_CF],"ATS") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"BEF") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"DEM") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"ESP") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"FIM") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"FRF") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"GRD") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"IEP") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"ITL") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"LUF") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"NLG") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"PTE") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		if (strcmp(ptb_Pla[PLA1_CUR_CF],"XEU") == 0)
		{
			strcpy(ptb_Pla[PLA1_CUR_CF],"EUR");
		}

		/* conversion devise de la prev => devise du placement */
		d_taux = d_GetTaux ( Kp_CoursFile,
		                    (char)  atoi(psz_ligne[PRE_SSD_CF]),
		                    (short) Kn_annee,
		                    psz_ligne[PRE_CUR_CF],
		                    ptb_Pla[PLA1_CUR_CF]);

		/* type_poste correspondant aux 3 derniers chiffres */
		n_type_poste = atoi(psz_ligne[PRE_ACMTRS_NT]) % 1000;
		d_montant_1  = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_RETSIGSHA_R])) * -1;

		/* [008] */
		if (atoi(psz_ligne[PRE_ACMTRS_NT]) == 1150)
			n_poste_1 = 2145;
		else
			n_poste_1 = 2000 + n_type_poste;

		memset ( val ,0, sizeof (val));
		val [0] = '1';

		switch ( atoi(psz_ligne[PRE_ACMTRS_NT]) )
		{
			/* primes nettes RCPP */
			case 1010:
				if (strcmp(ptb_Pla[PLA1_OVRBASIS_NT],"") == 0)
				{
					strcpy(ptb_Pla[PLA1_OVRBASIS_NT], "1");
				}

				for (n_indice = 0; n_indice <= Kn_Acmtrs_base; n_indice++)
				{
					if (( strcmp(Kbd_Acmtrs_base[n_indice].ACMTRS, ptb_Pla[PLA1_OVRBASIS_NT]) == 0) &&
					    ( strcmp(Kbd_Acmtrs_base[n_indice].DETTRNCOD, psz_ligne[PRE_DETTRNCOD_CF]) == 0) &&
					    ( strcmp(Kbd_Acmtrs_base[n_indice].CTR_NF,    psz_ligne[PRE_CTR_NF]) == 0) &&
					    ( strcmp(Kbd_Acmtrs_base[n_indice].SEC_NF,    psz_ligne[PRE_SEC_NF]) == 0) &&
					    ( strcmp(Kbd_Acmtrs_base[n_indice].UWY_NF,    psz_ligne[PRE_UWY_NF]) == 0) &&
					    ( strcmp(Kbd_Acmtrs_base[n_indice].GAAP_NT,   psz_ligne[PRE_GAAP_NF]) == 0)
					   )
					{
						// [020]
						/* A ne pas faire => strcpy (psz_ligne[PRE_ESTMNT_M],Kbd_Acmtrs_base[n_indice].ESTMNT_M);*/
						d_montant_2 = atof(Kbd_Acmtrs_base[n_indice].ESTMNT_M);
						sprintf(sz_montant_tmp, "%.3lf", d_montant_2);
						psz_ligne[PRE_ESTMNT_M] = sz_montant_tmp;
					}
				}
				d_montant_2 = atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_OVRCOM_R]);
				n_poste_2 = 2150;
				break;

			/* provisions primes constituees */
			case 1063:
				// [012]            case 1093:      //[009]
				// [012]            case 1543:      //[010]
				d_montant_2 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_URRFUN_R])) * -1;
				n_poste_2 = 2303;
				break;

			/* provisions primes liberees */
			case 1064:
				// [012]            case 1094:      //[009]
				d_montant_2 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_URRFUN_R])) * -1;
				n_poste_2 = 2304;

				d_montant_3 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_URRFUNINT_R])) * -1;
				break;

			/* provisions sinistres constituees */
			case 1243:
				d_montant_2 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_CLMFUN_R])) * -1;
				n_poste_2 = 2323;
				break;

			/* provisions sinistres liberees */
			case 1244:
				d_montant_2 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_CLMFUN_R])) * -1;
				n_poste_2 = 2324;

				d_montant_3 = (atof(psz_ligne[PRE_ESTMNT_M]) * d_taux * atof(ptb_Pla[PLA1_CESSH_R]) * atof(ptb_Pla[PLA1_CLMFUNINT_R])) * -1;
				break;

			/* $$$$$$$$$$$$$$$$    ajout jr 17/03/03  $$$$$$$$$$$$$$$$$$$$*/
			case 1303:
				if (strcmp(ptb_Pla[PLA1_DEPORI_B],val) != 0)
				{
					d_montant_1 = dw_montant_1;
				}
				break;

			case 1304:
				if (strcmp(ptb_Pla[PLA1_DEPORI_B],val) != 0)
				{
					d_montant_1 = dw_montant_1;
				}
				break;

			case 1323:
				if (strcmp(ptb_Pla[PLA1_DEPORI_B],val) != 0)
				{
					d_montant_1 = dw_montant_1;
				}
				break;

			case 1324:
				if (strcmp(ptb_Pla[PLA1_DEPORI_B],val) != 0)
				{
					d_montant_1 = dw_montant_1;
				}
				break;

			case 1340:
				if (strcmp(ptb_Pla[PLA1_DEPORI_B],val) != 0)
				{
					d_montant_1 = dw_montant_1;
				}
				break;
			/* $$$$$$$$$$$$$$$$  fin  ajout jr 17/03/03  $$$$$$$$$$$$$$$$$$$$*/
		}

		/* ecritures previsions si non nulles pour contrat/avenant/section/Ex/ordreEx RETROCESSION */
		n_poste_3 = 2340;   /* poste interet sur depot */

		psz_ligne[PRE_CTR_NF]        = ptb_Pla[PLA1_RETCTR_NF];
		psz_ligne[PRE_END_NT]        = ptb_Pla[PLA1_RETEND_NT];
		psz_ligne[PRE_SEC_NF]        = ptb_Pla[PLA1_RETSEC_NF];
		psz_ligne[PRE_UW_NT]         = ptb_Pla[PLA1_RETUW_NT] ;
		psz_ligne[PRE_ACCADMTYP_CT]  = ptb_Pla[PLA1_ACCTYP_CT]; // [026]

		if (atoi(ptb_Pla[PLA1_ACCTYP_CT]) == 1)
		{
			psz_ligne[PRE_UWY_NF] = psz_ligne[PRE_ACY_NF];
		}

		if (strcmp(psz_ligne[PRE_ORICOD_LS] ,"RETRO INTERNE")==0)
		{
			psz_ligne[PRE_CRE_D] = Ksz_Cre ;   //Ksz_Cre2 ;    JR 15 12 2006
		}
		else
		{
			psz_ligne[PRE_CRE_D] = Ksz_Cre ;
		}
		
		psz_ligne[PRE_BATCH_B] = "1"; // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
		strcpy(psz_ligne[PRE_BALSHEY_NF], s_DateBilan);
		psz_ligne[PRE_BALSHTMTH_NF] = Ksz_Balshtmth ;
		psz_ligne[PRE_CUR_CF] = ptb_Pla[PLA1_CUR_CF];
		psz_ligne[PRE_UPD_NF] = sz_new;
		strcpy(psz_ligne[PRE_CREUSR_CF], "dbo") ;
		psz_ligne[PRE_LSTUPD_D] = Ksz_Cre ;
		strcpy(psz_ligne[PRE_LSTUPDUSR_CF] , "dbo")  ;
		psz_ligne[PRE_UWGRP_CF]  = ""  ;  /* ajout 12/01/98 */
		psz_ligne[PRE_ESTCRB_CT] = " " ;  /* ajout 20/01/98 */
		psz_ligne[PRE_CED_NF] = "" ;      /* ajout 07/04/03 */
		psz_ligne[PRE_BRK_NF] = "" ;      /* ajout 07/04/03 */
		psz_ligne[PRE_PAY_NF] = "" ;      /* ajout 07/04/03 */
		psz_ligne[PRE_GANPAYORD_NT] = "" ;/* ajout 07/04/03 */
		psz_ligne[PRE_LIFTRTTYP_CF] = "" ;/* ajout 07/04/03 */
		//psz_ligne[PRE_ESTMTH_NF]="13";
		psz_ligne[PRE_ORICOD_LS] = sz_lib_oricod;  /* JR  ajout 12/02/03 */
		sprintf(psz_ligne[PRE_ACMTRS_NT], "%d", n_poste_1);
		sprintf(sz_montant_1, "%.3lf", d_montant_1);
		psz_ligne[PRE_ESTMNT_M] = sz_montant_1;

		Det_RS1=psz_ligne[PRE_DETTRS_CF][1];
		Det_RS8=psz_ligne[PRE_DETTRS_CF][8];
		strcpy(sz_DeTTRN, psz_ligne[PRE_DETTRNCOD_CF]);
		sz_DeTTRN[5]=0;

		if (atoi(psz_ligne[PRE_DETTRS_CF]) > 0)
		{
			psz_ligne[PRE_DETTRS_CF][0]= '2';
			
			if (atoi(ptb_Pla[PLA1_LOB_CF]) == 30)
			{
				psz_ligne[PRE_DETTRS_CF][0]= '4';
			}
		}

		Det_RS0=psz_ligne[PRE_DETTRS_CF][0];
		psz_ligne[PRE_NBCOL]=0;
		// [022] prise en compte des limtes pour l'année de compte
		sprintf(yearSTR_D,"%.4s",ptb_Pla[PLA1_BLCSHTSTR_D]);
		sprintf(yearEND_D,"%.4s",ptb_Pla[PLA1_BLCSHTEND_D]);
		dateACY = atoi(psz_ligne[PRE_ACY_NF] ) ;

		// [027] begin : case of assumed family not null
		sz_ACCTYP = atoi(ptb_Pla[PLA1_ACCTYP_CT]);
		if ( strcmp(ptb_Pla[PLA1_ACCFAM_CT], "") != 0 )
		{
			sprintf(TRANSTYP_CF, "%s","ASSFA");
			strcpy(FAMTRN_CF,ptb_Pla[PLA1_ACCFAM_CT]);
		}

		if ( strcmp(TRANSTYP_CF, "") != 0 )
		{
			// Appel fonction de recherche dans TRTRANSTCODE
			// [028] : START 
			int index_postTran = n_GetPostranstcode(sz_DETTRS_CF, ptb_Pla[PLA1_CTRNAT_CT], sz_ACCTYP, FAMTRN_CF, bd_TRANSTCODE, Kn_NbTranstcode);
			if ( index_postTran >= 0 )
			{
				sprintf(sz_DETR, "%.8s%c", bd_TRANSTCODE[index_postTran].TRADETTRS_CF, 0);
				sprintf(sz_DETTRNCOD, "%.5s%c", sz_DETR+2, 0);
				
				psz_ligne[PRE_DETTRS_CF]=sz_DETR;
				psz_ligne[PRE_DETTRNCOD_CF]=sz_DETTRNCOD;
				sprintf(psz_ligne[PRE_ACMTRS_NT], "%d", n_RechACMTRS(psz_ligne[PRE_DETTRS_CF]));

			}
			// [028] : END 
		}
		// [027] end   : case of assumed family not null

		if ( (dateACY  >= atoi(yearSTR_D))&&(dateACY <= atoi(yearEND_D))) 
		{
			n_WriteCols(Kp_PrevOutFile,psz_ligne,'~',0);
		}
		else 
		{
			n_WriteCols(Kp_AnoFile,psz_ligne,'~',0);
		}

		if (n_poste_2 != 0 && ((d_montant_2 != 0) || (d_montant_1 == 0)))
		{
			sprintf(psz_ligne[PRE_ACMTRS_NT], "%d", n_poste_2);
			reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne,6,2,sz_DeTTRN);
			if (reslt!=-1)
			{
				sprintf(sz_DETR,"%c%c%s%c",Det_RS0,Det_RS1,SubTrsAssoLigne.DETTRNCOD2_CF,Det_RS8);
				sz_DETR[8]=0;
				psz_ligne[PRE_DETTRS_CF]=sz_DETR;
				psz_ligne[PRE_DETTRNCOD_CF]=SubTrsAssoLigne.DETTRNCOD2_CF;
			}
			else
			{
				sprintf(sz_DETR,"%d",n_RechercheTACCPAR(atoi(psz_ligne[PRE_ACMTRS_NT])));
				sz_DETR[8]=0;
				psz_ligne[PRE_DETTRS_CF]=sz_DETR;
				strcpy(sz_DeTTRN,psz_ligne[PRE_DETTRS_CF]+2);
				sz_DeTTRN[5]=0;
				psz_ligne[PRE_DETTRNCOD_CF]=sz_DeTTRN;
			}

			sprintf(sz_montant_2, "%.3lf", d_montant_2);
			psz_ligne[PRE_ESTMNT_M] = sz_montant_2;
			psz_ligne[PRE_NBCOL]=0;
			psz_ligne[PRE_ORICOD_LS] = "RETRO AUTO";

			// Exception :
			//---------------

			// n_WriteCols(Kp_PrevOutFile,psz_ligne,'~',0);
			// [022] prise en compte des limtes pour l'année de compte
			sprintf(yearSTR_D,"%.4s",ptb_Pla[PLA1_BLCSHTSTR_D]);
			sprintf(yearEND_D,"%.4s",ptb_Pla[PLA1_BLCSHTEND_D]);
			dateACY = atoi(psz_ligne[PRE_ACY_NF] ) ;

			if ( (dateACY  >= atoi(yearSTR_D))&&(dateACY <= atoi(yearEND_D)))
			{
				n_WriteCols(Kp_PrevOutFile,psz_ligne,'~',0);
			}
			else
			{
				n_WriteCols(Kp_AnoFile,psz_ligne,'~',0);
			}

		}

		if ((d_montant_3 != 0) || (d_montant_1 == 0))
		{
			sprintf(psz_ligne[PRE_ACMTRS_NT], "%d", n_poste_3);
			reslt=n_FindTsubTRSAsso(&SubTrsAssoLigne,6,2,sz_DeTTRN);
			if (reslt!=-1)
			{
				sprintf(sz_DETR,"%c%c%s%c",Det_RS0,Det_RS1,SubTrsAssoLigne.DETTRNCOD2_CF,Det_RS8);
				sz_DETR[8]=0;
				/* [025] : calcul du poste complement si il est vide */
				if (strcmp(sz_DETR, " ") <= 0)
				{
					CompleterPoste (psz_ligne[PRE_LOB_CF],
					                SubTrsAssoLigne.DETTRNCOD2_CF,
					                atoi(psz_ligne[PRE_GAAP_NF]),
					                psz_ligne[PRE_ACMTRS_NT],
					                sz_DETR);
				}
				psz_ligne[PRE_DETTRS_CF]=sz_DETR;
				psz_ligne[PRE_DETTRNCOD_CF]=SubTrsAssoLigne.DETTRNCOD2_CF;
			}
			else
			{
				sprintf(sz_DETR,"%d",n_RechercheTACCPAR(atoi(psz_ligne[PRE_ACMTRS_NT])));
				sz_DETR[8]=0;
				psz_ligne[PRE_DETTRS_CF]=sz_DETR;
				strcpy(sz_DeTTRN,psz_ligne[PRE_DETTRS_CF]+2);
				sz_DeTTRN[5]=0;
				psz_ligne[PRE_DETTRNCOD_CF]=sz_DeTTRN;
			}

			sprintf(sz_montant_3, "%.3lf", d_montant_3);
			psz_ligne[PRE_ESTMNT_M] = sz_montant_3;
			psz_ligne[PRE_NBCOL]=0;
			psz_ligne[PRE_ORICOD_LS] = "RETRO AUTO";

			// n_WriteCols(Kp_PrevOutFile,psz_ligne,'~',0);
			// [022] prise en compte des limtes pour l'année de compte
			sprintf(yearSTR_D,"%.4s",ptb_Pla[PLA1_BLCSHTSTR_D]);
			sprintf(yearEND_D,"%.4s",ptb_Pla[PLA1_BLCSHTEND_D]);
			dateACY = atoi(psz_ligne[PRE_ACY_NF] ) ;

			if ((dateACY >= atoi(yearSTR_D)) &&
			    (dateACY <= atoi(yearEND_D)) &&
			    /*[025] : ecrire la ligne que si le poste et l'ACMTRS sont correct */
			    (n_RechACMTRS(psz_ligne[PRE_DETTRS_CF]) == atoi(psz_ligne[PRE_ACMTRS_NT]))) 
			{
				n_WriteCols(Kp_PrevOutFile,psz_ligne,'~',0);
			}
			else
			{
				n_WriteCols(Kp_AnoFile,psz_ligne,'~',0);
			}
		}
	}

	RETURN_VAL (OK);
}


/***************************************************************************
**   Objet :    Recherche un pilotage dans la table charge en memoire
**   Nom:       n_RechPilot
**   Parametres:  la prevision recherche
**   Retour:    indice de le ligne du pilotage cherchee
**              -1 si non trouvee
****************************************************************************/
int n_RechPilot (char **psz_prev, char **psz_prev1, int n_indice)
{
	int i ;

	for(i=n_indice;i<Kn_NbLigPilot;i++)
	{
		if (strcmp(psz_prev[PLA1_RETCTR_NF], Kbd_PILOT[i].CTR_NF)==0    &&
		    atoi(psz_prev[PLA1_RETSEC_NF])== Kbd_PILOT[i].SEC_NF        &&
		    atoi(psz_prev1[PRE_ACY_NF])==Kbd_PILOT[i].ACY_NF            &&
		    atoi(psz_prev[PLA1_RETUW_NT])==Kbd_PILOT[i].UW_NT )
		{
			return i ;
		}
	}

	return -1 ;
}


/*******************************************************************************
** objet :
**      Affiche une structure de type T_LIFDRI
*******************************************************************************/
void affiche (T_LIFDRI_ALL *bd_Lu)
{
    printf("ctr=|%s|   sec=|%d|  uwy=|%d|   autupd=|%d|   comacc=|%d| \n",
            bd_Lu->CTR_NF,
            bd_Lu->SEC_NF,
            bd_Lu->UWY_NF,
            bd_Lu->AUTUPD_B,
            bd_Lu->COMACC_B );
}


/*******************************************************************************
** Objet :    Copie le contenu du fichier en entree dans un tableau
** Nom: n_ChargerPilot
**   Parametres: Le pointeur du fichier
**               Le tableau de structures
**   Retour: 0
*******************************************************************************/
int n_ChargerPilot()
{
	int n_EOF = 0;
	T_LIFDRI_ALL bd_Lu;
	char MsgAno[300];

	DEBUT_FCT("n_ChargerPilot");

	if ( n_OpenFileAppl ("ESTC2135_I4","rb",&Kp_PilotFile) == ERR )
		ExitPgm ( ERR_XX , "" );

	Kn_NbLigPilot=0;
	/* Tant que la fin de fichier n'est pas atteinte,... */
	while ( n_EOF == 0 )
	{
		/* ... lecture d'une ligne dans le fichier. */
		if ( fread(&bd_Lu,sizeof(T_LIFDRI_ALL),1,Kp_PilotFile) <= 0 )
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			/* Ecriture dans log si depassement du tableau */
			if ( Kn_NbLigPilot >= NB_MAX_PILOT)
			{
				sprintf(MsgAno,"The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
				        bd_Lu.CTR_NF,
				        bd_Lu.SEC_NF,
				        bd_Lu.UWY_NF);
				n_WriteAno(MsgAno);
				RETURN_VAL(0);
			}

			/* Enregistrement ecrit dans le tableau */
			Kbd_PILOT[Kn_NbLigPilot++] = bd_Lu;
		}
	}

	RETURN_VAL (0);
}


/*******************************************************************************
** objet :     Initialisation du fichier
** retour:     OK
*******************************************************************************/
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitTACCPAR");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

	// ouverture du fichier esclave
	n_OpenFileAppl ("ESTC2135_I5","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture           = 0  ;
	pbd_Rupt->n_ActionLigne         = n_ActionLigneTACCPAR;
	pbd_Rupt->c_Separ   = '~' ;

	RETURN_VAL(OK);
}


/*******************************************************************************
** objet : fonction lancee pour chaque ligne du perimetre
** retour: OK ---> traitement correctement effectue
**      ERR --> probleme rencontre
*******************************************************************************/
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR )
{
	ACM_DETT.Acmtrs[ACM_DETT.nb_acmtrs]= atoi( ptb_InRecTACCPAR[ACC_ACMTRS_NT]);
	ACM_DETT.Dettrs[ACM_DETT.nb_acmtrs]= atoi(ptb_InRecTACCPAR[ACC_DETTRS_CF]);

	ACM_DETT.nb_acmtrs++;

	return(0);
	RETURN_VAL(OK);
}


/********************************************************************************
** object :
** return : 
********************************************************************************/
int n_RechercheTACCPAR( int ACMTRS )
{
	int i =0;
	for (i =0; i<= ACM_DETT.nb_acmtrs; i++)
	{
		if (ACM_DETT.Acmtrs[i]== ACMTRS)
			return (ACM_DETT.Dettrs[i]);
	}

	return -1;
}


/*******************************************************************************
**   Objet :    Initialisation de la structure TRSASSO
**   Nom:       init_SubTrsAssoLigne
**   Parametres:
**   Retour:    0
*******************************************************************************/
void init_SubTrsAssoLigne()
{
	strcpy (SubTrsAssoLigne.ASSOTYP_CT,"");   //[014]
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


/*******************************************************************************
**   Objet :    Initialisation de la structure TRS
**   Nom:       init_SubTrsEsBprop
**   Parametres:
**   Retour:    0
*******************************************************************************/
void init_SubTrsEsBprop()
{
	strcpy(SubTrsEsBprop.DETTRNCOD_CF, "");
	SubTrsEsBprop.SSD_CF=0;
	SubTrsEsBprop.ESB_CF=0;
	SubTrsEsBprop.GLTFEEDING_B=0;
	SubTrsEsBprop.INTERNRETRO_B=0;
	SubTrsEsBprop.SRVFEEDING_B=0;
	SubTrsEsBprop.PREMIUMPNPEGPI_B=0;
	SubTrsEsBprop.RETROAUTO_B=0;
	SubTrsEsBprop.COMACIMPACT_B=0;
	SubTrsEsBprop.CASHFLOWPOS_CT=0;
	SubTrsEsBprop.GAAP1TRS_CT=0;
	SubTrsEsBprop.GAAP2TRS_CT=0;
	SubTrsEsBprop.GAAP3TRS_CT=0;
	SubTrsEsBprop.GAAP4TRS_CT=0;
	SubTrsEsBprop.GAAP5TRS_CT=0;
	strcpy(SubTrsEsBprop.CRE_D,"");
	strcpy(SubTrsEsBprop.CREUSR_CF,"");
	strcpy(SubTrsEsBprop.LSTUPD_D,"");
	strcpy(SubTrsEsBprop.LSTUPDUSR_CF,"");
}

/* [025] : ajout de fonction pour transformer un poste a 5 vers un poste a 8 */
/***********************************************************************************
** objet : fonction permettant de formater le poste complement (poste a 8 digits), *
**         ajoute prefixe, sous-prefixe et suffixe                                 *
** entree: type: 1 pour acceptation,                                               *
**               2 pour retrocession = 1er chiffre de l'ACMTRS                     *
************************************************************************************/
void CompleterPoste (char *lob, char *DETTRN, int norme, char *ACMTRS, char *poste)
{
	int n_lob;
	int reslt;
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

	DEBUT_FCT("CompleterPoste");

	/* Calcul du 8eme cractere du poste a 8 digit 8 '.. ..... x' */
	n_lob = atoi(lob);
	switch (norme)
	{
		case 1: strcpy(TRN8, "2");
			break;
		case 2: strcpy(TRN8, "A");
			break;
		case 3:  strcpy(TRN8, "C");
			break;
		case 4:  strcpy(TRN8, "E");
			break;
		case 5:   strcpy(TRN8, "G");
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
		{  strcpy(TRN2, "1"); }
		else if (SubTrsLigne.TRSTYPE_CT == 4 )
		{  strcpy(TRN2, "3"); }
		else
		{  strcpy(TRN2, "9"); }
	}
	if (DETTRN[0] == '2')
		strcpy(TRN2, "1");

	TRN2[1] = 0;

	//Cas particuliers : 
	//----------------- 
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
	if ((DETTRN[0] == '8') && ( (DETTRN[1] == '2') ||
	    (DETTRN[1] == '3') ||
	    (DETTRN[1] == '4') ))
	{
		strcpy(TRN2, "3");
		TRN2[1] = 0;
	}

	sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, "0");
	poste[8] = 0;
}

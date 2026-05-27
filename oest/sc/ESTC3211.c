/*==============================================================================
Nom de l'application          : Separation du GT acceptation en vie et non vie
Nom du source                 : ESTC3211.c
Revision                      : $Revision: 1.2 $
Date de creation              : 01/09/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Separation du GT acceptation en vie et non vie.
  En entree : le GT acceptation,
              le perimetre IADVPERICASE.
  En sortie : le GT dommages,
              le GT vie,
              un fichier d'anomalies.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include "ESTC3201.h"

#define Kn_MaxPostes 3000        /* Le nombre max de postes est fixe a 600 */

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 		   *Kp_OutputMvtCpt;
FILE 		   *Kp_OutputAff;
FILE		   *Kp_TrslnkFil  ;
FILE		   *Kp_Curquot  ;

T_RUPTURE_SYNC_VAR 	bd_SyncGTA, bd_SyncSTATGTA, bd_SyncARCSTATGTA  ;

BOOL 		b_IsAffMvtSync = FALSE ;
int     	Kn_NbLigTrslnk=0;
T_TRSLNK	Kbd_TRSLNK[Kn_MaxPostes];

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigne (char *ptsz_LigneCour[]);
int n_ChargerTRSLNK ();


int n_RechPoste(char *sz_poste);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync, char *sz_FicName);
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPere(char **ptsz_LigneMaitre);


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
   T_RUPTURE_VAR 		bd_MaitreCtrLis;

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }


/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_MaitreCtrLis ) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation du GTAavec le perimetre */
   if (n_InitSync(&bd_SyncGTA, "ESTC3211_I2") == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncGTA");
   }

/* Initialisation de la structure de synchronisation du STATGTA avec le perimetre */
   if (n_InitSync(&bd_SyncSTATGTA, "ESTC3211_I3") == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncSTAT");
   }

/* Initialisation de la structure de synchronisation du ARCSTATGTA avec le perimetre */
   if (n_InitSync(&bd_SyncARCSTATGTA, "ESTC3211_I4") == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncARCSTAT");
   }

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTC3211_I5", "rb", &Kp_TrslnkFil) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl Kp_TrslnkFil");
   }

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTC3211_I6", "rb", &Kp_Curquot) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl Kp_Curquot");
   }

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTC3211_O1", "wt", &Kp_OutputMvtCpt) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDom");
   }

/* Ouverture du fichier de sortie dommages */
   if (n_OpenFileAppl("ESTC3211_O2", "wt", &Kp_OutputAff) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDom");
   }

   if ( n_ChargerTRSLNK () == ERR){
      ExitPgm(ERR_XX , "Erreur appel fonction n_ChargerTRSLNK");
   }
/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_MaitreCtrLis) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC3211_I1", &(bd_MaitreCtrLis.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC3211_I2", &(bd_SyncGTA.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC3211_I3", &(bd_SyncSTATGTA.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC3211_I4", &(bd_SyncARCSTATGTA.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC3211_I5", &Kp_TrslnkFil) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC3211_I6", &Kp_Curquot) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }


   if (n_CloseFileAppl("ESTC3211_O1", &Kp_OutputMvtCpt) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileApplDom");
   }

   if (n_CloseFileAppl("ESTC3211_O2", &Kp_OutputAff) == ERR) {
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
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

   /* Ouverture du fichier maitre */

   if (n_OpenFileAppl("ESTC3211_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }


   pbd_Rupture->n_ActionLigne=n_ActionLigne;
   pbd_Rupture->c_Separ= '~';

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

int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync, char *sz_FicName)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

   /* Ouverture du fichier esclave */
   if (n_OpenFileAppl(sz_FicName, "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }


   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
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

   b_IsAffMvtSync = FALSE ;


   /* Synchronisation avec le GTA */
   n_ProcessingRuptureSyncVar(&bd_SyncGTA, ptsz_LigneCour);

   /* Synchronisation avec le STATGTA */
   n_ProcessingRuptureSyncVar(&bd_SyncSTATGTA, ptsz_LigneCour);

   /* Synchronisation avec le ARCSTATGTA */
   n_ProcessingRuptureSyncVar(&bd_SyncARCSTATGTA, ptsz_LigneCour);

   /* S'il y a un mouvement pour l'affaire on reconduit l'affaire */
   if( b_IsAffMvtSync == TRUE )
	   n_WriteCols(Kp_OutputAff, ptsz_LigneCour, '~', 0);

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
   int s_ret;

   DEBUT_FCT("n_ConditionSync");

   if (s_ret = strcmp(ptsz_LigneMaitre[AFF_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) {
      RETURN_VAL(s_ret);
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[AFF_END_NT], ptsz_LigneEsclave[GT_END_NT])) {
      RETURN_VAL(s_ret);
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[AFF_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) {
      RETURN_VAL(s_ret);
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[AFF_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) {
      RETURN_VAL(s_ret);
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[AFF_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
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
	int n_AcmTrs = 0 ;
	int n_indice ;
	char sz_AcmTrs[30] ;
	char PrdCpt[20], CptComplet[20] ;
	double d_Taux, d_PmdEgp ;
    	char MsgAno[300];

   DEBUT_FCT("n_ActionLigneSync");


   if (	(	strncmp(ptsz_LigneEsclave[GT_TRNCOD_CF],"11",2 )  &&
         	strncmp(ptsz_LigneEsclave[GT_TRNCOD_CF],"12",2 )
       	) 	|| ptsz_LigneEsclave[GT_TRNCOD_CF][7] != '0'
      )
   {
		RETURN_VAL(OK);
   }

   	n_indice=n_RechPoste(ptsz_LigneEsclave[GT_TRNCOD_CF]) ;
   	if ( n_indice < 0 )
 		RETURN_VAL(OK);


   	b_IsAffMvtSync = TRUE  ;



	sprintf(PrdCpt,"%s%2s", ptsz_LigneEsclave[GT_ACY_NF],ptsz_LigneEsclave[GT_SCOENDMTH_NF]);
	sprintf(CptComplet,"%s%2s",ptsz_LigneMaitre[AFF_CPLACCY_NF ],ptsz_LigneMaitre[AFF_SCOLSTMTH_NF]);

    	if (    ( *ptsz_LigneMaitre[AFF_CTRNAT_CT] == 'N' ) ||
            ( *ptsz_LigneMaitre[AFF_CTRNAT_CT] == 'F' ) ||
            ( *ptsz_LigneMaitre[AFF_CTRNAT_CT] == 'P' && strcmp(PrdCpt,CptComplet) <= 0)
       )
    {
        n_AcmTrs = Kbd_TRSLNK[n_indice].ACMTRS_NT  * -1 ;
    }
	else
        n_AcmTrs = Kbd_TRSLNK[n_indice].ACMTRS_NT  ;



	d_Taux = d_GetTaux( Kp_Curquot,
				        (char) atoi(ptsz_LigneEsclave[GT_SSD_CF]),/* filiale */
				        (int)atoi(ptsz_LigneEsclave[GT_BALSHEY_NF]),  /* Exercice */
				        ptsz_LigneEsclave[GT_CUR_CF]	,	  /* Cours d'origine */
				        ptsz_LigneMaitre[AFF_EGPCUR_CF]		  /* Cours destination */
				      );
	if ( d_Taux <= 0 )
	{
		sprintf(MsgAno,"TCURQUOT:  %s; %s; ;%s ;%s Not found",
				        ptsz_LigneEsclave[GT_SSD_CF], /* filiale */
				        ptsz_LigneEsclave[GT_BALSHEY_NF],  /* Exercice */
				        ptsz_LigneEsclave[GT_CUR_CF]	,	  /* Cours d'origine */
				        ptsz_LigneMaitre[AFF_EGPCUR_CF]		  /* Cours destination */
			);
		n_WriteAno(MsgAno);
   		RETURN_VAL(OK);

	}


    /* Calcul du montant en devise de l'aliment */
    d_PmdEgp = atof( ptsz_LigneEsclave[GT_AMT_M] ) * d_Taux  ;

   	/* Ecriture dans le fichier Mouvement comptable */
   	fprintf( Kp_OutputMvtCpt , "%s~%s~%s~%s~%s~%s~%s~%d~%s~%18.3f\n",
								ptsz_LigneEsclave[GT_SSD_CF      ],   /*  0 */
								ptsz_LigneEsclave[GT_BALSHEY_NF  ],   /*  1 */
								ptsz_LigneEsclave[GT_CTR_NF      ],   /*  2 */
								ptsz_LigneEsclave[GT_END_NT      ],   /*  3 */
								ptsz_LigneEsclave[GT_SEC_NF      ],   /*  4 */
								ptsz_LigneEsclave[GT_UWY_NF      ],   /*  5 */
								ptsz_LigneEsclave[GT_UW_NT       ],   /*  6 */
						       		n_AcmTrs,			      /*  7 */
						        	ptsz_LigneMaitre[AFF_EGPCUR_CF	 ],   /*  8 */
						        	d_PmdEgp);			      /*  9 */


   RETURN_VAL(OK);
}




/*==============================================================================
objet:
        Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK ()
{
    int n_EOF = 0;
    T_TRSLNK bd_Lu;
    char MsgAno[300];

    DEBUT_FCT("n_ChargerTRSLNK") ;

    Kn_NbLigTrslnk = 0 ;
    /* Tant que la fin de fichier n'est pas atteinte,... */
    while( fread(&Kbd_TRSLNK[Kn_NbLigTrslnk],sizeof(T_TRSLNK),1,Kp_TrslnkFil)  > 0 )
    {
	if( Kbd_TRSLNK[Kn_NbLigTrslnk].PRS_CF == 600 ) Kn_NbLigTrslnk++ ;
    	if ( Kn_NbLigTrslnk >= Kn_MaxPostes )
	{
		/* depassement tableau */
		sprintf(MsgAno,"TRSLNK:  overflows the program's storage capacity");
		n_WriteAno(MsgAno);
		RETURN_VAL(ERR);
	}
    }

    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de recherche du poste
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int i, ret;

	DEBUT_FCT("n_RechPoste");

	for(i=0;i<Kn_NbLigTrslnk;i++)
	{
	    /* S'ils sont egaux, retourner l'indice */
	    if( strcmp(sz_poste,Kbd_TRSLNK[i].DETTRS_CF)== 0 )
	    	RETURN_VAL(i);
	}

    /* Si la ligne est passee, retourner -1 (echec) */

    RETURN_VAL(-1);
}



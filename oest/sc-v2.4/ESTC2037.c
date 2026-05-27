/*==============================================================================
nom de l'application          : Maj compta et AS pour les traites fictifs
nom du source                 : ESTC2037.c
revision                      : $Revision:   1.0  $
date de creation              : 23/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
	A chaque ligne des traites fictifs, les traites non-cribles sont
	synchronises. Leurs montant et aliment sont reconduits en sortie
	apres avoir ete convertis et le montant est cumule et ecrit dans
	le traite de rattachement mis a jour. Ce dernier aura pour AS la
	valeur 1 si tous les traites non-cribles lies etaient a 1, sinon
	il vaudra 0.

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

FILE	*Kp_GT_C_Fil,	/* pointeur sur le GT cimulé en sortie */
		*Kp_GT_D_Fil,	/* pointeur sur le GT détaillé en sortie */
		*Kp_CoursFil;	/* fichier des cours devise en entree */
double	Kf_total;	/* Montant cumule */
int		Kb_AS;		/* Indicateur arrete statistique */

T_RUPTURE_VAR 		bd_RuptGT_N;	/* gestion rupture sur GT N */
T_RUPTURE_SYNC_VAR 	bd_RuptGT_R;	/* gestion synchro R -> N */

int n_InitGT_N			(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGT_N	(char **pbd_InRec_Cur);
int n_ActionFirstCSAC( char **ptb_InRec_Cur);
int n_ActionFirstCSACP( char **ptb_InRec_Cur);
int n_ActionLastCSACP( char **ptb_InRec_Cur);
int n_IsR1GT_N		(	char **pbd_InRec ,	char **pbd_InRec_Cur	);
int n_IsR2GT_N		(	char **pbd_InRec ,	char **pbd_InRec_Cur);  

int n_InitGT_R			(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLigneGT_R	(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncGT_R	(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_FilsSansPere_R(  char **ptb_InRecChild);

char	Ksz_CUR_CF[4]; /* monnaie du contrat de ratachement */

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* ouverture des fichiers */
	if ( n_OpenFileAppl ("ESTC2037_I3","rb",&Kp_CoursFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2037_O1","wt",&Kp_GT_D_Fil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2037_O2","wt",&Kp_GT_C_Fil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible bd_RuptGT_N */
	if ( n_InitGT_N(&bd_RuptGT_N) )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible bd_RuptGT_R */
	if ( n_InitGT_R(&bd_RuptGT_R) )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar (&bd_RuptGT_N) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2037_I1",&(bd_RuptGT_N.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2037_I2",&(bd_RuptGT_R.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2037_I3",&Kp_CoursFil))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2037_O1",&Kp_GT_D_Fil))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC2037_O2",&Kp_GT_C_Fil))
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(0) ;

}

/*==============================================================================
objet :
	Initialisation de la gestion de repture du fichier des mouvements non criblés

retour :
	0
==============================================================================*/
int n_InitGT_N(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT_N");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

	if ( n_OpenFileAppl ("ESTC2037_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)	
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 2;

	pbd_Rupt->n_ConditionRupture[0]=n_IsR1GT_N	;
	pbd_Rupt->n_ConditionRupture[1]=n_IsR2GT_N	;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_Rupt->n_ActionLigne   	= n_ActionLigneGT_N ;


	/* fonction d'action en rupture première de niveau 1*/
	pbd_Rupt->n_ActionFirst[0] 	= n_ActionFirstCSAC ;


	/* fonction d'action en rupture première de niveau 2*/
	pbd_Rupt->n_ActionFirst[1] 	= n_ActionFirstCSACP ;

	/* fonction d'action en rupture derniere de niveau 2*/
	pbd_Rupt->n_ActionLast [1]  = n_ActionLastCSACP ;


	pbd_Rupt->c_Separ       	= SEPARATEUR ;

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du 
	fichier maitre, celui des traites de rattachement.

retour :
	0
==============================================================================*/
int n_InitGT_R(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT_R");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

	if ( n_OpenFileAppl ("ESTC2037_I2","rt",&(pbd_Rupt->pf_InputFil))==ERR)
		RETURN_VAL (ERR);

	pbd_Rupt->n_NbRupture = 0  ;

	pbd_Rupt->n_ActionLigne = n_ActionLigneGT_R ;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync	= n_ConditionSyncGT_R ;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_Rupt->n_FilsSansPere	= n_FilsSansPere_R ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de rupture au niveau CTR/SEC/ACY 

retour :
	0 ---> synchro
	sinon, non trouve
==============================================================================*/
int n_IsR1GT_N(	char **pbd_InRec ,	char **pbd_InRec_Cur	)
{
	int ret;

	DEBUT_FCT("n_IsR1GT_N");


	if ((ret=strcmp(pbd_InRec[GT_ESTCTR_NF],
			pbd_InRec_Cur[GT_ESTCTR_NF]))!=0)
	RETURN_VAL (ret);

	if ((ret=strcmp(pbd_InRec[GT_ESTSEC_NF],
			pbd_InRec_Cur[GT_ESTSEC_NF]))!=0)
	RETURN_VAL (ret);

	if ((ret=strcmp(pbd_InRec[GT_ACY_NF],
			pbd_InRec_Cur[GT_ACY_NF]))!=0)

	RETURN_VAL (ret);

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de rupture au niveau CTR/SEC/ACY/POSTE 

retour :
	0 ---> synchro
	sinon, non trouve
==============================================================================*/
int n_IsR2GT_N(	char **pbd_InRec ,	char **pbd_InRec_Cur  
	)
{
	int ret;

	DEBUT_FCT("n_IsR2GT_N");

	if ((ret=strcmp(pbd_InRec[GT_ACMTRS_NT],
			pbd_InRec_Cur[GT_ACMTRS_NT]))!=0)
		RETURN_VAL (ret);

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de synchro

retour :
	0 ---> synchro
	sinon, non trouve
==============================================================================*/
int n_ConditionSyncGT_R(
	char **pbd_InRecOwner ,/* adresse de la ligne du maitre	*/
	char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
	)
{
	int ret;

	DEBUT_FCT("n_ConditionSyncGT_N");

	if ((ret=strcmp(pbd_InRecOwner[GT_ESTCTR_NF],
			pbd_InRecChild[GT_CTR_NF]))!=0)
	RETURN_VAL (ret);

	if ((ret=strcmp(pbd_InRecOwner[GT_ESTSEC_NF],
			pbd_InRecChild[GT_SEC_NF]))!=0)
	RETURN_VAL (ret);

	if ((ret=strcmp(pbd_InRecOwner[GT_ACY_NF],
			pbd_InRecChild[GT_UWY_NF]))!=0)
	RETURN_VAL (ret);

	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction lancee en repture premiere du maitre (ctr/sec/ACY) pour aller
	chercher la monnaie du contrat de ratachement

retour :
	0 ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstCSAC( char **ptb_InRec_Cur)
{
	/* Synchronisation des mouvements non-cribles */
	n_ProcessingRuptureSyncVar(&bd_RuptGT_R, ptb_InRec_Cur);

}
/*==============================================================================
objet :
	fonction lancee en repture premiere du maitre (ctr/sec/ACY/poste )

retour :
	0 ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstCSACP( char **ptb_InRec_Cur)
{
	/* Initialisation du total et de l'AS */
	Kb_AS=1;
	Kf_total=0 ;
}

/*==============================================================================
objet :
	fonction lancee en repture derniere du maitre (ctr/sec/ACY/poste )

retour :
	0 ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastCSACP( char **ptb_InRec_Cur)
{
	char sz_total[25];	/* Montant cumule */
	char	 sz_AS[2];	/* Indicateur arrete statistique */




	/* Reconduction du traite fictif avec le montant mis a jour */
	sprintf(sz_total,"%18.3lf",Kf_total);
    ptb_InRec_Cur[GT_ESTAMT_M]	=sz_total;

	sprintf(sz_AS,"%d",Kb_AS);
    ptb_InRec_Cur[GT_COMACC_B]	=sz_AS;

	ptb_InRec_Cur[GT_CTR_NF]	=ptb_InRec_Cur[GT_ESTCTR_NF];
	ptb_InRec_Cur[GT_SEC_NF]	=ptb_InRec_Cur[GT_ESTSEC_NF];
	ptb_InRec_Cur[GT_UWY_NF]	=ptb_InRec_Cur[GT_ACY_NF];


	/* Ecriture du traite non-crible en sortie */
	ptb_InRec_Cur[GT_AMT_M]   ="";
	ptb_InRec_Cur[GT_SCOEGP_M]="";


	n_WriteCols(Kp_GT_C_Fil,ptb_InRec_Cur,SEPARATEUR,0);
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du maitre 

retour :
	0 ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT_N( char **ptb_InRec_Cur)
{
	double f_montant,f_aliment,f_taux;
	static char   sz_montant[25],sz_aliment[25];

	DEBUT_FCT("n_ActionLigneGT_R");


	/* Controle de l'AS */
	if (ptb_InRec_Cur[GT_COMACC_B][0]=='0') Kb_AS=0;


	/* Calcul du taux de conversion */
	f_taux=d_GetTaux(Kp_CoursFil,
						(char) atoi(ptb_InRec_Cur[GT_SSD_CF]),
						(short)atoi(ptb_InRec_Cur[GT_BALSHEY_NF]),
						ptb_InRec_Cur[GT_ESTCUR_CF],
						Ksz_CUR_CF);

	ptb_InRec_Cur[GT_ESTCUR_CF]= Ksz_CUR_CF;

	/* Conversion du montant */
	f_montant=atof(ptb_InRec_Cur[GT_ESTAMT_M])*f_taux;

	/* Conversion de l'aliment */
	f_aliment=atof(ptb_InRec_Cur[GT_SCOEGP_M])*f_taux;

	/* Cumul du montant converti */
	Kf_total+=f_montant;

	/* Controle de l'AS */
	if (ptb_InRec_Cur[GT_COMACC_B][0]=='0') Kb_AS=0;

	/* Ecriture du traite non-crible en sortie */
	sprintf(sz_montant,"%18.3lf",f_montant);
	ptb_InRec_Cur[GT_ESTAMT_M]   =sz_montant;

	sprintf(sz_aliment,"%18.3lf",f_aliment);
	ptb_InRec_Cur[GT_SCOEGP_M]=sz_aliment;

	n_WriteCols(Kp_GT_D_Fil,ptb_InRec_Cur,SEPARATEUR,0);

	RETURN_VAL (0);
}



/*==============================================================================
objet :
	fonction lancee pour chaque ligne du mouvement de ratacchement pour 
	sauvegarder la monnaie.
	

retour :
	0 ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT_R(
	char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
	char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
	double f_montant,f_aliment,f_taux;
	char   sz_montant[25],sz_aliment[25];
	int	Kn_annee;	/* Annee d'inventaire pour le cours devise */

	DEBUT_FCT("n_ActionLigneGT_N");

	strcpy(Ksz_CUR_CF,ptb_InRecChild[GT_ESTCUR_CF]);


	RETURN_VAL (OK);
}

/*==============================================================================
objet :
	fonction lancee quand un mouvement de rattachement n'a pas de mouvements 
	non correspondants 

retour :
	0K ----> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_FilsSansPere_R(
	char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{

	DEBUT_FCT("n_FilsSansPere_R");


	n_WriteCols(Kp_GT_C_Fil,ptb_InRecChild,SEPARATEUR,0);

	RETURN_VAL (OK);
}

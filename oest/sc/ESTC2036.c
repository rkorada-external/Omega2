/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Prise en compte des AS pour les mvts comptables
nom du source                 : ESTC2036.c
revision                      : $Revision:   1.0  $
date de creation              : 17/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
<11/06/2001>		ANB		Modif prise en cpte AS pour la rétro (cela ne dépend 
plus que autupd_b car on force comacc_b = 1)	
[001] 08/12/2015 S.Behague :spot:29253 Ajout ESTCRB A et E
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

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE					*Kp_GT_N_Fil,	// pointeur sur le GT "N" en sortie
						*Kp_GT_R_Fil,	// pointeur sur le GT "R" en sortie
						*Kp_GT_OS_Fil;	// pointeur sur le GT "O/S" en sortie

T_RUPTURE_VAR			bd_RuptGT;		// gestion rupture sur GT

T_RUPTURE_SYNC_VAR		bd_RuptCmpl,	// gestion synchro comptes complets-GT
						bd_RuptMth;		// gestion synchro Mois fin periode - GT

int						Kn_annee;		// Derniere annee de compte statistiquee, 0 si NULL
int						Kn_anneeQ;		// Derniere annee de compte statistiquee, 0 si NULL
int						Kn_month;		// last month complet year statistic

char					Kc_crible;		// Code crible

int						Kb_SyncCmpl,	// Indicateur de synchro. des comptes complets
						Kb_SyncCmplQ,
						Kb_AR,			// 1 si acceptation, 2 si retrocession
						Kb_COMACC_B,	// Indicateur arrete statistique
						Kb_PropagRes;	// Indicateur propagation réserve

char					Ksz_Mois[3];	// Mois de fin de periode


int n_InitCmpl(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLigneCmpl(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ConditionSyncCmpl(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_InitMth(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_IsR1Mth(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptMth(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ConditionSyncMth(char **ptb_InRecOwner, char **pbd_InRecChild);

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneGT(char **pbd_InRec_Cur);
int n_IsR1GT(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptGT(char **ptb_InRec_Cur);

/*==============================================================================
objet :
point d'entree du programme

retour :
En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
	// Initialisation des signaux
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
		ExitPgm(ERR_XX, "");
	// ouverture des fichiers en sortie
	if (n_OpenFileAppl("ESTC2036_O1","wt",&Kp_GT_N_Fil) == ERR )
		ExitPgm(ERR_XX, "");

	if (n_OpenFileAppl("ESTC2036_O2", "wt", &Kp_GT_R_Fil) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_OpenFileAppl("ESTC2036_O3", "wt", &Kp_GT_OS_Fil) == ERR)
		ExitPgm (ERR_XX, "");
	// Initialisation de la varible bd_RuptGT

	if (n_InitGT(&bd_RuptGT))
		ExitPgm(ERR_XX, "");
	// Initialisation de la varible bd_RuptCmpl

	if (n_InitCmpl(&bd_RuptCmpl))
		ExitPgm(ERR_XX, "");
	// Initialisation de la varible bd_RuptMth

	if (n_InitMth(&bd_RuptMth))
		ExitPgm(ERR_XX, "");
	// lancement du traitement du fichier

	if (n_ProcessingRuptureVar(&bd_RuptGT) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_I1", &(bd_RuptGT.pf_InputFil)))
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_I2", &(bd_RuptCmpl.pf_InputFil)))
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_I3", &(bd_RuptMth.pf_InputFil)))
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_O1", &Kp_GT_N_Fil))
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_O2", &Kp_GT_R_Fil))
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2036_O3", &Kp_GT_OS_Fil))
		ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX, "");
	exit(0);
}

/*==============================================================================
objet :
fonction d'initialisation de la variable de gestion de rupture du 
fichier maitre.

retour :
0
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2036_I1", "rt", &(pbd_Rupt->pf_InputFil)))
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGT;
	pbd_Rupt->n_ActionLigne = n_ActionLigneGT;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction de test de rupture du niveau 1

retour :
0   ---> Pas de rupture
1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1GT");
	if (strcmp(ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF]) != 0)
		RETURN_VAL(1);
	RETURN_VAL(0);
}

/*==============================================================================
objet :
Fonction lancee a chaque rupture premiere sur contrat
==============================================================================*/
int n_ActionFirstRuptGT(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptGT");
	// On n'a pas encore trouve de compte complet OK
	Kb_SyncCmpl = 0;
	Kb_SyncCmplQ = 0;
	// valeur par defaut de Kn_annee
	Kn_annee = 0;
	Kn_anneeQ = 0;
	// Valeur par defaut de l'AS:
	Kb_COMACC_B = 0;
	// Acceptation ou retrocession ?
	// if (ptb_InRec_Cur[GT_ESTCRB_CT][0]==0 || ptb_InRec_Cur[GT_ESTCRB_CT][0]==' ') Kb_AR=0; else Kb_AR=1;
	if (ptb_InRec_Cur[GT_TRNCOD_CF][0] == '2' || ptb_InRec_Cur[GT_TRNCOD_CF][0] == '4')
		Kb_AR=0;
	else
		Kb_AR = 1;
	// Si Acceptation
	if (Kb_AR == 1)
	{
		// Recherche de la ligne correspondante dans les comptes complets
		n_ProcessingRuptureSyncVar(&bd_RuptCmpl, ptb_InRec_Cur);
	}
	else // Retrocession
	{
		Ksz_Mois[0] = 0; 
		// Recherche du mois de fin de periode de ce contrat
		n_ProcessingRuptureSyncVar(&bd_RuptMth, ptb_InRec_Cur);

		/*
 		** Si le dernier compte envoye correspond a une fin de periode,
		** le contrat est en AS
		*/
		// if (atoi(Ksz_Mois)==12) Kb_COMACC_B=1;
	}
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction lancee pour chaque ligne du maitre

retour :
0 ----> traitement correctement effectue
ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
	char sz_COMACC_B[2];
	char sz_PROPAGRES[2];

	DEBUT_FCT("n_ActionLigneGT");
	// Memorisation du code crible
	Kc_crible = ptb_InRec_Cur[GT_ESTCRB_CT][0];
	// On complete le GT avec le dernier mois
	ptb_InRec_Cur[GT_LSTENDMTH_NF] = Ksz_Mois;
	sprintf(sz_PROPAGRES, "%d", 0);
	ptb_InRec_Cur[GT_PROPAGRES_B] = sz_PROPAGRES ; // Nouveau Champ pour utilisation dans le ESTC2038 
	// Si acceptation
	if (Kb_AR == 1)
	{
		//printf("test crible ");
		//printf("%s\n", ptb_InRec_Cur[GT_ESTCRB_CT]);
		if (Kc_crible == 'T' || Kc_crible == 'U')
		{
			//if (strcmp(ptb_InRec_Cur[GT_CTR_NF], "14T001458") == 0)
			//	printf("sync => [%d]\nmounth => [%s]\nKn_mounth => [%d]\ncrible => [%s]\nyear => [%s]\nKn_annee => [%d]\n\n", Kb_SyncCmplQ, ptb_InRec_Cur[74], Kn_month, ptb_InRec_Cur[GT_ESTCRB_CT], ptb_InRec_Cur[GT_ACY_NF], Kn_annee);
			if (Kb_SyncCmplQ == 1 && atoi(ptb_InRec_Cur[74]) <= Kn_month && atoi(ptb_InRec_Cur[GT_ACY_NF]) <= Kn_anneeQ)
				Kb_COMACC_B = 1;
			else
				Kb_COMACC_B = 0;
		}
		else if ((Kc_crible == 'O') || (Kc_crible == 'N') || (Kc_crible == 'A') || (Kc_crible == 'E')) // [001]
		{
			/*
 			** Si les comptes complets sont synchronises et si
			** annee de compte > derniere Ac statistiquee, AS=non
 			*/
			if ((Kb_SyncCmpl == 1) && (atoi(ptb_InRec_Cur[GT_ACY_NF]) <= Kn_annee))
			{
				Kb_COMACC_B = 1;
				sprintf(sz_PROPAGRES, "%d", Kb_PropagRes);
				ptb_InRec_Cur[GT_PROPAGRES_B] = sz_PROPAGRES; // Nouveau Champ pour utilisation dans le ESTC2038
			}
			else
				Kb_COMACC_B = 0;
		}
		// Pour les autres cribles, on prend l'AS du GT
		else
			Kb_COMACC_B = atoi(ptb_InRec_Cur[GT_COMACC_B]);
	}
	else	// retrocession
	{
		Kb_COMACC_B = 1;
	}
	// Reconduction du GT en sortie
	// Ecriture du GT
	sprintf(sz_COMACC_B, "%d", (int)Kb_COMACC_B);
	ptb_InRec_Cur[GT_COMACC_B] = sz_COMACC_B ;
	// Choix du fichier de sortie
	switch (Kc_crible)
	{
		case 'N':
			n_WriteCols(Kp_GT_N_Fil, ptb_InRec_Cur, SEPARATEUR, 0);
			break;
		case 'R':
			n_WriteCols(Kp_GT_R_Fil, ptb_InRec_Cur, SEPARATEUR, 0);
			break;
		default:
			n_WriteCols(Kp_GT_OS_Fil, ptb_InRec_Cur, SEPARATEUR, 0);
			break;
	}
	RETURN_VAL (0);
}

/*==============================================================================
objet :
Initialisation de la synchronisation du maitre avec l'esclave Cmpl

retour :
0
==============================================================================*/
int n_InitCmpl(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitCmpl");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2036_I2", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	// fonction du test de la ligne du maitre avec l'esclave
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCmpl;
	// fonction d'action sur la ligne courante du fichier esclave
	pbd_Rupt->n_ActionLigne = n_ActionLigneCmpl;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction de test de synchro

retour :
0 ---> synchro
sinon, non trouve

discribe:
pbd_InRecOwner -> adresse de la ligne du maitre
pbd_InRecChild -> adresse de la ligne de l'esclave
==============================================================================*/
int n_ConditionSyncCmpl(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT("n_ConditionSyncCmpl");
	Kb_SyncCmpl = 0;
	Kb_SyncCmplQ = 0;
	if ((ret = strcmp(pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[CMP_CTR_NF])) != 0)
		RETURN_VAL(ret);
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction lancee pour chaque ligne des comptes complets synchronisee
avec le GT

retour :
0 ----> traitement correctement effectue
ERR --> probleme rencontre

parameter:
pbd_InRecOwner -> adresse de la ligne du maitre
pbd_InRecChild -> adresse de la ligne de l'esclave
==============================================================================*/
int n_ActionLigneCmpl(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionLigneCmpl");

	/*
	** On considere que les comptes complets sont synchro si
	** et seulement si le mois de fin de periode est 12.  On
	** memorise alors l'annee de compte correspondante comme
	** derniere annee de compte statistique
	*/
//	printf("in action cplacc => [%s]\n", ptb_InRecOwner[GT_ESTCRB_CT]);
//	printf("ctr_nf cplacc => [%s]\n", ptb_InRecChild[CMP_CTR_NF]);
//	printf(" cplacc => [%s]\n", ptb_InRecChild[CMP_CTR_NF]);
	Kn_month = atoi(ptb_InRecChild[CMP_SCOENDMTH_NF]);
//	printf("quarter in cplacc\n");
	Kb_SyncCmplQ = 1;
	Kn_anneeQ = atoi(ptb_InRecChild[CMP_ACY_NF]);
	Kb_PropagRes = atoi(ptb_InRecChild[CMP_PROPAGRES_B]);
	if (atoi(ptb_InRecChild[CMP_SCOENDMTH_NF]) == 12)
	{
		/*
		** Si on ne trouve pas de mois 12, la fonction principale
		** considerera qu'il n'y a pas eu synchro. Sinon, toutes
		** les lignes a 12 passeront par ici et on obtiendra bien
		** l'annee la plus recente puisque le tri est croissant.
		*/
		Kb_SyncCmpl = 1;
		Kn_annee = atoi(ptb_InRecChild[CMP_ACY_NF]);
		Kb_PropagRes = atoi(ptb_InRecChild[CMP_PROPAGRES_B]);
	}
	RETURN_VAL (0);
}

/*==============================================================================
objet :
Initialisation de la synchronisation du maitre avec l'esclave Mth

retour :
0
==============================================================================*/
int n_InitMth(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitMth");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2036_I3", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	// fonction du test de la ligne du maitre avec l'esclave
	pbd_Rupt->ConditionEndSync = n_ConditionSyncMth ;
	// fonction d'action en rupture derniere sur le contrat
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Mth;
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptMth;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction de test de synchro

retour :
0 ---> synchro
sinon, non trouve

parameter:
pbd_InRecOwner -> adresse de la ligne du maitre
pbd_InRecChild -> adresse de la ligne de l'esclave
==============================================================================*/
int n_ConditionSyncMth(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;

	DEBUT_FCT("n_ConditionSyncMth");
	if ((ret = strcmp(pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[MTH_RETCTR_NF])) != 0)
		RETURN_VAL (ret);
	RETURN_VAL (0);
}

/*==============================================================================
objet :
fonction de test de rupture du niveau 1

retour :
0   ---> Pas de rupture
1   ---> rupture
==============================================================================*/
int n_IsR1Mth(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1GT");
	if (strcmp(ptb_InRec[MTH_RETCTR_NF], ptb_InRec_Cur[MTH_RETCTR_NF]) != 0)
		RETURN_VAL(1);
	RETURN_VAL(0);
}

/*==============================================================================
objet :
fonction lancee pour la derniere ligne du contrat

retour :
0 ----> traitement correctement effectue
ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptMth(char **ptb_InRecOwner,char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionLastRuptMth");
	strcpy(Ksz_Mois, ptb_InRecChild[MTH_LSTENDMTH_NF]);
	Kn_month = atoi(ptb_InRecOwner[74]);
	Kn_annee = atoi(ptb_InRecChild[ MTH_RETACCYER_NF]);
	RETURN_VAL(0);
}

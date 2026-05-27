/*==============================================================================
nom de l'application          : Vérification de la LOB du contrat
nom du source                 : ESTC2052.c
revision                      : 
date de creation              : 18/09/2018
auteur                        : S.Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
				Vérification des LOB du contrat sur contrat/section du fichier estimation
				Si un exercice n'existe pas, la LOB du dernier exercice/section est postionné dans le fichier d'estimations


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
[001] 18/09/2018 SBE  spira:61671: Omega to SAP June simulation. Creation des postes prefixe 1 sur des sections Vie

*/


/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


static char VERSION_ESTC2052_C[100] = "ESTC2052.c version [001] - Spira 61671" ;


FILE    *Kp_PrevOutPutFile;		/* Pointeur sur le fichier de sortie */

T_RUPTURE_VAR           bd_RuptPeri;    /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR      bd_RuptPrev;     /* gestion rupture sur prevision */


/* Initialisation perimetre Pere */
int n_InitPerimPere	     		(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionFirstRuptPeri		(char **pbd_InRec_Cur);
int n_ConditionRuptPeri 		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePeri           (char **pbd_InRec_Cur);

/* Initialisation prevision fils */
int n_InitSyncPrev       		(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPrev  		(char **ptb_InRec_Peri, char **ptb_InRec_Prev);
int n_ActionPrevSansPeri 		(char **ptb_InRec_Prev);
int n_ActionLignePrev    		(char **ptb_InRec_Peri, char **ptb_InRec_Prev);


/* Variables Globales */
char 	LOB_CF[3]="XX";



/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );
	// Ouverture des fichiers

	if (n_OpenFileAppl("ESTC2052_O1", "wt", &Kp_PrevOutPutFile) == ERR) ExitPgm(ERR_XX, "");

	if (n_InitPerimPere(&bd_RuptPeri) == ERR) ExitPgm(ERR_XX, "");
	if (n_InitSyncPrev(&bd_RuptPrev) == ERR) ExitPgm(ERR_XX, "");


	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&bd_RuptPeri) == ERR) ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2052_O1", &Kp_PrevOutPutFile) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2052_I1", &(bd_RuptPeri.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2052_I2", &(bd_RuptPrev.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}


/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier perimetre.
==============================================================================================*/
int n_InitPerimPere(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerimPere");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl ("ESTC2052_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPeri;
	pbd_Rupt->n_ActionLigne         = n_ActionLignePeri;
	pbd_Rupt->n_ActionFirst[0] 		= n_ActionFirstRuptPeri;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptPeri(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPeri");

	if ((ret = strcmp(pbd_InRec[PER_CTR_NF],  pbd_InRec_Cur[PER_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_SEC_NF],  pbd_InRec_Cur[PER_SEC_NF])) != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionFirstRuptPeri(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPeri");

	// Sauvegarde de la LOB de l'exercice le plus récent pour la remettre sur les exerices absents du périmètre
	strcpy(LOB_CF, ptb_InRec_Cur[PER_LOB_CF]);

	RETURN_VAL (OK);
}

/*==============================================================================
objet :     fonction lancee pour chaque ligne du perimetre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePeri(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePeri");

	n_ProcessingRuptureSyncVar(&bd_RuptPrev, ptb_InRec_Cur);

	RETURN_VAL (0);
}

/*============================================================================================
objet : fonction d'initialisation de la variable de gestion de synchro/rupture du fichier prevision.
============================================================================================*/
int n_InitSyncPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitSyncPrev");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl("ESTC2052_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 0;
	pbd_Rupt->ConditionEndSync 		= n_ConditionSyncPrev;
	pbd_Rupt->n_ActionLigne 		= n_ActionLignePrev;
	pbd_Rupt->n_FilsSansPere        = n_ActionPrevSansPeri;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet : Condition de synchronisation des prévisions avec le périmetre
==============================================================================*/
int n_ConditionSyncPrev(char **ptb_InRec_Peri, char **ptb_InRec_Prev)
{
	int ret = 0;
	DEBUT_FCT("n_ConditionSyncPrev");

	if ((ret = strcmp(ptb_InRec_Peri[PER_CTR_NF] , ptb_InRec_Prev[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Peri[PER_SEC_NF] , ptb_InRec_Prev[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Peri[PER_UWY_NF] , ptb_InRec_Prev[PRE_UWY_NF])) != 0) RETURN_VAL(-ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Peri, char **ptb_InRec_Prev)
{
	DEBUT_FCT("n_ActionLignePrev");

	// On reecrit tel quel la ligne en sortie
	n_WriteCols(Kp_PrevOutPutFile,ptb_InRec_Prev,SEPARATEUR,0);

	RETURN_VAL(OK);
}
/*==============================================================================
objet : fonction lancée pour chaque ligne prévision sans périmètre
==============================================================================*/
int n_ActionPrevSansPeri(char **ptb_InRec_Prev)
{
	DEBUT_FCT("n_ActionFilsSansPere");

	// On recopie la LOB sauvegardée dans la ligne en fils sans pere (pas de perimetre)
	strcpy(ptb_InRec_Prev[PRE_LOB_CF],LOB_CF);

	n_WriteCols(Kp_PrevOutPutFile,ptb_InRec_Prev,SEPARATEUR,0);

	RETURN_VAL(OK);
}
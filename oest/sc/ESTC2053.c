/*==============================================================================
nom de l'application          : Correction de la génération des réserves à propager
nom du source                 : ESTC2053
revision                      : 
date de creation              : 05/10/2018
auteur                        : S.Behague
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
			Correction de la génération des réserves à propager. Verification des types comptable, type de postes


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>>   <auteur>>    <description de la modification>>
           ...           ...            ...              ...
[001] 05/10/2018 SBE  spira:30649: Batch: Fixed - INCIDENT IN RESERVES PROPAGATION FROM TAC AFTER COMPLETE ACCOUNT

*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
static char VERSION_ESTC2053_C[100] = "ESTC2053 version [001] - Spira 30649 ";


FILE    *Kp_OutPutFile;		/* Pointeur sur le fichier de sortie */

T_RUPTURE_VAR           bd_RuptPerimetre;    /* gestion rupture sur pere */
T_RUPTURE_SYNC_VAR      bd_RuptPrevision;    /* gestion rupture sur fils */

int n_ACCADMTYP;
char *sz_LastUWY;

/* Initialisation Pere */
int n_InitPerimetre	     		(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionFirstRuptPerimetre		(char **pbd_InRec_Cur);
int n_ActionFirstRuptSecPerimetre		(char **pbd_InRec_Cur);
int n_ConditionRuptPerimetre 		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ConditionRuptSecPerimetre 		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePerimetre           (char **pbd_InRec_Cur);

/* Initialisation fils */
int n_InitSyncPrevision       		(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPrevision  		(char **ptb_InRec_Perimetre, char **ptb_InRec_Prevision);
int n_ActionPrevisionSansPerimetre 		(char **ptb_InRec_Prevision);
int n_ActionLignePrevision    		(char **ptb_InRec_Perimetre, char **ptb_InRec_Prevision);

void TraiteReserve( char **ptb_InRec_Prevision);

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    /* Initialisation des signaux */

    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );

	if (n_OpenFileAppl("ESTC2053_O1", "wt", &Kp_OutPutFile) == ERR) ExitPgm(ERR_XX, "");
	if (n_InitPerimetre(&bd_RuptPerimetre) == ERR) ExitPgm(ERR_XX, "");
	if (n_InitSyncPrevision(&bd_RuptPrevision) == ERR) ExitPgm(ERR_XX, "");

	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&bd_RuptPerimetre) == ERR) ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2053_O1", &Kp_OutPutFile) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2053_I1", &(bd_RuptPerimetre.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2053_I2", &(bd_RuptPrevision.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}

/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier Pere.
==============================================================================================*/
int n_InitPerimetre(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerimetre");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl ("ESTC2053_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture           = 2;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPerimetre;
	pbd_Rupt->n_ConditionRupture[1] = n_ConditionRuptSecPerimetre;
	pbd_Rupt->n_ActionLigne         = n_ActionLignePerimetre;
	pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptPerimetre;
	pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRuptSecPerimetre;
	pbd_Rupt->c_Separ               = SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptPerimetre(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPerimetre");

	if ((ret = strcmp(pbd_InRec[PER_CTR_NF],  pbd_InRec_Cur[PER_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_SEC_NF],  pbd_InRec_Cur[PER_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_UWY_NF],  pbd_InRec_Cur[PER_UWY_NF])) != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptSecPerimetre(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPerimetre");

	if ((ret = strcmp(pbd_InRec[PER_CTR_NF],  pbd_InRec_Cur[PER_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_SEC_NF],  pbd_InRec_Cur[PER_SEC_NF])) != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionFirstRuptPerimetre(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPerimetre");

	n_ACCADMTYP=atoi(ptb_InRec_Cur[PER_ACCADMTYP_CT]);

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionFirstRuptSecPerimetre(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstRuptPerimetre");

	/* On est trié en ordre décroissant sur l'exercice. Pour le contrat on rencontre donc le dernier exercice valide */
	sz_LastUWY=ptb_InRec_Cur[PER_UWY_NF];

	RETURN_VAL (OK);
}


/*==============================================================================
objet :     fonction lancee pour chaque ligne du pere
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerimetre(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePerimetre");

	n_ProcessingRuptureSyncVar(&bd_RuptPrevision, ptb_InRec_Cur);

	RETURN_VAL (0);
}

/*============================================================================================
objet : fonction d'initialisation de la variable de gestion de synchro/rupture du fichier fils.
============================================================================================*/
int n_InitSyncPrevision (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitSyncPrevision");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl("ESTC2053_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 0;
	pbd_Rupt->ConditionEndSync 		= n_ConditionSyncPrevision;
	pbd_Rupt->n_ActionLigne 		= n_ActionLignePrevision;
	pbd_Rupt->n_FilsSansPere        = n_ActionPrevisionSansPerimetre;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet : Condition de synchronisation du fils avec le pere
==============================================================================*/
int n_ConditionSyncPrevision(char **ptb_InRec_Perimetre, char **ptb_InRec_Prevision)
{
	int ret = 0;
	DEBUT_FCT("n_ConditionSyncPrevision");

	if ((ret = strcmp(ptb_InRec_Perimetre[PER_CTR_NF] , ptb_InRec_Prevision[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Perimetre[PER_SEC_NF] , ptb_InRec_Prevision[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Perimetre[PER_UWY_NF] , ptb_InRec_Prevision[PRE_UWY_NF])) != 0) RETURN_VAL(-ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLignePrevision(char **ptb_InRec_Perimetre, char **ptb_InRec_Prevision)
{
	DEBUT_FCT("n_ActionLignePrevision");

	TraiteReserve(ptb_InRec_Prevision);

	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction lancée pour chaque ligne fils sans pere
==============================================================================*/
int n_ActionPrevisionSansPerimetre(char **ptb_InRec_Prevision)
{
	DEBUT_FCT("n_ActionPrevisionSansPerimetre");

	/* Test du type. Si type 4 on remplace l'exercice de la ligne prévision par le dernier exercice du contrat */
	if ( n_ACCADMTYP == 4 )
	{
		ptb_InRec_Prevision[PRE_UWY_NF] = sz_LastUWY;
	}

	TraiteReserve(ptb_InRec_Prevision);

	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction qui traite les actions à effectuer sur chaque ligne de reserve
		en fonction du type comptable, type de poste réserve
==============================================================================*/
void TraiteReserve( char **ptb_InRec_Prevision)
{
	char sz_dettrncod[3]="XX";

	DEBUT_FCT("TraiteReserve");
	

	if ( n_ACCADMTYP == 4 || n_ACCADMTYP == 1 )
	{
		n_WriteCols(Kp_OutPutFile,ptb_InRec_Prevision,SEPARATEUR,0);
	}

	strncpy(sz_dettrncod, ptb_InRec_Prevision[PRE_DETTRNCOD_CF], 2);

	if ( n_ACCADMTYP == 5 || n_ACCADMTYP == 3 )
	{
		if ( strcmp(sz_dettrncod, "42") != 0 )
		{
			n_WriteCols(Kp_OutPutFile,ptb_InRec_Prevision,SEPARATEUR,0);
		}
	}
	/* Si type comptable est égal à 2, on ne reconduit pas la ligne de réserve, on ne propage pas pour les type 2 */

}

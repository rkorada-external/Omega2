/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/* DESCRIPTION
[001] 12/02/2019 S.Behague     :REQ.L.02.05: Evolution quarterly
*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


/* Variables de travail */
FILE		*Kp_LifestOFil;						//Fichier Reserve

T_RUPTURE_VAR       bd_RuptReservePere;         // gestion rupture sur GT
T_RUPTURE_SYNC_VAR  bd_RuptPrevisionFils;       // gestion synchro c. previsions-GT

/* Variables Globales  */
int Kb_SyncPrev;

char Ksz_DateJour[11];           				// Date de traitement


// Fonction de synchronisation
int n_InitReserve (T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1Reserve (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLastRuptReserve ( char **ptb_InRec_Cur);

int n_InitPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPrev(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionReserveSansPrev (char **ptb_InRec);
int n_ActionPrevSansReserve (char **ptb_InRec);
int n_ActionLignePrev (char **ptb_InRecOwner, char **ptb_InRecChild);

// Fonctions utilitaires
void CreationLigne (double d_Montant,char **ptb_InRec);


/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )                                      ExitPgm ( ERR_XX , "" );

    // Recuperation des parametres
    strcpy(Ksz_DateJour, psz_GetCharArgv(1));

    // Ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2044_O1","wt",&Kp_LifestOFil) == ERR )            ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptGT
    if ( n_InitReserve(&bd_RuptReservePere) )                                   ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptPrev
    if ( n_InitPrev(&bd_RuptPrevisionFils) )                                    ExitPgm ( ERR_XX , "" );

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptReservePere) == ERR )                  ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2044_O1",&Kp_LifestOFil))                         ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2044_I1",&(bd_RuptReservePere.pf_InputFil)))      ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2044_I2",&(bd_RuptPrevisionFils.pf_InputFil)))    ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                   ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier Reserve.
retour :    0
============================================================================================*/
int n_InitReserve (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitReserve");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2044_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Reserve;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptReserve;

	//Pas utile pour le moment
    //pbd_Rupt->n_ActionLigne = n_ActionLigneReserve ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);	
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Reserve(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1Reserve");
	
	if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)           		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)           		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)           		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)           		RETURN_VAL(1);
    if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)           RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0) 	RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_GAAP_NF],ptb_InRec_Cur[PRE_GAAP_NF])!=0)           	RETURN_VAL(1);

	RETURN_VAL (0);
}

/*==============================================================================
objet :     Fonction lancee a chaque rupture derniere sur contrat/sec/uwy/ACY
==============================================================================*/
int n_ActionLastRuptReserve ( char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastRuptReserve");

	/* Synchronisation des previsions */
	Kb_SyncPrev=0;
	n_ProcessingRuptureSyncVar(&bd_RuptPrevisionFils, ptb_InRec_Cur);

	RETURN_VAL(0);
}


/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier prevision.
retour :    0
==============================================================================================*/
int n_InitPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitPrev");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier previsions */
    n_OpenFileAppl ("ESTC2044_I2","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture = 0;

    /* fonction du test de la ligne des reserves avec les previsions */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncPrev;

    /* fonction d'action quand le reserve est seul */
    pbd_Rupt->n_PereSansFils = n_ActionReserveSansPrev;
    
    /* fonction d'action quand les previsions sont seules */
    pbd_Rupt->n_FilsSansPere = n_ActionPrevSansReserve;

    /* fonction d'action sur la ligne courante du fichier previsions */
    pbd_Rupt->n_ActionLigne = n_ActionLignePrev;
    
    pbd_Rupt->c_Separ = '~';

  	RETURN_VAL (0);	
}

/*==============================================================================
objet :     fonction de test de synchro
retour :    0 ---> synchro
            sinon, non trouve
==============================================================================*/
/* adresse de la ligne du Reserve *//* adresse de la ligne des previsions */
int n_ConditionSyncPrev(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;
	
  	DEBUT_FCT("n_ConditionSyncPrev");
  	
  	if ((ret=strcmp(pbd_InRecOwner[PRE_CTR_NF],  pbd_InRecChild[PRE_CTR_NF]))!=0)       			RETURN_VAL (ret);
  	if ((ret=strcmp(pbd_InRecOwner[PRE_SEC_NF],  pbd_InRecChild[PRE_SEC_NF]))!=0)       			RETURN_VAL (ret);
  	if ((ret=strcmp(pbd_InRecOwner[PRE_UWY_NF],  pbd_InRecChild[PRE_UWY_NF]))!=0)       			RETURN_VAL (ret);
  	if ((ret=strcmp(pbd_InRecOwner[PRE_ACY_NF],  pbd_InRecChild[PRE_ACY_NF]))!=0)       			RETURN_VAL (ret);
    if ((ret=strcmp(pbd_InRecOwner[PRE_ESTMTH_NF],  pbd_InRecChild[PRE_ESTMTH_NF]))!=0)             RETURN_VAL (ret);
    if ((ret=strcmp(pbd_InRecOwner[PRE_ACMTRS_NT],  pbd_InRecChild[PRE_ACMTRS_NT]))!=0)       		RETURN_VAL (ret); 	    
	if ((ret=strcmp(pbd_InRecOwner[PRE_DETTRNCOD_CF],  pbd_InRecChild[PRE_DETTRNCOD_CF]))!=0)       RETURN_VAL (ret);
	if ((ret=strcmp(pbd_InRecOwner[PRE_GAAP_NF],  pbd_InRecChild[PRE_GAAP_NF]))!=0)       			RETURN_VAL (ret);
	
	RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction lancee quand le reserve est seul (pas de previsions)
retour :    0 ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        	// adresse de la ligne du Reserve
int n_ActionReserveSansPrev (char **ptb_InRec)
{
	double d_Montant;
	
	DEBUT_FCT("n_ActionReserveSansPrev");

	d_Montant=atof(ptb_InRec[PRE_ESTMNT_M]);
	CreationLigne(d_Montant, ptb_InRec);
	
	RETURN_VAL (0);
}
/*==============================================================================
objet :     fonction lancee quand le reserve est seul (pas de previsions)
retour :    0 ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        	// adresse de la ligne du Reserve
int n_ActionPrevSansReserve (char **ptb_InRec)
{	
	DEBUT_FCT("n_ActionPrevSansReserve");
	// On reconduit la ligne telle quelle
	n_WriteCols(Kp_LifestOFil,ptb_InRec,SEPARATEUR,0);
	
	RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee avec le 
		Reserve
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
                	/* adresse de la ligne du reserve, des previsions */
int n_ActionLignePrev (char **ptb_InRecOwner, char **ptb_InRecChild)
{
	double d_Montant;

	DEBUT_FCT("n_ActionLignePrev");
	d_Montant=atof(ptb_InRecChild[PRE_ESTMNT_M])+atof(ptb_InRecOwner[PRE_ESTMNT_M]);
	CreationLigne(d_Montant, ptb_InRecOwner);
	
	RETURN_VAL (0);
}

/*=====================================================
objet : Fonction qui écrit dans le fichier de sortie
=====================================================*/
void CreationLigne (double d_Montant,char **ptb_InRec)
{
	char sz_Montant[25];
	char sz_new_cre[20];

	sprintf(sz_Montant,"%.3lf",d_Montant);
	sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:40");
	
	ptb_InRec[PRE_ESTMNT_M]=sz_Montant;
	ptb_InRec[PRE_CRE_D]=sz_new_cre;
	
	n_WriteCols(Kp_LifestOFil,ptb_InRec,SEPARATEUR,0);
}

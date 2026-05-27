/*=============================================================================
nom de l'application          : OMEGA/Estimation
nom du source                 : ESTM2557.c
revision                      : $Revision: 1.0 $ 
date de creation              : 01/02/2021
auteur                        : B. Lagha
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Filtre sur le fichier GT Retro pour exclure les contrats 
   de type traites model et IAS39

------------------------------------------------------------------------------
Historique des modifications :
<MOD> <DATE>      <auteur>    <description de la modification>
[000] dd/mm/aaaa  P. Nom      :spiraXXXXX -

=============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/* Variables de travail */
FILE		*Kp_GTOFil;						//Fichier Prevision en sortie - Fichier sans traite model IAS39

T_RUPTURE_VAR       bd_RuptGTPere;         // gestion rupture sur GT
T_RUPTURE_SYNC_VAR  bd_RuptPeriFils;       // gestion synchro Perimetre

/* Variables Globales  */
int n_ModelIAS39 = 0;

// Fonction de synchronisation
// Fichier pere GT
int n_InitGT (T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1GT (char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionLigneGT ( char **ptb_InRec_Cur);
int n_ActionFirstGT ( char **ptb_InRec_Cur);

// Fichier Fils perimetre
int n_InitPeri (T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPeri(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLignePeri (char **ptb_InRecOwner, char **ptb_InRecChild);


/*==============================================================================
objet  :    Point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )                                      ExitPgm ( ERR_XX , "" );

    // Ouverture des fichiers
    if ( n_OpenFileAppl ("ESTM2557_O1","wt",&Kp_GTOFil) == ERR )                ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptGTPere
    if ( n_InitGT(&bd_RuptGTPere) )                                             ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptPeriFils
    if ( n_InitPeri(&bd_RuptPeriFils) )                                         ExitPgm ( ERR_XX , "" );

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGTPere) == ERR )                       ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTM2557_O1",&Kp_GTOFil))                             ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTM2557_I1",&(bd_RuptGTPere.pf_InputFil)))           ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTM2557_I2",&(bd_RuptPeriFils.pf_InputFil)))         ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                   ExitPgm ( ERR_XX , "" );

    exit(0) ;
}
/*************** Fin Main ****************/

/*============================================================================================
objet  :    Fonction d'initialisation de la variable de gestion de rupture du fichier GT.
retour :    0
============================================================================================*/
int n_InitGT (T_RUPTURE_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitGT");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTM2557_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;

    pbd_Rupt->n_ActionLigne = n_ActionLigneGT;
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstGT;
    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);	
}

/*==============================================================================
objet  :    Fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1GT");
	
	if (strcmp(ptb_InRec[GT_RETCTR_NF],ptb_InRec_Cur[GT_RETCTR_NF])!=0)           		RETURN_VAL(1);

	RETURN_VAL (0);
}

/*==============================================================================
objet :     Fonction lancee a chaque ligne syncrhonisee
==============================================================================*/
int n_ActionLigneGT ( char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLigneGT");

	n_ProcessingRuptureSyncVar(&bd_RuptPeriFils, ptb_InRec_Cur);
    // Ecrire le ficheir de sortie ICI !!
    if ( n_ModelIAS39 != 1 )
    {
        n_WriteCols(Kp_GTOFil , ptb_InRec_Cur, '~', 0 );
    }

	RETURN_VAL(0);
}

/*==============================================================================
objet :     Fonction lancee a chaque rupture premire sur contrat
==============================================================================*/
int n_ActionFirstGT ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstGT");

    // Remise a zero du flag pour chaque nouvelle rupture (changement de contrat)
    n_ModelIAS39 = 0;
    RETURN_VAL(0);
}

/*==============================================================================================
objet  :    Fonction d'initialisation de la variable de gestion de rupture du fichier perimetre.
retour :    0
==============================================================================================*/
int n_InitPeri (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitPeri");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier previsions */
    n_OpenFileAppl ("ESTM2557_I2","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture = 0;

    /* fonction du test syncro de la ligne du GT avec le perimetre */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncPeri;

    /* fonction d'action de chaque lignes du perimetre synchronisees avec le GT */
    pbd_Rupt->n_ActionLigne = n_ActionLignePeri;
    
    pbd_Rupt->c_Separ = '~';

  	RETURN_VAL (0);	
}

/*==============================================================================
objet  :    Fonction de test de synchro
retour :    0 ---> synchro
            sinon, non trouve
==============================================================================*/
int n_ConditionSyncPeri(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret;
	
  	DEBUT_FCT("n_ConditionSyncPeri");
  	
  	if ((ret=strcmp(pbd_InRecOwner[GT_RETCTR_NF],  pbd_InRecChild[PER_CTR_NF]))!=0)       			RETURN_VAL (ret);
	
	RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee pour chaque ligne du gt synchronisee avec le 
		le perimetre
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePeri (char **ptb_InRecOwner, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionLignePeri");

    if ( ( strcmp(ptb_InRecChild[PER_ASSFINANCE_CT],"2") == 0 && strcmp(ptb_InRecChild[PER_ESTCRB_CT],"D") == 0) )
    {
        n_ModelIAS39=1;
    }

	RETURN_VAL (0);
}

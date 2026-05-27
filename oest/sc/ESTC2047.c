/*==============================================================================
 * nom de l'application          : 
 * nom du source                 : ESTC2047.c
 * revision                      :
 * date de creation              : 23/07/2015
 * auteur                        : S. Behague
 * references des specifications :
 * squelette de base             : batch
 * ------------------------------------------------------------------------------
 *  description :
 *  ------------------------------------------------------------------------------
 *  historique des modifications :
 *  <jj/mm/aaaa>   <auteur>    <description de la modification>
 *   23/07/2015         SBE    spot:29253:             Création
 *
 *   _________________
 *
 *   ==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/* Fichiers */
FILE       *Kp_GT1501OFil,              // Pointeur sur le fichier GT1501 en sortie
           *Kp_GT1501IFil,              // Pointeur sur le fichier GT1501 en entrée
           *Kp_GTIFil;                  // Pointeur sur le fichier GT en entrée

T_RUPTURE_VAR       bd_RuptGT1501;      // gestion rupture sur GT1501
T_RUPTURE_SYNC_VAR  bd_RuptGT;          // gestion synchro GT1501 / GT

// Structure Pere - GT1501
int n_InitGT1501(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLastRuptGT1501(char **pbd_InRec_Cur);
int n_IsR1GT1501(char **ptb_InRec, char **ptb_InRec_Cur);

// Structure Fils - GT
int n_InitGT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionGTSansGT1501(char **ptb_InRecOwner);


int main(int argc ,char *argv[])
{
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );


    // ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2047_O1","wb",&Kp_GT1501OFil) == ERR )            ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptGT1501 - Fichier 1501 Maitre
    if ( n_InitGT1501(&bd_RuptGT1501) )                                         ExitPgm ( ERR_XX , "" );

    // Initialisation de la varible bd_RuptGT
    if ( n_InitGT(&bd_RuptGT) )                                                 ExitPgm ( ERR_XX , "" );



    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGT1501) == ERR )                       ExitPgm ( ERR_XX , "" );


    if (n_CloseFileAppl ("ESTC2047_I1",&(bd_RuptGT1501.pf_InputFil)))           ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2047_I2",&(bd_RuptGT.pf_InputFil)))               ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_O1",&Kp_GT1501OFil))                         ExitPgm ( ERR_XX , "" );
    	
    if ( n_EndPgm () == ERR )                               ExitPgm ( ERR_XX , "" );

  exit(0);
}




/*==================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du GT1501
retour :    0
==================================================================================*/
int n_InitGT1501(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitGT1501");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2047_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT1501;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGT1501;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);
}

int n_ActionLastRuptGT1501(char **pbd_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptGT1501");
    
    n_ProcessingRuptureSyncVar(&bd_RuptGT, pbd_InRec_Cur);
    
    RETURN_VAL (0);
}

int n_IsR1GT1501(char **ptb_InRec, char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1GT1501");
    
    if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_ACY_NF],ptb_InRec_Cur[GT_ACY_NF])!=0)           RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_ACMTRS_NT],ptb_InRec_Cur[GT_ACMTRS_NT])!=0)     RETURN_VAL(1);
        
    RETURN_VAL (0);
}

/*==============================================================================
objet :     Initialisation de la synchronisation du GT1501 avec le GT
retour :    0
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitGT");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier previsions */
    n_OpenFileAppl ("ESTC2047_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0;

    /* fonction du test de la ligne du GT1501 avec le GT */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncGT;

    /* fonction d'action quand le GT1501 est seul */
    pbd_Rupt->n_FilsSansPere = n_ActionGTSansGT1501;

    /* fonction d'action sur la ligne courante du fichier GT */
    pbd_Rupt->n_ActionLigne = n_ActionLigneGT;
    
    pbd_Rupt->c_Separ = '~';

 	RETURN_VAL (0);
}

int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild)
{
    DEBUT_FCT("n_ActionLigneGT");
    
    // On flagge le poste Fictif si le montant = 0
    if ( atol(pbd_InRecChild[GT_ESTAMT_M]) == 0 )
    {
        pbd_InRecChild[GT_ADJCOD_CT]="FIC";
    }
    n_WriteCols(Kp_GT1501OFil,pbd_InRecChild,SEPARATEUR,0);
    

    RETURN_VAL (0);
}

int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild)
{
    int ret;
    DEBUT_FCT("n_ConditionSyncGT");
    
    if ((ret=strcmp(ptb_InRecOwner[GT_CTR_NF],  pbd_InRecChild[GT_CTR_NF]))!=0)             RETURN_VAL (ret);
    if ((ret=strcmp(ptb_InRecOwner[GT_SEC_NF],  pbd_InRecChild[GT_SEC_NF]))!=0)             RETURN_VAL (ret);
    if ((ret=strcmp(ptb_InRecOwner[GT_UWY_NF],  pbd_InRecChild[GT_UWY_NF]))!=0)             RETURN_VAL (ret);
    if ((ret=strcmp(ptb_InRecOwner[GT_ACY_NF],  pbd_InRecChild[GT_ACY_NF]))!=0)             RETURN_VAL (ret);
    if ((ret=strcmp(ptb_InRecOwner[GT_ACMTRS_NT],  pbd_InRecChild[GT_ACMTRS_NT]))!=0)       RETURN_VAL (ret);
    
    RETURN_VAL (0);
}

int n_ActionGTSansGT1501(char **ptb_InRecOwner)
{
    DEBUT_FCT("n_ActionGTSansGT1501");

    // Si Pere sans fils on réécrit la ligne en mettant à jour le flaog pour poste fictif
    n_WriteCols(Kp_GT1501OFil,ptb_InRecOwner,SEPARATEUR,0);
    
    RETURN_VAL (0);
}
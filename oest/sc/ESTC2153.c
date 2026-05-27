/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Ventilation des complements previsionnels
nom du source                 : ESTC2153.c
revision                      : $Revision:   1.2  $
date de creation              : 22/07/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Ce traitement ventile les complements des traites de rattachements
        sur les comptes non complets dans les differents traites non cribles
        qui les composent.

                PARTIE : Creation des fichiers de rapprochements
                
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    15/04/1998   M.HA-THUC	Rajout d'une synchro supplementaire avec le
				fichier des comptes stats.
				On n'ecrit plus en sortie dans les fichiers 
				de rapprochements si l'annee de compte est
				statistiquee
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
        
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*-------------------------------------------7--*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define TAILLE_TAB_CIBLE        6000

/*----------------------------------*/


int	Kn_AnneeStat ;		/* annee statistiquee pour un traite donne */


FILE            *Kp_GTFil;              /* pointeur sur le fichier GT */
FILE            *Kp_Rappro12Fil;        /* pointeur sur les rapprochements (sortie) */
FILE            *Kp_Rappro34Fil;        /* pointeur sur les rapprochements (sortie) */
FILE            *Kp_Rappro5Fil;         /* pointeur sur les rapprochements (sortie) */


T_RUPTURE_VAR      	bd_RuptGT;      /* gestion rupture sur GT */
T_RUPTURE_SYNC_VAR      bd_RuptCptStat; /* gestion synchro avec le fichier des comptes stats */



int n_InitGT           		( T_RUPTURE_VAR *pbd_Rupt ) ;
int n_IsR1GT			( char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptR1GT   ( char **ptb_InRecOwner ) ;
int n_ActionLigneGT    		( char **ptb_InRec );

int n_InitCptStat      		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncCptStat	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLigneCptStat    ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2153_O1","wt",&Kp_Rappro12Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2153_O2","wt",&Kp_Rappro34Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2153_O3","wt",&Kp_Rappro5Fil) == ERR )
                ExitPgm ( ERR_XX , "" );
                


        /* Initialisation de la varible bd_RuptComp */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

	 /* Initialisation de la varible bd_RuptCptStat */
        if ( n_InitCptStat(&bd_RuptCptStat) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptGT) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2153_I1",&(bd_RuptGT.pf_InputFil)) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2153_I2",&(bd_RuptCptStat.pf_InputFil)) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2153_O1",&Kp_Rappro12Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2153_O2",&Kp_Rappro34Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2153_O3",&Kp_Rappro5Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );
        
        exit(0) ;
}



/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre « Liste des affaires » avec
        l’esclave « Mouvement comptable »

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{

        DEBUT_FCT( "n_InitGT" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESTC2153_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
                return ERR ;


        pbd_Rupt->n_NbRupture = 1 ;

        /* Rupture niveau 1 sur Contrat/Section */
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptR1GT;


        pbd_Rupt->n_ActionLigne = n_ActionLigneGT ; 

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre « GT des traites NC » avec
        l’esclave « fichier des comptes stat »

retour :
        OK
==============================================================================*/
int n_InitCptStat(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

        DEBUT_FCT( "n_InitCptStat" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESTC2153_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR ) 
                return ERR ;

        pbd_Rupt->n_NbRupture = 0 ;

        /* condition de synchro */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncCptStat ;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneCptStat ; 

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
        fonction de test de rupture de niveau 1 sur Contrat
        de traite non crible
retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1GT");
       
        if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
                RETURN_VAL(1);
       
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Fonction lancee en rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptR1GT    ( char **ptb_InRecOwner )
{
    DEBUT_FCT("n_ActionFirstRuptR1GT");

    /* initialisation de l'annee statistiquee */
    Kn_AnneeStat = 0 ;

    /* synchronisation avec le fichier des comptes statistiques */
    n_ProcessingRuptureSyncVar( &bd_RuptCptStat, ptb_InRecOwner ) ;

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
        FILE    *Kp_Rapprochement;
        int     resultat;


        DEBUT_FCT("n_ActionLigneComp");


         /* mode de ventilation */
         resultat = atoi(ptb_InRec_Cur[GT_SPIMOD_CT]);

         /* aiguillage selon le mode de ventilation */
         switch ( resultat ) {
             case 1:         Kp_Rapprochement = Kp_Rappro12Fil; break;
             case 2:         Kp_Rapprochement = Kp_Rappro12Fil; break;
             case 3:         Kp_Rapprochement = Kp_Rappro34Fil; break;
             case 4:         Kp_Rapprochement = Kp_Rappro34Fil; break;
             case 5:         Kp_Rapprochement = Kp_Rappro5Fil; break;
             default: return (OK) ;
         }



        if ( atoi(ptb_InRec_Cur[GT_ACY_NF]) > Kn_AnneeStat )
			n_WriteCols(Kp_Rapprochement , ptb_InRec_Cur, SEPARATEUR, 0 ) ;

        
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de synchronisation
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalite de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCptStat(
        char **pbd_InRecOwner ,         /* adresse de la ligne du maitre */
        char **pbd_InRecChild  )        /* adresse de la ligne de l'esclave */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncCptStat" ) ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 )
                return ret ;

        RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne de l'esclave

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCptStat(char **ptb_InRecOwner, char **pbd_InRecChild)
{
        DEBUT_FCT("n_ActionLigneCptStat");

        /* recherche de l'annee statistiquee */
	if ( atoi( pbd_InRecChild[CMP_ACY_NF] ) > Kn_AnneeStat )
		Kn_AnneeStat = atoi( pbd_InRecChild[CMP_ACY_NF] ) ;
        
        RETURN_VAL (0);
}



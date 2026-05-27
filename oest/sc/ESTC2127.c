/*==============================================================================
nom de l'application          : Generation Retrocession
nom du source                 : ESTC2129.c
revision                      : $Revision: 1.13 $
date de creation              : 05/01/2015
auteur                        : A. BEN JEDDOU
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
               Control pour le type de contrat Retro

------------------------------------------------------------------------------
historique des modifications :
[n° PB]  <jj/mm/aaaa>  <auteur>  <N° SPIRA>  <description de la modification>
[011]    12/12/2016     MMA     Spira : 57802   La valeur renseignée pour ACCSTS_CT dans le LIFEST et remplacée par celle du PERICASE.
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
	      *Kp_OutPREB1;       /* fichier Bilan -1 en sortie */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptPRE; /* gestion synchro GT-perimetre */

int n_InitPRE (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePRE(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPRE(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_IsR1Perim(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPerim(char **ptb_InRec_Cur);
int     Kb_rupt1;       /* 1 si rupture de niveau 1, 0 sinon */

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionFilsSansPerePRE(char **ptb_InRecChild);
int Acadmtype=0;
int     Kn_annee ;      	/* Annee Bilan */
char    Ksz_Balshey[5] ;   	/* Annee Bilan */
char 	Ksz_Balshtmth[3] ;	/* Mois Bilan */
char	Ksz_Cre[20] ;	  /* date de creation des previsions en sortie */
char  sz_Batch[2] = "1";
char      s_DateBilan[5];
/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
   char	sz_Cre[9];
        /* Initialisation des signaux */
        InitSig () ;
         
        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* ouverture des fichiers */
 
        if ( n_OpenFileAppl ("ESTC2127_O1","wt",&Kp_OutputFil) == ERR )
                  ExitPgm ( ERR_XX , "" );
        /* Recuperation de l'annee bilan */
         strcpy( Ksz_Balshey, psz_GetCharArgv(1) ) ;
         Kn_annee = atoi( Ksz_Balshey );
         strcpy(s_DateBilan, Ksz_Balshey);

	      /* Recuperation du mois bilan */
   	     strcpy( Ksz_Balshtmth, psz_GetCharArgv(3) ) ;           
       	/* Recuperation de la date de lancement du batch */
	     strcpy (sz_Cre, psz_GetCharArgv(2));           
       sprintf( Ksz_Cre, "%s %s", sz_Cre, "23:59:15" ) ;

        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPRE */
        if ( n_InitPRE(&bd_RuptPRE) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2127_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );


        if (n_CloseFileAppl("ESTC2127_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2127_I2",&(bd_RuptPRE.pf_InputFil))== ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2127_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Perim;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Perim(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Perim");

        Kb_rupt1=0;

        if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_UWY_NF],ptb_InRec_Cur[PER_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPerim(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPerim");
    Acadmtype=0;
    RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerim");
        n_ProcessingRuptureSyncVar (&bd_RuptPRE, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitPRE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPRE");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2127_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPRE ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePRE ;

 	/* fonction d'action quand le maitre n'a pas de fils PRE */
         pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPerePRE;

        pbd_Rupt->c_Separ               = SEPARATEUR ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPRE(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPRE");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[PRE_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[PRE_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[PRE_UWY_NF])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePRE(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{


        DEBUT_FCT("n_ActionLignePRE");
         char sz_acmtrs[5]="";
         double montant=0;
         char sz_Mnt[30];
         
         sprintf(sz_acmtrs,"%s",ptb_InRecChild[PRE_ACMTRS_NT]);
               
    ptb_InRecChild[PRE_ACCSTS_CT] = ptb_InRecOwner[PER_SECACCSTS_CT];                                                   //[011]
       
        if( ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 1 || atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 3 ) &&           //[008]
        ( (sz_acmtrs[3] == '3' || sz_acmtrs[3] == '4') && sz_acmtrs[1]=='3' ) )                                         //[008] [010]
    {                                                                                                                   //[008]
        // Ne rien faire                                                                                                //[008]
    }                                                                                                                   //[008]
    else                                                                                                                //[008]
    {                                                                                                                   //[008]
    	if ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 1 ||
    		 ( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) == 3    &&
    		   ( sz_acmtrs[1] == '0'    ||
    		     sz_acmtrs[1] == '1'    ||
    		     sz_acmtrs[1] == '3'    ||
    		     sz_acmtrs[1] == '5'    ||
    		     sz_acmtrs[1] == '6'
    		   ) && 
    		   ( atoi(sz_acmtrs) != 1160 && atoi(sz_acmtrs) != 2160 && atoi(sz_acmtrs) != 1303 && 
    		     atoi(sz_acmtrs) != 1323 && atoi(sz_acmtrs) != 2303 && atoi(sz_acmtrs) != 2323 && 
    		     atoi(sz_acmtrs) != 1340 && atoi(sz_acmtrs) != 2340 )  // [011]
    		 )
    		 )
    	{
    		
        ptb_InRecChild[PRE_CRE_D] = Ksz_Cre ;
        ptb_InRecChild[PRE_BATCH_B] = "1"; 
        strcpy(ptb_InRecChild[PRE_BALSHEY_NF], s_DateBilan);
        ptb_InRecChild[PRE_BALSHTMTH_NF] = Ksz_Balshtmth ;
        strcpy(ptb_InRecChild[PRE_CREUSR_CF], "dbo") ;
        ptb_InRecChild[PRE_LSTUPD_D] = Ksz_Cre ;
        strcpy(ptb_InRecChild[PRE_LSTUPDUSR_CF] , "dbo")  ;
        
        
        montant= atof(ptb_InRecChild[PRE_ESTMNT_M]); 
        sprintf(ptb_InRecChild[PRE_ACCADMTYP_CT],"%d",atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] )); 
		    sprintf(sz_Mnt,"%.3lf",0.0);
		    sprintf(ptb_InRecChild[PRE_ESTMNT_M],"%s",sz_Mnt);  
    		n_WriteCols(Kp_OutputFil , ptb_InRecChild, '~' , 0);	
    		
    	
    		sprintf(sz_Mnt,"%.3lf",montant);
		    sprintf(ptb_InRecChild[PRE_ESTMNT_M],"%s",sz_Mnt);      		
    		sprintf(ptb_InRecChild[PRE_UWY_NF],"%s", ptb_InRecChild[PRE_ACY_NF]) ;
    	
    	}
    }                                                                                                                   //[008]
    
       
       
	     n_WriteCols(Kp_OutputFil , ptb_InRecChild, '~' , 0);	
	     Acadmtype=atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] );
       RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPerePRE(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
)
{
  
         char sz_acmtrs[5]="";
         double montant=0;
         char sz_Mnt[30];
         
         sprintf(sz_acmtrs,"%s",ptb_InRecChild[PRE_ACMTRS_NT]);
        
       
  
  if( ( Acadmtype== 1 || Acadmtype == 3 ) &&           //[008]
        ( (sz_acmtrs[3] == '3' || sz_acmtrs[3] == '4') && sz_acmtrs[1]=='3' ) )                                         //[008] [010]
    {                                                                                                                   //[008]
        // Ne rien faire                                                                                                //[008]
    }                                                                                                                   //[008]
    else                                                                                                                //[008]
    {                                                                                                                   //[008]
    	if ( Acadmtype == 1 ||
    		 ( Acadmtype == 3    &&
    		   ( sz_acmtrs[1] == '0'    ||
    		     sz_acmtrs[1] == '1'    ||
    		     sz_acmtrs[1] == '3'    ||
    		     sz_acmtrs[1] == '5'    ||
    		     sz_acmtrs[1] == '6'
    		   ) && 
    		   ( atoi(sz_acmtrs) != 1160 && atoi(sz_acmtrs) != 2160 && atoi(sz_acmtrs) != 1303 && 
    		     atoi(sz_acmtrs) != 1323 && atoi(sz_acmtrs) != 2303 && atoi(sz_acmtrs) != 2323 && 
    		     atoi(sz_acmtrs) != 1340 && atoi(sz_acmtrs) != 2340 )  // [011]
    		 )
    		 )
    	{
    		ptb_InRecChild[PRE_CRE_D] = Ksz_Cre ;
        ptb_InRecChild[PRE_BATCH_B] = "1"; 
        strcpy(ptb_InRecChild[PRE_BALSHEY_NF], s_DateBilan);
        ptb_InRecChild[PRE_BALSHTMTH_NF] = Ksz_Balshtmth ;
        strcpy(ptb_InRecChild[PRE_CREUSR_CF], "dbo") ;
        ptb_InRecChild[PRE_LSTUPD_D] = Ksz_Cre ;
        strcpy(ptb_InRecChild[PRE_LSTUPDUSR_CF] , "dbo")  ;
        
        montant= atof(ptb_InRecChild[PRE_ESTMNT_M]); 
		    sprintf(sz_Mnt,"%.3lf",0.0);
		    sprintf(ptb_InRecChild[PRE_ESTMNT_M],"%s",sz_Mnt);  
    		n_WriteCols(Kp_OutputFil , ptb_InRecChild, '~' , 0);	
    		
    		sprintf(ptb_InRecChild[PRE_ACCADMTYP_CT],"%d",Acadmtype); 
    		sprintf(sz_Mnt,"%.3lf",montant);
		    sprintf(ptb_InRecChild[PRE_ESTMNT_M],"%s",sz_Mnt);      		
    		sprintf(ptb_InRecChild[PRE_UWY_NF],"%s", ptb_InRecChild[PRE_ACY_NF]) ;
    	}
    }                                                                                                                   //[008]
    
       
     
		n_WriteCols(Kp_OutputFil, ptb_InRecChild, '~' , 0);

		RETURN_VAL(OK);
}



